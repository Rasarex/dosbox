Progr           segment
                assume  cs:Progr, ds:data, ss:m_stack

start:          mov     ax,data
                mov     ds,ax
                mov     ax,m_stack
                mov     ss,ax
                mov     sp,offset top
                mov     ax,0b800h
                mov     es,ax
                ;Czyszcenie ekranu
                mov     ax,0600h
                mov     bh,7
                mov     cx,0
                mov     dx,1847h
                int     10h
                ;ustawianie danych
                mov     cx,10h ;wielkość pyramidy 
                mov     di,0h
                mov     si,cx
                rcl     si,1
                dec     si ;2x -1
                ;stała wyśrodkowania
                mov     ax,80
                rcr     ax,1
                sub     ax,cx
                push    ax

loop1:          
                mov     dx,di
                push    dx
                call    setcursor
                add     sp,2 ;przywracanie stack pointer

                mov     bx,si
                mov     dx,88 ; X = 88
                sub     dx,di 
                push    bx
                push    dx
                call    print
                add     sp,4 ;regain stack pointer

                sub     si,2
                add     di,1
                cmp     si,1
                jge     loop1
                jmp     exit
                
                ;Ustawienie pozycji kursora
setcursor: 
                ;zdejmij wartość ze stacku
                push    bp
                mov     bp,sp
                mov     cx,[bp+4]
                mov     ax,[bp+6]

                mov     dh,dl
                mov     dl,cl
                add     dl,al

                mov     ah,02h
                mov     bh,0
                int     10h
                pop     bp
                ret
                ;zapisz znak
print:                
                ;zdejmij wartośc ze stacku
                push    bp
                mov     bp,sp
                mov     cx,[bp+6]
                mov     dx,[bp+4] 

                mov     ah,09h
                mov     al,dl ;znak
                mov     bl,7 ;atrybut znaku
                mov     bh,0 ;strona znaku
                int     10h
                pop     bp
                ret    
exit:
      		    mov     ah,4ch
	            mov	    al,0
	            int	    21h
Progr           ends

data            segment

data            ends

m_stack          segment STACK
                dw    100h dup(0)
top          Label word
m_stack          ends

end start
.word  width dw 160
.word  height dw 25
