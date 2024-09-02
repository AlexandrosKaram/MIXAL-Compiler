%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "simple_lang.tab.h"
#include "symbol_table.h"

// Node structure for syntax tree
typedef enum { 
    NodeType_Const, NodeType_Ident, NodeType_Op, NodeType_If, NodeType_Repeat, NodeType_Read, NodeType_Write 
} NodeType;

typedef struct Node {
    NodeType type;
    union {
        int value;                // For constants
        char *name;               // For identifiers
        struct {
            int operator;         // For operators
            struct Node *left;    // Left operand
            struct Node *right;   // Right operand
        } op;
        struct {
            struct Node *condition;  // Condition for if statement
            struct Node *then_branch; // Statements to execute if condition is true
            struct Node *else_branch; // Statements to execute if condition is false (optional)
        } if_stmt;
        struct {
            struct Node *body;    // Statements to execute in the loop
            struct Node *condition; // Condition to repeat until
        } repeat_stmt;
        struct {
            struct Node *expr;    // Expression to read
        } read_stmt;
        struct {
            struct Node *expr;    // Expression to write
        } write_stmt;
    } data;
    struct Node *next; // Pointer to the next node (for statements)
} Node;

// Helper functions to create nodes
Node *createConstNode(int value);
Node *createIdentNode(char *name);
Node *createOpNode(int operator, Node *left, Node *right);
Node *createIfNode(Node *condition, Node *then_branch, Node *else_branch);
Node *createRepeatNode(Node *body, Node *condition);
Node *createReadNode(Node *expr);
Node *createWriteNode(Node *expr);

// Function to free the syntax tree
void freeNode(Node *node);

void yyerror(const char *s);
int yylex(void);

%}

%union {
    int yint;     // Integer values for constants
    char ystr[100];   // String values for identifiers
    struct Node *node;   // Node pointer for syntax tree nodes
}

// Tokens
%token <ystr> ID
%token <yint> DEC_CONST
%token IF THEN ELSE END REPEAT UNTIL READ WRITE
%token <ystr> '(' ')' ';'
%token ASSIGN EQ LT 
%token '+' '-' '*' '/'

// Define non-terminal types
%type <node> program stmt_list stmt expr rel_exp simple_exp term factor

%%

program:
    stmt_list { 
        printf("Program parsed successfully!\n"); 
        // Free the syntax tree here if needed
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
        $$ = createReadNode(createIdentNode($2)); 
    }
    | WRITE expr {
        $$ = createWriteNode($2);
    }
    ;

expr:
    rel_exp { $$ = $1; }
    ;

rel_exp:
    simple_exp { $$ = $1; }
    | rel_exp LT simple_exp { $$ = createOpNode('<', $1, $3); }
    | rel_exp EQ simple_exp { $$ = createOpNode('=', $1, $3); }
    ;

simple_exp:
    term { $$ = $1; }
    | simple_exp '+' term { $$ = createOpNode('+', $1, $3); }
    | simple_exp '-' term { $$ = createOpNode('-', $1, $3); }
    ;

term:
    factor { $$ = $1; }
    | term '*' factor { $$ = createOpNode('*', $1, $3); }
    | term '/' factor { $$ = createOpNode('/', $1, $3); }
    ;

factor:
    DEC_CONST { $$ = createConstNode($1); }
    | ID { $$ = createIdentNode($1); }
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

Node *createIfNode(Node *condition, Node *then_branch, Node *else_branch) {
    Node *node = (Node *) malloc(sizeof(Node));
    node->type = NodeType_If;
    node->data.if_stmt.condition = condition;
    node->data.if_stmt.then_branch = then_branch;
    node->data.if_stmt.else_branch = else_branch;
    node->next = NULL;
    return node;
}

Node *createRepeatNode(Node *body, Node *condition) {
    Node *node = (Node *) malloc(sizeof(Node));
    node->type = NodeType_Repeat;
    node->data.repeat_stmt.body = body;
    node->data.repeat_stmt.condition = condition;
    node->next = NULL;
    return node;
}

Node *createReadNode(Node *expr) {
    Node *node = (Node *) malloc(sizeof(Node));
    node->type = NodeType_Read;
    node->data.read_stmt.expr = expr;
    node->next = NULL;
    return node;
}

Node *createWriteNode(Node *expr) {
    Node *node = (Node *) malloc(sizeof(Node));
    node->type = NodeType_Write;
    node->data.write_stmt.expr = expr;
    node->next = NULL;
    return node;
}

void freeNode(Node *node) {
    if (node == NULL) return;
    switch (node->type) {
        case NodeType_Const:
            break;
        case NodeType_Ident:
            free(node->data.name);
            break;
        case NodeType_Op:
            freeNode(node->data.op.left);
            freeNode(node->data.op.right);
            break;
        case NodeType_If:
            freeNode(node->data.if_stmt.condition);
            freeNode(node->data.if_stmt.then_branch);
            freeNode(node->data.if_stmt.else_branch);
            break;
        case NodeType_Repeat:
            freeNode(node->data.repeat_stmt.body);
            freeNode(node->data.repeat_stmt.condition);
            break;
        case NodeType_Read:
            freeNode(node->data.read_stmt.expr);
            break;
        case NodeType_Write:
            freeNode(node->data.write_stmt.expr);
            break;
    }
    freeNode(node->next); // Free the next node
    free(node);
}

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main() {
    yyparse();
    return 0;
}