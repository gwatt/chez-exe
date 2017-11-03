
.PHONEY: clean

main: main.c boot
	cc -o main main.c $(CFLAGS) -std=gnu99 -Wall -Wextra -pedantic
	objcopy --add-section chezschemebootfile=boot --add-section schemesource=hello.ss main

clean:
	rm -f main
