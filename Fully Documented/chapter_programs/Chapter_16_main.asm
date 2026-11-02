; ========================================================================
; Chapter_16_main.asm - documented ACME source
; Every code-bearing line has WHAT, WHY and HOW comments.
; WHAT describes the operation. WHY explains its role. HOW explains encoding,
; flags, addressing, hardware effects or control flow.
; Code comments do not change the generated program bytes.
; PURPOSE: Alternate two raster targets and border colours using a state byte.
; FLOW: The first event sets red and schedules line 160; the next sets blue and schedules line
; 80 for the next frame. next records which stage should run. The handler ignores non-raster
; invocations and chains KERNAL service.
; TRY: Choose two new lines that remain below 256 and are comfortably separated.
; ASSUMPTIONS: The state byte is initialised by its loaded data, not explicitly reset in
; start. Reset/reload for a clean start. This is a simple colour split, not a cycle-stable
; raster effect.
; ASSEMBLE: Select CBM format and an output name using the command line.
; Example from the companion root:
; acme --strict-segments -f cbm -o demo.prg chapter_programs/Chapter_16_main.asm
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
; WHAT: Load A from vertical/control register with mixed raster read/write bit.
; WHY: Fetch vertical/control register with mixed raster read/write bit while we prepare the
; program before display updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.  Bit 7 read is current raster high; writing that bit later changes the compare
; high bit.
    lda $d011
; WHAT: A = A AND #$7f.
; WHY: Select, combine or constrain the bits used to prepare the program before display updates
; begin.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    and #$7f
; WHAT: Copy A to vertical/control register with mixed raster read/write bit.
; WHY: Update vertical/control register with mixed raster read/write bit while we prepare the
; program before display updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.  Bits 0-2 select fine Y; bit 7 written selects raster compare high, unlike its
; read meaning.
    sta $d011
; WHAT: Load A from 80 (literal value).
; WHY: Prepare the value for raster low byte / compare target.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #80
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
; WHY: Update VIC pending interrupt flags while we prepare the program before display updates
; begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged. Writing a 1 acknowledges the corresponding pending VIC flag, not an ordinary
; RAM assignment.
    sta $d019
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
; WHY: Update VIC interrupt enables while we prepare the program before display updates begin.
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
; WHAT: Branch when Z=1; target is done.
; WHY: Choose the path that continues or completes acknowledge and dispatch the scheduled raster
; event.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    beq done
; WHAT: Load A from 1 (literal value).
; WHY: Prepare the value for VIC pending interrupt flags.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #1
; WHAT: Copy A to VIC pending interrupt flags.
; WHY: Update VIC pending interrupt flags while we acknowledge and dispatch the scheduled raster
; event.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged. Writing a 1 acknowledges the corresponding pending VIC flag, not an ordinary
; RAM assignment.
    sta $d019
; WHAT: Load A from two-stage raster state.
; WHY: Fetch two-stage raster state while we acknowledge and dispatch the scheduled raster
; event.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda next
; WHAT: Branch when Z=0; target is second.
; WHY: Choose the path that continues or completes acknowledge and dispatch the scheduled raster
; event.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne second
; WHAT: Define address label first.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
first:
; WHAT: Load A from 2 (literal value).
; WHY: Prepare the value for border colour.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #2
; WHAT: Copy A to border colour.
; WHY: Update border colour while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d020
; WHAT: Load A from 160 (literal value).
; WHY: Prepare the value for raster low byte / compare target.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #160
; WHAT: Copy A to raster low byte / compare target.
; WHY: Update raster low byte / compare target while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.  A write programs raster compare low; it does not move the video beam.
    sta $d012
; WHAT: Load A from 1 (literal value).
; WHY: Prepare the value for two-stage raster state.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #1
; WHAT: Copy A to two-stage raster state.
; WHY: Update two-stage raster state while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta next
; WHAT: Continue execution at done.
; WHY: Repeat the main loop or join the named control path.
; HOW: Absolute JMP changes PC without stacking a return address; flags are unchanged.
    jmp done
; WHAT: Define address label second.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
second:
; WHAT: Load A from 6 (literal value).
; WHY: Prepare the value for border colour.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #6
; WHAT: Copy A to border colour.
; WHY: Update border colour while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d020
; WHAT: Load A from 80 (literal value).
; WHY: Prepare the value for raster low byte / compare target.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #80
; WHAT: Copy A to raster low byte / compare target.
; WHY: Update raster low byte / compare target while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.  A write programs raster compare low; it does not move the video beam.
    sta $d012
; WHAT: Load A from 0 (literal value).
; WHY: Prepare the value for two-stage raster state.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #0
; WHAT: Copy A to two-stage raster state.
; WHY: Update two-stage raster state while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta next
; WHAT: Define address label done.
; WHY: Name the entry or data location used to restore the handler state or return from the
; current step.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
done:
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
; WHY: Initialise two-stage raster state; successive entries are adjacent bytes.
; HOW: The label next names this data address. These are stored data, not CPU instructions.
; Binary row bits run left to right from the high bit of each byte; table indices start at zero.
next: !byte 0
