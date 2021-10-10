WORDLISTS = $(wildcard *.add)
SPELLFILES = $(addsuffix .spl,$(WORDLISTS))

all : $(SPELLFILES)

%.add.spl : %.add
	vim "+mkspell! $<" +q
