%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "simple_lang.tab.h"
#include "symbol_table.h"

// Define constants
#define N 8   // number of keywords

// Function to check if the identifier is a keyword
int id_or_keyword(char *s);

%}

%%

[0-9]+                       {
                               printf("%s\n", yytext);
                               strcpy(yylval.ystr, yytext);
                               return DEC_CONST;
                            }

"*"                           {
                               printf("%s\n", yytext);
                               strcpy(yylval.ystr, yytext);
                               return '*';
                            }

"/"                           {
                               printf("%s\n", yytext);
                               strcpy(yylval.ystr, yytext);
                               return '/';
                            }

"+"                           {
                               printf("%s\n", yytext);
                               strcpy(yylval.ystr, yytext);
                               return '+';
                            }

"-"                           {
                               printf("%s\n", yytext);
                               strcpy(yylval.ystr, yytext);
                               return '-';
                            }

"("                           {
                               printf("%s\n", yytext);
                               strcpy(yylval.ystr, yytext);
                               return '(';
                            }

")"                           {
                               printf("%s\n", yytext);
                               strcpy(yylval.ystr, yytext);
                               return ')';
                            }

";"                           {
                               printf("%s\n", yytext);
                               strcpy(yylval.ystr, yytext);
                               return ';';
                            }

":="                          {
                               printf("%s\n", yytext);
                               strcpy(yylval.ystr, yytext);
                               return ASSIGN;
                            }

"<"                           {
                               printf("%s\n", yytext);
                               strcpy(yylval.ystr, yytext);
                               return LT;
                            }

"="                           {
                               printf("%s\n", yytext);
                               strcpy(yylval.ystr, yytext);
                               return EQ;
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
                                       printf("%s\n", yytext);
                                       strcpy(yylval.ystr, yytext);
                                       insert(yytext, ID);
                                       return ID;
                                   }
                               } else {
                                   printf("%s\n", yytext);
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
