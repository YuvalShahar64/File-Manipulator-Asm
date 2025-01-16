CC=gcc
NASM=nasm
LD=ld
CFLAGS= -m32 -Wall -ansi -nostdlib -fno-stack-protector
ASMFLAGS=-f elf32

all: task1 

task1: encoderAss.o util.o
	$(LD) -m elf_i386 encoderAss.o util.o -o task1

start.o: start.s
	$(NASM) $(ASMFLAGS) start.s -o start.o

encoderAss.o: encoderAss.s
	$(NASM) $(ASMFLAGS) encoderAss.s -o encoderAss.o

util.o: util.c
	$(CC) $(CFLAGS) -c util.c -o util.o

clean:
	rm -f *.o task1
