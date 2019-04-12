;
;
;
;   motor and stepper control
;
;
;   irq into controller every 10 ms
end
	lda t1hl2
	sta t1hc2
;
	lda dskcnt
;
end001
	and #$10        ; test write proctect
	cmp lwpt
	sta lwpt        ; change ?
	beq end002      ; no
;
	lda #1          ; yes, set flag
	sta wpsw
;
end002	lda phase       ; test for phase offset
	beq end40
;
	cmp #2
	bne end003
;
	lda #0
	sta phase
	beq end40
;
end003	sta steps
	lda #2
	sta phase
	jmp dostep
;
end40	ldx cdrive      ; work on active drive only
	bmi end33x      ; no active drive
;
	lda drvst       ; test if motor on
	tay
	cmp #$20        ; test if anything to do
	bne end10       ; something here
;
end33x	jmp end33       ; motor just running
;
end10	dec acltim      ; dec timer
	bne end30
;
	tya             ; test if acel
	bpl end20
;
;
	and #$7f        ; over, clear acel bit
	sta drvst
;
end20	and #$10        ; test if time out state
	beq end30
;
	lda dskcnt
	and #$ff-$04    ; turnoff motor
	sta dskcnt
;
;
	lda #$ff        ; no active drive now
	sta cdrive
;
	lda #0          ; drive inactive
	sta drvst       ; clear on bit and timout
	beq end33x
;
end30	tya             ; test if step needed
	and #$40
	bne end30x      ; stepping
;
	jmp end33
;
;
end30x	jmp (nxtst)     ;goto proper stepper state
;
inact	lda steps       ; get abs(steps)
	bpl inac10
;
	eor #$ff
	clc
	adc #1
;
inac10	cmp minstp      ; test if we can accel
	bcs inac20      ; too small
;
	lda #<short     ;short step mode
	sta nxtst
	lda #>short
	sta nxtst+1
	bne dostep
;
inac20	; calc the # of run steps
	sbc as
	sbc as
	sta rsteps
;
	lda as
	sta aclstp      ; set  # of accel steps
	lda #<ssacl
	sta nxtst
	lda #>ssacl
	sta nxtst+1
;
dostep	lda steps
	bpl stpin
;
stpout	inc steps
	ldx dskcnt
	dex
	jmp stp
;
short	lda steps
	bne dostep
;
	lda #<setle
	sta nxtst
	lda #>setle
	sta nxtst+1
	lda #5          ; settle time
	sta aclstp
	jmp end33
;
setle	dec aclstp
	bne end33
;
	lda drvst
	and #$ff-$40
	sta drvst
;
	lda #<inact
	sta nxtst
	lda #>inact
	sta nxtst+1
	jmp end33
;
stpin	dec steps
	ldx dskcnt
	inx
;
stp	txa
	and #3
	sta tmp
	lda dskcnt
	and #$ff-$03    ; mask out old
	ora tmp
	sta dskcnt
	jmp end33
;
ssacl	                ; sub acel factor
	sec
	lda t1hl2
	sbc af
	sta t1hc2
;
	dec aclstp
	bne ssa10
;
	lda as
	sta aclstp
;
	lda #<ssrun
	sta nxtst
	lda #>ssrun
	sta nxtst+1
;
ssa10	jmp dostep
;
ssrun	dec rsteps
	bne ssa10
;
	lda #<ssdec
	sta nxtst
	lda #>ssdec
	sta nxtst+1
	bne ssa10
;
ssdec	                ; decel
	lda t1hl2
	clc
	adc af
	sta t1hc2
;
	dec aclstp
	bne ssa10
;
	lda #<setle     ; goto settle mode
	sta nxtst
	lda #>setle
	sta nxtst+1
;
	lda #5
	sta aclstp      ; settle timer
;
;
end33	lda pcr2        ; disable s.o. to 6502
	and #$ff-$02
	sta pcr2
;
	rts
;
;
;
