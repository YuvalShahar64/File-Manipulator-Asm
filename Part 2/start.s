section .text
global infection
global infector
global code_start
global _start
global system_call

extern main
_start:
    pop    dword ecx    ; ecx = argc
    mov    esi,esp      ; esi = argv
    ;; lea eax, [esi+4*ecx+4] ; eax = envp = (4*ecx)+esi+4
    mov     eax,ecx     ; put the number of arguments into eax
    shl     eax,2       ; compute the size of argv in bytes
    add     eax,esi     ; add the size to the address of argv 
    add     eax,4       ; skip NULL at the end of argv
    push    dword eax   ; char *envp[]
    push    dword esi   ; char* argv[]
    push    dword ecx   ; int argc

    call    main        ; int main( int argc, char *argv[], char *envp[] )

    mov     ebx,eax
    mov     eax,1
    int     0x80
    nop
    
; infection function
infection:
    ; Print "Hello, Infected File" to stdout using syscall write
    mov eax, 4                ; syscall number for write
    mov ebx, 1                ; file descriptor 1 (stdout)
    lea ecx, [infect_message] ; load address of the infection message
    mov edx, infect_message_len ; length of the message
    int 0x80                  ; make the syscall
    ret

; infector function
infector:
    ; Argument: char *filename (file name in [esp + 4])
    
    ; Open the file (O_WRONLY | O_APPEND)
    mov eax, 5                ; syscall number for open
    mov ebx, [esp + 4]        ; filename (argument)
    mov ecx, 0101h            ; flags (O_WRONLY | O_APPEND)
    mov edx, 0                ; mode (not needed here)
    int 0x80                  ; make the syscall (open)
    mov ebx, eax              ; save file descriptor in ebx

    ; Write the infection message to the file (write)
    mov eax, 4                ; syscall number for write
    lea ecx, [infect_message] ; load address of the infection message
    mov edx, infect_message_len ; length of the message
    int 0x80                  ; make the syscall (write)
    
    ; Close the file (close)
    mov eax, 6                ; syscall number for close
    int 0x80                  ; make the syscall (close)

    ret

system_call:
    push    ebp             ; Save caller state
    mov     ebp, esp
    sub     esp, 4          ; Leave space for local var on stack
    pushad                  ; Save some more caller state

    mov     eax, [ebp+8]    ; Copy function args to registers: leftmost...        
    mov     ebx, [ebp+12]   ; Next argument...
    mov     ecx, [ebp+16]   ; Next argument...
    mov     edx, [ebp+20]   ; Next argument...
    int     0x80            ; Transfer control to operating system
    mov     [ebp-4], eax    ; Save returned value...
    popad                   ; Restore caller state (registers)
    mov     eax, [ebp-4]    ; place returned value where caller can see it
    add     esp, 4          ; Restore caller state
    pop     ebp             ; Restore caller state
    ret                     ; Back to caller

section .data
infect_message db "Hello, Infected File", 10  ; Message to print (includes newline)
infect_message_len equ $ - infect_message    ; Calculate the length of the message