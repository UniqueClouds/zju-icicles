DATA_SEG	SEGMENT
OLD_KEY	DB	0H
TABLE	DW	524,588,660,698,784,880,988
DATA_SEG	ENDS
STACK_SEG	SEGMENT		STACK
STA	DB	100 DUP(?)
TOP	EQU	LENGTH STA
STACK_SEG	ENDS
CODE_SEG	SEGMENT
	assume	cs:CODE_SEG,ds:DATA_SEG
	assume	ss:STACK_SEG
main	proc	far
	mov	ax,DATA_SEG
	mov	ds,ax
	mov	es,ax
	mov	ax,STACK_SEG
	mov	ss,ax
	mov	ax,top
	mov	sp,ax

	mov al,0b6h	;b6h＝10110110b
	out 43h,al	;写入控制字

start:	mov	ah,01
	int	16h
	jz	off
	
	mov	ah,0
	int	16h
	cmp	al,38h
	jz	finish

	MOV	AH, OLD_KEY
	CMP	AL, AH
	JZ	START

	MOV	OLD_KEY, AL
	sub	al,31h
	shl	al,01
	mov	bl,al
	mov	bh,00
	mov	ax,3234h
	mov	dx,12h
	div	word ptr [TABLE+bx]
	
	call	speakon			;打开扬声器声音
	call	speaker			;设置扬声器音调
	jmp	start			;

off:	MOV	OLD_KEY, 0H
	call	speakoff		;关闭扬声器声音

	jmp	start

finish:	mov	ah,4ch
	int	21h
main	endp

speaker	proc
	push ax
	out 42h,al	;写入低8位计数值
	mov al,ah
	out 42h,al	;写入高8位计数值
	pop ax
	ret
speaker	endp

speakon	proc
	push ax
	in al,61h	;PB端口的地址为61H
	mov ah, al
	or al,03h	;D1D0＝PB1PB0＝11B，其他位不变
	cmp ah, al
	jz rr
	out 61h,al
rr:	pop ax
	ret
speakon	endp

speakoff	proc
	push ax
	in al,61h	;PB端口的地址为61H
	mov ah, al
	and al,0fch	;D1D0＝PB1PB0＝00B，其他位不变
	cmp al,ah
	jz r
	out 61h,al
r:	pop ax
	ret
speakoff	endp

CODE_SEG	ENDS
	end	main
