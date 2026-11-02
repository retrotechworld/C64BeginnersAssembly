; ========================================================================
; 05_sprite.asm - documented ACME source
; Every code-bearing line has WHAT, WHY and HOW comments.
; WHAT describes the operation. WHY explains its role. HOW explains encoding,
; flags, addressing, hardware effects or control flow.
; Code comments do not change the generated program bytes.
; PURPOSE: Move one rectangular hardware sprite once per frame.
; ASSUMPTIONS: Assumes default VIC bank 0 after reset; shape at $3000 uses pointer $C0. Reset
; to exit.
; ASSEMBLE: Select CBM format and an output name using the command line.
; Example from the companion root:
; acme --strict-segments -f cbm -o demo.prg programs/05_sprite.asm
; Archived originals are unchanged and are not the recommended teaching copies.
; ========================================================================
; Fully documented edition: WHAT / WHY / HOW before each code-bearing line.
; Book listing numbers are mapped to this file in SOURCE_LINE_MAP.json.
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
; WHAT: Load A from 0 (literal value).
; WHY: Prepare the value for sprite-enable mask.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #0
; WHAT: Copy A to sprite-enable mask.
; WHY: Update sprite-enable mask while we prepare the program before display updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.  Bit n enables hardware sprite channel n when it is 1.
    sta $d015
; WHAT: Copy A to sprite X-high-bit mask.
; WHY: Update sprite X-high-bit mask while we prepare the program before display updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.  Bit n supplies X bit 8 for hardware sprite n.
    sta $d010
; WHAT: Copy A to sprite Y-expansion mask.
; WHY: Update sprite Y-expansion mask while we prepare the program before display updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d017
; WHAT: Copy A to sprite X-expansion mask.
; WHY: Update sprite X-expansion mask while we prepare the program before display updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d01d
; WHAT: Copy A to sprite multicolour mask.
; WHY: Update sprite multicolour mask while we prepare the program before display updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d01c
; WHAT: Copy A to sprite priority mask.
; WHY: Update sprite priority mask while we prepare the program before display updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d01b
; WHAT: Load A from $14 (literal value).
; WHY: Prepare the value for video-memory selection.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #$14
; WHAT: Copy A to video-memory selection.
; WHY: Update video-memory selection while we prepare the program before display updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d018
; WHAT: Load A from $1b (literal value).
; WHY: Prepare the value for vertical/control register with mixed raster read/write bit.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #$1b
; WHAT: Copy A to vertical/control register with mixed raster read/write bit.
; WHY: Update vertical/control register with mixed raster read/write bit while we prepare the
; program before display updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.  Bits 0-2 select fine Y; bit 7 written selects raster compare high, unlike its
; read meaning.
    sta $d011
; WHAT: Load A from $c8 (literal value).
; WHY: Prepare the value for horizontal/control register.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #$c8
; WHAT: Copy A to horizontal/control register.
; WHY: Update horizontal/control register while we prepare the program before display updates
; begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.  Bits 0-2 select fine X; bit 3 chooses 40/38 columns; preserve deliberate upper
; controls.
    sta $d016
; WHAT: Load A from $c0 (literal value).
; WHY: Prepare the value for first sprite pointer.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #$c0
; WHAT: Copy A to first sprite pointer.
; WHY: Update first sprite pointer while we prepare the program before display updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $07f8
; WHAT: Load A from 1 (literal value).
; WHY: Prepare the value for sprite 0 colour / colour-register base.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #1
; WHAT: Copy A to sprite 0 colour / colour-register base.
; WHY: Update sprite 0 colour / colour-register base while we prepare the program before display
; updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d027
; WHAT: Copy A to sprite-enable mask.
; WHY: Update sprite-enable mask while we prepare the program before display updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.  Bit n enables hardware sprite channel n when it is 1.
    sta $d015
; WHAT: Load A from 120 (literal value).
; WHY: Prepare the value for moving sprite X coordinate.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #120
; WHAT: Copy A to moving sprite X coordinate.
; WHY: Update moving sprite X coordinate while we prepare the program before display updates
; begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta xpos
; WHAT: Copy A to sprite 0 X low byte.
; WHY: Update sprite 0 X low byte while we prepare the program before display updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d000
; WHAT: Copy A to sprite 0 Y coordinate.
; WHY: Update sprite 0 Y coordinate while we prepare the program before display updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d001
; WHAT: Define address label main.
; WHY: Name the entry or data location used to advance the sprite once per frame.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
main:
; WHAT: Call wait_frame.
; WHY: Delegate work to synchronise work to the end of raster line 250.
; HOW: Push the address of the last JSR byte on the page-1 stack, then load the target into PC.
; RTS pulls it and adds one.
    jsr wait_frame
; WHAT: Increment moving sprite X coordinate modulo 256.
; WHY: Advance the counter, position or offset used to advance the sprite once per frame.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z. NMOS memory read-modify-write writes the old byte before the new one; avoid
; applying this blindly to I/O.
    inc xpos
; WHAT: Load A from moving sprite X coordinate.
; WHY: Fetch moving sprite X coordinate while we advance the sprite once per frame.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda xpos
; WHAT: Compare A with #240 without changing that register.
; WHY: Set the condition for the following branch in main.
; HOW: Compute a temporary subtraction. Z means equal; C means register >= operand unsigned; N
; is subtraction bit 7; V is unchanged.
    cmp #240
; WHAT: Branch when C=0; target is draw.
; WHY: Choose the path that continues or completes advance the sprite once per frame.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bcc draw
; WHAT: Load A from 40 (literal value).
; WHY: Prepare the value for moving sprite X coordinate.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #40
; WHAT: Copy A to moving sprite X coordinate.
; WHY: Update moving sprite X coordinate while we advance the sprite once per frame.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta xpos
; WHAT: Define address label draw.
; WHY: Name the entry or data location used to write the resulting sprite X position.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
draw:
; WHAT: Copy A to sprite 0 X low byte.
; WHY: Update sprite 0 X low byte while we write the resulting sprite X position.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d000
; WHAT: Continue execution at main.
; WHY: Repeat the main loop or join the named control path.
; HOW: Absolute JMP changes PC without stacking a return address; flags are unchanged.
    jmp main
; WHAT: Define address label wait_frame.
; WHY: Name the entry or data location used to synchronise work to the end of raster line 250.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
wait_frame:
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
; WHAT: Return from the current subroutine.
; WHY: Return control to the caller after this routine has completed its work.
; HOW: Pull the JSR return address, add one, and continue there. The stack must still match the
; call; flags are unchanged.
    rts
; WHAT: Emit 1 literal byte.
; WHY: Initialise moving sprite X coordinate; successive entries are adjacent bytes.
; HOW: The label xpos names this data address. These are stored data, not CPU instructions.
; Binary row bits run left to right from the high bit of each byte; table indices start at zero.
xpos: !byte 120
; WHAT: Place the following output at $3000.
; WHY: Keep the BASIC launcher, executable code or graphics at its planned address.
; HOW: This is assembly-time placement, not a runtime jump. CBM output fills gaps between the
; lowest and highest emitted addresses.
* = $3000
; WHAT: Emit the stated count of repeated bytes.
; WHY: Allocate and initialise moving sprite X coordinate or the sprite artwork.
; HOW: ACME creates data during assembly; !fill 12,0 produces twelve zeros, while !fill 63,$ff
; produces 21 solid three-byte sprite rows.
!fill 63,$ff
; WHAT: Emit 1 literal byte.
; WHY: Initialise moving sprite X coordinate; successive entries are adjacent bytes.
; HOW: These are stored data, not CPU instructions. Binary row bits run left to right from the
; high bit of each byte; table indices start at zero.
!byte 0
