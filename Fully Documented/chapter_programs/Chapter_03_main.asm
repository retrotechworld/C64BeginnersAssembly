; ========================================================================
; Chapter_03_main.asm - documented ACME source
; Every code-bearing line has WHAT, WHY and HOW comments.
; WHAT describes the operation. WHY explains its role. HOW explains encoding,
; flags, addressing, hardware effects or control flow.
; Code comments do not change the generated program bytes.
; PURPOSE: Display and move one white hardware sprite.
; FLOW: A $80 pointer selects the shape at $2000 in VIC bank 0. Raster IRQ line 100 increments
; xpos; values reaching 240 reset to 40. The updated byte goes to sprite 0 X.
; TRY: Edit the 63 shape bytes or move the starting Y coordinate. Keep the slot at 64-byte
; alignment.
; ASSUMPTIONS: The program assumes the reset VIC bank and sprite mode state. X is only eight
; bits here. It chains KERNAL service on both raster and CIA events; the sprite movement
; itself occurs only on the raster source.
; ASSEMBLE: Select CBM format and an output name using the command line.
; Example from the companion root:
; acme --strict-segments -f cbm -o demo.prg chapter_programs/Chapter_03_main.asm
; Archived originals are unchanged and are not the recommended teaching copies.
; ========================================================================
; WHAT / WHY / HOW documented teaching copy.
; Original files are preserved in originals/ACME_Source.
; WHAT: Select the NMOS 6510 instruction set.
; WHY: Generate instructions for the C64 CPU rather than a later 65C02.
; HOW: In ACME 0.97, 6510 aliases nmos6502 and also permits undocumented opcodes; this course
; uses official instructions.
!cpu 6510 ; Output is selected with -f cbm -o on the command line.
; BASIC: 10 SYS 2064
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
    ; Sprite data at $2000 (VIC bank 0)
; WHAT: Load A from $80 (literal value).
; WHY: Prepare the value for first sprite pointer.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #$80
; WHAT: Copy A to first sprite pointer.
; WHY: pointer: $80 * 64.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $07f8          ; pointer: $80 * 64
; WHAT: Load A from 1 (literal value).
; WHY: Prepare the value for sprite 0 colour / colour-register base.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #1
; WHAT: Copy A to sprite 0 colour / colour-register base.
; WHY: white sprite.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d027          ; white sprite
; WHAT: Load A from 120 (literal value).
; WHY: Prepare the value for sprite 0 X low byte.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #120
; WHAT: Copy A to sprite 0 X low byte.
; WHY: X position.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d000          ; X position
; WHAT: Load A from 120 (literal value).
; WHY: Prepare the value for sprite 0 Y coordinate.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #120
; WHAT: Copy A to sprite 0 Y coordinate.
; WHY: Y position.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d001          ; Y position
; WHAT: Load A from sprite X-high-bit mask.
; WHY: Fetch sprite X-high-bit mask while we prepare the program before display updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda $d010
; WHAT: A = A AND #%11111110.
; WHY: X high bit = 0.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    and #%11111110     ; X high bit = 0
; WHAT: Copy A to sprite X-high-bit mask.
; WHY: Update sprite X-high-bit mask while we prepare the program before display updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.  Bit n supplies X bit 8 for hardware sprite n.
    sta $d010
; WHAT: Load A from sprite-enable mask.
; WHY: Fetch sprite-enable mask while we prepare the program before display updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda $d015
; WHAT: A = A OR #1.
; WHY: Select, combine or constrain the bits used to prepare the program before display updates
; begin.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    ora #1
; WHAT: Copy A to sprite-enable mask.
; WHY: enable sprite 0.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.  Bit n enables hardware sprite channel n when it is 1.
    sta $d015          ; enable sprite 0
; WHAT: Load A from 120 (literal value).
; WHY: Prepare the value for moving sprite X coordinate.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #120
; WHAT: Copy A to moving sprite X coordinate.
; WHY: Update moving sprite X coordinate while we prepare the program before display updates
; begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta xpos
    ; Raster line 100, high bit clear
; WHAT: Load A from vertical/control register with mixed raster read/write bit.
; WHY: Fetch vertical/control register with mixed raster read/write bit while we prepare the
; program before display updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.  Bit 7 read is current raster high; writing that bit later changes the compare
; high bit.
    lda $d011
; WHAT: A = A AND #%01111111.
; WHY: Select, combine or constrain the bits used to prepare the program before display updates
; begin.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    and #%01111111
; WHAT: Copy A to vertical/control register with mixed raster read/write bit.
; WHY: Update vertical/control register with mixed raster read/write bit while we prepare the
; program before display updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.  Bits 0-2 select fine Y; bit 7 written selects raster compare high, unlike its
; read meaning.
    sta $d011
; WHAT: Load A from 100 (literal value).
; WHY: Prepare the value for raster low byte / compare target.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #100
; WHAT: Copy A to raster low byte / compare target.
; WHY: Update raster low byte / compare target while we prepare the program before display
; updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.  A write programs raster compare low; it does not move the video beam.
    sta $d012
; WHAT: Load A from 1 (literal value).
; WHY: Prepare the value for VIC pending interrupt flags.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #1
; WHAT: Copy A to VIC pending interrupt flags.
; WHY: acknowledge raster.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged. Writing a 1 acknowledges the corresponding pending VIC flag, not an ordinary
; RAM assignment.
    sta $d019          ; acknowledge raster
; WHAT: Load A from <irq_handler (literal value).
; WHY: Prepare the value for KERNAL IRQ vector low byte.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #<irq_handler
; WHAT: Copy A to KERNAL IRQ vector low byte.
; WHY: Update KERNAL IRQ vector low byte while we prepare the program before display updates
; begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $0314
; WHAT: Load A from >irq_handler (literal value).
; WHY: Prepare the value for KERNAL IRQ vector high byte.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #>irq_handler
; WHAT: Copy A to KERNAL IRQ vector high byte.
; WHY: Update KERNAL IRQ vector high byte while we prepare the program before display updates
; begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $0315
; WHAT: Load A from VIC interrupt enables.
; WHY: Fetch VIC interrupt enables while we prepare the program before display updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda $d01a
; WHAT: A = A OR #1.
; WHY: Select, combine or constrain the bits used to prepare the program before display updates
; begin.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    ora #1
; WHAT: Copy A to VIC interrupt enables.
; WHY: enable raster IRQ.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d01a          ; enable raster IRQ
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
; WHAT: Define address label irq_handler.
; WHY: Name the entry or data location used to test the raster source and update the scheduled
; display stage.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
irq_handler:
; WHAT: Push A on page-1 stack.
; WHY: Decrement SP after the write; A remains unchanged.
; HOW: Decrement SP after the write; A remains unchanged. Other registers are not implicitly
; saved.
    pha
; WHAT: A = X.
; WHY: Bring an index into arithmetic/logic register A.
; HOW: Bring an index into arithmetic/logic register A. Among status flags, only N Z change.
    txa
; WHAT: Push A on page-1 stack.
; WHY: Decrement SP after the write; A remains unchanged.
; HOW: Decrement SP after the write; A remains unchanged. Other registers are not implicitly
; saved.
    pha
; WHAT: Load A from VIC pending interrupt flags.
; WHY: Fetch VIC pending interrupt flags while we test the raster source and update the
; scheduled display stage.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda $d019
; WHAT: A = A AND #1.
; WHY: Select, combine or constrain the bits used to test the raster source and update the
; scheduled display stage.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    and #1
; WHAT: Branch when Z=1; target is irq_exit.
; WHY: Choose the path that continues or completes test the raster source and update the
; scheduled display stage.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    beq irq_exit
; WHAT: Load A from 1 (literal value).
; WHY: Prepare the value for VIC pending interrupt flags.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #1
; WHAT: Copy A to VIC pending interrupt flags.
; WHY: Update VIC pending interrupt flags while we test the raster source and update the
; scheduled display stage.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged. Writing a 1 acknowledges the corresponding pending VIC flag, not an ordinary
; RAM assignment.
    sta $d019
    ; One X increment each video frame
; WHAT: Increment moving sprite X coordinate modulo 256.
; WHY: Advance the counter, position or offset used to test the raster source and update the
; scheduled display stage.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z. NMOS memory read-modify-write writes the old byte before the new one; avoid
; applying this blindly to I/O.
    inc xpos
; WHAT: Load A from moving sprite X coordinate.
; WHY: Fetch moving sprite X coordinate while we test the raster source and update the scheduled
; display stage.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda xpos
; WHAT: Compare A with #240 without changing that register.
; WHY: Set the condition for the following branch in irq_handler.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cmp #240
; WHAT: Branch when C=0; target is move_sprite.
; WHY: Choose the path that continues or completes test the raster source and update the
; scheduled display stage.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bcc move_sprite
; WHAT: Load A from 40 (literal value).
; WHY: Prepare the value for moving sprite X coordinate.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #40
; WHAT: Copy A to moving sprite X coordinate.
; WHY: Update moving sprite X coordinate while we test the raster source and update the
; scheduled display stage.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta xpos
; WHAT: Define address label move_sprite.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
move_sprite:
; WHAT: Copy A to sprite 0 X low byte.
; WHY: Update sprite 0 X low byte while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d000
; WHAT: Define address label irq_exit.
; WHY: Name the entry or data location used to restore extra saved registers and continue normal
; KERNAL IRQ service.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
irq_exit:
; WHAT: Pull one byte from stack into A.
; WHY: Increment SP before reading.
; HOW: Increment SP before reading. Among status flags, only N Z change.
    pla
; WHAT: X = A.
; WHY: Transfer a copy, often to index a lookup table.
; HOW: Transfer a copy, often to index a lookup table. Among status flags, only N Z change.
    tax
; WHAT: Pull one byte from stack into A.
; WHY: Increment SP before reading.
; HOW: Increment SP before reading. Among status flags, only N Z change.
    pla
; WHAT: Continue execution at $ea31.
; WHY: Continue standard KERNAL IRQ service after balancing this handler extra saves.
; HOW: Absolute JMP changes PC without stacking a return address; flags are unchanged. Standard
; ROM service ultimately restores the ROM-saved registers and returns with RTI; this internal
; address depends on the C64 ROM.
    jmp $ea31
; WHAT: Emit 1 literal byte.
; WHY: Initialise moving sprite X coordinate; successive entries are adjacent bytes.
; HOW: The label xpos names this data address. These are stored data, not CPU instructions.
; Binary row bits run left to right from the high bit of each byte; table indices start at zero.
xpos: !byte 120
; Pad PRG output to sprite data location.
; WHAT: Place the following output at $2000.
; WHY: Keep the BASIC launcher, executable code or graphics at its planned address.
; HOW: This is assembly-time placement, not a runtime jump. CBM output fills gaps between the
; lowest and highest emitted addresses.
* = $2000
; WHAT: Define address label sprite_data.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
sprite_data:
; WHAT: Emit the stated count of repeated bytes.
; WHY: Allocate and initialise sprite_data or the sprite artwork.
; HOW: ACME creates data during assembly; !fill 12,0 produces twelve zeros, while !fill 63,$ff
; produces 21 solid three-byte sprite rows.
!fill 63,$ff        ; 21 solid rows of 3 bytes
; WHAT: Emit 1 literal byte.
; WHY: Initialise sprite_data; successive entries are adjacent bytes.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
!byte 0            ; pad to 64-byte block
