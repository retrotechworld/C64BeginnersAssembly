; ========================================================================
; 03_fill.asm - documented ACME source
; Every code-bearing line has WHAT, WHY and HOW comments.
; WHAT describes the operation. WHY explains its role. HOW explains encoding,
; flags, addressing, hardware effects or control flow.
; Code comments do not change the generated program bytes.
; PURPOSE: Fill exactly 1,000 visible screen and colour cells.
; ASSUMPTIONS: Three 256-byte blocks plus 232 tail cells leave sprite pointers untouched.
; ASSEMBLE: Select CBM format and an output name using the command line.
; Example from the companion root:
; acme --strict-segments -f cbm -o demo.prg programs/03_fill.asm
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
; WHAT: Load X from 0 (literal value).
; WHY: Set the literal value needed to prepare the program before display updates begin.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    ldx #0
; WHAT: Define address label page.
; WHY: Name the entry or data location used to fill three full 256-byte blocks.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
page:
; WHAT: Load A from 1 (literal value).
; WHY: Prepare the value for first screen cell.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #1
; WHAT: Copy A to first screen cell.
; WHY: Update first screen cell while we fill three full 256-byte blocks.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta $0400,x
; WHAT: Copy A to $0500.
; WHY: Update $0500 while we fill three full 256-byte blocks.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta $0500,x
; WHAT: Copy A to $0600.
; WHY: Update $0600 while we fill three full 256-byte blocks.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta $0600,x
; WHAT: Load A from 7 (literal value).
; WHY: Prepare the value for first colour-RAM cell.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #7
; WHAT: Copy A to first colour-RAM cell.
; WHY: Update first colour-RAM cell while we fill three full 256-byte blocks.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta $d800,x
; WHAT: Copy A to $d900.
; WHY: Update $d900 while we fill three full 256-byte blocks.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta $d900,x
; WHAT: Copy A to $da00.
; WHY: Update $da00 while we fill three full 256-byte blocks.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta $da00,x
; WHAT: Increment X modulo 256.
; WHY: Advance the counter, position or offset used to fill three full 256-byte blocks.
; HOW: Implied/accumulator form; no separate memory operand. Flags updated: N Z.
    inx
; WHAT: Branch when Z=0; target is page.
; WHY: Choose the path that continues or completes fill three full 256-byte blocks.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne page
; WHAT: Load X from 0 (literal value).
; WHY: Set the literal value needed to fill three full 256-byte blocks.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    ldx #0
; WHAT: Define address label tail.
; WHY: Name the entry or data location used to fill the last 232 visible cells.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
tail:
; WHAT: Load A from 1 (literal value).
; WHY: Prepare the value for $0700.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #1
; WHAT: Copy A to $0700.
; WHY: Update $0700 while we fill the last 232 visible cells.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta $0700,x
; WHAT: Load A from 7 (literal value).
; WHY: Prepare the value for $db00.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #7
; WHAT: Copy A to $db00.
; WHY: Update $db00 while we fill the last 232 visible cells.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta $db00,x
; WHAT: Increment X modulo 256.
; WHY: Advance the counter, position or offset used to fill the last 232 visible cells.
; HOW: Implied/accumulator form; no separate memory operand. Flags updated: N Z.
    inx
; WHAT: Compare X with #232 without changing that register.
; WHY: Set the condition for the following branch in tail.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cpx #232
; WHAT: Branch when Z=0; target is tail.
; WHY: Choose the path that continues or completes fill the last 232 visible cells.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne tail
; WHAT: Return from the current subroutine.
; WHY: Return control to the caller after this routine has completed its work.
; HOW: Pull the JSR return address, add one, and continue there. The stack must still match the
; call; flags are unchanged.
    rts
