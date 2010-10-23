/* palindromo.c */
#include <stdio.h>
#include <string.h>

int palindromo (char *string);

int main() {
    printf ("Stringa: ");
    char s[64];
    fgets (s, sizeof(s), stdin);
    s[strlen(s)-1] = 0;
    if (palindromo(s)) {
        printf ("E' palindromo!\n");
    }
    else {
        printf ("Non e' palindromo\n");
    }
    return 0;
}

int palindromo(char *string) {
    int i;
    int len = strlen(string);
    for (i=0; i<len; i++) {
        if (string[i] != string[(len - 1 - i)]) {
            return 0;
        }
    }
    return 1;
}
