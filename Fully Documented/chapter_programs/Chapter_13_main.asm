; ========================================================================
; Chapter_13_main.asm - documented ACME source
; Every code-bearing line has WHAT, WHY and HOW comments.
; WHAT describes the operation. WHY explains its role. HOW explains encoding,
; flags, addressing, hardware effects or control flow.
; Code comments do not change the generated program bytes.
; PURPOSE: Start a sawtooth note, wait briefly, then clear gate to release it.
; FLOW: Frequency and ADSR settings initialise voice 1, master volume becomes 15 and control
; $21 starts sawtooth with gate. Nested DEY/DEX loops create a CPU-time delay; control $20
; then releases the envelope.
; TRY: Change frequency high byte from $20 to $10 for approximately one octave lower.
; ASSUMPTIONS: The delay depends on CPU timing and interrupts, not a measured musical
; duration. Clearing gate starts release; it does not instantly mute the sound. SID model and
; PAL/NTSC clocks affect the result.
; ASSEMBLE: Select CBM format and an output name using the command line.
; Example from the companion root:
; acme --strict-segments -f cbm -o demo.prg chapter_programs/Chapter_13_main.asm
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
; WHAT: Load A from 0 (literal value).
; WHY: Prepare the value for SID master volume / filter mode.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #0
; WHAT: Copy A to SID master volume / filter mode.
; WHY: master volume off.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d418       ; master volume off
; WHAT: Copy A to voice 1 waveform and gate.
; WHY: voice 1 gate off.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d404       ; voice 1 gate off
; WHAT: Load A from $11 (literal value).
; WHY: Prepare the value for voice 1 attack and decay.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #$11
; WHAT: Copy A to voice 1 attack and decay.
; WHY: attack/decay.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d405       ; attack/decay
; WHAT: Load A from $f3 (literal value).
; WHY: Prepare the value for voice 1 sustain and release.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #$f3
; WHAT: Copy A to voice 1 sustain and release.
; WHY: sustain/release.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d406       ; sustain/release
; WHAT: Load A from $00 (literal value).
; WHY: Prepare the value for voice 1 frequency low.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #$00
; WHAT: Copy A to voice 1 frequency low.
; WHY: frequency low.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d400       ; frequency low
; WHAT: Load A from $20 (literal value).
; WHY: Prepare the value for voice 1 frequency high.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #$20
; WHAT: Copy A to voice 1 frequency high.
; WHY: frequency high.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d401       ; frequency high
; WHAT: Load A from 15 (literal value).
; WHY: Prepare the value for SID master volume / filter mode.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #15
; WHAT: Copy A to SID master volume / filter mode.
; WHY: volume 15.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d418       ; volume 15
; WHAT: Load A from %00100001 (literal value).
; WHY: sawtooth + gate.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #%00100001  ; sawtooth + gate
; WHAT: Copy A to voice 1 waveform and gate.
; WHY: Update voice 1 waveform and gate while we prepare the program before display updates
; begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d404
; WHAT: Load X from 0 (literal value).
; WHY: Set the literal value needed to prepare the program before display updates begin.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    ldx #0
; WHAT: Define address label outer.
; WHY: Name the entry or data location used to run a CPU-time delay with an outer X counter.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
outer:
; WHAT: Load Y from 0 (literal value).
; WHY: Set the literal value needed to run a CPU-time delay with an outer X counter.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    ldy #0
; WHAT: Define address label inner.
; WHY: Name the entry or data location used to run the inner Y delay counter.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
inner:
; WHAT: Decrement Y modulo 256.
; WHY: Advance the counter, position or offset used to run the inner Y delay counter.
; HOW: Implied/accumulator form; no separate memory operand. Flags updated: N Z.
    dey
; WHAT: Branch when Z=0; target is inner.
; WHY: Choose the path that continues or completes run the inner Y delay counter.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne inner
; WHAT: Decrement X modulo 256.
; WHY: Advance the counter, position or offset used to run the inner Y delay counter.
; HOW: Implied/accumulator form; no separate memory operand. Flags updated: N Z.
    dex
; WHAT: Branch when Z=0; target is outer.
; WHY: Choose the path that continues or completes run the inner Y delay counter.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne outer
; WHAT: Load A from %00100000 (literal value).
; WHY: gate off.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #%00100000  ; gate off
; WHAT: Copy A to voice 1 waveform and gate.
; WHY: Update voice 1 waveform and gate while we run the inner Y delay counter.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d404
; WHAT: Return from the current subroutine.
; WHY: Return control to the caller after this routine has completed its work.
; HOW: Pull the JSR return address, add one, and continue there. The stack must still match the
; call; flags are unchanged.
    rts
