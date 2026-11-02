!cpu 6510
* = $0801
!byte $0b,$08,$0a,$00,$9e
!text "2064"
!byte 0,0,0
* = $0810
start:
sei
lda $d011
and #%01111111
sta $d011
lda #100
sta $d012
lda #1
sta $d019
lda #<irq_routine
sta $0314
lda #>irq_routine
sta $0315
lda $d01a
ora #1
sta $d01a
cli
rts
irq_routine:
pha
lda $d019
and #1
beq irq_exit
lda #1
sta $d019
inc $d020
irq_exit:
pla
jmp $ea31
