!cpu 6510
* = $0801
!byte $0b,$08,$0a,$00,$9e
!text "2064"
!byte 0,0,0
* = $0810

start:
lda #32
sta player_x
lda #35
sta target_x
jsr check_hit
lda hit
beq no_hit
lda #2
sta $d020
rts
no_hit:
lda #6
sta $d020
rts


check_hit:
lda #0
sta hit
lda player_x
sec
sbc target_x
bcs positive
eor #$ff
clc
adc #1
positive:
cmp #8
bcs finished
lda #1
sta hit
finished:
rts
player_x: !byte 0
target_x: !byte 0
hit: !byte 0
