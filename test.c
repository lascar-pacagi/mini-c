int fact_rec(int n) {
  if (n <= 1) return 1;
  return n * fact_rec(n - 1);
}

int main() {
  if (fact_rec(10) == 3628800) putchar('1');
  putchar(10);
  return 0;
}