; ========================================================================
; Chapter_01_moving_irq.asm - documented ACME source
; Every code-bearing line has WHAT, WHY and HOW comments.
; WHAT describes the operation. WHY explains its role. HOW explains encoding,
; flags, addressing, hardware effects or control flow.
; Code comments do not change the generated program bytes.
; PURPOSE: Move an A along one screen row at a reduced update rate.
; FLOW: Every IRQ increments delay_counter. At six ticks, the routine resets it, erases the
; old cell with screen code 32, advances position modulo 40 and writes screen code 1 at
; $0540+position.
; TRY: Change CMP #6 to #12: movement takes twice as many IRQ ticks per step. $0540 is row 8,
; column 0.
; ASSUMPTIONS: This uses screen codes and existing colour RAM, not a sprite. It uses the
; system timer, not a PAL frame counter. The extra A/X pushes are balanced before $EA31; ROM
; already saved the interrupted register set.
; ASSEMBLE: Select CBM format and an output name using the command line.
; Example from the companion root:
; acme --strict-segments -f cbm -o demo.prg chapter_programs/Chapter_01_moving_irq.asm
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
; WHAT: Load A from 0 (literal value).
; WHY: Prepare the value for IRQ tick divider.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #0
; WHAT: Copy A to IRQ tick divider.
; WHY: Update IRQ tick divider while we prepare the program before display updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta delay_counter
; WHAT: Copy A to screen-column position.
; WHY: Update screen-column position while we prepare the program before display updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta position
; WHAT: Load A from <irq_routine (literal value).
; WHY: Prepare the value for KERNAL IRQ vector low byte.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #<irq_routine
; WHAT: Copy A to KERNAL IRQ vector low byte.
; WHY: Update KERNAL IRQ vector low byte while we prepare the program before display updates
; begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $0314
; WHAT: Load A from >irq_routine (literal value).
; WHY: Prepare the value for KERNAL IRQ vector high byte.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #>irq_routine
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
; WHAT: Define address label irq_routine.
; WHY: Name the entry or data location used to handle the system or raster interrupt before
; KERNAL continuation.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
irq_routine:
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
; WHAT: Increment IRQ tick divider modulo 256.
; WHY: Advance the counter, position or offset used to handle the system or raster interrupt
; before KERNAL continuation.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z. NMOS memory read-modify-write writes the old byte before the new one; avoid
; applying this blindly to I/O.
    inc delay_counter
; WHAT: Load A from IRQ tick divider.
; WHY: Fetch IRQ tick divider while we handle the system or raster interrupt before KERNAL
; continuation.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda delay_counter
; WHAT: Compare A with #6 without changing that register.
; WHY: Set the condition for the following branch in irq_routine.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cmp #6
; WHAT: Branch when Z=0; target is irq_exit.
; WHY: Choose the path that continues or completes handle the system or raster interrupt before
; KERNAL continuation.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne irq_exit
; WHAT: Load A from 0 (literal value).
; WHY: Prepare the value for IRQ tick divider.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #0
; WHAT: Copy A to IRQ tick divider.
; WHY: Update IRQ tick divider while we handle the system or raster interrupt before KERNAL
; continuation.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta delay_counter
; WHAT: Load X from screen-column position.
; WHY: Fetch screen-column position while we handle the system or raster interrupt before KERNAL
; continuation.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    ldx position
; WHAT: Load A from 32 (literal value).
; WHY: Prepare the value for $0540.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #32
; WHAT: Copy A to $0540.
; WHY: Update $0540 while we handle the system or raster interrupt before KERNAL continuation.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta $0540,x
; WHAT: Increment X modulo 256.
; WHY: Advance the counter, position or offset used to handle the system or raster interrupt
; before KERNAL continuation.
; HOW: Implied/accumulator form; no separate memory operand. Flags updated: N Z.
    inx
; WHAT: Compare X with #40 without changing that register.
; WHY: Set the condition for the following branch in irq_routine.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cpx #40
; WHAT: Branch when Z=0; target is store_position.
; WHY: Choose the path that continues or completes handle the system or raster interrupt before
; KERNAL continuation.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne store_position
; WHAT: Load X from 0 (literal value).
; WHY: Set the literal value needed to handle the system or raster interrupt before KERNAL
; continuation.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    ldx #0
; WHAT: Define address label store_position.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
store_position:
; WHAT: Copy X to screen-column position.
; WHY: Update screen-column position while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    stx position
; WHAT: Load A from 1 (literal value).
; WHY: Prepare the value for $0540.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #1
; WHAT: Copy A to $0540.
; WHY: Update $0540 while we process this section.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta $0540,x
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
; WHY: Initialise IRQ tick divider; successive entries are adjacent bytes.
; HOW: The label delay_counter names this data address. These are stored data, not CPU
; instructions. Binary row bits run left to right from the high bit of each byte; table indices
; start at zero.
delay_counter: !byte 0
; WHAT: Emit 1 literal byte.
; WHY: Initialise screen-column position; successive entries are adjacent bytes.
; HOW: The label position names this data address. These are stored data, not CPU instructions.
; Binary row bits run left to right from the high bit of each byte; table indices start at zero.
position:      !byte 0
