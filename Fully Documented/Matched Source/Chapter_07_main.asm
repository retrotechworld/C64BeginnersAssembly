!cpu 6510
* = $0801
!byte $0b,$08,$0a,$00,$9e
!text "2064"
!byte 0,0,0
* = $0810

start:
sei

ldx #0
shape_loop:
lda #$ff
sta $3000,x
inx
cpx #63
bne shape_loop
lda #0
sta $303f


lda #$ff
sta $d015
lda #0
sta $d017
sta $d01d
sta $d010

ldx #0
pointer_loop:
lda #$c0
sta $07f8,x
inx
cpx #8
bne pointer_loop

jsr sort_y
lda #0
sta phase
sta frame_counter

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



sort_y:
ldx #0
sort_init:
txa
sta order,x
inx
cpx #12
bne sort_init
lda #11
sta pass_limit
sort_pass:
ldx #0
sort_pair:
ldy order,x
lda sprite_y,y
sta temp_y
ldy order+1,x
lda sprite_y,y
cmp temp_y
bcs no_swap
lda order,x
sta order+1,x
tya
sta order,x
no_swap:
inx
cpx pass_limit
bne sort_pair
dec pass_limit
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
beq irq_exit
lda #1
sta $d019
lda phase
bne lower_band

upper_band:

inc frame_counter
ldx #0
animate_loop:
inc sprite_x,x
inx
cpx #12
bne animate_loop


ldx #0
upper_loop:
ldy order,x
jsr load_object
jsr set_channel
inx
cpx #8
bne upper_loop

lda #1
sta phase
lda #155
sta $d012
jmp irq_exit

lower_band:


ldx #0
lower_loop:
ldy order+8,x
jsr load_object
jsr set_channel
inx
cpx #4
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



load_object:
lda sprite_x,y
sta obj_x
lda sprite_y,y
sta obj_y
lda sprite_color,y
sta obj_color
rts



set_channel:
txa
asl
tay
lda obj_x
sta $d000,y
lda obj_y
sta $d001,y
lda obj_color
sta $d027,x
rts

phase: !byte 0
frame_counter: !byte 0
pass_limit: !byte 0
temp_y: !byte 0
obj_x: !byte 0
obj_y: !byte 0
obj_color: !byte 0
order: !fill 12,0




sprite_x:
!byte 40,65,90,115,140,165
!byte 190,215,60,110,160,210
sprite_y:
!byte 200,70,190,100,80,215
!byte 90,110,185,65,95,105
sprite_color:
!byte 2,3,4,5,6,7,8,9,10,11,14,1
