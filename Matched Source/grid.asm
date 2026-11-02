


!cpu 6510
* = $0801
!byte $0b,$08,$0a,$00,$9e
!text "2064"
!byte 0,0,0
* = $0810
start:
sei
cld
lda #$7f
sta $dc0d
sta $dd0d
lda $dc0d
lda $dd0d
lda #0
sta $d01a
sta $d015
lda #$0f
sta $d019

lda $dd02
ora #3
sta $dd02
lda $dd00
ora #3
sta $dd00

lda #0
sta $dc02
sta scroll_x
sta scroll_y
sta $d020
sta $d021

lda #$10
sta control_y
sta $d011
lda #$00
sta control_x
sta $d016

lda #$18
sta $d018
jsr setup_custom_chars
jsr init_screen
main_loop:
jsr wait_frame
jsr read_joystick
jsr update_scroll
jmp main_loop
wait_frame:
.wait_in:
lda $d012
cmp #250
bne .wait_in
.wait_out:
lda $d012
cmp #250
beq .wait_out
rts
setup_custom_chars:

ldx #7
.copy:
lda tile,x
sta $2008,x
dex
bpl .copy
rts
init_screen:
ldx #0
.fill:
lda #1
sta $0400,x
sta $0500,x
sta $0600,x
lda #2
sta $d800,x
sta $d900,x
sta $da00,x
inx
bne .fill
ldx #0
.tail:
lda #1
sta $0700,x
lda #2
sta $db00,x
inx
cpx #232
bne .tail
rts
read_joystick:
lda $dc00
and #1
bne .not_up
dec scroll_y
.not_up:
lda $dc00
and #2
bne .not_down
inc scroll_y
.not_down:
lda $dc00
and #4
bne .not_left
dec scroll_x
.not_left:
lda $dc00
and #8
bne .not_right
inc scroll_x
.not_right:
lda scroll_x
and #7
sta scroll_x
lda scroll_y
and #7
sta scroll_y
rts
update_scroll:
lda control_x
ora scroll_x
sta $d016
lda control_y
ora scroll_y
sta $d011
rts
scroll_x: !byte 0
scroll_y: !byte 0
control_x: !byte 0
control_y: !byte 0
tile: !byte $18,$18,$18,$ff,$18,$18,$18,$18
