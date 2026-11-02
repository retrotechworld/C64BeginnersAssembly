!cpu 6510

* = $0801
!byte $0b,$08,$0a,$00,$9e
!text "2064"
!byte 0,0,0
* = $0810
start:
sei


lda #0
sta $d015
sta $d010
sta $d017
sta $d01d
sta $d01c

ldx #0
setup_pointers:
lda #$c0
sta $07f8,x
lda #1
sta $d027,x
inx
cpx #8
bne setup_pointers

ldx #0
ldy #0
setup_positions:
lda initial_x,y
sta $d000,x
lda #70
sta $d001,x
inx
inx
iny
cpy #8
bne setup_positions
lda #$ff
sta $d015
lda #0
sta phase

lda $d011
and #%01111111
sta $d011
lda #130
sta $d012
lda #1
sta $d019
lda #<irq_handler
sta $0314
lda #>irq_handler
sta $0315
lda $d01a
ora #1
sta $d01a
cli
rts
irq_handler:
pha
lda $d019
and #1
beq irq_exit
lda #1
sta $d019
lda phase
bne restore_top
move_down:
lda #160
sta $d000
lda #170
sta $d001
lda #2
sta $d027
lda #250
sta $d012
lda #1
sta phase
jmp irq_exit
restore_top:
lda #40
sta $d000
lda #70
sta $d001
lda #1
sta $d027
lda #130
sta $d012
lda #0
sta phase
irq_exit:
pla
jmp $ea31
phase:
!byte 0
initial_x:
!byte 40,64,88,112,136,160,184,208

* = $3000
!fill 64,$ff
