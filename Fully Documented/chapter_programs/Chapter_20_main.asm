; ========================================================================
; Chapter_20_main.asm - documented ACME source
; Every code-bearing line has WHAT, WHY and HOW comments.
; WHAT describes the operation. WHY explains its role. HOW explains encoding,
; flags, addressing, hardware effects or control flow.
; Code comments do not change the generated program bytes.
; PURPOSE: Multiply eight small values by three using one shift and one addition.
; FLOW: For each table entry, ASL computes twice the value in A. CLC prevents that shift carry
; from joining the subsequent ADC of the original value, producing three times the entry
; modulo 256.
; TRY: Predict the eight outputs: 3,6,9,12,15,18,21,24. Then design multiply-by-five.
; ASSUMPTIONS: Results are bytes, so larger inputs can overflow. The display contains those
; screen codes, not a printed numeric table. X and table bounds must stay consistent.
; ASSEMBLE: Select CBM format and an output name using the command line.
; Example from the companion root:
; acme --strict-segments -f cbm -o demo.prg chapter_programs/Chapter_20_main.asm
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
; WHAT: Load X from 0 (literal value).
; WHY: Set the literal value needed to prepare the program before display updates begin.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    ldx #0
; WHAT: Define address label loop.
; WHY: Name the entry or data location used to process the next item in this example loop.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
loop:
; WHAT: Load A from input value table.
; WHY: Fetch input value table while we process the next item in this example loop.
; HOW: Indexed address: add the index register to the named base address. Flags updated: N Z.
    lda values,x
; WHAT: Shift left; old bit 7 enters C; bit 0 becomes 0.
; WHY: Scale a value or form a register/table offset for process the next item in this example
; loop.
; HOW: Implied/accumulator form; no separate memory operand. Flags updated: N Z C.  Unsigned
; multiply by two modulo 256.
    asl
; WHAT: C = 0.
; WHY: Start an independent addition without an incoming carry.
; HOW: Start an independent addition without an incoming carry. Among status flags, only C
; changes.
    clc
; WHAT: A = A + values,x + C.
; WHY: Calculate the next coordinate, phase or high-byte adjustment in loop.
; HOW: Indexed address: add the index register to the named base address. Updates N,V,Z,C in
; binary mode. Preserve low-byte carry for a following high-byte addition.
    adc values,x
; WHAT: Copy A to first screen cell.
; WHY: Update first screen cell while we process the next item in this example loop.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta $0400,x
; WHAT: Increment X modulo 256.
; WHY: Advance the counter, position or offset used to process the next item in this example
; loop.
; HOW: Implied/accumulator form; no separate memory operand. Flags updated: N Z.
    inx
; WHAT: Compare X with #8 without changing that register.
; WHY: Set the condition for the following branch in loop.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cpx #8
; WHAT: Branch when Z=0; target is loop.
; WHY: Choose the path that continues or completes process the next item in this example loop.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne loop
; WHAT: Return from the current subroutine.
; WHY: Return control to the caller after this routine has completed its work.
; HOW: Pull the JSR return address, add one, and continue there. The stack must still match the
; call; flags are unchanged.
    rts
; WHAT: Define address label values.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
values:
; WHAT: Emit 8 literal bytes.
; WHY: Initialise input value table; successive entries are adjacent bytes.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
    !byte 1,2,3,4,5,6,7,8
