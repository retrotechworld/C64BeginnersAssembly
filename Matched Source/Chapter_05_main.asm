!cpu 6510
* = $0801
!byte $0b,$08,$0a,$00,$9e
!text "2064"
!byte 0,0,0
* = $0810

start:
sei

ldx #0
make_shape:
lda #$ff
sta $3000,x
inx
cpx #63
bne make_shape
lda #0
sta $303f


lda #$ff
sta $d015
lda #0
sta $d010
sta $d017
sta $d01d


ldx #0
set_pointers:
lda #$c0
sta $07f8,x
inx
cpx #8
bne set_pointers

lda #0
sta phase
lda $d011
and #$7f
sta $d011
lda #40
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
tya
pha

lda $d019
and #1
beq done
lda #1
sta $d019

lda phase
bne lower_band

upper_band:

ldx #0
upper_loop:
txa
asl
tay
lda sprite_x,x
sta $d000,y
lda sprite_y,x
sta $d001,y
lda sprite_colour,x
sta $d027,x
inx
cpx #8
bne upper_loop

lda #1
sta phase
lda #145
sta $d012
jmp done

lower_band:


lda sprite_x+8
sta $d000
lda sprite_y+8
sta $d001
lda sprite_colour+8
sta $d027

lda #0
sta phase
lda #40
sta $d012

done:
pla
tay
pla
tax
pla
jmp $ea31

phase: !byte 0


sprite_x:
!byte 45,75,105,135,165,195,225,245,140
sprite_y:
!byte 70,70,70,70,100,100,100,100,180
sprite_colour:
!byte 2,3,4,5,6,7,8,9,14
