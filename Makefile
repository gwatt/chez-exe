
.PHONEY: clean

bootpath = $(csdir)/$m/boot/$m
psboot = $(bootpath)/petite.boot
csboot = $(bootpath)/scheme.boot
kernel = $(bootpath)/kernel.o
binpath = $(csdir)/$m/bin
scmexe = $(binpath)/scheme

h = $(m:t%=%)

ifeq ($h, a6le)
CFLAGS += -m64 -DBITS=64
else ifeq ($h, i3le)
CFLAGS += -m32 -DBITS=32
endif

compile-chez-program: compile-chez-program.ss chez.a
	$(scmexe) -b ./boot --program $< $<

chez.a: embed_target.o boot.o $(kernel)
	ar rcs $@ $^

embed_target.o: embed_target.c
	cc -c -o $@ $< -I$(bootpath) -Wall -Wextra -pedantic $(CFLAGS)

boot.o: boot.s boot
	cc -c $(CFLAGS) $<

boot: $(psboot) $(csboot)
	sh make-bootfile.sh "$(scmexe)" "$(psboot)" "$(csboot)"

clean:
	rm -f boot chez.a embed_target.o *.chez *.so *.wpo
