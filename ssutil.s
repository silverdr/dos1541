;*********************************
;* b0tob0: transfer bytes from   *
;*         one buf to other.     *
;*   reg: in: .a= # bytes        *
;*            .y= source buf #   *
;*            .x= destin buf #   *
;*********************************
;
b0tob0
	pha
	lda #0
	sta temp
	sta temp+2
	lda bufind,y
	sta temp+1
	lda bufind,x
	sta temp+3
	pla
	tay
	dey
b02
	lda (temp),y
	sta (temp+2),y
	dey
	bpl b02
	rts
;
;*********************************
;* clrbuf: clear buffer given    *
;*   reg: in: .a= buffer #       *
;*       out: .y,.a =0           *
;*********************************
;
clrbuf
	tay
	lda bufind,y
	sta temp+1
	lda #0
	sta temp
	tay
cb10
	sta (temp),y
	iny
	bne cb10
	rts
;
;
;*********************************
;* ssset: set ss pntr to 0       *
;*   reg: out: .a= ss number     *
;*********************************
;
ssset
	lda #0
	jsr ssdir
	ldy #2
	lda (dirbuf),y
	rts
;
;*********************************
;* ssdir: set dirbuf with current*
;*        ss pointer.            *
;*   regs: in: .a= low byte      *
;*********************************
;
ssdir
	sta dirbuf
	ldx lindx
	lda ss,x
	tax
	lda bufind,x
	sta dirbuf+1
	rts
;
;*********************************
;* setssp: set dirbuf & buftab   *
;*        with current ss ptr.   *
;*   regs: in: .a= low byte      *
;*********************************
;
setssp
	pha
	jsr ssdir
	pha
	txa
	asl a
	tax
	pla
	sta buftab+1,x
	pla
	sta buftab,x
	rts
;
;*********************************
;* sspos: position ss & buftab   *
;*        to ssnum ssind.        *
;*   flag:  .v=0: ok             *
;*          .v=1: out of range   *
;*********************************
;
sspos
	jsr sstest
	bmi ssp10       ;out of range
	bvc ssp20       ;er0:ok, in range
;
	ldx lindx       ;er1: possibly in range
	lda ss,x
	jsr ibrd        ;read ss in
	jsr sstest      ;test again
	bpl ssp20
ssp10
	jsr ssend       ;not in range,set end
	bit er1
	rts
ssp20
	lda ssind       ;ok, set ptr w/ index
	jsr setssp
	bit er0
	rts
;
;*********************************
;* ibrd: indirect block read &   *
;* ibwt: write.                  *
;*   regs: in: .a= buf # for r/w *
;*             .x= lindx         *
;*         (dirbuf),y   points to *
;*         t&s to be r/w.        *
;*********************************
;
ibrd
	sta jobnum
	lda #read
	bne ibop
ibwt
	sta jobnum
	lda #write
ibop
	pha
	lda filtyp,x
	and #1
	sta drvnum
	pla
	ora drvnum
	sta cmd
;
	lda (dirbuf),y
	sta track
	iny
	lda (dirbuf),y
	sta sector
	lda jobnum
	jsr seth
	ldx jobnum
	jmp doit2
;
;
;*
;*****************************
;*
;*  gsspnt
;*
;*****************************
;*
gsspnt	ldx lindx
	lda ss,x
	jmp gp1
;
scal1
	lda #nssp
	jsr addt12      ;add (#ss needed)*120
sscalc
	dex
	bpl scal1
;
	lda t3          ;add (# ss indices needed)
	lsr a
	jsr addt12
	lda t4          ;add (# ss blocks needed)
; jmp addt12
;
addt12
	clc             ;add .a to t1,t2
	adc t1
	sta t1
	bcc addrts
	inc t2
addrts
	rts
;
