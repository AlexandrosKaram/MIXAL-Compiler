#include "ast.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Function to create an AST node
AstNode *createNode(int nodeType, AstNode *left, AstNode *right, char *value) {
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
    for (int i = 0; i < level; i++) fprintf(outputFile, "  ");  // Use fprintf
    fprintf(outputFile, "%c", node->nodeType);  // Use fprintf
    if (node->value) fprintf(outputFile, " (%s)", node->value);  // Use fprintf
    fprintf(outputFile, "\n");
    printTree(node->left, level + 1, outputFile);
    printTree(node->right, level + 1, outputFile);
}
