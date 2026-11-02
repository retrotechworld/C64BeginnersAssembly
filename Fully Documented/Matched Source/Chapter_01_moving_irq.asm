!cpu 6510
* = $0801
!byte $0b,$08,$0a,$00,$9e
!text "2064"
!byte 0,0,0
* = $0810
start:
sei
lda #0
sta delay_counter
sta position
lda #<irq_routine
sta $0314
lda #>irq_routine
sta $0315
cli
rts
irq_routine:
pha
txa
pha
inc delay_counter
lda delay_counter
cmp #6
bne irq_exit
lda #0
sta delay_counter
ldx position
lda #32
sta $0540,x
inx
cpx #40
bne store_position
ldx #0
store_position:
stx position
lda #1
sta $0540,x
irq_exit:
pla
tax
pla
jmp $ea31
delay_counter: !byte 0
position: !byte 0
