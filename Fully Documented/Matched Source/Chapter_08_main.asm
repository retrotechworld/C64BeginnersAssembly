!cpu 6510

* = $0801
!byte $0b,$08,$0a,$00,$9e
!text "2064"
!byte 0,0,0
* = $0810

start:
sei
lda #$01
sta $d015
lda #$00
sta $d010
sta $d017
sta $d01d
lda #$07
sta $d027
lda #$80
sta $d000
lda #$80
sta $d001
lda #$c0
sta $07f8
lda #0
sta tick
sta frame
lda #<irq
sta $0314
lda #>irq
sta $0315
cli
rts

irq:
pha


lda $dc00
and #%00000100
bne check_right
dec $d000
check_right:
lda $dc00
and #%00001000
bne animate
inc $d000
animate:
inc tick
lda tick
cmp #8
bcc finish
lda #0
sta tick
lda frame
eor #1
sta frame
clc
adc #$c0
sta $07f8
finish:
pla
jmp $ea31

frame: !byte 0
tick: !byte 0



* = $3000
!fill 63,$18
!byte 0
* = $3040
!fill 63,$3c
!byte 0
