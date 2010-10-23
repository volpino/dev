/* fibonacci ricorsivo */
#include <stdio.h>

int fibonacci (int n);

int main () {
    printf ("Inserisci l'ennesimo numero della serie di fibonacciche vuoi ottenere: ");
    int n;
    scanf ("%d", &n);
    printf ("Risultato: %d\n", fibonacci(n));
    return 0;
}

int fibonacci (int n) {
    if ((n == 0) || (n == 1)) {
        return 1;
    }
    else {
        return fibonacci(n-1) + fibonacci(n-2);
    }
}
