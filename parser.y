%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);
int yylex();
extern FILE *yyin;
extern int line;

/* Simple symbol table implementation */
#define MAX_SYMBOLS 100
#define MAX_NAME_LEN 100

typedef enum {
    TYPE_OPERATION,
    TYPE_FRAGMENT
} SymbolType;

typedef struct {
    char name[MAX_NAME_LEN];
    SymbolType type;
    int line;
} Symbol;

Symbol symbol_table[MAX_SYMBOLS];
int symbol_count = 0;

/* Semantic analysis functions */
int add_symbol(const char *name, SymbolType type, int line) {
    if (symbol_count >= MAX_SYMBOLS) {
        fprintf(stderr, "Symbol table full\n");
        return 0;
    }
    
    /* Check if symbol already exists */
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbol_table[i].name, name) == 0 && symbol_table[i].type == type) {
            fprintf(stderr, "Semantic Error at line %d: %s already defined at line %d\n", 
                    line, name, symbol_table[i].line);
            return 0;
        }
    }
    
    /* Add new symbol */
    strcpy(symbol_table[symbol_count].name, name);
    symbol_table[symbol_count].type = type;
    symbol_table[symbol_count].line = line;
    symbol_count++;
    return 1;
}

int find_symbol(const char *name, SymbolType type) {
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbol_table[i].name, name) == 0 && symbol_table[i].type == type) {
            return 1;
        }
    }
    return 0;
}

int semantic_errors = 0;
%}

/* Union for token values */
%union {
    char *sval;
    int ival;
    float fval;
}

/* Token Definitions */
%token <sval> QUERY MUTATION SUBSCRIPTION FRAGMENT ON IDENTIFIER
%token <sval> STRING_LITERAL TRUE FALSE NULL_VAL
%token <ival> INT_LITERAL
%token <fval> FLOAT_LITERAL
%token LBRACE RBRACE LPAREN RPAREN LBRACKET RBRACKET COLON AT BANG EQUAL ELLIPSIS

/* Non-terminal type declarations */
%type <sval> operation_type

%%

document:
    definition_list { 
        if (semantic_errors == 0) {
            printf("\n\nGraphQL query parsed successfully.\n");
            printf("Semantic analysis: No errors found. Document is semantically correct.\n");
        } else {
            printf("\n\nGraphQL query parsed with %d semantic error(s).\n", semantic_errors);
            printf("Semantic analysis: Document is semantically incorrect.\n");
        }
    }
    ;

definition_list:
    definition
  | definition_list definition
  ;

definition:
    operation_definition
  | fragment_definition
  ;

operation_type:
    QUERY { $$ = "query"; }
  | MUTATION { $$ = "mutation"; }
  | SUBSCRIPTION { $$ = "subscription"; }
  ;

operation_definition:
    operation_type IDENTIFIER selection_set {
        if (!add_symbol($2, TYPE_OPERATION, line)) {
            semantic_errors++;
        }
    }
  ;

selection_set:
    LBRACE selection_list RBRACE
  ;

selection_list:
    selection
  | selection_list selection
  ;

selection:
    field
  | fragment_spread
  ;

field:
    IDENTIFIER                              /* Simple field */
  | IDENTIFIER selection_set                /* Nested field */
  | IDENTIFIER COLON IDENTIFIER            /* Aliased field */
  | IDENTIFIER LPAREN argument_list RPAREN /* Field with arguments */
  | IDENTIFIER LPAREN argument_list RPAREN selection_set /* Field with arguments and nested selection */
  ;

argument_list:
    argument
  | argument_list argument
  ;

argument:
    IDENTIFIER COLON value
  ;

value:
    STRING_LITERAL
  | INT_LITERAL
  | FLOAT_LITERAL
  | TRUE
  | FALSE
  | NULL_VAL
  | object_value
  | array_value
  ;

object_value:
    LBRACE object_field_list RBRACE
  | LBRACE RBRACE
  ;

object_field_list:
    object_field
  | object_field_list object_field
  ;

object_field:
    IDENTIFIER COLON value
  ;

array_value:
    LBRACKET value_list RBRACKET
  | LBRACKET RBRACKET
  ;

value_list:
    value
  | value_list value
  ;

fragment_definition:
    FRAGMENT IDENTIFIER ON IDENTIFIER selection_set {
        if (!add_symbol($2, TYPE_FRAGMENT, line)) {
            semantic_errors++;
        }
    }
  ;

fragment_spread:
    ELLIPSIS IDENTIFIER {
        if (!find_symbol($2, TYPE_FRAGMENT)) {
            fprintf(stderr, "Semantic Error at line %d: Fragment '%s' is referenced but not defined\n", 
                    line, $2);
            semantic_errors++;
        }
    }
  ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Syntax Error at line %d: %s\n", line, s);
    exit(1);
}

int main(int argc, char **argv) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <input_file.graphql>\n", argv[0]);
        return 1;
    }
    FILE *file = fopen(argv[1], "r");
    if (!file) {
        perror("Error opening file");
        return 1;
    }
    yyin = file;
    int result = yyparse();
    fclose(file);
    return result;
}