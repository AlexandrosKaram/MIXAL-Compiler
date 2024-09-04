#ifndef AST_H
#define AST_H

#include <stdlib.h>
#include <stdio.h>

// Representation of an Abstract Syntax Tree (AST) node
typedef struct AstNode {
    int nodeType;
    struct AstNode *left;
    struct AstNode *right;
    char *value;
} AstNode;

// Declarations (no implementation here)
AstNode *createNode(int nodeType, AstNode *left, AstNode *right, char *value);
void printTree(AstNode *node, int level, FILE *outputFile);

#endif
