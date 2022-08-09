%option yylineno

O   [0-7]
D   [0-9]
NZ  [1-9]
L   [a-zA-Z_]
A   [a-zA-Z_0-9]
H   [a-fA-F0-9]
E   ([Ee][+-]?{D}+)
P   ([Pp][+-]?{D}+)
FS  (f|F|l|L)
IS  (((u|U)(l|L|ll|LL)?)|((l|L|ll|LL)(u|U)?))
CP  (u|U|L)
HP  (0[xX])
ES  (\\(['"\?\\abfnrtv]|[0-7]{1,3}|x[a-fA-F0-9]+))
WS  [ \t\v\n\f]

%{

#include <stdio.h>
#include "symbol_table.h"
#include "ilp.tab.h"

#define T_INT 1
#define T_FLOAT 2
#define T_CHAR 3

extern void yyerror(const char *);

static void comment(void);

int type_current=1;



%}

%%
"/*"                    { comment(); }
"//".*                  {  }

"do"					{ return(DO); }
"struct"				{ return(STRUCT); }
"unsigned"				{ return(UNSIGNED); }
"void"					{ return(VOID); }
"while"					{ return(WHILE); }
"__global__"            { return(GLOBAL); }
"double"				{ return(DOUBLE); }
"int"					{ type_current=T_INT; return(INT); }
"float"					{ type_current=T_FLOAT; return(FLOAT); }
"main"					{ return(MAIN); }
"if"					{ return(IF); }
"switch"				{ return(SWITCH); }
"else"					{ return(ELSE); }
"break"					{ return(BREAK); }
"case"					{ return(CASE); }
"char"					{ type_current=T_CHAR; return(CHAR); }
"union"					{ return(UNION); }
"long"					{ return(LONG); }
"return"				{ return(RETURN); }
"short"					{ return(SHORT); }
"signed"				{ return(SIGNED); }
"continue"				{ return(CONTINUE); }
"default"				{ return(DEFAULT); }

{HP}{H}+{IS}?				    { 
                                    iden_t *var = (iden_t*)malloc(sizeof(iden_t));
                                    char *destination = (char*)malloc(12*sizeof(char));
                                    strncpy(destination, yytext, strlen(yytext));
                                    var->name=destination;
                                    var->type=T_INT;
                                    yylval.sym_val=var;
                                    return INT_LITERAL; 
                                }
{NZ}{D}*{IS}?				    { 
                                    iden_t *var = (iden_t*)malloc(sizeof(iden_t));
                                    char *destination = (char*)malloc(12*sizeof(char));
                                    strncpy(destination, yytext, strlen(yytext));
                                    var->name=destination;
                                    var->type=T_INT;
                                    yylval.sym_val=var;
                                    return INT_LITERAL; 
                                }
"0"{O}*{IS}?				    { 
                                    iden_t *var = (iden_t*)malloc(sizeof(iden_t));
                                    char *destination = (char*)malloc(12*sizeof(char));
                                    strncpy(destination, yytext, strlen(yytext));
                                    var->name=destination;
                                    var->type=T_INT;
                                    yylval.sym_val=var;
                                    return INT_LITERAL; 
                                }
{CP}?"'"([^'\\\n]|{ES})+"'"		{ 
                                    iden_t *var = (iden_t*)malloc(sizeof(iden_t));
                                    char *destination = (char*)malloc(12*sizeof(char));
                                    strncpy(destination, yytext, strlen(yytext));
                                    var->name=destination;
                                    var->type=T_CHAR;
                                    yylval.sym_val=var;
                                    return CHAR_LITERAL; 
                                }
{D}+{E}{FS}?				    { 
                                    iden_t *var = (iden_t*)malloc(sizeof(iden_t));
                                    char *destination = (char*)malloc(12*sizeof(char));
                                    strncpy(destination, yytext, strlen(yytext));
                                    var->name=destination;
                                    var->type=T_FLOAT;
                                    yylval.sym_val=var;
                                    return FLOAT_LITERAL; 
                                }
{D}*"."{D}+{E}?{FS}?			{ 
                                    iden_t *var = (iden_t*)malloc(sizeof(iden_t));
                                    char *destination = (char*)malloc(12*sizeof(char));
                                    strncpy(destination, yytext, strlen(yytext));
                                    var->name=destination;
                                    var->type=T_FLOAT;
                                    yylval.sym_val=var;
                                    return FLOAT_LITERAL; 
                                }
{D}+"."{E}?{FS}?			    { 
                                    iden_t *var = (iden_t*)malloc(sizeof(iden_t));
                                    char *destination = (char*)malloc(12*sizeof(char));
                                    strncpy(destination, yytext, strlen(yytext));
                                    var->name=destination;
                                    var->type=T_FLOAT;
                                    yylval.sym_val=var;
                                    return FLOAT_LITERAL; 
                                }
{HP}{H}+{P}{FS}?			    { 
                                    iden_t *var = (iden_t*)malloc(sizeof(iden_t));
                                    char *destination = (char*)malloc(12*sizeof(char));
                                    strncpy(destination, yytext, strlen(yytext));
                                    var->name=destination;
                                    var->type=T_FLOAT;
                                    yylval.sym_val=var;
                                    return FLOAT_LITERAL; 
                                }
{HP}{H}*"."{H}+{P}{FS}?			{ 
                                    iden_t *var = (iden_t*)malloc(sizeof(iden_t));
                                    char *destination = (char*)malloc(12*sizeof(char));
                                    strncpy(destination, yytext, strlen(yytext));
                                    var->name=destination;
                                    var->type=T_FLOAT;
                                    yylval.sym_val=var;
                                    return FLOAT_LITERAL; 
                                }
{HP}{H}+"."{P}{FS}?			    { 
                                    iden_t *var = (iden_t*)malloc(sizeof(iden_t));
                                    char *destination = (char*)malloc(12*sizeof(char));
                                    strncpy(destination, yytext, strlen(yytext));
                                    var->name=destination;
                                    var->type=T_FLOAT;
                                    yylval.sym_val=var;
                                    return FLOAT_LITERAL; 
                                }

">>"					{ return R_OP; }
"<<"					{ return L_OP; }
"++"					{ return INC_OP; }
"--"					{ return DEC_OP; }
"<="					{ return LE_OP; }
">="					{ return GE_OP; }
"=="					{ return EQ_OP; }
"!="					{ return NE_OP; }
"&&"                    { return AND_OP; }
"||"                    { return OR_OP; }
"<"					    { return '<'; }
">"					    { return '>'; }
"^"					    { return '^'; }
"|"					    { return '|'; }
"?"					    { return '?'; }
"&"					    { return '&'; }
"!"					    { return '!'; }
"~"					    { return '~'; }
"="                     { return '='; }
"("					    { return '('; }
")"					    { return ')'; }
"[" 				    { return '['; }
"]" 				    { return ']'; }
"."					    { return '.'; }
";"					    { return ';'; }
"{" 				    { return '{'; }
"}" 				    { return '}'; }
","					    { return ','; }
":"					    { return ':'; }
"%"					    { return '%'; }
"-"					    { return '-'; }
"+"					    { return '+'; }
"*"					    { return '*'; }
"/"					    { return '/'; }

{L}{A}*					{ insert(yytext, strlen(yytext), type_current, yylineno);
                            iden_t *var = (iden_t*)malloc(sizeof(iden_t));
                            char *destination = (char*)malloc(12*sizeof(char));
                            strncpy(destination, yytext, strlen(yytext));
                            var->name=destination;
                            var->type=get_type(destination);
                            yylval.sym_val=var;
                            return IDEN; }

{WS}+					{ }
.					    { }

%%

int yywrap(void)        /* called at end of input */
{
    return 1;           /* terminate now */
}

static void comment(void)
{
    int c;

    while ((c = input()) != 0)
        if (c == '*')
        {
            while ((c = input()) == '*')
                ;

            if (c == '/')
                return;

            if (c == 0)
                break;
        }
    yyerror("unterminated comment");
}
