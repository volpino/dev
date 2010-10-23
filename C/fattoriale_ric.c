/* fattoriale ricorsivo */
#include<stdio.h>

int fattoriale_ric(int n);

int main(int argc, char **argv) {
    if (argc == 2) {
        printf ("%d\n", fattoriale_ric(atoi(argv[1])));
    }
    return 0;
}

int fattoriale_ric(int n) {
    if (n==1) {
        return 1;
    }
    else {
        return n*fattoriale_ric(n-1);
    }
}
