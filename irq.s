;
;
;
sysirq	pha             ; save .a,.x,.y
	txa
	pha
	tya
	pha
;
;
	lda ifr1        ; test if atn
	and #2
	beq irq10       ; not atn
;
	jsr atnirq      ; handle atn request
;
;
irq10	lda ifr2        ; test if timer
	asl a
	bpl irq20       ; not timer
;
	jsr lcc         ; goto controller
;
irq20	pla             ; restore .y,.x,.a
	tay
	pla
	tax
	pla
	rti
;
;
;
