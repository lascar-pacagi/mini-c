// un exemple de fichier mini-C
// à modifier au fur et à mesure des tests
//
// la commande 'make' recompile mini-c (si nécessaire)
// et le lance sur ce fichier

/* struct toto { */
/*   int a; */
/*   int b; */
/* }; */

/* struct titi { */
/*   int a; */
/*   struct titi* b; */
/*   struct toto* c; */
/* }; */

/* struct tutu { */
/*   int a; */
/*   struct tutu* b; */
/*   struct tutu* c; */
/*   int d; */
/* }; */

/* int titi(int a, struct tutu* b) { */
/*   int c; */
/*   { */
/*     int c; */
/*     int d; */
/*     c = c + d; */
/*     { */
/*       int c; */
/*       c = 0; */
/*     } */
/*   } */
/*   return 0; */
/* } */

/* int toto(int a, int c) { */
/*   int d; */
/*   struct toto * s; */
/*   struct titi * s1; */
/*   struct tutu * s2; */
/*   s->a = s->b; */
/*   d = s->a + s1->c->b + titi(s2->a, 0); */
/*   s = 0; */
/*   if (s1->b == 0) { */
/*     return 0; */
/*   } */
/*   return 42; */
/* } */

/* int toto(int n1, int n2, int n3, int n4, int n5, int n6, int n7) { */
/*   return n1 + n2 + n7; */
/* } */
/* int main() { */
/*   return toto(42, 42 + 1, 42 + 2, 42 + 3, 42 + 4, 42 + 5, 42 + 6); */
/* } */

/* int toto(int n1, int n2, int n3) { */
/*   int x; */
/*   return n2; */
/* } */

/* int main() { */
/*   return toto(1, 2, 3); */
/* } */

/* struct S { int a; int b; }; */

/* int main() { */
/*   struct S *p; */
/*   p = sbrk(sizeof(struct S)); */
/*   p->a = 40; */
/*   p->b = 2; */
/*   return p->a + p->b; */
/* } */

/* int main() { */
/*   int x; */
/*   x = 65; */
/*   putchar(x); */
/*   if (1) { */
/*     int y; */
/*     y = 66; */
/*     putchar(y); */
/*   } else { */
/*     int z; */
/*     z = 67; */
/*     putchar(z); */
/*   } */
/*   putchar(x); */
/*   putchar(10); */
/*   return 0; */
/* } */

/* int fibonacci(int n) */
/* { */
/*   if (n < 2) return n; */
/*   return fibonacci(n - 1) + fibonacci(n - 2); */
/* } */

/* int main() */
/* { */
/*   return fibonacci(10); */
/* } */

/* int factorial(int n) */
/* { */
/*   if (n <= 1) return 1; */
/*   return n * factorial(n - 1); */
/* } */

/* int main() */
/* { */
/*   return factorial(10); */
/* } */


/*** listes circulaires doublement chaînées ***/

/* struct L { */
/*   int valeur; */
/*   struct L *suivant, *precedent; */
/* }; */

/* /\* liste réduite à un élément *\/ */
/* struct L* make(int v) { */
/*   struct L* r; */
/*   r = sbrk(sizeof(struct L)); */
/*   r->valeur = v; */
/*   r->suivant = r->precedent = r; */
/*   return r; */
/* } */

/* /\* insertion après un élément donnée *\/ */
/* int inserer_apres(struct L *l, int v) { */
/*   struct L *e; */
/*   e = make(v); */
/*   e->suivant = l->suivant; */
/*   l->suivant = e; */
/*   e->suivant->precedent = e; */
/*   e->precedent = l; */
/*   return 0; */
/* } */

/* /\* suppression d'un élément donné *\/ */
/* int supprimer(struct L *l) { */
/*   l->precedent->suivant = l->suivant; */
/*   l->suivant->precedent = l->precedent; */
/*   return 0; */
/* } */

/* /\* affichage *\/ */
/* int afficher(struct L *l) { */
/*   struct L *p; */
/*   p = l; */
/*   putchar(p->valeur); */
/*   p = p->suivant; */
/*   while (p != l) { */
/*     putchar(p->valeur); */
/*     p = p->suivant; */
/*   } */
/*   putchar(10); */
/*   return 0; */
/* } */

/* int main() { */
/*   struct L *l; */
/*   l = make(65); */
/*   afficher(l); */
/*   inserer_apres(l, 66); */
/*   afficher(l); */
/*   inserer_apres(l, 67); */
/*   afficher(l); */
/*   supprimer(l->suivant); */
/*   afficher(l); */
/*   return 0; */
/* } */

/* int main() */
/* { */
/*   return 42; */
/* } */

/* struct ABR { */
/*   int valeur; */
/*   struct ABR *gauche, *droite; */
/* }; */

/* struct ABR* make(int v, struct ABR *g, struct ABR *d) { */
/*   struct ABR * s; */
/*   s = sbrk(sizeof(struct ABR)); */
/*   s->valeur = v; */
/*   s->gauche = g; */
/*   s->droite = d; */
/*   return s; */
/* } */

/* int insere(struct ABR *a, int x) { */
/*   if (x == a->valeur) */
/*     return 0; */
/*   if (x < a->valeur) { */
/*     if (a->gauche == 0) */
/*       a->gauche = make(x, 0, 0); */
/*     else */
/*       insere(a->gauche, x); */
/*   } else */
/*     if (a->droite == 0) */
/*       a->droite = make(x, 0, 0); */
/*     else */
/*       insere(a->droite, x); */
/*   return 0; */
/* } */

/* int contient(struct ABR *a, int x) { */
/*   if (x == a->valeur) return 1; */
/*   if (x < a->valeur && a->gauche != 0) return contient(a->gauche, x); */
/*   if (a->droite != 0) return contient(a->droite, x); */
/*   return 0; */
/* } */

/* int print_int(int n) { */
/*   int q; */
/*   q = n / 10; */
/*   if (n > 9) print_int(q); */
/*   putchar('0' + (n - 10*q)); */
/*   return 0; */
/* } */

/* int print(struct ABR *a) { */
/*   putchar('('); */
/*   if (a->gauche != 0) print(a->gauche); */
/*   print_int(a->valeur); */
/*   if (a->droite != 0) print(a->droite); */
/*   return putchar(')'); */
/* } */

/* int main() { */
/*   struct ABR *dico; */
/*   dico = make(1, 0, 0); */
/*   insere(dico, 17); */
/*   insere(dico, 5); */
/*   insere(dico, 8); */
/*   print(dico); */
/*   putchar(10); */
/*   if (contient(dico, 5) && !contient(dico, 0) && */
/*       contient(dico, 17) && !contient(dico, 3)) { */
/*     putchar('o'); */
/*     putchar('k'); */
/*     putchar(0x0a); */
/*   } */
/*   insere(dico, 42); */
/*   insere(dico, 1000); */
/*   insere(dico, 0); */
/*   print(dico); */
/*   putchar(10); */
/*   return 0; */
/* } */

/* int main() { */
/*   int i, n; */
/*   i = 0; */
/*   n = 10; */
/*   while (i < n) { */
/*     i = i + 1; */
/*     putchar('@'); */
/*     putchar(10); */
/*   } */
/*   /\* putchar('#'); *\/ */
/*   /\* putchar(10); *\/ */
/*   return 0; */
/* } */

/* int fact(int n) { */
/*   if (n <= 1) return 1; */
/*   return n * fact(n-1); */
/* } */

/* int main() { */
/*   int n; */
/*   n = 0; */
/*   while (n <= 4) { */
/*     putchar(65 + fact(n)); */
/*     n = n+1; */
/*   } */
/*   putchar(10); */
/*   return 0; */
/* } */

/* int print_int(int n) { */
/*   int q; */
/*   q = n / 10; */
/*   if (n > 9) print_int(q); */
/*   putchar('0' + (n - 10*q)); */
/*   return 0; */
/* } */

/* int ackermann(int m, int n) */
/* { */
/*         if (!m) return n + 1; */
/*         if (!n) return ackermann(m - 1, 1); */
/*         return ackermann(m - 1, ackermann(m, n - 1)); */
/* } */

/* int main() */
/* { */
/*         int m, n; */
/*         m = 0; */
/*         while (m < 8) { */
/*           n = 0; */
/*           while (n < 6 - m) { */
/*             print_int(ackermann(m, n)); */
/*             putchar(10); */
/*             n = n + 1; */
/*           } */
/*           m = m + 1; */
/*         } */
/*         return 0; */
/* } */

int main() {
  int a, b, c;
  a = 1;
  b = a + 42;
  c = a + b;
  a = 2 * c;
  if (a < 0) {
    int d;
    int e, f;
    d = 12;
    e = a + 2;
    c = d;
    f = d + e + c;
  }
  return 0;
}
