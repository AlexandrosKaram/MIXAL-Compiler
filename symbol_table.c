#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol_table.h"

// Symbol table as an array of pointers to Symbol
Symbol *symbolTable[HASH_SIZE] = { NULL };

// Hash function for symbols
unsigned int hash(char *s) {
    unsigned int hashval = 0;
    while (*s != '\0') {
        hashval = *s + 31 * hashval;
        s++;
    }
    return hashval % HASH_SIZE;
}

// Lookup function for finding a symbol in the table
Symbol *lookup(char *name) {
    unsigned int hashval = hash(name);
    for (Symbol *sym = symbolTable[hashval]; sym != NULL; sym = sym->next) {
        if (strcmp(sym->name, name) == 0) {
            return sym; // Found symbol
        }
    }
    return NULL; // Not found
}

// Insert function for adding a new symbol to the table
Symbol *insert(char *name, int token) {
    unsigned int hashval = hash(name);
    Symbol *sym = (Symbol *)malloc(sizeof(Symbol));
    if (sym == NULL) {
        fprintf(stderr, "Out of memory for symbols!\n");
        exit(1);
    }
    sym->name = strdup(name);
    sym->token = token;
    sym->next = symbolTable[hashval];
    symbolTable[hashval] = sym;
    return sym;
}

// Function to free the entire symbol table
void free_symbol_table(void) {
    for (int i = 0; i < HASH_SIZE; i++) {
        Symbol *sym = symbolTable[i];
        while (sym != NULL) {
            Symbol *next = sym->next;
            free(sym->name);
            free(sym);
            sym = next;
        }
        symbolTable[i] = NULL;
    }
}
