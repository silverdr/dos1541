;
; get next char from a chanl
;
gbyte	;get through internal channel
	jsr fndrch
	jsr setlds
	jsr get
	ldx lindx
	lda chndat,x
	rts
;
;
get	ldx lindx
	jsr typfil      ;get file type
	bne get00
;
	jmp rdrel
get00
	lda sa
	cmp #$f
	beq geterc
;
	lda chnrdy,x    ;was last char just sent
	and #eoisnd     ; just sent eoi
	bne get1        ;nope not this time
;
	jsr typfil
	cmp #dirtyp
	bne get0        ;not direct type
;
	lda #rndrdy     ; direct file remains active
	sta chnrdy,x    ;talker listener noeoi
	jmp rndget      ; prepare the next char
;
get0	lda #notrdy     ;lst char sent,not ready
	sta chnrdy,x
	rts
;
;
get1	lda sa          ;test if a load
	beq get6        ;its a load sa of 0
;
get2	jsr typfil      ; tst for rnd file
	cmp #4
	bcc seqget      ;seq file char get
;
rndget	jsr getpre      ;direct file get
	lda buftab,x
	cmp lstchr,y    ;up to lst char yet
	bne rnget1      ;not yet
;
	lda #0          ;read the whole thing
	sta buftab,x    ;wrap pntr to 0
rnget1
	inc buftab,x    ;get the next char
rnget2
	lda (buftab,x)
rnget4
	sta chndat,y    ;save char in
	lda buftab,x
	cmp lstchr,y
	bne rnget3
;
	lda #rndeoi
	sta chnrdy,y    ;this is last char
rnget3	rts             ;send eoi with it
;
;
seqget	jsr rdbyt       ;read the next byte
get3	ldx lindx
	sta chndat,x    ;store in chndat
	rts
;
;
get6	lda dirlst      ;test if dir lsting
	beq seqget      ;no, its not
	jsr getdir      ;yes it is,get dir char
	jmp get3
;
geterc
	jsr getpnt
	cmp #<errbuf-1
	bne ge10
	lda dirbuf+1
	cmp #>errbuf
	bne ge10
;
	lda #cr
	sta data
	jsr erroff
	lda #0
	jsr errts0
	dec cb+2
	lda #eoiout
	bne ge30        ;(jump)
;
ge10
	jsr getbyt
	sta data
	bne ge20
ge15
	lda #<errbuf-1
	jsr setpnt
	lda #>errbuf
	sta buftab+1,x
ge20
	lda #rdytlk
ge30
	sta chnrdy+errchn
	lda data
	sta chndat+errchn
	rts
;
;
; read next buffer of a file
; follow links in first two bytes
; end of file if 1st byte=0
; 2nd char length
;
nxtbuf	jsr getact
	asl a
	tax
	lda #0
	sta buftab,x
	lda (buftab,x)
	beq nxtb1
	dec buftab,x
	jmp rdbyt
nxtb1	rts
;
; direct block read
;
;
drtrd	lda #read
	bne drt
; direct block write
;
; direct block write
drtwrt	lda #write
drt	ora drvnum
	sta cmd
	lda jobnum
	jsr seth
	ldx jobnum
	jmp doit2
; open internal read chanl (sa=16)
;
opnird
	lda #1
opntyp
	sta type
	lda #irsa
	sta sa
	jsr opnrch
	lda #2
	jmp setpnt
; open internal write chanl (sa=16)
;
;
opniwr	lda #iwsa
	sta sa
	jmp opnwch
;
; allocate next directory block on 18
;  and mark as used in bam
;
nxdrbk	jsr curblk
	lda #1
	sta temp
	lda secinc
	pha
	lda #3          ;  incr sector by 3 in directory
	sta secinc
	jsr nxtds
	pla
	sta secinc
	lda #0
	jsr setpnt
	lda track
	jsr putbyt
	lda sector
	jsr putbyt
	jsr wrtbuf
	jsr watjob
	lda #0
	jsr setpnt
nxdb1	jsr putbyt
	bne nxdb1
	jsr putbyt
	lda #$ff
	jmp putbyt
;
;
; .a=new pntr value
;
setpnt	sta temp
	jsr getact
	asl a
	tax
	lda buftab+1,x
	sta dirbuf+1
	lda temp
	sta buftab,x
	sta dirbuf
	rts
;
;
;
; free the internal chanl (sa=16)
;
freich	lda #irsa
	sta sa
	jsr frechn
	lda	#iwsa
	sta	sa
	jmp	frechn
;
; read the active buffer pointer
;
getpnt	jsr getact
setdir
gp1	asl a
	tax
	lda buftab+1,x
	sta dirbuf+1
	lda buftab,x
	sta dirbuf
	rts
;
; direct read byte, .a=byte# to read
;
drdbyt	sta temp+2
	jsr getact
	tax
	lda bufind,x
	sta temp+3
	ldy #0
	lda (temp+2),y
	rts
; index table containing high
; byte address of buffers
;
