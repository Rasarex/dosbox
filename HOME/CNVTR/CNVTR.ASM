TEXT segment 
    assume  cs:TEXT, ds:DATA, ss:LOCAL_STACK
start:          mov     ax,DATA
                mov     ds,ax
                mov     ax,LOCAL_STACK
                mov     ss,ax
                mov     sp,offset top
                ;Czysczenie ekranu
                mov ax,0600h
                mov bh,7
                mov cx,0 
                mov dx,1847h
                int 10h
                xor cx,cx
                ;save bp
                push bp
readloop:
                mov bp, input_data
                add bp,cx
                mov ah,0
                int 16h
                mov [bp],ax
                add cx,1
                
exitloop:
                pop bp

exit:
      		    mov     ah,4ch
	            mov	    al,0
	            int	    21h

TEXT ends

DATA segment
input_data      dw 10 dup(0)

DATA ends

LOCAL_STACK     segment STACK
                dw 100h dup(0)
top             Label word
LOCAL_STACK     ends

end start