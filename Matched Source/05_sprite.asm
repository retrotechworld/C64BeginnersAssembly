!cpu 6510
* = $0801
!byte $0b,$08,$0a,$00,$9e
!text "2064"
!byte 0,0,0
* = $0810
start:
sei
cld
lda #0
sta $d015
sta $d010
sta $d017
sta $d01d
sta $d01c
sta $d01b
lda #$14
sta $d018
lda #$1b
sta $d011
lda #$c8
sta $d016
lda #$c0
sta $07f8
lda #1
sta $d027
sta $d015
lda #120
sta xpos
sta $d000
sta $d001
main:
jsr wait_frame
inc xpos
lda xpos
cmp #240
bcc draw
lda #40
sta xpos
draw:
sta $d000
jmp main
wait_frame:
wait_in:
lda $d012
cmp #250
bne wait_in
wait_out:
lda $d012
cmp #250
beq wait_out
rts
xpos: !byte 120
* = $3000
!fill 63,$ff
!byte 0
