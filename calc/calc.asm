; multi-segment executable file template.

data segment
    ; add your data here!
    pkey db "press any key...$"
    input db 20 dup(?)
    conta db 30 dup(?)
    num dd 5 dup(?)
    res dw ?
    
    tes db "1+59+10-1",0
    
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
    
    mov si, offset tes
    call str_calc
            
    lea dx, pkey
    mov ah, 9
    int 21h        ; output string at ds:dx
    
    ; wait for any key....    
    mov ah, 1
    int 21h
    
    mov ax, 4c00h ; exit to operating system.
    int 21h

    del_char proc;si= offset str;bl=char
        
        push dx ;dl, guarda o char
        push di ;ptr antes  ' '
        push bx ;ptr depois ' ' 
        push si
        mov di,si
        
        lp1_del_char:
            
            mov dl,byte ptr [si];guardar o char
            or dl,dl
            jz end_dlch         ;procurar fim da str
            
            cmp dl,bl
            jne endif_dlch      ;procurar o char em bl
                inc si
                jmp lp1_del_char    
            
            endif_dlch:
            
            mov [di],dl         ;da shift a str
            
            inc di
            inc si
            jmp lp1_del_char
    
        end_dlch:
        
        mov [di],0
        pop si
        pop bx
        pop di
        pop dx
        ret
    endp            
    
    ;recebe uma str sem espacos ,
    ;so com um operador entre numeros 
    ;e so numeros < 10000
    ;Si=offset str
    ;Dx=resultado
    str_calc proc    
        
        push cx
        push bx
       ; push dx
        
        mov dx,0
        mov cx,0
        mov bl,0
        
        lp1_strcl:
 
            mov bh,[si]
            
            cmp bh,'0'
            jb lp2_strcl  ;verifica se o num n esta entre 0 e 9
            cmp bh,'9'
            ja lp2_strcl
            
            inc si
            inc cl
            jmp lp1_strcl
            
        lp2_strcl:
            
            sub si,cx
            call str_int
            
            or bl,bl
            jz add_strcl ;se for o primeiro numero
            
            cmp bl,'+'
            je add_strcl
            
            cmp bl,'-'
            je sub_strcl
            
            
            add_strcl:
                add dx,ax
                jmp endswtc_strcl
            
            sub_strcl:
                sub dx,ax
            
            endswtc_strcl:
            
                mov bl,bh
                add si,cx
                inc si
                mov cx,0
                or bh,bh
                jnz lp1_strcl
                
        ;pop dx
        pop bx
        pop cx
        ret        
        
    endp

    
    str_int proc; si = offset str,cl=numero char da str,Ax = resultado 
        
        push dx ;inicializar as variaveis
        push cx
        push si
        mov ax,0
        mov dh,0
        mov ch,10
        
        str_intLp:
            
            mov dl,byte ptr [si];char 
            or dl,dl
            jz str_int_end      ;para no fim da string
            or cl,cl
            jz str_int_end
            sub dl,'0'          ;passar para inteiro
            
            mul ch              ;multiplicar o resultado por 10
            add ax,dx           ;adicionar o numero novo
            dec cl              ;contar ciclos
            inc si
            jmp str_intLp
            
        str_int_end:
        
        pop si
        pop cx
        pop dx
        ret   
    endp
    
printf proc
    
    or bl,bl
    jz print_0
    
    cmp bl,1
    je print_min
    
    cmp bl,2
    je print_max
    
    cmp bl,4
    je print_enter
    
    print_max:
        mov bl,'a'
        mov bh,'z'
        mov cl, 'A'-'a'
        call printf_min_max
        ret
    
    print_min:
        mov bl,'A'
        mov bh,'Z'
        mov cl,'a'-'A'
        call printf_min_max
        ret
    
    print_0:
        call printf_norm
        ret
    
    print_enter:
        call printf_norm
        mov al,0dh
        call co
        mov al,0ah
        call co
        ret
    
printf endp

printf_norm proc
    
    L1: mov al,byte ptr [si]
        or al,al
        jz fimprtstr
        call co
        inc si
        jmp L1
    fimprtstr: ret
    
endp

printf_min_max proc
    
        push si
        
        printf_bgl1: mov al,byte ptr [si]
            
            or al,al
            jz printf_Endl1
            
            cmp al,bh
            ja printf_if1;'Z'
            
            cmp al,bl
            jb printf_if1 ;'A'
                       
                add al,cl;normaliza se o char estiver entre 'A' e 'Z'
                       
            printf_if1:
            
            call co    
            inc si
            jmp printf_bgl1
        
        printf_Endl1:
        
        pop si
        ret
    endp

    co proc
        push ax
        push dx
        mov ah,02H
        mov dl,al
        int 21H
        pop dx
        pop ax
        ret
    co endp

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
