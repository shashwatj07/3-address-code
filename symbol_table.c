// Courtsey: Drifter and me

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol_table.h"

int cur_scope = 0;
int declare = 0;

void insert(char *name, int len, int type, int lineno){
	unsigned int hashval = hash(name);
	list_t *l = hash_table[hashval];
	
	while ((l != NULL) && (strcmp(name,l->st_name) != 0)) l = l->next;
	
	if (l == NULL){
		if(declare == 1)
		{
			l = (list_t*) malloc(sizeof(list_t));
			strncpy(l->st_name, name, len);  
			l->st_type = type;
			l->scope = cur_scope;
			l->lines = (RefList*) malloc(sizeof(RefList));
			l->lines->lineno = lineno;
			l->lines->next = NULL;
			
			l->next = hash_table[hashval];
			hash_table[hashval] = l; 
			// printf("Inserted %s for the first time with linenumber %d!\n", name, lineno);
		}
		else {
			fprintf(stderr, "ERROR: Use of undeclared variable %s at line %d\n", name, lineno);
		}
	}
	else{
		if(declare == 0){
			RefList *t = l->lines;
			while (t->next != NULL) t = t->next;
			
			t->next = (RefList*) malloc(sizeof(RefList));
			t->next->lineno = lineno;
			t->next->next = NULL;
			// printf("Found %s again at line %d!\n", name, lineno);
		}
		else{
			if(l->scope == cur_scope){
				fprintf(stderr, "ERROR: A multiple declaration of variable %s at line %d\n", name, lineno);
 				exit(1);
			}
			else{
				l = (list_t*) malloc(sizeof(list_t));
				strncpy(l->st_name, name, len);  
				l->st_type = type;
				l->scope = cur_scope;
				l->lines = (RefList*) malloc(sizeof(RefList));
				l->lines->lineno = lineno;
				l->lines->next = NULL;
				
				l->next = hash_table[hashval];
				hash_table[hashval] = l; 
				// printf("Inserted %s for a new scope with linenumber %d!\n", name, lineno);
			}	
		}		
	}
}

list_t *lookup(char *name){
	unsigned int hashval = hash(name);
	list_t *l = hash_table[hashval];
	while ((l != NULL) && (strcmp(name,l->st_name) != 0)) l = l->next;
	return l;
}

void incr_scope(){
	cur_scope++;
}

void hide_scope(){
	list_t *l;
	int i;
	// printf("Hiding scope \'%d\':\n", cur_scope);
	for (i = 0; i < SIZE; i++){
		if(hash_table[i] != NULL){
			l = hash_table[i];
			while(l != NULL && l->scope == cur_scope){
				// printf("Hiding %s..\n", l->st_name);
				l = l->next;
			}
			hash_table[i] = l;
		}
	}
	cur_scope--;
}

int get_type(char *name){
	list_t *l = lookup(name);
	
	return l!=NULL?l->st_type:-1;
}

void symtab_dump(FILE * of){  
  int i;
  fprintf(of,"Name         Type   Scope \n");
  for (i=0; i < SIZE; ++i){ 
	if (hash_table[i] != NULL){ 
		list_t *l = hash_table[i];
		while (l != NULL){ 
			RefList *t = l->lines;
			fprintf(of,"%-12s ",l->st_name);
			if (l->st_type == INT_TYPE) fprintf(of,"%-7s","int");
			else if (l->st_type == REAL_TYPE) fprintf(of,"%-7s","float");
			else if (l->st_type == CHAR_TYPE) fprintf(of,"%-7s","char");
			else if (l->st_type == ARRAY_TYPE){
				fprintf(of,"array of ");
				if (l->inf_type == INT_TYPE) 		   fprintf(of,"%-7s","int");
				else if (l->inf_type  == REAL_TYPE)    fprintf(of,"%-7s","float");
				else if (l->inf_type  == CHAR_TYPE) 	   fprintf(of,"%-7s","char");
				else fprintf(of,"%-7s","undef");
			}
			else if (l->st_type == POINTER_TYPE){
				fprintf(of,"%-7s %s","pointer to ");
				if (l->inf_type == INT_TYPE) 		   fprintf(of,"%-7s","int");
				else if (l->inf_type  == REAL_TYPE)    fprintf(of,"%-7s","float");
				else if (l->inf_type  == CHAR_TYPE) 	   fprintf(of,"%-7s","char");
				else fprintf(of,"%-7s","undef");
			}
			else if (l->st_type == FUNCTION_TYPE){
				fprintf(of,"%-7s %s","function returns ");
				if (l->inf_type == INT_TYPE) 		   fprintf(of,"%-7s","int");
				else if (l->inf_type  == REAL_TYPE)    fprintf(of,"%-7s","float");
				else if (l->inf_type  == CHAR_TYPE) 	   fprintf(of,"%-7s","char");
				else fprintf(of,"%-7s","undef");
			}
			else fprintf(of,"%-7s","undef");
			fprintf(of,"  %d  ",l->scope);
			// while (t != NULL){
			// 	fprintf(of,"%4d ",t->lineno);
			// t = t->next;
			// }
			fprintf(of,"\n");
			l = l->next;
		}
    }
  }
}

void type_check(int type_1, int type_2, int lineno){
	if(type_1!=type_2){
			fprintf(stderr, "ERROR: Types conflicting at line %d\n", lineno);
			// exit(1);
		}
}

void init_hash_table(){
	int i; 
	hash_table = malloc(SIZE * sizeof(list_t*));
	for(i = 0; i < SIZE; i++) hash_table[i] = NULL;
}

unsigned int hash(char *key){
	unsigned int hashval = 0;
	for(;*key!='\0';key++) hashval += *key;
	hashval += key[0] % 11 + (key[0] << 3) - key[0];
	return hashval % SIZE;
}
