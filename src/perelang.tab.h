/* A Bison parser, made by GNU Bison 2.3.  */

/* Skeleton interface for Bison's Yacc-like parsers in C

   Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02110-1301, USA.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     ID = 258,
     VINT = 259,
     VREAL = 260,
     VCHAR = 261,
     VBOOLEAN = 262,
     INT = 263,
     REAL = 264,
     CHAR = 265,
     BOOLEAN = 266,
     INICI = 267,
     FINAL = 268
   };
#endif
/* Tokens.  */
#define ID 258
#define VINT 259
#define VREAL 260
#define VCHAR 261
#define VBOOLEAN 262
#define INT 263
#define REAL 264
#define CHAR 265
#define BOOLEAN 266
#define INICI 267
#define FINAL 268




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
#line 38 "perelang.y"
{
    char *name;       // lexema amb memòria dinàmica
    int enter;       // valor de les constants enteres
    double real;     // valor de les constants reals
    char caracter;  // valor de les constants de caràcter
    int tipus_b;    // 3 tipus bàsics
    void *sense_atribut;    // constructors sense atribut
    char *boolean;
    }
/* Line 1529 of yacc.c.  */
#line 85 "perelang.tab.h"
	YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif

extern YYSTYPE yylval;

