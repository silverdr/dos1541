; next track & sector
;  returns next available track & sector
;  given current t & s
; 
;  allocation is from track 18
;  towards 1 & 35, by full tracks
nxtts
	jsr gethdr
	lda #3
	sta temp
	lda #1          ;set no write bam
	ora wbam
	sta wbam
nxtds
nxt1
	lda temp
	pha             ;save temp
	jsr setbam
	pla
	sta temp        ;restore temp
	lda (bmpnt),y
	bne fndnxt
	lda track
	cmp dirtrk
	beq nxterr
	bcc nxt2
	inc track
	lda track
	cmp maxtrk
	bne nxt1
	ldx dirtrk
	dex
	stx track
	lda #0
	sta sector
	dec temp
	bne nxt1
nxterr	lda #dskful
	jsr cmderr
nxt2	dec track
	bne nxt1
	ldx dirtrk
	inx
	stx track
	lda #0
	sta sector
	dec temp
	bne nxt1
	beq nxterr
;
; find the next optimum sector
; next sector=current sector+n
;
fndnxt	lda sector
	clc
	adc secinc
	sta sector
	lda track
	jsr maxsec
	sta lstsec
	sta cmd
	cmp sector
	bcs fndn0
	sec
	lda sector
	sbc lstsec
	sta sector
	beq fndn0
	dec sector
fndn0
	jsr getsec
	beq fndn2
fndn1
	jmp wused
fndn2
	lda #0
	sta sector
	jsr getsec
	bne fndn1
	jmp derr
;
;
; returns optimum initial track,sector
;
intts
	lda #1
	ora wbam
	sta wbam
	lda r0
	pha             ;save temp var
;r0:= 1
	lda #1
	sta r0
its1	;track:= dirtrk-r0
	lda dirtrk
	sec
	sbc r0
	sta track
;if t>0
	bcc its2
	beq its2
;then begin
	jsr setbam      ;set the bam pointer
;if @b[.y] then goto fndsec
	lda (bmpnt),y
	bne fndsec
;end
its2	;track:= dirtrk+r0
	lda dirtrk
	clc
	adc r0
	sta track
;r0:= r0+1
	inc r0
;if track >=maxtrk then cmder2(systs)
	cmp maxtrk
	bcc its3
;
	lda #systs
	jsr cmder2
its3
	jsr setbam      ;set ptr
;if @b[.y]=0 then goto its1
	lda (bmpnt),y
	beq its1
fndsec
	pla
	sta r0          ;restore r0
	lda #0
	sta sector
	jsr getsec
	beq fnd2
	jmp wused
;
fnd2
derr
	lda #direrr
	jsr cmder2
;
;
; set bam and find available sector
; starting at sector
;
getsec
	jsr setbam
	tya
	pha             ;save .y
	jsr avck        ;check bits & count
;
	lda track
	jsr maxsec
	sta lstsec      ;save max sector #
	pla
	sta temp        ;temp:= old .y for freus3
gs10
	lda sector
	cmp lstsec
	bcs gs20
;
	jsr freus3
	bne gs30
;
	inc sector
	bne gs10        ;bra
gs20
	lda #0
gs30
	rts             ;(z=1): used
;bit map validity check
avck
	lda temp
	pha             ;save temp
	lda #0
	sta temp        ;temp:=0
;for .y:=bamsiz to 1 do;
	ldy bamsiz
	dey
ac10	;for .x:=7 to 0 do;
	ldx #7          ;count the bits
ac20	;if @b[.y] & bmask[x]
;  then temp:=temp+1
	lda (bmpnt),y
	and	bmask,x
	beq ac30
	inc temp
ac30	;end .x
	dex
	bpl ac20
;end .y
	dey
	bne ac10
;if @b[.y] <> temp
;  then cmder2(direrr);
	lda (bmpnt),y
	cmp temp
	bne ac40        ;counts do not match
;
	pla
	sta temp        ;restore temp
	rts
ac40
	lda #direrr
	jsr cmder2
; .a=track # ,returns #sectors on this track
maxsec	ldx nzones
max1	cmp trknum-1,x
	dex
	bcs max1
	lda numsec,x
	rts
;
