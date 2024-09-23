#ifndef SYMBOL_H
#define SYMBOL_H

#include <stdlib.h>
#include "ast.h"

extern Symbol *symbolTable;

// Representation of a symbol
typedef struct Symbol {
    char *name;
    int value;
    int memoryLocation;
    struct Symbol *next;
} Symbol;

// Declarations
Symbol *createSymbol(char *name, int value);
void insertSymbol(char *name, int value, int memoryLocation, Symbol **symbolTable);
Symbol *findSymbol(char *name, Symbol *symbolTable);
void printSymbolTable(Symbol *symbolTable, FILE *outputFile);
void declareVariable(char *name, Symbol **symbolTable);
int evaluateExpression(AstNode *node, Symbol *symbolTable);

#endif
