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
    void executeNode(struct AstNode *node);
%}

%union {
  int yint;
  char ystr[100];
  struct AstNode *node;
}

%token <yint> DEC_CONST
%token <ystr> ID
%token IF THEN ELSE WRITE READ REPEAT UNTIL END
%token EQ
%token ASSIGN LT
%token <ystr> '(' ')' ';'
%token <ystr> '+' '-' '*' '/'

%type <node> program stmt_seq stmt assign_stmt if_stmt repeat_stmt read_stmt write_stmt exp simple_exp term factor rel_exp

%%

program:
    stmt_seq { root = $1; }  // Store root of AST in global variable
    ;

stmt_seq:
    stmt_seq ';' stmt { $$ = createNode(';', $1, $3, NULL); }
    | stmt { $$ = $1; }
    ;

stmt:
    assign_stmt
    | if_stmt
    | repeat_stmt
    | read_stmt
    | write_stmt
    ;

assign_stmt:
    ID ASSIGN exp {
        $$ = createNode('=', createNode('I', NULL, NULL, $1), $3, NULL); 
    }
    ;

if_stmt:
    IF exp THEN stmt_seq END { 
        $$ = createNode('I', $2, $4, NULL); 
    }
    | IF exp THEN stmt_seq ELSE stmt_seq END { 
        $$ = createNode('I', $2, createNode('E', $4, $6, NULL), NULL); 
    }
    ;

repeat_stmt:
    REPEAT stmt_seq UNTIL exp { $$ = createNode('R', $2, $4, NULL); }
    ;

read_stmt:
    READ ID {
        $$ = createNode('L', NULL, NULL, strdup($2)); 
    }
    ;

write_stmt:
    WRITE ID {
        $$ = createNode('W', NULL, NULL, strdup($2)); 
    }
    ;

exp:
    rel_exp { $$ = $1; }
    ;

rel_exp:
    simple_exp
    | simple_exp LT simple_exp { $$ = createNode('<', $1, $3, NULL); }
    | simple_exp EQ simple_exp { $$ = createNode('=', $1, $3, NULL); }
    ;

simple_exp:
    term
    | simple_exp '+' term { $$ = createNode('+', $1, $3, NULL); }
    | simple_exp '-' term { $$ = createNode('-', $1, $3, NULL); }
    ;

term:
    factor
    | term '*' factor { $$ = createNode('*', $1, $3, NULL); }
    | term '/' factor { $$ = createNode('/', $1, $3, NULL); }
    ;

factor:
    DEC_CONST { 
        char buffer[100];
        snprintf(buffer, sizeof(buffer), "%d", $1);
        $$ = createNode('N', NULL, NULL, strdup(buffer)); 
    }
    | ID {
        $$ = createNode('I', NULL, NULL, strdup($1));
    }
    | '(' exp ')' { $$ = $2; }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

void executeNode(AstNode *node) {
    if (node == NULL) return;

    switch (node->nodeType) {
        case 'I': { // If statement
            int cond = evaluateExpression(node->left, symbolTable);
            if (cond) {
                executeNode(node->right); // Execute THEN block
            } else if (node->right && node->right->nodeType == 'E') {
                executeNode(node->right->right); // Execute ELSE block if exists
            }
            break;
        }
        case '=': { // Assignment
            if (findSymbol(node->left->value, symbolTable) == NULL) {
                declareVariable(node->left->value, &symbolTable); 
            }
            Symbol *symbol = findSymbol(node->left->value, symbolTable);
            if (symbol != NULL) {
                symbol->value = evaluateExpression(node->right, symbolTable);
                fprintf(outputFile, "Assigned %d to %s\n", symbol->value, node->left->value);
            }
            break;
        }
        case 'R': { // Repeat statement
            do {
                executeNode(node->left); // Execute block
            } while (!evaluateExpression(node->right, symbolTable)); 
            break;
        }
        case 'L': { // Read statement
            if (findSymbol(node->value, symbolTable) == NULL) {
                declareVariable(node->value, &symbolTable);
            }
            fprintf(outputFile, "Reading value for %s\n", node->value);
            break;
        }
        case 'W': { // Write statement
            if (findSymbol(node->value, symbolTable) == NULL) {
                fprintf(stderr, "Semantic Error: Undeclared variable %s\n", node->value);
                exit(1);
            }
            Symbol *symbol = findSymbol(node->value, symbolTable);
            if (symbol != NULL) {
                fprintf(outputFile, "Value of %s: %d\n", node->value, symbol->value);
            }
            break;
        }
        case ';': { // Sequence of statements
            executeNode(node->left);
            executeNode(node->right);
            break;
        }
        default:
            fprintf(outputFile, "Unknown node type: %c\n", node->nodeType);
            break;
    }
}

int main() {
    // Open a file for writing (output.txt in the same directory)
    outputFile = fopen("output.txt", "w");
    if (outputFile == NULL) {
        fprintf(stderr, "Error opening file for writing\n");
        return 1;
    }

    yyparse(); 

    fprintf(outputFile, "Syntax Tree:\n");
    printTree(root, 0, outputFile);  // Pass the file pointer to this function
    fprintf(outputFile, "\nExecuting program:\n");
    executeNode(root);
    printSymbolTable(symbolTable); 

    fclose(outputFile);  // Close the file when done
    return 0;
}
