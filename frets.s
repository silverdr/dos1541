; mark a track,sector as free in bam
wfree
	jsr fixbam
;
frets
	jsr freuse      ;calc index into bam
frets2
	sec             ;flag for no action
	bne frerts      ;free already
	lda (bmpnt),y   ;not free, free it
	ora bmask,x
	sta (bmpnt),y
	jsr dtybam      ;set dirty flag
	ldy temp
	clc
	lda (bmpnt),y   ;add one
	adc #1
	sta (bmpnt),y
	lda track
	cmp dirtrk
	beq use10
;
	inc ndbl,x
	bne fre10
	inc ndbh,x
fre10
frerts	rts
;
dtybam
	ldx drvnum
	lda #1
	sta mdirty,x    ;set dirty flag
	rts
;
; mark track,sector,(bmpnt) as used
;
wused
	jsr fixbam
;
usedts	;calc in dex into bam
	jsr freuse      ;calc in dex into bam
	beq userts      ;used, no action
	lda (bmpnt),y   ;get bits
	eor bmask,x     ;mark sec used
	sta (bmpnt),y
	jsr dtybam
	ldy temp
	lda (bmpnt),y   ;get count
	sec
	sbc #1          ; dec one (c=0)
	sta (bmpnt),y   ;save it
	lda track
	cmp dirtrk
	beq use20
;
	lda ndbl,x
	bne use10
	dec ndbh,x
use10
	dec ndbl,x
use20
	lda ndbh,x
	bne userts
	lda ndbl,x
;
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;
	jmp ptch66	; *** rom ds 04/25/86 ***
	nop		; fill
;       cmp #3
;       bcs userts
;
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;
	lda #dskful
	jsr errmsg
userts	rts
;
; calculates index into bam
; for frets and usedts
;
freuse
	jsr setbam
	tya
freus2
	sta temp        ;save index
freus3
	lda sector      ;a=sector/8
	lsr a
	lsr a
	lsr a           ;for which of three bytes
	sec
	adc temp        ;calc index
	tay
	lda sector      ;bit in that byte
	and #7
	tax
	lda (bmpnt),y   ;get the byte
	and bmask,x     ;test it
	rts             ;z=1=used,z=0=free
;
;
bmask	.byte 1,2,4,8,16,32,64,128
;
fixbam	;write the bam according to wbam flag
	lda #$ff
	bit wbam
	beq fbam10      ;test flags
	bpl fbam10
	bvs fbam10
;
	lda #0
	sta wbam        ;clear flag
	jmp dowrit
;
fbam10
	rts
;
;
; clear the bam area
;
clrbam
	jsr setbpt
	ldy #0
	tya
clb1
	sta (bmpnt),y
	iny
	bne clb1
	rts
;
setbam	;set bam image in memory
	lda t0          ;save temps
	pha
	lda t1
	pha
;
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;
	jmp ptch52	; *** rom ds 05/01/85 ***
	nop		; fill
;       ldx drvnum
;       lda nodrv,x
rtch52			; ret address
;
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;
	beq sbm10
;
	lda #nodriv     ;no drive
	jsr cmder3
sbm10
	jsr bam2a
	sta t0          ;t0:= index into buf0
	txa
	asl a
	sta t1          ;t1:= 2*drvnum
	tax
	lda track
	cmp tbam,x      ;check bam table for track
	beq sbm30       ;it's in
;
	inx
	stx t1          ;check next entry
	cmp tbam,x
	beq sbm30       ;it's in
;
	jsr swap        ;swap track bam in table
sbm30
	lda t1
	ldx drvnum
	sta ubam,x      ;set last used ptr
	asl a
	asl a
	clc
	adc #<bam       ;set actual ptr
	sta bmpnt
	lda #>bam
	adc #0
	sta bmpnt+1
	ldy #0
	pla
	sta t1
	pla
	sta t0
	rts
;
;
swap	;swap images of bam
	ldx t0
	jsr redbam      ;read bam if not in
	lda drvnum
	tax
	asl a
	ora ubam,x      ;swap out least used image
	eor #1
	and #3
	sta t1
	jsr putbam      ;put to bam
	lda jobnum
	asl a
	tax
	lda track
	asl a
	asl a
	sta buftab,x    ;set ptr
	lda t1
	asl a
	asl a
	tay
swap3	;transfer bam to mem image
	lda (buftab,x)
	sta bam,y
	lda #0
	sta (buftab,x)  ;clear bam
	inc buftab,x
	iny
	tya
	and #3
	bne swap3
;
	ldx t1
	lda track
	sta tbam,x      ;set track # for image
;
	lda wbam
	bne swap4       ;don't write now
	jmp dowrit
swap4
	ora #$80        ;set pending write flag
	sta wbam
	rts
;
putbam	;put mem image to bam
	tay
	lda tbam,y
	beq swap2       ;no image here
;
	pha             ;save track #
	lda #0
	sta tbam,y      ;clear track flag
	lda jobnum
	asl a
	tax
	pla
	asl a
	asl a
	sta buftab,x    ;set ptr in bam
	tya
	asl a
	asl a
	tay
swap1	;transfer image to bam
	lda bam,y
	sta (buftab,x)
	lda #0
	sta bam,y       ;clear image
	inc buftab,x
	iny
	tya
	and #3
	bne swap1
swap2
	rts
;
;
clnbam	;clean track # for images
	lda drvnum
	asl a
	tax
	lda #0
	sta tbam,x
	inx
	sta tbam,x
	rts
;
;
;
redbam	;read in bam if not present
	lda buf0,x
	cmp #$ff
	bne rbm20       ;it is in memory
	txa
	pha             ;save channel ptr
	jsr getbuf      ;go find a buffer
	tax
	bpl rbm10
;
	lda #nochnl     ;no buffers around
	jsr cmderr
rbm10
	stx jobnum      ;save jobnum assigned
	pla
	tay
	txa
	ora #$80
	sta buf0,y      ;set as inactive for stealing
;read in bam
	asl a
	tax
	lda dirtrk
	sta hdrs,x
	lda #0
	sta hdrs+1,x
	jmp doread
rbm20
	and #$f         ;set bam's jobnum
	sta jobnum
	rts
;
;set bam pointer in buf0/1 tables
;
bam2a	;leave in .a
	lda #blindx
	ldx drvnum
	bne b2x10
;
	clc
	adc #mxchns+1
b2x10
	rts
;
bam2x	;leave in .x
	jsr bam2a
	tax
	rts
;
;
