
#include <assert.h>
#include <fcntl.h>
#include <errno.h>	
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <scheme.h>

extern const char chezschemebootfile_start;
extern const char chezschemebootfile_end;
extern const char scheme_program_start;
extern const char scheme_program_end;

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

	bootfd = maketempfile(bootfilename, &chezschemebootfile_start, &chezschemebootfile_end - &chezschemebootfile_start);
	schemefd = maketempfile(schemefilename, &scheme_program_start, &scheme_program_end - &scheme_program_start);

	Sscheme_init(0);
	Sregister_boot_file(bootfilename);
	Sbuild_heap(0, 0);
	ret = Sscheme_program(schemefilename, argc, argv);

	close(bootfd);
	close(schemefd);

	return ret;
}

