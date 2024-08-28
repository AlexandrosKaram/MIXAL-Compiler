%{
#include <stdio.h>
#include <string.h>
#include "y.tab.h"

int id_or_keyword(char *s);
#define N 8   // number of keywords

%}

%%

[0-9]+ {
    printf("%s", yytext);    
}
"*" {
    printf("*");
}
"/" {
    printf("/");
}
"+" {
    printf("+");
}
"-" {
    printf("-");
}
"(" {
    printf("(");
}
")" {
    printf(")");
}
";" {
    printf(";");
}
":=" {
    printf(":=");
}
"<" {
    printf("<");
}
"=" {
    printf("=");
}
[a-zA-Z][a-zA-Z0-9]* {
    int keyword_index = id_or_keyword(yytext);
    if (keyword_index != 0) {
        printf("Keyword: %s\n", yytext);
    } else {
        printf("ID: %s\n", yytext); 
    }
}
[\t\n\r\f]+ {
    // ignore whitespace
}
. {
    printf("Invalid character: %s\n", yytext);
}

%%

static char *kid[N] = {
    "if", "repeat", "read", "write", "then", "end", "else", "until"
};

// return 0 if s is not a keyword
int id_or_keyword(char *s) {
    int i;
    // loop through all keywords
    for (i = 0; i < N; i++) {
        if (strcmp(s, kid[i]) == 0) {
            return i;   // return index of keyword
        }
    }
    return 0;
}

int main(void) {
    yylex();
}
