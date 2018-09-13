;*********************************
;* addrel: add blocks to relative*
;*         file.                 *
;*   vars:                       *
;*   regs:                       *
;*                               *
;*********************************
;
addrel
	jsr setdrn
	jsr ssend       ;set up end of file
	jsr posbuf
	jsr dbset
	lda ssind
	sta r1          ;save ss index
	lda ssnum
	sta r0          ;save ss number
	lda #0
	sta r2          ;clear flag for one block
;
	lda #0          ;clear for calculation...
	sta recptr      ;...to 1st byte in record
	jsr fndrel      ;calc ss ptrs
addr1	; entry for rel record fix
	jsr numfre      ;calc available...
;
	ldy lindx       ;record span?
	ldx rs,y
	dex
	txa
	clc
	adc relptr
	bcc ar10        ;no span
;
	inc ssind       ;inc ss ptrs & check
	inc ssind       ;inc ss ptrs & check
	bne ar10
	inc ssnum
	lda #ssioff
	sta ssind
ar10
	lda r1
	clc
	adc #2
	jsr setssp
;
	lda ssnum
	cmp #nssl
	bcc ar25        ;valid range
;
ar20
	lda #bigfil
	jsr cmderr      ;too many ss's
ar25
	lda ssind       ;calc # blocks needed...
	sec             ;...& check against avail.
	sbc r1
	bcs ar30
	sbc #ssioff-1
	clc
ar30
	sta t3          ;# ss indices
	lda ssnum
	sbc r0
	sta t4          ;# ss needed
;
	ldx #0          ;clear accum.
	stx t1
	stx t2
	tax             ;.x=# ss
	jsr sscalc      ;calc # of blocks needed
;
	lda t2
	bne ar35
	ldx t1
	dex
	bne ar35
;
	inc r2
ar35
	cmp nbtemp+1
	bcc ar40        ;ok!!
	bne ar20
	lda nbtemp
	cmp t1
	bcc ar20        ;not enuf blocks
ar40
	lda #1
	jsr drdbyt      ;look at sector link
	clc
	adc #1          ;+1 is nr
	ldx lindx
	sta nr,x
	jsr nxtts       ;get next block...
	jsr setlnk      ;...& set link.
	lda r2
	bne ar50        ;add one block
;
	jsr wrtout      ;write current last rec
ar45
	jsr dblbuf      ;switch bufs
	jsr sethdr      ;set hdr from t & s
	jsr nxtts       ;get another
	jsr setlnk      ;set up link
	jsr nulbuf      ;clean it out
	jmp ar55
ar50
	jsr dblbuf      ;switch bufs
	jsr sethdr      ;set hdr from t & s
	jsr nulbuf      ;clean buffer
	jsr nullnk      ;last block =0,lstchr
ar55
	jsr wrtout      ;write buffer
	jsr getlnk      ;get t&s from link
	lda track
	pha             ;save 'em
	lda sector
	pha
	jsr gethdr      ;now get hdr t&s
	lda sector
	pha             ;save 'em
	lda track
	pha
	jsr gsspnt      ;check ss ptr
	tax
	bne ar60
;
	jsr newss       ;need another ss
	lda #ssioff
	jsr setssp      ;.a=bt val
	inc r0          ;advance ss count
ar60
	pla
	jsr putss       ;record t&s...
	pla
	jsr putss       ;...in ss.
	pla             ;get t&s from link
	sta sector
	pla
	sta track
	beq ar65        ;t=0: that's all!!
;
	lda r0
	cmp ssnum
	bne ar45        ;not even done yet
;
	jsr gsspnt
	cmp ssind
	bcc ar45        ;almost done
	beq ar50        ;one more block left
ar65
	jsr gsspnt
	pha
	lda #0
	jsr ssdir
	lda #0
	tay
	sta (dirbuf),y
	iny
	pla
	sec
	sbc #1
	sta (dirbuf),y
	jsr wrtss       ;write ss
	jsr watjob
	jsr mapout
	jsr fndrel
	jsr dblbuf      ;get back to leading buffer
	jsr sspos
	bvs ar70
	jmp positn
ar70
	lda #lrf
	jsr setflg
	lda #norec
	jsr cmderr
	jsr dblbuf
