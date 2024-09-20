#ifndef ASSEMBLY_GEN_H
#define ASSEMBLY_GEN_H

#include "ast.h"

// Αρχικοποίηση του αρχείου εξόδου για τη δημιουργία του κώδικα
void initAssembly(const char *filename);

// Συνάρτηση που δημιουργεί κώδικα για εντολές ανάθεσης
void generateAssign(AstNode *node);

// Συνάρτηση που δημιουργεί κώδικα για εντολές if
void generateIf(AstNode *node);

// Συνάρτηση που δημιουργεί κώδικα για εντολές repeat
void generateRepeat(AstNode *node);

// Συνάρτηση που δημιουργεί κώδικα για εντολές write
void generateWrite(AstNode *node);

// Συνάρτηση που δημιουργεί κώδικα για εντολές read
void generateRead(AstNode *node);

// Συνάρτηση που δημιουργεί κώδικα για εκφράσεις
void generateExp(AstNode *node);

// Ολοκλήρωση της εξαγωγής του κώδικα
void finalizeAssembly(void);

#endif // ASSEMBLY_GEN_H
