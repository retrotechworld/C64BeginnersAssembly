!cpu 6510
* = $0801
!byte $0b,$08,$0a,$00,$9e
!text "2064"
!byte 0,0,0
* = $0810

start:
lda #0
sta index
main:

wait_out:
lda $d012
cmp #250
beq wait_out
wait_in:
lda $d012
cmp #250
bne wait_in
ldx index
lda palette,x
sta $d020
sta $d021
lda #1
sta $0400,x
inx
cpx #8
bne keep
ldx #0
keep:
stx index
jmp main
index: !byte 0
palette: !byte 2,8,7,5,3,6,14,1
