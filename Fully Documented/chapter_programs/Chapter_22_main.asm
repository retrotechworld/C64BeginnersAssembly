; ========================================================================
; Chapter_22_main.asm - documented ACME source
; Every code-bearing line has WHAT, WHY and HOW comments.
; WHAT describes the operation. WHY explains its role. HOW explains encoding,
; flags, addressing, hardware effects or control flow.
; Code comments do not change the generated program bytes.
; PURPOSE: Cycle a palette and reveal eight screen cells one at a time.
; FLOW: The frame poll advances index modulo eight. The selected palette byte goes to
; border/background and screen code 1 is written at the corresponding first-row cell.
; TRY: Change the palette order, then add matching colour-RAM writes so the revealed letters
; have a deliberate ink colour.
; ASSUMPTIONS: After the first eight updates, all eight cells remain A; later updates
; primarily cycle colours. No scene system, sound player or complete demo framework is already
; present.
; ASSEMBLE: Select CBM format and an output name using the command line.
; Example from the companion root:
; acme --strict-segments -f cbm -o demo.prg chapter_programs/Chapter_22_main.asm
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
; WHY: Prepare the value for palette and screen-cell index.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #0
; WHAT: Copy A to palette and screen-cell index.
; WHY: Update palette and screen-cell index while we prepare the program before display updates
; begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta index
; WHAT: Define address label main.
; WHY: Name the entry or data location used to repeat the example foreground update.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
main:
    ; Wait for frame boundary.
; WHAT: Define address label wait_out.
; WHY: Name the entry or data location used to wait until line 250 ends.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
wait_out:
; WHAT: Load A from raster low byte / compare target.
; WHY: Fetch raster low byte / compare target while we wait until line 250 ends.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.  A read returns the current raster low byte, not the stored interrupt compare
; value.
    lda $d012
; WHAT: Compare A with #250 without changing that register.
; WHY: Set the condition for the following branch in wait_out.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cmp #250
; WHAT: Branch when Z=1; target is wait_out.
; WHY: Choose the path that continues or completes wait until line 250 ends.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    beq wait_out
; WHAT: Define address label wait_in.
; WHY: Name the entry or data location used to wait until raster line 250.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
wait_in:
; WHAT: Load A from raster low byte / compare target.
; WHY: Fetch raster low byte / compare target while we wait until raster line 250.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.  A read returns the current raster low byte, not the stored interrupt compare
; value.
    lda $d012
; WHAT: Compare A with #250 without changing that register.
; WHY: Set the condition for the following branch in wait_in.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cmp #250
; WHAT: Branch when Z=0; target is wait_in.
; WHY: Choose the path that continues or completes wait until raster line 250.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne wait_in
; WHAT: Load X from palette and screen-cell index.
; WHY: Fetch palette and screen-cell index while we wait until raster line 250.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    ldx index
; WHAT: Load A from colour-cycle table.
; WHY: Fetch colour-cycle table while we wait until raster line 250.
; HOW: Indexed address: add the index register to the named base address. Flags updated: N Z.
    lda palette,x
; WHAT: Copy A to border colour.
; WHY: Update border colour while we wait until raster line 250.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d020
; WHAT: Copy A to background colour.
; WHY: Update background colour while we wait until raster line 250.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d021
; WHAT: Load A from 1 (literal value).
; WHY: Prepare the value for first screen cell.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #1
; WHAT: Copy A to first screen cell.
; WHY: Update first screen cell while we wait until raster line 250.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta $0400,x
; WHAT: Increment X modulo 256.
; WHY: Advance the counter, position or offset used to wait until raster line 250.
; HOW: Implied/accumulator form; no separate memory operand. Flags updated: N Z.
    inx
; WHAT: Compare X with #8 without changing that register.
; WHY: Set the condition for the following branch in wait_in.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cpx #8
; WHAT: Branch when Z=0; target is keep.
; WHY: Choose the path that continues or completes wait until raster line 250.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne keep
; WHAT: Load X from 0 (literal value).
; WHY: Set the literal value needed to wait until raster line 250.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    ldx #0
; WHAT: Define address label keep.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
keep:
; WHAT: Copy X to palette and screen-cell index.
; WHY: Update palette and screen-cell index while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    stx index
; WHAT: Continue execution at main.
; WHY: Repeat the main loop or join the named control path.
; HOW: Absolute JMP changes PC without stacking a return address; flags are unchanged.
    jmp main
; WHAT: Emit 1 literal byte.
; WHY: Initialise palette and screen-cell index; successive entries are adjacent bytes.
; HOW: The label index names this data address. These are stored data, not CPU instructions.
; Binary row bits run left to right from the high bit of each byte; table indices start at zero.
index: !byte 0
; WHAT: Emit 8 literal bytes.
; WHY: Initialise colour-cycle table; successive entries are adjacent bytes.
; HOW: The label palette names this data address. These are stored data, not CPU instructions.
; Binary row bits run left to right from the high bit of each byte; table indices start at zero.
palette: !byte 2,8,7,5,3,6,14,1
