
#include <assert.h>
#include <elf.h>
#include <fcntl.h>
#include <errno.h>	
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <scheme.h>

#if BITS == 64
	typedef Elf64_Ehdr Elf_Ehdr;
	typedef Elf64_Shdr Elf_Shdr;
	typedef Elf64_Off Elf_Off;
#elif BITS == 32
	typedef Elf32_Ehdr Elf_Ehdr;
	typedef Elf32_Shdr Elf_Shdr;
	typedef Elf32_Off Elf_Off;
#else
# error "Unable to determine machine bits"
#endif

const char *bootsectionname = "chezschemebootfile";
const char *schemesectionname = "schemeprogram";

char *read_section_header_names(FILE *fp, Elf_Ehdr ehdr) {
	Elf_Shdr strings;
	char *section_header_names;
	fseek(fp, ehdr.e_shoff + sizeof(Elf_Shdr) * ehdr.e_shstrndx, SEEK_SET);
	fread(&strings, sizeof strings, 1, fp);
	section_header_names = calloc(strings.sh_size, 1);
	fseek(fp, strings.sh_offset, SEEK_SET);
	fread(section_header_names, 1, strings.sh_size, fp);

	return section_header_names;
}

size_t extract_elf_section(FILE *fp, uint16_t shnum, Elf_Off shoff, const char *names, const char *name, char **body) {
	Elf_Shdr shdr;
	int count = 0;
	size_t size = -1;
	*body = 0;

	assert(fseek(fp, shoff, SEEK_SET) == 0);
	while(count++ < shnum) {
		assert(fread(&shdr, sizeof shdr, 1, fp) == 1);
		if (strcmp(&names[shdr.sh_name], name) == 0) {
			assert(fseek(fp, shdr.sh_offset, SEEK_SET) == 0);
			size = shdr.sh_size;
			assert((*body = malloc(size)) != 0);
			assert(fread(*body, 1, size, fp) == size);
                        break;
		}
	}
	return size;
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
	FILE *fp;
	Elf_Ehdr ehdr;
	char *s_names;
	char *boot;
	size_t bootsize;
	char *scheme;
	size_t schemesize;
	char bootfilename[] = "/tmp/chezschemebootXXXXXX";
	int bootfd;
	char schemefilename[] = "/tmp/schemeprogramXXXXXX";
	int schemefd;
        int ret;

	fp = fopen("/proc/self/exe", "rb");
	fread(&ehdr, sizeof ehdr, 1, fp);
	s_names = read_section_header_names(fp, ehdr);
	bootsize = extract_elf_section(fp, ehdr.e_shnum, ehdr.e_shoff, s_names, bootsectionname, &boot);
	schemesize = extract_elf_section(fp, ehdr.e_shnum, ehdr.e_shoff, s_names, schemesectionname, &scheme);
	free(s_names);
	fclose(fp);

	assert(bootsize > 0);
	if (!schemesize) {
		fputs("No scheme program found\n", stderr);
		free(boot);
		return -ENOENT;
	}

	bootfd = maketempfile(bootfilename, boot, bootsize);
	schemefd = maketempfile(schemefilename, scheme, schemesize);

        free(boot);
        free(scheme);

	Sscheme_init(0);
	Sregister_boot_file(bootfilename);
	Sbuild_heap(0, 0);
	ret = Sscheme_program(schemefilename, argc, argv);

	close(bootfd);
	close(schemefd);

	return ret;
}

