#include "symbol.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int next_index = 1;    // Start memory address for variables

// Create a new symbol
Symbol *createSymbol(char *name, int value) {
    Symbol *symbol = (Symbol *)malloc(sizeof(Symbol));
    symbol->name = strdup(name);
    symbol->value = value;
    symbol->next = NULL;
    return symbol;
}

void insertSymbol(char *name, int value, int memoryLocation, Symbol **symbolTable) {
    Symbol *symbol = createSymbol(name, value);
    symbol->memoryLocation = memoryLocation;
    symbol->next = *symbolTable;
    *symbolTable = symbol;
}

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
    Symbol *existingSymbol = findSymbol(name, *symbolTable);

    if (existingSymbol == NULL) {
        int memoryLocation = next_index++;
        insertSymbol(name, 0, memoryLocation, symbolTable);
    }
}

// Print the symbol table in a new format to the output file
void printSymbolTable(Symbol *symbolTable, FILE *outputFile) {
    Symbol *current = symbolTable;
    fprintf(outputFile, "\nSymbol Table:\n");
    fprintf(outputFile, "===============\n");
    int count = 1;
    while (current != NULL) {
        fprintf(outputFile, "Symbol %d:\n", count);
        fprintf(outputFile, "  Name  : %s\n", current->name);
        fprintf(outputFile, "  Value : %d\n", current->value);
        fprintf(outputFile, "---------------\n");
        current = current->next;
        count++;
    }
    if (count == 1) {
        fprintf(outputFile, "The symbol table is empty.\n");
    }
}

// Evaluate an expression in the AST using the symbol table
int evaluateExpression(AstNode *node, Symbol *symbolTable) {
    if (node == NULL) return 0;
    switch (node->nodeType) {
        case CONST_NODE:
            return atoi(node->value);
        case IDENT_NODE: {
            Symbol *symbol = findSymbol(node->value, symbolTable);
            return symbol ? symbol->value : 0;
        }
        case PLUS_NODE:
            return evaluateExpression(node->left, symbolTable) + evaluateExpression(node->right, symbolTable);
        case MINUS_NODE:
            return evaluateExpression(node->left, symbolTable) - evaluateExpression(node->right, symbolTable);
        case MUL_NODE:
            return evaluateExpression(node->left, symbolTable) * evaluateExpression(node->right, symbolTable);
        case DIV_NODE:
            return evaluateExpression(node->left, symbolTable) / evaluateExpression(node->right, symbolTable);
        case LT_NODE:
            return evaluateExpression(node->left, symbolTable) < evaluateExpression(node->right, symbolTable);
        case EQ_NODE:
            return evaluateExpression(node->left, symbolTable) == evaluateExpression(node->right, symbolTable);
        default:
            return 0;
    }
}
