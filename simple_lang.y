%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "ast.h"  
    #include "symbol.h"
    #include "assembly_gen.h"

    Symbol *symbolTable = NULL;
    struct AstNode *root = NULL;

    FILE *outputFile;
    FILE *assemblyFile;

    void yyerror(const char *s);
    int yylex(void);
    void executeNode(struct AstNode *node);  // Execute the AST
%}

%union {
  int yint;
  char ystr[100];
  struct AstNode *node;
}

// Represent Decimal Constants
%token <yint> DEC_CONST
// Represent Identifiers
%token <ystr> ID
// Represent Keywords
%token IF THEN ELSE WRITE READ REPEAT UNTIL END
// Represent Operators
%token ASSIGN LT EQ
%token <ystr> '(' ')' ';' '+' '-' '*' '/'

// Non-terminals
%type <node> program stmt_seq stmt assign_stmt if_stmt repeat_stmt read_stmt write_stmt exp simple_exp term factor rel_exp

%%

// Initialization of the program
program:
    stmt_seq {
        $$ = createNode(PROGRAM_NODE, $1, NULL, NULL);  // Create a program node
        root = $$;
    }
    ;

// Statement sequence
stmt_seq:
    stmt_seq ';' stmt { $$ = createNode(SEQ_NODE, $1, $3, NULL); }
    | stmt { $$ = $1; }
    ;

// Statement
stmt:
    assign_stmt
    | if_stmt
    | repeat_stmt
    | read_stmt
    | write_stmt
    ;

// Assignment statement
assign_stmt:
    ID ASSIGN exp {
        $$ = createNode(ASSIGN_NODE, createNode(IDENT_NODE, NULL, NULL, $1), $3, NULL); 
    }
    ;

// If statement
if_stmt:
    IF exp THEN stmt_seq END { 
        $$ = createNode(IF_NODE, $2, $4, NULL); 
    }
    | IF exp THEN stmt_seq ELSE stmt_seq END { 
        $$ = createNode(IF_NODE, $2, createNode(ELSE_NODE, $4, $6, NULL), NULL); 
    }
    ;

// Repeat statement
repeat_stmt:
    REPEAT stmt_seq UNTIL exp { $$ = createNode(REPEAT_NODE, $2, $4, NULL); }
    ;

// Input statement
read_stmt:
    READ ID {
        $$ = createNode(READ_NODE, NULL, NULL, strdup($2)); 
    }
    ;

// Output statement
write_stmt:
    WRITE ID {
        $$ = createNode(WRITE_NODE, NULL, NULL, strdup($2)); 
    }
    ;

// Expression
exp:
    rel_exp { $$ = $1; }
    ;

// Relational expression
rel_exp:
    simple_exp
    | simple_exp LT simple_exp { $$ = createNode(LT_NODE, $1, $3, NULL); }
    | simple_exp EQ simple_exp { $$ = createNode(EQ_NODE, $1, $3, NULL); }
    ;

// Simple expression
simple_exp:
    term
    | simple_exp '+' term { $$ = createNode(PLUS_NODE, $1, $3, NULL); }
    | simple_exp '-' term { $$ = createNode(MINUS_NODE, $1, $3, NULL); }
    ;

// Term
term:
    factor
    | term '*' factor { $$ = createNode(MUL_NODE, $1, $3, NULL); }
    | term '/' factor { $$ = createNode(DIV_NODE, $1, $3, NULL); }
    ;

// Factor
factor:
    DEC_CONST { 
        char buffer[100];
        snprintf(buffer, sizeof(buffer), "%d", $1);
        $$ = createNode(CONST_NODE, NULL, NULL, strdup(buffer)); 
    }
    | ID {
        $$ = createNode(IDENT_NODE, NULL, NULL, strdup($1));
    }
    | '(' exp ')' { $$ = $2; }
    ;

%%

// Custom function to handle errors
void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

// Function to execute the AST and update the symbol table
void executeNode(AstNode *node) {
    if (node == NULL) return;

    switch (node->nodeType) {
        case PROGRAM_NODE:
            executeNode(node->left);
            break;
        case ASSIGN_NODE: {
            if (findSymbol(node->left->value, symbolTable) == NULL) {
                declareVariable(node->left->value, &symbolTable);
            }
            Symbol *symbol = findSymbol(node->left->value, symbolTable);
            if (symbol != NULL) {
                symbol->value = evaluateExpression(node->right, symbolTable);
                printf("Assigned %d to %s\n", symbol->value, node->left->value);
            }
            break;
        }
        case REPEAT_NODE: {
            do {
                executeNode(node->left);
            } while (!evaluateExpression(node->right, symbolTable));
            break;
        }
        case IF_NODE: {
            int cond = evaluateExpression(node->left, symbolTable);
            if (cond) {
                executeNode(node->right);
            } else if (node->right && node->right->nodeType == ELSE_NODE) {
                executeNode(node->right->right);
            }
            break;
        }
        case READ_NODE: {
            if (findSymbol(node->value, symbolTable) == NULL) {
                declareVariable(node->value, &symbolTable);
            }
            Symbol *symbol = findSymbol(node->value, symbolTable);
            printf("Read value for %s\n", node->value);
            break;
        }
        case WRITE_NODE: { // Handle write statement
            if (findSymbol(node->value, symbolTable) == NULL) {
                fprintf(stderr, "Semantic error: Variable %s not declared.\n", node->value);
                exit(1);
            }
            Symbol *symbol = findSymbol(node->value, symbolTable);
            if (symbol != NULL) {
                fprintf(outputFile, "%s = %d\n", node->value, symbol->value);
            }
            break;
        }
        case SEQ_NODE: { // Handle sequence of statements
            executeNode(node->left);
            executeNode(node->right);
            break;
        }
        default:
            printf("Unknown node type.\n");
            break;
    }
}


int main() {
    outputFile = fopen("output.txt", "w");
    if (outputFile == NULL) {
        fprintf(stderr, "Error opening file for writing\n");
        return 1;
    }

    yyparse();

    executeNode(root);  // Execute the AST

    fprintf(outputFile, "Syntax Tree:\n");
    printTree(root, 0, outputFile);  // Print the syntax tree to the output file
    printSymbolTable(symbolTable, outputFile);

    assemblyFile = fopen("output.mixal", "w");
    if (!assemblyFile) {
        fprintf(stderr, "Error: Could not open output file output.mixal\n");
        return 1;
    }

    printf("\nGenerating MIXAL code:\n");
    generateMixalCode(root);
    
    fclose(assemblyFile);  // Close the assembly file

    // Now print the symbol table after execution

    fclose(outputFile);     // Close the output file
    fclose(assemblyFile);   // Close the assembly file
    return 0;
}
