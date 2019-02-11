
.PHONY: clean cleanconfig

-include make.in

fcs = full-chez.boot
pcs = petite-chez.boot

incdir ?= $(bootpath)
libdir ?= $(bootpath)

psboot = $(bootpath)/petite.boot
csboot = $(bootpath)/scheme.boot
kernel = $(libdir)/kernel.o
scheme ?= scheme

runscheme = "$(scheme)" -b "$(bootpath)/petite.boot" -b "$(bootpath)/scheme.boot"

compile-chez-program: compile-chez-program.ss full-chez.a petite-chez.a $(wildcard config.ss)
	$(runscheme) --compile-imported-libraries --program $< --full-chez --chez-lib-dir . $<

%.a: embed_target.o stubs.o %_boot.o $(kernel)
	ar rcs $@ $^

stubs.o: stubs.c
	$(CC) -c -o $@ $<

%.o: %.c
	$(CC) -c -o $@ $< -I$(incdir) -Wall -Wextra -pedantic $(CFLAGS)

%_boot.o: %_boot.c
	$(CC) -o $@ -c $(CFLAGS) $<

%_boot.c: %.boot
	$(runscheme) --script build-included-binary-file.ss "$@" chezschemebootfile $^

$(fcs): $(psboot) $(csboot)
	$(runscheme) --script make-boot-file.ss $@ $^

$(pcs): $(psboot)
	$(runscheme) --script make-boot-file.ss $@ $^

$(psboot) $(csboot) $(kernel):
	@echo Unable to find "$@". Try running gen-config.ss to set dependency paths
	@false

install: compile-chez-program
	install -m 755 compile-chez-program $(DESTDIR)$(installbindir)/
	install -m 644 full-chez.a petite-chez.a $(DESTDIR)$(installlibdir)/

clean:
	rm -f compile-chez-program *.a *_boot.* *.s *.o *.chez *.so *.wpo *.boot

cleanconfig:
	rm -f config.ss make.in
