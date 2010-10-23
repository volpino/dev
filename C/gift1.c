/*
LANG: C
TASK: gift1
*/

#include <stdio.h>
#include <string.h>

#define find_name for (j=0; j<NP; j++) { if (!strcmp(tmp, a[j].name)) { break;}}

int main() {
    FILE *filein = fopen("gift1.in", "r");
    FILE *fileout = fopen("gift1.out", "w");
    int NP;
    int fpos = 0;
    fscanf(filein, "%d\n", &NP);
    fpos = ftell(filein);
    fseek (filein,fpos,SEEK_SET);
    typedef struct {
        char name[14];
        int  n;
    } gift;
    gift a[NP];
    int i;
    int j;
    //cerco i nomi
    for (i=0; i<NP; i++) {
        fscanf(filein, "%s\n", a[i].name);
        fpos = ftell(filein);
        fseek (filein,fpos,SEEK_SET);
        a[i].n = 0;
    }
    //inizio giving
    char tmp[14];
    int n1,n2;
    while(!feof(filein)) {
        fscanf(filein, "%s\n", tmp);
        if (fpos==ftell(filein)) {break;} // evita cicli infiniti
        fpos = ftell(filein);
        fseek (filein,fpos,SEEK_SET);
        fscanf(filein, "%d %d\n", &n1, &n2);
        fpos = ftell(filein);
        fseek (filein,fpos,SEEK_SET);
        find_name;
        if (n2!=0) {
            a[j].n += (n1%n2) - n1;
            for (i=0;i<n2;i++) {
                fscanf(filein, "%s\n",tmp);
                fpos = ftell(filein);
                fseek (filein,fpos,SEEK_SET);
                find_name;
                a[j].n += n1/n2;
            }
        }
    }
    for (i=0; i<NP;i++){
        fprintf (fileout, "%s %d\n", a[i].name, a[i].n);
    }
    return 0;      
}
