This is an incomplete port of a program I wrote that is just a quick test to write something in x86 assmebly.
Run on linux with this command:
nasm -f elf mans.asm ; ld -melf_i386 mans.o; ./a.out

Or if ld defaults to i386 (because you are on a 32 bit machine and not a 64 bit machine) then you just need this:
nasm -f elf mans.asm ; ld mans.o; ./a.out
