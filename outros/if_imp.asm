; multi-segment executable file template.

data segment
    ; add your data here!
    pkey db "press any key...$"
    a db 
    b db
ends

stack segment
    dw   128  dup(0)
ends

code segment
start:
; set segment registers:
    mov ax, data
    mov ds, ax
    mov es, ax

    ; if a > b / else imp
    mov al, a
    cmp al,b
    
    ja if_true ;if (a>b) == true 
       
        ;salta o else se for !(a>b)
         
    jmp end_if ;nao executa o if true
    if_true:
        ;code
    end_if:
   
    ; wait for any key....    
    mov ah, 1
    int 21h
    
    mov ax, 4c00h ; exit to operating system.
    int 21h    
ends

end start ; set entry point and stop the assembler.
