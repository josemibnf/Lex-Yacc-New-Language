        /*******************************************************/
        /*              ESPECIFICACIO YACC                     */
        /*  Mostrar codi assignacio etiquetes: codi 3 adreces  */
        /*     If/Else  gestió de labels: codi 3 adreces       */
        /*******************************************************/

	
		
%{
	
	#include<stdio.h>
    #include<string.h>
    #include<stdlib.h>
    
     #define MAX 20
     #define NUL (void *)0
    
	
	extern int nlin;
   	extern int yylex();
    extern int yyerror (char *);
    
    
    extern FILE * yyin;
    extern FILE * yyout;
    
    char *new_temp();
    char *new_label();
    void convertir(int , char *);
    
    typedef struct _doble_cond{
        char label_V[MAX+1];
        char label_F[MAX+1];
                            } doble_cond;

%}
	

%start programa

%union{ char nom[MAX+1];
        doble_cond bloc_cond;
        char label[MAX+1];
        void *sense_atribut;
      }

%token <nom> ID CONST

%token IF THEN ELSE ENDIF WHILE DO ENDWHILE

%left '+' '-'
%left '*' '/' '%'
%right UMENYS        /* precedencia de l'operador unari menys */

%left MAI MEI IG DIF    /* precedència operadors de relació */


%left OR            /* precedència operadors de lògics */
%left AND
%right NOT

%type <nom> expr

%type <bloc_cond> cond

%type <label> aux_endif aux_inici_while

%type <sense_atribut> programa llista_inst inst asig inst_if else_opcional inst_while

%%

programa :  llista_inst    {$$=NUL;}
         ;

llista_inst :                         {$$=NUL;}              // epsilon (buida) (programa sense instruccions)
            |  llista_inst inst       {$$=NUL;}
            ;


inst    :  ';'              {$$=NUL;}       // instrucció no fer res (buida però correcta)
        | asig              {$$=NUL;}       // instrucció assignació
        | inst_if           {$$=NUL;}       // instrucció if_else
        | inst_while        {$$=NUL;}       // instrucció while-do
        | error ';'         {$$=NUL;
                            fprintf(stderr,"ERROR INSTRUCCIÓ INCORRECTA: línea %d\n", nlin);
                            yyerrok; }      // sortir de l'error amb ;
        ;

asig    :  ID '=' expr ';'        { $$=NUL;
                                    fprintf(yyout,"\t%s = %s\n", $1, $3); }
        ;

inst_if :   IF cond                         { fprintf(yyout, "Label %s:\n",$2.label_V); }

            THEN llista_inst aux_endif      { fprintf(yyout, "\tgoto %s\n",$6);
                                            fprintf(yyout, "Label %s:\n",$2.label_F); }

            else_opcional

            ENDIF                    { fprintf(yyout, "Label %s:\n",$6);
                                       $$=NUL; }

        | error ENDIF                { $$=NUL;
                                     fprintf(stderr,"ERROR IF/ELSE INCORRECTE: línea %d\n", nlin);
                                     yyerrok; }           // sortir de l'error amb ;
        ;

aux_endif   :         { strcpy($$,new_label()); }   // constructor auxiliar per l'etiqueta ENDIF
            ;

else_opcional   :                            { $$=NUL; }               // epsilon (buida) (ELSE BUIT)
                |   ELSE    llista_inst      { $$=NUL; }
                ;

inst_while :   WHILE aux_inici_while      { fprintf(yyout, "Label %s:\n", $2);}

                    cond
                {fprintf(yyout, "Label %s:\n", $4.label_V);}

                    DO llista_inst ENDWHILE

                { fprintf(yyout, "\tgoto %s\n", $2);
                fprintf(yyout, "Label %s:\n", $4.label_F);
                $$=NUL; }

        | error ENDWHILE     { $$=NUL;
                            fprintf(stderr,"ERROR WHILE/DO INCORRECTE: línea %d\n", nlin);
                            yyerrok; }           // sortir de l'error amb endwhile
        ;


aux_inici_while : { strcpy($$,new_label());
                    // constructor auxiliar per l'etiqueta d'inici del WHILE
                  }
                ;

expr  :         expr '+' expr           { strcpy($$,new_temp());
                                          fprintf(yyout, "\t%s = %s SUM %s\n",$$,$1,$3); }

      |        expr '-' expr            { strcpy($$,new_temp());
                                          fprintf(yyout, "\t%s = %s DIF %s\n",$$,$1,$3); }

      |        expr '*' expr            { strcpy($$,new_temp());
                                          fprintf(yyout, "\t%s = %s MULT %s\n",$$,$1,$3); }

      |        expr '/' expr            { strcpy($$,new_temp());
                                          fprintf(yyout, "\t%s = %s DIV %s\n",$$,$1,$3); }

      |       expr '%' expr             { strcpy($$,new_temp());
                                          fprintf(yyout, "\t%s = %s MOD %s\n",$$,$1,$3); }

      |       '-' expr %prec UMENYS     { strcpy($$,new_temp());
                                          fprintf(yyout, "\t%s = MINUS %s\n",$$,$2); }

      |      '(' expr ')'               {strcpy($$,$2);}

      |       ID                        {strcpy($$,$1);}

      |       CONST                     {strcpy($$,$1);}
      ;

cond    :  expr '>' expr       { strcpy($$.label_V, new_label());
                                strcpy($$.label_F, new_label());
                                fprintf(yyout,"\tif %s GT %s goto %s\n",$1,$3,$$.label_V);
                                fprintf(yyout,"\tgoto %s\n",$$.label_F); }

        | expr '<' expr        { strcpy($$.label_V, new_label());
                                strcpy($$.label_F, new_label());
                                fprintf(yyout,"\tif %s LT %s goto %s\n",$1,$3,$$.label_V);
                                fprintf(yyout,"\tgoto %s\n",$$.label_F); }

        | expr MAI expr        { strcpy($$.label_V, new_label());
                                strcpy($$.label_F, new_label());
                                fprintf(yyout,"\tif %s GEQ %s goto %s\n",$1,$3,$$.label_V);
                                fprintf(yyout,"\tgoto %s\n",$$.label_F); }

        | expr MEI expr        { strcpy($$.label_V, new_label());
                                strcpy($$.label_F, new_label());
                                fprintf(yyout,"\tif %s LEQ %s goto %s\n",$1,$3,$$.label_V);
                                fprintf(yyout,"\tgoto %s\n",$$.label_F); }

        | expr IG expr        { strcpy($$.label_V, new_label());
                                strcpy($$.label_F, new_label());
                                fprintf(yyout,"\tif %s EQU %s goto %s\n",$1,$3,$$.label_V);
                                fprintf(yyout,"\tgoto %s\n",$$.label_F); }

        | expr DIF expr        { strcpy($$.label_V, new_label());
                                strcpy($$.label_F, new_label());
                                fprintf(yyout,"\tif %s DIFF %s goto %s\n",$1,$3,$$.label_V);
                                fprintf(yyout,"\tgoto %s\n",$$.label_F); }

        | NOT cond             { strcpy($$.label_V,$2.label_F);
                                strcpy($$.label_F,$2.label_V);}

        | cond AND              {fprintf(yyout,"Label %s: \n",$1.label_V); }
          cond                  { fprintf(yyout,"Label %s: \n",$1.label_F);
                                fprintf(yyout,"\tgoto %s\n",$4.label_F);
                                strcpy($$.label_V,$4.label_V);
                                strcpy($$.label_F,$4.label_F); }

        | cond OR               {fprintf(yyout,"Label %s: \n",$1.label_F); }
          cond                  { fprintf(yyout,"Label %s: \n",$1.label_V);
                                fprintf(yyout,"\tgoto %s\n",$4.label_V);
                                strcpy($$.label_V,$4.label_V);
                                strcpy($$.label_F,$4.label_F); }

        | '('cond ')'          { strcpy($$.label_V,$2.label_V);
                                strcpy($$.label_F,$2.label_F); }
        ;

%%

int main(int argc, char *argv[]){
        if (argc>=2){
            yyin = fopen( argv[1], "r" );
        }
        if (argc==3){
            yyout = fopen( argv[2], "w" );
        }
        if (argc > 3){
            printf("Error paràmetres línia comanda");
            return 1;
        }
        return(yyparse());
    
}

char *new_temp(){
    char *temp;
    static int actual=0;
    
        actual++;
        temp = (char *)malloc(MAX+1);
        strcpy(temp,"temp");
        convertir(actual, temp+4);
        return temp;
}

char *new_label(){
    char *temp;
    static int actual=0;
    
    actual++;
    temp = (char *)malloc(MAX+1);
    strcpy(temp,"etiq");
    convertir(actual, temp+4);
    return temp;
}

void convertir(int valor, char *etiq){
    int c,r;
    char aux[MAX+1];
    int i=0;
    
    c=valor;
    
    while (c>=10){
        r= c%10;
        c= c/10;
        aux[i]= r+'0';
        i++;
    }
    aux[i]= c+'0';
    
    while (i>=0){
        *etiq=aux[i];
        i--;
        etiq++;
    }
    *etiq='\0';
    
}


