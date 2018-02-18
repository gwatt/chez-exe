
.PHONY: clean cleanconfig

-include make.in

incdir ?= $(bootpath)
libdir ?= $(bootpath)

psboot = $(bootpath)/petite.boot
csboot = $(bootpath)/scheme.boot
kernel = $(libdir)/kernel.o
scheme ?= scheme

CFLAGS += $(shell echo '(include "utils.ss") (format (current-output-port) "-m~a" (machine-bits))' | $(scheme) -q -b $(psboot))

compile-chez-program: compile-chez-program.ss chez.a $(wildcard config.ss)
	$(scheme) -b ./boot --compile-imported-libraries --program $< --chez-file chez.a $<

chez.a: embed_target.o stubs.o boot.o $(kernel)
	ar rcs $@ $^

%.o: %.c
	$(CC) -c -o $@ $< -I$(incdir) -Wall -Wextra -pedantic $(CFLAGS)

boot.o: boot.generated.c
	$(CC) -o $@ -c $(CFLAGS) $<

boot.generated.c: boot
	echo '(include "utils.ss") (build-included-binary-file "boot.generated.c" "chezschemebootfile" "boot")' | $(scheme) -q -b $(psboot)

boot: $(psboot) $(csboot)
	echo '(make-boot-file "boot" (list) "$(psboot)" "$(csboot)")' | "$(scheme)" -q -b "$(psboot)" -b "$(csboot)"

install: compile-chez-program
	install -m 755 compile-chez-program -t $(DESTDIR)$(installbindir)/
	install -m 644 chez.a $(DESTDIR)$(installlibdir)/

clean:
	rm -f compile-chez-program boot chez.a *.generated.c *.s *.o *.chez *.so *.wpo

cleanconfig:
	rm -f config.ss make.in
