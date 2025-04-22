%{
#include <stdio.h>
#include "parser.tab.h"
#include <string.h>

int line = 1;
%}

DIGIT   [0-9]
LETTER  [a-zA-Z_]
ID      {LETTER}({LETTER}|{DIGIT})*
STRING  \"([^\"]*)\"

%%

"query"         { printf("Line No: %d, Token Type: Keyword, Lexeme: %s Token_ID: 1\n\n", line, yytext); yylval.sval = strdup(yytext); return QUERY; }
"mutation"      { printf("Line No: %d, Token Type: Keyword, Lexeme: %s Token_ID: 2\n\n", line, yytext); yylval.sval = strdup(yytext); return MUTATION; }
"subscription"  { printf("Line No: %d, Token Type: Keyword, Lexeme: %s Token_ID: 3\n\n", line, yytext); yylval.sval = strdup(yytext); return SUBSCRIPTION; }
"fragment"      { printf("Line No: %d, Token Type: Keyword, Lexeme: %s Token_ID: 4\n\n", line, yytext); yylval.sval = strdup(yytext); return FRAGMENT; }
"on"            { printf("Line No: %d, Token Type: Keyword, Lexeme: %s Token_ID: 5\n\n", line, yytext); yylval.sval = strdup(yytext); return ON; }
"true"          { printf("Line No: %d, Token Type: Literal, Lexeme: %s Token_ID: 1\n\n", line, yytext); yylval.sval = strdup(yytext); return TRUE; }
"false"         { printf("Line No: %d, Token Type: Literal, Lexeme: %s Token_ID: 2\n\n", line, yytext); yylval.sval = strdup(yytext); return FALSE; }
"null"          { printf("Line No: %d, Token Type: Literal, Lexeme: %s Token_ID: 3\n\n", line, yytext); yylval.sval = strdup(yytext); return NULL_VAL; }

"{"             { printf("Line No: %d, Token Type: Symbol, Lexeme: %s Token_ID: 1\n\n", line, yytext); return LBRACE; }
"}"             { printf("Line No: %d, Token Type: Symbol, Lexeme: %s Token_ID: 2\n\n", line, yytext); return RBRACE; }
"("             { printf("Line No: %d, Token Type: Symbol, Lexeme: %s Token_ID: 3\n\n", line, yytext); return LPAREN; }
")"             { printf("Line No: %d, Token Type: Symbol, Lexeme: %s Token_ID: 4\n\n", line, yytext); return RPAREN; }
"["             { printf("Line No: %d, Token Type: Symbol, Lexeme: %s Token_ID: 5\n\n", line, yytext); return LBRACKET; }
"]"             { printf("Line No: %d, Token Type: Symbol, Lexeme: %s Token_ID: 6\n\n", line, yytext); return RBRACKET; }
":"             { printf("Line No: %d, Token Type: Symbol, Lexeme: %s Token_ID: 7\n\n", line, yytext); return COLON; }
"@"             { printf("Line No: %d, Token Type: Symbol, Lexeme: %s Token_ID: 8\n\n", line, yytext); return AT; }
"!"             { printf("Line No: %d, Token Type: Symbol, Lexeme: %s Token_ID: 9\n\n", line, yytext); return BANG; }
"="             { printf("Line No: %d, Token Type: Symbol, Lexeme: %s Token_ID: 10\n\n", line, yytext); return EQUAL; }
"..."           { printf("Line No: %d, Token Type: Symbol, Lexeme: %s Token_ID: 11\n\n", line, yytext); return ELLIPSIS; }

{ID}            { printf("Line No: %d, Token Type: Identifier, Lexeme: %s\n\n", line, yytext); yylval.sval = strdup(yytext); return IDENTIFIER; }

{STRING}        { printf("Line No: %d, Token Type: Literal, Lexeme: %s\n\n", line, yytext); yylval.sval = strdup(yytext); return STRING_LITERAL; }
{DIGIT}+        { printf("Line No: %d, Token Type: Literal, Lexeme: %s\n\n", line, yytext); 
                  yylval.ival = atoi(yytext); return INT_LITERAL; }
{DIGIT}+"."{DIGIT}+ { printf("Line No: %d, Token Type: Literal, Lexeme: %s\n\n", line, yytext); 
                  yylval.fval = atof(yytext); return FLOAT_LITERAL; }

[ \t]+          ;  /* Ignore whitespaces */
\n              { line++; }  /* Increment line number on newline */
"#".*           { printf("Line No: %d, Comment: %s\n", line, yytext); }  /* Ignore comments but print them */

.               { printf("Line No: %d, Unknown character: %s\n", line, yytext); }

%%

int yywrap() { return 1; }