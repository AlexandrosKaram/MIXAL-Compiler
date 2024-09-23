#include "ast.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Function to create an AST node
AstNode *createNode(NodeType nodeType, AstNode *left, AstNode *right, char *value) {
    AstNode *node = (AstNode *)malloc(sizeof(AstNode));
    node->nodeType = nodeType;
    node->left = left;
    node->right = right;
    node->value = value ? strdup(value) : NULL;
    return node;
}

// Function to print the AST
void printTree(AstNode *node, int level, FILE *outputFile) {
    if (node == NULL) return;
    for (int i = 0; i < level; i++) fprintf(outputFile, "  ");

    // Print the node type based on the enum
    switch (node->nodeType) {
        case PROGRAM_NODE: fprintf(outputFile, "PROGRAM"); break;
        case IF_NODE: fprintf(outputFile, "IF"); break;
        case ELSE_NODE: fprintf(outputFile, "ELSE"); break;
        case ASSIGN_NODE: fprintf(outputFile, "ASSIGN"); break;
        case REPEAT_NODE: fprintf(outputFile, "REPEAT"); break;
        case READ_NODE: fprintf(outputFile, "READ"); break;
        case WRITE_NODE: fprintf(outputFile, "WRITE"); break;
        case CONST_NODE: fprintf(outputFile, "CONST"); break;
        case IDENT_NODE: fprintf(outputFile, "IDENT"); break;
        case PLUS_NODE: fprintf(outputFile, "PLUS"); break;
        case MINUS_NODE: fprintf(outputFile, "MINUS"); break;
        case MUL_NODE: fprintf(outputFile, "MUL"); break;
        case DIV_NODE: fprintf(outputFile, "DIV"); break;
        case LT_NODE: fprintf(outputFile, "LT"); break;
        case EQ_NODE: fprintf(outputFile, "EQ"); break;
        case SEQ_NODE: fprintf(outputFile, "SEQ"); break;
        default: fprintf(outputFile, "UNKNOWN"); break;
    }

    if (node->value) fprintf(outputFile, " (%s)", node->value);
    fprintf(outputFile, "\n");
    printTree(node->left, level + 1, outputFile);
    printTree(node->right, level + 1, outputFile);
}
