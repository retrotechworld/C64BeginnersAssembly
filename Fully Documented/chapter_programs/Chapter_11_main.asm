; ========================================================================
; Chapter_11_main.asm - documented ACME source
; Every code-bearing line has WHAT, WHY and HOW comments.
; WHAT describes the operation. WHY explains its role. HOW explains encoding,
; flags, addressing, hardware effects or control flow.
; Code comments do not change the generated program bytes.
; PURPOSE: Explore fine X bits while preserving the other $D016 settings.
; FLOW: start records the control byte with low three bits cleared. main waits for $D012 to
; change, merges fine_x into base_ctrl, writes $D016 and counts fine_x down from seven to zero
; before wrapping.
; TRY: Observe how fast it runs. For a frame-paced variant, replace the raster-change wait
; with the course wait_frame routine.
; ASSUMPTIONS: As supplied, it waits for the next raster line, not the next frame. It can
; write scrolling values throughout the picture and is not a finished smooth map scroller. No
; character columns are shifted when the fine offset wraps.
; ASSEMBLE: Select CBM format and an output name using the command line.
; Example from the companion root:
; acme --strict-segments -f cbm -o demo.prg chapter_programs/Chapter_11_main.asm
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
; WHAT: Load A from horizontal/control register.
; WHY: Fetch horizontal/control register while we prepare the program before display updates
; begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda $d016
; WHAT: A = A AND #%11111000.
; WHY: Select, combine or constrain the bits used to prepare the program before display updates
; begin.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    and #%11111000
; WHAT: Copy A to $D016 control bits with scroll cleared.
; WHY: Update $D016 control bits with scroll cleared while we prepare the program before display
; updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta base_ctrl
; WHAT: Load A from 7 (literal value).
; WHY: Prepare the value for fine horizontal scroll value.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #7
; WHAT: Copy A to fine horizontal scroll value.
; WHY: Update fine horizontal scroll value while we prepare the program before display updates
; begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta fine_x
; WHAT: Define address label main.
; WHY: Name the entry or data location used to repeat the example foreground update.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
main:
; WHAT: Load A from raster low byte / compare target.
; WHY: Fetch raster low byte / compare target while we repeat the example foreground update.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.  A read returns the current raster low byte, not the stored interrupt compare
; value.
    lda $d012
; WHAT: Define address label wait_low.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
wait_low:
; WHAT: Compare A with $d012 without changing that register.
; WHY: Set the condition for the following branch in wait_low.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cmp $d012
; WHAT: Branch when Z=1; target is wait_low.
; WHY: Choose the path that continues or completes this operation.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    beq wait_low
; WHAT: Load A from fine horizontal scroll value.
; WHY: Fetch fine horizontal scroll value while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda fine_x
; WHAT: A = A OR base_ctrl.
; WHY: Select, combine or constrain the bits used to update this setting.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    ora base_ctrl
; WHAT: Copy A to horizontal/control register.
; WHY: Update horizontal/control register while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.  Bits 0-2 select fine X; bit 3 chooses 40/38 columns; preserve deliberate upper
; controls.
    sta $d016
; WHAT: Decrement fine horizontal scroll value modulo 256.
; WHY: Advance the counter, position or offset used to process this loop.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z. NMOS memory read-modify-write writes the old byte before the new one; avoid
; applying this blindly to I/O.
    dec fine_x
; WHAT: Branch when N=0; target is main.
; WHY: Choose the path that continues or completes this operation.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bpl main
; WHAT: Load A from 7 (literal value).
; WHY: Prepare the value for fine horizontal scroll value.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #7
; WHAT: Copy A to fine horizontal scroll value.
; WHY: Update fine horizontal scroll value while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta fine_x
; WHAT: Continue execution at main.
; WHY: Repeat the main loop or join the named control path.
; HOW: Absolute JMP changes PC without stacking a return address; flags are unchanged.
    jmp main
; WHAT: Emit 1 literal byte.
; WHY: Initialise $D016 control bits with scroll cleared; successive entries are adjacent bytes.
; HOW: The label base_ctrl names this data address. These are stored data, not CPU instructions.
; Binary row bits run left to right from the high bit of each byte; table indices start at zero.
base_ctrl: !byte 0
; WHAT: Emit 1 literal byte.
; WHY: Initialise fine horizontal scroll value; successive entries are adjacent bytes.
; HOW: The label fine_x names this data address. These are stored data, not CPU instructions.
; Binary row bits run left to right from the high bit of each byte; table indices start at zero.
fine_x:    !byte 7
