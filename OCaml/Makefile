# OCAMLC = ocamlopt -noassert -unsafe
OCAMLC = ocamlopt -g

ML=$(shell ocamldep -sort $(wildcard *.ml))
MODULES=$(ML:.ml=.cmx)

default: $(MODULES) main

main: $(MODULES)
	if [ -f main.ml ] ; then \
	  $(OCAMLC) $(MODULES) -o main ; \
	fi

SOURCES = $(wildcard *.ml) $(wildcard *mli)
.depend: $(SOURCES)
	ocamldep $(SOURCES) > .depend
-include .depend

%.cmx: %.ml Makefile
	$(OCAMLC) -c $<
%.cmi: %.mli Makefile
	$(OCAMLC) -c $<

clean:
	rm -f main
	rm -f *.cmx *.cmo *.cmi *.o
