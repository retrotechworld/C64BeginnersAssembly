!cpu 6510
* = $0801
!byte $0b,$08,$0a,$00,$9e
!text "2064"
!byte 0,0,0
* = $0810
start:
ldx #0
page:
lda #1
sta $0400,x
sta $0500,x
sta $0600,x
lda #7
sta $d800,x
sta $d900,x
sta $da00,x
inx
bne page
ldx #0
tail:
lda #1
sta $0700,x
lda #7
sta $db00,x
inx
cpx #232
bne tail
rts
