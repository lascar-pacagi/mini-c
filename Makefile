test: main.native mini-c
	./mini-c --debug test.c

main.native: *.ml*
	ocamlbuild $@

mini-c:
	ln -s main.native $@

clean:
	ocamlbuild -clean
	rm -f mini-c
