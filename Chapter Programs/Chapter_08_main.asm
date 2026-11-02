; ========================================================================
; Chapter_08_main.asm - documented ACME source
; Every code-bearing line has WHAT, WHY and HOW comments.
; WHAT describes the operation. WHY explains its role. HOW explains encoding,
; flags, addressing, hardware effects or control flow.
; Code comments do not change the generated program bytes.
; PURPOSE: Alternate between two sprite images and respond to left/right input.
; FLOW: The shape slots at $3000/$3040 use pointers $C0/$C1. Every eight system IRQ ticks, EOR
; #1 toggles frame and ADC #$C0 turns it into a sprite pointer. Active-low joystick bits
; directly change sprite 0 X.
; TRY: Change CMP #8 to #16 for slower shape changes, then change one bitmap fill pattern.
; ASSUMPTIONS: Stock CIA system service is normally about 60 Hz on PAL and NTSC, not one PAL
; raster-frame tick; that source comment is corrected. X has no boundary clamp and wraps.
; Joystick/keyboard share CIA pins, and this example relies on standard system configuration.
; ASSEMBLE: Select CBM format and an output name using the command line.
; Example from the companion root:
; acme --strict-segments -f cbm -o demo.prg chapter_programs/Chapter_08_main.asm
; Archived originals are unchanged and are not the recommended teaching copies.
; ========================================================================
; WHAT / WHY / HOW documented teaching copy.
; Original files are preserved in originals/ACME_Source.
; WHAT: Select the NMOS 6510 instruction set.
; WHY: Generate instructions for the C64 CPU rather than a later 65C02.
; HOW: In ACME 0.97, 6510 aliases nmos6502 and also permits undocumented opcodes; this course
; uses official instructions.
!cpu 6510 ; Output is selected with -f cbm -o on the command line.

; WHAT: Place the following output at $0801.
; WHY: Keep the BASIC launcher, executable code or graphics at its planned address.
; HOW: This is assembly-time placement, not a runtime jump. CBM output fills gaps between the
; lowest and highest emitted addresses.
* = $0801
; WHAT: Emit 5 literal bytes.
; WHY: Create the BASIC next-line link, line number and SYS token.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
!byte $0b,$08,$0a,$00,$9e
; WHAT: Emit the quoted text bytes.
; WHY: Supply decimal SYS digits in the BASIC launch line.
; HOW: ACME converts the string with the current text table; digits 2064 occupy four bytes. This
; is not executable text or a screen-code declaration.
!text "2064"
; WHAT: Emit 3 literal bytes.
; WHY: Terminate the BASIC line and then the BASIC program.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
!byte 0,0,0
; WHAT: Place the following output at $0810.
; WHY: Keep the BASIC launcher, executable code or graphics at its planned address.
; HOW: This is assembly-time placement, not a runtime jump. CBM output fills gaps between the
; lowest and highest emitted addresses.
* = $0810

; WHAT: Define address label start.
; WHY: Name the entry or data location used to prepare the program before display updates begin.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
start:
; WHAT: I = 1.
; WHY: Mask IRQ recognition; NMI and hardware activity continue.
; HOW: Mask IRQ recognition; NMI and hardware activity continue. Among status flags, only I
; changes.
    sei
; WHAT: Load A from $01 (literal value).
; WHY: Prepare the value for sprite-enable mask.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #$01
; WHAT: Copy A to sprite-enable mask.
; WHY: enable sprite 0.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.  Bit n enables hardware sprite channel n when it is 1.
    sta $d015         ; enable sprite 0
; WHAT: Load A from $00 (literal value).
; WHY: Prepare the value for sprite X-high-bit mask.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #$00
; WHAT: Copy A to sprite X-high-bit mask.
; WHY: X coordinate under 256.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.  Bit n supplies X bit 8 for hardware sprite n.
    sta $d010         ; X coordinate under 256
; WHAT: Copy A to sprite Y-expansion mask.
; WHY: normal height.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d017         ; normal height
; WHAT: Copy A to sprite X-expansion mask.
; WHY: normal width.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d01d         ; normal width
; WHAT: Load A from $07 (literal value).
; WHY: Prepare the value for sprite 0 colour / colour-register base.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #$07
; WHAT: Copy A to sprite 0 colour / colour-register base.
; WHY: sprite 0: yellow.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d027         ; sprite 0: yellow
; WHAT: Load A from $80 (literal value).
; WHY: Prepare the value for sprite 0 X low byte.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #$80
; WHAT: Copy A to sprite 0 X low byte.
; WHY: X = 128.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d000         ; X = 128
; WHAT: Load A from $80 (literal value).
; WHY: Prepare the value for sprite 0 Y coordinate.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #$80
; WHAT: Copy A to sprite 0 Y coordinate.
; WHY: Y = 128.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d001         ; Y = 128
; WHAT: Load A from $c0 (literal value).
; WHY: Prepare the value for first sprite pointer.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #$c0
; WHAT: Copy A to first sprite pointer.
; WHY: $3000 / 64 = $c0.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $07f8         ; $3000 / 64 = $c0
; WHAT: Load A from 0 (literal value).
; WHY: Prepare the value for update counter.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #0
; WHAT: Copy A to update counter.
; WHY: Update update counter while we prepare the program before display updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta tick
; WHAT: Copy A to sprite animation frame index.
; WHY: Update sprite animation frame index while we prepare the program before display updates
; begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta frame
; WHAT: Load A from <irq (literal value).
; WHY: Prepare the value for KERNAL IRQ vector low byte.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #<irq
; WHAT: Copy A to KERNAL IRQ vector low byte.
; WHY: Update KERNAL IRQ vector low byte while we prepare the program before display updates
; begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $0314
; WHAT: Load A from >irq (literal value).
; WHY: Prepare the value for KERNAL IRQ vector high byte.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #>irq
; WHAT: Copy A to KERNAL IRQ vector high byte.
; WHY: Update KERNAL IRQ vector high byte while we prepare the program before display updates
; begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $0315
; WHAT: I = 0.
; WHY: Permit maskable IRQ recognition; does not clear interrupt sources.
; HOW: Permit maskable IRQ recognition; does not clear interrupt sources. Among status flags,
; only I change.
    cli
; WHAT: Return from the current subroutine.
; WHY: Return control to the caller after this routine has completed its work.
; HOW: Pull the JSR return address, add one, and continue there. The stack must still match the
; call; flags are unchanged.
    rts

; WHAT: Define address label irq.
; WHY: Name the entry or data location used to acknowledge and dispatch the scheduled raster
; event.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
irq:
; WHAT: Push A on page-1 stack.
; WHY: Decrement SP after the write; A remains unchanged.
; HOW: Decrement SP after the write; A remains unchanged. Other registers are not implicitly
; saved.
    pha
    ; Stock KERNAL CIA timer service is normally about 60 Hz on PAL/NTSC.
    ; It is not inherently one tick per PAL video frame. Read joystick port 2.
; WHAT: Load A from CIA1 port A / joystick 2.
; WHY: Fetch CIA1 port A / joystick 2 while we acknowledge and dispatch the scheduled raster
; event.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda $dc00
; WHAT: A = A AND #%00000100.
; WHY: bit 2 low = left.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    and #%00000100   ; bit 2 low = left
; WHAT: Branch when Z=0; target is check_right.
; WHY: Choose the path that continues or completes acknowledge and dispatch the scheduled raster
; event.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne check_right
; WHAT: Decrement sprite 0 X low byte modulo 256.
; WHY: Advance the counter, position or offset used to acknowledge and dispatch the scheduled
; raster event.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z. NMOS memory read-modify-write writes the old byte before the new one; avoid
; applying this blindly to I/O.
    dec $d000
; WHAT: Define address label check_right.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
check_right:
; WHAT: Load A from CIA1 port A / joystick 2.
; WHY: Fetch CIA1 port A / joystick 2 while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda $dc00
; WHAT: A = A AND #%00001000.
; WHY: bit 3 low = right.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    and #%00001000   ; bit 3 low = right
; WHAT: Branch when Z=0; target is animate.
; WHY: Choose the path that continues or completes this operation.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne animate
; WHAT: Increment sprite 0 X low byte modulo 256.
; WHY: Advance the counter, position or offset used to process this loop.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z. NMOS memory read-modify-write writes the old byte before the new one; avoid
; applying this blindly to I/O.
    inc $d000
; WHAT: Define address label animate.
; WHY: Name the entry or data location used to advance the animation tick and select a shape
; when due.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
animate:
; WHAT: Increment update counter modulo 256.
; WHY: Advance the counter, position or offset used to advance the animation tick and select a
; shape when due.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z. NMOS memory read-modify-write writes the old byte before the new one; avoid
; applying this blindly to I/O.
    inc tick
; WHAT: Load A from update counter.
; WHY: Fetch update counter while we advance the animation tick and select a shape when due.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda tick
; WHAT: Compare A with #8 without changing that register.
; WHY: Set the condition for the following branch in animate.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cmp #8
; WHAT: Branch when C=0; target is finish.
; WHY: Choose the path that continues or completes advance the animation tick and select a shape
; when due.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bcc finish
; WHAT: Load A from 0 (literal value).
; WHY: Prepare the value for update counter.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #0
; WHAT: Copy A to update counter.
; WHY: Update update counter while we advance the animation tick and select a shape when due.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta tick
; WHAT: Load A from sprite animation frame index.
; WHY: Fetch sprite animation frame index while we advance the animation tick and select a shape
; when due.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda frame
; WHAT: A = A XOR #1.
; WHY: Select, combine or constrain the bits used to advance the animation tick and select a
; shape when due.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    eor #1
; WHAT: Copy A to sprite animation frame index.
; WHY: Update sprite animation frame index while we advance the animation tick and select a
; shape when due.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta frame
; WHAT: C = 0.
; WHY: Start an independent addition without an incoming carry.
; HOW: Start an independent addition without an incoming carry. Among status flags, only C
; changes.
    clc
; WHAT: A = A + #$c0 + C.
; WHY: frame 0=$c0, frame 1=$c1.
; HOW: Immediate operand: the value is encoded in the instruction. Updates N,V,Z,C in binary
; mode. Preserve low-byte carry for a following high-byte addition.
    adc #$c0         ; frame 0=$c0, frame 1=$c1
; WHAT: Copy A to first sprite pointer.
; WHY: Update first sprite pointer while we advance the animation tick and select a shape when
; due.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $07f8
; WHAT: Define address label finish.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
finish:
; WHAT: Pull one byte from stack into A.
; WHY: Increment SP before reading.
; HOW: Increment SP before reading. Among status flags, only N Z change.
    pla
; WHAT: Continue execution at $ea31.
; WHY: Continue standard KERNAL IRQ service after balancing this handler extra saves.
; HOW: Absolute JMP changes PC without stacking a return address; flags are unchanged. Standard
; ROM service ultimately restores the ROM-saved registers and returns with RTI; this internal
; address depends on the C64 ROM.
    jmp $ea31       ; continue standard KERNAL IRQ

; WHAT: Emit 1 literal byte.
; WHY: Initialise sprite animation frame index; successive entries are adjacent bytes.
; HOW: The label frame names this data address. These are stored data, not CPU instructions.
; Binary row bits run left to right from the high bit of each byte; table indices start at zero.
frame: !byte 0
; WHAT: Emit 1 literal byte.
; WHY: Initialise update counter; successive entries are adjacent bytes.
; HOW: The label tick names this data address. These are stored data, not CPU instructions.
; Binary row bits run left to right from the high bit of each byte; table indices start at zero.
tick:  !byte 0

; Each frame is 64 bytes: 63 sprite bitmap bytes
; plus one unused padding byte.
; WHAT: Place the following output at $3000.
; WHY: Keep the BASIC launcher, executable code or graphics at its planned address.
; HOW: This is assembly-time placement, not a runtime jump. CBM output fills gaps between the
; lowest and highest emitted addresses.
* = $3000
; WHAT: Emit the stated count of repeated bytes.
; WHY: Allocate and initialise update counter or the sprite artwork.
; HOW: ACME creates data during assembly; !fill 12,0 produces twelve zeros, while !fill 63,$ff
; produces 21 solid three-byte sprite rows.
!fill 63,$18
; WHAT: Emit 1 literal byte.
; WHY: Initialise update counter; successive entries are adjacent bytes.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
!byte 0
; WHAT: Place the following output at $3040.
; WHY: Keep the BASIC launcher, executable code or graphics at its planned address.
; HOW: This is assembly-time placement, not a runtime jump. CBM output fills gaps between the
; lowest and highest emitted addresses.
* = $3040
; WHAT: Emit the stated count of repeated bytes.
; WHY: Allocate and initialise update counter or the sprite artwork.
; HOW: ACME creates data during assembly; !fill 12,0 produces twelve zeros, while !fill 63,$ff
; produces 21 solid three-byte sprite rows.
!fill 63,$3c
; WHAT: Emit 1 literal byte.
; WHY: Initialise update counter; successive entries are adjacent bytes.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
!byte 0
