;**********************************
;*
;* relput
;*
;*
;**********************************
;*
;*
relput	jsr sdirty      ;write data to buffer
	jsr getact
	asl a
	tax
	lda data
	sta (buftab,x)
;
	ldy buftab,x    ;inc the pointer
	iny
	bne relp05
	ldy lindx
	lda nr,y
	beq relp07
;
relp06
	ldy #2
relp05
	tya
	ldy lindx
;
	cmp nr,y        ;test if nr=pointer
	bne relp10      ;no,set new pointer
;
relp07	lda #ovrflo     ;yes,set overflow
	jmp setflg
;
relp10	;write back new pointer
	inc buftab,x
;
	bne relp20      ;test if =0
	jsr nrbuf       ;prepare nxt buffer
;
relp20	rts
;*
;*
;*
;*********************************
;*
;*  wrtrel
;*
;*
;*********************************
;*
;*
wrtrel
	lda #lrf+ovrflo ;check all flags
	jsr tstflg
	bne wr50        ;some flag is set
wr10
	lda data        ;ready to put data
	jsr relput
wr20
	lda eoiflg
	beq wr40        ;eoi was sent
	rts
wr30
	lda #ovrflo
	jsr tstflg
	beq wr40        ;no rec overflow
	lda #recovf
	sta erword      ;set error for end of print
wr40
	jsr clrec       ;clear rest of record
	jsr rd40
	lda erword
	beq wr45
	jmp cmderr
wr45
	jmp okerr
;
;
wr50
	and #lrf
	bne wr60        ;last rec, add
	lda eoiflg
	beq wr30
wr51
	rts
;
wr60
	lda data
	pha
	jsr addrel      ;add to file
	pla
	sta data
	lda #lrf
	jsr clrflg
	jmp wr10
;*
;*
;*
;********************************
;*
;*   clrec
;*
;*********************************
;
clrec	lda #ovrflo     ;put 0's into rest of record
	jsr tstflg
	bne clr10
;
	lda #0
	sta data
	jsr relput
;
	jmp clrec
;
clr10	rts
;
;
;*
;*
;*******************************
;*
;*   sdirty
;*
;*******************************
;*
;
sdirty	lda #dyfile
	jsr setflg
	jsr gaflgs
	ora #$40
	ldx lbused
	sta buf0,x
	rts
;
;*
;*
;*******************************
;*
;*   cdirty
;*
;*******************************
;*
;
cdirty	jsr gaflgs
	and #$bf
	ldx lbused
	sta buf0,x
	rts
;
;
