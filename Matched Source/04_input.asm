!cpu 6510
* = $0801
!byte $0b,$08,$0a,$00,$9e
!text "2064"
!byte 0,0,0
* = $0810
start:
sei
lda #0
sta $dc02
loop:
lda $dc00
and #16
bne released
lda #2
bne show
released:
lda #6
show:
sta $d020
jmp loop
