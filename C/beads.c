/*
 TASK: beads
 LANG: C
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#define cond ((s[i]==s[i+1]) || (s[i]=='w') || (s[i+1]=='w')) 

int main() {
    FILE *fin = fopen("beads.in", "r");
    FILE *fout = fopen("beads.out", "w");
    char nl[100];
    int n;
    fscanf(fin, "%d\n%s", &n, nl);
    //controllo se e' formata da b r o w
    int i;
    for (i=0; i<strlen(nl); i++) {
        if (!(nl[i]=='b' || nl[i]=='r' || nl[i]=='w')) {
            return -1;
        }
    }
    char *s;
    s = (char*) malloc((n+1)*sizeof(char));
    for (i=0; i<n; i++) {
        if (i<strlen(nl)) {
            s[i] = nl[i];
        }
        else {
            int k;
            k = (int) i;
            while (k>=strlen(nl)) {
                k -= strlen(nl);
            }
            s[i] = nl[k];
        }
    }
    //s[n]=*s; //array circolare
    typedef struct{
        int pos;
        int n;
    } bead;
    bead beads;
    for(i=0;i<n;i++) {beads.pos=0; beads.n=0;}
    i=0;
    while (i<n) {
        int pos;
        int num=0;
            if ((s[i]==s[i+1]) || (s[i]=='w') || (s[i+1]=='w')) {
                pos = i;
            }
            while ((s[i]==s[i+1]) || (s[i]=='w') || (s[i+1]=='w')) {
                num++;
                i++;
                if (((s[0]==s[n-1]) || (s[0]=='w') || (s[n-1]=='w')) && (i>=n)) {
                    int k=0;
                    //printf("lol");
                    while ((s[k]==s[k+1]) || (s[k]=='w') || (s[k+1]=='w')) {
                        num++;
                        k++;
                        printf("%d",k);
                    } 
                    break;
                }
            }
        /*else {
            if ((s[i-n]==s[i+1-n]) || (s[i-n]=='w') || (s[i+1-n]=='w')) {
                pos = i-n;
            }
            else { break; }
            while ((s[i-n]==s[i+1-n]) || (s[i-n]=='w') || (s[i+1-n]=='w')) {
                num++;
                i++;
            } 
            if ((s[0]==s[n-1]) || (s[0]=='w') || (s[n-1]=='w')) {
                i=0;
                printf("lol");
                while ((s[i]==s[i+1]) || (s[i]=='w') || (s[i+1]=='w')) {
                    num++;
                    i++;
                } 
                break;
            }
        }*/
        if (num>beads.n) {
            beads.n = num;
            beads.pos = pos;
        }
        i++;
    }
    printf("pos:%d n:%d\n", beads.pos, beads.n);
    return 0;
}
