!cpu 6510

* = $0801
!byte $0b,$08,$0a,$00,$9e
!text "2064"
!byte 0,0,0
* = $0810
start:
sei

lda #$80
sta $07f8
lda #1
sta $d027
lda #120
sta $d000
lda #120
sta $d001
lda $d010
and #%11111110
sta $d010
lda $d015
ora #1
sta $d015
lda #120
sta xpos

lda $d011
and #%01111111
sta $d011
lda #100
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
txa
pha
lda $d019
and #1
beq irq_exit
lda #1
sta $d019

inc xpos
lda xpos
cmp #240
bcc move_sprite
lda #40
sta xpos
move_sprite:
sta $d000
irq_exit:
pla
tax
pla
jmp $ea31
xpos: !byte 120

* = $2000
sprite_data:
!fill 63,$ff
!byte 0
