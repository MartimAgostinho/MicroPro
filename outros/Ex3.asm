; multi-segment executable file template.

data segment
    ; add your data here! 
    pkey db "press any key...$"  
    res db ? 
    array db 20 dup(0,2,3,4,5,6,7,8,9,19,11,12,13,14,15)
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
    
    mov cl, 20
    mov si, offSet array
    mov al, BYTE PTR[si] 
                                                     
    for:               
        inc si
        
        mov bl, BYTE PTR[si]
        cmp al,bl
        
        ja a_grt
          
            mov al,bl
             
        a_grt:
        
    dec cl
    cmp cl,0
    jne for 
    
    
    mov res, al
    
    ; wait for any key....    
    mov ah, 1
    int 21h
    
    mov ax, 4c00h ; exit to operating system.
    int 21h    
ends      

end start ; set entry point and stop the assembler.
