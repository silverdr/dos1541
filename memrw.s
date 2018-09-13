; memory access commands
;  "-" must be 2nd char
mem	lda cmdbuf+1
	cmp #'-
	bne memerr
;
	lda cmdbuf+3    ;set address in temp
	sta temp
	lda cmdbuf+4
	sta temp+1
;
	ldy #0
	lda cmdbuf+2
	cmp #'r
	beq memrd       ;read
	jsr killp       ;kill protect
	cmp #'w
	beq memwrt      ;write
	cmp #'e
	bne memerr      ;error
; execute
memex	jmp (temp)
memrd
	lda (temp),y
	sta data
	lda cmdsiz
	cmp #6
	bcc m30
;
	ldx cmdbuf+5
	dex
	beq m30
	txa
	clc
	adc temp
	inc temp
	sta lstchr+errchn
	lda temp
	sta cb+2
	lda temp+1
	sta cb+3
	jmp ge20
m30
	jsr fndrch
	jmp ge15
memerr	lda #badcmd     ;bad command
	jmp cmderr
memwrt	;write
m10	lda cmdbuf+6,y
	sta (temp),y    ;transfer from cmdbuf
	iny
	cpy cmdbuf+5    ;# of bytes to write
	bcc m10
	rts
