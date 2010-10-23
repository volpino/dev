#include<stdio.h>

int main() {
    FILE *filein = fopen("test.in", "r");
    FILE *fileout = fopen("test.out", "w");
    int a, b;
    fscaf (filein, "%d%d", &a,&b);
    fprintf(fileout, "%d\n", a+b);
    return 0;
}
