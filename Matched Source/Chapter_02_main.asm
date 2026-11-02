!cpu 6510
* = $0801
!byte $0b,$08,$0a,$00,$9e
!text "2064"
!byte 0,0,0
* = $0810
start:
sei
lda #0
sta band_index

lda $d011
and #%01111111
sta $d011
lda #60
sta $d012

lda #1
sta $d019

lda #<irq_handler
sta $0314
lda #>irq_handler
sta $0315

lda $d01a
ora #1
sta $d01a
cli
rts
irq_handler:
pha
txa
pha

lda $d019
and #1
beq irq_done

lda #1
sta $d019
ldx band_index
lda band_colours,x
sta $d020

inx
cpx #4
bne index_ok
ldx #0
index_ok:
stx band_index

lda band_lines,x
sta $d012
irq_done:
pla
tax
pla
jmp $ea31
band_index:
!byte 0
band_lines:
!byte 60,110,160,210
band_colours:
!byte 2,5,7,6
