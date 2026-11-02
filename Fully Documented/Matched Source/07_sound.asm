!cpu 6510
* = $0801
!byte $0b,$08,$0a,$00,$9e
!text "2064"
!byte 0,0,0
* = $0810
start:
lda #0
sta $d404
lda #15
sta $d418
lda #$12
sta $d405
lda #$f8
sta $d406
lda #$00
sta $d400
lda #$20
sta $d401
lda #$21
sta $d404
rts
