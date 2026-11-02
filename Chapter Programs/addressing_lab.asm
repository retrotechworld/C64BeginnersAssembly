; ========================================================================
; addressing_lab.asm - documented ACME source
; Every code-bearing line has WHAT, WHY and HOW comments.
; WHAT describes the operation. WHY explains its role. HOW explains encoding,
; flags, addressing, hardware effects or control flow.
; Code comments do not change the generated program bytes.
; PURPOSE: Trace immediate, direct, indexed and indirect reads in one complete program.
; FLOW: The lab preserves $FB-$FD, writes the nine expected codes from lessons 9A-9G, then
; reaches cleanup through an indirect JMP. It assigns white ink so the first-row results are
; visible.
; TRY: Change one table index or one pointer offset, rebuild and predict exactly which cell
; changes.
; ASSUMPTIONS: The borrowed zero-page bytes are restored before RTS, but this is still a small
; standalone lab after a reset. Do not repurpose the same workspace in an asynchronous
; interrupt handler.
; ASSEMBLE: Select CBM format and an output name using the command line.
; Example from the companion root:
; acme --strict-segments -f cbm -o demo.prg chapter_programs/addressing_lab.asm
; Archived originals are unchanged and are not the recommended teaching copies.
; ========================================================================
; WHAT / WHY / HOW documented teaching copy.
; Original files are preserved in originals/ACME_Source.
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
; WHAT: D = 0.
; WHY: Select ordinary binary ADC/SBC arithmetic.
; HOW: Select ordinary binary ADC/SBC arithmetic. Among status flags, only D change.
    cld
; WHAT: Load A from borrowed zero-page byte / pointer low.
; WHY: Fetch borrowed zero-page byte / pointer low while we prepare the program before display
; updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda $fb
; WHAT: Copy A to saved original $FB byte.
; WHY: Update saved original $FB byte while we prepare the program before display updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta saved_fb
; WHAT: Load A from borrowed pointer byte.
; WHY: Fetch borrowed pointer byte while we prepare the program before display updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda $fc
; WHAT: Copy A to saved original $FC byte.
; WHY: Update saved original $FC byte while we prepare the program before display updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta saved_fc
; WHAT: Load A from borrowed scratch or pointer-high byte.
; WHY: Fetch borrowed scratch or pointer-high byte while we prepare the program before display
; updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda $fd
; WHAT: Copy A to saved original $FD byte.
; WHY: Update saved original $FD byte while we prepare the program before display updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta saved_fd
; WHAT: Load X from 8 (literal value).
; WHY: Set the literal value needed to prepare the program before display updates begin.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    ldx #8
; WHAT: Define address label ink_loop.
; WHY: Name the entry or data location used to set white colour on the nine lab cells.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
ink_loop:
; WHAT: Load A from 1 (literal value).
; WHY: Prepare the value for first colour-RAM cell.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #1
; WHAT: Copy A to first colour-RAM cell.
; WHY: Update first colour-RAM cell while we set white colour on the nine lab cells.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta $d800,x
; WHAT: Decrement X modulo 256.
; WHY: Advance the counter, position or offset used to set white colour on the nine lab cells.
; HOW: Implied/accumulator form; no separate memory operand. Flags updated: N Z.
    dex
; WHAT: Branch when N=0; target is ink_loop.
; WHY: Choose the path that continues or completes set white colour on the nine lab cells.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bpl ink_loop
; WHAT: Load A from 1 (literal value).
; WHY: Prepare the value for first screen cell.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #1
; WHAT: Copy A to first screen cell.
; WHY: Update first screen cell while we set white colour on the nine lab cells.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $0400
; WHAT: Load X from 1 (literal value).
; WHY: Set the literal value needed to set white colour on the nine lab cells.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    ldx #1
; WHAT: Load A from input value table.
; WHY: Fetch input value table while we set white colour on the nine lab cells.
; HOW: Indexed address: add the index register to the named base address. Flags updated: N Z.
    lda values,x
; WHAT: Copy A to $0401.
; WHY: Update $0401 while we set white colour on the nine lab cells.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $0401
; WHAT: Load Y from 2 (literal value).
; WHY: Set the literal value needed to set white colour on the nine lab cells.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    ldy #2
; WHAT: Load A from input value table.
; WHY: Fetch input value table while we set white colour on the nine lab cells.
; HOW: Indexed address: add the index register to the named base address. Flags updated: N Z.
    lda values,y
; WHAT: Copy A to $0402.
; WHY: Update $0402 while we set white colour on the nine lab cells.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $0402
; WHAT: Load A from 4 (literal value).
; WHY: Prepare the value for borrowed scratch or pointer-high byte.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #4
; WHAT: Copy A to borrowed scratch or pointer-high byte.
; WHY: Update borrowed scratch or pointer-high byte while we set white colour on the nine lab
; cells.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $fd
; WHAT: Load A from borrowed scratch or pointer-high byte.
; WHY: Fetch borrowed scratch or pointer-high byte while we set white colour on the nine lab
; cells.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda $fd
; WHAT: Copy A to $0403.
; WHY: Update $0403 while we set white colour on the nine lab cells.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $0403
; WHAT: Load X from 1 (literal value).
; WHY: Set the literal value needed to set white colour on the nine lab cells.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    ldx #1
; WHAT: Load A from borrowed pointer byte.
; WHY: Fetch borrowed pointer byte while we set white colour on the nine lab cells.
; HOW: Indexed address: add the index register to the named base address. Flags updated: N Z.
    lda $fc,x
; WHAT: Copy A to $0404.
; WHY: Update $0404 while we set white colour on the nine lab cells.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $0404
; WHAT: Load A from <values (literal value).
; WHY: Prepare the value for borrowed zero-page byte / pointer low.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #<values
; WHAT: Copy A to borrowed zero-page byte / pointer low.
; WHY: Update borrowed zero-page byte / pointer low while we set white colour on the nine lab
; cells.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $fb
; WHAT: Load A from >values (literal value).
; WHY: Prepare the value for borrowed pointer byte.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #>values
; WHAT: Copy A to borrowed pointer byte.
; WHY: Update borrowed pointer byte while we set white colour on the nine lab cells.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $fc
; WHAT: Load Y from 3 (literal value).
; WHY: Set the literal value needed to set white colour on the nine lab cells.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    ldy #3
; WHAT: Load A from ($fb).
; WHY: Fetch ($fb) while we set white colour on the nine lab cells.
; HOW: Indirect indexed: fetch the zero-page low/high pointer pair, then add Y to that 16-bit
; address before accessing its byte. Flags updated: N Z.
    lda ($fb),y
; WHAT: Copy A to $0405.
; WHY: Update $0405 while we set white colour on the nine lab cells.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $0405
; WHAT: Load X from 1 (literal value).
; WHY: Set the literal value needed to set white colour on the nine lab cells.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    ldx #1
; WHAT: Load A from ($fa,x).
; WHY: Fetch ($fa,x) while we set white colour on the nine lab cells.
; HOW: Indexed indirect: add X to the zero-page pointer location, wrap there, fetch its low/high
; address pair, then access the pointed-to byte. Flags updated: N Z.
    lda ($fa,x)
; WHAT: Copy A to $0406.
; WHY: Update $0406 while we set white colour on the nine lab cells.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $0406
; WHAT: Load A from 3 (literal value).
; WHY: Set the literal value needed to set white colour on the nine lab cells.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #3
; WHAT: Shift left; old bit 7 enters C; bit 0 becomes 0.
; WHY: Scale a value or form a register/table offset for set white colour on the nine lab cells.
; HOW: Implied/accumulator form; no separate memory operand. Flags updated: N Z C.  Unsigned
; multiply by two modulo 256.
    asl
; WHAT: Copy A to $0407.
; WHY: Update $0407 while we set white colour on the nine lab cells.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $0407
; WHAT: Compare A with #6 without changing that register.
; WHY: Set the condition for the following branch in ink_loop.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cmp #6
; WHAT: Branch when Z=1; target is matched.
; WHY: Choose the path that continues or completes set white colour on the nine lab cells.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    beq matched
; WHAT: Load A from 0 (literal value).
; WHY: Set the literal value needed to set white colour on the nine lab cells.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #0
; WHAT: Continue execution at result.
; WHY: Repeat the main loop or join the named control path.
; HOW: Absolute JMP changes PC without stacking a return address; flags are unchanged.
    jmp result
; WHAT: Define address label matched.
; WHY: Name the entry or data location used to select the successful comparison screen code.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
matched:
; WHAT: Load A from 7 (literal value).
; WHY: Set the literal value needed to select the successful comparison screen code.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #7
; WHAT: Define address label result.
; WHY: Name the entry or data location used to write the final comparison result and transfer to
; cleanup.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
result:
; WHAT: Copy A to $0408.
; WHY: Update $0408 while we write the final comparison result and transfer to cleanup.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $0408
; WHAT: Continue execution at (cleanup_vector).
; WHY: Repeat the main loop or join the named control path.
; HOW: Indirect JMP fetches PC from the low/high pointer pair; flags are unchanged. Avoid a
; pointer ending in $FF because of NMOS page wrapping.
    jmp (cleanup_vector)
; WHAT: Define address label cleanup.
; WHY: Name the entry or data location used to restore the borrowed zero-page bytes before
; returning.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
cleanup:
; WHAT: Load A from saved original $FB byte.
; WHY: Fetch saved original $FB byte while we restore the borrowed zero-page bytes before
; returning.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda saved_fb
; WHAT: Copy A to borrowed zero-page byte / pointer low.
; WHY: Update borrowed zero-page byte / pointer low while we restore the borrowed zero-page
; bytes before returning.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $fb
; WHAT: Load A from saved original $FC byte.
; WHY: Fetch saved original $FC byte while we restore the borrowed zero-page bytes before
; returning.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda saved_fc
; WHAT: Copy A to borrowed pointer byte.
; WHY: Update borrowed pointer byte while we restore the borrowed zero-page bytes before
; returning.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $fc
; WHAT: Load A from saved original $FD byte.
; WHY: Fetch saved original $FD byte while we restore the borrowed zero-page bytes before
; returning.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda saved_fd
; WHAT: Copy A to borrowed scratch or pointer-high byte.
; WHY: Update borrowed scratch or pointer-high byte while we restore the borrowed zero-page
; bytes before returning.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $fd
; WHAT: Return from the current subroutine.
; WHY: Return control to the caller after this routine has completed its work.
; HOW: Pull the JSR return address, add one, and continue there. The stack must still match the
; call; flags are unchanged.
    rts
; WHAT: Emit 4 literal bytes.
; WHY: Initialise input value table; successive entries are adjacent bytes.
; HOW: The label values names this data address. These are stored data, not CPU instructions.
; Binary row bits run left to right from the high bit of each byte; table indices start at zero.
values: !byte 1,2,3,4
; WHAT: Emit 1 literal byte.
; WHY: Initialise saved original $FB byte; successive entries are adjacent bytes.
; HOW: The label saved_fb names this data address. These are stored data, not CPU instructions.
; Binary row bits run left to right from the high bit of each byte; table indices start at zero.
saved_fb: !byte 0
; WHAT: Emit 1 literal byte.
; WHY: Initialise saved original $FC byte; successive entries are adjacent bytes.
; HOW: The label saved_fc names this data address. These are stored data, not CPU instructions.
; Binary row bits run left to right from the high bit of each byte; table indices start at zero.
saved_fc: !byte 0
; WHAT: Emit 1 literal byte.
; WHY: Initialise saved original $FD byte; successive entries are adjacent bytes.
; HOW: The label saved_fd names this data address. These are stored data, not CPU instructions.
; Binary row bits run left to right from the high bit of each byte; table indices start at zero.
saved_fd: !byte 0
; WHAT: Emit the listed 16-bit word value.
; WHY: Store a destination address for the indirect jump or another pointer consumer.
; HOW: The label cleanup_vector names this data address. ACME emits each word low byte first,
; then high byte; the directive performs no runtime jump.
cleanup_vector: !word cleanup
