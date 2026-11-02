!cpu 6510
* = $0801
!byte $0b,$08,$0a,$00,$9e
!text "2064"
!byte 0,0,0
* = $0810
start:
sei
lda #<irq_routine
sta $0314
lda #>irq_routine
sta $0315
cli
rts
irq_routine:
inc $d020
jmp $ea31
