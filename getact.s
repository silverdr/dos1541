;*********************************
;* getact: get active buffer #   *
;*   vars: buf0,buf1,lindx       *
;*   regs: out: .a= act buffer # *
;*              .x= lindx        *
;*   flags:     .n=1: no act-buf *
;*********************************
;
getact
	ldx lindx
	lda buf0,x
	bpl ga1
	lda buf1,x
ga1
	and #$bf        ; strip dirty bit
	rts
;
;*********************************
;* gaflg: get active buffer #;   *
;*        set lbused & flags.    *
;*   regs: out: .a= act buffer # *
;*              .x= lindx        *
;*   flags:     .n=1: no act-buf *
;*              .v=1: dirty buf  *
;*********************************
;
gaflgs
	ldx lindx
ga2	stx lbused      ;save buf #
	lda buf0,x
	bpl ga3
;
	txa
	clc
	adc #mxchns+1
	sta lbused
	lda buf1,x
ga3
	sta t1
	and #$1f
	bit t1
	rts
;
;******************************
;******************************
;
; get channels inactive
; buffer number.
;
;    input parameters:
;        lindx - channel #
;
;    output parameters:
;        a <== inactive buffer #
;           or
;        a <== $ff if no
;            inactive buffer.
;
;******************************
;
getina	ldx lindx
	lda buf0,x
	bmi gi10
	lda buf1,x
gi10	cmp #$ff
	rts
;
;*****************************
;**********  p u t i n a  ****
;*****************************
;
; put inactive buffer
;
;    input paramters:
;        a = buffer #
;
;    output paramters:
;        none
;
;*****************************
;
putina	ldx lindx
	ora #$80
	ldy buf0,x
	bpl pi1
	sta buf0,x
	rts
pi1	sta buf1,x
	rts
;
