%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    char* op;
    char* arg1;
    char* arg2;
    char* result;
    int index;
} Quadruple;

typedef struct {
    Quadruple* quads;
    int count;
} OptimizedQuads;

typedef struct {
    int original_index;
    char* reason;
} RemovedQuad;

#define MAX_QUADRUPLES 1000
Quadruple quad_table[MAX_QUADRUPLES];
int quad_count = 0;
int temp_var_count = 0;

#define MAX_REMOVED 1000
RemovedQuad removed_quads[MAX_REMOVED];
int removed_count = 0;

char* new_temp() {
    char* temp = (char*)malloc(10);
    sprintf(temp, "t%d", temp_var_count++);
    return temp;
}

void gen_quad(const char* op, const char* arg1, const char* arg2, const char* result) {
    if (quad_count >= MAX_QUADRUPLES) {
        fprintf(stderr, "Quadruple table full\n");
        return;
    }
    quad_table[quad_count].op = strdup(op);
    quad_table[quad_count].arg1 = arg1 ? strdup(arg1) : strdup("-");
    quad_table[quad_count].arg2 = arg2 ? strdup(arg2) : strdup("-");
    quad_table[quad_count].result = result ? strdup(result) : strdup("-");
    quad_table[quad_count].index = quad_count;
    quad_count++;
}

int are_equivalent_quads(Quadruple q1, Quadruple q2) {
    return (strcmp(q1.op, q2.op) == 0 &&
            strcmp(q1.arg1, q2.arg1) == 0 &&
            strcmp(q1.arg2, q2.arg2) == 0);
}

OptimizedQuads optimize_quadruples() {
    OptimizedQuads opt;
    opt.quads = (Quadruple*)malloc(sizeof(Quadruple) * MAX_QUADRUPLES);
    opt.count = 0;
    removed_count = 0;
    
   
    opt.quads[opt.count++] = quad_table[0];
    
    for (int i = 1; i < quad_count; i++) {
        int found_common = 0;
        
        for (int j = 0; j < i; j++) {
            if (are_equivalent_quads(quad_table[i], quad_table[j])) {
                
                removed_quads[removed_count].original_index = i;
                removed_quads[removed_count].reason = strdup(quad_table[j].result);
                removed_count++;
                
                found_common = 1;
                break;
            }
        }
        
        if (!found_common) {
            opt.quads[opt.count] = quad_table[i];
            opt.count++;
        }
    }
    
    return opt;
}

void print_wide_table(const char* title, Quadruple* quads, int count) {
    printf("\n\n%s:\n", title);
    printf("+-------+----------------+--------------------+----------------+----------------+\n");
    printf("| Index | Operator       | Arg1               | Arg2           | Result         |\n");
    printf("+-------+----------------+--------------------+----------------+----------------+\n");
    
    for (int i = 0; i < count; i++) {
        printf("| %-5d | %-14s | %-19s | %-14s | %-14s |\n",
            quads[i].index,
            quads[i].op,
            quads[i].arg1,
            quads[i].arg2,
            quads[i].result);
    }
    printf("+-------+----------------+----------------+----------------+----------------+\n");
}

void print_quadruples() {
    print_wide_table("Original Intermediate Code (Quadruples)", quad_table, quad_count);
    
    OptimizedQuads opt = optimize_quadruples();
    
    print_wide_table("Optimized Intermediate Code (After CSE)", opt.quads, opt.count);
    
    printf("\nOptimization Statistics:\n");
    printf("Original quadruples: %d\n", quad_count);
    printf("Optimized quadruples: %d\n", opt.count);
    printf("Eliminated expressions: %d\n", quad_count - opt.count);
    
    if (removed_count > 0) {
        printf("\nRemoved Quadruples:\n");
        printf("+-------+----------------+--------------------+----------------+----------------+----------------+\n");
        printf("| Index | Operator       | Arg1              | Arg2           | Result         | Replaced By    |\n");
        printf("+-------+----------------+--------------------+----------------+----------------+----------------+\n");
        
        for (int i = 0; i < removed_count; i++) {
            int idx = removed_quads[i].original_index;
            printf("| %-5d | %-14s | %-18s | %-14s | %-14s | %-14s |\n",
                quad_table[idx].index,
                quad_table[idx].op,
                quad_table[idx].arg1,
                quad_table[idx].arg2,
                quad_table[idx].result,
                removed_quads[i].reason);
        }
        printf("+-------+----------------+--------------------+----------------+----------------+----------------+\n");
    }
    
    // Free allocated memory
    free(opt.quads);
    for (int i = 0; i < removed_count; i++) {
        free(removed_quads[i].reason);
    }
}

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
        print_quadruples(); 
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
        char* temp = new_temp();
        gen_quad("OPERATION", $1, $2, temp);
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
    IDENTIFIER {
        char* temp = new_temp();
        gen_quad("FIELD", $1, "-", temp);
    }
    | IDENTIFIER selection_set {
        char* temp = new_temp();
        gen_quad("FIELD", $1, "NESTED", temp);
    }
    | IDENTIFIER COLON IDENTIFIER {
        char* temp = new_temp();
        gen_quad("ALIAS", $1, $3, temp);
    }
    | IDENTIFIER LPAREN argument_list RPAREN {
        char* temp = new_temp();
        gen_quad("FIELD_ARGS", $1, "-", temp);
    }
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
        char* temp = new_temp();
        gen_quad("FRAGMENT", $2, $4, temp);
    }
    ;

fragment_spread:
    ELLIPSIS IDENTIFIER {
        if (!find_symbol($2, TYPE_FRAGMENT)) {
            fprintf(stderr, "Semantic Error at line %d: Fragment '%s' is referenced but not defined\n", 
                    line, $2);
            semantic_errors++;
        }
        char* temp = new_temp();
        gen_quad("SPREAD", $2, "-", temp);
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