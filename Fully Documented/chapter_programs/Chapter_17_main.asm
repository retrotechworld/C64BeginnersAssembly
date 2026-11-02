; ========================================================================
; Chapter_17_main.asm - documented ACME source
; Every code-bearing line has WHAT, WHY and HOW comments.
; WHAT describes the operation. WHY explains its role. HOW explains encoding,
; flags, addressing, hardware effects or control flow.
; Code comments do not change the generated program bytes.
; PURPOSE: Connect joystick movement, a target position and a score counter.
; FLOW: player begins at column 20, target at 30. Once per video frame, left/right adjusts
; player, the code writes an A at $0400+player and equality with target increments score and
; border colour.
; TRY: Tap toward the target and inspect score in the report/monitor or display it as a later
; exercise.
; ASSUMPTIONS: This is a sketch, not a complete game: old cells are not erased, movement is
; not bounded to 0..39, and the score increases every frame spent on the target rather than
; once per arrival. Those are clear next exercises, not hidden completed features.
; ASSEMBLE: Select CBM format and an output name using the command line.
; Example from the companion root:
; acme --strict-segments -f cbm -o demo.prg chapter_programs/Chapter_17_main.asm
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
; WHAT: Load A from 20 (literal value).
; WHY: Prepare the value for player column state.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #20
; WHAT: Copy A to player column state.
; WHY: Update player column state while we prepare the program before display updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta player
; WHAT: Load A from 30 (literal value).
; WHY: Prepare the value for target column.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #30
; WHAT: Copy A to target column.
; WHY: Update target column while we prepare the program before display updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta target
; WHAT: Load A from 0 (literal value).
; WHY: Prepare the value for score counter.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #0
; WHAT: Copy A to score counter.
; WHY: Update score counter while we prepare the program before display updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta score
; WHAT: Define address label main.
; WHY: Name the entry or data location used to repeat the example foreground update.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
main:
    ; Wait for a new frame at line 250.
; WHAT: Define address label not_line.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
not_line:
; WHAT: Load A from raster low byte / compare target.
; WHY: Fetch raster low byte / compare target while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.  A read returns the current raster low byte, not the stored interrupt compare
; value.
    lda $d012
; WHAT: Compare A with #250 without changing that register.
; WHY: Set the condition for the following branch in not_line.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cmp #250
; WHAT: Branch when Z=1; target is not_line.
; WHY: Choose the path that continues or completes this operation.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    beq not_line
; WHAT: Define address label on_line.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
on_line:
; WHAT: Load A from raster low byte / compare target.
; WHY: Fetch raster low byte / compare target while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.  A read returns the current raster low byte, not the stored interrupt compare
; value.
    lda $d012
; WHAT: Compare A with #250 without changing that register.
; WHY: Set the condition for the following branch in on_line.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cmp #250
; WHAT: Branch when Z=0; target is on_line.
; WHY: Choose the path that continues or completes this operation.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne on_line

    ; Joystick 2 left/right.
; WHAT: Load A from CIA1 port A / joystick 2.
; WHY: Fetch CIA1 port A / joystick 2 while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda $dc00
; WHAT: A = A AND #4.
; WHY: Select, combine or constrain the bits used to update this setting.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    and #4
; WHAT: Branch when Z=0; target is check_right.
; WHY: Choose the path that continues or completes this operation.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne check_right
; WHAT: Decrement player column state modulo 256.
; WHY: Advance the counter, position or offset used to process this loop.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z. NMOS memory read-modify-write writes the old byte before the new one; avoid
; applying this blindly to I/O.
    dec player
; WHAT: Define address label check_right.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
check_right:
; WHAT: Load A from CIA1 port A / joystick 2.
; WHY: Fetch CIA1 port A / joystick 2 while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda $dc00
; WHAT: A = A AND #8.
; WHY: Select, combine or constrain the bits used to update this setting.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    and #8
; WHAT: Branch when Z=0; target is draw.
; WHY: Choose the path that continues or completes this operation.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne draw
; WHAT: Increment player column state modulo 256.
; WHY: Advance the counter, position or offset used to process this loop.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z. NMOS memory read-modify-write writes the old byte before the new one; avoid
; applying this blindly to I/O.
    inc player
; WHAT: Define address label draw.
; WHY: Name the entry or data location used to write the resulting sprite X position.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
draw:
; WHAT: Load X from player column state.
; WHY: Fetch player column state while we write the resulting sprite X position.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    ldx player
; WHAT: Load A from 1 (literal value).
; WHY: Prepare the value for first screen cell.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #1
; WHAT: Copy A to first screen cell.
; WHY: Update first screen cell while we write the resulting sprite X position.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta $0400,x
; WHAT: Compare X with target without changing that register.
; WHY: Set the condition for the following branch in draw.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cpx target
; WHAT: Branch when Z=0; target is main.
; WHY: Choose the path that continues or completes write the resulting sprite X position.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne main
; WHAT: Increment score counter modulo 256.
; WHY: Advance the counter, position or offset used to write the resulting sprite X position.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z. NMOS memory read-modify-write writes the old byte before the new one; avoid
; applying this blindly to I/O.
    inc score
; WHAT: Increment border colour modulo 256.
; WHY: Advance the counter, position or offset used to write the resulting sprite X position.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z. NMOS memory read-modify-write writes the old byte before the new one; avoid
; applying this blindly to I/O.
    inc $d020
; WHAT: Continue execution at main.
; WHY: Repeat the main loop or join the named control path.
; HOW: Absolute JMP changes PC without stacking a return address; flags are unchanged.
    jmp main
; WHAT: Emit 1 literal byte.
; WHY: Initialise player column state; successive entries are adjacent bytes.
; HOW: The label player names this data address. These are stored data, not CPU instructions.
; Binary row bits run left to right from the high bit of each byte; table indices start at zero.
player: !byte 20
; WHAT: Emit 1 literal byte.
; WHY: Initialise target column; successive entries are adjacent bytes.
; HOW: The label target names this data address. These are stored data, not CPU instructions.
; Binary row bits run left to right from the high bit of each byte; table indices start at zero.
target: !byte 30
; WHAT: Emit 1 literal byte.
; WHY: Initialise score counter; successive entries are adjacent bytes.
; HOW: The label score names this data address. These are stored data, not CPU instructions.
; Binary row bits run left to right from the high bit of each byte; table indices start at zero.
score:  !byte 0
