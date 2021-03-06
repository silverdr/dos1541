;
;
; .a=#buffers needed
; sets up buffer # and allocates lindx
getwch
	sec             ;set .c=1 indicate write
	bcs getr2
getrch
	clc             ;set .c=0 indicate read
getr2
	php             ;save r/w flag (.c)
	sta temp        ;save #bufs needed
	jsr frechn      ;free any channels
	jsr fndlnx      ; get next lindx open
	sta lindx
	ldx sa
	plp
	bcc getr55
getr52	ora #$80
getr55	sta lintab,x    ;save lindx in lintab
getbf
	and #$3f
	tay             ;now get the buffers
	lda #$ff
	sta buf0,y
	sta buf1,y
	sta ss,y
getr3	dec temp
	bmi getr4
	jsr getbuf
	bpl getr5
gberr	jsr relbuf      ; error ,rel bufs
	lda #nochnl
	jmp cmderr
getr5	sta buf0,y
	dec temp
	bmi getr4
	jsr getbuf
	bmi gberr
	sta buf1,y
getr4	rts
;
; free chanl associated with sa
; free read and write chanls
; dont free chanl 15
frechn	lda sa
	cmp #$f
	bne freco
	rts
freco
frerd
frewrt	ldx sa
	lda lintab,x
	cmp #$ff
	beq fre25
	and	#$3f
	sta lindx
	lda #$ff
	sta lintab,x
	ldx lindx
	lda #0
	sta chnrdy,x
	jsr relbuf
;
; release the lindx
;
relinx	ldx lindx
	lda #1
rel15	dex
	bmi rel10
	asl a
	bne rel15
rel10	ora linuse      ;1=free 0=used
	sta linuse
fre25	rts
; given sa , free its read chanl
;
; 
; release buffers (lindx)
;
relbuf	ldx lindx
	lda buf0,x
	cmp #$ff
	beq rel1
	pha
	lda #$ff
	sta buf0,x
	pla
	jsr frebuf
rel1	ldx lindx
	lda buf1,x
	cmp #$ff
	beq rel2
	pha
	lda #$ff
	sta buf1,x
	pla
	jsr frebuf
rel2	ldx lindx
	lda ss,x
	cmp #$ff
	beq rel3
	pha
	lda #$ff
	sta ss,x
	pla
	jsr frebuf
rel3	rts
;
; get a free buffer #
;
;  regs destroyed: .a  .x
;  out:  .a,.x= buf # or $ff  if failed
;        .n= 1 if failed
;
;     if successful init jobs & lstjob
;
getbuf
	tya             ;save .y
	pha
	ldy #1
	jsr fndbuf
	bpl gbf1        ;found one
;
	dey
	jsr fndbuf
	bpl gbf1        ;found one
;
	jsr stlbuf      ;steal one
	tax             ;test it
	bmi gbf2        ;didn't find one
gbf1
	lda jobs,x
	bmi gbf1        ;wait for job free
	lda drvnum
	sta jobs,x      ;clear job queue
	sta lstjob,x
	txa
	asl a
	tay
	lda #2
	sta buftab,y
gbf2
	pla
	tay             ;restore .y
	txa             ;exit with buf # in .a & cc set
	rts
;
;
; find a free buf # & set bit in bufuse
;  all regs used
;  in:  .y= index into bufuse
; out:  .x= buf # or $ff  if failed
;       .n= 1 if failed
;
fndbuf
	ldx #7
fb1
	lda bufuse,y    ;search bufuse
	and bmask,x
	beq fb2         ;found a free one
;
	dex
	bpl fb1         ;until all bits are tested
;
	rts
fb2	;set it used
	lda bufuse,y
	eor bmask,x     ;set bit
	sta bufuse,y
	txa
	dey
	bmi fb3         ;if .y then...
	clc             ;...add 8 more
	adc #8
fb3
	tax             ;leave in .x
fri20
	rts
;
freiac	;free inactive buffer
	ldx lindx
	lda buf0,x
	bmi fri10
;
	txa
	clc
	adc #mxchns+1
	tax
	lda buf0,x
	bpl fri20
fri10
	cmp #$ff
	beq fri20
;
	pha
	lda #$ff
	sta buf0,x
	pla
;  jmp frebuf
;
;
;
frebuf	and #$f
	tay
	iny
	ldx #16
freb1	ror bufuse+1
	ror bufuse
	dey
	bne freb2
	clc
freb2	dex
	bpl freb1
	rts
;
;
clrchn	lda #14
	sta sa
clrc1	jsr frechn 
	dec sa
	bne clrc1
	rts
;
cldchn	lda #14
	sta sa
clsd	ldx sa
	lda lintab,x
	cmp #$ff
	beq cld2
	and #$3f
	sta lindx
	jsr getact
	tax
	lda lstjob,x
	and #1
	cmp drvnum
	bne cld2
	jsr frechn
cld2	dec sa
	bpl clsd
	rts
;
;********************************
;***********  s t l b u f  ******
;********************************
;
; steal a buffer
;
; this rtn searches the channels
; in order of least recently used
; and steals the first inactive
; buffer it finds.
;
;    input paramters:
;        lrutbl - least recentyl
;                 used table
;
;    output paramters:
;        a <== buffer #
;
;    register usage:
;        x - channel index
;        y - lrutbl index
;
;*******************************
;
stlbuf
	lda t0
	pha             ;save t0
	ldy #0
stl05
	ldx lrutbl,y
	lda buf0,x
	bpl stl10       ;active
;
	cmp #$ff
	bne stl30       ;it's inactive
stl10
	txa
	clc
	adc #mxchns+1
	tax
	lda buf0,x
	bpl stl20
	cmp #$ff
	bne stl30
stl20
	iny
	cpy #mxchns-1
	bcc stl05
	ldx #$ff        ;set failure
	bne stl60       ;bra
stl30	;steal the buffer if no error
	stx t0
	and #$3f
	tax
stl40
	lda jobs,x
	bmi stl40       ;wait till done

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

	jmp ptch54	; *** rom ds 06/18/85 ***
	nop
;       cmp #2          ; errors?
;       bcc stl50       ; ok

rtch54			; return

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

	ldx t0
	cpx #mxchns+1
	bcc stl10       ;check opposite slot
	bcs stl20       ;check another channel
;
; found one, so lets steal it
;
stl50
	ldy t0
	lda #$ff
	sta buf0,y      ;clear slot
stl60
	pla
	sta t0
	txa             ;buf # in .a & set cc's
	rts
;
;
;
; find a free lindx to use
; mark as used in linuse
;
fndlnx	ldy #0
	lda #1
fnd10	bit linuse      ;1=free 0=used
	bne fnd30
	iny
	asl a
	bne fnd10
	lda #nochnl     ;no free lindx available
	jmp cmderr
fnd30	eor #$ff        ;toggle bit mask
	and linuse      ;mark bit used
	sta linuse
	tya             ;return lindx in .a
	rts
