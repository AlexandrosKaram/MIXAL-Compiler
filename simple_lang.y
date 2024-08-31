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
Node *createIfNode(Node *condition, Node *thenBranch, Node *elseBranch);
Node *createRepeatNode(Node *body, Node *condition);
Node *createReadNode(char *name);
Node *createWriteNode(Node *expr);
void freeNode(Node *node);

// Error handling function
void yyerror(const char *s);
int yylex(void);
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
        // Here you could execute or further process the syntax tree starting with $1
        freeNode($1);
    }
    ;

stmt_list:
    stmt { $$ = $1; }
    | stmt_list ';' stmt { 
        Node *last = $1;
        while (last->next) last = last->next;
        last->next = $3;
        $$ = $1;
    }
    ;

stmt:
    ID ASSIGN expr { 
        $$ = createOpNode(ASSIGN, createIdentNode($1), $3); 
    }
    | IF expr THEN stmt_list END {
        $$ = createIfNode($2, $4, NULL);
    }
    | IF expr THEN stmt_list ELSE stmt_list END {
        $$ = createIfNode($2, $4, $6);
    }
    | REPEAT stmt_list UNTIL expr {
        $$ = createRepeatNode($2, $4);
    }
    | READ ID { 
        $$ = createReadNode($2);
    }
    | WRITE expr {
        $$ = createWriteNode($2);
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
    | ID { $$ = createIdentNode($1); }
    | '(' expr ')' { $$ = $2; }
    ;

%%

// Node creation functions
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

Node *createIfNode(Node *condition, Node *thenBranch, Node *elseBranch) {
    Node *node = (Node *) malloc(sizeof(Node));
    node->type = NodeType_Stmt;
    node->data.op.operator = IF;
    node->data.op.left = condition;
    node->data.op.right = thenBranch;
    node->next = elseBranch;
    return node;
}

Node *createRepeatNode(Node *body, Node *condition) {
    Node *node = (Node *) malloc(sizeof(Node));
    node->type = NodeType_Stmt;
    node->data.op.operator = REPEAT;
    node->data.op.left = body;
    node->data.op.right = condition;
    node->next = NULL;
    return node;
}

Node *createReadNode(char *name) {
    Node *node = (Node *) malloc(sizeof(Node));
    node->type = NodeType_Stmt;
    node->data.name = strdup(name);
    node->next = NULL;
    return node;
}

Node *createWriteNode(Node *expr) {
    Node *node = (Node *) malloc(sizeof(Node));
    node->type = NodeType_Stmt;
    node->data.op.operator = WRITE;
    node->data.op.left = expr;
    node->next = NULL;
    return node;
}

// Memory management for syntax tree
void freeNode(Node *node) {
    if (node == NULL) return;
    
    switch (node->type) {
        case NodeType_Ident:
            free(node->data.name);
            break;
        case NodeType_Op:
        case NodeType_Stmt:
            freeNode(node->data.op.left);
            freeNode(node->data.op.right);
            break;
        default:
            break;
    }
    free(node);
}

// Error handling function
void yyerror(const char *s) {
    fprintf(stderr, "Error at line %d: %s\n", yylineno, s);
}

// Main function
int main() {
    return yyparse();
}
