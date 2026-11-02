!cpu 6510
* = $0801
!byte $0b,$08,$0a,$00,$9e
!text "2064"
!byte 0,0,0
* = $0810

start:

lda $d018
and #%11110001
ora #%00001000
sta $d018
lda $d011
ora #%00100000
sta $d011


lda #$10
sta $0400

lda #%10000000
sta $2000
rts
