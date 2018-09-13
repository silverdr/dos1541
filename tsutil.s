;*
;*
;*********************************
;*
;*  scrub
;*
;*  write out buffer if dirty
;*
;*********************************
;*
;*
scrub
	jsr gaflgs
	bvc scr1        ;not dirty
;
	jsr wrtout
	jsr watjob
scr1	rts
;*
;*
;*********************************
;*
;*  setlnk
;*
;*  put track,sector into buffer
;*
;*********************************
;*
;*
setlnk	jsr set00
;
	lda track
	sta (dirbuf),y
	iny
	lda sector
	sta (dirbuf),y
	jmp sdirty
;
;*
;*
;********************************
;*
;*  getlnk
;*
;*  get link from buffer into
;*  track and sector
;*
;********************************
;*
;*
getlnk	jsr set00
;
	lda (dirbuf),y
	sta track
	iny
	lda (dirbuf),y
	sta sector
	rts
;*
;*
;********************************
;*
;*  nullnk
;*
;*  set track link=0 & sector
;*  link=last non-zero char.
;*
;*********************************
;*
;*
nullnk
	jsr set00
	lda #0
	sta (dirbuf),y
	iny
	ldx lindx
	lda nr,x
	tax
	dex
	txa
	sta (dirbuf),y
	rts
;
;*
;*
;*******************************
;*
;* set00
;*
;* setup up pointer to buffer
;*
;*******************************
;*
;*
set00	jsr getact
	asl	a
	tax
	lda buftab+1,x
	sta dirbuf+1
	lda #0
	sta dirbuf
	ldy #0
	rts
;
;*
;*
;*******************************
;*
;*  gethdr
;*
;*  read track,setor from header
;*
;*******************************
;*
;*
curblk	jsr fndrch
gethdr	jsr getact
	sta jobnum
	asl a
	tay
	lda hdrs,y      ;4/12**************
	sta track
	lda hdrs+1,y    ;4/12**************
	sta sector
	rts
;
;*
;*
;******************************
;*
;* wrtab,rdab  wrtout,rdin
;* wrtss,rdss
;*
;******************************
;*
;*
wrtab	lda #write
	sta cmd
	bne sj10
;
rdab	lda #read
	sta cmd
	bne sj10
;
wrtout	lda #write
	sta cmd
	bne sj20
;
rdin	lda #read
	sta cmd
	bne sj20
;
wrtss	lda #write
	sta cmd
	bne rds5
;
rdss	lda #read
rds5	sta cmd
	ldx lindx
	lda ss,x
	tax
	bpl sj30        ;was...bne sj30
;
sj10	jsr sethdr
	jsr getact
	tax
	lda drvnum
	sta lstjob,x
sj20	jsr cdirty
	jsr getact
	tax
sj30	jmp setljb
;*
;*
;*
;***************************
;*
;*     rdlnk
;*
;***************************
;*
;*
rdlnk	lda #0
	jsr setpnt
	jsr getbyt
	sta track
	jsr getbyt
	sta sector
	rts
;
