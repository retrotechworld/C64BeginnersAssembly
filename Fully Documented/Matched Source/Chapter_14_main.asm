!cpu 6510
* = $0801
!byte $0b,$08,$0a,$00,$9e
!text "2064"
!byte 0,0,0
* = $0810

start:
lda #0
sta tick
main:

wait_not_250:
lda $d012
cmp #250
beq wait_not_250
wait_250:
lda $d012
cmp #250
bne wait_250
inc tick
lda tick
and #15
sta $d020
jmp main
tick: !byte 0
