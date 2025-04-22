%{
#include <stdio.h>
#include "parser.tab.h"
#include <string.h>

int line = 1;
int first_token = 1;  // Flag to print header

// Function to print table header
void print_header() {
    printf("+---------+---------------+--------------------+-----------+\n");
    printf("| Line No | Token Type    | Lexeme            | Token ID  |\n");
    printf("+---------+---------------+--------------------+-----------+\n");
}

// Function to print token in table format
void print_token(int line, const char* type, const char* lexeme, int token_id) {
    if (first_token) {
        print_header();
        first_token = 0;
    }
    printf("| %-7d | %-13s | %-18s | %-9d |\n", line, type, lexeme, token_id);
}

// Function to print comment in table format
void print_comment(int line, const char* comment) {
    if (first_token) {
        print_header();
        first_token = 0;
    }
    printf("| %-7d | %-13s | %-18s | %-9s |\n", line, "Comment", comment, "-");
}
%}

DIGIT   [0-9]
LETTER  [a-zA-Z_]
ID      {LETTER}({LETTER}|{DIGIT})*
STRING  \"([^\"]*)\"

%%

"query"         { print_token(line, "Keyword", yytext, 1); yylval.sval = strdup(yytext); return QUERY; }
"mutation"      { print_token(line, "Keyword", yytext, 2); yylval.sval = strdup(yytext); return MUTATION; }
"subscription"  { print_token(line, "Keyword", yytext, 3); yylval.sval = strdup(yytext); return SUBSCRIPTION; }
"fragment"      { print_token(line, "Keyword", yytext, 4); yylval.sval = strdup(yytext); return FRAGMENT; }
"on"            { print_token(line, "Keyword", yytext, 5); yylval.sval = strdup(yytext); return ON; }
"true"          { print_token(line, "Literal", yytext, 1); yylval.sval = strdup(yytext); return TRUE; }
"false"         { print_token(line, "Literal", yytext, 2); yylval.sval = strdup(yytext); return FALSE; }
"null"          { print_token(line, "Literal", yytext, 3); yylval.sval = strdup(yytext); return NULL_VAL; }

"{"             { print_token(line, "Symbol", yytext, 1); return LBRACE; }
"}"             { print_token(line, "Symbol", yytext, 2); return RBRACE; }
"("             { print_token(line, "Symbol", yytext, 3); return LPAREN; }
")"             { print_token(line, "Symbol", yytext, 4); return RPAREN; }
"["             { print_token(line, "Symbol", yytext, 5); return LBRACKET; }
"]"             { print_token(line, "Symbol", yytext, 6); return RBRACKET; }
":"             { print_token(line, "Symbol", yytext, 7); return COLON; }
"@"             { print_token(line, "Symbol", yytext, 8); return AT; }
"!"             { print_token(line, "Symbol", yytext, 9); return BANG; }
"="             { print_token(line, "Symbol", yytext, 10); return EQUAL; }
"..."           { print_token(line, "Symbol", yytext, 11); return ELLIPSIS; }

{ID}            { print_token(line, "Identifier", yytext, 0); yylval.sval = strdup(yytext); return IDENTIFIER; }
{STRING}        { print_token(line, "Literal", yytext, 0); yylval.sval = strdup(yytext); return STRING_LITERAL; }
{DIGIT}+        { print_token(line, "Literal", yytext, 0); yylval.ival = atoi(yytext); return INT_LITERAL; }
{DIGIT}+"."{DIGIT}+ { print_token(line, "Literal", yytext, 0); yylval.fval = atof(yytext); return FLOAT_LITERAL; }

[ \t]+          ;  /* Ignore whitespaces */
\n              { line++; }  /* Increment line number on newline */
"#".*           { print_comment(line, yytext); }  /* Print comments in table format */

.               { printf("Line %d: Unknown character: %s\n", line, yytext); }

%%

int yywrap() { 
    printf("+---------+---------------+--------------------+-----------+\n");
    return 1; 
}