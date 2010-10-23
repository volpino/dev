/*
LANG: C
TASK: ride
*/

#include <stdio.h>
#include <string.h>

int calc_sum(char *s);
int check_str(char *s);

int main() {
    char a[32];
    char b[32];
    FILE *filein = fopen("ride.in", "r");
    FILE *fileout = fopen("ride.out", "w");
    fscanf (filein, "%s\n%s", a,b); 
    if ((check_str(a)) && (check_str(b))) {
        if ((calc_sum(a) % 47) == (calc_sum(b) % 47)) {
             fprintf(fileout, "GO\n");
        }
        else {
             fprintf(fileout, "STAY\n");
        }
    }
    else {
        printf("\nStrings not valid| Only upper-case, up-to-6chars strings\n");
    }
    return 0;
}

int calc_sum (char *s) {
    int sum = 1;
    int i;
    for (i=0; i<strlen(s); i++) {
        sum *= (s[i] - 64);
    }
    return sum;
}

int check_str (char *s) {
    int i;
    if (strlen(s) > 6) {
        return 0;
    }
    for (i=0; i<strlen(s); i++) {
        if (!((s[i]>='A') && (s[i]<='Z'))) {
            return 0;
        }
    }
    return 1;
}
