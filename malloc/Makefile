all: malloc rw brk input mmap mfile

malloc: malloc.c
	gcc -static -o $@ $<

rw: rw.c
	gcc -static -o $@ $<

brk: brk.c
	gcc -static -o $@ $<

input: input.c
	gcc -static -o $@ $< -lpthread

mmap: mmap.c
	gcc -static -o $@ $<

mfile: mfile.c
	gcc -static -o $@ $<

clean:
	rm -rf malloc rw brk input mmap mfile
