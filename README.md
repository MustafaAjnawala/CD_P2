# GraphQL Compiler Project

## Overview

This project implements a **compiler for a GraphQL specification language** using Flex (Lex) for lexical analyzer generation and Bison (Yacc) for syntax analyzer generation, along with semantic analysis and intermediate code generation (quadruples) phases. The compiler parses GraphQL queries, performs semantic checks, and generates intermediate code and performs common subexpression elimination (CSE) on it to produce **optimized** intermediate code(IC) which could then be used to produce Machine Code.

---

## Features

- **Lexical Analysis:**  
  Implemented using a lexical analyzer(`lex.yy.c`) generated using Flex (`lexer.l`). Recognizes GraphQL keywords, identifiers, literals, symbols, and comments. Prints tokens in a formatted lex table.

- **Syntax Analysis:**  
  Implemented using a syntax analyzer(`parser.tab.c`) generated using Bison and the `parser.y` file. Supports GraphQL constructs such as queries, fragments, fields, arguments, arrays, and objects.

- **Semantic Analysis:**  
  - Symbol table for operations and fragments.
  - Checks for duplicate definitions and undefined fragment references.
  - Reports semantic errors with line numbers.

- **Intermediate Code Generation:**  
  - Generates quadruples for operations, fields, fragments, aliases, and arguments.
  - Each quadruple contains operator, arguments, result, and index.

- **Optimization:**  
  - Performs Common Subexpression Elimination (CSE) on quadruples.
  - Displays both original and optimized intermediate code.
  - Reports eliminated expressions and shows which quadruples were replaced.

- **User-Friendly Output:**  
  - Token table for lexical analysis.
  - Quadruple tables for intermediate code.
  - Clear error and statistics reporting.

---

## File Structure

```
.
├── compiler.exe         # Compiled executable
├── lexer.l              # Flex lexer specification
├── parser.y             # Bison parser specification
├── parser.tab.c         # Generated parser source (Bison)
├── parser.tab.h         # Generated parser header (Bison)
├── lex.yy.c             # Generated lexer source (Flex)
├── input.gql            # Correct GraphQL input
├── input2.gql           # Incorrect GraphQL input
```

---

## How to Build

1. **Generate Lexer and Parser:**
   ```sh
   flex lexer.l
   bison -d parser.y
   ```

2. **Compile:**
   ```sh
   gcc lex.yy.c parser.tab.c -o compiler.exe
   ```

---

## How to Run

1. **Correct Input Syntax**
```sh
./compiler.exe input.gql
```
2. **Incorrect Input Syntax**
```sh
./compiler.exe input2.gql
```

- The program expects a single GraphQL input file as an argument.
- Output includes token tables, semantic analysis results, and intermediate code tables.

---

## Example Output

- **Token Table:**  
  Displays line number, token type, lexeme, and token ID for each token.

- **Semantic Analysis:**  
  Reports success or lists semantic errors with line numbers.

- **Intermediate Code:**  
  Shows original and optimized quadruple tables, with statistics and details of eliminated expressions.

---

## Key Concepts Demonstrated

- **Compiler Frontend Design:**  
  Lexical, syntax, and semantic analysis for a domain-specific language (GraphQL).

- **Intermediate Representation:**  
  Quadruple-based IR for further optimization and code generation.

- **Optimization Techniques:**  
  Common Subexpression Elimination (CSE) at the IR level.

- **Error Handling:**  
  User-friendly syntax and semantic error messages.

---

## Authors

- [Mustafa Ajnawala](https://github.com/MustafaAjnawala)

---

## License

This project is licensed under the [MIT License](LICENSE).