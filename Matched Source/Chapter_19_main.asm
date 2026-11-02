!cpu 6510
* = $0801
!byte $0b,$08,$0a,$00,$9e
!text "2064"
!byte 0,0,0
* = $0810

start:
lda #1
sta $0400
lda #2
sta $d020
lda $01
sta saved_port

lda saved_port
and #7
sta $0401
rts
saved_port: !byte 0
