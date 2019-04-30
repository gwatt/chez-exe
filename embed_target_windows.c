
#include <windows.h>
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <scheme.h>
#include "setup.h"

extern const unsigned char chezschemebootfile;
extern const unsigned chezschemebootfile_size;
extern const unsigned char scheme_program;
extern const unsigned scheme_program_size;

char tmpdir[MAX_PATH-14];
char bootfilename[MAX_PATH];
char schemefilename[MAX_PATH];

char *cleanup_bootfile;
char *cleanup_schemefile;

void cleanup(void) {
	if (cleanup_bootfile) DeleteFile(bootfilename);
	if (cleanup_schemefile) DeleteFile(schemefilename);
}

void maketempfile(const char *prefix, char *tempfilename, const unsigned char *contents, DWORD size) {
	HANDLE hFile;
	DWORD written;
	assert(GetTempFileName(tmpdir, prefix, 0, tempfilename));
	hFile = CreateFile(tempfilename,
		GENERIC_WRITE | GENERIC_READ,
		0,
		NULL,
		TRUNCATE_EXISTING,
		0, //FILE_ATTRIBUTE_TEMPORARY | FILE_FLAG_DELETE_ON_CLOSE,
		NULL);
	if (hFile == INVALID_HANDLE_VALUE) {
		fprintf(stderr, "ERROR MAKING TEMP FILE: %ld %s\n", GetLastError(), tempfilename);
		exit(1);
	}
	if (!WriteFile(hFile, contents, size, &written, NULL)) {
		fprintf(stderr, "ERROR WRITING FILE %s: %ld\n", tempfilename, GetLastError());
		fprintf(stderr, "total bytes: %ld\nbytes written: %ld\n", size, written);
		exit(1);
	}
	assert(written == size);
	CloseHandle(hFile);
}

int scheme_main(int argc, char *argv[]) {
	DWORD res;

	atexit(cleanup);

	res = GetTempPath(sizeof(tmpdir), tmpdir);
	assert(res < sizeof(tmpdir));
	maketempfile("b", bootfilename, &chezschemebootfile, chezschemebootfile_size);
	cleanup_bootfile = bootfilename;
	maketempfile("s", schemefilename, &scheme_program, scheme_program_size);
	cleanup_schemefile = schemefilename;

	return run_program(argc, argv, bootfilename, schemefilename);
}