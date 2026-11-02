; ========================================================================
; Chapter_10_main.asm - documented ACME source
; Every code-bearing line has WHAT, WHY and HOW comments.
; WHAT describes the operation. WHY explains its role. HOW explains encoding,
; flags, addressing, hardware effects or control flow.
; Code comments do not change the generated program bytes.
; PURPOSE: Choose a red or blue border from the distance between two X values.
; FLOW: check_hit subtracts target_x from player_x. If a borrow occurred, it negates the byte
; with EOR/ADC to form the absolute unsigned difference. A difference below eight sets hit=1.
; TRY: Change target_x from 35 to 50: with player_x=32, the difference grows from 3 to 18 and
; the border becomes blue.
; ASSUMPTIONS: This tests one-dimensional proximity, not full 2D collision or sprite-pixel
; overlap. It assumes ordinary binary arithmetic after reset. Add a separate Y-range test
; before calling this a rectangular collision system.
; ASSEMBLE: Select CBM format and an output name using the command line.
; Example from the companion root:
; acme --strict-segments -f cbm -o demo.prg chapter_programs/Chapter_10_main.asm
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
; WHAT: Load A from 32 (literal value).
; WHY: Prepare the value for player horizontal position.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #32
; WHAT: Copy A to player horizontal position.
; WHY: Update player horizontal position while we prepare the program before display updates
; begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta player_x
; WHAT: Load A from 35 (literal value).
; WHY: Prepare the value for target horizontal position.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #35
; WHAT: Copy A to target horizontal position.
; WHY: Update target horizontal position while we prepare the program before display updates
; begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta target_x
; WHAT: Call check_hit.
; WHY: Delegate work to calculate absolute X distance and set the proximity result.
; HOW: Push the address of the last JSR byte on the page-1 stack, then load the target into PC.
; RTS pulls it and adds one.
    jsr check_hit
; WHAT: Load A from one-dimensional proximity result.
; WHY: Fetch one-dimensional proximity result while we prepare the program before display
; updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda hit
; WHAT: Branch when Z=1; target is no_hit.
; WHY: Choose the path that continues or completes prepare the program before display updates
; begin.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    beq no_hit
; WHAT: Load A from 2 (literal value).
; WHY: Prepare the value for border colour.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #2
; WHAT: Copy A to border colour.
; WHY: Update border colour while we prepare the program before display updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d020
; WHAT: Return from the current subroutine.
; WHY: Return control to the caller after this routine has completed its work.
; HOW: Pull the JSR return address, add one, and continue there. The stack must still match the
; call; flags are unchanged.
    rts
; WHAT: Define address label no_hit.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
no_hit:
; WHAT: Load A from 6 (literal value).
; WHY: Prepare the value for border colour.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #6
; WHAT: Copy A to border colour.
; WHY: Update border colour while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d020
; WHAT: Return from the current subroutine.
; WHY: Return control to the caller after this routine has completed its work.
; HOW: Pull the JSR return address, add one, and continue there. The stack must still match the
; call; flags are unchanged.
    rts

; A collision if the two X values differ by < 8.
; WHAT: Define address label check_hit.
; WHY: Name the entry or data location used to calculate absolute X distance and set the
; proximity result.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
check_hit:
; WHAT: Load A from 0 (literal value).
; WHY: Prepare the value for one-dimensional proximity result.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #0
; WHAT: Copy A to one-dimensional proximity result.
; WHY: Update one-dimensional proximity result while we calculate absolute X distance and set
; the proximity result.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta hit
; WHAT: Load A from player horizontal position.
; WHY: Fetch player horizontal position while we calculate absolute X distance and set the
; proximity result.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda player_x
; WHAT: C = 1.
; WHY: Start independent SBC with no initial borrow.
; HOW: Start independent SBC with no initial borrow. Among status flags, only C change.
    sec
; WHAT: A = A - target_x - (1-C).
; WHY: Calculate the next coordinate, phase or high-byte adjustment in check_hit.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Updates
; N,V,Z,C in binary mode. SEC starts a subtraction without an incoming borrow.
    sbc target_x
; WHAT: Branch when C=1; target is positive.
; WHY: Choose the path that continues or completes calculate absolute X distance and set the
; proximity result.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bcs positive
; WHAT: A = A XOR #$ff.
; WHY: Select, combine or constrain the bits used to calculate absolute X distance and set the
; proximity result.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    eor #$ff
; WHAT: C = 0.
; WHY: Start an independent addition without an incoming carry.
; HOW: Start an independent addition without an incoming carry. Among status flags, only C
; changes.
    clc
; WHAT: A = A + #1 + C.
; WHY: Calculate the next coordinate, phase or high-byte adjustment in check_hit.
; HOW: Immediate operand: the value is encoded in the instruction. Updates N,V,Z,C in binary
; mode. Preserve low-byte carry for a following high-byte addition.
    adc #1
; WHAT: Define address label positive.
; WHY: Name the entry or data location used to test the nonnegative distance against eight.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
positive:
; WHAT: Compare A with #8 without changing that register.
; WHY: Set the condition for the following branch in positive.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cmp #8
; WHAT: Branch when C=1; target is finished.
; WHY: Choose the path that continues or completes test the nonnegative distance against eight.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bcs finished
; WHAT: Load A from 1 (literal value).
; WHY: Prepare the value for one-dimensional proximity result.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #1
; WHAT: Copy A to one-dimensional proximity result.
; WHY: Update one-dimensional proximity result while we test the nonnegative distance against
; eight.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta hit
; WHAT: Define address label finished.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
finished:
; WHAT: Return from the current subroutine.
; WHY: Return control to the caller after this routine has completed its work.
; HOW: Pull the JSR return address, add one, and continue there. The stack must still match the
; call; flags are unchanged.
    rts
; WHAT: Emit 1 literal byte.
; WHY: Initialise player horizontal position; successive entries are adjacent bytes.
; HOW: The label player_x names this data address. These are stored data, not CPU instructions.
; Binary row bits run left to right from the high bit of each byte; table indices start at zero.
player_x: !byte 0
; WHAT: Emit 1 literal byte.
; WHY: Initialise target horizontal position; successive entries are adjacent bytes.
; HOW: The label target_x names this data address. These are stored data, not CPU instructions.
; Binary row bits run left to right from the high bit of each byte; table indices start at zero.
target_x: !byte 0
; WHAT: Emit 1 literal byte.
; WHY: Initialise one-dimensional proximity result; successive entries are adjacent bytes.
; HOW: The label hit names this data address. These are stored data, not CPU instructions.
; Binary row bits run left to right from the high bit of each byte; table indices start at zero.
hit:      !byte 0
