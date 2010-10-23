#include <stdio.h>

void lamerize (char *string);
int _strlen (char *string);
void lower (char *string);

int main() {
    printf ("Inserisci il testo: ");
    char string[256];
    scanf ("%s", string);
    lamerize(string);
    printf ("LaMeRiZeD -> %s\n", string);
    return 0;
}

void lamerize (char *string) {
    lower(string);
    int i;
    for (i = 0; i <= _strlen(string); i++) {
        if (((string[i] >= 'a') && (string[i]<= 'z')) && (!(i%2))) {
            string[i] -= 32;
        }
    }
}

int _strlen (char *string) {
    int len;
    for (len=0; string[len]!=0; len++);
    return len;
}

void lower (char *string) {
    int i;
    for (i=0; i<_strlen(string); i++) {
        if ( (string[i]>='A') && (string[i]<='Z') ) {
            string[i]+=32;
        }
    }
}
