bits 16
org 0x8000

%define CMD_LENGTH 64
%define VIDEO_MEMORY 0xB8000
%define MAX_PASS_LEN      16


jmp kernel_start

; Данные
shell_prompt db "YodaOS-shell> ", 0
shell_msg db "shell comming soon..."
prompt db "YodaOS-tool> ",0
help_msg db "Commands:", 0x0D, 0x0A, "sysinfo, reboot, shutdown, echo <text>, goto-echo <word>, help, rootfs, dir, mkdir, cd, process-sys, clear", 0x0D, 0x0A,"secure command:", 0x0D, 0x0A,"secret-parrot, secret-ball",0
sysinfo_msg db "YodaOs beta-console v1.0 | ???MB RAM | VGA Text Mode",0
reboot_msg db "Rebooting...",0
shutdown_msg db "Shutting down...",0
color_msg db "color been change",0
invalid_color_msg db "enter number color 1-15!", 0
unknown_msg db "Unknown command! Type 'help'",0
parrot_msg db "Secret parrot |0_0| (-_-)", 0
rootfs_msg db "rootfs not found", 0; заглушка 
dir_msg db "Error code 1 - Not found filesystem on disk", 0 ;заглушка
mkdir_msg db "Error code 1 - Not found filesystem on disk", 0 ;заглушка
cd_msg db "Error code 1 - Not found filesystem on disk", 0 ;заглушка
process_sys_msg db "1, Kernel.asm", 0
logcat_msg db "Start", 0x0D, 0x0A, "log:starting kernel.bin...", 0x0D,0x0A,"log: kernel.bin has starting", 0x0D,0x0A, "log: starting simpleboot", 0x0D,0x0A,"log: succes, system start", 0x0D, 0x0A, "log: logcat exit", 0
simpleboot_msg db "Simpleboot version: 1.0", 0x0D, 0x0A, "write for YodaOS",0x0D,0x0A, "select boot logo:", 0x0D,0x0A," simpleboot-1 for circle",0x0D, 0x0A,"simpleboot-2 for square",0
neofetch_msg db "    000   ", 0x0D, 0x0A, "  0000000", 0x0D, 0x0A, " 000000000", 0x0D, 0x0A, " 000000000", 0x0D, 0x0A, "  0000000", 0x0D, 0x0A, "    000", 0x0D, 0x0A, "YodaOS system", 0x0D, 0x0A, " using ram: ???MB", 0x0D, 0x0A, "video mode: 80x25 symbol", 0x0D, 0x0A, "video memory: ????Mb", 0x0D, 0x0A, "command use neofetch", 0x0D, 0x0A, "System-type: console", 0x0D, 0x0A, "filesystem: not foudn (version with out filesystem)", 0
bool_msg db "                                       000 ", 0x0D, 0x0A, "                                      00000", 0x0D, 0x0A, "                                      00000", 0x0D, 0x0A, "                                       000 ", 0x0D, 0x0A,"secure ball",0
bootload_msg db " ", 0x0D, 0x0A, " ", 0x0D, 0x0A, " ", 0x0D, 0x0A, " ", 0x0D, 0x0A, " ", 0x0D, 0x0A, " ", 0x0D, 0x0A, " ", 0x0D, 0x0A, "", 0x0D, 0x0A, "", 0x0D, 0x0A, "", 0x0D, 0x0A, "                                       000 ", 0x0D, 0x0A, "                                      01110", 0x0D, 0x0A, "                                      01110", 0x0D, 0x0A, "                                       000 ", 0x0D, 0x0A,"                                  YodaOS v1.0", 0x0D, 0x0A,"                                 simple bootloader ", 0x0D, 0x0A, "                                       100%",0 
bootload_square_msg db " ", 0x0D, 0x0A, " ", 0x0D, 0x0A, " ", 0x0D, 0x0A, " ", 0x0D, 0x0A, " ", 0x0D, 0x0A, " ", 0x0D, 0x0A, " ", 0x0D, 0x0A, "", 0x0D, 0x0A, "", 0x0D, 0x0A, "", 0x0D, 0x0A, "                                      00000 ", 0x0D, 0x0A, "                                      01110", 0x0D, 0x0A, "                                      01110", 0x0D, 0x0A, "                                      00000 ", 0x0D, 0x0A,"                                  YodaOS v1.0", 0x0D, 0x0A,"                                 simple bootloader ", 0x0D, 0x0A, "                                       100%",0 
baby_yoda:
    db "  @@@@@@@  ", 0x0D, 0x0A   
    db " @@&&&&&@@ ", 0x0D, 0x0A 
    db "@##%   %##@", 0x0D, 0x0A 
    db "@##*   *##@", 0x0D, 0x0A   
    db "@##%   %##@", 0x0D, 0x0A
    db " @@&&&&&@@ ", 0x0D, 0x0A  
    db "  @@@@@@@  ", 0x0D, 0x0A 
    db "RAM: ???MB",0x0D, 0x0A
    db "VIDEO MEMORY: ???MB",0x0D, 0x0A
    db "system: YodaOS console edition v1.0 ",0x0D, 0x0A
    db "kernel: YodaOS v1.0.0.0-x86_64-debug",0x0D, 0x0A
    db "z-ram: none",0x0D, 0x0A
    db "processor: Unknown",0x0D, 0x0A
    db "disk: None",0x0D, 0x0A
    db "shell: YodaOS bsm-1.0",0x0D, 0x0A, 0
bootlogo:
    db "", 0x0D, 0x0A
    db "", 0x0D, 0x0A
    db "", 0x0D, 0x0A
    db "", 0x0D, 0x0A
    db "", 0x0D, 0x0A
    db "", 0x0D, 0x0A
    db "", 0x0D, 0x0A
    db "                                     @@@@@@@  ", 0x0D, 0x0A   
    db "                                    @@&&&&&@@ ", 0x0D, 0x0A 
    db "                                   @##%   %##@", 0x0D, 0x0A 
    db "                                   @##*   *##@", 0x0D, 0x0A   
    db "                                   @##%   %##@", 0x0D, 0x0A
    db "                                    @@&&&&&@@ ", 0x0D, 0x0A  
    db "                                     @@@@@@@  ", 0x0D, 0x0A 
    db "                                 simpleboot v1.0", 0x0D,0x0A
    db "                                     YodaOS", 0
baby_yoda_len equ $ - baby_yoda
section_circle db "1",0
setcolor dw 0
section_square db "2",0
section_romb db "romb",0
section_circle_msg db "good, reboot system now", 0
section_square_msg db "good, reboot system now", 0
error_msg db "error", 0
saved_value dd "circle", 0
old_int8 dw 0, 0
ticks dw 0

current_color db 11111100b 
input_buffer times CMD_LENGTH db 0
rand_seed dw 0x1234

commands:
    db "sysinfo",0
    db "reboot",0
    db "shutdown",0
    db "echo",0
    db "goto-echo",0
    db "help",0
    db "secret-parrot", 0
    db "rootfs", 0
    db "dir", 0
    db "mkdir", 0
    db "cd", 0
    db "secret-ball", 0
    db "clear", 0
    db "process-sys", 0
    db "neofetch", 0
    db "simpleboot-version", 0
    db "simpleboot-1", 0
    db "simpleboot-2", 0
    db "sleepmode", 0
    db "shell", 0
    db "cleatefile", 0
    db 0

command_shell:
    db "set-color-1",0
    db "logcat",0
    db "dumpsys-bootlogo-vision",0
    db "dumpsys-set-password",0
    db "exit-shell", 0
    db 0

command_shell_table:
    dw set_color_handler
    dw logcat_handler
    ;dw dumpsys_boot_handler
    ;dw dumpsys_pass_handler
    dw exit_shell_handler

command_table:
    dw sysinfo_handler ;1
    dw reboot_handler ;2
    dw shutdown_handler ;3
    dw echo_handler ;4
    dw goto_echo_handler ;5
    dw help_handler ;6
    dw secret_handler ;7
    dw rootfs_handler ;8
    dw dir_handler ;9
    dw mkdir_handler ;10
    dw cd_handler ;11
    dw secret_ball_handler ;12
    dw clear_handler ;13
    dw processsys_handler ;14
    dw neofetch_handler ;15
    dw simpleboot_handler ;16
    dw simpleboot_circle_handler ;17 заглушка
    dw simpleboot_square_handler ;18 заглушка
    dw sleepmode_handler ;19 заглушка
    dw shell_handler ;20 заглушка


kernel_start:
    cli
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0xFFFF
    sti
    mov ax, 0x0003
    int 0x10

    call read_from_cmos
    mov eax, [saved_value]   
    cmp eax, 1  
    jc section_circle_equal
    mov si,bootlogo
    call print_string

    
    call wait_3_seconds

    mov ax, 0x0003
    int 0x10


    

    jmp main_loop

main_loop:
    mov si, prompt
    call print_string
    call read_input
    call parse_command
    jmp main_loop
shell:
    mov si, shell_prompt
    call print_string
    call read_input
    call parse_shell_command
    jmp shell

parse_shell_command:
    mov si, input_buffer
    cmp byte [si], 0
    je .done_shell

    mov di, command_shell
    xor bx, bx
.check_cmd_shell:
    mov si, input_buffer
    call strcmp
    je .found_shell

.next_cmd_shell:
    inc di
    cmp byte [di-1], 0
    jne .next_cmd_shell
    inc bx
    cmp byte [di], 0
    jne .check_cmd_shell

    mov si, unknown_msg
    call print_string
    call new_line
    ret

.found_shell:
    shl bx, 1
    jmp [command_shell_table + bx]
.done_shell:
   ret
; ---------------------------- файловая система --------------------------------

;-----------------------------
init:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00      ; Устанавливаем стек
    sti                 ; Разрешаем прерывания

    ; Проверяем поддержку ACPI
    mov ax, 0xE980
    mov dx, 0x4150      ; Сигнатура 'PA' (APM)
    int 0x15
    jc apm_error        ; Если флаг переноса - ошибка
    
    ; Устанавливаем версию APM
    mov ax, 0x5304
    xor bx, bx          ; Отключаем все экземпляры APM
    int 0x15
    
    ; Подключаемся к интерфейсу
    mov ax, 0x5301
    xor bx, bx          ; Устройство: BIOS
    int 0x15
    jc apm_error
    
    ; Устанавливаем состояние питания
    mov ax, 0x5307
    mov bx, 1           ; Все устройства
    mov cx, 3           ; Состояние: Suspend-to-RAM (S3)
    int 0x15
    jc apm_error
    
    ; Если не сработало, используем альтернативный метод
    mov ax, 0x5300      ; Проверка установки APM
    xor bx, bx
    int 0x15
    jc apm_error
    
    mov ax, 0x5308      ; Включить управление питанием
    mov bx, 1
    mov cx, 1
    int 0x15
    
    mov ax, 0x5307      ; Переход в S3
    mov bx, 1
    mov cx, 3
    int 0x15

apm_error:
    ; Если ошибка - выводим сообщение
    mov dx, 0x400       ; PM1a Control Register (типичное значение)
    mov ax, 0x1F00 | (3 << 10)  ; SLP_TYPx=3 (S3), SLP_EN=1
    out dx, ax
    hlt   
    mov ax, 0x0003
    int 0x10
section_circle_equal:
    mov si, bootload_square_msg
    call print_string
    call wait_3_seconds
    mov ax, 0x0003
    int 0x10
    jmp main_loop

write_to_cmos:
    cli                     ; Запретить прерывания
    mov cx, 4               ; 4 байта
    mov dx, 0x38 ; Начальный адрес CMOS

.loop:
    mov al, dl
    out 0x70, al            ; Выбрать адрес в CMOS
    mov al, [esp - 4]       ; Текущий младший байт (со стека)
    out 0x71, al            ; Записать байт
    shr dword [esp - 4], 8  ; Сдвинуть значение для следующего байта
    inc dx                  ; Следующий адрес
    loop .loop
    sti                     ; Разрешить прерывания
    ret

read_from_cmos:
    cli                     ; Запретить прерывания
    xor eax, eax
    mov cx, 4
    mov dx, 0x3B            ; Старший адрес (0x3B → 0x38)
.loop:
    shl eax, 8              ; Сдвинуть предыдущие байты
    mov al, dl
    out 0x70, al            ; Выбрать адрес
    in al, 0x71             ; Прочитать байт
    dec dx                  ; Предыдущий адрес
    loop .loop
    sti                     ; Разрешить прерывания
    ret
wait_3_seconds:
    mov ah, 0x86
    mov cx, 0x002D      
    mov dx, 0xC6C0      
    int 0x15
    jc .fallback 
    ret

.fallback:
   
    mov cx, 55          
    xor ax, ax
    mov es, ax
    cli
   
    mov ax, [es:0x20]   
    mov [old_int8], ax
    mov ax, [es:0x22]
    mov [old_int8+2], ax

    mov word [es:0x20], timer_handler
    mov [es:0x22], cs
    sti

.wait_loop:
    cmp [ticks], cx
    jb .wait_loop

   
    cli
    mov ax, [old_int8]
    mov [es:0x20], ax
    mov ax, [old_int8+2]
    mov [es:0x22], ax
    sti
    ret


timer_handler:
    inc word [ticks]
    jmp far [cs:old_int8] 
print_string:
    pusha
    mov ah, 0x0E
    mov bh, 0
    mov bl, [current_color]
.loop:
    lodsb
    test al, al
    jz .done
    int 0x10
    jmp .loop
.done:
    popa
    ret

;-----------------------------
read_input:
    pusha
    mov di, input_buffer
    xor cx, cx

.loop:
    mov ah, 0
    int 0x16
    
    cmp al, 0x0D
    je .done
    
    cmp al, 0x08
    je .backspace
    
    cmp cx, CMD_LENGTH-1
    jae .loop
    
    stosb
    inc cx
    
    mov ah, 0x0E
    int 0x10
    jmp .loop

.backspace:
    test cx, cx
    jz .loop
    dec di
    dec cx
    mov byte [di], 0
    
    mov ah, 0x0E
    mov al, 0x08
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 0x08
    int 0x10
    jmp .loop

.done:
    mov byte [di], 0
    mov ah, 0x0E
    mov al, 0x0D
    int 0x10
    mov al, 0x0A
    int 0x10
    popa
    ret

;-----------------------------


parse_command:
    mov si, input_buffer
    cmp byte [si], 0
    je .done

    mov di, commands
    xor bx, bx


.check_cmd:
    mov si, input_buffer
    call strcmp
    je .found

.next_cmd:
    inc di
    cmp byte [di-1], 0
    jne .next_cmd
    inc bx
    cmp byte [di], 0
    jne .check_cmd

    mov si, unknown_msg
    call print_string
    call new_line
    ret

.found:
    shl bx, 1
    jmp [command_table + bx]

.done:
    ret
.done_shell:
    ret
;----------------------------
;shell команды
;----------------------------
set_color_handler:
    xor     ax, ax     ; DS=0
    mov     ds, ax
    cld                ; DF=0 because our LODSB requires it
    mov al, [setcolor]
    mov si, color_msg
    call    printstr
    mov bl, 2
    call new_line
    ret
logcat_handler:
    mov si, logcat_msg
    cmp al, [setcolor]
    je logcat_with_color
    call print_string
    call new_line
    ret
logcat_with_color:
    xor     ax, ax     ; DS=0
    mov     ds, ax
    cld                ; DF=0 because our LODSB requires it
    mov si, logcat_msg
    call    printstr
    mov bl, 2
    call new_line
    ret
exit_shell_handler:
    call main_loop
    ret

;-----------------------------
; Обработчики команд
;-----------------------------
shell_handler:
    call shell
    mov si, shell_prompt
    call print_string
    call new_line
    ret
sleepmode_handler:
    cli                 
    jmp 0:init 
    call new_line
simpleboot_circle_handler:
    mov al, [section_circle]
    mov [saved_value], al
    mov eax, [saved_value]
    call write_to_cmos
    mov si, section_circle_msg
    call print_string
    call new_line
    ret

simpleboot_square_handler:
    mov al, [section_square]
    mov [saved_value], al
    mov eax, [saved_value]
    call write_to_cmos
    mov si, section_square_msg
    call print_string
    call new_line
    ret


simpleboot_handler:
    mov si, simpleboot_msg
    call print_string
    call new_line
    ret

neofetch_handler: 
    mov si, baby_yoda
    call print_string
    call new_line
    ret


processsys_handler:
    mov si, process_sys_msg
    call print_string
    call new_line
    ret

clear_handler:
    mov ax, 0x0003
    int 0x10
    ret

dir_handler:
    xor     ax, ax     ; DS=0
    mov     ds, ax
    cld                ; DF=0 because our LODSB requires it
    mov si, dir_msg
    call    printstr
    mov bl, 2
    call new_line
    ret

mkdir_handler:
    xor     ax, ax     ; DS=0
    mov     ds, ax
    cld                ; DF=0 because our LODSB requires it
    mov si, mkdir_msg
    call    printstr
    mov bl, 2
    call new_line
    ret

cd_handler:
    xor     ax, ax     ; DS=0
    mov     ds, ax
    cld                ; DF=0 because our LODSB requires it
    mov si, cd_msg
    call    printstr
    mov bl, 2
    call new_line
    ret
printstr:
    mov     cx, 1     ; RepetitionCount
    mov     bh, 0     ; DisplayPage
print:
    lodsb
    cmp     al, 0
    je      done
    cmp     al, 32
    jb      skip
    mov     ah, 09h  ; BIOS.WriteCharacterWithAttribute
    int     10h
skip:
    mov     ah, 0Eh   ; BIOS.Teletype
    int     10h
    jmp     print
done:
    ret

secret_ball_handler:
    mov ax, 0x0003
    int 0x10
    mov si, bool_msg
    call print_string
    call new_line
    ret

rootfs_handler:
    mov si, rootfs_msg
    call print_string
    call new_line
    ret

secret_handler:
    mov si, parrot_msg
    call print_string
    call new_line
    ret

sysinfo_handler:
    mov si, sysinfo_msg
    call print_string
    call new_line
    ret

reboot_handler:
    mov si, reboot_msg
    call print_string
    call new_line
    mov al, 0xFE
    out 0x64, al
    ret

shutdown_handler:
    mov si, shutdown_msg
    call print_string
    call new_line
    mov ax, 0x5307
    mov bx, 0x0001
    mov cx, 0x0003
    int 0x15
    ret


echo_handler:
    mov si, input_buffer + 5
.process:
    lodsb
    test al, al
    jz .done
    
    cmp al, '%'
    jne .print
    
    call check_random
    jc .random
    
.print:
    mov ah, 0x0E
    int 0x10
    jmp .process

.random:
    call generate_random
    call print_number
    add si, 7
    jmp .process

.done:
    call new_line
    ret

goto_echo_handler:
    mov si, input_buffer + 10
.loop:
    mov ah, 0x01
    int 0x16
    jnz .exit
    
    call print_string
    call new_line
    jmp .loop
.exit:
    ret

help_handler:
    mov si, help_msg
    call print_string
    call new_line
    ret

;-----------------------------


new_line:
    mov ah, 0x0E
    mov al, 0x0D
    int 0x10
    mov al, 0x0A
    int 0x10
    ret


strcmp:
    pusha
.loop:
    mov al, [si]
    cmp al, [di]
    jne .no
    test al, al
    jz .yes
    inc si
    inc di
    jmp .loop
.yes:
    popa
    stc
    ret
.no:
    popa
    clc
    ret

atoi:
    xor ax, ax
.loop:
    lodsb
    test al, al
    jz .done
    sub al, '0'
    imul cx, 10
    add cx, ax
    jmp .loop
.done:
    mov ax, cx
    ret

check_random:
    push si
    mov si, input_buffer + 5
    cmp word [si], '%r'
    jne .no
    cmp word [si+2], 'an'
    jne .no
    cmp word [si+4], 'do'
    jne .no
    cmp byte [si+6], 'm'
    jne .no
    cmp byte [si+7], '%'
    jne .no
    pop si
    stc
    ret
.no:
    pop si
    clc
    ret

generate_random:
    mov ax, [rand_seed]
    mov dx, 0x7389
    mul dx
    add ax, 0x4AB2
    mov [rand_seed], ax
    xor dx, dx
    mov cx, 100
    div cx
    mov ax, dx
    ret

print_number:
    pusha
    mov bx, 10
    xor cx, cx
.divide:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz .divide
.print:
    pop dx
    add dl, '0'
    mov ah, 0x0E
    mov al, dl
    int 0x10
    loop .print
    popa
    ret

times 15*512 - ($-$$) db 0
