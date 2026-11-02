; ========================================================================
; grid.asm - documented ACME source
; Every code-bearing line has WHAT, WHY and HOW comments.
; WHAT describes the operation. WHY explains its role. HOW explains encoding,
; flags, addressing, hardware effects or control flow.
; Code comments do not change the generated program bytes.
; PURPOSE: Scroll a repeating custom cross tile with joystick port 2.
; ASSUMPTIONS: Teaching rewrite of the supplied grid: known VIC setup, software control
; shadows and exact screen fill. Fine scroll only; reset to exit.
; FIND IN GUIDE: PDF lessons pages 44-47; complete walkthrough pages 99-109. Word edition:
; lessons pages 41-44; complete walkthrough pages 91-100 in the checked render.
; ASSEMBLE: Select CBM format and an output name using the command line.
; Example from the companion root:
; acme --strict-segments -f cbm -o demo.prg programs/grid.asm
; Archived originals are unchanged and are not the recommended teaching copies.
; ========================================================================
; Fully documented edition: WHAT / WHY / HOW before each code-bearing line.
; Book listing numbers are mapped to this file in SOURCE_LINE_MAP.json.
; Gridrunner-inspired repeating grid study, not the original commercial game.
; ACME / stock C64 / reset before running / joystick port 2.
; Teaching rewrite of supplied gridrunner.asm; see README.md for changes.
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
; WHAT: I = 1.
; WHY: Mask IRQ recognition; NMI and hardware activity continue.
; HOW: Mask IRQ recognition; NMI and hardware activity continue. Among status flags, only I
; changes.
    sei
; WHAT: D = 0.
; WHY: Select ordinary binary ADC/SBC arithmetic.
; HOW: Select ordinary binary ADC/SBC arithmetic. Among status flags, only D change.
    cld
; WHAT: Load A from $7f (literal value).
; WHY: Prepare the value for CIA1 interrupt control/status.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #$7f
; WHAT: Copy A to CIA1 interrupt control/status.
; WHY: Update CIA1 interrupt control/status while we prepare the program before display updates
; begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged. With bit 7 clear, each written 1 disables that interrupt source; bit 7 set
; enables selected sources.
    sta $dc0d
; WHAT: Copy A to CIA2 interrupt control/status.
; WHY: Update CIA2 interrupt control/status while we prepare the program before display updates
; begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged. With bit 7 clear, each written 1 disables that interrupt source; bit 7 set
; enables selected sources.
    sta $dd0d
; WHAT: Load A from CIA1 interrupt control/status.
; WHY: Fetch CIA1 interrupt control/status while we prepare the program before display updates
; begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.  Reading this CIA register clears its pending interrupt flags.
    lda $dc0d
; WHAT: Load A from CIA2 interrupt control/status.
; WHY: Fetch CIA2 interrupt control/status while we prepare the program before display updates
; begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.  Reading this CIA register clears its pending interrupt flags.
    lda $dd0d
; WHAT: Load A from 0 (literal value).
; WHY: Prepare the value for VIC interrupt enables.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #0
; WHAT: Copy A to VIC interrupt enables.
; WHY: Update VIC interrupt enables while we prepare the program before display updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d01a
; WHAT: Copy A to sprite-enable mask.
; WHY: Update sprite-enable mask while we prepare the program before display updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.  Bit n enables hardware sprite channel n when it is 1.
    sta $d015
; WHAT: Load A from $0f (literal value).
; WHY: Prepare the value for VIC pending interrupt flags.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #$0f
; WHAT: Copy A to VIC pending interrupt flags.
; WHY: Update VIC pending interrupt flags while we prepare the program before display updates
; begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged. Writing a 1 acknowledges the corresponding pending VIC flag, not an ordinary
; RAM assignment.
    sta $d019
    ; CIA2 low two output bits select VIC bank; 3 means $0000.
; WHAT: Load A from CIA2 port A direction register.
; WHY: Fetch CIA2 port A direction register while we prepare the program before display updates
; begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda $dd02
; WHAT: A = A OR #3.
; WHY: Select, combine or constrain the bits used to prepare the program before display updates
; begin.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    ora #3
; WHAT: Copy A to CIA2 port A direction register.
; WHY: Update CIA2 port A direction register while we prepare the program before display updates
; begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.  Each direction bit is 1 for output and 0 for input.
    sta $dd02
; WHAT: Load A from CIA2 port A / VIC bank bits.
; WHY: Fetch CIA2 port A / VIC bank bits while we prepare the program before display updates
; begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda $dd00
; WHAT: A = A OR #3.
; WHY: Select, combine or constrain the bits used to prepare the program before display updates
; begin.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    ora #3
; WHAT: Copy A to CIA2 port A / VIC bank bits.
; WHY: Update CIA2 port A / VIC bank bits while we prepare the program before display updates
; begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.  Low two output bits select VIC bank with inverted encoding: 3 selects the
; $0000 bank.
    sta $dd00
    ; CIA1 Port A direction inputs for joystick port 2.
; WHAT: Load A from 0 (literal value).
; WHY: Prepare the value for CIA1 port A direction register.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #0
; WHAT: Copy A to CIA1 port A direction register.
; WHY: Update CIA1 port A direction register while we prepare the program before display updates
; begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.  Each direction bit is 1 for output and 0 for input.
    sta $dc02
; WHAT: Copy A to 0-7 horizontal fine offset.
; WHY: Update 0-7 horizontal fine offset while we prepare the program before display updates
; begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta scroll_x
; WHAT: Copy A to 0-7 vertical fine offset.
; WHY: Update 0-7 vertical fine offset while we prepare the program before display updates
; begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta scroll_y
; WHAT: Copy A to border colour.
; WHY: Update border colour while we prepare the program before display updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d020
; WHAT: Copy A to background colour.
; WHY: Update background colour while we prepare the program before display updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d021
    ; 38 columns / 24 rows hide fine-scroll seams behind border.
; WHAT: Load A from $10 (literal value).
; WHY: Prepare the value for fixed $D011 settings in RAM.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #$10
; WHAT: Copy A to fixed $D011 settings in RAM.
; WHY: Update fixed $D011 settings in RAM while we prepare the program before display updates
; begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta control_y
; WHAT: Copy A to vertical/control register with mixed raster read/write bit.
; WHY: Update vertical/control register with mixed raster read/write bit while we prepare the
; program before display updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.  Bits 0-2 select fine Y; bit 7 written selects raster compare high, unlike its
; read meaning.
    sta $d011
; WHAT: Load A from $00 (literal value).
; WHY: Prepare the value for fixed $D016 settings in RAM.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #$00
; WHAT: Copy A to fixed $D016 settings in RAM.
; WHY: Update fixed $D016 settings in RAM while we prepare the program before display updates
; begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta control_x
; WHAT: Copy A to horizontal/control register.
; WHY: Update horizontal/control register while we prepare the program before display updates
; begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.  Bits 0-2 select fine X; bit 3 chooses 40/38 columns; preserve deliberate upper
; controls.
    sta $d016
    ; Screen $0400, custom characters $2000 in bank 0.
; WHAT: Load A from $18 (literal value).
; WHY: Prepare the value for video-memory selection.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #$18
; WHAT: Copy A to video-memory selection.
; WHY: Update video-memory selection while we prepare the program before display updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d018
; WHAT: Call setup_custom_chars.
; WHY: Delegate work to define the cross tile pixels.
; HOW: Push the address of the last JSR byte on the page-1 stack, then load the target into PC.
; RTS pulls it and adds one.
    jsr setup_custom_chars
; WHAT: Call init_screen.
; WHY: Delegate work to fill visible screen cells and matching colour RAM.
; HOW: Push the address of the last JSR byte on the page-1 stack, then load the target into PC.
; RTS pulls it and adds one.
    jsr init_screen
; WHAT: Define address label main_loop.
; WHY: Name the entry or data location used to repeat the foreground loop.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
main_loop:
; WHAT: Call wait_frame.
; WHY: Delegate work to synchronise work to the end of raster line 250.
; HOW: Push the address of the last JSR byte on the page-1 stack, then load the target into PC.
; RTS pulls it and adds one.
    jsr wait_frame
; WHAT: Call read_joystick.
; WHY: Delegate work to turn active-low direction bits into fine-scroll changes.
; HOW: Push the address of the last JSR byte on the page-1 stack, then load the target into PC.
; RTS pulls it and adds one.
    jsr read_joystick
; WHAT: Call update_scroll.
; WHY: Delegate work to merge offsets with known display-control settings.
; HOW: Push the address of the last JSR byte on the page-1 stack, then load the target into PC.
; RTS pulls it and adds one.
    jsr update_scroll
; WHAT: Continue execution at main_loop.
; WHY: Repeat the main loop or join the named control path.
; HOW: Absolute JMP changes PC without stacking a return address; flags are unchanged.
    jmp main_loop
; WHAT: Define address label wait_frame.
; WHY: Name the entry or data location used to synchronise work to the end of raster line 250.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
wait_frame:
; WHAT: Define address label .wait_in.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
.wait_in:
; WHAT: Load A from raster low byte / compare target.
; WHY: Fetch raster low byte / compare target while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.  A read returns the current raster low byte, not the stored interrupt compare
; value.
    lda $d012
; WHAT: Compare A with #250 without changing that register.
; WHY: Set the condition for the following branch in .wait_in.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cmp #250
; WHAT: Branch when Z=0; target is .wait_in.
; WHY: Choose the path that continues or completes this operation.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne .wait_in
; WHAT: Define address label .wait_out.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
.wait_out:
; WHAT: Load A from raster low byte / compare target.
; WHY: Fetch raster low byte / compare target while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.  A read returns the current raster low byte, not the stored interrupt compare
; value.
    lda $d012
; WHAT: Compare A with #250 without changing that register.
; WHY: Set the condition for the following branch in .wait_out.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cmp #250
; WHAT: Branch when Z=1; target is .wait_out.
; WHY: Choose the path that continues or completes this operation.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    beq .wait_out
; WHAT: Return from the current subroutine.
; WHY: Return control to the caller after this routine has completed its work.
; HOW: Pull the JSR return address, add one, and continue there. The stack must still match the
; call; flags are unchanged.
    rts
; WHAT: Define address label setup_custom_chars.
; WHY: Name the entry or data location used to define the cross tile pixels.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
setup_custom_chars:
    ; Only character 1 is used. Define all eight of its rows.
; WHAT: Load X from 7 (literal value).
; WHY: Set the literal value needed to define the cross tile pixels.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    ldx #7
; WHAT: Define address label .copy.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
.copy:
; WHAT: Load A from eight pixel rows of the grid cross.
; WHY: Fetch eight pixel rows of the grid cross while we process this section.
; HOW: Indexed address: add the index register to the named base address. Flags updated: N Z.
    lda tile,x
; WHAT: Copy A to character 1 bitmap start.
; WHY: Update character 1 bitmap start while we process this section.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta $2008,x
; WHAT: Decrement X modulo 256.
; WHY: Advance the counter, position or offset used to process this loop.
; HOW: Implied/accumulator form; no separate memory operand. Flags updated: N Z.
    dex
; WHAT: Branch when N=0; target is .copy.
; WHY: Choose the path that continues or completes this operation.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bpl .copy
; WHAT: Return from the current subroutine.
; WHY: Return control to the caller after this routine has completed its work.
; HOW: Pull the JSR return address, add one, and continue there. The stack must still match the
; call; flags are unchanged.
    rts
; WHAT: Define address label init_screen.
; WHY: Name the entry or data location used to fill visible screen cells and matching colour
; RAM.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
init_screen:
; WHAT: Load X from 0 (literal value).
; WHY: Set the literal value needed to fill visible screen cells and matching colour RAM.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    ldx #0
; WHAT: Define address label .fill.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
.fill:
; WHAT: Load A from 1 (literal value).
; WHY: Prepare the value for first screen cell.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #1
; WHAT: Copy A to first screen cell.
; WHY: Update first screen cell while we process this section.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta $0400,x
; WHAT: Copy A to $0500.
; WHY: Update $0500 while we process this section.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta $0500,x
; WHAT: Copy A to $0600.
; WHY: Update $0600 while we process this section.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta $0600,x
; WHAT: Load A from 2 (literal value).
; WHY: Prepare the value for first colour-RAM cell.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #2
; WHAT: Copy A to first colour-RAM cell.
; WHY: Update first colour-RAM cell while we process this section.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta $d800,x
; WHAT: Copy A to $d900.
; WHY: Update $d900 while we process this section.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta $d900,x
; WHAT: Copy A to $da00.
; WHY: Update $da00 while we process this section.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta $da00,x
; WHAT: Increment X modulo 256.
; WHY: Advance the counter, position or offset used to process this loop.
; HOW: Implied/accumulator form; no separate memory operand. Flags updated: N Z.
    inx
; WHAT: Branch when Z=0; target is .fill.
; WHY: Choose the path that continues or completes this operation.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne .fill
; WHAT: Load X from 0 (literal value).
; WHY: Set the literal value needed to perform this step.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    ldx #0
; WHAT: Define address label .tail.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
.tail:
; WHAT: Load A from 1 (literal value).
; WHY: Prepare the value for $0700.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #1
; WHAT: Copy A to $0700.
; WHY: Update $0700 while we process this section.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta $0700,x
; WHAT: Load A from 2 (literal value).
; WHY: Prepare the value for $db00.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #2
; WHAT: Copy A to $db00.
; WHY: Update $db00 while we process this section.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta $db00,x
; WHAT: Increment X modulo 256.
; WHY: Advance the counter, position or offset used to process this loop.
; HOW: Implied/accumulator form; no separate memory operand. Flags updated: N Z.
    inx
; WHAT: Compare X with #232 without changing that register.
; WHY: Set the condition for the following branch in .tail.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cpx #232
; WHAT: Branch when Z=0; target is .tail.
; WHY: Choose the path that continues or completes this operation.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne .tail
; WHAT: Return from the current subroutine.
; WHY: Return control to the caller after this routine has completed its work.
; HOW: Pull the JSR return address, add one, and continue there. The stack must still match the
; call; flags are unchanged.
    rts
; WHAT: Define address label read_joystick.
; WHY: Name the entry or data location used to turn active-low direction bits into fine-scroll
; changes.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
read_joystick:
; WHAT: Load A from CIA1 port A / joystick 2.
; WHY: Fetch CIA1 port A / joystick 2 while we turn active-low direction bits into fine-scroll
; changes.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda $dc00
; WHAT: A = A AND #1.
; WHY: Select, combine or constrain the bits used to turn active-low direction bits into fine-
; scroll changes.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    and #1
; WHAT: Branch when Z=0; target is .not_up.
; WHY: Choose the path that continues or completes turn active-low direction bits into fine-
; scroll changes.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne .not_up
; WHAT: Decrement 0-7 vertical fine offset modulo 256.
; WHY: Advance the counter, position or offset used to turn active-low direction bits into fine-
; scroll changes.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z. NMOS memory read-modify-write writes the old byte before the new one; avoid
; applying this blindly to I/O.
    dec scroll_y
; WHAT: Define address label .not_up.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
.not_up:
; WHAT: Load A from CIA1 port A / joystick 2.
; WHY: Fetch CIA1 port A / joystick 2 while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda $dc00
; WHAT: A = A AND #2.
; WHY: Select, combine or constrain the bits used to update this setting.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    and #2
; WHAT: Branch when Z=0; target is .not_down.
; WHY: Choose the path that continues or completes this operation.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne .not_down
; WHAT: Increment 0-7 vertical fine offset modulo 256.
; WHY: Advance the counter, position or offset used to process this loop.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z. NMOS memory read-modify-write writes the old byte before the new one; avoid
; applying this blindly to I/O.
    inc scroll_y
; WHAT: Define address label .not_down.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
.not_down:
; WHAT: Load A from CIA1 port A / joystick 2.
; WHY: Fetch CIA1 port A / joystick 2 while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda $dc00
; WHAT: A = A AND #4.
; WHY: Select, combine or constrain the bits used to update this setting.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    and #4
; WHAT: Branch when Z=0; target is .not_left.
; WHY: Choose the path that continues or completes this operation.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne .not_left
; WHAT: Decrement 0-7 horizontal fine offset modulo 256.
; WHY: Advance the counter, position or offset used to process this loop.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z. NMOS memory read-modify-write writes the old byte before the new one; avoid
; applying this blindly to I/O.
    dec scroll_x
; WHAT: Define address label .not_left.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
.not_left:
; WHAT: Load A from CIA1 port A / joystick 2.
; WHY: Fetch CIA1 port A / joystick 2 while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda $dc00
; WHAT: A = A AND #8.
; WHY: Select, combine or constrain the bits used to update this setting.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    and #8
; WHAT: Branch when Z=0; target is .not_right.
; WHY: Choose the path that continues or completes this operation.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne .not_right
; WHAT: Increment 0-7 horizontal fine offset modulo 256.
; WHY: Advance the counter, position or offset used to process this loop.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z. NMOS memory read-modify-write writes the old byte before the new one; avoid
; applying this blindly to I/O.
    inc scroll_x
; WHAT: Define address label .not_right.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
.not_right:
; WHAT: Load A from 0-7 horizontal fine offset.
; WHY: Fetch 0-7 horizontal fine offset while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda scroll_x
; WHAT: A = A AND #7.
; WHY: Select, combine or constrain the bits used to update this setting.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    and #7
; WHAT: Copy A to 0-7 horizontal fine offset.
; WHY: Update 0-7 horizontal fine offset while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta scroll_x
; WHAT: Load A from 0-7 vertical fine offset.
; WHY: Fetch 0-7 vertical fine offset while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda scroll_y
; WHAT: A = A AND #7.
; WHY: Select, combine or constrain the bits used to update this setting.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    and #7
; WHAT: Copy A to 0-7 vertical fine offset.
; WHY: Update 0-7 vertical fine offset while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta scroll_y
; WHAT: Return from the current subroutine.
; WHY: Return control to the caller after this routine has completed its work.
; HOW: Pull the JSR return address, add one, and continue there. The stack must still match the
; call; flags are unchanged.
    rts
; WHAT: Define address label update_scroll.
; WHY: Name the entry or data location used to merge offsets with known display-control
; settings.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
update_scroll:
; WHAT: Load A from fixed $D016 settings in RAM.
; WHY: Fetch fixed $D016 settings in RAM while we merge offsets with known display-control
; settings.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda control_x
; WHAT: A = A OR scroll_x.
; WHY: Select, combine or constrain the bits used to merge offsets with known display-control
; settings.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    ora scroll_x
; WHAT: Copy A to horizontal/control register.
; WHY: Update horizontal/control register while we merge offsets with known display-control
; settings.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.  Bits 0-2 select fine X; bit 3 chooses 40/38 columns; preserve deliberate upper
; controls.
    sta $d016
; WHAT: Load A from fixed $D011 settings in RAM.
; WHY: Fetch fixed $D011 settings in RAM while we merge offsets with known display-control
; settings.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda control_y
; WHAT: A = A OR scroll_y.
; WHY: Select, combine or constrain the bits used to merge offsets with known display-control
; settings.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    ora scroll_y
; WHAT: Copy A to vertical/control register with mixed raster read/write bit.
; WHY: Update vertical/control register with mixed raster read/write bit while we merge offsets
; with known display-control settings.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.  Bits 0-2 select fine Y; bit 7 written selects raster compare high, unlike its
; read meaning.
    sta $d011
; WHAT: Return from the current subroutine.
; WHY: Return control to the caller after this routine has completed its work.
; HOW: Pull the JSR return address, add one, and continue there. The stack must still match the
; call; flags are unchanged.
    rts
; WHAT: Emit 1 literal byte.
; WHY: Initialise 0-7 horizontal fine offset; successive entries are adjacent bytes.
; HOW: The label scroll_x names this data address. These are stored data, not CPU instructions.
; Binary row bits run left to right from the high bit of each byte; table indices start at zero.
scroll_x: !byte 0
; WHAT: Emit 1 literal byte.
; WHY: Initialise 0-7 vertical fine offset; successive entries are adjacent bytes.
; HOW: The label scroll_y names this data address. These are stored data, not CPU instructions.
; Binary row bits run left to right from the high bit of each byte; table indices start at zero.
scroll_y: !byte 0
; WHAT: Emit 1 literal byte.
; WHY: Initialise fixed $D016 settings in RAM; successive entries are adjacent bytes.
; HOW: The label control_x names this data address. These are stored data, not CPU instructions.
; Binary row bits run left to right from the high bit of each byte; table indices start at zero.
control_x: !byte 0
; WHAT: Emit 1 literal byte.
; WHY: Initialise fixed $D011 settings in RAM; successive entries are adjacent bytes.
; HOW: The label control_y names this data address. These are stored data, not CPU instructions.
; Binary row bits run left to right from the high bit of each byte; table indices start at zero.
control_y: !byte 0
; WHAT: Emit 8 literal bytes.
; WHY: Initialise eight pixel rows of the grid cross; successive entries are adjacent bytes.
; HOW: The label tile names this data address. These are stored data, not CPU instructions.
; Binary row bits run left to right from the high bit of each byte; table indices start at zero.
tile: !byte $18,$18,$18,$ff,$18,$18,$18,$18
