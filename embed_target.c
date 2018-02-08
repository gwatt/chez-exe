
#include <assert.h>
#include <fcntl.h>
#include <errno.h>	
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <scheme.h>

extern const char chezschemebootfile;
extern const unsigned chezschemebootfile_size;
extern const char scheme_program;
extern const unsigned scheme_program_size;

int maketempfile(char *template, const char *contents, size_t size) {
	int fd;
	fd = mkstemp(template);
	assert(fd >= 0);

	assert(write(fd, contents, size) == size);
	assert(lseek(fd, 0, SEEK_SET) == 0);
	return fd;
}

int main(int argc, const char **argv) {
	char bootfilename[] = "/tmp/chezschemebootXXXXXX";
	int bootfd;
	char schemefilename[] = "/tmp/schemeprogramXXXXXX";
	int schemefd;
	int ret;

	fprintf(stderr, "chezschemebootfile_size = %d\n", chezschemebootfile_size);
	fprintf(stderr, "scheme_program_size = %d\n", scheme_program_size);

	bootfd = maketempfile(bootfilename, &chezschemebootfile, chezschemebootfile_size);
	schemefd = maketempfile(schemefilename, &scheme_program, scheme_program_size);

	Sscheme_init(0);
	Sregister_boot_file(bootfilename);
	Sbuild_heap(0, 0);
	ret = Sscheme_program(schemefilename, argc, argv);

	close(bootfd);
	close(schemefd);

	return ret;
}

