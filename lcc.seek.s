;
;
;
seak	ldx #90         ; search 90 headers
	stx tmp
;
	ldx #0          ;read in 8 gcr bytes
;
	lda #$52        ; header block id
	sta stab
;
seek10	jsr sync        ; find sync char
;
	bvc *           ; wait for block id
	clv
;
	lda data2
	cmp stab        ; test if header block
	bne seek20      ; not header
;
seek15	bvc *
	clv             ; read in gcr header
;
	lda data2
	sta stab+1,x
;
	inx
	cpx #7
	bne seek15
;
	jsr cnvbin      ; convert header in stab to binary in header
;
	ldy #4          ; compute checksum
	lda #0
;
seek30	eor header,y
	dey
	bpl seek30
;
	cmp #0          ; test if ok
	bne cserr       ; nope, checksum error in header
;
	ldx cdrive      ; update drive track#
	lda header+2
	sta drvtrk,x
;
	lda job         ; test if a seek job
	cmp #$30
	beq eseek
;
	lda cdrive
	asl a           ; test if correct id
	tay
	lda dskid,y
	cmp header
	bne badid
	lda dskid+1,y
	cmp header+1
	bne badid
;
	jmp wsect       ; find best sector to service
;
;
seek20	dec tmp         ; search more?
	bne seek10      ;yes
;
	lda #2          ; cant find a sector
	jsr errr
;
;
eseek	lda header      ;harris fix....
	sta dskid       ;....
	lda header+1    ;....
	sta dskid+1     ;....
;
done	lda #1          ; return ok code
	.byte skip2
;
badid	lda #11         ; disk id mismatch
	.byte skip2
;
cserr	lda #9          ; checksum error in header
	jmp errr
;
;
;
wsect	lda #$7f        ; find best job
	sta csect
;
	lda header+3    ; get upcoming sector #
	clc
	adc #2
	cmp sectr
	bcc l460
;
	sbc sectr       ;wrap around
;
l460	sta nexts       ; next sector
;
	ldx #numjob-1
	stx jobn
;
	ldx #$ff
;
l480	jsr setjb
	bpl l470
;
	sta work
	and #1
	cmp cdrive      ; test if same drive
	bne l470        ; nope
;
	ldy #0          ; test if same track
	lda (hdrpnt),y
	cmp tracc
	bne l470
;
	lda job         ; test if execute job
	cmp #execd
	beq l465
;
	ldy #1
	sec
	lda (hdrpnt),y
	sbc nexts
	bpl l465
;
	clc
	adc sectr
;
l465	cmp csect
	bcs l470
;
	pha             ; save it
	lda job
	beq tstrdj      ; must be a read
;
	pla
	cmp #wrtmin     ; [if(csect<9)return;
	bcc l470        ; [if(csect>12)return;
;
	cmp #wrtmax
	bcs l470
;
doitt	sta csect       ;its better
	lda jobn
	tax
	adc #>bufs
	sta bufpnt+1
;
	bne l470
;
tstrdj	pla
	cmp #rdmax      ; if(csect>6)return;
	bcc doitt
;
;
l470	dec jobn
	bpl l480
;
	txa             ; test if a job to do
	bpl l490
;
	jmp end         ; no job found
;
l490	stx jobn
	jsr setjb
	lda job
	jmp reed
;
;
;
;
cnvbin	lda bufpnt
	pha
	lda bufpnt+1
	pha             ; save buffer pntr
;
	lda #<stab
	sta bufpnt      ; point at gcr code
	lda #>stab
	sta bufpnt+1
;
	lda #0
	sta gcrpnt
;
	jsr get4gb      ; convert 4 bytes
;
	lda btab+3
	sta header+2
;
	lda btab+2
	sta header+3
;
	lda btab+1
	sta header+4
;
;
	jsr get4gb      ; get 2 more
;
	lda btab        ; get id
	sta header+1
	lda btab+1
	sta header
;
	pla
	sta bufpnt+1    ;restore pointer
	pla
	sta bufpnt
;
	rts
;
;
;
;
;
;
;
