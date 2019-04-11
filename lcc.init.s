;
;
;
;     initialization of controller
;
;
;
cntint	lda #%01101111  ; data direction
	sta ddrb2
	and #$ff-$08-$04-$03 ; turn motor off,set phase a, led off
	sta dskcnt
;
;
	lda pcr2        ; set edge and latch mode
	and #$ff-$01    ; neg edge please
;
;
;  ca2: soe output hi disable s.o. into 6502
;
	ora #$0e
;
;
; cb1 input only
;
; cb2 mode control r/w
;
	ora #$e0
	sta pcr2
;
;
	lda #$41        ; cont irq, latch mode
	sta acr2
;
;--------9/25 rom05-bc-------------
	lda #0
	sta t1ll2
	lda #tim        ; / 15 ms /irq
	sta t1hl2
	sta t1hc2       ; get 6522's attention
;----------------------------------
;
	lda #$7f        ; clear all irq sources
	sta ier2
;
	lda #$80+$40
	sta ifr2        ; clear bit
	sta ier2        ; enable irq
;
;
	lda #$ff        ; no current drive
	sta cdrive
	sta ftnum       ; init format flag
;
	lda #$08        ; header block id
	sta hbid
;
	lda #$07        ; data block id
	sta dbid
;
	lda #<inact
	sta nxtst
	lda #>inact
	sta nxtst+1
;
	lda #200
	sta minstp
;
	lda #4
	sta as
;
	lda #$4
	sta af
;
