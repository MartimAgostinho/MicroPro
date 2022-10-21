; multi-segment executable file template.

data segment
    ; add your data here!
    pkey db "press any key...$"
    bemvindo_str db "Bem vindo a calculadora!",0
    introstr db "Introduza a conta:",0
    restr db "O resultado de ",0
    estr db " ]e :",0
    tes db 20 dup(?)
    conta db 20 dup(?)
    num dw 999 
    res dw  0
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
    
    mov si,offset bemvindo_str
    mov bl,4
    call printf
    
    mov si, offset introstr  
    mov bl,0
    call printf
              
    mov di,offset tes
    mov bx,20
    call scanf
    
    mov al,0dh
    call co
    mov al,0ah
    call co
    
    mov si, offset tes
    mov bl,0
    call printf 
    
    mov si,offset estr
    mov bl,0
    call printf
    
    mov si, offset tes
    mov di, offset conta
    call str_conta
    
    mov si,offset conta
    call conta_res
    
    mov si,offset conta
    mov ax,[si]
    call print_int
    
    mov al,0dh
    call co
    mov al,0ah
    call co
            
              
        
    ;lea dx, pkey
    ;mov ah, 9
    ;int 21h        ; output string at ds:dx
    
    ; wait for any key....    
    ;mov ah, 1
    ;int 21h
    
    mov ax, 4c00h ; exit to operating system.
    int 21h
    
    
        ;si = offset conta
    ;escreve no ecra a conta 
    ;dw+db+dw(...)
    print_conta proc
        
        lp1_prtct:
            mov ax,[si]
            call print_int
            add si,2
            mov al,[si]
            or al,al
            jz end_prtct
            call co        
            inc si
            jmp lp1_prtct
            
        end_prtct: ret   
                
    endp
        
    ;si = inicio conta
    ;di = fim conta
    conta_res proc
        
        push ax
        push bx
        push cx
        push dx
    
        add si,2 ;operador
        push si
                        
        mov bl,'*'
        mov bh,'/'
        
        p1_ctrs:
        
            cmp si,di
            je  end_p1ctrs      ;para se chega ao fim sem encontrar
            
            mov cl,[si]
            
            cmp cl,bl           ;pelo op em bl
            je p1_calc
            
            cmp cl,bh
            je p1_calc
            
            add si,3            ;prox op
            jmp p1_ctrs         ;volta pro inicio se em si n estiver o op em bl ou bh
            p1_calc:
                ;sub si,3       ;volta si ao op inicial
                call calc
                jmp p1_ctrs
                
        end_p1ctrs:
        
        pop si
        sub sp,2                ;evitar  fazer push si                
        
        cmp bl,'+'              ;fazer as somas depois das mul
        je end_ctrs
        
        mov bl, '+'
        mov bh, '-'
        
        jmp p1_ctrs
        
        end_ctrs:
        
        ;pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        
        ret 
        
    endp
    
    ;Si = op
    ;ve a operacao e executa a deixando o resultado em [si - 1]
    ;faz str_shift
    proc calc
       
        push cx
        push dx
        push ax
        push bx
        push di
        push si
        
        mov cl,[si]
        
        mov dx,0
        mov bx,word ptr [si + 1];num2          
        mov ax ,word ptr[si - 2];num1
        
        cmp cl , '+'
        je plu_calc
        
        cmp cl , '-'
        je min_calc
        
        cmp cl , '*'
        je mul_calc
        
        cmp cl , '/'
        je div_calc
        
        plu_calc:
            
            add ax,bx
            jmp endsw_calc
        
        min_calc:
            sub ax,bx
            jmp endsw_calc
        
        mul_calc:
            mul bx
            jmp endsw_calc
            
        div_calc:
            div bx         
        
        endsw_calc:
        
        mov [si - 2],ax         ;guarda resultado               
        
        mov cx,di               ;di = fim conta
        mov di,si
        add si,3                ;prox op
        sub cx,si               ;numero de bytes
         
        cld
        rep movsb               ;shift
        
        pop si    
        pop di
        sub di,3
        pop bx
        pop ax
        pop dx
        pop cx
        ret
    endp
    
    ;si=str 
    ;di=conta
    str_conta proc
        
        push cx
        push ax
        mov cl,0

        lp1_strct:
            
            mov ch,[si]
            
            cmp ch,'0'
            jb endif1_strct
            
            cmp ch,'9'
            ja endif1_strct
                inc si
                inc cl 
                jmp lp1_strct
                    
            endif1_strct:
            
            mov ch,0
            sub si,cx
            call str_int
            mov [di],ax
            
            add di,2        ;2 porque um numero sao 2 bits
            add si,cx       ;apontar para o prox operador
            mov ch,[si]
            or ch,ch
            jz end_strct    ;terminar se for o fim da str
            mov [di],ch     ;por o operador na str
            inc di
            inc si
            mov cl,0
            jmp lp1_strct
            
        end_strct:
        mov [di + 1], 0   ;terminar a str 
        pop ax
        pop cx
        ret
            
    endp
        
     
    ;Di = inicio str terminada em 0
    ;Ax = valor     
    cnt_str proc
            
        push cx
        push di
            
        mov al,0
        mov cx,-1
            
        cld 
        repne scasb                           
                      
        mov ax,-1          
        sub ax, cx  ; ax = -(Cx + 1) 
        
        pop di    
        pop Cx
        ret
    endp
    
    
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
    
    ;TODO REFAZER
    ;si=inicio ax = quantos char salta
    ; exemplo 1+2+3+4 onde si aponta para 2 e ax = 2
    ; fica 1+2+4
    str_shift proc
 
        push cx
        push si
        push di
        
        inc si
        mov di,si
        add di , ax
        
        lp1_strshft:
            
            mov ch,[di]
            mov [si],ch
            inc si
            inc di
            or ch,ch
        
        jnz lp1_strshft
        
        pop di
        pop si
        pop cx
        ret
        
    endp
        
    ;ax = num
    print_int proc
        
        push bx
        push cx
        push dx
        
        mov bx,10000
        mov dx,0
        
        mov cx,ax   ;ax fica guardado em cx
            
        lp_prtnt:
            cmp ax,bx
            jb le_prtnt
            div bx 

            ;mov cx,ax   ;ax fica guardado em cx
            
            add al,'0'
            call co
            sub al,'0'
            mul bx
            sub cx,ax
        
        le_prtnt:
            mov dx,0
            mov ax,bx   ;divido bx por 10 para passar pro proximo digito
            mov bx,10
            div bx
            mov bx,ax
            mov ax,cx
            or dx,dx    ; so ha resto no ultimo loop
            je lp_prtnt
            
        pop dx
        pop cx 
        pop bx
            
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

;------------STRINGS------------;
    ;bx = num de char 
    ;di = endereco da str
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

