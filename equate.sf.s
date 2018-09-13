;******************************
;*  equates
;******************************
;
rom	=$c000          ;first rom address
;
lrf	=$80            ;last record flag
dyfile	=$40            ;dirty flag for rr file
ovrflo	=$20            ;rr print overflow
nssl	=6 ;# of side-sector links
ssioff	=4+nssl+nssl    ;offset into ss for data block ptrs
nssp	=120            ;# of ptrs in ss
mxchns	=6 ;max # channels in system
maxsa	=18             ;max sa # +1
vererr	=7 ;controller verify error
cr	=$0d            ; carriage return
bfcnt	=5 ;available  buffer count
cbptr	=bfcnt+bfcnt    ;command buffer ptr
errchn	=mxchns-1       ;error channel #
errsa	=16             ;error channel sa #
cmdchn	=mxchns-2       ;command channel #
lxint	=%00001111      ;power up linuse (logical index usage
blindx	=6 ;bam lindx for floating bams
cmdsa	=15             ;command channel sa #
apmode	=2 ;open append mode
mdmode	=3 ;open modify mode
rdmode	=0 ;open read mode
wtmode	=1 ;open write mode
reltyp	=4 ;open relative type
dirtyp	=7 ;open direct type
seqtyp	=1 ;open sequential type
prgtyp	=2 ;open program type
usrtyp	=3 ;open user type
typmsk	=7 ;mask for type bits
irsa	=17             ;internal read sa #
iwsa	=18             ;internal write sa #
dosver	=2 ;dos version
fm2030	=$42            ;2030 format version
fm4040	=$41            ;4040 format version
;controller job types
read	=$80
write	=$90
wverfy	=$a0
seek	=$b0
secsek	=seek+8
bump	=$c0
jumpc	=$d0
exec	=$e0
mxfils	=5 ; max # filenames in string
dirlen	=24             ;directory length used
nbsiz	=27             ;nambuf text size
cmdlen	=41             ;length of command buffer
