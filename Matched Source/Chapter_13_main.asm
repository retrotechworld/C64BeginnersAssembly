!cpu 6510
* = $0801
!byte $0b,$08,$0a,$00,$9e
!text "2064"
!byte 0,0,0
* = $0810

start:
lda #0
sta $d418
sta $d404
lda #$11
sta $d405
lda #$f3
sta $d406
lda #$00
sta $d400
lda #$20
sta $d401
lda #15
sta $d418
lda #%00100001
sta $d404
ldx #0
outer:
ldy #0
inner:
dey
bne inner
dex
bne outer
lda #%00100000
sta $d404
rts
