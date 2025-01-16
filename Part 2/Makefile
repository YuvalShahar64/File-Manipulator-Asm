CC=gcc
NASM=nasm
LD=ld
CFLAGS= -m32 -Wall -ansi -nostdlib -fno-stack-protector
ASMFLAGS=-f elf32

all: task2

task2: start.o main.o
	$(LD) -m elf_i386 start.o main.o -o task2

start.o: start.s
	$(NASM) $(ASMFLAGS) start.s -o start.o

main.o: main.c
	$(CC) $(CFLAGS) -c main.c -o main.o

clean:
	rm -f *.o task2
