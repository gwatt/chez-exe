
.PHONEY: clean

bootpath = $(csdir)/$m/boot/$m
psboot = $(bootpath)/petite.boot
csboot = $(bootpath)/scheme.boot
kernel = $(bootpath)/kernel.o
binpath = $(csdir)/$m/bin
scmexe = $(binpath)/scheme

compile-chez-program: compile-chez-program.ss chez.a
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
