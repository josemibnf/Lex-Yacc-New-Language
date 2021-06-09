        /*********************************************************/
        /*               ESPECIFICACIO LEX                       */
        /*     Assignacions amb Expressions variables temporals  */
        /*     If/Else  gestió de labels                         */
        /*********************************************************/

%{
    #define MAX 20
    
    typedef struct _doble_cond{
        char label_V[MAX+1];
        char label_F[MAX+1];
    } doble_cond;
    
	#include "if_else_while_label.tab.h"
    
	int nlin=1;
    
%}

%array

%option nounput
%option noinput
%option noyywrap


iden        [a-zA-Z_][a-zA-Z_0-9]*


%%
[ \t]+                          ;       // saltar delimitadors

"//".*\n                        ;       // saltar comentaris

                           /* Operadors de relació amb múltiples símbols lèxics */

">="                            {return MAI;}

"<="                            {return MEI;}

"=="                            {return IG;}

"!="                            {return DIF;}

                           /*  Paraules reservades: if then else endif */

"if"                            {return IF;}

"then"                          {return THEN;}

"else"                          {return ELSE;}

"endif"                          {return ENDIF;}

                        /*  Paraules reservades: while do endwhile */

"while"                            {return WHILE;}

"do"                               {return DO;}

"endwhile"                         {return ENDWHILE;}

                            /*  Operadors lògics: && || ! */

"&&"                             {return AND;}

"||"                             {return OR;}

"!"                              {return NOT;}

                            /*  Identificadors */

{iden}                         {	strcpy(yylval.nom,yytext); 		// nom del identificadors
                                	return(ID);
                                }

                            /*  Constants enteres */

[0-9]+                        {	strcpy(yylval.nom,yytext);         // string del valor constant
                                return(CONST);  }

\n                             {	nlin++;  }                     // comptar línies

                            /*  resta operadors  1 símbol lèxic */

.                     		 {	return(yytext[0]);	}	      //  Els errors es processaran a nvell sintàctic


