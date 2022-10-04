; multi-segment executable file template.

data segment
    ; add your data here!
    pkey db "press any key...$"
    num1 dw -1
    num2 dw 5
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

    ; add your code here
              
    mov ax,num1
    mov bx,num2
    
    call mlt 
    
    mov num1, dx
    
              
    lea dx, pkey
    mov ah, 9
    int 21h        ; output string at ds:dx
    
    ; wait for any key....    
    mov ah, 1
    int 21h
    
    mov ax, 4c00h ; exit to operating system.
    int 21h
    
    mlt proc ;multiplica Ax e Bx resultado em Dx, Cl usado
        
        ;para que Ax > Bx
        
        cmp ax,bx 
        
        ja mlt_if1
        
        mov dx,ax   ;trocar os valores em bx com ax 
        mov ax,bx
        mov bx,dx
                
        mlt_if1:
        
        mov dx,0 
        mov cl,0
        
        mlt_BgLp1:
            
            mov ch,bl
            and ch,1
            jz mlt_If2;faz o shift se o numero for impar         
            
            shl ax,cl ;bit shift
            add dx,ax        
            
            mlt_If2:
            
            inc cl
            shr bx,1
        
        add bx,0;ativa as flags para o numero em bx
        jnz mlt_BgLp1          
            
        ret
    endp
    
        
ends

end start ; set entry point and stop the assembler.
