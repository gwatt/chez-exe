
.PHONY: clean cleanconfig

-include make.in

incdir ?= $(bootpath)
libdir ?= $(bootpath)

psboot = $(bootpath)/petite.boot
csboot = $(bootpath)/scheme.boot
kernel = $(libdir)/kernel.o
scheme ?= scheme

runscheme = "$(scheme)" -b "$(bootpath)/petite.boot" -b "$(bootpath)/scheme.boot"

compile-chez-program: compile-chez-program.ss chez.a $(wildcard config.ss)
	$(scheme) -b ./boot --compile-imported-libraries --program $< --chez-lib-dir . $<

chez.a: embed_target.o stubs.o boot.o $(kernel)
	ar rcs $@ $^

%.o: %.c
	$(CC) -c -o $@ $< -I$(incdir) -Wall -Wextra -pedantic $(CFLAGS)

boot.o: boot.generated.c
	$(CC) -o $@ -c $(CFLAGS) $<

boot.generated.c: boot
	$(runscheme) --script build-included-binary-file.ss "$@" chezschemebootfile boot

boot: $(psboot) $(csboot)
	$(runscheme) --script make-boot-file.ss "$(bootpath)"

install: compile-chez-program
	install -m 755 compile-chez-program $(DESTDIR)$(installbindir)/
	install -m 644 chez.a $(DESTDIR)$(installlibdir)/

clean:
	rm -f compile-chez-program boot chez.a *.generated.c *.s *.o *.chez *.so *.wpo

cleanconfig:
	rm -f config.ss make.in
