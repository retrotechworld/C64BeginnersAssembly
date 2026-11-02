; ========================================================================
; Chapter_04_main.asm - documented ACME source
; Every code-bearing line has WHAT, WHY and HOW comments.
; WHAT describes the operation. WHY explains its role. HOW explains encoding,
; flags, addressing, hardware effects or control flow.
; Code comments do not change the generated program bytes.
; PURPOSE: Reuse hardware channel 0 below an upper row of eight sprites.
; FLOW: The upper row starts at Y=70. At raster 130 the code moves channel 0 to Y=170 and
; turns it red; at 250 it restores channel 0 to its top-row position and white colour.
; TRY: Change lower X from 160 to 100 and red to yellow. Keep the vertical gaps unchanged
; first.
; ASSUMPTIONS: The lower image is a second use of a physical channel, not a ninth hardware
; channel. Expanded sprites or closer bands need a new timing analysis. All sprites use one
; shared shape.
; ASSEMBLE: Select CBM format and an output name using the command line.
; Example from the companion root:
; acme --strict-segments -f cbm -o demo.prg chapter_programs/Chapter_04_main.asm
; Archived originals are unchanged and are not the recommended teaching copies.
; ========================================================================
; WHAT / WHY / HOW documented teaching copy.
; Original files are preserved in originals/ACME_Source.
; WHAT: Select the NMOS 6510 instruction set.
; WHY: Generate instructions for the C64 CPU rather than a later 65C02.
; HOW: In ACME 0.97, 6510 aliases nmos6502 and also permits undocumented opcodes; this course
; uses official instructions.
!cpu 6510 ; Output is selected with -f cbm -o on the command line.
; BASIC line 10: SYS 2064
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
    ; Use the normal VIC bank and text screen.
    ; Disable sprites while setting them up.
; WHAT: Load A from 0 (literal value).
; WHY: Prepare the value for sprite-enable mask.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #0
; WHAT: Copy A to sprite-enable mask.
; WHY: Update sprite-enable mask while we prepare the program before display updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.  Bit n enables hardware sprite channel n when it is 1.
    sta $d015
; WHAT: Copy A to sprite X-high-bit mask.
; WHY: all X positions < 256.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.  Bit n supplies X bit 8 for hardware sprite n.
    sta $d010           ; all X positions < 256
; WHAT: Copy A to sprite Y-expansion mask.
; WHY: no vertical expansion.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d017           ; no vertical expansion
; WHAT: Copy A to sprite X-expansion mask.
; WHY: no horizontal expansion.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d01d           ; no horizontal expansion
; WHAT: Copy A to sprite multicolour mask.
; WHY: single-colour sprites.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d01c           ; single-colour sprites
    ; Every channel points to the same 64-byte image.
; WHAT: Load X from 0 (literal value).
; WHY: Set the literal value needed to prepare the program before display updates begin.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    ldx #0
; WHAT: Define address label setup_pointers.
; WHY: Name the entry or data location used to assign pointers and initial colours to the
; enabled hardware channels.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
setup_pointers:
; WHAT: Load A from $c0 (literal value).
; WHY: $3000 / 64 = $c0.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #$c0            ; $3000 / 64 = $c0
; WHAT: Copy A to first sprite pointer.
; WHY: Update first sprite pointer while we assign pointers and initial colours to the enabled
; hardware channels.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta $07f8,x
; WHAT: Load A from 1 (literal value).
; WHY: white.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #1              ; white
; WHAT: Copy A to sprite 0 colour / colour-register base.
; WHY: Update sprite 0 colour / colour-register base while we assign pointers and initial
; colours to the enabled hardware channels.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta $d027,x
; WHAT: Increment X modulo 256.
; WHY: Advance the counter, position or offset used to assign pointers and initial colours to
; the enabled hardware channels.
; HOW: Implied/accumulator form; no separate memory operand. Flags updated: N Z.
    inx
; WHAT: Compare X with #8 without changing that register.
; WHY: Set the condition for the following branch in setup_pointers.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cpx #8
; WHAT: Branch when Z=0; target is setup_pointers.
; WHY: Choose the path that continues or completes assign pointers and initial colours to the
; enabled hardware channels.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne setup_pointers
    ; Place eight sprites at Y=70.
; WHAT: Load X from 0 (literal value).
; WHY: Set the literal value needed to assign pointers and initial colours to the enabled
; hardware channels.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    ldx #0
; WHAT: Load Y from 0 (literal value).
; WHY: Set the literal value needed to assign pointers and initial colours to the enabled
; hardware channels.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    ldy #0
; WHAT: Define address label setup_positions.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
setup_positions:
; WHAT: Load A from initial hardware-channel X table.
; WHY: Fetch initial hardware-channel X table while we process this section.
; HOW: Indexed address: add the index register to the named base address. Flags updated: N Z.
    lda initial_x,y
; WHAT: Copy A to sprite 0 X low byte.
; WHY: sprite X.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta $d000,x         ; sprite X
; WHAT: Load A from 70 (literal value).
; WHY: Prepare the value for sprite 0 Y coordinate.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #70
; WHAT: Copy A to sprite 0 Y coordinate.
; WHY: sprite Y.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta $d001,x         ; sprite Y
; WHAT: Increment X modulo 256.
; WHY: Advance the counter, position or offset used to process this loop.
; HOW: Implied/accumulator form; no separate memory operand. Flags updated: N Z.
    inx
; WHAT: Increment X modulo 256.
; WHY: next X/Y register pair.
; HOW: Implied/accumulator form; no separate memory operand. Flags updated: N Z.
    inx                 ; next X/Y register pair
; WHAT: Increment Y modulo 256.
; WHY: Advance the counter, position or offset used to process this loop.
; HOW: Implied/accumulator form; no separate memory operand. Flags updated: N Z.
    iny
; WHAT: Compare Y with #8 without changing that register.
; WHY: Set the condition for the following branch in setup_positions.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cpy #8
; WHAT: Branch when Z=0; target is setup_positions.
; WHY: Choose the path that continues or completes this operation.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne setup_positions
; WHAT: Load A from $ff (literal value).
; WHY: Prepare the value for sprite-enable mask.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #$ff
; WHAT: Copy A to sprite-enable mask.
; WHY: enable all eight channels.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.  Bit n enables hardware sprite channel n when it is 1.
    sta $d015           ; enable all eight channels
; WHAT: Load A from 0 (literal value).
; WHY: Prepare the value for selected multiplexer band.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #0
; WHAT: Copy A to selected multiplexer band.
; WHY: 0 = move down next.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta phase           ; 0 = move down next
    ; Both IRQ lines are below 256.
; WHAT: Load A from vertical/control register with mixed raster read/write bit.
; WHY: Fetch vertical/control register with mixed raster read/write bit while we process this
; section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.  Bit 7 read is current raster high; writing that bit later changes the compare
; high bit.
    lda $d011
; WHAT: A = A AND #%01111111.
; WHY: Select, combine or constrain the bits used to update this setting.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    and #%01111111
; WHAT: Copy A to vertical/control register with mixed raster read/write bit.
; WHY: Update vertical/control register with mixed raster read/write bit while we process this
; section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.  Bits 0-2 select fine Y; bit 7 written selects raster compare high, unlike its
; read meaning.
    sta $d011
; WHAT: Load A from 130 (literal value).
; WHY: Prepare the value for raster low byte / compare target.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #130
; WHAT: Copy A to raster low byte / compare target.
; WHY: Update raster low byte / compare target while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.  A write programs raster compare low; it does not move the video beam.
    sta $d012
; WHAT: Load A from 1 (literal value).
; WHY: Prepare the value for VIC pending interrupt flags.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #1
; WHAT: Copy A to VIC pending interrupt flags.
; WHY: clear pending raster flag.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged. Writing a 1 acknowledges the corresponding pending VIC flag, not an ordinary
; RAM assignment.
    sta $d019           ; clear pending raster flag
; WHAT: Load A from <irq_handler (literal value).
; WHY: Prepare the value for KERNAL IRQ vector low byte.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #<irq_handler
; WHAT: Copy A to KERNAL IRQ vector low byte.
; WHY: Update KERNAL IRQ vector low byte while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $0314
; WHAT: Load A from >irq_handler (literal value).
; WHY: Prepare the value for KERNAL IRQ vector high byte.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #>irq_handler
; WHAT: Copy A to KERNAL IRQ vector high byte.
; WHY: Update KERNAL IRQ vector high byte while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $0315
; WHAT: Load A from VIC interrupt enables.
; WHY: Fetch VIC interrupt enables while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda $d01a
; WHAT: A = A OR #1.
; WHY: Select, combine or constrain the bits used to update this setting.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    ora #1
; WHAT: Copy A to VIC interrupt enables.
; WHY: enable VIC raster IRQ.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d01a           ; enable VIC raster IRQ
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
; WHY: only A is modified here.
; HOW: Decrement SP after the write; A remains unchanged. Other registers are not implicitly
; saved.
    pha                 ; only A is modified here
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
; WHY: ordinary CIA IRQ.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    beq irq_exit        ; ordinary CIA IRQ
; WHAT: Load A from 1 (literal value).
; WHY: Prepare the value for VIC pending interrupt flags.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #1
; WHAT: Copy A to VIC pending interrupt flags.
; WHY: acknowledge raster IRQ.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged. Writing a 1 acknowledges the corresponding pending VIC flag, not an ordinary
; RAM assignment.
    sta $d019           ; acknowledge raster IRQ
; WHAT: Load A from selected multiplexer band.
; WHY: Fetch selected multiplexer band while we test the raster source and update the scheduled
; display stage.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda phase
; WHAT: Branch when Z=0; target is restore_top.
; WHY: Choose the path that continues or completes test the raster source and update the
; scheduled display stage.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne restore_top
; WHAT: Define address label move_down.
; WHY: Name the entry or data location used to apply the lower-band or downward-movement step
; for this example.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
move_down:
; WHAT: Load A from 160 (literal value).
; WHY: Prepare the value for sprite 0 X low byte.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #160
; WHAT: Copy A to sprite 0 X low byte.
; WHY: sprite channel 0 X.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d000           ; sprite channel 0 X
; WHAT: Load A from 170 (literal value).
; WHY: Prepare the value for sprite 0 Y coordinate.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #170
; WHAT: Copy A to sprite 0 Y coordinate.
; WHY: sprite channel 0 Y.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d001           ; sprite channel 0 Y
; WHAT: Load A from 2 (literal value).
; WHY: red ninth sprite.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #2              ; red ninth sprite
; WHAT: Copy A to sprite 0 colour / colour-register base.
; WHY: Update sprite 0 colour / colour-register base while we apply the lower-band or downward-
; movement step for this example.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d027
; WHAT: Load A from 250 (literal value).
; WHY: Prepare the value for raster low byte / compare target.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #250
; WHAT: Copy A to raster low byte / compare target.
; WHY: restore later this frame.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.  A write programs raster compare low; it does not move the video beam.
    sta $d012           ; restore later this frame
; WHAT: Load A from 1 (literal value).
; WHY: Prepare the value for selected multiplexer band.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #1
; WHAT: Copy A to selected multiplexer band.
; WHY: Update selected multiplexer band while we apply the lower-band or downward-movement step
; for this example.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta phase
; WHAT: Continue execution at irq_exit.
; WHY: Repeat the main loop or join the named control path.
; HOW: Absolute JMP changes PC without stacking a return address; flags are unchanged.
    jmp irq_exit
; WHAT: Define address label restore_top.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
restore_top:
; WHAT: Load A from 40 (literal value).
; WHY: Prepare the value for sprite 0 X low byte.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #40
; WHAT: Copy A to sprite 0 X low byte.
; WHY: Update sprite 0 X low byte while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d000
; WHAT: Load A from 70 (literal value).
; WHY: Prepare the value for sprite 0 Y coordinate.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #70
; WHAT: Copy A to sprite 0 Y coordinate.
; WHY: Update sprite 0 Y coordinate while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d001
; WHAT: Load A from 1 (literal value).
; WHY: white first sprite.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #1              ; white first sprite
; WHAT: Copy A to sprite 0 colour / colour-register base.
; WHY: Update sprite 0 colour / colour-register base while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d027
; WHAT: Load A from 130 (literal value).
; WHY: Prepare the value for raster low byte / compare target.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #130
; WHAT: Copy A to raster low byte / compare target.
; WHY: first IRQ next frame.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.  A write programs raster compare low; it does not move the video beam.
    sta $d012           ; first IRQ next frame
; WHAT: Load A from 0 (literal value).
; WHY: Prepare the value for selected multiplexer band.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #0
; WHAT: Copy A to selected multiplexer band.
; WHY: Update selected multiplexer band while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta phase
; WHAT: Define address label irq_exit.
; WHY: Name the entry or data location used to restore extra saved registers and continue normal
; KERNAL IRQ service.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
irq_exit:
; WHAT: Pull one byte from stack into A.
; WHY: Increment SP before reading.
; HOW: Increment SP before reading. Among status flags, only N Z change.
    pla
; WHAT: Continue execution at $ea31.
; WHY: Continue standard KERNAL IRQ service after balancing this handler extra saves.
; HOW: Absolute JMP changes PC without stacking a return address; flags are unchanged. Standard
; ROM service ultimately restores the ROM-saved registers and returns with RTI; this internal
; address depends on the C64 ROM.
    jmp $ea31           ; continue standard KERNAL IRQ
; WHAT: Define address label phase.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
phase:
; WHAT: Emit 1 literal byte.
; WHY: Initialise selected multiplexer band; successive entries are adjacent bytes.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
    !byte 0
; WHAT: Define address label initial_x.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
initial_x:
; WHAT: Emit 8 literal bytes.
; WHY: Initialise initial hardware-channel X table; successive entries are adjacent bytes.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
    !byte 40,64,88,112,136,160,184,208
; One solid 24x21 sprite image (63 bytes + padding).
; WHAT: Place the following output at $3000.
; WHY: Keep the BASIC launcher, executable code or graphics at its planned address.
; HOW: This is assembly-time placement, not a runtime jump. CBM output fills gaps between the
; lowest and highest emitted addresses.
* = $3000
; WHAT: Emit the stated count of repeated bytes.
; WHY: Allocate and initialise initial hardware-channel X table or the sprite artwork.
; HOW: ACME creates data during assembly; !fill 12,0 produces twelve zeros, while !fill 63,$ff
; produces 21 solid three-byte sprite rows.
!fill 64,$ff
