;
drvst	*=*+2
drvtrk	*=*+2
stab	*=*+10
;    variables
;
; pointers
savpnt	*=*+2
bufpnt	*=*+2
hdrpnt	*=*+2
;
;
gcrpnt	*=*+1
gcrerr	*=*+1           ; indicates gcr decode error
bytcnt	*=*+1
bitcnt	*=*+1
bid	*=*+1
hbid	*=*+1
chksum	*=*+1
hinib	*=*+1
byte	*=*+1
drive	*=*+1
cdrive	*=*+1
jobn	*=*+1
tracc	*=*+1
nxtjob	*=*+1
nxtrk	*=*+1
sectr	*=*+1
work	*=*+1
job	*=*+1
ctrack	*=*+1
dbid	*=*+1           ; data block id
acltim	*=*+1           ; acel time delay
savsp	*=*+1           ; save stack pointer
steps	*=*+1           ; steps to desired track
tmp	*=*+1
csect	*=*+1
nexts	*=*+1
nxtbf	*=*+1           ; pointer at next gcr source buffer
nxtpnt	*=*+1           ; and next gcr byte location in buffer
gcrflg	*=*+1           ; buffer in gcr image
ftnum	*=*+1           ; current format track
btab	*=*+4
gtab	*=*+8
;
as	*=*+1           ; # of steps to acel
af	*=*+1           ; acel. factor
aclstp	*=*+1           ; steps to go
rsteps	*=*+1           ; # of run steps
nxtst	*=*+2
minstp	*=*+1           ; min reqired to acel
;
;
;
;  constants
;
ovrbuf	=$0100          ; top of stack
numjob	=6 ; number of jobs
jmpc	=$50            ; jump command
bumpc	=$40            ; bump command
execd	=$60            ; execute command
bufs	=$0300          ; start of buffers
buff0	=bufs
buff1	=bufs+$100
buff2	=bufs+$200
tolong	=$2             ; format errors
tomany	=$3
tobig	=$4
tosmal	=$5
notfnd	=$6
skip2	=$2c            ; bit abs
toprd	=69             ; top of read overflo buffer on a read
topwrt	=69             ; top of write overflo buffer on a write
numsyn	= 5             ; gcr byte count for size of sync area
gap1	= 10            ; gap after header to  clear erase in gcr bytes
gap2	= 4             ; gap after data block min size
rdmax	= 6             ; sector distance wait
wrtmin	= 9
wrtmax	= 12
tim	=58             ;irq rate for 15ms
;
;
;
;
;
;
