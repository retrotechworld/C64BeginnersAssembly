; ========================================================================
; Chapter_05_main.asm - documented ACME source
; Every code-bearing line has WHAT, WHY and HOW comments.
; WHAT describes the operation. WHY explains its role. HOW explains encoding,
; flags, addressing, hardware effects or control flow.
; Code comments do not change the generated program bytes.
; PURPOSE: Describe nine logical objects with X, Y and colour arrays.
; FLOW: At line 40, upper_loop copies logical entries 0-7 into hardware channels 0-7. At line
; 145, lower_band copies entry 8 into channel 0. TXA/ASL/TAY converts channel number to an X/Y
; register-pair offset.
; TRY: Change only sprite_colour+8, then only sprite_x+8. Identify which visible object
; changes.
; ASSUMPTIONS: Tables have nine entries and hardware masks eight bits. The selected Y values
; allow channel 0 reuse; arbitrary new Y values may not. This is a fixed schedule, not a
; general scheduler.
; ASSEMBLE: Select CBM format and an output name using the command line.
; Example from the companion root:
; acme --strict-segments -f cbm -o demo.prg chapter_programs/Chapter_05_main.asm
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
    ; Sprite shape at $3000 (64-byte slot).
; WHAT: Load X from 0 (literal value).
; WHY: Set the literal value needed to prepare the program before display updates begin.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    ldx #0
; WHAT: Define address label make_shape.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
make_shape:
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
; WHY: Set the condition for the following branch in make_shape.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cpx #63
; WHAT: Branch when Z=0; target is make_shape.
; WHY: Choose the path that continues or completes this operation.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne make_shape
; WHAT: Load A from 0 (literal value).
; WHY: Prepare the value for sprite slot padding.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #0
; WHAT: Copy A to sprite slot padding.
; WHY: Update sprite slot padding while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $303f

    ; Enable all eight sprite channels.
; WHAT: Load A from $ff (literal value).
; WHY: Prepare the value for sprite-enable mask.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #$ff
; WHAT: Copy A to sprite-enable mask.
; WHY: Update sprite-enable mask while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.  Bit n enables hardware sprite channel n when it is 1.
    sta $d015
; WHAT: Load A from 0 (literal value).
; WHY: Prepare the value for sprite X-high-bit mask.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #0
; WHAT: Copy A to sprite X-high-bit mask.
; WHY: all X values below 256.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.  Bit n supplies X bit 8 for hardware sprite n.
    sta $d010       ; all X values below 256
; WHAT: Copy A to sprite Y-expansion mask.
; WHY: normal sprite height.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d017       ; normal sprite height
; WHAT: Copy A to sprite X-expansion mask.
; WHY: normal sprite width.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d01d       ; normal sprite width

    ; Set sprite pointers for screen at $0400.
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
; WHY: $3000 / 64.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #$c0        ; $3000 / 64
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
; WHY: raster high bit = 0.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    and #$7f        ; raster high bit = 0
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
; WHY: acknowledge old raster IRQ.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged. Writing a 1 acknowledges the corresponding pending VIC flag, not an ordinary
; RAM assignment.
    sta $d019      ; acknowledge old raster IRQ

; WHAT: Load A from <irq_handler (literal value).
; WHY: Prepare the value for KERNAL IRQ vector low byte.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #<irq_handler
; WHAT: Copy A to KERNAL IRQ vector low byte.
; WHY: Update KERNAL IRQ vector low byte while we assign the shared sprite pointer to each
; enabled hardware channel.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $0314
; WHAT: Load A from >irq_handler (literal value).
; WHY: Prepare the value for KERNAL IRQ vector high byte.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #>irq_handler
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
; WHY: enable VIC raster IRQ.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d01a      ; enable VIC raster IRQ
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
; WHAT: Branch when Z=1; target is done.
; WHY: Choose the path that continues or completes test the raster source and update the
; scheduled display stage.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    beq done
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

; WHAT: Load A from selected multiplexer band.
; WHY: Fetch selected multiplexer band while we test the raster source and update the scheduled
; display stage.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda phase
; WHAT: Branch when Z=0; target is lower_band.
; WHY: Choose the path that continues or completes test the raster source and update the
; scheduled display stage.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne lower_band

; WHAT: Define address label upper_band.
; WHY: Name the entry or data location used to configure the first group of logical objects.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
upper_band:
    ; Draw logical sprites 0..7 in the upper area.
; WHAT: Load X from 0 (literal value).
; WHY: Set the literal value needed to configure the first group of logical objects.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    ldx #0
; WHAT: Define address label upper_loop.
; WHY: Name the entry or data location used to copy the next logical object into an upper-pass
; hardware channel.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
upper_loop:
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
; WHAT: Load A from logical sprite X table.
; WHY: Fetch logical sprite X table while we copy the next logical object into an upper-pass
; hardware channel.
; HOW: Indexed address: add the index register to the named base address. Flags updated: N Z.
    lda sprite_x,x
; WHAT: Copy A to sprite 0 X low byte.
; WHY: Update sprite 0 X low byte while we copy the next logical object into an upper-pass
; hardware channel.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta $d000,y
; WHAT: Load A from logical sprite Y table.
; WHY: Fetch logical sprite Y table while we copy the next logical object into an upper-pass
; hardware channel.
; HOW: Indexed address: add the index register to the named base address. Flags updated: N Z.
    lda sprite_y,x
; WHAT: Copy A to sprite 0 Y coordinate.
; WHY: Update sprite 0 Y coordinate while we copy the next logical object into an upper-pass
; hardware channel.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta $d001,y
; WHAT: Load A from logical sprite colour table.
; WHY: Fetch logical sprite colour table while we copy the next logical object into an upper-
; pass hardware channel.
; HOW: Indexed address: add the index register to the named base address. Flags updated: N Z.
    lda sprite_colour,x
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
; WHAT: Continue execution at done.
; WHY: Repeat the main loop or join the named control path.
; HOW: Absolute JMP changes PC without stacking a return address; flags are unchanged.
    jmp done

; WHAT: Define address label lower_band.
; WHY: Name the entry or data location used to reuse completed hardware channels for the later
; group.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
lower_band:
    ; Reuse hardware sprite channel 0
    ; for logical sprite number 8.
; WHAT: Load A from sprite_x+8.
; WHY: Fetch sprite_x+8 while we reuse completed hardware channels for the later group.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda sprite_x+8
; WHAT: Copy A to sprite 0 X low byte.
; WHY: Update sprite 0 X low byte while we reuse completed hardware channels for the later
; group.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d000
; WHAT: Load A from sprite_y+8.
; WHY: Fetch sprite_y+8 while we reuse completed hardware channels for the later group.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda sprite_y+8
; WHAT: Copy A to sprite 0 Y coordinate.
; WHY: Update sprite 0 Y coordinate while we reuse completed hardware channels for the later
; group.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d001
; WHAT: Load A from sprite_colour+8.
; WHY: Fetch sprite_colour+8 while we reuse completed hardware channels for the later group.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda sprite_colour+8
; WHAT: Copy A to sprite 0 colour / colour-register base.
; WHY: Update sprite 0 colour / colour-register base while we reuse completed hardware channels
; for the later group.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d027

; WHAT: Load A from 0 (literal value).
; WHY: Prepare the value for selected multiplexer band.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #0
; WHAT: Copy A to selected multiplexer band.
; WHY: Update selected multiplexer band while we reuse completed hardware channels for the later
; group.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta phase
; WHAT: Load A from 40 (literal value).
; WHY: Prepare the value for raster low byte / compare target.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #40
; WHAT: Copy A to raster low byte / compare target.
; WHY: Update raster low byte / compare target while we reuse completed hardware channels for
; the later group.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.  A write programs raster compare low; it does not move the video beam.
    sta $d012

; WHAT: Define address label done.
; WHY: Name the entry or data location used to restore the handler state or return from the
; current step.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
done:
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
phase: !byte 0

; First eight are high on screen; ninth is lower.
; WHAT: Define address label sprite_x.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
sprite_x:
; WHAT: Emit 9 literal bytes.
; WHY: Initialise logical sprite X table; successive entries are adjacent bytes.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
    !byte 45,75,105,135,165,195,225,245,140
; WHAT: Define address label sprite_y.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
sprite_y:
; WHAT: Emit 9 literal bytes.
; WHY: Initialise logical sprite Y table; successive entries are adjacent bytes.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
    !byte 70,70,70,70,100,100,100,100,180
; WHAT: Define address label sprite_colour.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
sprite_colour:
; WHAT: Emit 9 literal bytes.
; WHY: Initialise logical sprite colour table; successive entries are adjacent bytes.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
    !byte 2,3,4,5,6,7,8,9,14
