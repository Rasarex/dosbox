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
                mov     bh,0h
                mov     ah,02h
                int     10h
                ;save bp
                xor     cx,cx
                mov     ax,0Dh
                push    ax
readloop:
                mov     ah,0
                int     16h
                push    ax
                cmp     al,0Dh
                je      exitloop
                cmp     cx,4
                jnl     exitloop
                call    printchar
                mov     si,1
                call    advance_cursor
                inc     bp
                jmp     readloop
exitloop:
                call    newline
                mov     si,1
                xor     di,di
                pop     ax ;delete \r
tiloop:
                pop     ax
                xor     ah,ah
                cmp     al,2Dh
                jne     notneg
                mov     dx,di
                not     dl
                add     dl,1
                mov     di,dx
                jmp     exittiloop
notneg:         cmp     al,0Dh
                je      exittiloop
                cmp     al,48
                jge     tinext
                jmp     exit
tinext:         cmp     al,58
                jl      tiinext
                jmp     exit
tiinext:        sub     al,30h   
                mul     si
                add     di,ax
                mov     ax,10
                mul     si
                mov     si,ax
                jmp     tiloop
exittiloop: 
                mov     int_data,di
                call    smr
                call    onecompl
                call    twocompl
                call    hex
                jmp     exit
hex:
                mov     si,1
                call    advance_cursor
                mov     bx,int_data
                shr     bx,4
                and     bx,15
                mov     al,hextable[bx]
                call    printchar
                call    advance_cursor
                mov     bx,int_data
                and     bx,15
                mov     al,hextable[bx]
                call    printchar
                call    newline
                ret

twocompl:
                mov     ax,int_data
                xor     cx,cx
                call    printbits
                call    newline
                ret
onecompl:
                mov     dx,int_data
                xor     cx,cx
                mov     al,dl
                shr     al,7
                jz      ocomplepos
                add     dl,1
ocomplepos:     
                mov     al,dl
                call    printbits
                call    newline
                ret
smr:            
                mov     dx,int_data
                mov     ax,int_data
                xor     ah,ah
                shr     al,7
                jz      smrnoneg
                not     dl
                inc     dl
                or      dl,128
smrnoneg:       
                mov     ax,dx
                mov     cx,0
                call    printbits
                call    newline
                ret
printbits:      
                mov     si,8
                call    advance_cursor
                xor     cx,cx
printloop:
                push    ax
                push    cx

                and     ax,1
                add     ax,30h
                call    printchar
                call    back_cursor

                pop     cx
                pop     ax

                shr     ax,1
                inc     cx
                cmp     cx,8
                jl      printloop
                ret
newline:
                mov     ah,03h
                int     10h
                add     dh,1
                xor     dl,dl
                mov     ah,02h
                int     10h
                ret
advance_cursor:
                mov     ah,03h
                int     10h
                add     dx,si
                mov     ah,02h
                int     10h
                xor     cx,cx
                ret
back_cursor:
                mov     ah,03h
                int     10h
                sub     dx,1
                mov     ah,02h
                int     10h
                xor     cx,cx
                ret
printchar:
                mov     cx,1
                mov     ah,09h
                mov     bl,07
                mov     bh,0
                int     10h
                ret
exit:
      		    mov     ah,4ch
	            mov	    al,0
	            int	    21h


TEXT ends

DATA segment
input_data      dw 10 dup(0)
int_data        dw 1  dup(0)
zm_data         dw 1 dup(0)
hextable        db '0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'
DATA ends

LOCAL_STACK     segment STACK
                dw 100h dup(0)
top             Label word
LOCAL_STACK     ends

end start