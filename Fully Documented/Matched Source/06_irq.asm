!cpu 6510
* = $0801
!byte $0b,$08,$0a,$00,$9e
!text "2064"
!byte 0,0,0
* = $0810
start:
sei
cld
lda #$7f
sta $dc0d
sta $dd0d
lda $dc0d
lda $dd0d
lda #<irq
sta $0314
lda #>irq
sta $0315
lda #$1b
sta $d011
lda #100
sta $d012
lda #1
sta $d019
sta $d01a
lda #0
sta count
cli
idle:
jmp idle
irq:
lda #1
sta $d019
inc count
lda count
and #15
sta $d020
jmp $ea81
count: !byte 0
