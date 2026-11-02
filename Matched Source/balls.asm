
















SCREEN = $0400
SPR_PTR = $07f8
SPR_X = $d000
SPR_Y = $d001
SPR_X_MSB = $d010
SPR_ENABLE = $d015
RASTER = $d012
IRQ_STATUS = $d019
IRQ_ENABLE = $d01a


* = $0801
!byte $0b,$08,$0a,$00,$9e
!text "2064"
!byte $00,$00,$00

* = $0810
start:
sei

lda #$00
sta $d020
sta $d021
jsr $e544

ldx #$00
title_loop:
lda title_text,x
beq title_done
sta SCREEN+40,x
inx
bne title_loop
title_done:



ldx #$00
pointer_loop:
lda #$c0
sta SPR_PTR,x
inx
cpx #$04
bne pointer_loop

lda #%00001111
sta SPR_ENABLE
lda #$00
sta $d01d
sta $d017
sta $d01b
sta $d01c


ldx #$00
initial_phases:
txa
asl
asl
asl
asl
clc
adc #$09
sta phase,x
inx
cpx #12
bne initial_phases


lda #$7f
sta $dc0d
sta $dd0d
lda $dc0d
lda $dd0d


lda #<irq
sta $0314
lda #>irq
sta $0315

lda #$1b
sta $d011
lda #$01
sta IRQ_STATUS
sta IRQ_ENABLE
lda #45
sta RASTER
lda #0
sta irq_stage
cli

main_loop:
jmp main_loop






irq:
lda #$01
sta IRQ_STATUS

lda irq_stage
beq show_group_zero
cmp #$01
beq show_group_one
cmp #$02
beq show_group_two
jmp frame_update

show_group_zero:
ldx #0
jsr draw_group
lda #115
sta RASTER
lda #1
sta irq_stage
jmp $ea81

show_group_one:
ldx #4
jsr draw_group
lda #181
sta RASTER
lda #2
sta irq_stage
jmp $ea81

show_group_two:
ldx #8
jsr draw_group
lda #250
sta RASTER
lda #3
sta irq_stage
jmp $ea81

frame_update:
jsr move_balls
lda #45
sta RASTER
lda #0
sta irq_stage
jmp $ea81











draw_group:
lda #0
sta msb_bits
ldy #0
draw_one:
stx logical_index
sty sprite_index


lda phase,x
tax
lda wave,x
sec
sbc #12
sta wobble

ldx logical_index
lda base_x_lo,x
clc
adc wobble
sta temp_x_lo
lda base_x_hi,x
ldy wobble
bmi negative_wobble
adc #0
jmp x_high_done
negative_wobble:
adc #$ff
x_high_done:
sta temp_x_hi


ldy sprite_index
tya
asl
tay
lda temp_x_lo
sta SPR_X,y


lda temp_x_hi
beq no_high_x
ldy sprite_index
lda msb_bits
ora bit_masks,y
sta msb_bits
no_high_x:


ldx logical_index
lda phase,x
clc
adc #64
tax
lda wave,x
lsr
ldx logical_index
clc
adc group_y,x
sta temp_y


ldy sprite_index
tya
asl
tay
lda temp_y
sta SPR_Y,y


ldx logical_index
lda ball_colours,x
ldy sprite_index
sta $d027,y

inc sprite_index
ldy sprite_index
ldx logical_index
inx
cpy #4
beq group_complete
jmp draw_one
group_complete:
lda msb_bits
sta SPR_X_MSB
rts







move_balls:
ldx #0
move_next:
lda phase,x
clc
adc phase_speed,x
sta phase,x

lda direction,x
bne move_left

move_right:
clc
lda base_x_lo,x
adc speed,x
sta base_x_lo,x
lda base_x_hi,x
adc #0
sta base_x_hi,x


cmp #$01
bcc move_done
lda base_x_lo,x
cmp #$1c
bcc move_done
lda #1
sta direction,x
jmp move_done

move_left:
sec
lda base_x_lo,x
sbc speed,x
sta base_x_lo,x
lda base_x_hi,x
sbc #0
sta base_x_hi,x


lda base_x_hi,x
bne move_done
lda base_x_lo,x
cmp #$31
bcs move_done
lda #0
sta direction,x

move_done:
inx
cpx #12
bne move_next
rts







irq_stage: !byte 0
logical_index: !byte 0
sprite_index: !byte 0
msb_bits: !byte 0
wobble: !byte 0
temp_x_lo: !byte 0
temp_x_hi: !byte 0
temp_y: !byte 0

base_x_lo: !byte 48,105,165,225, 65,125,185,245, 48,110,175,240
base_x_hi: !fill 12,0
direction: !byte 0,1,0,1, 1,0,1,0, 0,1,0,1
speed: !byte 1,2,1,2, 2,1,2,1, 1,2,2,1
phase: !fill 12,0
phase_speed: !byte 2,3,4,3, 3,4,2,4, 4,2,3,2
group_y: !byte 62,62,62,62, 128,128,128,128, 194,194,194,194
ball_colours: !byte 1,2,3,7, 5,6,10,13, 4,8,9,14
bit_masks: !byte 1,2,4,8



title_text:
!byte $31,$32,$20,$02,$01,$0c,$0c,$13,$20,$2f,$20,$34
!byte $20,$13,$10,$12,$09,$14,$05,$13,$20,$2d,$20,$12
!byte $01,$13,$14,$05,$12,$20,$0d,$15,$0c,$14,$09,$10
!byte $0c,$05,$18
!byte 0




wave:
!byte 12,12,13,13,13,13,14,14,14,15,15,15,15,16,16,16
!byte 17,17,17,17,18,18,18,18,19,19,19,19,20,20,20,20
!byte 20,21,21,21,21,21,22,22,22,22,22,22,23,23,23,23
!byte 23,23,23,23,23,24,24,24,24,24,24,24,24,24,24,24
!byte 24,24,24,24,24,24,24,24,24,24,24,24,23,23,23,23
!byte 23,23,23,23,23,22,22,22,22,22,22,21,21,21,21,21
!byte 20,20,20,20,20,19,19,19,19,18,18,18,18,17,17,17
!byte 17,16,16,16,15,15,15,15,14,14,14,13,13,13,13,12
!byte 12,12,11,11,11,11,10,10,10,9,9,9,9,8,8,8
!byte 7,7,7,7,6,6,6,6,5,5,5,5,4,4,4,4
!byte 4,3,3,3,3,3,2,2,2,2,2,2,1,1,1,1
!byte 1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0
!byte 0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1
!byte 1,1,1,1,1,2,2,2,2,2,2,3,3,3,3,3
!byte 4,4,4,4,4,5,5,5,5,6,6,6,6,7,7,7
!byte 7,8,8,8,9,9,9,9,10,10,10,11,11,11,11,12






* = $3000
ball_sprite:
!byte $00,$00,$00
!byte $00,$7e,$00
!byte $01,$ff,$80
!byte $07,$ff,$e0
!byte $0f,$ff,$f0
!byte $1f,$ff,$f8
!byte $1f,$ff,$f8
!byte $3f,$ff,$fc
!byte $3f,$ff,$fc
!byte $3f,$ff,$fc
!byte $3f,$ff,$fc
!byte $3f,$ff,$fc
!byte $3f,$ff,$fc
!byte $3f,$ff,$fc
!byte $1f,$ff,$f8
!byte $1f,$ff,$f8
!byte $0f,$ff,$f0
!byte $07,$ff,$e0
!byte $01,$ff,$80
!byte $00,$7e,$00
!byte $00,$00,$00
!byte $00
