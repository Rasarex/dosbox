TEXT segment 
    assume  cs:TEXT, ds:DATA, ss:LOCAL_STACK
start:          mov     ax,DATA
                mov     ds,ax
                mov     ax,LOCAL_STACK
                mov     ss,ax
                mov     sp,offset top
                ;Czysczenie ekranu
                mov     ax,0600h
                mov     bh,7
                mov     cx,0 
                mov     dx,1847h
                int     10h
                ;set cursor at begining
                xor     dx,dx
                mov     ah,02h
                int     10h
                ;save bp
                xor     cx,cx
                push    bp
readloop:
                mov     bp, input_data
                add     bp,cx
                mov     ah,0
                int     16h
                mov     [bp],ax
                add     cx,1
                cmp     al,0Dh
                je      exitloop
                cmp     cx,4
                jnl     exitloop
                call    advance_cursor
                jmp     readloop
exitloop:
toint:
                xor     cx,cx
                xor     dx,dx
                mov     bp, input_data
                cmp     [bp],2Dh
                jnz     tiloop 
setnegative:    mov     ax,1 
                push    ax
                add     bp,1
                
tiloop:         
                cmp     [bp],0Dh
                jz      exittiloop
                cmp     [bp],0
                jnl     exit
                cmp     [bp],10
                jge     exit
                mov     ax,[bp]
                sub     ax,30h
                add     dx,ax
                jmp     tiloop
exittiloop: 
                mov     int_data,ax
                pop     bp
advance_cursor:
                mov     ah,03h
                int     10h
                add     dx,1
                mov     ah,02h
                int     10h
                xor     cx,cx
                ret
exit:
      		    mov     ah,4ch
	            mov	    al,0
	            int	    21h

TEXT ends

DATA segment
input_data      dw 10 dup(0)
int_data        dw 1  dup(0)
DATA ends

LOCAL_STACK     segment STACK
                dw 100h dup(0)
top             Label word
LOCAL_STACK     ends

end start