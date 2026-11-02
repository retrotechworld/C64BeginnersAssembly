; ========================================================================
; 07_sound.asm - documented ACME source
; Every code-bearing line has WHAT, WHY and HOW comments.
; WHAT describes the operation. WHY explains its role. HOW explains encoding,
; flags, addressing, hardware effects or control flow.
; Code comments do not change the generated program bytes.
; PURPOSE: Start a sawtooth SID note and return to BASIC.
; ASSUMPTIONS: Release with POKE 54276,32; mute with POKE 54296,0. Voice 1 and master volume
; are changed.
; ASSEMBLE: Select CBM format and an output name using the command line.
; Example from the companion root:
; acme --strict-segments -f cbm -o demo.prg programs/07_sound.asm
; Archived originals are unchanged and are not the recommended teaching copies.
; ========================================================================
; Fully documented edition: WHAT / WHY / HOW before each code-bearing line.
; Book listing numbers are mapped to this file in SOURCE_LINE_MAP.json.
; WHAT: Select the NMOS 6510 instruction set.
; WHY: Generate instructions for the C64 CPU rather than a later 65C02.
; HOW: In ACME 0.97, 6510 aliases nmos6502 and also permits undocumented opcodes; this course
; uses official instructions.
!cpu 6510
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
; WHY: Prepare the value for voice 1 waveform and gate.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #0
; WHAT: Copy A to voice 1 waveform and gate.
; WHY: Update voice 1 waveform and gate while we prepare the program before display updates
; begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d404
; WHAT: Load A from 15 (literal value).
; WHY: Prepare the value for SID master volume / filter mode.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #15
; WHAT: Copy A to SID master volume / filter mode.
; WHY: Update SID master volume / filter mode while we prepare the program before display
; updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d418
; WHAT: Load A from $12 (literal value).
; WHY: Prepare the value for voice 1 attack and decay.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #$12
; WHAT: Copy A to voice 1 attack and decay.
; WHY: Update voice 1 attack and decay while we prepare the program before display updates
; begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d405
; WHAT: Load A from $f8 (literal value).
; WHY: Prepare the value for voice 1 sustain and release.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #$f8
; WHAT: Copy A to voice 1 sustain and release.
; WHY: Update voice 1 sustain and release while we prepare the program before display updates
; begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d406
; WHAT: Load A from $00 (literal value).
; WHY: Prepare the value for voice 1 frequency low.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #$00
; WHAT: Copy A to voice 1 frequency low.
; WHY: Update voice 1 frequency low while we prepare the program before display updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d400
; WHAT: Load A from $20 (literal value).
; WHY: Prepare the value for voice 1 frequency high.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #$20
; WHAT: Copy A to voice 1 frequency high.
; WHY: Update voice 1 frequency high while we prepare the program before display updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d401
; WHAT: Load A from $21 (literal value).
; WHY: Prepare the value for voice 1 waveform and gate.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #$21
; WHAT: Copy A to voice 1 waveform and gate.
; WHY: Update voice 1 waveform and gate while we prepare the program before display updates
; begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d404
; WHAT: Return from the current subroutine.
; WHY: Return control to the caller after this routine has completed its work.
; HOW: Pull the JSR return address, add one, and continue there. The stack must still match the
; call; flags are unchanged.
    rts
; To release this note from BASIC: POKE 54276,32
