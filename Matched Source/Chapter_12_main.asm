!cpu 6510
* = $0801
!byte $0b,$08,$0a,$00,$9e
!text "2064"
!byte 0,0,0
* = $0810

start:
sei

lda #$33
sta $01
ldx #0
copy_page:
lda $d000,x
sta $2000,x
lda $d100,x
sta $2100,x
lda $d200,x
sta $2200,x
lda $d300,x
sta $2300,x
lda $d400,x
sta $2400,x
lda $d500,x
sta $2500,x
lda $d600,x
sta $2600,x
lda $d700,x
sta $2700,x
inx
bne copy_page
lda #$37
sta $01

lda $d018
and #%11110001
ora #%00001000
sta $d018

lda #1
sta $0400
lda #2
sta $0401
lda #3
sta $0402
cli
rts
