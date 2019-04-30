
#include <assert.h>
#include <fcntl.h>
#include <errno.h>	
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <scheme.h>
#include "setup.h"

char bootfilename[] = "/tmp/chezschemebootXXXXXX";
char schemefilename[] = "/tmp/schemeprogramXXXXXX";
const char *cleanup_bootfile = 0;
const char *cleanup_schemefile = 0;

void cleanup(void) {
	if (cleanup_bootfile) unlink(bootfilename);
	if (cleanup_schemefile) unlink(schemefilename);
}

int maketempfile(char *template, const char *contents, size_t size) {
	int fd;
	fd = mkstemp(template);
	assert(fd >= 0);

	assert(write(fd, contents, size) == size);
	assert(lseek(fd, 0, SEEK_SET) == 0);
	return fd;
}

int main(int argc, const char **argv) {
	int bootfd;
	int schemefd;
	int ret;

	atexit(cleanup);

	bootfd = maketempfile(bootfilename, &chezschemebootfile, chezschemebootfile_size);
	cleanup_bootfile = bootfilename;
	schemefd = maketempfile(schemefilename, &scheme_program, scheme_program_size);
	cleanup_schemefile = schemefilename;

	ret = run_program(argc, argv, bootfilename, schemefilename);

	close(bootfd);
	close(schemefd);

	return ret;
}

