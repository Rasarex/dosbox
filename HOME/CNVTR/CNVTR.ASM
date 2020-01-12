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
                push    bp
                mov     bp, input_data
readloop:
                mov     ah,0
                int     16h
                xor     ah,ah
                mov     [bp],ax
                inc     bp
                cmp     al,0Dh
                je      exitloop
                cmp     cx,4
                jnl     exitloop
                call    printchar
                call    advance_cursor
                jmp     readloop
exitloop:
                call    newline
toint:
                mov     bp, input_data

                cmp     [bp],2Dh
                jne     tiloop
                call    printchar
setnegative:    
                mov     si,1 
                inc     bp
                
                xor     dx,dx
tiloop:         
                cmp     [bp],0Dh
                je      exittiloop
                mov     ax,[bp]
                call    printchar
                sub     ax,30h
                jl      exit 
                cmp     [bp],0
                jnl     exit
                cmp     [bp],10
                jge     exit
                mov     ax,[bp]
                add     dx,ax
                inc     bp
                jmp     tiloop
exittiloop: 
                mov     int_data,dx
                pop     bp
smr:
                push    bp
                mov     bp,sp
                sub     bp,10 ; allocate 5 dwords on stack
                mov     ax, int_data
                xor     ah,ah
                and     ax,80h
                mov     [bp],ax

                mov     cx,2
                mov     dx,64 ;mask
smrloop:        
                mov     bx,int_data
                add     bp,2
                and     bx,dx
                mov     [bp],bx
                div     cx
                mov     al,bl
                call    printchar
                call    advance_cursor
                cmp     dx,0
                jne     smrloop
                add     bp,2
                mov     [bp],0
                pop     bp
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
                add     dx,1
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
DATA ends

LOCAL_STACK     segment STACK
                dw 100h dup(0)
top             Label word
LOCAL_STACK     ends

end start