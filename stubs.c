
int setupterm(char *term, int fd, int *errret) {
	return 0;
}

int tputs(const char *str, int affcnt, int (*putc)(int)) {
	return 0;
}

void *cur_term;
