#include "symbol.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Create a new symbol
Symbol *createSymbol(char *name, int value) {
    Symbol *symbol = (Symbol *)malloc(sizeof(Symbol));
    symbol->name = strdup(name);
    symbol->value = value;
    symbol->next = NULL;
    return symbol;
}

// Insert a symbol into the symbol table
void insertSymbol(char *name, int value, Symbol **symbolTable) {
    Symbol *symbol = createSymbol(name, value);
    symbol->next = *symbolTable;
    *symbolTable = symbol;  // Update symbolTable in caller
}

// Find a symbol in the symbol table
Symbol *findSymbol(char *name, Symbol *symbolTable) {
    Symbol *current = symbolTable;
    while (current != NULL) {
        if (strcmp(current->name, name) == 0) {
            return current;
        }
        current = current->next;
    }
    return NULL;
}

// Declare a new variable in the symbol table
void declareVariable(char *name, Symbol **symbolTable) {
    if (findSymbol(name, *symbolTable) == NULL) {
        insertSymbol(name, 0, symbolTable);  // Add variable with initial value 0
    }
}

// Print the symbol table
void printSymbolTable(Symbol *symbolTable) {
    Symbol *current = symbolTable;
    printf("Symbol Table:\n");
    printf("Name\tValue\n");
    printf("----\t-----\n");
    while (current != NULL) {
        printf("%s\t%d\n", current->name, current->value);
        current = current->next;
    }
}

// Evaluate an expression in the AST using the symbol table
int evaluateExpression(AstNode *node, Symbol *symbolTable) {
    if (node == NULL) return 0;
    switch (node->nodeType) {
        case CONST_NODE: // Constant
            return atoi(node->value);  // Convert string constant to integer
        case IDENT_NODE: { // Identifier
            Symbol *symbol = findSymbol(node->value, symbolTable);
            return symbol ? symbol->value : 0;  // Return the value of the identifier
        }
        case PLUS_NODE:  // Addition
            return evaluateExpression(node->left, symbolTable) + evaluateExpression(node->right, symbolTable);
        case MINUS_NODE:  // Subtraction
            return evaluateExpression(node->left, symbolTable) - evaluateExpression(node->right, symbolTable);
        case MUL_NODE:  // Multiplication
            return evaluateExpression(node->left, symbolTable) * evaluateExpression(node->right, symbolTable);
        case DIV_NODE:  // Division
            return evaluateExpression(node->left, symbolTable) / evaluateExpression(node->right, symbolTable);
        case LT_NODE:  // Less than comparison
            return evaluateExpression(node->left, symbolTable) < evaluateExpression(node->right, symbolTable);
        case EQ_NODE:  // Equality comparison
            return evaluateExpression(node->left, symbolTable) == evaluateExpression(node->right, symbolTable);
        default:
            return 0;
    }
}

