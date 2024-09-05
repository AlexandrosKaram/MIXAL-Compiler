#ifndef AST_H
#define AST_H

#include <stdlib.h>
#include <stdio.h>

// Define the types of AST nodes as an enum for readability
typedef enum {
    IF_NODE,
    ASSIGN_NODE,
    REPEAT_NODE,
    READ_NODE,
    WRITE_NODE,
    CONST_NODE,
    IDENT_NODE,
    PLUS_NODE,
    MINUS_NODE,
    MUL_NODE,
    DIV_NODE,
    LT_NODE,
    EQ_NODE,
    SEQ_NODE
} NodeType;

// Representation of an Abstract Syntax Tree (AST) node
typedef struct AstNode {
    NodeType nodeType;  // Use enum for node type instead of char
    struct AstNode *left;
    struct AstNode *right;
    char *value;  // Value is used for identifiers and constants
} AstNode;

// Declarations
AstNode *createNode(NodeType nodeType, AstNode *left, AstNode *right, char *value);
void printTree(AstNode *node, int level, FILE *outputFile);

#endif
