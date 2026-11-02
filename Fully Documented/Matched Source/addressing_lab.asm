!cpu 6510
* = $0801
!byte $0b,$08,$0a,$00,$9e
!text "2064"
!byte 0,0,0
* = $0810
start:
cld
lda $fb
sta saved_fb
lda $fc
sta saved_fc
lda $fd
sta saved_fd
ldx #8
ink_loop:
lda #1
sta $d800,x
dex
bpl ink_loop
lda #1
sta $0400
ldx #1
lda values,x
sta $0401
ldy #2
lda values,y
sta $0402
lda #4
sta $fd
lda $fd
sta $0403
ldx #1
lda $fc,x
sta $0404
lda #<values
sta $fb
lda #>values
sta $fc
ldy #3
lda ($fb),y
sta $0405
ldx #1
lda ($fa,x)
sta $0406
lda #3
asl
sta $0407
cmp #6
beq matched
lda #0
jmp result
matched:
lda #7
result:
sta $0408
jmp (cleanup_vector)
cleanup:
lda saved_fb
sta $fb
lda saved_fc
sta $fc
lda saved_fd
sta $fd
rts
values: !byte 1,2,3,4
saved_fb: !byte 0
saved_fc: !byte 0
saved_fd: !byte 0
cleanup_vector: !word cleanup
