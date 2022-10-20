; multi-segment executable file template.

data segment
    ; add your data here!
    pkey db "$"
    strg db 15 dup(?)
    str2 db "PIXA aaAA",0dH,0aH,0
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
            
    lea dx, pkey
    mov ah, 9
    int 21h        ; output string at ds:dx
    
    ; wait for any key....    
    mov ah, 1
    int 21h
    
    mov ax, 4c00h ; exit to operating system.
    int 21h             
    
    scanf proc
                 ;guardar valor anterior
        push bx
        mov bx,ax
        dec bx    ;reservo o ultimo char para terminar a str
        add bx,di
        scanf_Bgwhile1:
            
            
            mov ah,1
            int 21h  ;ler 1 char
          
            cmp al,0dh      ;para parar no enter
            je scanf_Endwhile1
            
            cmp al,08h          ;backspace
            jne endif_scanf 
                        
                dec di
                jmp scanf_Bgwhile1
            
            endif_scanf:
  
            mov [di], al    ;adiciona o char na memoria
                    
            inc di  
            cmp di,bx
            jb scanf_Bgwhile1 
        scanf_Endwhile1:
        
        mov  [di],0        
          
        pop Bx
        ret
    endp
      
ends

end start ; set entry point and stop the assembler.
