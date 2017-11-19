
.PHONEY: clean

bootpath = $(csdir)/$m/boot/$m
psboot = $(bootpath)/petite.boot
csboot = $(bootpath)/scheme.boot
kernel = $(bootpath)/kernel.o
binpath = $(csdir)/$m/bin
scmexe = $(binpath)/scheme

compile-chez: chez.a compile-whole-program
	cc -o $@ $< -W -Wall -Wextra -pedantic -lpthread -ltinfo -lm -ldl $(CFLAGS)
	objcopy compile-chez --add-section schemeprogram=compile-whole-program

compile-whole-program: compile-whole-program.ss
	$(scmexe) -b ./boot --program $< $<

chez.a: embed_target.o $(kernel)
	ar rcs $@ $^

embed_target.o: embed_target.c boot
	cc -c -o $@ $< -I$(bootpath) -Wall -Wextra -pedantic $(CFLAGS)
	objcopy --add-section chezschemebootfile=boot $@

boot: $(psboot) $(csboot)
	sh make-bootfile.sh "$(scmexe)" "$(psboot)" "$(csboot)"

clean:
	rm -f boot chez.a embed_target.o
