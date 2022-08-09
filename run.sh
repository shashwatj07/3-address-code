flex ilp.l
bison -d -Wnone ilp.y
gcc -w lex.yy.c ilp.tab.c
