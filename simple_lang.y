%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "ast.h"  
    #include "symbol.h"

    Symbol *symbolTable = NULL;
    struct AstNode *root = NULL;

    FILE *outputFile;  // Declare the file pointer globally or in main

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
    stmt_seq { root = $1; }  // Store root of AST in global variable
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
        $$ = createNode(IF_NODE, $2, createNode(SEQ_NODE, $4, $6, NULL), NULL); 
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
        case ASSIGN_NODE: { // Handle assignments
            Symbol *symbol = findSymbol(node->left->value, symbolTable);
            if (symbol == NULL) {
                declareVariable(node->left->value, &symbolTable);  // Declare the variable if not found
                symbol = findSymbol(node->left->value, symbolTable);
            }
            if (symbol != NULL) {
                symbol->value = evaluateExpression(node->right, symbolTable);  // Evaluate the right-hand side and assign the value
            }
            break;
        }
        case IF_NODE: { // Handle if statements
            int condition = evaluateExpression(node->left, symbolTable);  // Evaluate condition
            if (condition) {
                executeNode(node->right);  // Execute THEN branch
            }
            break;
        }
        case WRITE_NODE: { // Handle write statement
            Symbol *symbol = findSymbol(node->value, symbolTable);
            if (symbol != NULL) {
                /* fprintf(outputFile, "Value of %s: %d\n", node->value, symbol->value);  // Write the value of the variable to the output file */
            }
            break;
        }
        case SEQ_NODE: { // Handle sequence of statements
            executeNode(node->left);
            executeNode(node->right);
            break;
        }
        default:
            break;
    }
}

int main() {
    outputFile = fopen("output.txt", "w");
    if (outputFile == NULL) {
        fprintf(stderr, "Error opening file for writing\n");
        return 1;
    }

    yyparse();  // Parse the input program and build the AST

    fprintf(outputFile, "Syntax Tree:\n");
    printTree(root, 0, outputFile);  // Print the syntax tree to the output file

    // Execute the AST to populate the symbol table and perform write operations
    executeNode(root);

    // Now print the symbol table after execution
    printSymbolTable(symbolTable, outputFile);

    fclose(outputFile);  // Close the file when done
    return 0;
}
