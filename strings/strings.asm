; multi-segment executable file template.

data segment
    ; add your data here!
    pkey db "press any key...$"
    str db "e isto [e um teste!e" ,0
    str2 db 15 dup(?)
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
    
    mov bl,'e'
    mov bh,'P'
    mov di,offset str
    call swtch_char
    mov si,offset str
    mov bl,0
    call printf
    
            
    lea dx, pkey
    mov ah, 9
    int 21h        ; output string at ds:dx
    
    ; wait for any key....    
    mov ah, 1
    int 21h
    
    mov ax, 4c00h ; exit to operating system.
    int 21h
    
    ;Si = inicio do numero na str
    ;Cl = num de char =< 5
    ;Ax = resultado
    str_int proc
        
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
         
    ;Di = inicio str destino
    ;Ax = num
    ;bl = 0,para terminar str com 0
    int_str proc
                 
        push cx
        push dx
         
        mov cx,10
        
        lp1_intstr:
            
            mov dx,0        ;dx tem de ser 0
            div cx
            add dl,'0'      ;dl tem o char menos significativo
            mov [di], dl    ;adiciona a string      
                        
            inc di          ;prox posicao
            or ax,ax
            jnz lp1_intstr 
        
        or bl,bl
        jnz end_intstr
            mov [di],0;terminar a string    
        end_intstr:
        
        pop dx
        pop cx
        ret
        
    endp
 
    ;Di = inicio str terminada em 0
    ;Ax = valor     
    cnt_str proc
            
        push cx
            
        mov al,0
        mov cx,-1
            
        cld 
        repne scasb                           
                      
        mov ax,-1          
        sub ax, cx  ; ax = -(Cx + 1) 
            
        pop Cx
        ret
    endp
    
    
    ;si= offset str;bl=char
    del_char proc;si= offset str;bl=char
        
        push dx ;dl, guarda o char
        push di ;ptr antes  ' '
        push bx ;ptr depois ' ' 
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
        pop bx
        pop di
        pop bx
        ret
    endp
    
    ;Di = offset str
    ;bl = char para mudar
    ;bh = char novo
    swtch_char proc
        
        push cx
        push ax
        
        push di
        call cnt_str
        pop di
        
        mov cx,ax
        mov al,bl
        add di,cx
        
        lp1_swchar:
            
            inc cx          ;repne decrementa uma vez a mais       
            std
            repne scasb     ;procura o char 
 
            jnz end_swchar   ;acaba se tiver percorrido a str toda
            inc di
            
            mov [di],bh     ;substitui 
            jmp lp1_swchar
            
        end_swchar:   
        
        pop ax
        pop cx
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

;*****************************************************************
; co - caracter output
; descricao: rotina que faz o output de um caracter para o ecra
; input - al=caracter a escrever
; output - nenhum
; destroi - nada
;*****************************************************************
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
ends


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
        
ends

end start ; set entry point and stop the assembler.
