/*
LANG: C
TASK: friday
*/

#include <stdio.h>
#include <string.h>

void freq_13(int N, int *v);

int main() {
    int N;
    FILE *filein = fopen("friday.in", "r");
    FILE *fileout = fopen("friday.out", "w");
    if ((filein==NULL) || (fileout==NULL)) { return 1; }
    fscanf (filein, "%d", &N);
    int v[7] = {0,0,0,0,0,0,0};
    freq_13(N, v);
    fprintf(fileout, "%d ", v[5]);
    fprintf(fileout, "%d ", v[6]);
    fprintf(fileout, "%d ", v[0]);
    fprintf(fileout, "%d ", v[1]);
    fprintf(fileout, "%d ", v[2]);
    fprintf(fileout, "%d ", v[3]);
    fprintf(fileout, "%d",  v[4]);
    fprintf(fileout, "\n");
    return 0;
}

void freq_13(int N, int *v) {
    int year;
    int wday = 1;
    for (year=1900; year<(N+1900); year++) {
        int month = 1;
        int day = 1;
        int mday = 1;
        int max_days = 365;
        int feb_days = 28;
        if ((((year%4) == 0) && ((year%100)!=0)) || (year%400==0)) { //anno bisestile
            max_days = 366;
            feb_days = 29;
        }
        for (day=1; day<=max_days; day++, mday++, wday++) {
            /* new month! D: */
            /*   general              february                                               30days motnth*/
            if ((mday>31) || ((month==2) && (mday>feb_days)) || (((month==9) || (month==4) || (month==6) || (month==11)) && (mday>30))) {
                mday = 1; //reset mese
                month++; 
            }
            if (wday>7) {
                wday = 1; //reset settimana
            }
            if (mday == 13) {
                v[wday-1]++;
            }
            //printf ("year:%d\tmonth:%d\tday:%d\tmday:%d\twday:%d\t\n", year, month, day, mday, wday);
        }
        
    }
}
