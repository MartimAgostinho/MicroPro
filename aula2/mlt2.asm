; multi-segment executable file template.

data segment
    ; add your data here!
    pkey db "press any key...$"
    numa dw 9
    numb dw 8
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
                    
                    
    mov ax, numa
    mov bx, numb
    
    call mlt
    mov numa,ax     
    
    ; add your code here
            
    lea dx, pkey
    mov ah, 9
    int 21h        ; output string at ds:dx
    
    ; wait for any key....    
    mov ah, 1
    int 21h
    
    mov ax, 4c00h ; exit to operating system.
    int 21h  
    
    mlt proc
           
        add bx,0
        jz zero
           ;enquanto primeiro bit != 1
        mov dx,bx
        ;mov cx,0
        
        ;cmp bx,0
        bg1_loop:;bitshift fuckery
            
            and dx,1
            jnz end1_loop
            
            shr bx,1
            shl ax,1
            
            mov dx,bx       
                   
        jmp bg1_loop ;tinha a mesma label
        end1_loop:
        
        mov dx, ax 
         
        cmp ax,bx
        
        jae if1
         
        mov dx, ax 
        mov ax,bx
        mov ax,dx       
              
        if1:
        cmp bx,1
        je end2_loop       
        
        bg2_loop: 
            
            add ax,dx
            dec bx
                 
        cmp bx,1
        jle end2_loop
        jmp bg2_loop
        end2_loop:
        
        ret
        zero:
        mov ax,0
        ret
        
    endp 
             
ends

end start ; set entry point and stop the assembler.
