parser: y.tab.c
	gcc -o parser y.tab.c
y.tab.c: yacc.yacc lex.yy.c
	yacc yacc.yacc
lex.yy.c: lex.lex
	lex lex.lex
	