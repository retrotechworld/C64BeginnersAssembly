!cpu 6510
* = $0801
!byte $0b,$08,$0a,$00,$9e
!text "2064"
!byte 0,0,0
* = $0810
start:
lda #$93
jsr $ffd2
ldx #0
.loop:
lda text,x
beq .done
stx saved_x
jsr $ffd2
ldx saved_x
inx
bne .loop
.done:
rts
saved_x: !byte 0
text: !pet "hello, c64!",13,0
