.page 'new'
;new: initialize a disk, disk is 
;  soft-sectored, bit avail. map,
;  directory, & 1st block are all inited
.skip
new	jsr onedrv
	lda fildrv      ;set up drive #
	bpl n101
	lda #badfn      ;bad drive # given
	jmp cmderr
n101	and #1
	sta drvnum
	jsr setlds
.skip
	lda drvnum
	asl a
	tax
	ldy filtbl+1    ;get disk id
	cpy cmdsiz      ;?is this new or clear?
	beq n108        ;end of cmd string
	lda cmdbuf,y    ;format disk****
	sta dskid,x     ;store in proper drive
	lda cmdbuf+1,y  ;(y=0)
	sta dskid+1,x
.skip
	jsr clrchn      ;clear all channels when formatting
	lda #1          ;...in track, track=1
	sta track
	jsr format      ;transfer format to ram
	jsr clrbam      ;zero bam
	jmp n110
.skip
n108	jsr initdr      ;clear directory only
	ldx drvnum
	lda dskver,x    ;use current version #
	cmp vernum
	beq n110
	jmp vnerr       ;wrong version #
n110
	jsr newmap      ;new bam
.skip
	lda jobnum
	tay
	asl a
	tax
	lda dsknam      ;set ptr to disk name
	sta buftab,x
	ldx filtbl
	lda #27
	jsr trname      ;transfer cmd buf to bam
.skip
	ldy #$12
	ldx drvnum
	lda vernum      ;set dos's current format type
	sta dskver,x
	txa
	asl a
	tax
	lda dskid,x     ;write directory's  i.d.
	sta (dirbuf),y
	iny
	lda dskid+1,x
	sta (dirbuf),y
.skip
	iny
	iny
	lda #dosver+$30 ;write directory dos version
	sta (dirbuf)y
	iny
	lda vernum      ;write directory format type
	sta (dirbuf)y
;
	ldy #2
	sta (bmpnt),y   ;write diskette's format type
	lda dirtrk
	sta track
	jsr usedts      ;set bam block used
	lda #1
	sta sector
	jsr usedts      ;set 1st dir block used
	jsr scrbam      ;scrub the bam
	jsr clrbam      ;set to all 0's
	ldy #1
	lda #$ff        ;set end link
	sta (bmpnt)y
	jsr drtwrt      ;clear directory
	dec sector
	jsr drtrd       ;read bam back
.skip
	jmp endcmd
.skip
.end