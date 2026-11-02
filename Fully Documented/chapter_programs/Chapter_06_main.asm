; ========================================================================
; Chapter_06_main.asm - documented ACME source
; Every code-bearing line has WHAT, WHY and HOW comments.
; WHAT describes the operation. WHY explains its role. HOW explains encoding,
; flags, addressing, hardware effects or control flow.
; Code comments do not change the generated program bytes.
; PURPOSE: Sort ten object indices without rearranging their X/Y/colour records.
; FLOW: sort_by_y initialises order=0..9, then bubble-sorts adjacent indices by the Y values
; they reference. The raster handler draws the first eight sorted entries and later reuses
; channels 0 and 1 for the final two.
; TRY: Trace one swap: Y=200 at original index 0 and Y=72 at index 1 cause their order entries
; to swap.
; ASSUMPTIONS: The supplied BEQ irq_exit is out of range and is repaired in this teaching
; copy. Only channels 0/1 are reused at line 145: they previously displayed the two earliest
; objects. Some other upper-pass channels have Y=188/192 and have not drawn yet; that is
; compatible because those channels are not overwritten.
; ASSEMBLE: Select CBM format and an output name using the command line.
; Example from the companion root:
; acme --strict-segments -f cbm -o demo.prg chapter_programs/Chapter_06_main.asm
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
    ; Make a solid 24x21 sprite at $3000.
; WHAT: Load X from 0 (literal value).
; WHY: Set the literal value needed to prepare the program before display updates begin.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    ldx #0
; WHAT: Define address label fill_sprite.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
fill_sprite:
; WHAT: Load A from $ff (literal value).
; WHY: Prepare the value for shared sprite bitmap start.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #$ff
; WHAT: Copy A to shared sprite bitmap start.
; WHY: Update shared sprite bitmap start while we process this section.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta $3000,x
; WHAT: Increment X modulo 256.
; WHY: Advance the counter, position or offset used to process this loop.
; HOW: Implied/accumulator form; no separate memory operand. Flags updated: N Z.
    inx
; WHAT: Compare X with #63 without changing that register.
; WHY: Set the condition for the following branch in fill_sprite.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cpx #63
; WHAT: Branch when Z=0; target is fill_sprite.
; WHY: Choose the path that continues or completes this operation.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne fill_sprite
; WHAT: Load A from 0 (literal value).
; WHY: Prepare the value for sprite slot padding.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #0
; WHAT: Copy A to sprite slot padding.
; WHY: Update sprite slot padding while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $303f

    ; Normal size, no X high bits, enable 8.
; WHAT: Load A from 0 (literal value).
; WHY: Prepare the value for sprite X-high-bit mask.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #0
; WHAT: Copy A to sprite X-high-bit mask.
; WHY: Update sprite X-high-bit mask while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.  Bit n supplies X bit 8 for hardware sprite n.
    sta $d010
; WHAT: Copy A to sprite Y-expansion mask.
; WHY: Update sprite Y-expansion mask while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d017
; WHAT: Copy A to sprite X-expansion mask.
; WHY: Update sprite X-expansion mask while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d01d
; WHAT: Load A from $ff (literal value).
; WHY: Prepare the value for sprite-enable mask.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #$ff
; WHAT: Copy A to sprite-enable mask.
; WHY: Update sprite-enable mask while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.  Bit n enables hardware sprite channel n when it is 1.
    sta $d015

; WHAT: Load X from 0 (literal value).
; WHY: Set the literal value needed to perform this step.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    ldx #0
; WHAT: Define address label set_pointers.
; WHY: Name the entry or data location used to assign the shared sprite pointer to each enabled
; hardware channel.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
set_pointers:
; WHAT: Load A from $c0 (literal value).
; WHY: Prepare the value for first sprite pointer.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #$c0
; WHAT: Copy A to first sprite pointer.
; WHY: Update first sprite pointer while we assign the shared sprite pointer to each enabled
; hardware channel.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta $07f8,x
; WHAT: Increment X modulo 256.
; WHY: Advance the counter, position or offset used to assign the shared sprite pointer to each
; enabled hardware channel.
; HOW: Implied/accumulator form; no separate memory operand. Flags updated: N Z.
    inx
; WHAT: Compare X with #8 without changing that register.
; WHY: Set the condition for the following branch in set_pointers.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cpx #8
; WHAT: Branch when Z=0; target is set_pointers.
; WHY: Choose the path that continues or completes assign the shared sprite pointer to each
; enabled hardware channel.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne set_pointers

; WHAT: Call sort_by_y.
; WHY: Delegate work to sort logical indices by increasing Y.
; HOW: Push the address of the last JSR byte on the page-1 stack, then load the target into PC.
; RTS pulls it and adds one.
    jsr sort_by_y
; WHAT: Load A from 0 (literal value).
; WHY: Prepare the value for selected multiplexer band.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #0
; WHAT: Copy A to selected multiplexer band.
; WHY: Update selected multiplexer band while we assign the shared sprite pointer to each
; enabled hardware channel.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta phase
; WHAT: Load A from vertical/control register with mixed raster read/write bit.
; WHY: Fetch vertical/control register with mixed raster read/write bit while we assign the
; shared sprite pointer to each enabled hardware channel.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.  Bit 7 read is current raster high; writing that bit later changes the compare
; high bit.
    lda $d011
; WHAT: A = A AND #$7f.
; WHY: Select, combine or constrain the bits used to assign the shared sprite pointer to each
; enabled hardware channel.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    and #$7f
; WHAT: Copy A to vertical/control register with mixed raster read/write bit.
; WHY: Update vertical/control register with mixed raster read/write bit while we assign the
; shared sprite pointer to each enabled hardware channel.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.  Bits 0-2 select fine Y; bit 7 written selects raster compare high, unlike its
; read meaning.
    sta $d011
; WHAT: Load A from 40 (literal value).
; WHY: Prepare the value for raster low byte / compare target.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #40
; WHAT: Copy A to raster low byte / compare target.
; WHY: Update raster low byte / compare target while we assign the shared sprite pointer to each
; enabled hardware channel.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.  A write programs raster compare low; it does not move the video beam.
    sta $d012
; WHAT: Load A from 1 (literal value).
; WHY: Prepare the value for VIC pending interrupt flags.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #1
; WHAT: Copy A to VIC pending interrupt flags.
; WHY: Update VIC pending interrupt flags while we assign the shared sprite pointer to each
; enabled hardware channel.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged. Writing a 1 acknowledges the corresponding pending VIC flag, not an ordinary
; RAM assignment.
    sta $d019
; WHAT: Load A from <irq (literal value).
; WHY: Prepare the value for KERNAL IRQ vector low byte.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #<irq
; WHAT: Copy A to KERNAL IRQ vector low byte.
; WHY: Update KERNAL IRQ vector low byte while we assign the shared sprite pointer to each
; enabled hardware channel.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $0314
; WHAT: Load A from >irq (literal value).
; WHY: Prepare the value for KERNAL IRQ vector high byte.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #>irq
; WHAT: Copy A to KERNAL IRQ vector high byte.
; WHY: Update KERNAL IRQ vector high byte while we assign the shared sprite pointer to each
; enabled hardware channel.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $0315
; WHAT: Load A from VIC interrupt enables.
; WHY: Fetch VIC interrupt enables while we assign the shared sprite pointer to each enabled
; hardware channel.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda $d01a
; WHAT: A = A OR #1.
; WHY: Select, combine or constrain the bits used to assign the shared sprite pointer to each
; enabled hardware channel.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    ora #1
; WHAT: Copy A to VIC interrupt enables.
; WHY: Update VIC interrupt enables while we assign the shared sprite pointer to each enabled
; hardware channel.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d01a
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

; Bubble-sort ten INDEXES, not sprite records.
; WHAT: Define address label sort_by_y.
; WHY: Name the entry or data location used to sort logical indices by increasing Y.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
sort_by_y:
; WHAT: Load X from 0 (literal value).
; WHY: Set the literal value needed to sort logical indices by increasing Y.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    ldx #0
; WHAT: Define address label init_order.
; WHY: Name the entry or data location used to initialise the order table with consecutive
; indices.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
init_order:
; WHAT: A = X.
; WHY: Bring an index into arithmetic/logic register A.
; HOW: Bring an index into arithmetic/logic register A. Among status flags, only N Z change.
    txa
; WHAT: Copy A to logical-index order table.
; WHY: Update logical-index order table while we initialise the order table with consecutive
; indices.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta order,x
; WHAT: Increment X modulo 256.
; WHY: Advance the counter, position or offset used to initialise the order table with
; consecutive indices.
; HOW: Implied/accumulator form; no separate memory operand. Flags updated: N Z.
    inx
; WHAT: Compare X with #10 without changing that register.
; WHY: Set the condition for the following branch in init_order.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cpx #10
; WHAT: Branch when Z=0; target is init_order.
; WHY: Choose the path that continues or completes initialise the order table with consecutive
; indices.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne init_order

; WHAT: Load A from 9 (literal value).
; WHY: Prepare the value for remaining bubble-sort passes.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #9
; WHAT: Copy A to remaining bubble-sort passes.
; WHY: Update remaining bubble-sort passes while we initialise the order table with consecutive
; indices.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta passes
; WHAT: Define address label sort_pass.
; WHY: Name the entry or data location used to start another adjacent-pair sorting pass.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
sort_pass:
; WHAT: Load X from 0 (literal value).
; WHY: Set the literal value needed to start another adjacent-pair sorting pass.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    ldx #0
; WHAT: Define address label compare_pair.
; WHY: Name the entry or data location used to compare two Y values reached through adjacent
; order entries.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
compare_pair:
; WHAT: Load Y from logical-index order table.
; WHY: Fetch logical-index order table while we compare two Y values reached through adjacent
; order entries.
; HOW: Indexed address: add the index register to the named base address. Flags updated: N Z.
    ldy order,x
; WHAT: Load A from logical sprite Y table.
; WHY: Fetch logical sprite Y table while we compare two Y values reached through adjacent order
; entries.
; HOW: Indexed address: add the index register to the named base address. Flags updated: N Z.
    lda sprite_y,y
; WHAT: Copy A to first Y value of an adjacent pair.
; WHY: Update first Y value of an adjacent pair while we compare two Y values reached through
; adjacent order entries.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta first_y
; WHAT: Load Y from order+1.
; WHY: Fetch order+1 while we compare two Y values reached through adjacent order entries.
; HOW: Indexed address: add the index register to the named base address. Flags updated: N Z.
    ldy order+1,x
; WHAT: Load A from logical sprite Y table.
; WHY: Fetch logical sprite Y table while we compare two Y values reached through adjacent order
; entries.
; HOW: Indexed address: add the index register to the named base address. Flags updated: N Z.
    lda sprite_y,y
; WHAT: Compare A with first_y without changing that register.
; WHY: Set the condition for the following branch in compare_pair.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cmp first_y
; WHAT: Branch when C=1; target is already_sorted.
; WHY: Choose the path that continues or completes compare two Y values reached through adjacent
; order entries.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bcs already_sorted

    ; Swap adjacent indices in the order table.
; WHAT: Load A from logical-index order table.
; WHY: Fetch logical-index order table while we compare two Y values reached through adjacent
; order entries.
; HOW: Indexed address: add the index register to the named base address. Flags updated: N Z.
    lda order,x
; WHAT: Copy A to order+1.
; WHY: Update order+1 while we compare two Y values reached through adjacent order entries.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta order+1,x
; WHAT: A = Y.
; WHY: Bring an index into A for arithmetic or shifting.
; HOW: Bring an index into A for arithmetic or shifting. Among status flags, only N Z change.
    tya
; WHAT: Copy A to logical-index order table.
; WHY: Update logical-index order table while we compare two Y values reached through adjacent
; order entries.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta order,x
; WHAT: Define address label already_sorted.
; WHY: Name the entry or data location used to advance the sorting pair or finish the current
; pass.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
already_sorted:
; WHAT: Increment X modulo 256.
; WHY: Advance the counter, position or offset used to advance the sorting pair or finish the
; current pass.
; HOW: Implied/accumulator form; no separate memory operand. Flags updated: N Z.
    inx
; WHAT: Compare X with passes without changing that register.
; WHY: Set the condition for the following branch in already_sorted.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cpx passes
; WHAT: Branch when Z=0; target is compare_pair.
; WHY: Choose the path that continues or completes advance the sorting pair or finish the
; current pass.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne compare_pair
; WHAT: Decrement remaining bubble-sort passes modulo 256.
; WHY: Advance the counter, position or offset used to advance the sorting pair or finish the
; current pass.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z. NMOS memory read-modify-write writes the old byte before the new one; avoid
; applying this blindly to I/O.
    dec passes
; WHAT: Branch when Z=0; target is sort_pass.
; WHY: Choose the path that continues or completes advance the sorting pair or finish the
; current pass.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne sort_pass
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
; WHAT: A = X.
; WHY: Bring an index into arithmetic/logic register A.
; HOW: Bring an index into arithmetic/logic register A. Among status flags, only N Z change.
    txa
; WHAT: Push A on page-1 stack.
; WHY: Decrement SP after the write; A remains unchanged.
; HOW: Decrement SP after the write; A remains unchanged. Other registers are not implicitly
; saved.
    pha
; WHAT: A = Y.
; WHY: Bring an index into A for arithmetic or shifting.
; HOW: Bring an index into A for arithmetic or shifting. Among status flags, only N Z change.
    tya
; WHAT: Push A on page-1 stack.
; WHY: Decrement SP after the write; A remains unchanged.
; HOW: Decrement SP after the write; A remains unchanged. Other registers are not implicitly
; saved.
    pha
; WHAT: Load A from VIC pending interrupt flags.
; WHY: Fetch VIC pending interrupt flags while we acknowledge and dispatch the scheduled raster
; event.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda $d019
; WHAT: A = A AND #1.
; WHY: Select, combine or constrain the bits used to acknowledge and dispatch the scheduled
; raster event.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    and #1
; WHAT: Branch when Z=0; target is raster_pending.
; WHY: Choose the path that continues or completes acknowledge and dispatch the scheduled raster
; event.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne raster_pending
; WHAT: Continue execution at irq_exit.
; WHY: Repeat the main loop or join the named control path.
; HOW: Absolute JMP changes PC without stacking a return address; flags are unchanged.
    jmp irq_exit
; WHAT: Define address label raster_pending.
; WHY: Name the entry or data location used to process the raster-only path after the long-
; branch repair.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
raster_pending:
; WHAT: Load A from 1 (literal value).
; WHY: Prepare the value for VIC pending interrupt flags.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #1
; WHAT: Copy A to VIC pending interrupt flags.
; WHY: Update VIC pending interrupt flags while we process the raster-only path after the long-
; branch repair.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged. Writing a 1 acknowledges the corresponding pending VIC flag, not an ordinary
; RAM assignment.
    sta $d019
; WHAT: Load A from selected multiplexer band.
; WHY: Fetch selected multiplexer band while we process the raster-only path after the long-
; branch repair.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda phase
; WHAT: Branch when Z=0; target is lower.
; WHY: Choose the path that continues or completes process the raster-only path after the long-
; branch repair.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne lower

; WHAT: Define address label upper.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
upper:
    ; Eight sorted objects -> channels 0..7.
; WHAT: Load X from 0 (literal value).
; WHY: Set the literal value needed to perform this step.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    ldx #0
; WHAT: Define address label upper_loop.
; WHY: Name the entry or data location used to copy the next logical object into an upper-pass
; hardware channel.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
upper_loop:
; WHAT: Load Y from logical-index order table.
; WHY: Fetch logical-index order table while we copy the next logical object into an upper-pass
; hardware channel.
; HOW: Indexed address: add the index register to the named base address. Flags updated: N Z.
    ldy order,x
; WHAT: Load A from logical sprite X table.
; WHY: Fetch logical sprite X table while we copy the next logical object into an upper-pass
; hardware channel.
; HOW: Indexed address: add the index register to the named base address. Flags updated: N Z.
    lda sprite_x,y
; WHAT: Copy A to temporary object X.
; WHY: Update temporary object X while we copy the next logical object into an upper-pass
; hardware channel.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta value_x
; WHAT: Load A from logical sprite Y table.
; WHY: Fetch logical sprite Y table while we copy the next logical object into an upper-pass
; hardware channel.
; HOW: Indexed address: add the index register to the named base address. Flags updated: N Z.
    lda sprite_y,y
; WHAT: Copy A to temporary object Y.
; WHY: Update temporary object Y while we copy the next logical object into an upper-pass
; hardware channel.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta value_y
; WHAT: Load A from logical sprite colour table.
; WHY: Fetch logical sprite colour table while we copy the next logical object into an upper-
; pass hardware channel.
; HOW: Indexed address: add the index register to the named base address. Flags updated: N Z.
    lda sprite_color,y
; WHAT: Copy A to temporary object colour.
; WHY: Update temporary object colour while we copy the next logical object into an upper-pass
; hardware channel.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta value_color

; WHAT: A = X.
; WHY: Bring an index into arithmetic/logic register A.
; HOW: Bring an index into arithmetic/logic register A. Among status flags, only N Z change.
    txa
; WHAT: Shift left; old bit 7 enters C; bit 0 becomes 0.
; WHY: Scale a value or form a register/table offset for copy the next logical object into an
; upper-pass hardware channel.
; HOW: Implied/accumulator form; no separate memory operand. Flags updated: N Z C.  Unsigned
; multiply by two modulo 256.
    asl
; WHAT: Y = A.
; WHY: Transfer a copy into the Y index.
; HOW: Transfer a copy into the Y index. Among status flags, only N Z change.
    tay
; WHAT: Load A from temporary object X.
; WHY: Fetch temporary object X while we copy the next logical object into an upper-pass
; hardware channel.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda value_x
; WHAT: Copy A to sprite 0 X low byte.
; WHY: Update sprite 0 X low byte while we copy the next logical object into an upper-pass
; hardware channel.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta $d000,y
; WHAT: Load A from temporary object Y.
; WHY: Fetch temporary object Y while we copy the next logical object into an upper-pass
; hardware channel.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda value_y
; WHAT: Copy A to sprite 0 Y coordinate.
; WHY: Update sprite 0 Y coordinate while we copy the next logical object into an upper-pass
; hardware channel.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta $d001,y
; WHAT: Load A from temporary object colour.
; WHY: Fetch temporary object colour while we copy the next logical object into an upper-pass
; hardware channel.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda value_color
; WHAT: Copy A to sprite 0 colour / colour-register base.
; WHY: Update sprite 0 colour / colour-register base while we copy the next logical object into
; an upper-pass hardware channel.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta $d027,x

; WHAT: Increment X modulo 256.
; WHY: Advance the counter, position or offset used to copy the next logical object into an
; upper-pass hardware channel.
; HOW: Implied/accumulator form; no separate memory operand. Flags updated: N Z.
    inx
; WHAT: Compare X with #8 without changing that register.
; WHY: Set the condition for the following branch in upper_loop.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cpx #8
; WHAT: Branch when Z=0; target is upper_loop.
; WHY: Choose the path that continues or completes copy the next logical object into an upper-
; pass hardware channel.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne upper_loop

; WHAT: Load A from 1 (literal value).
; WHY: Prepare the value for selected multiplexer band.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #1
; WHAT: Copy A to selected multiplexer band.
; WHY: Update selected multiplexer band while we copy the next logical object into an upper-pass
; hardware channel.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta phase
; WHAT: Load A from 145 (literal value).
; WHY: Prepare the value for raster low byte / compare target.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #145
; WHAT: Copy A to raster low byte / compare target.
; WHY: Update raster low byte / compare target while we copy the next logical object into an
; upper-pass hardware channel.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.  A write programs raster compare low; it does not move the video beam.
    sta $d012
; WHAT: Continue execution at irq_exit.
; WHY: Repeat the main loop or join the named control path.
; HOW: Absolute JMP changes PC without stacking a return address; flags are unchanged.
    jmp irq_exit

; WHAT: Define address label lower.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
lower:
    ; Sorted objects 8 and 9 -> channels 0,1.
; WHAT: Load X from 0 (literal value).
; WHY: Set the literal value needed to perform this step.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    ldx #0
; WHAT: Define address label lower_loop.
; WHY: Name the entry or data location used to reuse a finished hardware channel for a later
; object.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
lower_loop:
; WHAT: Load Y from order+8.
; WHY: Fetch order+8 while we reuse a finished hardware channel for a later object.
; HOW: Indexed address: add the index register to the named base address. Flags updated: N Z.
    ldy order+8,x
; WHAT: Load A from logical sprite X table.
; WHY: Fetch logical sprite X table while we reuse a finished hardware channel for a later
; object.
; HOW: Indexed address: add the index register to the named base address. Flags updated: N Z.
    lda sprite_x,y
; WHAT: Copy A to temporary object X.
; WHY: Update temporary object X while we reuse a finished hardware channel for a later object.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta value_x
; WHAT: Load A from logical sprite Y table.
; WHY: Fetch logical sprite Y table while we reuse a finished hardware channel for a later
; object.
; HOW: Indexed address: add the index register to the named base address. Flags updated: N Z.
    lda sprite_y,y
; WHAT: Copy A to temporary object Y.
; WHY: Update temporary object Y while we reuse a finished hardware channel for a later object.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta value_y
; WHAT: Load A from logical sprite colour table.
; WHY: Fetch logical sprite colour table while we reuse a finished hardware channel for a later
; object.
; HOW: Indexed address: add the index register to the named base address. Flags updated: N Z.
    lda sprite_color,y
; WHAT: Copy A to temporary object colour.
; WHY: Update temporary object colour while we reuse a finished hardware channel for a later
; object.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta value_color

; WHAT: A = X.
; WHY: Bring an index into arithmetic/logic register A.
; HOW: Bring an index into arithmetic/logic register A. Among status flags, only N Z change.
    txa
; WHAT: Shift left; old bit 7 enters C; bit 0 becomes 0.
; WHY: Scale a value or form a register/table offset for reuse a finished hardware channel for a
; later object.
; HOW: Implied/accumulator form; no separate memory operand. Flags updated: N Z C.  Unsigned
; multiply by two modulo 256.
    asl
; WHAT: Y = A.
; WHY: Transfer a copy into the Y index.
; HOW: Transfer a copy into the Y index. Among status flags, only N Z change.
    tay
; WHAT: Load A from temporary object X.
; WHY: Fetch temporary object X while we reuse a finished hardware channel for a later object.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda value_x
; WHAT: Copy A to sprite 0 X low byte.
; WHY: Update sprite 0 X low byte while we reuse a finished hardware channel for a later object.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta $d000,y
; WHAT: Load A from temporary object Y.
; WHY: Fetch temporary object Y while we reuse a finished hardware channel for a later object.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda value_y
; WHAT: Copy A to sprite 0 Y coordinate.
; WHY: Update sprite 0 Y coordinate while we reuse a finished hardware channel for a later
; object.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta $d001,y
; WHAT: Load A from temporary object colour.
; WHY: Fetch temporary object colour while we reuse a finished hardware channel for a later
; object.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda value_color
; WHAT: Copy A to sprite 0 colour / colour-register base.
; WHY: Update sprite 0 colour / colour-register base while we reuse a finished hardware channel
; for a later object.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta $d027,x

; WHAT: Increment X modulo 256.
; WHY: Advance the counter, position or offset used to reuse a finished hardware channel for a
; later object.
; HOW: Implied/accumulator form; no separate memory operand. Flags updated: N Z.
    inx
; WHAT: Compare X with #2 without changing that register.
; WHY: Set the condition for the following branch in lower_loop.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cpx #2
; WHAT: Branch when Z=0; target is lower_loop.
; WHY: Choose the path that continues or completes reuse a finished hardware channel for a later
; object.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne lower_loop

; WHAT: Load A from 0 (literal value).
; WHY: Prepare the value for selected multiplexer band.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #0
; WHAT: Copy A to selected multiplexer band.
; WHY: Update selected multiplexer band while we reuse a finished hardware channel for a later
; object.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta phase
; WHAT: Load A from 40 (literal value).
; WHY: Prepare the value for raster low byte / compare target.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #40
; WHAT: Copy A to raster low byte / compare target.
; WHY: Update raster low byte / compare target while we reuse a finished hardware channel for a
; later object.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.  A write programs raster compare low; it does not move the video beam.
    sta $d012

; WHAT: Define address label irq_exit.
; WHY: Name the entry or data location used to restore extra saved registers and continue normal
; KERNAL IRQ service.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
irq_exit:
; WHAT: Pull one byte from stack into A.
; WHY: Increment SP before reading.
; HOW: Increment SP before reading. Among status flags, only N Z change.
    pla
; WHAT: Y = A.
; WHY: Transfer a copy into the Y index.
; HOW: Transfer a copy into the Y index. Among status flags, only N Z change.
    tay
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
; WHY: Initialise selected multiplexer band; successive entries are adjacent bytes.
; HOW: The label phase names this data address. These are stored data, not CPU instructions.
; Binary row bits run left to right from the high bit of each byte; table indices start at zero.
phase:       !byte 0
; WHAT: Emit 1 literal byte.
; WHY: Initialise remaining bubble-sort passes; successive entries are adjacent bytes.
; HOW: The label passes names this data address. These are stored data, not CPU instructions.
; Binary row bits run left to right from the high bit of each byte; table indices start at zero.
passes:      !byte 0
; WHAT: Emit 1 literal byte.
; WHY: Initialise first Y value of an adjacent pair; successive entries are adjacent bytes.
; HOW: The label first_y names this data address. These are stored data, not CPU instructions.
; Binary row bits run left to right from the high bit of each byte; table indices start at zero.
first_y:     !byte 0
; WHAT: Emit 1 literal byte.
; WHY: Initialise temporary object X; successive entries are adjacent bytes.
; HOW: The label value_x names this data address. These are stored data, not CPU instructions.
; Binary row bits run left to right from the high bit of each byte; table indices start at zero.
value_x:     !byte 0
; WHAT: Emit 1 literal byte.
; WHY: Initialise temporary object Y; successive entries are adjacent bytes.
; HOW: The label value_y names this data address. These are stored data, not CPU instructions.
; Binary row bits run left to right from the high bit of each byte; table indices start at zero.
value_y:     !byte 0
; WHAT: Emit 1 literal byte.
; WHY: Initialise temporary object colour; successive entries are adjacent bytes.
; HOW: The label value_color names this data address. These are stored data, not CPU
; instructions. Binary row bits run left to right from the high bit of each byte; table indices
; start at zero.
value_color: !byte 0
; WHAT: Emit the stated count of repeated bytes.
; WHY: Allocate and initialise logical-index order table or the sprite artwork.
; HOW: The label order names this data address. ACME creates data during assembly; !fill 12,0
; produces twelve zeros, while !fill 63,$ff produces 21 solid three-byte sprite rows.
order:       !fill 10,0

; Intentionally unsorted input.
; WHAT: Define address label sprite_x.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
sprite_x:
; WHAT: Emit 10 literal bytes.
; WHY: Initialise logical sprite X table; successive entries are adjacent bytes.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
    !byte 55,65,85,110,135,160,185,210,235,125
; WHAT: Define address label sprite_y.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
sprite_y:
; WHAT: Emit 10 literal bytes.
; WHY: Initialise logical sprite Y table; successive entries are adjacent bytes.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
    !byte 200,72,188,103,85,209,96,78,192,110
; WHAT: Define address label sprite_color.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
sprite_color:
; WHAT: Emit 10 literal bytes.
; WHY: Initialise logical sprite colour table; successive entries are adjacent bytes.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
    !byte 2,3,4,5,6,7,8,9,10,14
