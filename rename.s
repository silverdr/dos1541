; copy file(s) to one file
;
copy	;filenames, optimize
	jsr lookup      ;look ip all files
	lda f2cnt
	cmp #3
	bcc cop10
;
	lda fildrv
	cmp fildrv+1
	bne cop10
;
	lda entind
	cmp entind+1
	bne cop10
;
	lda entsec
	cmp entsec+1
	bne cop10
;
	jsr chkin       ;concat
	lda #1
	sta f2ptr
	jsr opirfl
;
	jsr typfil
	beq cop01
	cmp #prgtyp
	bne cop05
cop01
	lda #mistyp
	jsr cmderr
cop05
	lda #iwsa
	sta sa
	lda lintab+irsa
	sta lintab+iwsa
	lda #$ff
	sta lintab+irsa
	jsr append
	ldx #2
	jsr cy10
	jmp endcmd
cop10
	jsr cy
	jmp endcmd
;
;
cy
	jsr chkio       ;check files for existence
	lda fildrv
	and #1
	sta drvnum
	jsr opniwr      ;open internal write chnl
	jsr addfil      ;add to directory
	ldx f1cnt
cy10	stx f2ptr       ;set up read file
	jsr opirfl
;
	lda #irsa       ;add for rel copy
	sta sa
	jsr fndrch
	jsr typfil
	bne cy10a       ;not rel
	jsr cyext
;
cy10a	lda #eoisnd
	sta eoiflg
	jmp cy20
cy15
	jsr pibyte
cy20
	jsr gibyte
	lda #lrf
	jsr tstflg
	beq cy15
;
	jsr typfil
	beq cy30
;
	jsr pibyte
cy30
	ldx f2ptr
;
	inx
	cpx f2cnt
	bcc cy10        ;more files to copy
	lda #iwsa
	sta sa
	jmp clschn      ;close copy channel, file
;
opirfl
	ldx f2ptr
	lda fildrv,x
	and #1
	sta drvnum
	lda dirtrk
	sta track
	lda entsec,x
	sta sector
	jsr opnird
	ldx f2ptr
	lda entind,x
	jsr setpnt
	ldx f2ptr
	lda pattyp,x
	and #typmsk
	sta type
;
	lda #0
	sta rec
	jsr opread
	ldy #1
	jsr typfil
	beq opir10
	iny
opir10
	tya
	jmp setpnt
;
gibyte
	lda #irsa
	sta sa
gcbyte
	jsr gbyte
;
	sta data
	ldx lindx
	lda chnrdy,x
	and #eoisnd
	sta eoiflg
	bne gib20
;
	jsr typfil
	beq gib20
;
	lda #lrf
	jsr setflg
gib20	rts
;
cyext	jsr setdrn      ;copy rel records
	jsr ssend
	lda ssind
	pha
	lda ssnum
	pha
	lda #iwsa
	sta sa
	jsr fndwch
	jsr setdrn
	jsr ssend
	jsr posbuf
	lda ssind
	sta r1
	lda ssnum
	sta r0
	lda #0
	sta r2
	sta recptr
	sta relptr
	pla
	sta ssnum
	pla
	sta ssind
	jmp addr1
;
; rename file name in directory
rename	jsr alldrs      ;set both drive #'s
	lda fildrv+1
	and #1
	sta fildrv+1
	cmp fildrv
	beq rn10        ;same drive #'s 
	ora #$80        ;check both drives for name
rn10	sta fildrv
	jsr lookup      ;look up both names
	jsr chkio       ;check for existence
	lda fildrv+1
	and #1
	sta drvnum
	lda entsec+1
	sta sector
	jsr rdab        ;read directory sector
	jsr watjob
	lda entind+1
	clc             ;set sector index
	adc #3          ;...+3
	jsr setpnt
	jsr getact
	tay
	ldx filtbl
	lda #16
	jsr trname      ;transfer name
	jsr wrtout      ;write sector out
	jsr watjob
	jmp endcmd
; check i/o file for exist
chkin
	lda pattyp+1    ;1st file bears type
	and #typmsk
	sta type
;
	ldx f2cnt
ck10	dex
	cpx f1cnt 
	bcc ck20
	lda filtrk,x
	bne ck10
	lda #flntfd     ;input file not found
	jmp cmderr
ck20
	rts
;
chkio
	jsr chkin
ck25	lda filtrk,x
	beq ck30
	lda #flexst
	jmp cmderr
ck30	dex
	bpl ck25
	rts
