Ru version:

компиляция файлов:
nasm -f bin boot.asm -o boot.bin
nasm -f bin kernel.asm -o kernel.asm

дальше создание загрузочного образа
можно через "cat"
cat boot.bin kernel.bin > os.img
или через "dd"
dd if=/dev/zero of=os.img bs=512 count=2880
dd if=boot.bin of=os.img conv=notrunc
dd if=kernel.bin of=os.img bs=512 seek=1 conv=notrunc
чтобы запустить систему нужна виртуалка qemu
qemu-system-x86_64 -hda os.img
или чтобы не терять время просто написать 
make run
En version:
compile file:
nasm -f bin boot.asm -o boot.bin
nasm -f bin kernel.asm -o kernel.asm
create bootable image:
cat boot.bin kernel.bin > os.img
or
dd if=/dev/zero of=os.img 
s=512 count=2880
dd if=boot.bin of=os.img conv=notrunc
dd if=kernel.bin of=os.img bs=512 seek=1 conv=notrunc
starting system on qemu:
qemu-system-x86_64 -hda os.img
or starting with make
make run
![best_memory](https://github.com/user-attachments/assets/d927b809-c60f-4cdd-8c04-915999c03fa5)

