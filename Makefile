
.PHONEY: clean

incdir ?= $(bootpath)
libdir ?= $(bootpath)

psboot = $(bootpath)/petite.boot
csboot = $(bootpath)/scheme.boot
kernel = $(libdir)/kernel.o
scheme ?= scheme

CFLAGS += $(shell echo '(include "utils.ss") (format (current-output-port) "-m~a" (machine-bits))' | $(scheme) -q -b $(psboot))

compile-chez-program: compile-chez-program.ss chez.a
	$(scheme) -b ./boot --compile-imported-libraries --program $< $<

chez.a: embed_target.o boot.o $(kernel)
	ar rcs $@ $^

embed_target.o: embed_target.c
	cc -c -o $@ $< -I$(incdir) -Wall -Wextra -pedantic $(CFLAGS)

boot.o: boot.s boot
	cc -c $(CFLAGS) $<

boot.s:
	echo '(include "utils.ss") (build-assembly-file "boot.s" "chezschemebootfile" "boot")' | $(scheme) -q -b $(psboot)

boot: $(psboot) $(csboot)
	echo '(make-boot-file "boot" (list) "$(psboot)" "$(csboot)")' | "$(scheme)" -q -b "$(psboot)" -b "$(csboot)"

clean:
	rm -f compile-chez-program boot chez.a *.s *.o *.chez *.so *.wpo

