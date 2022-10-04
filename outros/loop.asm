; multi-segment executable file template.

data segment
    ; add your data here!
    pkey db "press any key...$"
    a dw  7
    b dw  3
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

    ; loop com varias condicoes
    
    mov ax, a
    mov bx, b
    call mult
    mov a,ax
    
    ; wait for any key....    
    mov ah, 1
    int 21h
    
    mov ax, 4c00h ; exit to operating system.
    int 21h 
    
    mult proc
         mov cx,0
         mov dx, ax 
         
         cmp ax,bx
         
         jae bg_loop
         
         mov dx, ax 
         mov ax,bx
         mov ax,dx       
                 
        bg_loop: 
            
            add ax,dx
            inc cx
                 
        cmp bx,cx
        je end_loop
        jmp bg_loop
       
    end_loop:
    ret    
        
    endp   
ends

end start ; set entry point and stop the assembler.
