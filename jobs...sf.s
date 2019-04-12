;
; use lastjob for drive #
; cmd is used for job command
;
setljb
	lda lstjob,x
	and #1
	ora cmd
;
; set job up and check t&s
;  .a=command for jobs
;  .x=job number
;
setjob
	pha
	stx jobnum
	txa
;asl a  ;4/12*****************
;asl a
	asl a
	tax
	lda hdrs+1,x    ;4/12***********
	sta cmd         ;save sector
	lda hdrs,x      ;4/12***********
	beq tserr
;
	cmp maxtrk
	bcs tserr       ;track too large
;
	tax
	pla             ;check for write
	pha
	and #$f0
	cmp #write
	bne sjb1        ;not write,skip check
	pla
	pha
	lsr a
	bcs sjb2        ;drive 1
;
	lda dskver      ;get version #
	bcc sjb3
sjb2
	lda dskver+1    ;get drive 1 ver#
sjb3
	beq sjb4        ;no # is ok, too
	cmp vernum
	bne vnerr       ;not same vernum #
;
sjb4
	txa             ;restore track #
	jsr maxsec
	cmp cmd
	beq tserr
	bcs sjb1        ;sector is ok!
;
;
; illegal track and sector
;
tserr
	jsr hed2ts
tser1
	lda #badts
	jmp cmder2
;
;
hed2ts
	lda jobnum
; asl a ;4/12*************
; asl a
	asl a
	tax
	lda hdrs,x      ;4/12***********
	sta track
	lda hdrs+1,x    ;4/12***********
	sta sector
	rts
;
;
tschk
	lda track
	beq tser1
	cmp maxtrk
	bcs tser1
;
	jsr maxsec
	cmp sector
	beq tser1
	bcc tser1
	rts
;
vnerr
	jsr hed2ts
	lda #cbmv2      ;write to wrong version
	jmp cmder2
;
sjb1
	ldx jobnum
	pla
	sta cmd
	sta jobs,x
	sta lstjob,x
	rts
;
;
; do job in .a, set up error count
; and lstjob. return when job done ok
; jmp to error if error returns
;
doread
	lda #read
	bne dojob       ;bra
dowrit
	lda #write
dojob
	ora drvnum
	ldx jobnum
;
doit	sta cmd
doit2	lda cmd
	jsr setjob
;      jmp watjob
;
; wait until job(.x) is done
; return when done
;
watjob	jsr tstjob
	bcs watjob
	pha             ;clr jobrtn flag
	lda #0
	sta jobrtn
	pla
	rts
;
;
;test if job(.x) is done yet
;if not done return
;if ok then return else redo it
;
tstjob	lda jobs,x
	bmi notyet
	cmp #2
	bcc ok
;
	cmp #8          ;check for wp switch on
	beq tj10
;
	cmp #11         ;check for id mismatch
	beq tj10
;
	cmp #$f         ;check for nodrive
	bne recov
tj10	bit jobrtn
	bmi ok
	jmp quit2
;
ok	clc             ;c=0 finished ok or quit
	rts
;
notyet	sec             ;c=1 not yet
	rts
;
;
recov
	tya             ;save .y
	pha
	lda drvnum      ;save drive #
	pha
	lda lstjob,x
	and #1
	sta drvnum      ;set active drive #
;
	tay
	lda ledmsk,y
	sta erled
;
	jsr dorec
	cmp #2
	bcs rec01
	jmp rec95
rec01
;
	lda lstjob,x    ;original job
	and #$f0        ;mask job code
	pha             ;save it
	cmp #write
	bne rec0        ;not a write
;
	lda drvnum
	ora #secsek     ;replace w/ sector seek...
	sta lstjob,x    ;... during recovery
rec0
	bit revcnt
	bvs rec5        ;no track offset
;
	lda #0
	sta eptr        ;clr offset table ptr
	sta toff        ;clr total offset
rec1
	ldy eptr
	lda toff
	sec
	sbc offset,y
	sta toff        ;keep track of all offsets
	lda offset,y
	jsr hedoff
	inc eptr        ;bump table ptr
	jsr dorec       ;do the recovery
	cmp #2          ;error code < 2?
	bcc rec3        ;job worked
;
	ldy eptr
	lda offset,y 
	bne rec1        ;null indicates end
rec3
	lda toff
	jsr hedoff
	lda jobs,x
	cmp #2
	bcc rec9        ;no error
rec5
	bit revcnt      ;check bump-on flag
	bpl rec7        ;no bump
;
quit
	pla
	cmp #write      ;check original job
	bne quit2
;
	ora drvnum
	sta lstjob,x    ;must restore original
quit2
	lda jobs,x      ;.a= error #
	jsr error
rec7
	pla
	bit jobrtn
	bmi rec95       ;return job error
	pha
;
;do the bump
	lda #bump
	ora drvnum
	sta jobs,x
rec8
	lda jobs,x
	bmi rec8        ;wait
;
	jsr dorec       ;try one last set
	cmp #2
	bcs quit        ;it clearly ain't gonna work
rec9
	pla             ;check original job for write
	cmp #write
	bne rec95       ;original job worked
;
	ora drvnum
	sta lstjob,x    ;set write job back
	jsr dorec       ;try last set of writes
	cmp #2          ;check error code
	bcs quit2       ;error
rec95
	pla
	sta drvnum      ;restore drive #
	pla
	tay             ;restore .y
	lda jobs,x
	clc             ;ok!
	rts
;
hedoff	;.a=offset
	cmp #0
	beq hof3        ;no offset
	bmi hof2        ;steps are inward
hof1
	ldy #1          ;step out 1 track
	jsr movhed
	sec
	sbc #1
	bne hof1        ;not finished
	beq hof3
hof2
	ldy #$ff        ;step in 1 track
	jsr movhed
	clc
	adc #1
	bne hof2        ; not finished
hof3
	rts
;
movhed
	pha             ;save .a
	tya             ;put phase in .a
	ldy drvnum
	sta phase,y
mh10
	cmp phase,y
	beq mh10        ;wait for controller
;to change it
	lda #0
	sta phase,y     ;clear it out
	pla             ;restore
	rts
;
;
dorec	;do last job recovery
	lda revcnt      ;re-try job revcnt...
	and #$3f        ;...# of times
	tay
dorec1
	lda erled
	eor ledprt
	sta ledprt
	lda lstjob,x    ;set last job
	sta jobs,x
dorec2
	lda jobs,x      ;wait
	bmi dorec2
	cmp #2
	bcc dorec3      ;it worked
;
	dey
	bne dorec1      ;keep trying
dorec3
	pha
	lda erled       ;leave drive led on
	ora ledprt
	sta ledprt
	pla
	rts             ;finished
;
; set header of active buffer of the 
; current lindx to track,sector,id
;
sethdr	jsr getact
seth
; asl a ;4/12*****************
; asl a
	asl a
	tay
	lda track
	sta hdrs,y      ;4/12*********** ;set track
	lda sector
	sta hdrs+1,y    ;4/12*********** ;set sector
	lda drvnum      ;get proper id(drvnum)
	asl a
	tax
; lda dskid,x
; sta hdrs,y    ;4/12***********
; lda dskid+1,x
; sta hdrs+1,y  ;4/12***********
	rts 
;
