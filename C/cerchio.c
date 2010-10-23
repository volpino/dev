/* cerchio.c  */

#include <stdio.h>
#include <math.h>

double area(double raggio);
double circonferenza(double raggio);

int main (void) {
    printf ("-- Area e circonferenza del cerchio --\n");
    printf ("Inserisci il raggio: ");
    double raggio;
    scanf ("%lf", &raggio);
    printf ("L'area di un cerchio di raggio %lf e' di %lf e la circonferenza e' di %lf\n", raggio,area(raggio),circonferenza(raggio));
    return 0;
}

double area(double raggio) {
    return raggio*raggio*M_PI;
}

double circonferenza(double raggio) {
    return 2*raggio*M_PI;
}

