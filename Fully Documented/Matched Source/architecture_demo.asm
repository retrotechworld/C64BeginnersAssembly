!cpu 6510
* = $0801
!byte $0b,$08,$0a,$00,$9e
!text "2064"
!byte 0,0,0
* = $0810
start:
    lda #2
    sta $d020
    lda #1
    sta $0400
    sta $d800
    rts
