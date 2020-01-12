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
                mov     si,18h
                mov     di,0
outerclear:
                mov     cx,mwidth
                mov     ax,0
clearloop:      
                mov     es:[di],ax
                add     di,1

                loop    clearloop
                sub     si,1
                jnz     outerclear
            
                ;ustawianie danych
                mov     cx,msize ;wielkość pyramidy 
                mov     di,0h
                mov     si,cx
                shl     si,1
                dec     si ;2x -1
                mov     amount,si
                ;stała wyśrodkowania
                mov     ax,80
                shr     ax,1
                sub     ax,cx
                shl     ax,1
                mov     centeroff,ax

loop1:          
                mov     dx,di
                push    dx
                call    setcursor
                add     sp,2 ;przywracanie stack pointer
 
                mov     bx,amount
                mov     dx,88 ; X = 88
                sub     dx,di 
                push    bx
                push    dx
                call    print
                add     sp,4 ;regain stack pointer

                mov     ax,centeroff
                add     ax,1
                mov     centeroff,ax
                mov     ax,amount
                sub     ax,2
                mov     amount,ax
                add     di,1
                cmp     ax,1
                jge     loop1
                jmp     exit
                
                ;Ustawienie pozycji kursora
setcursor: 
                ;zdejmij wartość ze stacku
                push    bp
                mov     bp,sp
                mov     cx,[bp+4]
                mov     ax,centeroff
                
                mov     dh,cl
                mov     dl,cl
                add     dl,al

                call    movcursor
                pop     bp
                ret
movcursor:
                mov     ax,160
                mul     dh
                mov     dh,0
                add     ax,dx
                mov     cursor,ax
                ret
                ;zapisz znak
print:                
                ;zdejmij wartośc ze stacku
                push    bp
                mov     bp,sp
                mov     cx,[bp+6]
                mov     dx,[bp+4] 

                mov     al,dl ;znak
                mov     ah,7 ;atrybut znaku
                mov     bh,0 ;strona znaku
                call    printchar
                pop     bp
                ret
printchar:      
                cmp     cx,0
                jz      return
                mov     si,cursor
                mov     es:[si],ax
                add     si,2
                mov     cursor,si
                dec     cx
                jmp     printchar
return:         
                ret
exit:
      		    mov     ah,4ch
	            mov	    al,0
	            int	    21h
Progr           ends

data            segment
mwidth          dw 160
height          dw 25
msize           dw 18h
centeroff       dw 0
cursor          dw 0
amount          dw 0
data            ends

m_stack         segment STACK
                dw    100h dup(0)
top             Label word
m_stack         ends

end start



