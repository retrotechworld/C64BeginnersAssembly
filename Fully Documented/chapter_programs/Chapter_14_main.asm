; ========================================================================
; Chapter_14_main.asm - documented ACME source
; Every code-bearing line has WHAT, WHY and HOW comments.
; WHAT describes the operation. WHY explains its role. HOW explains encoding,
; flags, addressing, hardware effects or control flow.
; Code comments do not change the generated program bytes.
; PURPOSE: Update a small counter when raster line 250 is reached.
; FLOW: The first wait leaves an already-active line 250. The second waits for the next
; occurrence. tick increments, AND #15 maps its low nibble to a border colour, then main
; repeats.
; TRY: Change AND #15 to AND #7; predict which colour indices can appear.
; ASSUMPTIONS: This is raster polling, not a CIA timer setup. It produces one update per frame
; only while the remaining work finishes in time. Video refresh rates differ between PAL and
; NTSC.
; ASSEMBLE: Select CBM format and an output name using the command line.
; Example from the companion root:
; acme --strict-segments -f cbm -o demo.prg chapter_programs/Chapter_14_main.asm
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
; WHY: Prepare the value for update counter.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #0
; WHAT: Copy A to update counter.
; WHY: Update update counter while we prepare the program before display updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta tick
; WHAT: Define address label main.
; WHY: Name the entry or data location used to repeat the example foreground update.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
main:
    ; Wait for raster line 250 to begin.
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
; WHAT: Define address label wait_250.
; WHY: Name the entry or data location used to organise this section.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
wait_250:
; WHAT: Load A from raster low byte / compare target.
; WHY: Fetch raster low byte / compare target while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.  A read returns the current raster low byte, not the stored interrupt compare
; value.
    lda $d012
; WHAT: Compare A with #250 without changing that register.
; WHY: Set the condition for the following branch in wait_250.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cmp #250
; WHAT: Branch when Z=0; target is wait_250.
; WHY: Choose the path that continues or completes this operation.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne wait_250
; WHAT: Increment update counter modulo 256.
; WHY: Advance the counter, position or offset used to process this loop.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z. NMOS memory read-modify-write writes the old byte before the new one; avoid
; applying this blindly to I/O.
    inc tick
; WHAT: Load A from update counter.
; WHY: Fetch update counter while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda tick
; WHAT: A = A AND #15.
; WHY: Select, combine or constrain the bits used to update this setting.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    and #15
; WHAT: Copy A to border colour.
; WHY: Update border colour while we process this section.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d020
; WHAT: Continue execution at main.
; WHY: Repeat the main loop or join the named control path.
; HOW: Absolute JMP changes PC without stacking a return address; flags are unchanged.
    jmp main
; WHAT: Emit 1 literal byte.
; WHY: Initialise update counter; successive entries are adjacent bytes.
; HOW: The label tick names this data address. These are stored data, not CPU instructions.
; Binary row bits run left to right from the high bit of each byte; table indices start at zero.
tick: !byte 0
