!cpu 6510
* = $0801
!byte $0b,$08,$0a,$00,$9e
!text "2064"
!byte 0,0,0
* = $0810

start:
lda #20
sta player
lda #30
sta target
lda #0
sta score
main:

not_line:
lda $d012
cmp #250
beq not_line
on_line:
lda $d012
cmp #250
bne on_line


lda $dc00
and #4
bne check_right
dec player
check_right:
lda $dc00
and #8
bne draw
inc player
draw:
ldx player
lda #1
sta $0400,x
cpx target
bne main
inc score
inc $d020
jmp main
player: !byte 20
target: !byte 30
score: !byte 0
