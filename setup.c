
#include <scheme.h>
#include "setup.h"

static const char *argv0;

const char *program_name(void) {
	return argv0;
}

void custom_init(void) {
	Sregister_symbol("program_name", program_name);
}

int run_program(int argc, const char **argv, const char *bootfilename, const char *schemefilename) {
	argv0 = argv[0];
	Sscheme_init(0);
	Sregister_boot_file(bootfilename);
	Sbuild_heap(0, custom_init);
	return Sscheme_program(schemefilename, argc, argv);
}
