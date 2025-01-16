section .data
    newline db 10    ; Newline character

section .bss
    argBuffer resb 1 ; Buffer to hold the character being processed

section .text
    global _start
    extern strlen  ; External declaration for strlen from util.c

_start:
    ; Get argc (number of arguments) from the stack (cdecl convention)
    mov eax, [esp + 4]   ; argc is at esp + 4
    mov ebx, [esp + 8]   ; argv is at esp + 8

    ; Initialize input/output file descriptors
    mov dword [Infile], 0  ; Default: stdin
    mov dword [Outfile], 1 ; Default: stdout

parse_args:
    ; Loop through arguments (argc and argv)
    cmp eax, 1
    jle done_parsing        ; If argc <= 1, no arguments to process

    ; Get the address of the current argument (argv[i])
    mov esi, [ebx]          ; argv[i]
    add ebx, 4              ; Advance argv
    dec eax                 ; Decrement argc

    ; Check if the argument starts with '-i'
    cmp byte [esi], '-'
    jne check_output
    cmp byte [esi + 1], 'i'
    jne check_output

    ; Open input file
    lea esi, [esi + 2]       ; Skip "-i"
    mov eax, 5               ; sys_open
    mov ebx, esi             ; File name
    xor ecx, ecx             ; Flags: read-only (0)
    xor edx, edx             ; Mode: ignored
    int 0x80
    test eax, eax
    js error                 ; If negative, it's an error
    mov [Infile], eax        ; Save input file descriptor

    jmp parse_args           ; Continue parsing arguments


check_output:
    ; Check if the argument starts with '-o'
    cmp byte [esi], '-'
    jne next_arg
    cmp byte [esi + 1], 'o'
    jne next_arg

    ; Open output file
    lea esi, [esi + 2]       ; Skip "-o"
    mov eax, 5               ; sys_open
    mov ebx, esi             ; File name
    mov ecx, 1               ; Flags: write-only
    xor edx, edx             ; Mode: ignored
    int 0x80
    test eax, eax
    js open_error                 ; If negative, it's an error
    mov [Outfile], eax       ; Save output file descriptor
    jmp parse_args           ; Continue parsing arguments   

next_arg:
    jmp parse_args           ; Process next argument

done_parsing:
    ; Process input and output

process_input_output:
    ; Read one byte from input
    mov eax, 3               ; sys_read
    mov ebx, [Infile]        ; Input file descriptor
    lea ecx, [argBuffer]     ; Buffer to store input
    mov edx, 1               ; Read one byte
    int 0x80
    test eax, eax
    jz done                  ; Exit if EOF

    ; Encode the character
    call encode

    ; Write the encoded character to output
    mov eax, 4               ; sys_write
    mov ebx, [Outfile]       ; Output file descriptor
    lea ecx, [argBuffer]     ; Buffer with encoded character
    mov edx, 1               ; Write one byte
    int 0x80
    jmp process_input_output

done:
    ; Exit the program
    mov eax, 1               ; sys_exit
    xor ebx, ebx             ; Return code 0
    int 0x80

error:
    ; Exit with error code 1
    mov eax, 1               ; sys_exit
    mov ebx, 1               ; Return code 1
    int 0x80

open_error:
; Debug: Print error message for file open failure
mov eax, 4                ; sys_write
mov ebx, 1                ; Output to stdout
lea ecx, [open_error_msg] ; Pointer to error message
mov edx, 25               ; Length of the error message
int 0x80
jmp done                  ; Exit after printing error message

section .data
open_error_msg db 'File open failed!', 10  ; Error message with newline

encode:
    mov al, byte [argBuffer]
    cmp al, 'A'
    jl not_in_range
    cmp al, 'z'
    jg not_in_range
    inc al
    mov byte [argBuffer], al
not_in_range:
    ret

section .data
Infile dd 0                ; Global variable for input file descriptor
Outfile dd 1               ; Global variable for output file descriptor

