;
;
;
;    * write job
;
;    write out data buffer
;
;
wright	cmp #$10        ; test if write
	beq wrt05
;
	jmp vrfy
;
wrt05	jsr chkblk      ; get block checksum
	sta chksum
;
	lda dskcnt      ; test for write protect
	and #$10
	bne wrt10       ; not  protected
;
	lda #8          ; write protect error
	jmp errr
;
wrt10	jsr bingcr      ; convert buffer to write image
;
	jsr srch        ; find header
;
	ldx #gap1-2     ; wait out header gap
;
wrt20	bvc *
	clv
;
	dex             ; test if done yet
	bne wrt20
;
	lda #$ff        ; make output $ff
	sta ddra2
;
	lda pcr2        ; set write mode
	and #$ff-$e0
	ora #$c0
	sta pcr2
;
	lda #$ff        ; write 5 gcr sync
	ldx #numsyn     ;
	sta data2
	clv
;
wrtsnc	bvc *
;
	clv
	dex
	bne wrtsnc
;
	ldy #256-topwrt ; write out overflow buffer
;
wrt30	lda ovrbuf,y    ; get a char
	bvc *           ; wait until ready
	clv
;
	sta data2       ; stuff it
	iny
	bne wrt30       ; do next char
;
         ; write rest of buffer
;
wrt40	lda (bufpnt),y  ; now do buffer
	bvc *           ; wait until ready
	clv
;
	sta data2       ; stuff it again
	iny
    ; test if done
	bne wrt40       ; do the whole thing
;
	bvc *           ; wait for last char to write out
;
;
	lda pcr2        ; goto read mode
	ora #$e0
	sta pcr2
;
	lda #0          ; make data2 input $00
	sta ddra2
;
	jsr wtobin      ; convert write image to binary
;
	ldy jobn        ; make job a verify
	lda jobs,y
	eor #$30
	sta jobs,y
;
	jmp seak        ; scan job que
;
;
chkblk	lda #0          ; get eor checksum
	tay
;
chkb10	eor (bufpnt),y
	iny
	bne chkb10
;
	rts             ; return checksum in .a
;
;
;
;
;    * wtobin
;
;    convert write image back to
;    binary data
;
;
wtobin	lda #0          ; init pointer
	sta savpnt
	sta bufpnt      ; lsb
	sta nxtpnt
;
	lda bufpnt+1    ;goto buffer next
	sta nxtbf
;
	lda #>ovrbuf    ; use overflow first
	sta bufpnt+1
	sta savpnt+1
;
	lda #256-topwrt
	sta gcrpnt      ; get here first
	sta bytcnt      ; store here
;
	jsr get4gb      ; get first four- id and 3 data
;
	lda btab        ; save bid
	sta bid
;
	ldy bytcnt
;
	lda btab+1
	sta (savpnt),y
	iny
;
	lda btab+2
	sta (savpnt),y
	iny
;
	lda btab+3
	sta (savpnt),y
	iny
;
	sty bytcnt
;
wtob14	jsr get4gb      ;do rest of overflow buffer
;
	ldy bytcnt
;
	lda btab
	sta (savpnt),y
	iny
;
	lda btab+1
	sta (savpnt),y
	iny
	beq wtob50
;
	lda btab+2
	sta (savpnt),y
	iny
;
	lda btab+3
	sta (savpnt),y
	iny
;
	sty bytcnt
	bne wtob14      ; jmp
;
wtob50
;
	lda btab+2
	sta (bufpnt),y
	iny
;
	lda btab+3
	sta (bufpnt),y
	iny
;
	sty bytcnt
;
wtob53	jsr get4gb
;
	ldy bytcnt
;
	lda btab
	sta (bufpnt),y
	iny
;
	lda btab+1
	sta (bufpnt),y
	iny
;
	lda btab+2
	sta (bufpnt),y
	iny
;
	lda btab+3
	sta (bufpnt),y
	iny
;
	sty bytcnt
	cpy #187
	bcc wtob53
;
wtob52	lda #69         ; move buffer up
	sta savpnt
;
	lda bufpnt+1
	sta savpnt+1
;
	ldy #256-topwrt-1
;
wtob55	lda (bufpnt),y
	sta (savpnt),y
;
	dey
	bne wtob55
;
	lda (bufpnt),y
	sta (savpnt),y
;
	ldx #256-topwrt ; move overflow over to buffer
;
wtob57	lda ovrbuf,x
	sta (bufpnt),y
;
	iny
	inx
	bne wtob57
;
	stx gcrflg      ; clear buffer gcr flag
;
;
	rts
;
;
;
;
;
;    * verify data block
;
;   convert to gcr verify image
;
;   test against data block
;
;   convert back to binary
;
;
vrfy	cmp #$20        ; test if verify
	beq vrf10
;
	jmp sectsk
;
vrf10
;
	jsr chkblk      ; get block checksum
	sta chksum
;
	jsr bingcr      ; convert to verify image
;
	jsr dstrt
;
	ldy #256-topwrt
vrf15	lda ovrbuf,y    ; get char
	bvc *
	clv
;
	eor data2       ; test if same
	bne vrf20       ;verify error
;
	iny
	bne vrf15       ; next byte
;
;
vrf30	lda (bufpnt),y  ; now do buffer
;
	bvc *
	clv             ; wait for char
;
	eor data2       ; test if same
	bne vrf20       ; error
;
	iny
	cpy #$fd        ; dont test off bytes
	bne vrf30
;
;
	jmp done        ; verify ok
;
vrf20	lda #7          ; verify error
	jmp errr
;
;
sectsk	jsr srch        ; sector seek
	jmp done
;
;
