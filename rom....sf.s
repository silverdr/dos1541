.segment "SC000"
           ;+$300 ;rom patch
;code ;controller format code
;*=*+$3a1
cchksm	.byte 0
freec0	.res 255        ; c0 patch space
