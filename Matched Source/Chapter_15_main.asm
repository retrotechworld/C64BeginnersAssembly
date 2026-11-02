!cpu 6510
* = $0801
!byte $0b,$08,$0a,$00,$9e
!text "2064"
!byte 0,0,0
* = $0810

counter = $fb
screen_ptr = $fc
start:
lda #0
sta counter
lda #<$0400
sta screen_ptr
lda #>$0400
sta screen_ptr+1
ldy #0
loop:
lda counter
sta (screen_ptr),y
inc counter
iny
cpy #40
bne loop
rts
