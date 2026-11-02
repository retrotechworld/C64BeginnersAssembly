!cpu 6510
* = $0801
!byte $0b,$08,$0a,$00,$9e
!text "2064"
!byte 0,0,0
* = $0810

start:
sei

ldx #0
shape:
lda #$ff
sta $3000,x
inx
cpx #63
bne shape
lda #0
sta $303f


lda #$c0
sta $07f8
lda #1
sta $d015
lda #0
sta $d010
sta $d017
sta $d01d
lda #7
sta $d027
lda #120
sta $d000
lda #120
sta $d001
cli

main_loop:
jsr wait_frame
lda #0
sta fire_flag
jsr read_joystick
jsr read_keyboard
lda fire_flag
beq no_fire
lda #2
bne set_colour
no_fire:
lda #7
set_colour:
sta $d027
jmp main_loop



wait_frame:
wait_not_250:
lda $d012
cmp #250
beq wait_not_250
wait_for_250:
lda $d012
cmp #250
bne wait_for_250
rts



read_joystick:
lda $dc00
sta joy_state
and #%00000001
bne joy_down
jsr move_up
joy_down:
lda joy_state
and #%00000010
bne joy_left
jsr move_down
joy_left:
lda joy_state
and #%00000100
bne joy_right
jsr move_left
joy_right:
lda joy_state
and #%00001000
bne joy_fire
jsr move_right
joy_fire:
lda joy_state
and #%00010000
bne joy_done
lda #1
sta fire_flag
joy_done:
rts




read_keyboard:
jsr $ffe4
cmp #'W'
bne key_s
jsr move_up
rts
key_s:
cmp #'S'
bne key_a
jsr move_down
rts
key_a:
cmp #'A'
bne key_d
jsr move_left
rts
key_d:
cmp #'D'
bne key_space
jsr move_right
rts
key_space:
cmp #32
bne key_done
lda #1
sta fire_flag
key_done:
rts


move_left:
lda $d000
cmp #24
beq left_done
dec $d000
left_done:
rts
move_right:
lda $d000
cmp #240
beq right_done
inc $d000
right_done:
rts
move_up:
lda $d001
cmp #50
beq up_done
dec $d001
up_done:
rts
move_down:
lda $d001
cmp #229
beq down_done
inc $d001
down_done:
rts

joy_state: !byte 0
fire_flag: !byte 0
