.page 'i/odef.sf'
;*****************************
;*      i/o definitions      *
;*****************************
;
unlsn	=$3f            ; ieee unlisten command
untlk	=$5f            ; ieee untalk command
notrdy	=$0             ; not ready
talker	=$80            ; ieee talker flag
lisner	=1 ; ieee listener flag
eoiout	=$80            ; talk with eoi
eoisnd	=$08            ; not(eoi) to send
eoi	=$08            ; not(eoi) to send
rdytlk	=$88            ; talk no eoi
rdylst	=$1             ; ready to listen
rndrdy	=rdytlk+rdylst  ; random chnrdy
rndeoi	=eoiout+rdylst  ; random w/ eoi
.ski 3
;i/o registers
.skip
; mos 6522-a
.ski
	* =$1800
;ieee control port
pb	*=*+1           ; serial port
pa1	*=*+1           ; unused port
ddrb1	*=*+1
ddra1	*=*+1           ;ieee data dir
t1lc1	*=*+1           ; timer 1 low counter
t1hc1	*=*+1           ; timer 1 hi counter
t1ll1	*=*+1           ; timer 1 low latch
t1hl1	*=*+1           ; timer 1 hi latch
t2lc1	*=*+1           ; timer 2 low counter
t2hc1	*=*+1           ; timer 2 hi counter
sr1	*=*+1           ; shift reg
acr1	*=*+1           ; aux control reg
pcr1	*=*+1
ifr1	*=*+1
ier1	*=*+1
;
;
;
;  bits for serial handshake
;
datin	=$1             ;data in line
datout	=$2             ; data out
clkin	=$4             ;clock in
clkout	=$8             ;clock out
atna	=$10            ;atna ack
atn	=$80            ; atn in
;
;
led0	=8 ; act led
led1	=0 ; no led
ledprt=$1c00  ; on pb of $1c00
ledout=$1c02 ; ddrb  of $1c00 for output-led
;
;
.end