mini-c: main.native
	ln -fs main.native $@

main.native: *.ml*
	ocamlbuild $@

clean:
	ocamlbuild -clean
	rm -f mini-c

