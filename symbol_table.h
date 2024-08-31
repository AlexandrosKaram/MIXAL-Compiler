#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

// Define the Symbol structure
typedef struct Symbol {
    char *name;               // Name of the symbol
    int token;                // Token type (e.g., ID, keyword)
    struct Symbol *next;      // Pointer to next symbol in case of hash collision
} Symbol;

#define HASH_SIZE 101

// Function declarations
unsigned int hash(char *s);
Symbol *lookup(char *name);
Symbol *insert(char *name, int token);
void free_symbol_table(void);

#endif // SYMBOL_TABLE_H
