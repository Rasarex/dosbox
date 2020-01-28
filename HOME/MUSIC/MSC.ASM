TEXT segment
    assume  cs:TEXT,ds:DATA, ss:LOCAL_STACK


start:          mov     ax,DATA
                mov     ds,ax
                mov     ax,LOCAL_STACK
                mov     ss,ax
                mov     sp,offset top
                mov     ah,62h
                int     21h
                mov     es,bx  
                ;Czysczenie ekranu
                mov     ax,0600h
                mov     bh,7
                mov     cx,0
                mov     dx,184Ch
                int     10h
                ;set cursor at begining
                xor     dx,dx
                mov     bh,0h
                mov     ah,02h
                int     10h
readenv:    
                mov     bx,0
                mov     al,es:[0]
                cmp     al,0
                jne     loopenv
                mov     ax,25h
                call    printchar
                jmp     exit
loopenv:        
                mov     al,[es]:[bx + 130]
                cmp     al,0Dh
                je      openfile
                cmp     al,00h
                je      openfile
                mov     filepath[bx],al
                call    printchar
                mov     si,1
                call    advance_cursor
                inc     bx
                jmp     loopenv
openfile:
                mov     filepath[bx],0h
                mov     ah,3Dh
                mov     al,0 ; readonly
                mov     dl,OFFSET filepath
                int     21h
                jb      endopen
                mov     filehandle,ax
                jmp     play
endopen:            
                mov     ax,23h
                call    printchar
                jmp     exit 
play:   
                mov     ax,21h
                call    printchar
                call    newline
                mov     al,182
                out     43,al
playloop:       
                mov     ah,3Fh
                mov     bx,filehandle
                mov     cx,2 
                mov     dx,OFFSET note
                int     21h
                jb      endplay ;check carry flag
                cmp     ax,65535
                je      endplay
                mov     ah,3Fh
                mov     bx,filehandle
                mov     cx,2
                mov     dx,OFFSET duration
                int     21h
                jb      endplay ;check carry flag
                mov     ax,note
                cmp     ax,65535
                je      endplay
                mov     bx,duration
                cmp     ax,0
                jne     noteplay
                call    pause1
                jmp     playloop
noteplay:       call    playnote
                jmp     playloop 
endplay:
                jmp     exit

newline:
                mov     ah,03h
                int     10h
                add     dh,1
                xor     dl,dl
                mov     ah,02h
                int     10h
                ret
advance_cursor:
                push    dx
                push    cx
                mov     ah,03h
                int     10h
                add     dx,si
                mov     ah,02h
                int     10h
                pop     cx
                pop     dx
                ret
back_cursor:
                push    dx
                mov     ah,03h
                int     10h
                sub     dx,1
                mov     ah,02h
                int     10h
                pop     dx
                ret
printchar:
                push    cx
                push    bx
                mov     cx,1
                mov     ah,09h
                mov     bl,07
                mov     bh,0
                int     10h
                pop     bx
                pop     cx
                ret
playnote:       ;ax for note , bx duration
                out     42h,al
                mov     al,ah
                out     42h,al
                in      al,61h
                or      al,00000011b
                out     61h,al
pause1:
                mov     cx,65535
pause2:         
                dec     cx
                jne     pause2
                dec     bx
                jne     pause1
                in      al,61h
                and     al,11111100b
                out     61h,al
                ret
exit:
      		    mov     ah,4ch
	            mov	    al,0
	            int	    21h

TEXT ends


DATA segment 
filepath    db  30h dup(0)
filehandle  dw  0
note        dw  0
duration    dw  0
DATA ends

LOCAL_STACK segment stack
            dw 100h dup(0)
top         Label word

LOCAL_STACK ends
end start