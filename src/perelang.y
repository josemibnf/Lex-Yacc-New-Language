        /*************************************************/
        /*              ESPECIFICACIO YACC               */
        /*               Gestió atributs                 */
        /*  Gestio de tipus basics  a les declaracions   */
        /*   Gestio d'àmbits: begin/end                  */
        /*************************************************/



%{
    #include <stdio.h>
    #include <stdlib.h>
    #include"symtab.h"  // Conté la definicio de les Entrades a la TS


/* Tipus del IDENTIFICADORS: de més específic a més general */
#define TBOOLEAN 1
#define TCHAR 2
#define TINT 3
#define TREAL 4


#define MAX(x,y) (x)>=(y)?x:y
#define NUL (void *)0

extern int nlin;
extern int yylex();

void yyerror (char const *);


extern FILE * yyin;
extern FILE * yyout;

int tid;                    // variable extreure atributs de la TS

%}

%union	{
    char *name;             // lexema amb memòria dinàmica
    int enter;              // valor de les constants enteres
    double real;            // valor de les constants reals
    char caracter;          // valor de les constants de caràcter
    int tipus_b;            // 3 tipus bàsics
    void *sense_atribut;    // constructors sense atribut
    char *boolean;
    }

	
%start programa

%token<name> ID

%token<enter> VINT
%token<real> VREAL
%token<caracter> VCHAR
%token<caracter> VBOOLEAN

%token INT REAL CHAR BOOLEAN GLOBAL

%token INICI FINAL IF FI ELSE

%left '+' '-'
%left '*' '/' '=='

%type<tipus_b> tipus llistaid expr aux

%type<sense_atribut> programa llistainst inst decla asig ambit aux_ambit condicional

%%

programa:                                   { $$=NUL; }     // Epsilon (programa buit)
            |   INICI llistainst FINAL      { $$=NUL; }     // Àmbit global o principal
            ;

llistainst:                         { $$=NUL; }     // Bloc buit
            | llistainst inst       { $$=NUL; }
            | llistainst  ambit
            | llistainst   condicional
            ;

ambit:  INICI   aux_ambit llistainst FINAL  {   
                                                if (sym_pop_scope()==SYMTAB_STACK_UNDERFLOW) {
                                                    fprintf(stderr,"ERROR compilador!!\n");
                                                    YYERROR;    // ERROR del sistema!!
                                                }
                                                $$=NUL;
                                            }
        ;

condicional:    IF  llistainst FI {   
                                                if (sym_pop_scope()==SYMTAB_STACK_UNDERFLOW) {
                                                    fprintf(stderr,"ERROR compilador!!\n");
                                                    YYERROR;    // ERROR del sistema!!
                                                }
                                                $$=NUL;
                                            }
            |   IF llistainst ELSE llistainst FI {   
                                                if (sym_pop_scope()==SYMTAB_STACK_UNDERFLOW) {
                                                    fprintf(stderr,"ERROR compilador!!\n");
                                                    YYERROR;    // ERROR del sistema!!
                                                }
                                                $$=NUL;
                                            }
            ;

aux_ambit:  {   if (sym_push_scope()==SYMTAB_STACK_OVERFLOW){  //Verificar espai pila àmbits disponible
                    fprintf(stderr,"ERROR NO es pot crear nou àmbit de definició. Línea %d \n", nlin);
                    YYERROR;
                }
                $$=NUL;
            }
            ;


inst:       ';'                 { $$=NUL; }
        |   decla ';'           { $$=NUL; }
        |   asig  ';'           { $$=NUL; }
        |   error ';'           { $$=NUL;
                                fprintf(stderr,"Línea %d: ERROR INSTRUCCIÓ INCORRECTA\n", nlin);
                                yyerrok; }      // sortir de error amb ;
        ; 

decla:	    tipus llistaid          {$$=NUL;}
        |   scope tipus llistaid    {$$=NUL;}
        ;

scope:  GLOBAL  {
                    //TODO: Añadir semantica a "global"
                    tid=$<tipus_b>0;
                    sym_global_add("x", &tid);
                    fprintf(yyout,"Declara Scope Global\n");  
                }
        ;

tipus:      INT     {$$ = TINT;}
        |   REAL    {$$ = TREAL;}
        |   CHAR    {$$ = TCHAR;}
        |   BOOLEAN {$$ = TBOOLEAN;}
        ;

llistaid:   ID          {  if (sym_lookup($1, &tid)==SYMTAB_OK) {   //verificar duplicat
                            fprintf(stderr,"ERROR ID %s ja utilitzat. Línea %d \n", $1, nlin);
                            YYERROR;
                        }else{
                            tid=$<tipus_b>0;
                            sym_add($1,&tid);
                            fprintf(yyout,"Declara Identificador: %s\t Tipus: %d\n", $1, tid);
                            $$ = $<tipus_b>0;
                        }
                    }
        |  llistaid ',' ID      {   if (sym_lookup($3, &tid)==SYMTAB_OK){   //verificar duplicat
                                        fprintf(stderr,"ERROR ID %s ja utilitzat. Línea %d \n", $3, nlin);
                                        YYERROR;
                                    }else{
                                        tid=$1;
                                        sym_add($3,&tid);
                                        fprintf(yyout,"Declara Identificador: %s\t Tipus: %d\n", $3, tid);
                                        $$ = $1;
                                    }
                                }
            ;

asig  :     ID '=' aux expr     { if ($4>$3){   // verificar casament de tipus entre ID i exp
                                    fprintf(stderr,"Línea %d: Error tipus: ID %s tipus %d \t Expressió tipus %d\n", nlin, $1, $3, $4);
                                    YYERROR; }
                                else{
                                    fprintf(yyout,"Línea %d: Assignació Ok: ID %s tipus %d \t Expressió tipus %d\n", nlin, $1, $3, $4);
                                    $$=NUL;
                                }
                            }
           ;

aux:                    { if (sym_lookup($<name>-1, &tid)!=SYMTAB_OK){   //verificar existeix
                            fprintf(stderr,"Línea %d: ERROR ID %s no declarat. \n", nlin, $<name>-1);
                            YYERROR; }
                        $$=tid; }
        ;


expr  :         expr '+' expr   { $$=MAX($1,$3); }   // tipus expressió més general

        |        expr '-' expr   { $$=MAX($1,$3); }
        |        expr '*' expr   { $$=MAX($1,$3); }
        |        expr '/' expr   { $$=MAX($1,$3); }
        |        expr '==' expr   { 
                                    if ($1==$3){
                                        $$=1;
                                    }else{
                                        $$=0;
                                    }
                                }
        |      '(' expr ')'      { $$=$2; }
        |       ID              { if (sym_lookup($1,&tid)!=SYMTAB_OK){   //verificar existeix entrada TS
                                        fprintf(stderr,"Línea %d: ERROR ID %s NO definit\n", nlin, $1);
                                        YYERROR;
                                    } else { $$= tid; }
                                }
        |       VINT            { $$=TINT; }
        |       VREAL           { $$ = TREAL;}
        |       VCHAR           { $$ = TCHAR;}
        |       VBOOLEAN           { $$ = TBOOLEAN;}
        ;

%%

/* Called by yyparse on error. */

void yyerror (char const *s){
    fprintf (stderr, "%s\n", s);
}

int main(int argc, char *argv[]){
    if (argc>=2){
        yyin = fopen( argv[1], "r" );
    }
    if (argc==3){
        yyout = fopen( argv[2], "w" );
    }
    if (argc > 3){
        fprintf(stderr, "Error paràmetres línia comanda");
        return 1;
    }
    return(yyparse());
    
}
