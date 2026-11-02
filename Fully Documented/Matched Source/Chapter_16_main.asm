!cpu 6510
* = $0801
!byte $0b,$08,$0a,$00,$9e
!text "2064"
!byte 0,0,0
* = $0810

start:
sei
lda $d011
and #$7f
sta $d011
lda #80
sta $d012
lda #1
sta $d019
lda #<irq
sta $0314
lda #>irq
sta $0315
lda $d01a
ora #1
sta $d01a
cli
rts
irq:
pha
lda $d019
and #1
beq done
lda #1
sta $d019
lda next
bne second
first:
lda #2
sta $d020
lda #160
sta $d012
lda #1
sta next
jmp done
second:
lda #6
sta $d020
lda #80
sta $d012
lda #0
sta next
done:
pla
jmp $ea31
next: !byte 0
