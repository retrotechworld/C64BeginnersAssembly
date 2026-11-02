; ========================================================================
; Chapter_15_main.asm - documented ACME source
; Every code-bearing line has WHAT, WHY and HOW comments.
; WHAT describes the operation. WHY explains its role. HOW explains encoding,
; flags, addressing, hardware effects or control flow.
; Code comments do not change the generated program bytes.
; PURPOSE: Use a zero-page pointer with Y indexing to write forty screen codes.
; FLOW: counter uses $FB; screen_ptr uses $FC/$FD and is initialised to $0400. STA
; (screen_ptr),Y follows that pointer and selects each column, while counter and Y advance
; together.
; TRY: Change the pointer to $0428 for the second row, and explain why only the two setup
; bytes need changing.
; ASSUMPTIONS: The original borrows $FB-$FD without preserving them. Treat that as a workspace
; contract, not a universal free-memory rule. The new addressing lab demonstrates saving and
; restoring those bytes. It writes screen codes, not decimal text.
; ASSEMBLE: Select CBM format and an output name using the command line.
; Example from the companion root:
; acme --strict-segments -f cbm -o demo.prg chapter_programs/Chapter_15_main.asm
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

; WHAT: Define counter as $fb.
; WHY: Give borrowed zero-page byte counter a readable symbolic name.
; HOW: ACME substitutes the value in expressions; this assignment allocates no RAM and executes
; no instruction.
counter = $fb
; WHAT: Define screen_ptr as $fc.
; WHY: Give borrowed two-byte zero-page screen pointer a readable symbolic name.
; HOW: ACME substitutes the value in expressions; this assignment allocates no RAM and executes
; no instruction.
screen_ptr = $fc
; WHAT: Define address label start.
; WHY: Name the entry or data location used to prepare the program before display updates begin.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
start:
; WHAT: Load A from 0 (literal value).
; WHY: Prepare the value for borrowed zero-page byte counter.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #0
; WHAT: Copy A to borrowed zero-page byte counter.
; WHY: Update borrowed zero-page byte counter while we prepare the program before display
; updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta counter
; WHAT: Load A from <$0400 (literal value).
; WHY: Prepare the value for borrowed two-byte zero-page screen pointer.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #<$0400
; WHAT: Copy A to borrowed two-byte zero-page screen pointer.
; WHY: Update borrowed two-byte zero-page screen pointer while we prepare the program before
; display updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta screen_ptr
; WHAT: Load A from >$0400 (literal value).
; WHY: Prepare the value for screen_ptr+1.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #>$0400
; WHAT: Copy A to screen_ptr+1.
; WHY: Update screen_ptr+1 while we prepare the program before display updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta screen_ptr+1
; WHAT: Load Y from 0 (literal value).
; WHY: Set the literal value needed to prepare the program before display updates begin.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    ldy #0
; WHAT: Define address label loop.
; WHY: Name the entry or data location used to process the next item in this example loop.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
loop:
; WHAT: Load A from borrowed zero-page byte counter.
; WHY: Fetch borrowed zero-page byte counter while we process the next item in this example
; loop.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda counter
; WHAT: Copy A to (screen_ptr).
; WHY: Update (screen_ptr) while we process the next item in this example loop.
; HOW: Indirect indexed: fetch the zero-page low/high pointer pair, then add Y to that 16-bit
; address before accessing its byte. Status flags are unchanged.
    sta (screen_ptr),y
; WHAT: Increment borrowed zero-page byte counter modulo 256.
; WHY: Advance the counter, position or offset used to process the next item in this example
; loop.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z. NMOS memory read-modify-write writes the old byte before the new one; avoid
; applying this blindly to I/O.
    inc counter
; WHAT: Increment Y modulo 256.
; WHY: Advance the counter, position or offset used to process the next item in this example
; loop.
; HOW: Implied/accumulator form; no separate memory operand. Flags updated: N Z.
    iny
; WHAT: Compare Y with #40 without changing that register.
; WHY: Set the condition for the following branch in loop.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cpy #40
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
