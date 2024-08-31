%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Node structure for syntax tree
typedef enum { 
    NodeType_Const, NodeType_Ident, NodeType_Op, NodeType_Stmt, NodeType_Expr 
} NodeType;

typedef struct Node {
    NodeType type;
    union {
        int value;               // For constants
        char *name;              // For identifiers
        struct {
            int operator;        // For operators
            struct Node *left;   // Left operand
            struct Node *right;  // Right operand
        } op;
    } data;
    struct Node *next; // Pointer to the next node (for statements)
} Node;

// Helper functions to create nodes
Node *createConstNode(int value);
Node *createIdentNode(char *name);
Node *createOpNode(int operator, Node *left, Node *right);

// Define yylval union
%}

%union {
    int ival;
    char *sval;
    Node *node;
}

// Tokens
%token DEC_CONST ID
%token IF THEN ELSE END REPEAT UNTIL READ WRITE
%token ASSIGN '<' '=' '+' '-' '*' '/'

%type <node> program stmt_list stmt expr term factor

%%

program:
    stmt_list { 
        printf("Program parsed successfully!\n"); 
    }
    ;

stmt_list:
    stmt { $$ = $1; }
    | stmt_list stmt { 
        Node *last = $1;
        while (last->next) last = last->next;
        last->next = $2;
        $$ = $1;
    }
    ;

stmt:
    ID ASSIGN expr { 
        $$ = createOpNode(ASSIGN, createIdentNode($1), $3); 
    }
    | IF expr THEN stmt_list END {
        // Create IF node here (not implemented in this example)
    }
    | REPEAT stmt_list UNTIL expr {
        // Create REPEAT node here (not implemented in this example)
    }
    | READ ID { 
        // Create READ node here (not implemented in this example)
    }
    | WRITE expr {
        // Create WRITE node here (not implemented in this example)
    }
    ;

expr:
    expr '+' term { $$ = createOpNode('+', $1, $3); }
    | expr '-' term { $$ = createOpNode('-', $1, $3); }
    | term { $$ = $1; }
    ;

term:
    term '*' factor { $$ = createOpNode('*', $1, $3); }
    | term '/' factor { $$ = createOpNode('/', $1, $3); }
    | factor { $$ = $1; }
    ;

factor:
    DEC_CONST { $$ = createConstNode(atoi(yytext)); }
    | ID { $$ = createIdentNode(yytext); }
    | '(' expr ')' { $$ = $2; }
    ;

%%

Node *createConstNode(int value) {
    Node *node = (Node *) malloc(sizeof(Node));
    node->type = NodeType_Const;
    node->data.value = value;
    node->next = NULL;
    return node;
}

Node *createIdentNode(char *name) {
    Node *node = (Node *) malloc(sizeof(Node));
    node->type = NodeType_Ident;
    node->data.name = strdup(name);
    node->next = NULL;
    return node;
}

Node *createOpNode(int operator, Node *left, Node *right) {
    Node *node = (Node *) malloc(sizeof(Node));
    node->type = NodeType_Op;
    node->data.op.operator = operator;
    node->data.op.left = left;
    node->data.op.right = right;
    node->next = NULL;
    return node;
}

// Error handling function
void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

// Main function
int main() {
    return yyparse();
}
