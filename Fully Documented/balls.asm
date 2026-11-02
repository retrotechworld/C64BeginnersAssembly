; ========================================================================
; balls.asm - documented ACME source
; Every code-bearing line has WHAT, WHY and HOW comments.
; WHAT describes the operation. WHY explains its role. HOW explains encoding,
; flags, addressing, hardware effects or control flow.
; Code comments do not change the generated program bytes.
; PURPOSE: Display twelve logical balls using four hardware sprites in three PAL raster bands.
; ASSUMPTIONS: PAL stock C64 after reset; hardware channels 0-3 are reused at lines
; 45/115/181, and movement updates at 250. Reset to exit.
; FIND IN GUIDE: PDF lessons pages 39-43; complete walkthrough pages 72-98. Word edition:
; lessons pages 36-40; complete walkthrough pages 67-90 in the checked render.
; ASSEMBLE: Select CBM format and an output name using the command line.
; Example from the companion root:
; acme --strict-segments -f cbm -o demo.prg programs/balls.asm
; Archived originals are unchanged and are not the recommended teaching copies.
; ========================================================================
; Fully documented edition: WHAT / WHY / HOW before each code-bearing line.
; Book listing numbers are mapped to this file in SOURCE_LINE_MAP.json.
; --------------------------------------------------------------
; SWIRLING BOUNCING BALLS - Commodore 64 / ACME assembler
; --------------------------------------------------------------
; 12 moving balls, but only FOUR real hardware sprites!
; We reuse sprites 0-3 three times per video frame.
;
; Build: acme -f cbm -o swirling_balls.prg balls.asm
; Run:   LOAD "SWIRLING_BALLS",8,1  then SYS 2064
; In VICE you can also drag the resulting PRG into the emulator.
;
; This is written for PAL C64 timing (raster lines 45/115/181/250).
; The sprite positions are separated vertically to make the
; beginner-friendly multiplexing reliable without cycle tricks.
; --------------------------------------------------------------

; Output filename is selected by the -o command-line option.

; WHAT: Define SCREEN as $0400.
; WHY: Give text-screen base a readable symbolic name.
; HOW: ACME substitutes the value in expressions; this assignment allocates no RAM and executes
; no instruction.
SCREEN      = $0400          ; Start of the C64's text screen
; WHAT: Define SPR_PTR as $07f8.
; WHY: Give sprite-pointer table base a readable symbolic name.
; HOW: ACME substitutes the value in expressions; this assignment allocates no RAM and executes
; no instruction.
SPR_PTR     = $07f8          ; Four sprite pointer bytes live here
; WHAT: Define SPR_X as $d000.
; WHY: Give hardware sprite X-register base a readable symbolic name.
; HOW: ACME substitutes the value in expressions; this assignment allocates no RAM and executes
; no instruction.
SPR_X       = $d000          ; Sprite 0 X, sprite 0 Y, sprite 1 X...
; WHAT: Define SPR_Y as $d001.
; WHY: Give hardware sprite Y-register base a readable symbolic name.
; HOW: ACME substitutes the value in expressions; this assignment allocates no RAM and executes
; no instruction.
SPR_Y       = $d001
; WHAT: Define SPR_X_MSB as $d010.
; WHY: Give collected ninth X-coordinate bits a readable symbolic name.
; HOW: ACME substitutes the value in expressions; this assignment allocates no RAM and executes
; no instruction.
SPR_X_MSB   = $d010          ; High X bit for all eight sprites
; WHAT: Define SPR_ENABLE as $d015.
; WHY: Give sprite-enable mask a readable symbolic name.
; HOW: ACME substitutes the value in expressions; this assignment allocates no RAM and executes
; no instruction.
SPR_ENABLE  = $d015          ; Which hardware sprites are visible?
; WHAT: Define RASTER as $d012.
; WHY: Give raster compare low byte a readable symbolic name.
; HOW: ACME substitutes the value in expressions; this assignment allocates no RAM and executes
; no instruction.
RASTER      = $d012          ; Current / requested raster line
; WHAT: Define IRQ_STATUS as $d019.
; WHY: Give VIC interrupt acknowledge register a readable symbolic name.
; HOW: ACME substitutes the value in expressions; this assignment allocates no RAM and executes
; no instruction.
IRQ_STATUS  = $d019          ; VIC interrupt status and acknowledge
; WHAT: Define IRQ_ENABLE as $d01a.
; WHY: Give VIC interrupt enable register a readable symbolic name.
; HOW: ACME substitutes the value in expressions; this assignment allocates no RAM and executes
; no instruction.
IRQ_ENABLE  = $d01a          ; Enable VIC raster interrupts

; BASIC line: 10 SYS2064. The machine code begins at $0810.
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
!byte $00,$00,$00

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
; WHY: Don't interrupt us during setup.
; HOW: Mask IRQ recognition; NMI and hardware activity continue. Among status flags, only I
; changes.
    sei                     ; Don't interrupt us during setup

; WHAT: Load A from $00 (literal value).
; WHY: Prepare the value for border colour.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #$00
; WHAT: Copy A to border colour.
; WHY: Black border.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d020               ; Black border
; WHAT: Copy A to background colour.
; WHY: Black background.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d021               ; Black background
; WHAT: Call $e544.
; WHY: Clear the display using an internal standard-ROM editor entry; see the ROM compatibility
; appendix.
; HOW: Push the address of the last JSR byte on the page-1 stack, then load the target into PC.
; RTS pulls it and adds one.
    jsr $e544               ; KERNAL: clear text screen

; WHAT: Load X from $00 (literal value).
; WHY: Set the literal value needed to prepare the program before display updates begin.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    ldx #$00
; WHAT: Define address label title_loop.
; WHY: Name the entry or data location used to copy the screen-code title until its zero
; terminator.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
title_loop:
; WHAT: Load A from zero-terminated screen-code title.
; WHY: Fetch zero-terminated screen-code title while we copy the screen-code title until its
; zero terminator.
; HOW: Indexed address: add the index register to the named base address. Flags updated: N Z.
    lda title_text,x
; WHAT: Branch when Z=1; target is title_done.
; WHY: Choose the path that continues or completes copy the screen-code title until its zero
; terminator.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    beq title_done
; WHAT: Copy A to SCREEN+40.
; WHY: Put title on second screen row.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta SCREEN+40,x         ; Put title on second screen row
; WHAT: Increment X modulo 256.
; WHY: Advance the counter, position or offset used to copy the screen-code title until its zero
; terminator.
; HOW: Implied/accumulator form; no separate memory operand. Flags updated: N Z.
    inx
; WHAT: Branch when Z=0; target is title_loop.
; WHY: Choose the path that continues or completes copy the screen-code title until its zero
; terminator.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne title_loop
; WHAT: Define address label title_done.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
title_done:

    ; Tell VIC-II where to find our ball shape.
    ; $3000 / 64 = $c0, so every sprite uses pointer $c0.
; WHAT: Load X from $00 (literal value).
; WHY: Set the literal value needed to perform this step.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    ldx #$00
; WHAT: Define address label pointer_loop.
; WHY: Name the entry or data location used to give four hardware channels the shared ball
; shape.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
pointer_loop:
; WHAT: Load A from $c0 (literal value).
; WHY: Prepare the value for sprite-pointer table base.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #$c0
; WHAT: Copy A to sprite-pointer table base.
; WHY: Update sprite-pointer table base while we give four hardware channels the shared ball
; shape.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta SPR_PTR,x
; WHAT: Increment X modulo 256.
; WHY: Advance the counter, position or offset used to give four hardware channels the shared
; ball shape.
; HOW: Implied/accumulator form; no separate memory operand. Flags updated: N Z.
    inx
; WHAT: Compare X with #$04 without changing that register.
; WHY: Set the condition for the following branch in pointer_loop.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cpx #$04
; WHAT: Branch when Z=0; target is pointer_loop.
; WHY: Choose the path that continues or completes give four hardware channels the shared ball
; shape.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne pointer_loop

; WHAT: Load A from %00001111 (literal value).
; WHY: Prepare the value for sprite-enable mask.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #%00001111
; WHAT: Copy A to sprite-enable mask.
; WHY: Enable hardware sprites 0,1,2,3.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.  Bit n enables hardware sprite channel n when it is 1.
    sta SPR_ENABLE          ; Enable hardware sprites 0,1,2,3
; WHAT: Load A from $00 (literal value).
; WHY: Prepare the value for sprite X-expansion mask.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #$00
; WHAT: Copy A to sprite X-expansion mask.
; WHY: Normal sprite width (no X expansion).
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d01d               ; Normal sprite width (no X expansion)
; WHAT: Copy A to sprite Y-expansion mask.
; WHY: Normal sprite height (no Y expansion).
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d017               ; Normal sprite height (no Y expansion)
; WHAT: Copy A to sprite priority mask.
; WHY: Sprites in front of background.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d01b               ; Sprites in front of background
; WHAT: Copy A to sprite multicolour mask.
; WHY: Single-colour sprites.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d01c               ; Single-colour sprites

    ; Use 12 independent phase values so the balls swirl differently.
; WHAT: Load X from $00 (literal value).
; WHY: Set the literal value needed to give four hardware channels the shared ball shape.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    ldx #$00
; WHAT: Define address label initial_phases.
; WHY: Name the entry or data location used to give each logical ball a different starting
; phase.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
initial_phases:
; WHAT: A = X.
; WHY: Bring an index into arithmetic/logic register A.
; HOW: Bring an index into arithmetic/logic register A. Among status flags, only N Z change.
    txa
; WHAT: Shift left; old bit 7 enters C; bit 0 becomes 0.
; WHY: Scale a value or form a register/table offset for give each logical ball a different
; starting phase.
; HOW: Implied/accumulator form; no separate memory operand. Flags updated: N Z C.  Unsigned
; multiply by two modulo 256.
    asl
; WHAT: Shift left; old bit 7 enters C; bit 0 becomes 0.
; WHY: Scale a value or form a register/table offset for give each logical ball a different
; starting phase.
; HOW: Implied/accumulator form; no separate memory operand. Flags updated: N Z C.  Unsigned
; multiply by two modulo 256.
    asl
; WHAT: Shift left; old bit 7 enters C; bit 0 becomes 0.
; WHY: Scale a value or form a register/table offset for give each logical ball a different
; starting phase.
; HOW: Implied/accumulator form; no separate memory operand. Flags updated: N Z C.  Unsigned
; multiply by two modulo 256.
    asl
; WHAT: Shift left; old bit 7 enters C; bit 0 becomes 0.
; WHY: Scale a value or form a register/table offset for give each logical ball a different
; starting phase.
; HOW: Implied/accumulator form; no separate memory operand. Flags updated: N Z C.  Unsigned
; multiply by two modulo 256.
    asl
; WHAT: C = 0.
; WHY: Start an independent addition without an incoming carry.
; HOW: Start an independent addition without an incoming carry. Among status flags, only C
; changes.
    clc
; WHAT: A = A + #$09 + C.
; WHY: Calculate the next coordinate, phase or high-byte adjustment in initial_phases.
; HOW: Immediate operand: the value is encoded in the instruction. Updates N,V,Z,C in binary
; mode. Preserve low-byte carry for a following high-byte addition.
    adc #$09
; WHAT: Copy A to per-ball wave-table phases.
; WHY: Update per-ball wave-table phases while we give each logical ball a different starting
; phase.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta phase,x
; WHAT: Increment X modulo 256.
; WHY: Advance the counter, position or offset used to give each logical ball a different
; starting phase.
; HOW: Implied/accumulator form; no separate memory operand. Flags updated: N Z.
    inx
; WHAT: Compare X with #12 without changing that register.
; WHY: Set the condition for the following branch in initial_phases.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cpx #12
; WHAT: Branch when Z=0; target is initial_phases.
; WHY: Choose the path that continues or completes give each logical ball a different starting
; phase.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne initial_phases

    ; Turn off CIA interrupts (we use a VIC raster interrupt).
; WHAT: Load A from $7f (literal value).
; WHY: Prepare the value for CIA1 interrupt control/status.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #$7f
; WHAT: Copy A to CIA1 interrupt control/status.
; WHY: Update CIA1 interrupt control/status while we give each logical ball a different starting
; phase.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged. With bit 7 clear, each written 1 disables that interrupt source; bit 7 set
; enables selected sources.
    sta $dc0d
; WHAT: Copy A to CIA2 interrupt control/status.
; WHY: Update CIA2 interrupt control/status while we give each logical ball a different starting
; phase.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged. With bit 7 clear, each written 1 disables that interrupt source; bit 7 set
; enables selected sources.
    sta $dd0d
; WHAT: Load A from CIA1 interrupt control/status.
; WHY: Clear any pending CIA interrupt.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.  Reading this CIA register clears its pending interrupt flags.
    lda $dc0d               ; Clear any pending CIA interrupt
; WHAT: Load A from CIA2 interrupt control/status.
; WHY: Fetch CIA2 interrupt control/status while we give each logical ball a different starting
; phase.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.  Reading this CIA register clears its pending interrupt flags.
    lda $dd0d

    ; $0314/$0315 is the KERNAL RAM IRQ vector.
; WHAT: Load A from <irq (literal value).
; WHY: Prepare the value for KERNAL IRQ vector low byte.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #<irq
; WHAT: Copy A to KERNAL IRQ vector low byte.
; WHY: Update KERNAL IRQ vector low byte while we give each logical ball a different starting
; phase.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $0314
; WHAT: Load A from >irq (literal value).
; WHY: Prepare the value for KERNAL IRQ vector high byte.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #>irq
; WHAT: Copy A to KERNAL IRQ vector high byte.
; WHY: Update KERNAL IRQ vector high byte while we give each logical ball a different starting
; phase.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $0315

; WHAT: Load A from $1b (literal value).
; WHY: Prepare the value for vertical/control register with mixed raster read/write bit.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #$1b
; WHAT: Copy A to vertical/control register with mixed raster read/write bit.
; WHY: Standard screen, raster high bit = 0.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.  Bits 0-2 select fine Y; bit 7 written selects raster compare high, unlike its
; read meaning.
    sta $d011               ; Standard screen, raster high bit = 0
; WHAT: Load A from $01 (literal value).
; WHY: Prepare the value for VIC interrupt acknowledge register.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #$01
; WHAT: Copy A to VIC interrupt acknowledge register.
; WHY: Acknowledge pending raster interrupt.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged. Writing a 1 acknowledges the corresponding pending VIC flag, not an ordinary
; RAM assignment.
    sta IRQ_STATUS          ; Acknowledge pending raster interrupt
; WHAT: Copy A to VIC interrupt enable register.
; WHY: Enable raster interrupts.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta IRQ_ENABLE          ; Enable raster interrupts
; WHAT: Load A from 45 (literal value).
; WHY: Prepare the value for raster compare low byte.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #45
; WHAT: Copy A to raster compare low byte.
; WHY: First sprite group starts at line 45.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.  A write programs raster compare low; it does not move the video beam.
    sta RASTER              ; First sprite group starts at line 45
; WHAT: Load A from 0 (literal value).
; WHY: Prepare the value for four-stage interrupt state.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #0
; WHAT: Copy A to four-stage interrupt state.
; WHY: 0 = first of three groups.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta irq_stage           ; 0 = first of three groups
; WHAT: I = 0.
; WHY: Allow interrupts to happen.
; HOW: Permit maskable IRQ recognition; does not clear interrupt sources. Among status flags,
; only I change.
    cli                     ; Allow interrupts to happen

; WHAT: Define address label main_loop.
; WHY: Name the entry or data location used to repeat the foreground loop.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
main_loop:
; WHAT: Continue execution at main_loop.
; WHY: All the animation happens in the IRQ.
; HOW: Absolute JMP changes PC without stacking a return address; flags are unchanged.
    jmp main_loop           ; All the animation happens in the IRQ

; --------------------------------------------------------------
; IRQ: called when the video beam reaches our chosen raster line.
; The KERNAL already saved A, X and Y before calling this vector.
; Jump to $ea81 to restore them and return from the interrupt.
; --------------------------------------------------------------
; WHAT: Define address label irq.
; WHY: Name the entry or data location used to acknowledge and dispatch the scheduled raster
; event.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
irq:
; WHAT: Load A from $01 (literal value).
; WHY: Prepare the value for VIC interrupt acknowledge register.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #$01
; WHAT: Copy A to VIC interrupt acknowledge register.
; WHY: Tell VIC-II we handled its interrupt.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged. Writing a 1 acknowledges the corresponding pending VIC flag, not an ordinary
; RAM assignment.
    sta IRQ_STATUS          ; Tell VIC-II we handled its interrupt

; WHAT: Load A from four-stage interrupt state.
; WHY: Fetch four-stage interrupt state while we acknowledge and dispatch the scheduled raster
; event.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda irq_stage
; WHAT: Branch when Z=1; target is show_group_zero.
; WHY: Choose the path that continues or completes acknowledge and dispatch the scheduled raster
; event.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    beq show_group_zero
; WHAT: Compare A with #$01 without changing that register.
; WHY: Set the condition for the following branch in irq.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cmp #$01
; WHAT: Branch when Z=1; target is show_group_one.
; WHY: Choose the path that continues or completes acknowledge and dispatch the scheduled raster
; event.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    beq show_group_one
; WHAT: Compare A with #$02 without changing that register.
; WHY: Set the condition for the following branch in irq.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cmp #$02
; WHAT: Branch when Z=1; target is show_group_two.
; WHY: Choose the path that continues or completes acknowledge and dispatch the scheduled raster
; event.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    beq show_group_two
; WHAT: Continue execution at frame_update.
; WHY: Repeat the main loop or join the named control path.
; HOW: Absolute JMP changes PC without stacking a return address; flags are unchanged.
    jmp frame_update

; WHAT: Define address label show_group_zero.
; WHY: Name the entry or data location used to present balls 0-3 in the top band.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
show_group_zero:
; WHAT: Load X from 0 (literal value).
; WHY: Logical balls 0..3 -> sprites 0..3.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    ldx #0                  ; Logical balls 0..3 -> sprites 0..3
; WHAT: Call draw_group.
; WHY: Delegate work to translate four logical balls into hardware-channel state.
; HOW: Push the address of the last JSR byte on the page-1 stack, then load the target into PC.
; RTS pulls it and adds one.
    jsr draw_group
; WHAT: Load A from 115 (literal value).
; WHY: Beam will be below the first group.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #115                ; Beam will be below the first group
; WHAT: Copy A to raster compare low byte.
; WHY: Update raster compare low byte while we present balls 0-3 in the top band.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.  A write programs raster compare low; it does not move the video beam.
    sta RASTER
; WHAT: Load A from 1 (literal value).
; WHY: Prepare the value for four-stage interrupt state.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #1
; WHAT: Copy A to four-stage interrupt state.
; WHY: Update four-stage interrupt state while we present balls 0-3 in the top band.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta irq_stage
; WHAT: Continue execution at $ea81.
; WHY: Use the standard KERNAL IRQ restore-and-RTI path for registers already saved by ROM.
; HOW: Absolute JMP changes PC without stacking a return address; flags are unchanged. This is a
; tail transfer, not JSR; an unmatched extra push would corrupt the exit.
    jmp $ea81               ; KERNAL's IRQ exit routine

; WHAT: Define address label show_group_one.
; WHY: Name the entry or data location used to reuse channels for balls 4-7.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
show_group_one:
; WHAT: Load X from 4 (literal value).
; WHY: Logical balls 4..7 -> SAME sprites.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    ldx #4                  ; Logical balls 4..7 -> SAME sprites
; WHAT: Call draw_group.
; WHY: Delegate work to translate four logical balls into hardware-channel state.
; HOW: Push the address of the last JSR byte on the page-1 stack, then load the target into PC.
; RTS pulls it and adds one.
    jsr draw_group
; WHAT: Load A from 181 (literal value).
; WHY: Prepare the value for raster compare low byte.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #181
; WHAT: Copy A to raster compare low byte.
; WHY: Update raster compare low byte while we reuse channels for balls 4-7.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.  A write programs raster compare low; it does not move the video beam.
    sta RASTER
; WHAT: Load A from 2 (literal value).
; WHY: Prepare the value for four-stage interrupt state.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #2
; WHAT: Copy A to four-stage interrupt state.
; WHY: Update four-stage interrupt state while we reuse channels for balls 4-7.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta irq_stage
; WHAT: Continue execution at $ea81.
; WHY: Use the standard KERNAL IRQ restore-and-RTI path for registers already saved by ROM.
; HOW: Absolute JMP changes PC without stacking a return address; flags are unchanged. This is a
; tail transfer, not JSR; an unmatched extra push would corrupt the exit.
    jmp $ea81

; WHAT: Define address label show_group_two.
; WHY: Name the entry or data location used to reuse channels for balls 8-11.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
show_group_two:
; WHAT: Load X from 8 (literal value).
; WHY: Logical balls 8..11 -> SAME sprites.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    ldx #8                  ; Logical balls 8..11 -> SAME sprites
; WHAT: Call draw_group.
; WHY: Delegate work to translate four logical balls into hardware-channel state.
; HOW: Push the address of the last JSR byte on the page-1 stack, then load the target into PC.
; RTS pulls it and adds one.
    jsr draw_group
; WHAT: Load A from 250 (literal value).
; WHY: Prepare the value for raster compare low byte.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #250
; WHAT: Copy A to raster compare low byte.
; WHY: Update raster compare low byte while we reuse channels for balls 8-11.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.  A write programs raster compare low; it does not move the video beam.
    sta RASTER
; WHAT: Load A from 3 (literal value).
; WHY: Prepare the value for four-stage interrupt state.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #3
; WHAT: Copy A to four-stage interrupt state.
; WHY: Update four-stage interrupt state while we reuse channels for balls 8-11.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta irq_stage
; WHAT: Continue execution at $ea81.
; WHY: Use the standard KERNAL IRQ restore-and-RTI path for registers already saved by ROM.
; HOW: Absolute JMP changes PC without stacking a return address; flags are unchanged. This is a
; tail transfer, not JSR; an unmatched extra push would corrupt the exit.
    jmp $ea81

; WHAT: Define address label frame_update.
; WHY: Name the entry or data location used to move every ball once and schedule the next frame.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
frame_update:
; WHAT: Call move_balls.
; WHY: Move all 12 balls once per frame.
; HOW: Push the address of the last JSR byte on the page-1 stack, then load the target into PC.
; RTS pulls it and adds one.
    jsr move_balls          ; Move all 12 balls once per frame
; WHAT: Load A from 45 (literal value).
; WHY: Schedule first group next frame.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #45                 ; Schedule first group next frame
; WHAT: Copy A to raster compare low byte.
; WHY: Update raster compare low byte while we move every ball once and schedule the next frame.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.  A write programs raster compare low; it does not move the video beam.
    sta RASTER
; WHAT: Load A from 0 (literal value).
; WHY: Prepare the value for four-stage interrupt state.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #0
; WHAT: Copy A to four-stage interrupt state.
; WHY: Update four-stage interrupt state while we move every ball once and schedule the next
; frame.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta irq_stage
; WHAT: Continue execution at $ea81.
; WHY: Use the standard KERNAL IRQ restore-and-RTI path for registers already saved by ROM.
; HOW: Absolute JMP changes PC without stacking a return address; flags are unchanged. This is a
; tail transfer, not JSR; an unmatched extra push would corrupt the exit.
    jmp $ea81

; --------------------------------------------------------------
; draw_group
; Input X = 0, 4, or 8 (first logical ball in this group).
; Y indexes the four physical hardware sprites.
;
; X display position = base_x + wave[phase] - 12.
; Y display position = group_y + wave[phase+64]/2.
; This produces a little circular/swirling movement while the
; underlying base_x moves left and right, bouncing at the edges.
; --------------------------------------------------------------
; WHAT: Define address label draw_group.
; WHY: Name the entry or data location used to translate four logical balls into hardware-
; channel state.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
draw_group:
; WHAT: Load A from 0 (literal value).
; WHY: Prepare the value for accumulated X-high-bit mask.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #0
; WHAT: Copy A to accumulated X-high-bit mask.
; WHY: Build $d010 for these four sprites.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta msb_bits            ; Build $d010 for these four sprites
; WHAT: Load Y from 0 (literal value).
; WHY: Set the literal value needed to translate four logical balls into hardware-channel state.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    ldy #0
; WHAT: Define address label draw_one.
; WHY: Name the entry or data location used to calculate one logical ball and emit its hardware
; settings.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
draw_one:
; WHAT: Copy X to saved logical ball number.
; WHY: Update saved logical ball number while we calculate one logical ball and emit its
; hardware settings.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    stx logical_index
; WHAT: Copy Y to saved hardware channel number.
; WHY: Update saved hardware channel number while we calculate one logical ball and emit its
; hardware settings.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sty sprite_index

    ; Compute wobbly X, including the 9th bit for X >= 256.
; WHAT: Load A from per-ball wave-table phases.
; WHY: Fetch per-ball wave-table phases while we calculate one logical ball and emit its
; hardware settings.
; HOW: Indexed address: add the index register to the named base address. Flags updated: N Z.
    lda phase,x
; WHAT: X = A.
; WHY: Transfer a copy, often to index a lookup table.
; HOW: Transfer a copy, often to index a lookup table. Among status flags, only N Z change.
    tax
; WHAT: Load A from 256-entry wave table.
; WHY: 0..24.
; HOW: Indexed address: add the index register to the named base address. Flags updated: N Z.
    lda wave,x              ; 0..24
; WHAT: C = 1.
; WHY: Start independent SBC with no initial borrow.
; HOW: Start independent SBC with no initial borrow. Among status flags, only C change.
    sec
; WHAT: A = A - #12 - (1-C).
; WHY: -12..+12 (carry represents borrow).
; HOW: Immediate operand: the value is encoded in the instruction. Updates N,V,Z,C in binary
; mode. SEC starts a subtraction without an incoming borrow.
    sbc #12                 ; -12..+12 (carry represents borrow)
; WHAT: Copy A to signed horizontal wave offset.
; WHY: Signed byte offset.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta wobble              ; Signed byte offset

; WHAT: Load X from saved logical ball number.
; WHY: Fetch saved logical ball number while we calculate one logical ball and emit its hardware
; settings.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    ldx logical_index
; WHAT: Load A from per-ball low base-X bytes.
; WHY: Fetch per-ball low base-X bytes while we calculate one logical ball and emit its hardware
; settings.
; HOW: Indexed address: add the index register to the named base address. Flags updated: N Z.
    lda base_x_lo,x
; WHAT: C = 0.
; WHY: Start an independent addition without an incoming carry.
; HOW: Start an independent addition without an incoming carry. Among status flags, only C
; changes.
    clc
; WHAT: A = A + wobble + C.
; WHY: Calculate the next coordinate, phase or high-byte adjustment in draw_one.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Updates
; N,V,Z,C in binary mode. Preserve low-byte carry for a following high-byte addition.
    adc wobble
; WHAT: Copy A to temporary low X byte.
; WHY: Update temporary low X byte while we calculate one logical ball and emit its hardware
; settings.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta temp_x_lo
; WHAT: Load A from per-ball high base-X bytes.
; WHY: Fetch per-ball high base-X bytes while we calculate one logical ball and emit its
; hardware settings.
; HOW: Indexed address: add the index register to the named base address. Flags updated: N Z.
    lda base_x_hi,x
; WHAT: Load Y from signed horizontal wave offset.
; WHY: Fetch signed horizontal wave offset while we calculate one logical ball and emit its
; hardware settings.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    ldy wobble
; WHAT: Branch when N=1; target is negative_wobble.
; WHY: Choose the path that continues or completes calculate one logical ball and emit its
; hardware settings.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bmi negative_wobble
; WHAT: A = A + #0 + C.
; WHY: Positive offset: add carry to high byte.
; HOW: Immediate operand: the value is encoded in the instruction. Updates N,V,Z,C in binary
; mode. Preserve low-byte carry for a following high-byte addition.
    adc #0                  ; Positive offset: add carry to high byte
; WHAT: Continue execution at x_high_done.
; WHY: Repeat the main loop or join the named control path.
; HOW: Absolute JMP changes PC without stacking a return address; flags are unchanged.
    jmp x_high_done
; WHAT: Define address label negative_wobble.
; WHY: Name the entry or data location used to sign-extend a negative 8-bit wobble into the high
; X byte.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
negative_wobble:
; WHAT: A = A + #$ff + C.
; WHY: Negative offset: high byte - 1 + carry.
; HOW: Immediate operand: the value is encoded in the instruction. Updates N,V,Z,C in binary
; mode. Preserve low-byte carry for a following high-byte addition.
    adc #$ff                ; Negative offset: high byte - 1 + carry
; WHAT: Define address label x_high_done.
; WHY: Name the entry or data location used to finish the 16-bit X result and write its low
; byte.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
x_high_done:
; WHAT: Copy A to temporary high X byte.
; WHY: Update temporary high X byte while we finish the 16-bit X result and write its low byte.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta temp_x_hi

    ; $d000, $d002, $d004, $d006 hold the X coordinates.
; WHAT: Load Y from saved hardware channel number.
; WHY: Fetch saved hardware channel number while we finish the 16-bit X result and write its low
; byte.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    ldy sprite_index
; WHAT: A = Y.
; WHY: Bring an index into A for arithmetic or shifting.
; HOW: Bring an index into A for arithmetic or shifting. Among status flags, only N Z change.
    tya
; WHAT: Shift left; old bit 7 enters C; bit 0 becomes 0.
; WHY: Scale a value or form a register/table offset for finish the 16-bit X result and write
; its low byte.
; HOW: Implied/accumulator form; no separate memory operand. Flags updated: N Z C.  Unsigned
; multiply by two modulo 256.
    asl
; WHAT: Y = A.
; WHY: Transfer a copy into the Y index.
; HOW: Transfer a copy into the Y index. Among status flags, only N Z change.
    tay
; WHAT: Load A from temporary low X byte.
; WHY: Fetch temporary low X byte while we finish the 16-bit X result and write its low byte.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda temp_x_lo
; WHAT: Copy A to hardware sprite X-register base.
; WHY: Update hardware sprite X-register base while we finish the 16-bit X result and write its
; low byte.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta SPR_X,y

    ; Each sprite has one bit in $d010 for its 9th X bit.
; WHAT: Load A from temporary high X byte.
; WHY: Fetch temporary high X byte while we finish the 16-bit X result and write its low byte.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda temp_x_hi
; WHAT: Branch when Z=1; target is no_high_x.
; WHY: Choose the path that continues or completes finish the 16-bit X result and write its low
; byte.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    beq no_high_x
; WHAT: Load Y from saved hardware channel number.
; WHY: Fetch saved hardware channel number while we finish the 16-bit X result and write its low
; byte.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    ldy sprite_index
; WHAT: Load A from accumulated X-high-bit mask.
; WHY: Fetch accumulated X-high-bit mask while we finish the 16-bit X result and write its low
; byte.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda msb_bits
; WHAT: A = A OR bit_masks,y.
; WHY: Select, combine or constrain the bits used to finish the 16-bit X result and write its
; low byte.
; HOW: Indexed address: add the index register to the named base address. Flags updated: N Z.
    ora bit_masks,y
; WHAT: Copy A to accumulated X-high-bit mask.
; WHY: Update accumulated X-high-bit mask while we finish the 16-bit X result and write its low
; byte.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta msb_bits
; WHAT: Define address label no_high_x.
; WHY: Name the entry or data location used to calculate vertical swirl after collecting the X
; high bit.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
no_high_x:

    ; Compute swirling Y position from a second wave phase.
; WHAT: Load X from saved logical ball number.
; WHY: Fetch saved logical ball number while we calculate vertical swirl after collecting the X
; high bit.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    ldx logical_index
; WHAT: Load A from per-ball wave-table phases.
; WHY: Fetch per-ball wave-table phases while we calculate vertical swirl after collecting the X
; high bit.
; HOW: Indexed address: add the index register to the named base address. Flags updated: N Z.
    lda phase,x
; WHAT: C = 0.
; WHY: Start an independent addition without an incoming carry.
; HOW: Start an independent addition without an incoming carry. Among status flags, only C
; changes.
    clc
; WHAT: A = A + #64 + C.
; WHY: Quarter-cycle shift gives circular motion.
; HOW: Immediate operand: the value is encoded in the instruction. Updates N,V,Z,C in binary
; mode. Preserve low-byte carry for a following high-byte addition.
    adc #64                 ; Quarter-cycle shift gives circular motion
; WHAT: X = A.
; WHY: Transfer a copy, often to index a lookup table.
; HOW: Transfer a copy, often to index a lookup table. Among status flags, only N Z change.
    tax
; WHAT: Load A from 256-entry wave table.
; WHY: Fetch 256-entry wave table while we calculate vertical swirl after collecting the X high
; bit.
; HOW: Indexed address: add the index register to the named base address. Flags updated: N Z.
    lda wave,x
; WHAT: Shift right; old bit 0 enters C; bit 7 becomes 0.
; WHY: 0..12 pixels of vertical movement.
; HOW: Implied/accumulator form; no separate memory operand. Flags updated: N Z C.  Unsigned
; divide by two; N always clears.
    lsr                     ; 0..12 pixels of vertical movement
; WHAT: Load X from saved logical ball number.
; WHY: Fetch saved logical ball number while we calculate vertical swirl after collecting the X
; high bit.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    ldx logical_index
; WHAT: C = 0.
; WHY: Start an independent addition without an incoming carry.
; HOW: Start an independent addition without an incoming carry. Among status flags, only C
; changes.
    clc
; WHAT: A = A + group_y,x + C.
; WHY: Calculate the next coordinate, phase or high-byte adjustment in no_high_x.
; HOW: Indexed address: add the index register to the named base address. Updates N,V,Z,C in
; binary mode. Preserve low-byte carry for a following high-byte addition.
    adc group_y,x
; WHAT: Copy A to temporary Y coordinate.
; WHY: Update temporary Y coordinate while we calculate vertical swirl after collecting the X
; high bit.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta temp_y

    ; $d001, $d003, $d005, $d007 hold Y coordinates.
; WHAT: Load Y from saved hardware channel number.
; WHY: Fetch saved hardware channel number while we calculate vertical swirl after collecting
; the X high bit.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    ldy sprite_index
; WHAT: A = Y.
; WHY: Bring an index into A for arithmetic or shifting.
; HOW: Bring an index into A for arithmetic or shifting. Among status flags, only N Z change.
    tya
; WHAT: Shift left; old bit 7 enters C; bit 0 becomes 0.
; WHY: Scale a value or form a register/table offset for calculate vertical swirl after
; collecting the X high bit.
; HOW: Implied/accumulator form; no separate memory operand. Flags updated: N Z C.  Unsigned
; multiply by two modulo 256.
    asl
; WHAT: Y = A.
; WHY: Transfer a copy into the Y index.
; HOW: Transfer a copy into the Y index. Among status flags, only N Z change.
    tay
; WHAT: Load A from temporary Y coordinate.
; WHY: Fetch temporary Y coordinate while we calculate vertical swirl after collecting the X
; high bit.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda temp_y
; WHAT: Copy A to hardware sprite Y-register base.
; WHY: Update hardware sprite Y-register base while we calculate vertical swirl after collecting
; the X high bit.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta SPR_Y,y

    ; Give each ball its own colour.
; WHAT: Load X from saved logical ball number.
; WHY: Fetch saved logical ball number while we calculate vertical swirl after collecting the X
; high bit.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    ldx logical_index
; WHAT: Load A from per-ball colour values.
; WHY: Fetch per-ball colour values while we calculate vertical swirl after collecting the X
; high bit.
; HOW: Indexed address: add the index register to the named base address. Flags updated: N Z.
    lda ball_colours,x
; WHAT: Load Y from saved hardware channel number.
; WHY: Fetch saved hardware channel number while we calculate vertical swirl after collecting
; the X high bit.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    ldy sprite_index
; WHAT: Copy A to sprite 0 colour / colour-register base.
; WHY: Sprite colour registers.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta $d027,y             ; Sprite colour registers

; WHAT: Increment saved hardware channel number modulo 256.
; WHY: Advance the counter, position or offset used to calculate vertical swirl after collecting
; the X high bit.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z. NMOS memory read-modify-write writes the old byte before the new one; avoid
; applying this blindly to I/O.
    inc sprite_index
; WHAT: Load Y from saved hardware channel number.
; WHY: Fetch saved hardware channel number while we calculate vertical swirl after collecting
; the X high bit.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    ldy sprite_index
; WHAT: Load X from saved logical ball number.
; WHY: Fetch saved logical ball number while we calculate vertical swirl after collecting the X
; high bit.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    ldx logical_index
; WHAT: Increment X modulo 256.
; WHY: Advance the counter, position or offset used to calculate vertical swirl after collecting
; the X high bit.
; HOW: Implied/accumulator form; no separate memory operand. Flags updated: N Z.
    inx
; WHAT: Compare Y with #4 without changing that register.
; WHY: Set the condition for the following branch in no_high_x.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cpy #4
; WHAT: Branch when Z=1; target is group_complete.
; WHY: Short branch stays within 6502 range.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    beq group_complete      ; Short branch stays within 6502 range
; WHAT: Continue execution at draw_one.
; WHY: JMP can reach the longer loop body.
; HOW: Absolute JMP changes PC without stacking a return address; flags are unchanged.
    jmp draw_one            ; JMP can reach the longer loop body
; WHAT: Define address label group_complete.
; WHY: Name the entry or data location used to apply the complete four-channel high-X mask.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
group_complete:
; WHAT: Load A from accumulated X-high-bit mask.
; WHY: Fetch accumulated X-high-bit mask while we apply the complete four-channel high-X mask.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda msb_bits
; WHAT: Copy A to collected ninth X-coordinate bits.
; WHY: Apply all four X high bits at once.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.  Bit n supplies X bit 8 for hardware sprite n.
    sta SPR_X_MSB           ; Apply all four X high bits at once
; WHAT: Return from the current subroutine.
; WHY: Return control to the caller after this routine has completed its work.
; HOW: Pull the JSR return address, add one, and continue there. The stack must still match the
; call; flags are unchanged.
    rts

; --------------------------------------------------------------
; move_balls: change each ball's phase and its horizontal base X.
; direction=0 means right; direction=1 means left.
; Every ball travels between X=48 and X=284, so the swirl cannot
; carry it off the left/right edge of the visible picture.
; --------------------------------------------------------------
; WHAT: Define address label move_balls.
; WHY: Name the entry or data location used to advance each ball phase and horizontal base
; position.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
move_balls:
; WHAT: Load X from 0 (literal value).
; WHY: Set the literal value needed to advance each ball phase and horizontal base position.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    ldx #0
; WHAT: Define address label move_next.
; WHY: Name the entry or data location used to process the next ball record.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
move_next:
; WHAT: Load A from per-ball wave-table phases.
; WHY: Fetch per-ball wave-table phases while we process the next ball record.
; HOW: Indexed address: add the index register to the named base address. Flags updated: N Z.
    lda phase,x
; WHAT: C = 0.
; WHY: Start an independent addition without an incoming carry.
; HOW: Start an independent addition without an incoming carry. Among status flags, only C
; changes.
    clc
; WHAT: A = A + phase_speed,x + C.
; WHY: Calculate the next coordinate, phase or high-byte adjustment in move_next.
; HOW: Indexed address: add the index register to the named base address. Updates N,V,Z,C in
; binary mode. Preserve low-byte carry for a following high-byte addition.
    adc phase_speed,x
; WHAT: Copy A to per-ball wave-table phases.
; WHY: Update per-ball wave-table phases while we process the next ball record.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta phase,x

; WHAT: Load A from per-ball direction flags.
; WHY: Fetch per-ball direction flags while we process the next ball record.
; HOW: Indexed address: add the index register to the named base address. Flags updated: N Z.
    lda direction,x
; WHAT: Branch when Z=0; target is move_left.
; WHY: Choose the path that continues or completes process the next ball record.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne move_left

; WHAT: Define address label move_right.
; WHY: Name the entry or data location used to add speed and reverse at the right threshold.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
move_right:
; WHAT: C = 0.
; WHY: Start an independent addition without an incoming carry.
; HOW: Start an independent addition without an incoming carry. Among status flags, only C
; changes.
    clc
; WHAT: Load A from per-ball low base-X bytes.
; WHY: Fetch per-ball low base-X bytes while we add speed and reverse at the right threshold.
; HOW: Indexed address: add the index register to the named base address. Flags updated: N Z.
    lda base_x_lo,x
; WHAT: A = A + speed,x + C.
; WHY: Calculate the next coordinate, phase or high-byte adjustment in move_right.
; HOW: Indexed address: add the index register to the named base address. Updates N,V,Z,C in
; binary mode. Preserve low-byte carry for a following high-byte addition.
    adc speed,x
; WHAT: Copy A to per-ball low base-X bytes.
; WHY: Update per-ball low base-X bytes while we add speed and reverse at the right threshold.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta base_x_lo,x
; WHAT: Load A from per-ball high base-X bytes.
; WHY: Fetch per-ball high base-X bytes while we add speed and reverse at the right threshold.
; HOW: Indexed address: add the index register to the named base address. Flags updated: N Z.
    lda base_x_hi,x
; WHAT: A = A + #0 + C.
; WHY: Calculate the next coordinate, phase or high-byte adjustment in move_right.
; HOW: Immediate operand: the value is encoded in the instruction. Updates N,V,Z,C in binary
; mode. Preserve low-byte carry for a following high-byte addition.
    adc #0
; WHAT: Copy A to per-ball high base-X bytes.
; WHY: Update per-ball high base-X bytes while we add speed and reverse at the right threshold.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta base_x_hi,x

    ; Bounce at X >= 284 ($011c).
; WHAT: Compare A with #$01 without changing that register.
; WHY: Set the condition for the following branch in move_right.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cmp #$01
; WHAT: Branch when C=0; target is move_done.
; WHY: Choose the path that continues or completes add speed and reverse at the right threshold.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bcc move_done
; WHAT: Load A from per-ball low base-X bytes.
; WHY: Fetch per-ball low base-X bytes while we add speed and reverse at the right threshold.
; HOW: Indexed address: add the index register to the named base address. Flags updated: N Z.
    lda base_x_lo,x
; WHAT: Compare A with #$1c without changing that register.
; WHY: Set the condition for the following branch in move_right.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cmp #$1c
; WHAT: Branch when C=0; target is move_done.
; WHY: Choose the path that continues or completes add speed and reverse at the right threshold.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bcc move_done
; WHAT: Load A from 1 (literal value).
; WHY: Prepare the value for per-ball direction flags.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #1
; WHAT: Copy A to per-ball direction flags.
; WHY: Update per-ball direction flags while we add speed and reverse at the right threshold.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta direction,x
; WHAT: Continue execution at move_done.
; WHY: Repeat the main loop or join the named control path.
; HOW: Absolute JMP changes PC without stacking a return address; flags are unchanged.
    jmp move_done

; WHAT: Define address label move_left.
; WHY: Name the entry or data location used to subtract speed and reverse at the left threshold.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
move_left:
; WHAT: C = 1.
; WHY: Start independent SBC with no initial borrow.
; HOW: Start independent SBC with no initial borrow. Among status flags, only C change.
    sec
; WHAT: Load A from per-ball low base-X bytes.
; WHY: Fetch per-ball low base-X bytes while we subtract speed and reverse at the left
; threshold.
; HOW: Indexed address: add the index register to the named base address. Flags updated: N Z.
    lda base_x_lo,x
; WHAT: A = A - speed,x - (1-C).
; WHY: Calculate the next coordinate, phase or high-byte adjustment in move_left.
; HOW: Indexed address: add the index register to the named base address. Updates N,V,Z,C in
; binary mode. SEC starts a subtraction without an incoming borrow.
    sbc speed,x
; WHAT: Copy A to per-ball low base-X bytes.
; WHY: Update per-ball low base-X bytes while we subtract speed and reverse at the left
; threshold.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta base_x_lo,x
; WHAT: Load A from per-ball high base-X bytes.
; WHY: Fetch per-ball high base-X bytes while we subtract speed and reverse at the left
; threshold.
; HOW: Indexed address: add the index register to the named base address. Flags updated: N Z.
    lda base_x_hi,x
; WHAT: A = A - #0 - (1-C).
; WHY: Calculate the next coordinate, phase or high-byte adjustment in move_left.
; HOW: Immediate operand: the value is encoded in the instruction. Updates N,V,Z,C in binary
; mode. SEC starts a subtraction without an incoming borrow.
    sbc #0
; WHAT: Copy A to per-ball high base-X bytes.
; WHY: Update per-ball high base-X bytes while we subtract speed and reverse at the left
; threshold.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta base_x_hi,x

    ; Bounce at X <= 48 ($0030).
; WHAT: Load A from per-ball high base-X bytes.
; WHY: Fetch per-ball high base-X bytes while we subtract speed and reverse at the left
; threshold.
; HOW: Indexed address: add the index register to the named base address. Flags updated: N Z.
    lda base_x_hi,x
; WHAT: Branch when Z=0; target is move_done.
; WHY: Choose the path that continues or completes subtract speed and reverse at the left
; threshold.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne move_done
; WHAT: Load A from per-ball low base-X bytes.
; WHY: Fetch per-ball low base-X bytes while we subtract speed and reverse at the left
; threshold.
; HOW: Indexed address: add the index register to the named base address. Flags updated: N Z.
    lda base_x_lo,x
; WHAT: Compare A with #$31 without changing that register.
; WHY: Set the condition for the following branch in move_left.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cmp #$31
; WHAT: Branch when C=1; target is move_done.
; WHY: Choose the path that continues or completes subtract speed and reverse at the left
; threshold.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bcs move_done
; WHAT: Load A from 0 (literal value).
; WHY: Prepare the value for per-ball direction flags.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #0
; WHAT: Copy A to per-ball direction flags.
; WHY: Update per-ball direction flags while we subtract speed and reverse at the left
; threshold.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta direction,x

; WHAT: Define address label move_done.
; WHY: Name the entry or data location used to advance to the next ball record.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
move_done:
; WHAT: Increment X modulo 256.
; WHY: Advance the counter, position or offset used to advance to the next ball record.
; HOW: Implied/accumulator form; no separate memory operand. Flags updated: N Z.
    inx
; WHAT: Compare X with #12 without changing that register.
; WHY: Set the condition for the following branch in move_done.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cpx #12
; WHAT: Branch when Z=0; target is move_next.
; WHY: Choose the path that continues or completes advance to the next ball record.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne move_next
; WHAT: Return from the current subroutine.
; WHY: Return control to the caller after this routine has completed its work.
; HOW: Pull the JSR return address, add one, and continue there. The stack must still match the
; call; flags are unchanged.
    rts

; --------------------------------------------------------------
; DATA TABLES. A table is just a sequence of bytes.
; Index X picks which logical ball's value to read.
; The first 4 balls occupy the upper band, next 4 the middle,
; and last 4 the lower band.
; --------------------------------------------------------------
; WHAT: Emit 1 literal byte.
; WHY: Initialise four-stage interrupt state; successive entries are adjacent bytes.
; HOW: The label irq_stage names this data address. These are stored data, not CPU instructions.
; Binary row bits run left to right from the high bit of each byte; table indices start at zero.
irq_stage:    !byte 0
; WHAT: Emit 1 literal byte.
; WHY: Initialise saved logical ball number; successive entries are adjacent bytes.
; HOW: The label logical_index names this data address. These are stored data, not CPU
; instructions. Binary row bits run left to right from the high bit of each byte; table indices
; start at zero.
logical_index: !byte 0
; WHAT: Emit 1 literal byte.
; WHY: Initialise saved hardware channel number; successive entries are adjacent bytes.
; HOW: The label sprite_index names this data address. These are stored data, not CPU
; instructions. Binary row bits run left to right from the high bit of each byte; table indices
; start at zero.
sprite_index: !byte 0
; WHAT: Emit 1 literal byte.
; WHY: Initialise accumulated X-high-bit mask; successive entries are adjacent bytes.
; HOW: The label msb_bits names this data address. These are stored data, not CPU instructions.
; Binary row bits run left to right from the high bit of each byte; table indices start at zero.
msb_bits:     !byte 0
; WHAT: Emit 1 literal byte.
; WHY: Initialise signed horizontal wave offset; successive entries are adjacent bytes.
; HOW: The label wobble names this data address. These are stored data, not CPU instructions.
; Binary row bits run left to right from the high bit of each byte; table indices start at zero.
wobble:       !byte 0
; WHAT: Emit 1 literal byte.
; WHY: Initialise temporary low X byte; successive entries are adjacent bytes.
; HOW: The label temp_x_lo names this data address. These are stored data, not CPU instructions.
; Binary row bits run left to right from the high bit of each byte; table indices start at zero.
temp_x_lo:    !byte 0
; WHAT: Emit 1 literal byte.
; WHY: Initialise temporary high X byte; successive entries are adjacent bytes.
; HOW: The label temp_x_hi names this data address. These are stored data, not CPU instructions.
; Binary row bits run left to right from the high bit of each byte; table indices start at zero.
temp_x_hi:    !byte 0
; WHAT: Emit 1 literal byte.
; WHY: Initialise temporary Y coordinate; successive entries are adjacent bytes.
; HOW: The label temp_y names this data address. These are stored data, not CPU instructions.
; Binary row bits run left to right from the high bit of each byte; table indices start at zero.
temp_y:       !byte 0

; WHAT: Emit 12 literal bytes.
; WHY: Initialise per-ball low base-X bytes; successive entries are adjacent bytes.
; HOW: The label base_x_lo names this data address. These are stored data, not CPU instructions.
; Binary row bits run left to right from the high bit of each byte; table indices start at zero.
base_x_lo:    !byte 48,105,165,225, 65,125,185,245, 48,110,175,240
; WHAT: Emit the stated count of repeated bytes.
; WHY: Allocate and initialise per-ball high base-X bytes or the sprite artwork.
; HOW: The label base_x_hi names this data address. ACME creates data during assembly; !fill
; 12,0 produces twelve zeros, while !fill 63,$ff produces 21 solid three-byte sprite rows.
base_x_hi:    !fill 12,0
; WHAT: Emit 12 literal bytes.
; WHY: Initialise per-ball direction flags; successive entries are adjacent bytes.
; HOW: The label direction names this data address. These are stored data, not CPU instructions.
; Binary row bits run left to right from the high bit of each byte; table indices start at zero.
direction:    !byte 0,1,0,1, 1,0,1,0, 0,1,0,1
; WHAT: Emit 12 literal bytes.
; WHY: Initialise per-ball horizontal step sizes; successive entries are adjacent bytes.
; HOW: The label speed names this data address. These are stored data, not CPU instructions.
; Binary row bits run left to right from the high bit of each byte; table indices start at zero.
speed:        !byte 1,2,1,2, 2,1,2,1, 1,2,2,1
; WHAT: Emit the stated count of repeated bytes.
; WHY: Allocate and initialise per-ball wave-table phases or the sprite artwork.
; HOW: The label phase names this data address. ACME creates data during assembly; !fill 12,0
; produces twelve zeros, while !fill 63,$ff produces 21 solid three-byte sprite rows.
phase:        !fill 12,0
; WHAT: Emit 12 literal bytes.
; WHY: Initialise per-ball phase increments; successive entries are adjacent bytes.
; HOW: The label phase_speed names this data address. These are stored data, not CPU
; instructions. Binary row bits run left to right from the high bit of each byte; table indices
; start at zero.
phase_speed:  !byte 2,3,4,3, 3,4,2,4, 4,2,3,2
; WHAT: Emit 12 literal bytes.
; WHY: Initialise per-ball vertical-band baselines; successive entries are adjacent bytes.
; HOW: The label group_y names this data address. These are stored data, not CPU instructions.
; Binary row bits run left to right from the high bit of each byte; table indices start at zero.
group_y:      !byte 62,62,62,62, 128,128,128,128, 194,194,194,194
; WHAT: Emit 12 literal bytes.
; WHY: Initialise per-ball colour values; successive entries are adjacent bytes.
; HOW: The label ball_colours names this data address. These are stored data, not CPU
; instructions. Binary row bits run left to right from the high bit of each byte; table indices
; start at zero.
ball_colours: !byte 1,2,3,7, 5,6,10,13, 4,8,9,14
; WHAT: Emit 4 literal bytes.
; WHY: Initialise per-channel bit masks 1,2,4,8; successive entries are adjacent bytes.
; HOW: The label bit_masks names this data address. These are stored data, not CPU instructions.
; Binary row bits run left to right from the high bit of each byte; table indices start at zero.
bit_masks:    !byte 1,2,4,8

; Screen RAM uses SCREEN CODES, not PETSCII/ASCII text bytes.
; A=1, B=2, ... Z=26; digits and spaces keep their usual values.
; WHAT: Define address label title_text.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
title_text:
; WHAT: Emit 12 literal bytes.
; WHY: Encode the displayed title using screen codes, ending with a zero sentinel.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
!byte $31,$32,$20,$02,$01,$0c,$0c,$13,$20,$2f,$20,$34
; WHAT: Emit 12 literal bytes.
; WHY: Encode the displayed title using screen codes, ending with a zero sentinel.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
!byte $20,$13,$10,$12,$09,$14,$05,$13,$20,$2d,$20,$12
; WHAT: Emit 12 literal bytes.
; WHY: Encode the displayed title using screen codes, ending with a zero sentinel.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
!byte $01,$13,$14,$05,$12,$20,$0d,$15,$0c,$14,$09,$10
; WHAT: Emit 3 literal bytes.
; WHY: Encode the displayed title using screen codes, ending with a zero sentinel.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
!byte $0c,$05,$18
; WHAT: Emit 1 literal byte.
; WHY: Encode the displayed title using screen codes, ending with a zero sentinel.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
!byte 0 ; End marker for title_loop

; 256-entry smooth wave, values from 0 to 24.
; The table is generated below as literal bytes, not calculated
; at runtime. This is a common fast technique on the 6502.
; WHAT: Define address label wave.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
wave:
; WHAT: Emit 16 literal bytes.
; WHY: Provide precomputed samples 0-24 so the CPU need not calculate trigonometry.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
!byte 12,12,13,13,13,13,14,14,14,15,15,15,15,16,16,16
; WHAT: Emit 16 literal bytes.
; WHY: Provide precomputed samples 0-24 so the CPU need not calculate trigonometry.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
!byte 17,17,17,17,18,18,18,18,19,19,19,19,20,20,20,20
; WHAT: Emit 16 literal bytes.
; WHY: Provide precomputed samples 0-24 so the CPU need not calculate trigonometry.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
!byte 20,21,21,21,21,21,22,22,22,22,22,22,23,23,23,23
; WHAT: Emit 16 literal bytes.
; WHY: Provide precomputed samples 0-24 so the CPU need not calculate trigonometry.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
!byte 23,23,23,23,23,24,24,24,24,24,24,24,24,24,24,24
; WHAT: Emit 16 literal bytes.
; WHY: Provide precomputed samples 0-24 so the CPU need not calculate trigonometry.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
!byte 24,24,24,24,24,24,24,24,24,24,24,24,23,23,23,23
; WHAT: Emit 16 literal bytes.
; WHY: Provide precomputed samples 0-24 so the CPU need not calculate trigonometry.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
!byte 23,23,23,23,23,22,22,22,22,22,22,21,21,21,21,21
; WHAT: Emit 16 literal bytes.
; WHY: Provide precomputed samples 0-24 so the CPU need not calculate trigonometry.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
!byte 20,20,20,20,20,19,19,19,19,18,18,18,18,17,17,17
; WHAT: Emit 16 literal bytes.
; WHY: Provide precomputed samples 0-24 so the CPU need not calculate trigonometry.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
!byte 17,16,16,16,15,15,15,15,14,14,14,13,13,13,13,12
; WHAT: Emit 16 literal bytes.
; WHY: Provide precomputed samples 0-24 so the CPU need not calculate trigonometry.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
!byte 12,12,11,11,11,11,10,10,10,9,9,9,9,8,8,8
; WHAT: Emit 16 literal bytes.
; WHY: Provide precomputed samples 0-24 so the CPU need not calculate trigonometry.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
!byte 7,7,7,7,6,6,6,6,5,5,5,5,4,4,4,4
; WHAT: Emit 16 literal bytes.
; WHY: Provide precomputed samples 0-24 so the CPU need not calculate trigonometry.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
!byte 4,3,3,3,3,3,2,2,2,2,2,2,1,1,1,1
; WHAT: Emit 16 literal bytes.
; WHY: Provide precomputed samples 0-24 so the CPU need not calculate trigonometry.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
!byte 1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0
; WHAT: Emit 16 literal bytes.
; WHY: Provide precomputed samples 0-24 so the CPU need not calculate trigonometry.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
!byte 0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1
; WHAT: Emit 16 literal bytes.
; WHY: Provide precomputed samples 0-24 so the CPU need not calculate trigonometry.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
!byte 1,1,1,1,1,2,2,2,2,2,2,3,3,3,3,3
; WHAT: Emit 16 literal bytes.
; WHY: Provide precomputed samples 0-24 so the CPU need not calculate trigonometry.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
!byte 4,4,4,4,4,5,5,5,5,6,6,6,6,7,7,7
; WHAT: Emit 16 literal bytes.
; WHY: Provide precomputed samples 0-24 so the CPU need not calculate trigonometry.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
!byte 7,8,8,8,9,9,9,9,10,10,10,11,11,11,11,12

; --------------------------------------------------------------
; One 24x21 monochrome ball sprite = 63 bytes.
; A 1 bit is a coloured pixel, a 0 bit is transparent.
; The extra 64th byte is unused sprite padding.
; --------------------------------------------------------------
; WHAT: Place the following output at $3000.
; WHY: Keep the BASIC launcher, executable code or graphics at its planned address.
; HOW: This is assembly-time placement, not a runtime jump. CBM output fills gaps between the
; lowest and highest emitted addresses.
* = $3000
; WHAT: Define address label ball_sprite.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
ball_sprite:
; WHAT: Emit 3 literal bytes.
; WHY: Describe a three-byte, 24-pixel sprite row, or the final slot-padding byte.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
!byte $00,$00,$00  ; Pixel row 0
; WHAT: Emit 3 literal bytes.
; WHY: Describe a three-byte, 24-pixel sprite row, or the final slot-padding byte.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
!byte $00,$7e,$00  ; Pixel row 1
; WHAT: Emit 3 literal bytes.
; WHY: Describe a three-byte, 24-pixel sprite row, or the final slot-padding byte.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
!byte $01,$ff,$80  ; Pixel row 2
; WHAT: Emit 3 literal bytes.
; WHY: Describe a three-byte, 24-pixel sprite row, or the final slot-padding byte.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
!byte $07,$ff,$e0  ; Pixel row 3
; WHAT: Emit 3 literal bytes.
; WHY: Describe a three-byte, 24-pixel sprite row, or the final slot-padding byte.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
!byte $0f,$ff,$f0  ; Pixel row 4
; WHAT: Emit 3 literal bytes.
; WHY: Describe a three-byte, 24-pixel sprite row, or the final slot-padding byte.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
!byte $1f,$ff,$f8  ; Pixel row 5
; WHAT: Emit 3 literal bytes.
; WHY: Describe a three-byte, 24-pixel sprite row, or the final slot-padding byte.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
!byte $1f,$ff,$f8  ; Pixel row 6
; WHAT: Emit 3 literal bytes.
; WHY: Describe a three-byte, 24-pixel sprite row, or the final slot-padding byte.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
!byte $3f,$ff,$fc  ; Pixel row 7
; WHAT: Emit 3 literal bytes.
; WHY: Describe a three-byte, 24-pixel sprite row, or the final slot-padding byte.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
!byte $3f,$ff,$fc  ; Pixel row 8
; WHAT: Emit 3 literal bytes.
; WHY: Describe a three-byte, 24-pixel sprite row, or the final slot-padding byte.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
!byte $3f,$ff,$fc  ; Pixel row 9
; WHAT: Emit 3 literal bytes.
; WHY: Describe a three-byte, 24-pixel sprite row, or the final slot-padding byte.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
!byte $3f,$ff,$fc  ; Pixel row 10
; WHAT: Emit 3 literal bytes.
; WHY: Describe a three-byte, 24-pixel sprite row, or the final slot-padding byte.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
!byte $3f,$ff,$fc  ; Pixel row 11
; WHAT: Emit 3 literal bytes.
; WHY: Describe a three-byte, 24-pixel sprite row, or the final slot-padding byte.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
!byte $3f,$ff,$fc  ; Pixel row 12
; WHAT: Emit 3 literal bytes.
; WHY: Describe a three-byte, 24-pixel sprite row, or the final slot-padding byte.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
!byte $3f,$ff,$fc  ; Pixel row 13
; WHAT: Emit 3 literal bytes.
; WHY: Describe a three-byte, 24-pixel sprite row, or the final slot-padding byte.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
!byte $1f,$ff,$f8  ; Pixel row 14
; WHAT: Emit 3 literal bytes.
; WHY: Describe a three-byte, 24-pixel sprite row, or the final slot-padding byte.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
!byte $1f,$ff,$f8  ; Pixel row 15
; WHAT: Emit 3 literal bytes.
; WHY: Describe a three-byte, 24-pixel sprite row, or the final slot-padding byte.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
!byte $0f,$ff,$f0  ; Pixel row 16
; WHAT: Emit 3 literal bytes.
; WHY: Describe a three-byte, 24-pixel sprite row, or the final slot-padding byte.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
!byte $07,$ff,$e0  ; Pixel row 17
; WHAT: Emit 3 literal bytes.
; WHY: Describe a three-byte, 24-pixel sprite row, or the final slot-padding byte.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
!byte $01,$ff,$80  ; Pixel row 18
; WHAT: Emit 3 literal bytes.
; WHY: Describe a three-byte, 24-pixel sprite row, or the final slot-padding byte.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
!byte $00,$7e,$00  ; Pixel row 19
; WHAT: Emit 3 literal bytes.
; WHY: Describe a three-byte, 24-pixel sprite row, or the final slot-padding byte.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
!byte $00,$00,$00  ; Pixel row 20
; WHAT: Emit 1 literal byte.
; WHY: Describe a three-byte, 24-pixel sprite row, or the final slot-padding byte.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
!byte $00  ; Unused 64th sprite byte
