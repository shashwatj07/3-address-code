%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol_table.c"

extern FILE *fp;
extern FILE *yyin;
extern FILE *yyout;
extern int yylineno;
extern char yyval;

#define T_INT 1
#define T_FLOAT 2
#define T_CHAR 3

int t_count=0;
int *l_count;
int block=-1;
int flag;
int *queue;
int *queue_st;
int q_index=0;
int array_init=0;
int array_use=0;
int *array_dim;
int array_i=0;
int arr_index=0;
char *buf;
int array_decl=0;
list_t *l;
FILE *out;

%}

%error-verbose

/* YYSTYPE union */
%union{
	int int_val;
	iden_t* sym_val;
}

%token<int_val> GLOBAL STRUCT UNION
%token<int_val>	INC_OP DEC_OP L_OP R_OP LE_OP GE_OP EQ_OP NE_OP AND_OP OR_OP
%token<int_val>	CHAR SHORT INT LONG SIGNED UNSIGNED FLOAT DOUBLE VOID
%token<int_val>	CASE DEFAULT IF ELSE SWITCH WHILE DO MAIN CONTINUE BREAK RETURN

%token<sym_val>	INT_LITERAL
%token<sym_val> FLOAT_LITERAL
%token<sym_val> CHAR_LITERAL
%token<sym_val> IDEN

%type<sym_val> unary_op primary_expr expr assign_expr incl_or_expr unary_expr
%type<sym_val> mul_expr add_expr excl_or_expr equality_expr rel_expr logical_or_expr
%type<sym_val> shift_expr and_expr postfix_expr init_declr init declr logical_and_expr

%start start

%%

unary_op
	: '+' {
		char *buffer = (char*)malloc(50*sizeof(char));
		sprintf(buffer, "+");
		iden_t *var = (iden_t*)malloc(sizeof(iden_t));
		var->name=buffer;
		var->type=-1;
		$$=var;
	}
	| '-' {
		char *buffer = (char*)malloc(50*sizeof(char));
		sprintf(buffer, "-");
		iden_t *var = (iden_t*)malloc(sizeof(iden_t));
		var->name=buffer;
		var->type=-1;
		$$=var;
	}
	| '~' {
		char *buffer = (char*)malloc(50*sizeof(char));
		sprintf(buffer, "~");
		iden_t *var = (iden_t*)malloc(sizeof(iden_t));
		var->name=buffer;
		var->type=-1;
		$$=var;
	}
	| '!' {
		char *buffer = (char*)malloc(50*sizeof(char));
		sprintf(buffer, "!");
		iden_t *var = (iden_t*)malloc(sizeof(iden_t));
		var->name=buffer;
		var->type=-1;
		$$=var;
	}
	;

mul_expr
	: unary_expr {
		$$=$1;
	}
	| mul_expr '*' unary_expr {
		type_check($1->type, $3->type, yylineno);
		t_count++;
		if(flag==0)
			fprintf(out, "t%d = %s * %s\n", t_count, $1->name, $3->name);
		else
			sprintf(buf+ strlen(buf), "t%d = %s * %s\n", t_count, $1->name, $3->name);
		char *buffer = (char*)malloc(50*sizeof(char));
		sprintf(buffer, "t%d", t_count);
		iden_t *var = (iden_t*)malloc(sizeof(iden_t));
		var->name=buffer;
		var->type=$1->type;
		$$=var;
	}
	| mul_expr '/' unary_expr {
		type_check($1->type, $3->type, yylineno);
		t_count++;
		if(flag==0)
			fprintf(out, "t%d = %s / %s\n", t_count, $1->name, $3->name);
		else
			sprintf(buf+ strlen(buf), "t%d = %s / %s\n", t_count, $1->name, $3->name);
		char *buffer = (char*)malloc(50*sizeof(char));
		sprintf(buffer, "t%d", t_count);
		iden_t *var = (iden_t*)malloc(sizeof(iden_t));
		var->name=buffer;
		var->type=$1->type;
		$$=var;
	}
	| mul_expr '%' unary_expr {
		type_check($1->type, $3->type, yylineno);
		t_count++;
		if(flag==0)
			fprintf(out, "t%d = %s % %s\n", t_count, $1->name, $3->name);
		else
			sprintf(buf+ strlen(buf), "t%d = %s % %s\n", t_count, $1->name, $3->name);
		char *buffer = (char*)malloc(50*sizeof(char));
		sprintf(buffer, "t%d", t_count);
		iden_t *var = (iden_t*)malloc(sizeof(iden_t));
		var->name=buffer;
		var->type=$1->type;
		$$=var;
	}
	;

add_expr
	: mul_expr {
		$$=$1;
	}
	| add_expr '+' mul_expr {
		type_check($1->type, $3->type, yylineno);
		t_count++;
		if(flag==0)
			fprintf(out, "t%d = %s + %s\n", t_count, $1->name, $3->name);
		else
			sprintf(buf+ strlen(buf), "t%d = %s + %s\n", t_count, $1->name, $3->name);
		char *buffer = (char*)malloc(50*sizeof(char));
		sprintf(buffer, "t%d", t_count);
		iden_t *var = (iden_t*)malloc(sizeof(iden_t));
		var->name=buffer;
		var->type=$1->type;
		$$=var;
	}
	| add_expr '-' mul_expr {
		type_check($1->type, $3->type, yylineno);
		t_count++;
		if(flag==0)
			fprintf(out, "t%d = %s - %s\n", t_count, $1->name, $3->name);
		else
			sprintf(buf+ strlen(buf), "t%d = %s - %s\n", t_count, $1->name, $3->name);
		char *buffer = (char*)malloc(50*sizeof(char));
		sprintf(buffer, "t%d", t_count);
		iden_t *var = (iden_t*)malloc(sizeof(iden_t));
		var->name=buffer;
		var->type=$1->type;
		$$=var;
	}
	;

shift_expr
	: add_expr {
		$$=$1;
	}
	| shift_expr L_OP add_expr {
		type_check($1->type, $3->type, yylineno);
		t_count++;
		if(flag==0)
			fprintf(out, "t%d = %s << %s\n", t_count, $1->name, $3->name);
		else
			sprintf(buf+ strlen(buf), "t%d = %s << %s\n", t_count, $1->name, $3->name);
		char *buffer = (char*)malloc(50*sizeof(char));
		sprintf(buffer, "t%d", t_count);
		iden_t *var = (iden_t*)malloc(sizeof(iden_t));
		var->name=buffer;
		var->type=$1->type;
		$$=var;
	}
	| shift_expr R_OP add_expr {
		type_check($1->type, $3->type, yylineno);
		t_count++;
		if(flag==0)
			fprintf(out, "t%d = %s >> %s\n", t_count, $1->name, $3->name);
		else
			sprintf(buf+ strlen(buf), "t%d = %s >> %s\n", t_count, $1->name, $3->name);
		char *buffer = (char*)malloc(50*sizeof(char));
		sprintf(buffer, "t%d", t_count);
		iden_t *var = (iden_t*)malloc(sizeof(iden_t));
		var->name=buffer;
		var->type=$1->type;
		$$=var;
	}
	;

rel_expr
	: shift_expr {
		$$=$1;
	}
	| rel_expr '<' shift_expr {
		type_check($1->type, $3->type, yylineno);
		t_count++;
		if(flag==0)
			fprintf(out, "t%d = %s < %s\n", t_count, $1->name, $3->name);
		else
			sprintf(buf+ strlen(buf), "t%d = %s < %s\n", t_count, $1->name, $3->name);
		char *buffer = (char*)malloc(50*sizeof(char));
		sprintf(buffer, "t%d", t_count);
		iden_t *var = (iden_t*)malloc(sizeof(iden_t));
		var->name=buffer;
		var->type=$1->type;
		$$=var;
	}
	| rel_expr '>' shift_expr {
		type_check($1->type, $3->type, yylineno);
		t_count++;
		if(flag==0)
			fprintf(out, "t%d = %s > %s\n", t_count, $1->name, $3->name);
		else
			sprintf(buf+ strlen(buf), "t%d = %s > %s\n", t_count, $1->name, $3->name);
		char *buffer = (char*)malloc(50*sizeof(char));
		sprintf(buffer, "t%d", t_count);
		iden_t *var = (iden_t*)malloc(sizeof(iden_t));
		var->name=buffer;
		var->type=$1->type;
		$$=var;
	}
	| rel_expr LE_OP shift_expr {
		type_check($1->type, $3->type, yylineno);
		t_count++;
		if(flag==0)
			fprintf(out, "t%d = %s <= %s\n", t_count, $1->name, $3->name);
		else
			sprintf(buf+ strlen(buf), "t%d = %s <= %s\n", t_count, $1->name, $3->name);
		char *buffer = (char*)malloc(50*sizeof(char));
		sprintf(buffer, "t%d", t_count);
		iden_t *var = (iden_t*)malloc(sizeof(iden_t));
		var->name=buffer;
		var->type=$1->type;
		$$=var;
	}
	| rel_expr GE_OP shift_expr {
		type_check($1->type, $3->type, yylineno);
		t_count++;
		if(flag==0)
			fprintf(out, "t%d = %s >= %s\n", t_count, $1->name, $3->name);
		else
			sprintf(buf+ strlen(buf), "t%d >= %s < %s\n", t_count, $1->name, $3->name);
		char *buffer = (char*)malloc(50*sizeof(char));
		sprintf(buffer, "t%d", t_count);
		iden_t *var = (iden_t*)malloc(sizeof(iden_t));
		var->name=buffer;
		var->type=$1->type;
		$$=var;
	}
	;

equality_expr
	: rel_expr {
		$$=$1;
	}
	| equality_expr EQ_OP rel_expr {
		type_check($1->type, $3->type, yylineno);
		t_count++;
		if(flag==0)
			fprintf(out, "t%d = %s == %s\n", t_count, $1->name, $3->name);
		else
			sprintf(buf+ strlen(buf), "t%d = %s == %s\n", t_count, $1->name, $3->name);
		char *buffer = (char*)malloc(50*sizeof(char));
		sprintf(buffer, "t%d", t_count);
		iden_t *var = (iden_t*)malloc(sizeof(iden_t));
		var->name=buffer;
		var->type=$1->type;
		$$=var;
	}
	| equality_expr NE_OP rel_expr {
		type_check($1->type, $3->type, yylineno);
		t_count++;
		fprintf(out, "t%d = %s != %s\n", t_count, $1->name, $3->name);
		char *buffer = (char*)malloc(50*sizeof(char));
		sprintf(buffer, "t%d", t_count);
		iden_t *var = (iden_t*)malloc(sizeof(iden_t));
		var->name=buffer;
		var->type=$1->type;
		$$=var;
	}
	;

and_expr
	: equality_expr {
		$$=$1;
	}
	| and_expr '&' equality_expr {
		type_check($1->type, $3->type, yylineno);
		t_count++;
		if(flag==0)
			fprintf(out, "t%d = %s & %s\n", t_count, $1->name, $3->name);
		else
			sprintf(buf+ strlen(buf), "t%d = %s & %s\n", t_count, $1->name, $3->name);
		char *buffer = (char*)malloc(50*sizeof(char));
		sprintf(buffer, "t%d", t_count);
		iden_t *var = (iden_t*)malloc(sizeof(iden_t));
		var->name=buffer;
		var->type=$1->type;
		$$=var;
	}
	;

excl_or_expr
	: and_expr {
		$$=$1;
	}
	| excl_or_expr '^' and_expr {
		type_check($1->type, $3->type, yylineno);
		t_count++;
		if(flag==0)
			fprintf(out, "t%d = %s ^ %s\n", t_count, $1->name, $3->name);
		else
			sprintf(buf+ strlen(buf), "t%d = %s ^ %s\n", t_count, $1->name, $3->name);
		char *buffer = (char*)malloc(50*sizeof(char));
		sprintf(buffer, "t%d", t_count);
		iden_t *var = (iden_t*)malloc(sizeof(iden_t));
		var->name=buffer;
		var->type=$1->type;
		$$=var;
	}
	;

incl_or_expr
	: excl_or_expr {
		$$=$1;
	}
	| incl_or_expr '|' excl_or_expr {
		type_check($1->type, $3->type, yylineno);
		t_count++;
		if(flag==0)
			fprintf(out, "t%d = %s | %s\n", t_count, $1->name, $3->name);
		else
			sprintf(buf+ strlen(buf), "t%d = %s | %s\n", t_count, $1->name, $3->name);
		char *buffer = (char*)malloc(50*sizeof(char));
		sprintf(buffer, "t%d", t_count);
		iden_t *var = (iden_t*)malloc(sizeof(iden_t));
		var->name=buffer;
		var->type=$1->type;
		$$=var;
	}
	;

logical_and_expr
	: incl_or_expr {
		$$=$1;
	}
	| logical_and_expr AND_OP incl_or_expr {
		type_check($1->type, $3->type, yylineno);
		t_count++;
		if(flag==0)
			fprintf(out, "t%d = %s && %s\n", t_count, $1->name, $3->name);
		else
			sprintf(buf+ strlen(buf), "t%d = %s && %s\n", t_count, $1->name, $3->name);
		char *buffer = (char*)malloc(50*sizeof(char));
		sprintf(buffer, "t%d", t_count);
		iden_t *var = (iden_t*)malloc(sizeof(iden_t));
		var->name=buffer;
		var->type=$1->type;
		$$=var;
	}
	;

logical_or_expr
	: logical_and_expr {
		$$=$1;
	}
	| logical_or_expr OR_OP logical_and_expr {
		type_check($1->type, $3->type, yylineno);
		t_count++;
		if(flag==0)
			fprintf(out, "t%d = %s || %s\n", t_count, $1->name, $3->name);
		else
			sprintf(buf + strlen(buf),"t%d = %s || %s\n", t_count, $1->name, $3->name);
		char *buffer = (char*)malloc(50*sizeof(char));
		sprintf(buffer, "t%d", t_count);
		iden_t *var = (iden_t*)malloc(sizeof(iden_t));
		var->name=buffer;
		var->type=$1->type;
		$$=var;
	}
	;

assign_expr
	: logical_or_expr {
		$$=$1;
	}
	| unary_expr '=' assign_expr {
		type_check($1->type, $3->type, yylineno);
		$$=$1;
		if(flag==0)
			fprintf(out, "%s = %s\n", $1->name, $3->name);
		else
			sprintf(buf+ strlen(buf), "%s = %s\n", $1->name, $3->name);
	}
	;

expr
	: assign_expr {
		$$=$1;
	}
	| expr ',' assign_expr {
		iden_t *var = (iden_t*)malloc(sizeof(iden_t));
		$$=var;
	}
	;

primary_expr
	: IDEN { 
		$$=$1;
	}
	| INT_LITERAL {
		t_count++;
		if(flag==0)
			fprintf(out, "t%d = %s\n", t_count, $1->name);
		else
			sprintf(buf + strlen(buf), "t%d = %s\n", t_count, $1->name);
		char *buffer = (char*)malloc(50*sizeof(char));
		sprintf(buffer, "t%d", t_count);
		iden_t *var = (iden_t*)malloc(sizeof(iden_t));
		var->name=buffer;
		var->type=$1->type;
		$$=var;
	}
	| FLOAT_LITERAL {
		t_count++;
		if(flag==0)
			fprintf(out, "t%d = %s\n", t_count, $1->name);
		else
			sprintf(buf+ strlen(buf), "t%d = %s\n", t_count, $1->name);
		char *buffer = (char*)malloc(50*sizeof(char));
		sprintf(buffer, "t%d", t_count);
		iden_t *var = (iden_t*)malloc(sizeof(iden_t));
		var->name=buffer;
		var->type=$1->type;
		$$=var;
	}
	| CHAR_LITERAL {
		t_count++;
		if(flag==0)
			fprintf(out, "t%d = %s\n", t_count, $1->name);
		else
			sprintf(buf+ strlen(buf), "t%d = %s\n", t_count, $1->name);
		char *buffer = (char*)malloc(50*sizeof(char));
		sprintf(buffer, "t%d", t_count);
		iden_t *var = (iden_t*)malloc(sizeof(iden_t));
		var->name=buffer;
		var->type=$1->type;
		$$=var;
	}
	| '(' expr ')' {
		$$=$2;
	}
	;

postfix_expr
	: primary_expr {
		$$=$1;
	}
	| postfix_expr '[' expr ']' {
		if(array_use==0){
			// printf("lookup\n");
			l=lookup($1->name);
			array_use=1;
			array_i=1;
			array_dim=(int*)calloc(10, sizeof(int));
		}
		type_check(T_INT, $3->type, yylineno);
		if(l!=NULL){
			int temp = atoi(($3->name)+1);
			for(int i=array_i; i<l->dim; i++){
				t_count++;
				if(flag==0)
					fprintf(out, "t%d = t%d * t%d\n", t_count, temp, l->arr_dim[i]);
				else
					sprintf(buf + strlen(buf), "t%d = t%d * t%d\n", t_count, temp, l->arr_dim[i]);
				temp=t_count;
			}
			array_dim[array_i-1]=t_count;
			array_i++;
			if(array_i==l->dim+1){
				temp=t_count;
				for(int i=l->dim-2;i>=0;i--){
					t_count++;
					if(flag==0)
						fprintf(out, "t%d = t%d + t%d\n", t_count, temp, array_dim[i]);
					else
						sprintf(buf + strlen(buf), "t%d = t%d + t%d\n", t_count, temp, array_dim[i]);
					temp=t_count;
				}
				array_use=0;
				char *buffer = (char*)malloc(50*sizeof(char));
				sprintf(buffer, "%s[t%d]", l->st_name, t_count);
				iden_t *var = (iden_t*)malloc(sizeof(iden_t));
				var->name=buffer;
				var->type=$1->type;
				$$=var;
			}
		}
	}
	| postfix_expr INC_OP {
		array_use=0;
		if(flag==0)
			fprintf(out, "%s = %s + 1\n", $1->name, $1->name);
		else
			sprintf(buf+ strlen(buf), "%s = %s + 1\n", $1->name, $1->name);
		$$=$1;
	}
	| postfix_expr DEC_OP {
		array_use=0;
		if(flag==0)
			fprintf(out, "%s = %s - 1\n", $1->name, $1->name);
		else
			sprintf(buf+ strlen(buf), "%s = %s - 1\n", $1->name, $1->name);
		$$=$1;
	}
	;

unary_expr
	: postfix_expr {
		// array_use=0;
		$$=$1;
	}
	| INC_OP unary_expr {
		if(flag==0)
			fprintf(out, "%s = %s + 1\n", $2->name, $2->name);
		else
			sprintf(buf+ strlen(buf), "%s = %s + 1\n", $2->name, $2->name);
		$$=$2;
	}
	| DEC_OP unary_expr {
		if(flag==0)
			fprintf(out, "%s = %s - 1\n", $2->name, $2->name);
		else
			sprintf(buf+ strlen(buf), "%s = %s - 1\n", $2->name, $2->name);
		$$=$2;
	}
	| unary_op unary_expr {
		t_count++;
		if(flag==0)
			fprintf(out, "t%d = %s %s\n", t_count, $1->name, $2->name);
		else
			sprintf(buf + strlen(buf), "t%d = %s %s\n", t_count, $1->name, $2->name);
		char *buffer = (char*)malloc(50*sizeof(char));
		sprintf(buffer, "t%d", t_count);
		iden_t *var = (iden_t*)malloc(sizeof(iden_t));
		var->name=buffer;
		var->type=$2->type;
		$$=var;
	}
	;

decl
	: decl_specifiers ';'
	| decl_specifiers init_declr_list ';'
	;

decl_specifiers
	: type_specifier decl_specifiers
	| type_specifier
	;

init_declr_list
	: init_declr {
		array_init=0;
		// for(int i=0;i<l->dim;i++)
		// 	printf("%d ", l->arr_dim[i]);
		// if(l->dim>0)
		// 	printf("\n");
	}
	| init_declr_list ',' init_declr {
		array_init=0;
		// for(int i=0;i<l->dim;i++)
		// 	printf("%d ", l->arr_dim[i]);
		// if(l->dim>0)
		// 	printf("\n");
	}
	;

init_declr
	: declr '=' {
		array_init=0;
		declare=0;
	} init {
		declare=1;
		type_check($1->type, $4->type, yylineno);
		if(strcmp($1->name, $4->name)!=0)
			fprintf(out, "%s = %s\n", $1->name, $4->name);
		$$=$1;
	}
	| declr { array_init=0; }
	;

type_specifier
	: INT
	| LONG
	| FLOAT
	| DOUBLE
	| VOID
	| CHAR
	| SHORT
	| SIGNED
	| UNSIGNED
	| GLOBAL VOID
	| struct_or_union_specifier
	;

declr
	: IDEN {
		l = lookup($1->name);
		l->arr_dim=(int*)calloc(10, sizeof(int));
		l->dim=0;
		$$=$1;
	}
	| '(' declr ')' {
		$$=$2;
	}
	| declr '(' param_list ')'
	| declr '(' ')'
	| declr '(' id_list ')'
	| declr '[' ']'
	| declr '[' '*' ']'
	| declr '[' {
		if(array_init==0) {
			array_init=1;
		}
	} assign_expr {
		l->arr_dim[l->dim++]=atoi(($4->name)+1);
	} ']'
	;

declr_main
	: '(' {
		declare=1;
	} param_list {
		declare=0;
	} ')'
	| '(' ')'
	;

param_list
	: param_decl
	| param_list ',' param_decl
	;

param_decl
	: decl_specifiers declr
	| decl_specifiers direct_abstract_declr
	| decl_specifiers
	;

id_list
	: IDEN
	| id_list ',' IDEN
	;

struct_or_union_specifier
	: struct_or_union '{' struct_decl_list '}'
	| struct_or_union IDEN '{' struct_decl_list '}'
	| struct_or_union IDEN
	;

struct_or_union
	: STRUCT
	| UNION
	;

struct_decl_list
	: struct_decl
	| struct_decl_list struct_decl
	;

struct_decl
	: specifier_qualifier_list ';'
	| specifier_qualifier_list struct_declr_list ';'
	;

specifier_qualifier_list
	: type_specifier specifier_qualifier_list
	| type_specifier
	;

struct_declr_list
	: struct_declr
	| struct_declr_list ',' struct_declr
	;

struct_declr
	: ':' logical_or_expr
	| declr ':' logical_or_expr
	| declr
	;

direct_abstract_declr
	: '(' direct_abstract_declr ')'
	| '(' ')'
	| '(' param_list ')'
	| direct_abstract_declr '(' ')'
	| direct_abstract_declr '(' param_list ')'
	| '[' ']'
	| '[' '*' ']'
	| '[' assign_expr ']'
	| direct_abstract_declr '[' ']'
	| direct_abstract_declr '[' '*' ']'
	| direct_abstract_declr '[' assign_expr ']'
	;

init
	: '{' {
		array_decl=1;
		arr_index=0;
	} init_list '}' {
		array_decl=0;
	}
	| assign_expr {
		$$=$1;
	}
	;

init_list
	: designator_list '=' init {
		printf("");
	}
	| init {
		fprintf(out, "%s[%d] = %s\n", l->st_name, arr_index++, $1->name);
	}
	| init_list ',' designator_list '=' init {
		printf("");
	}
	| init_list ',' init {
		fprintf(out, "%s[%d] = %s\n", l->st_name, arr_index++, $3->name);
	}
	;

external_decl
	: {
		declare=1;
	} decl_specifiers dummy
	;

dummy
	: MAIN {
		declare=0;
		incr_scope();
	} declr_main compound_stmt {
		// hide_scope();
	}
	| init_declr_list {
		declare=0;
	} ';'

designator_list
	: designator
	| designator_list designator
	;

designator
	: '[' logical_or_expr ']'
	| '.' IDEN
	;

stmt
	: label_stmt
	| {
		incr_scope();
	} select_stmt {
		hide_scope();
	}
	| iter_stmt
	| jump_stmt
	| compound_stmt
	| expr_stmt
	;

label_stmt
	: IDEN ':' stmt
	| CASE {
		flag=1;
	} logical_or_expr { flag=0; } ':' {
		fprintf(out, "LABEL %c%d :\n", block+65, ++l_count[block]);
		queue[q_index++]=l_count[block];
		queue_st[q_index-1]=atoi(($3->name)+1);
	} stmt
	| DEFAULT ':' {
		fprintf(out, "LABEL %c%d :\n", block+65, ++l_count[block]);
		queue[q_index++]=l_count[block];
		queue_st[q_index-1]=-1;
	} stmt
	;

compound_stmt
	: '{' '}'
	| '{' {
		block++;
	} block_item_list '}' {
		block--;
	}
	;

block_item_list
	: block_item
	| block_item_list block_item
	;

block_item
	: {
		declare=1;
	} decl {
		declare=0;
	}
	| stmt
	;

expr_stmt
	: ';'
	| expr ';'
	;

select_stmt
	: IF '(' expr ')' {
		fprintf(out, "IF %s == 0 GO TO LABEL %c%d\n", $3->name, block+65, ++l_count[block]);
	} stmt if_tail
	| SWITCH '(' expr ')' {
		fprintf(out, "GO TO LABEL %c%d\n", block+65, ++l_count[block]);
		queue = (int*)malloc(100*sizeof(int));
		queue_st = (int*)malloc(100*sizeof(int));
		queue[q_index++]=l_count[block];
		buf = (char*)malloc(sizeof(char)*10001);
	} stmt {
		fprintf(out, "GO TO LABEL %c%d\n", block+65, ++l_count[block]);
		fprintf(out, "LABEL %c%d :\n", block+65, queue[0]);
		fprintf(out, "%s", buf);
		for(int i=1;queue[i]<=l_count[block+1]&&queue[i]>0;i++){
			if(queue_st[i]!=-1)
				fprintf(out, "IF %s == t%d GO TO LABEL %c%d\n", $3->name, queue_st[i], block+1+65, queue[i]);
			else{
				fprintf(out, "GO TO LABEL %c%d\n", block+1+65, queue[i]);
				break;
			}
		}
		fprintf(out, "LABEL %c%d :\n", block+65, l_count[block]);
	}
	;

if_tail
	: ELSE {
		fprintf(out, "GO TO LABEL %c%d\n", block+65, ++l_count[block]);
		fprintf(out, "LABEL %c%d :\n", block+65, l_count[block]-1);
		hide_scope();
		incr_scope(); 
	} stmt {
		fprintf(out, "LABEL %c%d :\n", block+65, l_count[block]);
	}
	| {
		fprintf(out, "LABEL %c%d :\n", block+65, l_count[block]);
	}
	;

iter_stmt
	: WHILE {
		fprintf(out, "LABEL %c%d :\n", block+65, ++l_count[block]);
	} while_tail
	;

while_tail
	: '(' expr ')' {
		incr_scope();
		fprintf(out, "IF %s == 0 GO TO LABEL %c%d\n", $2->name, block+65, ++l_count[block]);
	} stmt {
		hide_scope();
		fprintf(out, "GO TO LABEL %c%d\n", block+65, l_count[block]-1);
		fprintf(out, "LABEL %c%d :\n", block+65, l_count[block]);
	}
	;

jump_stmt
	: CONTINUE ';'
	| BREAK ';'
	| RETURN ';'
	| RETURN expr ';'
	;

start
	: external_decl
	| start external_decl
	;

%%
#include <stdio.h>

void yyerror(const char *msg)
{
	fflush(stdout);
	fprintf(stderr, "*** %s at line %d\n", msg, yylineno);
}

int main(int argc, char *argv[])
{
	init_hash_table();
	l_count=(int*)calloc(26, sizeof(int));
	array_dim=(int*)calloc(10, sizeof(int));
	yyin = fopen(argv[1], "r");
	out = fopen("3AC.txt", "w");
    if(!yyparse())
		printf("\nProgram Parsing Completed\n");
	else
		printf("\nProgram Parsing Failed\n");
	fclose(yyin);
	yyout = fopen("symbol_table.txt", "w");
	symtab_dump(yyout);
	fclose(yyout);	
    return 0;
}
