.page 'erproc'
; error processing 
.skip
; controller errors
;  0  (1)  no error
; 20  (2)  can't find block header
; 21  (3)  no synch character
; 22  (4)  data block not present
; 23  (5)  checksum error in data
; 24  (16) byte decoding error
; 25  (7)  write-verify error
; 26  (8)  write w/ write protect on
; 27  (9)  checksum error in header
; 28  (10) data extends into next block
; 29  (11) disk i.d. mismatch
.skip
; command errors
; 30  general syntax
; 31  invalid command
; 32  long line
; 33  invalid filname
; 34  no file given
; 39  command file not found
.skip
; 50  record not present
; 51  overflow in record
; 52  file too large
.skip
; 60  file open for write
; 61  file not open
; 62  file not found
; 63  file exists
; 64  file type mismatch
; 65  no block
; 66  illegal track or sector
; 67  illegal system t or s
.skip
; 70  no channels available
; 71  directory error
; 72  disk full
; 73  cbm dos v2.6 v170
; 74  drive not ready
.skip
;  1  files scratched response
.skip2
badsyn	=$30
badcmd	=$31
longln	=$32
badfn	=$33
nofile	=$34
nocfil	=$39
norec	=$50
recovf	=$51
bigfil	=$52
filopn	=$60
filnop	=$61
flntfd	=$62
flexst	=$63
mistyp	=$64
noblk	=$65
badts	=$66
systs	=$67
nochnl	=$70
direrr	=$71
dskful	=$72
cbmv2	=$73
nodriv	=$74
.page
; error message table
;   leading errror numbers,
;   text with 1st & last chars 
;   or'ed with $80,
;   tokens for key words are
;   less than $10 (and'ed w/ $80)
.skip 2
errtab	;" ok"
	.byt 0,$a0,'o',$cb
;"read error"
	.byt $20,$21,$22,$23,$24,$27
	.byt $d2,'ead',$89
;" file too large"
	.byte $52,$83,' too larg',$c5
;" record not present"
	.byte $50,$8b,6,' presen',$d4
;"overflow in record"
	.byte $51,$cf,'verflow '
	.byte 'in',$8b
;" write error"
	.byt $25,$28,$8a,$89
;" write protect on"
	.byt $26,$8a,' protect o',$ce
;" disk id mismatch"
	.byt $29,$88,' id',$85
;"syntax error"
	.byt $30,$31,$32,$33,$34
	.byt $d3,'yntax',$89
;" write file open"
	.byt $60,$8a,3,$84
;" file exists"
	.byt $63,$83,' exist',$d3
;" file type mismatch"
	.byt $64,$83,' type',$85
;"no block"
	.byt $65,$ce,'o bloc',$cb
;"illegal track or sector"
	.byte $66,$67,$c9,'llegal track'
	.byte ' or secto',$d2
;" file not open"
	.byt $61,$83,6,$84
;" file not found"
	.byt $39,$62,$83,6,$87
;" files scratched"
	.byt 1,$83,'s scratche',$c4
;"no channel"
	.byt $70,$ce,'o channe',$cc
;"dir error"
	.byt $71,$c4,'ir',$89
;" disk full"
	.byt $72,$88,' ful',$cc
;"cbm dos v2.6 4030"
	.byte $73,$c3,'bm dos v2.6 v17',$b0
;"drive not ready"
	.byte $74,$c4,'rive',6,' read',$d9
.skip
; error token key words
;   words used more than once
;"error"
	.byt 9,$c5,'rro',$d2
;"write"
	.byt $a,$d7,'rit',$c5
;"file"
	.byt 3,$c6,'il',$c5
;"open"
	.byt 4,$cf,'pe',$ce
;"mismatch"
	.byt 5,$cd,'ismatc',$c8
;"not"
	.byt 6,$ce,'o',$d4
;"found"
	.byt 7,$c6,'oun',$c4
;"disk"
	.byt 8,$c4,'is',$cb
;"record"
	.byte $b,$d2,'ecor',$c4
etend	=*
.page
; controller error entry
;   .a= error #
;   .x= job #
error	pha
	stx jobnum
	txa
	asl a
	tax
	lda hdrs,x      ;4/12*****;recall track,sector
	sta track
	lda hdrs+1,x    ;4/12*********
	sta sector
.skip
	pla
	and #$f         ;convert controller...
	beq err1        ;...errors to dos errors
	cmp #$f         ;check nodrive error
	bne err2
;
	lda #nodriv
	bne err3        ;bra
err1
	lda #6          ;code=16-->14
err2	ora #$20
	tax
	dex
	dex
	txa
err3
	pha
	lda cmdnum
	cmp #val
	bne err4
	lda #$ff
	sta cmdnum
	pla
	jsr errmsg
	jsr initdr      ;init for validate
	jmp cmder3
err4
	pla
cmder2
	jsr errmsg
cmder3
	jsr clrcb       ;clear cmdbuf
	lda #0
	sta wbam        ;clear after error
	jsr erron       ;set error led
	jsr freich      ;free internal channel
	lda #0          ;clear pointers
	sta buftab+cbptr
	ldx #topwrt
	txs             ; purge stack
	lda orgsa
	and #$f
	sta sa
	cmp #$f
	beq err10
	sei
	lda lsnact
	bne lsnerr
	lda tlkact
	bne tlkerr
;
	ldx sa
	lda lintab,x
	cmp #$ff
	beq err10
	and #$f
	sta lindx
	jmp tlerr
;
.skip
; talker error recovery
;  if command channel, release dav
;  if data channel, force not ready
;   and release channel
tlkerr
	jsr fndrch
	jsr iterr
	bne tlerr       ;finish
.skip
; listener error recovery
;  if command channel, release rfd
;  if data channel, force not ready
;   and release channel
lsnerr
	jsr fndwch
	jsr ilerr
tlerr
	jsr typfil
	cmp #reltyp
	bcs err10
	jsr frechn
err10
	jmp idle
.page
; convert hex to bcd
hexdec	tax
	lda #0
	sed
hex0	cpx #0
	beq hex5
	clc
	adc #1
	dex
	jmp hex0
hex5	cld
.skip
; convert bcd to ascii dec
;  return bcd in .x
;  store ascii in (temp)y
bcddec	tax
	lsr a
	lsr a
	lsr a
	lsr a
	jsr bcd2
	txa
bcd2
	and #$f
	ora #$30
	sta (cb+2)y
	iny
	rts
.ski
; transfer error message to
;  error buffer
;
okerr
	jsr erroff
	lda #0
errts0
	ldy #0
	sty track
	sty sector
;
errmsg
	ldy #0
	ldx #<errbuf
	stx cb+2
	ldx #>errbuf
	stx cb+3
	jsr bcddec      ;convert error #
	lda #',
	sta (cb+2),y
	iny
	lda errbuf
	sta chndat+errchn
	txa             ;error # in .x
	jsr ermove      ;move message
.skip
ermsg2	lda #',
	sta (cb+2),y
	iny
	lda track
	jsr hexdec      ;convert track #
	lda #',
	sta (cb+2),y
	iny
	lda sector      ;convert sector #
	jsr hexdec
	dey
	tya
	clc
	adc #<errbuf
	sta lstchr+errchn ;set last char
	inc cb+2
	lda #rdytlk
	sta chnrdy+errchn
	rts
;
;**********************************;
;*    ermove - move error message *;
;*      from errtab to errbuf.    *;
;*      fully recursive for token *;
;*      word prosessing.          *;
;*   input: .a= bcd error number  *;
;**********************************;
;
ermove
	tax             ;save .a
	lda r0          ;save r0,r0+1
	pha
	lda r0+1
	pha
	lda #<errtab    ;set pointer to table
	sta r0
	lda #>errtab
	sta r0+1
	txa             ;restore .a
	ldx #0          ;.x=0 for indirect
e10
	cmp (r0,x)      ;?error # = table entry?
	beq e50         ;yes, send message
;
	pha             ;save error #
	jsr eadv2       ;check & advance ptr
	bcc e30         ;more #'s to check
e20
	jsr eadv2       ;advance past this message
	bcc e20
e30
	lda r0+1        ;check ptr
	cmp #>etend
	bcc e40         ;<, continue
	bne e45         ;>, quit
;
	lda #<etend
	cmp r0
	bcc e45         ;past end of table
e40
	pla             ;restor error #
	jmp e10         ;check next entry
e45
	pla             ;pop error #
	jmp e90         ;go quit
;
e50	;the number has been located
	jsr eadv1
	bcc e50         ;advance past other #'s
e55
	jsr e60
	jsr eadv1
	bcc e55
;
	jsr e60         ;check for token or last word
e90
	pla             ;all finished
	sta r0+1        ;restore r0
	pla
	sta r0
	rts
;
e60
	cmp #$20        ;(max token #)+1
	bcs e70         ;not a token
	tax
	lda #$20        ;implied leading space
	sta (cb+2),y
	iny
	txa             ;restore token #
	jsr ermove      ;add token word to message
	rts
e70
	sta (cb+2),y    ;put char in message
	iny
	rts
;
;error advance & check
;
eadv1	;pre-increment
	inc r0          ;advance ptr
	bne ea10
	inc r0+1
ea10
	lda (r0,x)      ;get current entry
	asl a           ;.c=1 is end or beginning
	lda (r0,x)
	and #$7f        ;mask off bit7
	rts
;
eadv2	;post-increment
	jsr ea10        ;check table entry
	inc r0
	bne ea20
	inc r0+1
ea20
	rts
;