
.PHONEY: clean

bootpath = $(csdir)/$m/boot/$m
psboot = $(bootpath)/petite.boot
csboot = $(bootpath)/scheme.boot
kernel = $(bootpath)/kernel.o
binpath = $(csdir)/$m/bin
scmexe = $(binpath)/scheme

embed_target: main.c $(kernel) boot
	cc -o $@ $< $(kernel) -I$(bootpath) -ltinfo -lpthread -ldl -lm -Wall -Wextra -pedantic $(CFLAGS)
	objcopy --add-section chezschemebootfile=boot $@

boot: $(psboot) $(csboot)
	sh make-bootfile.sh "$(scmexe)" "$(psboot)" "$(csboot)"

clean:
	rm -f embed_target boot
