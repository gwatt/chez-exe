
.PHONEY: clean

bootpath = $(csdir)/$m/boot/$m
psboot = $(bootpath)/petite.boot
csboot = $(bootpath)/scheme.boot
kernel = $(bootpath)/kernel.o
binpath = $(csdir)/$m/bin
scmexe = $(binpath)/scheme

h = $(m:t%=%)

ifeq ($h, a6le)
CFLAGS += -m64
else ifeq ($h, i3le)
CFLAGS += -m32
endif

compile-chez-program: compile-chez-program.ss chez.a
	$(scmexe) -b ./boot --compile-imported-libraries --program $< $<

chez.a: embed_target.o boot.o $(kernel)
	ar rcs $@ $^

embed_target.o: embed_target.c
	cc -c -o $@ $< -I$(bootpath) -Wall -Wextra -pedantic $(CFLAGS)

boot.o: boot.s boot
	cc -c $(CFLAGS) $<

boot.s:
	echo '(import (build-assembly-file)) (build-assembly-file "boot.s" "chezschemebootfile" "boot")' | $(scmexe) -q -b $(psboot)

boot: $(psboot) $(csboot)
	echo '(make-boot-file "boot" (list) "$(psboot)" "$(csboot)")' | "$(scmexe)" -q -b "$(psboot)" -b "$(csboot)"

clean:
	rm -f boot chez.a *.s *.o *.chez *.so *.wpo

