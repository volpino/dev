/* vars_and_functions.c */

#include <stdio.h>

// prototipo della funzione
int somma (int x, int y);
void procedura_che_lolla();

//funzione main
int main(void) {
    int risultato = somma(2, 8);
    printf ("La somma di 2+8 e' uguale a: %d\n", risultato);
    procedura_che_lolla();
    void interna(void) {
        printf ("Sono una procedura interna :D\n");
    }
    interna();
    return 0;
}

// funzione somma
int somma (int x, int y) {
    return x+y;
}

//procedura che lolla xD
void procedura_che_lolla(void) {
    printf ("LOL!\n");
    return; /* riga opzionale */
}
