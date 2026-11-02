!cpu 6510
* = $0801
!byte $0b,$08,$0a,$00,$9e
!text "2064"
!byte 0,0,0
* = $0810
start:
ldx #0
copy:
lda message,x
sta $0400,x
lda #1
sta $d800,x
inx
cpx #5
bne copy
rts
message: !byte 8,5,12,12,15
