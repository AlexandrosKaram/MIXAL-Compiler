%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "simple_lang.tab.h"

// Define constants
#define N 8   // number of keywords

// Symbol table functions
typedef struct Symbol {
    char *name;
    int token;       // Token type (e.g., ID, keyword)
    struct Symbol *next; // Pointer to next symbol in case of hash collision
} Symbol;

#define HASH_SIZE 101

Symbol *symbolTable[HASH_SIZE];

// Hash function
unsigned int hash(char *s) {
    unsigned int hashval;
    for (hashval = 0; *s != '\0'; s++) {
        hashval = *s + 31 * hashval;
    }
    return hashval % HASH_SIZE;
}

// Lookup symbol in the symbol table
Symbol *lookup(char *name) {
    Symbol *sp;
    for (sp = symbolTable[hash(name)]; sp != NULL; sp = sp->next) {
        if (strcmp(sp->name, name) == 0)
            return sp; // found
    }
    return NULL; // not found
}

// Insert symbol into the symbol table
Symbol *insert(char *name, int token) {
    Symbol *sp;
    unsigned int hashval;

    if ((sp = lookup(name)) == NULL) {
        sp = (Symbol *) malloc(sizeof(*sp));
        if (sp == NULL || (sp->name = strdup(name)) == NULL)
            return NULL;

        hashval = hash(name);
        sp->token = token;
        sp->next = symbolTable[hashval];
        symbolTable[hashval] = sp;
    }
    return sp;
}

// Function to check if the identifier is a keyword
int id_or_keyword(char *s);

%}

%%

[0-9]+                       {
                               strcpy(yylval.ystr, yytext);
                               return DEC_CONST;
                            }

"*"                           {
                               strcpy(yylval.ystr, yytext);
                               return '*';
                            }

"/"                           {
                               strcpy(yylval.ystr, yytext);
                               return '/';
                            }

"+"                           {
                               strcpy(yylval.ystr, yytext);
                               return '+';
                            }

"-"                           {
                               strcpy(yylval.ystr, yytext);
                               return '-';
                            }

"("                           {
                               strcpy(yylval.ystr, yytext);
                               return '(';
                            }

")"                           {
                               strcpy(yylval.ystr, yytext);
                               return ')';
                            }

";"                           {
                               strcpy(yylval.ystr, yytext);
                               return ';';
                            }

":="                          {
                               strcpy(yylval.ystr, yytext);
                               return ASSIGN;
                            }

"<"                           {
                               strcpy(yylval.ystr, yytext);
                               return '<';
                            }

"="                           {
                               strcpy(yylval.ystr, yytext);
                               return '=';
                            }

[a-zA-Z][a-zA-Z0-9]*          {
                               Symbol *sym = lookup(yytext);
                               if (!sym) {
                                   int token_type = id_or_keyword(yytext);
                                   if (token_type) {
                                       yylval.yint = token_type;
                                       insert(yytext, token_type);
                                       return token_type;
                                   } else {
                                       strcpy(yylval.ystr, yytext);
                                       insert(yytext, ID);
                                       return ID;
                                   }
                               } else {
                                   strcpy(yylval.ystr, yytext);
                                   return sym->token;
                               }
                            }

[ \t\n\f\r]+                  ; // ignore whitespace

.                             {
                               printf("Illegal character %s\n", yytext);
                               return 0;
                            }

%%

// Keywords and their corresponding token types
static char *keywords[N] = {
    "if", "then", "else", "end", "repeat", "until", "read", "write"
};

static int keyword_tokens[N] = {
    IF, THEN, ELSE, END, REPEAT, UNTIL, READ, WRITE
};

int id_or_keyword(char *s) {
    for (int i = 0; i < N; i++) {
        if (strcmp(s, keywords[i]) == 0) {
            return keyword_tokens[i];
        }
    }
    return 0; // ID
}
