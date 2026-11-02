!cpu 6510
* = $2000
!macro put .value, .address {
lda #.value
sta .address
}
+put 5, $d020
rts
!align 63,0,0
sprite:
!fill 64,0
!for i,0,15 { !byte i }
!if sprite AND 63 { !error "sprite misaligned" }
