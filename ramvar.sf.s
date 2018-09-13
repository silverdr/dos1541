;permanent address variables
;
	*=zp2
;
vnmi	*=*+2           ;indirect for nmi
nmiflg	*=*+1
autofg	*=*+1
secinc	*=*+1           ;sector inc for seq
revcnt	*=*+1           ; error recovery count
;bufs	= $300          ; start of data bufs
fbufs	= bufs          ;format download image
;*
;*********************************
;*
;*      zero page variables
;*
;*********************************
;*
usrjmp	*=*+2           ; user jmp table ptr
bmpnt	*=*+2           ; bit map pointer
temp	*=*+6           ; temp work space
ip	*=*+2           ; indirect ptr variable
lsnadr	*=*+1           ; listen address
tlkadr	*=*+1           ;talker address
lsnact	*=*+1           ; active listener flag
tlkact	*=*+1           ; active talker flag 
adrsed	*=*+1           ; addressed flag
atnpnd	*=*+1           ;attention pending flag
atnmod	*=*+1           ;in atn mode
prgtrk	*=*+1           ;last prog accessed
drvnum	*=*+1           ;current drive #
track	*=*+1           ;current track
sector	*=*+1           ;current sector
lindx	*=*+1           ;logical index
sa	*=*+1           ;secondary address
orgsa	*=*+1           ;original sa
data	*=*+1           ; temp data byte
;*
;*
t0	=temp
t1	=temp+1
t2	=temp+2
t3	=temp+3
t4	=temp+4
r0	*=*+1
r1	*=*+1
r2	*=*+1
r3	*=*+1
r4	*=*+1
result	*=*+4
accum	*=*+5
dirbuf	*=*+2
icmd	*=*+1           ;ieee cmd in
mypa	*=*+1           ; my pa flag
cont	*=*+1           ; bit counter for ser
;*
;*********************
;*
;*  zero page array
;*
;***********************
;*
buftab	*=*+cbptr+4     ; buffer byte pointers
cb=buftab+cbptr
buf0	*=*+mxchns+1
buf1	*=*+mxchns+1
nbkl
recl	*=*+mxchns
nbkh
rech	*=*+mxchns
nr	*=*+mxchns
rs	*=*+mxchns
ss	*=*+mxchns
f1ptr	*=*+1           ; file stream 1 pointer
;
;***********************
; $4300 vars moved to zp
;
recptr	*=*+1
ssnum	*=*+1
ssind	*=*+1
relptr	*=*+1
entsec	*=*+mxfils      ; sector of directory entry
entind	*=*+mxfils      ; index of directory entry
fildrv	*=*+mxfils      ; default flag, drive #
pattyp	*=*+mxfils      ; pattern,replace,closed-flags,type
filtyp	*=*+mxchns      ; channel file type
chnrdy	*=*+mxchns      ; channel status
eoiflg	*=*+1           ; temp eoi
jobnum	*=*+1           ; current job #
lrutbl	*=*+mxchns-1    ;least recently used table
nodrv	*=*+2           ; no drive flag
dskver	*=*+2           ; disk version from 18.0
zpend=*
	*=$200
cmdbuf	*=*+cmdlen+1
cmdnum	*=*+1           ; command #
lintab	*=*+maxsa+1     ; sa:lindx table
chndat	*=*+mxchns      ; channel data byte
lstchr	*=*+mxchns      ; channel last char ptr
type	*=*+1           ; active file type
;
;*
;*******************
;*
;* ram variables in $4300
;*
;*******************
;*
;  *=$4300
strsiz	*=*+1
;zp:  recptr *=*+1
;zp:  ssnum  *=*+1
;zp:  ssind  *=*+1
;zp:  relptr *=*+1
tempsa	*=*+1           ; temporary sa
;zp:  eoiflg *=*+1           ; temp eoi
cmd	*=*+1           ; temp job command
lstsec	*=*+1           ; 
bufuse	*=*+2           ; buffer allocation
;zp:  jobnum *=*+1           ; current job #
mdirty	*=*+2           ;bam 0 & 1 dirty flags
entfnd	*=*+1           ;dir-entry found flag
dirlst	*=*+1           ;dir listing flag
cmdwat	*=*+1           ;command waiting flag
linuse	*=*+1           ;lindx use word
lbused	*=*+1           ;last buffer used
rec	*=*+1
trkss	*=*+1
secss	*=*+1
;*
;********************************
;*
;*  ram array area
;*
;********************************
;*
lstjob	*=*+bfcnt       ; last job
;zp:  lintab *=*+maxsa+1     ; sa:lindx table
;zp:  chndat *=*+mxchns      ; channel data byte
dsec	*=*+mxchns      ; sector of directory entry
dind	*=*+mxchns      ; index of directory entry
erword	*=*+1           ; error word for recovery
erled	*=*+1           ; error led mask for flashing
prgdrv	*=*+1           ; last program drive
prgsec	*=*+1           ; last program sector
wlindx	*=*+1           ; write lindx
rlindx	*=*+1           ; read lindx
nbtemp	*=*+2           ; # blocks temp
cmdsiz	*=*+1           ; command string size
char	*=*+1           ; char under parser
limit	*=*+1           ; ptr limit in compar
f1cnt	*=*+1           ; file stream 1 count
f2cnt	*=*+1           ; file stream 2 count
f2ptr	*=*+1           ; file stream 2 pointer
;  parser tables
filtbl	*=*+mxfils+1    ; filename pointer
;zp:   filent *=*+mxfils      ; directory entry
;zp:   fildat *=*+mxfils      ; drive #, pattern
filtrk	*=*+mxfils      ; 1st link/track
filsec	*=*+mxfils      ;         /sector
;  channel tables
;zp:  filtyp *=*+mxchns ; channel file type
;zp:  chnrdy *=*+mxchns      ; channel status
;zp:   lstchr *=*+mxchns      ; channel last char ptr
patflg	*=*+1           ; pattern presence flag
image	*=*+1           ; file stream image
drvcnt	*=*+1           ; number of drv searches
drvflg	*=*+1           ; drive search flag
lstdrv	*=*+1           ; last drive w/o error
found	*=*+1           ; found flag in dir searches
dirsec	*=*+1           ; directory sector
delsec	*=*+1           ; sector of 1st avail entry
delind	*=*+1           ; index  "
lstbuf	*=*+1           ; =0 if last block
index	*=*+1           ; current index in buffer
filcnt	*=*+1           ; counter, file entries
typflg	*=*+1           ; match by type flag
mode	*=*+1           ; active file mode (r,w)
;zp:  type   *=*+1           ; active file type
jobrtn	*=*+1           ;job return flag
eptr	*=*+1           ;ptr for recovery
toff	*=*+1           ;total track offset
ubam	*=*+2           ; last bam update ptr
tbam	*=*+4           ; track # of bam image
bam	*=*+16          ; bam images
;*
;*****************************************
;*
;*   output buffers
;*
;********************************************
;*
;    *=$4400-36-36
nambuf	*=*+36          ; directory buffer
errbuf	*=*+36          ; error msg buffer
wbam	*=*+1           ; don't-write-bam flag
ndbl	*=*+2           ; # of disk blocks free
ndbh	*=*+2
phase	*=*+2
ramend=*
