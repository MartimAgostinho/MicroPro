; multi-segment executable file template.

data segment
    ; add your data here!
    pkey db "press any key...$"
    res dw ? 
    num1 dw 79
    num2 dw -3
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
    
    call dvs            
    
    
    lea dx, pkey
    mov ah, 9
    int 21h        ; output string at ds:dx
    
    ; wait for any key....    
    mov ah, 1
    int 21h
    
    mov ax, 4c00h ; exit to operating system.
    int 21h
    
    dvs proc ;resultado guardado em res e resto no Ax TODO fazer de res uma var local
             ;so funciona para numeros positivos
             
        mov cl,15
        mov res,0
        
        div_BgLoop1:
        mov dx,bx
        shl dx,cl
        cmp dx,ax
        ja  end_if1
            
            sub ax,dx
            mov dx,1
            shl dx,cl
            add res,dx
         
        end_if1:
        dec cl
        jns div_BgLoop1
        div_EndLoop1:
        ret
        
    endp
        
ends

end start ; set entry point and stop the assembler.
