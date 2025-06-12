ASM = nasm
QEMU = qemu-system-i386
CAT = cat

all: os.img

grub.bin: boot.asm
	$(ASM) -f bin -o boot.bin boot.asm

kernel.bin: kernel.asm
	$(ASM) -f bin -o kernel.bin kernel.asm

os.img: boot.bin kernel.bin
	$(CAT) boot.bin kernel.bin > os.img

run: os.img
	$(QEMU) -fda os.img

