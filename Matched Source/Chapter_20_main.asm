!cpu 6510
* = $0801
!byte $0b,$08,$0a,$00,$9e
!text "2064"
!byte 0,0,0
* = $0810

start:
ldx #0
loop:
lda values,x
asl
clc
adc values,x
sta $0400,x
inx
cpx #8
bne loop
rts
values:
!byte 1,2,3,4,5,6,7,8
