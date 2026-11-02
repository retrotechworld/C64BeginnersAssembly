; ========================================================================
; Chapter_21_main.asm - documented ACME source
; Every code-bearing line has WHAT, WHY and HOW comments.
; WHAT describes the operation. WHY explains its role. HOW explains encoding,
; flags, addressing, hardware effects or control flow.
; Code comments do not change the generated program bytes.
; PURPOSE: Enable hires bitmap mode and set the first bitmap byte.
; FLOW: The $D018 update selects a bitmap at $2000 with the default screen at $0400. Setting
; $D011 bit 5 enables bitmap mode. Screen byte $10 gives the first cell white/black colours;
; $80 at $2000 sets its leftmost top-row bit.
; TRY: Change $80 to $40, then $FF: move the first lit pixel right, then light the whole first
; row of that cell.
; ASSUMPTIONS: The original does not clear the remaining 7,999 bitmap bytes or initialise all
; colour cells, so other areas can contain arbitrary graphics. The first cell may also retain
; other row data. A polished full-screen bitmap demo needs deliberate initialisation and a
; restoration path.
; ASSEMBLE: Select CBM format and an output name using the command line.
; Example from the companion root:
; acme --strict-segments -f cbm -o demo.prg chapter_programs/Chapter_21_main.asm
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
    ; Screen at $0400, bitmap at $2000.
; WHAT: Load A from video-memory selection.
; WHY: Fetch video-memory selection while we prepare the program before display updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda $d018
; WHAT: A = A AND #%11110001.
; WHY: Select, combine or constrain the bits used to prepare the program before display updates
; begin.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    and #%11110001
; WHAT: A = A OR #%00001000.
; WHY: Select, combine or constrain the bits used to prepare the program before display updates
; begin.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    ora #%00001000
; WHAT: Copy A to video-memory selection.
; WHY: Update video-memory selection while we prepare the program before display updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d018
; WHAT: Load A from vertical/control register with mixed raster read/write bit.
; WHY: Fetch vertical/control register with mixed raster read/write bit while we prepare the
; program before display updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.  Bit 7 read is current raster high; writing that bit later changes the compare
; high bit.
    lda $d011
; WHAT: A = A OR #%00100000.
; WHY: Select, combine or constrain the bits used to prepare the program before display updates
; begin.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    ora #%00100000
; WHAT: Copy A to vertical/control register with mixed raster read/write bit.
; WHY: Update vertical/control register with mixed raster read/write bit while we prepare the
; program before display updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.  Bits 0-2 select fine Y; bit 7 written selects raster compare high, unlike its
; read meaning.
    sta $d011
    ; White foreground / black background
    ; for first 8x8 bitmap cell.
; WHAT: Load A from $10 (literal value).
; WHY: Prepare the value for first screen cell.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #$10
; WHAT: Copy A to first screen cell.
; WHY: Update first screen cell while we prepare the program before display updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $0400
    ; Top-left pixel at bitmap byte $2000.
; WHAT: Load A from %10000000 (literal value).
; WHY: Prepare the value for $2000.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #%10000000
; WHAT: Copy A to $2000.
; WHY: Update $2000 while we prepare the program before display updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $2000
; WHAT: Return from the current subroutine.
; WHY: Return control to the caller after this routine has completed its work.
; HOW: Pull the JSR return address, add one, and continue there. The stack must still match the
; call; flags are unchanged.
    rts
