; ========================================================================
; rom_print.asm - documented ACME source
; Every code-bearing line has WHAT, WHY and HOW comments.
; WHAT describes the operation. WHY explains its role. HOW explains encoding,
; flags, addressing, hardware effects or control flow.
; Code comments do not change the generated program bytes.
; PURPOSE: Print a PETSCII message through public KERNAL CHROUT.
; ASSUMPTIONS: Complete SYS 2064 example. Keyboard/editor service must remain compatible with
; the standard ROM.
; ASSEMBLE: Select CBM format and an output name using the command line.
; Example from the companion root:
; acme --strict-segments -f cbm -o demo.prg reference_examples/rom_print.asm
; Archived originals are unchanged and are not the recommended teaching copies.
; ========================================================================
; WHAT: Select the NMOS 6510 instruction set.
; WHY: Generate instructions for the C64 CPU rather than a later 65C02.
; HOW: In ACME 0.97, 6510 aliases nmos6502 and also permits undocumented opcodes; this course uses official instructions.
!cpu 6510
; WHAT: Place the following output at $0801.
; WHY: Keep the BASIC launcher, executable code or graphics at its planned address.
; HOW: This is assembly-time placement, not a runtime jump. CBM output fills gaps between the lowest and highest emitted addresses.
* = $0801
; WHAT: Emit 5 literal bytes.
; WHY: Create the BASIC next-line link, line number and SYS token.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the high bit of each byte; table indices start at zero.
!byte $0b,$08,$0a,$00,$9e
; WHAT: Emit the quoted text bytes.
; WHY: Supply decimal SYS digits in the BASIC launch line.
; HOW: ACME converts the string with the current text table; digits 2064 occupy four bytes. This is not executable text or a screen-code declaration.
!text "2064"
; WHAT: Emit 3 literal bytes.
; WHY: Terminate the BASIC line and then the BASIC program.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the high bit of each byte; table indices start at zero.
!byte 0,0,0
; WHAT: Place the following output at $0810.
; WHY: Keep the BASIC launcher, executable code or graphics at its planned address.
; HOW: This is assembly-time placement, not a runtime jump. CBM output fills gaps between the lowest and highest emitted addresses.
* = $0810
; WHAT: Define address label start.
; WHY: Name the entry or data location used to prepare the program before display updates begin.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
start:
; WHAT: Load A from $93 (literal value).
; WHY: Set the literal value needed to prepare the program before display updates begin.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z. 
    lda #$93
; WHAT: Call $ffd2.
; WHY: Delegate work to $ffd2.
; HOW: Push the address of the last JSR byte on the page-1 stack, then load the target into PC. RTS pulls it and adds one.
    jsr $ffd2
; WHAT: Load X from 0 (literal value).
; WHY: Set the literal value needed to prepare the program before display updates begin.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z. 
    ldx #0
; WHAT: Define address label .loop.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
.loop:
; WHAT: Load A from text.
; WHY: Fetch text while we process this section.
; HOW: Indexed address: add the index register to the named base address. Flags updated: N Z. 
    lda text,x
; WHAT: Branch when Z=1; target is .done.
; WHY: Choose the path that continues or completes this operation.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127 from the next instruction; taken branches cost extra cycles.
    beq .done
; WHAT: Copy X to saved_x.
; WHY: Update saved_x while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags are unchanged. 
    stx saved_x
; WHAT: Call $ffd2.
; WHY: Delegate work to $ffd2.
; HOW: Push the address of the last JSR byte on the page-1 stack, then load the target into PC. RTS pulls it and adds one.
    jsr $ffd2
; WHAT: Load X from saved_x.
; WHY: Fetch saved_x while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags updated: N Z. 
    ldx saved_x
; WHAT: Increment X modulo 256.
; WHY: Advance the counter, position or offset used to process this loop.
; HOW: Implied/accumulator form; no separate memory operand. Flags updated: N Z. 
    inx
; WHAT: Branch when Z=0; target is .loop.
; WHY: Choose the path that continues or completes this operation.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127 from the next instruction; taken branches cost extra cycles.
    bne .loop
; WHAT: Define address label .done.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
.done:
; WHAT: Return from the current subroutine.
; WHY: Return control to the caller after this routine has completed its work.
; HOW: Pull the JSR return address, add one, and continue there. The stack must still match the call; flags are unchanged.
    rts
; WHAT: Emit 1 literal byte.
; WHY: Initialise saved_x; successive entries are adjacent bytes.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the high bit of each byte; table indices start at zero.
saved_x: !byte 0
; WHAT: Emit the message as PETSCII, followed by RETURN and zero.
; WHY: Supply bytes for CHROUT and a sentinel for the loop.
; HOW: ACME converts source characters; 13 is the numeric RETURN byte and 0 terminates our own string convention.
text: !pet "hello, c64!",13,0
