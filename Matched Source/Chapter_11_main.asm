!cpu 6510
* = $0801
!byte $0b,$08,$0a,$00,$9e
!text "2064"
!byte 0,0,0
* = $0810

start:
lda $d016
and #%11111000
sta base_ctrl
lda #7
sta fine_x
main:
lda $d012
wait_low:
cmp $d012
beq wait_low
lda fine_x
ora base_ctrl
sta $d016
dec fine_x
bpl main
lda #7
sta fine_x
jmp main
base_ctrl: !byte 0
fine_x: !byte 7
