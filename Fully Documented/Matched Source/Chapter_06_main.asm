!cpu 6510

* = $0801
!byte $0b,$08,$0a,$00,$9e
!text "2064"
!byte 0,0,0
* = $0810

start:
sei

ldx #0
fill_sprite:
lda #$ff
sta $3000,x
inx
cpx #63
bne fill_sprite
lda #0
sta $303f


lda #0
sta $d010
sta $d017
sta $d01d
lda #$ff
sta $d015

ldx #0
set_pointers:
lda #$c0
sta $07f8,x
inx
cpx #8
bne set_pointers

jsr sort_by_y
lda #0
sta phase
lda $d011
and #$7f
sta $d011
lda #40
sta $d012
lda #1
sta $d019
lda #<irq
sta $0314
lda #>irq
sta $0315
lda $d01a
ora #1
sta $d01a
cli
rts


sort_by_y:
ldx #0
init_order:
txa
sta order,x
inx
cpx #10
bne init_order

lda #9
sta passes
sort_pass:
ldx #0
compare_pair:
ldy order,x
lda sprite_y,y
sta first_y
ldy order+1,x
lda sprite_y,y
cmp first_y
bcs already_sorted


lda order,x
sta order+1,x
tya
sta order,x
already_sorted:
inx
cpx passes
bne compare_pair
dec passes
bne sort_pass
rts

irq:
pha
txa
pha
tya
pha
lda $d019
and #1
bne raster_pending
jmp irq_exit
raster_pending:
lda #1
sta $d019
lda phase
bne lower

upper:

ldx #0
upper_loop:
ldy order,x
lda sprite_x,y
sta value_x
lda sprite_y,y
sta value_y
lda sprite_color,y
sta value_color

txa
asl
tay
lda value_x
sta $d000,y
lda value_y
sta $d001,y
lda value_color
sta $d027,x

inx
cpx #8
bne upper_loop

lda #1
sta phase
lda #145
sta $d012
jmp irq_exit

lower:

ldx #0
lower_loop:
ldy order+8,x
lda sprite_x,y
sta value_x
lda sprite_y,y
sta value_y
lda sprite_color,y
sta value_color

txa
asl
tay
lda value_x
sta $d000,y
lda value_y
sta $d001,y
lda value_color
sta $d027,x

inx
cpx #2
bne lower_loop

lda #0
sta phase
lda #40
sta $d012

irq_exit:
pla
tay
pla
tax
pla
jmp $ea31

phase: !byte 0
passes: !byte 0
first_y: !byte 0
value_x: !byte 0
value_y: !byte 0
value_color: !byte 0
order: !fill 10,0


sprite_x:
!byte 55,65,85,110,135,160,185,210,235,125
sprite_y:
!byte 200,72,188,103,85,209,96,78,192,110
sprite_color:
!byte 2,3,4,5,6,7,8,9,10,14
