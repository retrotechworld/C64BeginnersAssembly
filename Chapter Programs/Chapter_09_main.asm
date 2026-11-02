; ========================================================================
; Chapter_09_main.asm - documented ACME source
; Every code-bearing line has WHAT, WHY and HOW comments.
; WHAT describes the operation. WHY explains its role. HOW explains encoding,
; flags, addressing, hardware effects or control flow.
; Code comments do not change the generated program bytes.
; PURPOSE: Move a sprite with port-2 joystick or W/A/S/D keyboard events, and show fire in
; red.
; FLOW: The main loop synchronises to the beginning of the next line 250, snapshots joystick
; bits and calls bounded movement routines. GETIN returns buffered key events; a fire flag
; merges space/fire input into the final colour decision.
; TRY: Use the joystick diagonally, then compare it with repeated keyboard taps. Hold fire and
; observe colour selection.
; ASSUMPTIONS: GETIN needs the normal keyboard service running. The original wait comment
; described leaving the target line, but the code leaves a current line 250 and waits for its
; next beginning; the comment is corrected. Bounds use equality and assume positions start
; within range.
; ASSEMBLE: Select CBM format and an output name using the command line.
; Example from the companion root:
; acme --strict-segments -f cbm -o demo.prg chapter_programs/Chapter_09_main.asm
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
; WHAT: I = 1.
; WHY: Mask IRQ recognition; NMI and hardware activity continue.
; HOW: Mask IRQ recognition; NMI and hardware activity continue. Among status flags, only I
; changes.
    sei
    ; Sprite graphics at $3000: a solid 24x21 block.
; WHAT: Load X from 0 (literal value).
; WHY: Set the literal value needed to prepare the program before display updates begin.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    ldx #0
; WHAT: Define address label shape.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
shape:
; WHAT: Load A from $ff (literal value).
; WHY: Prepare the value for shared sprite bitmap start.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #$ff
; WHAT: Copy A to shared sprite bitmap start.
; WHY: Update shared sprite bitmap start while we process this section.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta $3000,x
; WHAT: Increment X modulo 256.
; WHY: Advance the counter, position or offset used to process this loop.
; HOW: Implied/accumulator form; no separate memory operand. Flags updated: N Z.
    inx
; WHAT: Compare X with #63 without changing that register.
; WHY: Set the condition for the following branch in shape.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cpx #63
; WHAT: Branch when Z=0; target is shape.
; WHY: Choose the path that continues or completes this operation.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne shape
; WHAT: Load A from 0 (literal value).
; WHY: Prepare the value for sprite slot padding.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #0
; WHAT: Copy A to sprite slot padding.
; WHY: Update sprite slot padding while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $303f

    ; Default VIC bank 0, screen $0400.
; WHAT: Load A from $c0 (literal value).
; WHY: $3000 / 64.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #$c0        ; $3000 / 64
; WHAT: Copy A to first sprite pointer.
; WHY: Update first sprite pointer while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $07f8
; WHAT: Load A from 1 (literal value).
; WHY: Prepare the value for sprite-enable mask.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #1
; WHAT: Copy A to sprite-enable mask.
; WHY: enable sprite 0.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.  Bit n enables hardware sprite channel n when it is 1.
    sta $d015       ; enable sprite 0
; WHAT: Load A from 0 (literal value).
; WHY: Prepare the value for sprite X-high-bit mask.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #0
; WHAT: Copy A to sprite X-high-bit mask.
; WHY: X is 0..255.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.  Bit n supplies X bit 8 for hardware sprite n.
    sta $d010       ; X is 0..255
; WHAT: Copy A to sprite Y-expansion mask.
; WHY: normal height.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d017       ; normal height
; WHAT: Copy A to sprite X-expansion mask.
; WHY: normal width.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d01d       ; normal width
; WHAT: Load A from 7 (literal value).
; WHY: Prepare the value for sprite 0 colour / colour-register base.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #7
; WHAT: Copy A to sprite 0 colour / colour-register base.
; WHY: yellow.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d027       ; yellow
; WHAT: Load A from 120 (literal value).
; WHY: Prepare the value for sprite 0 X low byte.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #120
; WHAT: Copy A to sprite 0 X low byte.
; WHY: Update sprite 0 X low byte while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d000
; WHAT: Load A from 120 (literal value).
; WHY: Prepare the value for sprite 0 Y coordinate.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #120
; WHAT: Copy A to sprite 0 Y coordinate.
; WHY: Update sprite 0 Y coordinate while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d001
; WHAT: I = 0.
; WHY: Permit maskable IRQ recognition; does not clear interrupt sources.
; HOW: Permit maskable IRQ recognition; does not clear interrupt sources. Among status flags,
; only I change.
    cli

; WHAT: Define address label main_loop.
; WHY: Name the entry or data location used to repeat the foreground loop.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
main_loop:
; WHAT: Call wait_frame.
; WHY: Delegate work to wait for the next target raster event used by this example.
; HOW: Push the address of the last JSR byte on the page-1 stack, then load the target into PC.
; RTS pulls it and adds one.
    jsr wait_frame
; WHAT: Load A from 0 (literal value).
; WHY: Prepare the value for merged fire-button/key flag.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #0
; WHAT: Copy A to merged fire-button/key flag.
; WHY: Update merged fire-button/key flag while we repeat the foreground loop.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta fire_flag
; WHAT: Call read_joystick.
; WHY: Delegate work to turn active-low direction bits into fine-scroll changes.
; HOW: Push the address of the last JSR byte on the page-1 stack, then load the target into PC.
; RTS pulls it and adds one.
    jsr read_joystick
; WHAT: Call read_keyboard.
; WHY: Delegate work to convert one buffered key event into movement or fire.
; HOW: Push the address of the last JSR byte on the page-1 stack, then load the target into PC.
; RTS pulls it and adds one.
    jsr read_keyboard
; WHAT: Load A from merged fire-button/key flag.
; WHY: Fetch merged fire-button/key flag while we repeat the foreground loop.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda fire_flag
; WHAT: Branch when Z=1; target is no_fire.
; WHY: Choose the path that continues or completes repeat the foreground loop.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    beq no_fire
; WHAT: Load A from 2 (literal value).
; WHY: red while firing.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #2          ; red while firing
; WHAT: Branch when Z=0; target is set_colour.
; WHY: Choose the path that continues or completes repeat the foreground loop.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne set_colour
; WHAT: Define address label no_fire.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
no_fire:
; WHAT: Load A from 7 (literal value).
; WHY: yellow otherwise.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #7          ; yellow otherwise
; WHAT: Define address label set_colour.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
set_colour:
; WHAT: Copy A to sprite 0 colour / colour-register base.
; WHY: Update sprite 0 colour / colour-register base while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d027
; WHAT: Continue execution at main_loop.
; WHY: Repeat the main loop or join the named control path.
; HOW: Absolute JMP changes PC without stacking a return address; flags are unchanged.
    jmp main_loop

; Leave a currently active line 250, then wait for its next beginning.
; One update per video frame (PAL ~50, NTSC ~60).
; WHAT: Define address label wait_frame.
; WHY: Name the entry or data location used to wait for the next target raster event used by
; this example.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
wait_frame:
; WHAT: Define address label wait_not_250.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
wait_not_250:
; WHAT: Load A from raster low byte / compare target.
; WHY: Fetch raster low byte / compare target while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.  A read returns the current raster low byte, not the stored interrupt compare
; value.
    lda $d012
; WHAT: Compare A with #250 without changing that register.
; WHY: Set the condition for the following branch in wait_not_250.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cmp #250
; WHAT: Branch when Z=1; target is wait_not_250.
; WHY: Choose the path that continues or completes this operation.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    beq wait_not_250
; WHAT: Define address label wait_for_250.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
wait_for_250:
; WHAT: Load A from raster low byte / compare target.
; WHY: Fetch raster low byte / compare target while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.  A read returns the current raster low byte, not the stored interrupt compare
; value.
    lda $d012
; WHAT: Compare A with #250 without changing that register.
; WHY: Set the condition for the following branch in wait_for_250.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cmp #250
; WHAT: Branch when Z=0; target is wait_for_250.
; WHY: Choose the path that continues or completes this operation.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne wait_for_250
; WHAT: Return from the current subroutine.
; WHY: Return control to the caller after this routine has completed its work.
; HOW: Pull the JSR return address, add one, and continue there. The stack must still match the
; call; flags are unchanged.
    rts

; Joystick port 2 = CIA1 port A ($DC00), active low.
; Bits: 0 up, 1 down, 2 left, 3 right, 4 fire.
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
; WHAT: Copy A to saved joystick input bits.
; WHY: Update saved joystick input bits while we turn active-low direction bits into fine-scroll
; changes.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta joy_state
; WHAT: A = A AND #%00000001.
; WHY: Select, combine or constrain the bits used to turn active-low direction bits into fine-
; scroll changes.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    and #%00000001
; WHAT: Branch when Z=0; target is joy_down.
; WHY: Choose the path that continues or completes turn active-low direction bits into fine-
; scroll changes.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne joy_down
; WHAT: Call move_up.
; WHY: Delegate work to decrement the vertical coordinate within the stated bound.
; HOW: Push the address of the last JSR byte on the page-1 stack, then load the target into PC.
; RTS pulls it and adds one.
    jsr move_up
; WHAT: Define address label joy_down.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
joy_down:
; WHAT: Load A from saved joystick input bits.
; WHY: Fetch saved joystick input bits while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda joy_state
; WHAT: A = A AND #%00000010.
; WHY: Select, combine or constrain the bits used to update this setting.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    and #%00000010
; WHAT: Branch when Z=0; target is joy_left.
; WHY: Choose the path that continues or completes this operation.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne joy_left
; WHAT: Call move_down.
; WHY: Delegate work to apply the lower-band or downward-movement step for this example.
; HOW: Push the address of the last JSR byte on the page-1 stack, then load the target into PC.
; RTS pulls it and adds one.
    jsr move_down
; WHAT: Define address label joy_left.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
joy_left:
; WHAT: Load A from saved joystick input bits.
; WHY: Fetch saved joystick input bits while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda joy_state
; WHAT: A = A AND #%00000100.
; WHY: Select, combine or constrain the bits used to update this setting.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    and #%00000100
; WHAT: Branch when Z=0; target is joy_right.
; WHY: Choose the path that continues or completes this operation.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne joy_right
; WHAT: Call move_left.
; WHY: Delegate work to decrement the horizontal coordinate within the stated bound.
; HOW: Push the address of the last JSR byte on the page-1 stack, then load the target into PC.
; RTS pulls it and adds one.
    jsr move_left
; WHAT: Define address label joy_right.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
joy_right:
; WHAT: Load A from saved joystick input bits.
; WHY: Fetch saved joystick input bits while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda joy_state
; WHAT: A = A AND #%00001000.
; WHY: Select, combine or constrain the bits used to update this setting.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    and #%00001000
; WHAT: Branch when Z=0; target is joy_fire.
; WHY: Choose the path that continues or completes this operation.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne joy_fire
; WHAT: Call move_right.
; WHY: Delegate work to increment the horizontal coordinate within the stated bound.
; HOW: Push the address of the last JSR byte on the page-1 stack, then load the target into PC.
; RTS pulls it and adds one.
    jsr move_right
; WHAT: Define address label joy_fire.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
joy_fire:
; WHAT: Load A from saved joystick input bits.
; WHY: Fetch saved joystick input bits while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda joy_state
; WHAT: A = A AND #%00010000.
; WHY: Select, combine or constrain the bits used to update this setting.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    and #%00010000
; WHAT: Branch when Z=0; target is joy_done.
; WHY: Choose the path that continues or completes this operation.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne joy_done
; WHAT: Load A from 1 (literal value).
; WHY: Prepare the value for merged fire-button/key flag.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #1
; WHAT: Copy A to merged fire-button/key flag.
; WHY: Update merged fire-button/key flag while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta fire_flag
; WHAT: Define address label joy_done.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
joy_done:
; WHAT: Return from the current subroutine.
; WHY: Return control to the caller after this routine has completed its work.
; HOW: Pull the JSR return address, add one, and continue there. The stack must still match the
; call; flags are unchanged.
    rts

; KERNAL GETIN ($FFE4) reads buffered PETSCII keys.
; Keys are events, not held-key state; repeat depends
; on the C64's keyboard repeat behaviour.
; WHAT: Define address label read_keyboard.
; WHY: Name the entry or data location used to convert one buffered key event into movement or
; fire.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
read_keyboard:
; WHAT: Call $ffe4.
; WHY: Delegate work to $ffe4.
; HOW: Push the address of the last JSR byte on the page-1 stack, then load the target into PC.
; RTS pulls it and adds one.
    jsr $ffe4
; WHAT: Compare A with #'W' without changing that register.
; WHY: Set the condition for the following branch in read_keyboard.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cmp #'W'
; WHAT: Branch when Z=0; target is key_s.
; WHY: Choose the path that continues or completes convert one buffered key event into movement
; or fire.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne key_s
; WHAT: Call move_up.
; WHY: Delegate work to decrement the vertical coordinate within the stated bound.
; HOW: Push the address of the last JSR byte on the page-1 stack, then load the target into PC.
; RTS pulls it and adds one.
    jsr move_up
; WHAT: Return from the current subroutine.
; WHY: Return control to the caller after this routine has completed its work.
; HOW: Pull the JSR return address, add one, and continue there. The stack must still match the
; call; flags are unchanged.
    rts
; WHAT: Define address label key_s.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
key_s:
; WHAT: Compare A with #'S' without changing that register.
; WHY: Set the condition for the following branch in key_s.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cmp #'S'
; WHAT: Branch when Z=0; target is key_a.
; WHY: Choose the path that continues or completes this operation.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne key_a
; WHAT: Call move_down.
; WHY: Delegate work to apply the lower-band or downward-movement step for this example.
; HOW: Push the address of the last JSR byte on the page-1 stack, then load the target into PC.
; RTS pulls it and adds one.
    jsr move_down
; WHAT: Return from the current subroutine.
; WHY: Return control to the caller after this routine has completed its work.
; HOW: Pull the JSR return address, add one, and continue there. The stack must still match the
; call; flags are unchanged.
    rts
; WHAT: Define address label key_a.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
key_a:
; WHAT: Compare A with #'A' without changing that register.
; WHY: Set the condition for the following branch in key_a.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cmp #'A'
; WHAT: Branch when Z=0; target is key_d.
; WHY: Choose the path that continues or completes this operation.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne key_d
; WHAT: Call move_left.
; WHY: Delegate work to decrement the horizontal coordinate within the stated bound.
; HOW: Push the address of the last JSR byte on the page-1 stack, then load the target into PC.
; RTS pulls it and adds one.
    jsr move_left
; WHAT: Return from the current subroutine.
; WHY: Return control to the caller after this routine has completed its work.
; HOW: Pull the JSR return address, add one, and continue there. The stack must still match the
; call; flags are unchanged.
    rts
; WHAT: Define address label key_d.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
key_d:
; WHAT: Compare A with #'D' without changing that register.
; WHY: Set the condition for the following branch in key_d.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cmp #'D'
; WHAT: Branch when Z=0; target is key_space.
; WHY: Choose the path that continues or completes this operation.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne key_space
; WHAT: Call move_right.
; WHY: Delegate work to increment the horizontal coordinate within the stated bound.
; HOW: Push the address of the last JSR byte on the page-1 stack, then load the target into PC.
; RTS pulls it and adds one.
    jsr move_right
; WHAT: Return from the current subroutine.
; WHY: Return control to the caller after this routine has completed its work.
; HOW: Pull the JSR return address, add one, and continue there. The stack must still match the
; call; flags are unchanged.
    rts
; WHAT: Define address label key_space.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
key_space:
; WHAT: Compare A with #32 without changing that register.
; WHY: Set the condition for the following branch in key_space.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cmp #32
; WHAT: Branch when Z=0; target is key_done.
; WHY: Choose the path that continues or completes this operation.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne key_done
; WHAT: Load A from 1 (literal value).
; WHY: Prepare the value for merged fire-button/key flag.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #1
; WHAT: Copy A to merged fire-button/key flag.
; WHY: Update merged fire-button/key flag while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta fire_flag
; WHAT: Define address label key_done.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
key_done:
; WHAT: Return from the current subroutine.
; WHY: Return control to the caller after this routine has completed its work.
; HOW: Pull the JSR return address, add one, and continue there. The stack must still match the
; call; flags are unchanged.
    rts

; Keep sprite within X=24..240 and Y=50..229.
; WHAT: Define address label move_left.
; WHY: Name the entry or data location used to decrement the horizontal coordinate within the
; stated bound.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
move_left:
; WHAT: Load A from sprite 0 X low byte.
; WHY: Fetch sprite 0 X low byte while we decrement the horizontal coordinate within the stated
; bound.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda $d000
; WHAT: Compare A with #24 without changing that register.
; WHY: Set the condition for the following branch in move_left.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cmp #24
; WHAT: Branch when Z=1; target is left_done.
; WHY: Choose the path that continues or completes decrement the horizontal coordinate within
; the stated bound.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    beq left_done
; WHAT: Decrement sprite 0 X low byte modulo 256.
; WHY: Advance the counter, position or offset used to decrement the horizontal coordinate
; within the stated bound.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z. NMOS memory read-modify-write writes the old byte before the new one; avoid
; applying this blindly to I/O.
    dec $d000
; WHAT: Define address label left_done.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
left_done:
; WHAT: Return from the current subroutine.
; WHY: Return control to the caller after this routine has completed its work.
; HOW: Pull the JSR return address, add one, and continue there. The stack must still match the
; call; flags are unchanged.
    rts
; WHAT: Define address label move_right.
; WHY: Name the entry or data location used to increment the horizontal coordinate within the
; stated bound.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
move_right:
; WHAT: Load A from sprite 0 X low byte.
; WHY: Fetch sprite 0 X low byte while we increment the horizontal coordinate within the stated
; bound.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda $d000
; WHAT: Compare A with #240 without changing that register.
; WHY: Set the condition for the following branch in move_right.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cmp #240
; WHAT: Branch when Z=1; target is right_done.
; WHY: Choose the path that continues or completes increment the horizontal coordinate within
; the stated bound.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    beq right_done
; WHAT: Increment sprite 0 X low byte modulo 256.
; WHY: Advance the counter, position or offset used to increment the horizontal coordinate
; within the stated bound.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z. NMOS memory read-modify-write writes the old byte before the new one; avoid
; applying this blindly to I/O.
    inc $d000
; WHAT: Define address label right_done.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
right_done:
; WHAT: Return from the current subroutine.
; WHY: Return control to the caller after this routine has completed its work.
; HOW: Pull the JSR return address, add one, and continue there. The stack must still match the
; call; flags are unchanged.
    rts
; WHAT: Define address label move_up.
; WHY: Name the entry or data location used to decrement the vertical coordinate within the
; stated bound.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
move_up:
; WHAT: Load A from sprite 0 Y coordinate.
; WHY: Fetch sprite 0 Y coordinate while we decrement the vertical coordinate within the stated
; bound.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda $d001
; WHAT: Compare A with #50 without changing that register.
; WHY: Set the condition for the following branch in move_up.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cmp #50
; WHAT: Branch when Z=1; target is up_done.
; WHY: Choose the path that continues or completes decrement the vertical coordinate within the
; stated bound.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    beq up_done
; WHAT: Decrement sprite 0 Y coordinate modulo 256.
; WHY: Advance the counter, position or offset used to decrement the vertical coordinate within
; the stated bound.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z. NMOS memory read-modify-write writes the old byte before the new one; avoid
; applying this blindly to I/O.
    dec $d001
; WHAT: Define address label up_done.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
up_done:
; WHAT: Return from the current subroutine.
; WHY: Return control to the caller after this routine has completed its work.
; HOW: Pull the JSR return address, add one, and continue there. The stack must still match the
; call; flags are unchanged.
    rts
; WHAT: Define address label move_down.
; WHY: Name the entry or data location used to apply the lower-band or downward-movement step
; for this example.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
move_down:
; WHAT: Load A from sprite 0 Y coordinate.
; WHY: Fetch sprite 0 Y coordinate while we apply the lower-band or downward-movement step for
; this example.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda $d001
; WHAT: Compare A with #229 without changing that register.
; WHY: Set the condition for the following branch in move_down.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cmp #229
; WHAT: Branch when Z=1; target is down_done.
; WHY: Choose the path that continues or completes apply the lower-band or downward-movement
; step for this example.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    beq down_done
; WHAT: Increment sprite 0 Y coordinate modulo 256.
; WHY: Advance the counter, position or offset used to apply the lower-band or downward-movement
; step for this example.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z. NMOS memory read-modify-write writes the old byte before the new one; avoid
; applying this blindly to I/O.
    inc $d001
; WHAT: Define address label down_done.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
down_done:
; WHAT: Return from the current subroutine.
; WHY: Return control to the caller after this routine has completed its work.
; HOW: Pull the JSR return address, add one, and continue there. The stack must still match the
; call; flags are unchanged.
    rts

; WHAT: Emit 1 literal byte.
; WHY: Initialise saved joystick input bits; successive entries are adjacent bytes.
; HOW: The label joy_state names this data address. These are stored data, not CPU instructions.
; Binary row bits run left to right from the high bit of each byte; table indices start at zero.
joy_state: !byte 0
; WHAT: Emit 1 literal byte.
; WHY: Initialise merged fire-button/key flag; successive entries are adjacent bytes.
; HOW: The label fire_flag names this data address. These are stored data, not CPU instructions.
; Binary row bits run left to right from the high bit of each byte; table indices start at zero.
fire_flag: !byte 0
