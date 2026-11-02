; ========================================================================
; Chapter_12_main.asm - documented ACME source
; Every code-bearing line has WHAT, WHY and HOW comments.
; WHAT describes the operation. WHY explains its role. HOW explains encoding,
; flags, addressing, hardware effects or control flow.
; Code comments do not change the generated program bytes.
; PURPOSE: Make a RAM copy of the upper/graphics character set and select it.
; FLOW: With IRQs masked, $01=$33 exposes character ROM to CPU reads in the $D000 window.
; Eight indexed reads/stores copy 2 KB to $2000. $01=$37 restores I/O, $D018 selects the RAM
; set and screen codes 1,2,3 display A,B,C.
; TRY: After the copy, replace the eight bytes of character 1 at $2008 and see every screen
; code 1 use that new shape.
; ASSUMPTIONS: This assumes the standard reset banking/direction setup and restores a hard-
; coded $37 rather than the caller original port. SEI does not mask NMI; a general ROM-copy
; library needs an explicit NMI and mapping plan. The RAM font copy occupies $2000-$27FF.
; ASSEMBLE: Select CBM format and an output name using the command line.
; Example from the companion root:
; acme --strict-segments -f cbm -o demo.prg chapter_programs/Chapter_12_main.asm
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
    ; Copy ROM charset to RAM at $2000.
; WHAT: Load A from $33 (literal value).
; WHY: Prepare the value for 6510 banking port.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #$33
; WHAT: Copy A to 6510 banking port.
; WHY: Update 6510 banking port while we prepare the program before display updates begin.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $01
; WHAT: Load X from 0 (literal value).
; WHY: Set the literal value needed to prepare the program before display updates begin.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    ldx #0
; WHAT: Define address label copy_page.
; WHY: Name the entry or data location used to copy one indexed byte from each of eight
; character-ROM pages.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
copy_page:
; WHAT: Load A from sprite 0 X low byte.
; WHY: Fetch sprite 0 X low byte while we copy one indexed byte from each of eight character-ROM
; pages.
; HOW: Indexed address: add the index register to the named base address. Flags updated: N Z.
    lda $d000,x
; WHAT: Copy A to $2000.
; WHY: Update $2000 while we copy one indexed byte from each of eight character-ROM pages.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta $2000,x
; WHAT: Load A from $d100.
; WHY: Fetch $d100 while we copy one indexed byte from each of eight character-ROM pages.
; HOW: Indexed address: add the index register to the named base address. Flags updated: N Z.
    lda $d100,x
; WHAT: Copy A to $2100.
; WHY: Update $2100 while we copy one indexed byte from each of eight character-ROM pages.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta $2100,x
; WHAT: Load A from $d200.
; WHY: Fetch $d200 while we copy one indexed byte from each of eight character-ROM pages.
; HOW: Indexed address: add the index register to the named base address. Flags updated: N Z.
    lda $d200,x
; WHAT: Copy A to $2200.
; WHY: Update $2200 while we copy one indexed byte from each of eight character-ROM pages.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta $2200,x
; WHAT: Load A from $d300.
; WHY: Fetch $d300 while we copy one indexed byte from each of eight character-ROM pages.
; HOW: Indexed address: add the index register to the named base address. Flags updated: N Z.
    lda $d300,x
; WHAT: Copy A to $2300.
; WHY: Update $2300 while we copy one indexed byte from each of eight character-ROM pages.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta $2300,x
; WHAT: Load A from voice 1 frequency low.
; WHY: Fetch voice 1 frequency low while we copy one indexed byte from each of eight character-
; ROM pages.
; HOW: Indexed address: add the index register to the named base address. Flags updated: N Z.
    lda $d400,x
; WHAT: Copy A to $2400.
; WHY: Update $2400 while we copy one indexed byte from each of eight character-ROM pages.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta $2400,x
; WHAT: Load A from $d500.
; WHY: Fetch $d500 while we copy one indexed byte from each of eight character-ROM pages.
; HOW: Indexed address: add the index register to the named base address. Flags updated: N Z.
    lda $d500,x
; WHAT: Copy A to $2500.
; WHY: Update $2500 while we copy one indexed byte from each of eight character-ROM pages.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta $2500,x
; WHAT: Load A from $d600.
; WHY: Fetch $d600 while we copy one indexed byte from each of eight character-ROM pages.
; HOW: Indexed address: add the index register to the named base address. Flags updated: N Z.
    lda $d600,x
; WHAT: Copy A to $2600.
; WHY: Update $2600 while we copy one indexed byte from each of eight character-ROM pages.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta $2600,x
; WHAT: Load A from $d700.
; WHY: Fetch $d700 while we copy one indexed byte from each of eight character-ROM pages.
; HOW: Indexed address: add the index register to the named base address. Flags updated: N Z.
    lda $d700,x
; WHAT: Copy A to $2700.
; WHY: Update $2700 while we copy one indexed byte from each of eight character-ROM pages.
; HOW: Indexed address: add the index register to the named base address. Status flags are
; unchanged.
    sta $2700,x
; WHAT: Increment X modulo 256.
; WHY: Advance the counter, position or offset used to copy one indexed byte from each of eight
; character-ROM pages.
; HOW: Implied/accumulator form; no separate memory operand. Flags updated: N Z.
    inx
; WHAT: Branch when Z=0; target is copy_page.
; WHY: Choose the path that continues or completes copy one indexed byte from each of eight
; character-ROM pages.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne copy_page
; WHAT: Load A from $37 (literal value).
; WHY: Prepare the value for 6510 banking port.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #$37
; WHAT: Copy A to 6510 banking port.
; WHY: Update 6510 banking port while we copy one indexed byte from each of eight character-ROM
; pages.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $01
    ; $2000 charset, screen remains $0400.
; WHAT: Load A from video-memory selection.
; WHY: Fetch video-memory selection while we copy one indexed byte from each of eight character-
; ROM pages.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda $d018
; WHAT: A = A AND #%11110001.
; WHY: Select, combine or constrain the bits used to copy one indexed byte from each of eight
; character-ROM pages.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    and #%11110001
; WHAT: A = A OR #%00001000.
; WHY: Select, combine or constrain the bits used to copy one indexed byte from each of eight
; character-ROM pages.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    ora #%00001000
; WHAT: Copy A to video-memory selection.
; WHY: Update video-memory selection while we copy one indexed byte from each of eight
; character-ROM pages.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d018
    ; Draw screen codes 1,2,3 in a row.
; WHAT: Load A from 1 (literal value).
; WHY: Prepare the value for first screen cell.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #1
; WHAT: Copy A to first screen cell.
; WHY: Update first screen cell while we copy one indexed byte from each of eight character-ROM
; pages.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $0400
; WHAT: Load A from 2 (literal value).
; WHY: Prepare the value for $0401.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #2
; WHAT: Copy A to $0401.
; WHY: Update $0401 while we copy one indexed byte from each of eight character-ROM pages.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $0401
; WHAT: Load A from 3 (literal value).
; WHY: Prepare the value for $0402.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #3
; WHAT: Copy A to $0402.
; WHY: Update $0402 while we copy one indexed byte from each of eight character-ROM pages.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $0402
; WHAT: I = 0.
; WHY: Permit maskable IRQ recognition; does not clear interrupt sources.
; HOW: Permit maskable IRQ recognition; does not clear interrupt sources. Among status flags,
; only I change.
    cli
; WHAT: Return from the current subroutine.
; WHY: Return control to the caller after this routine has completed its work.
; HOW: Pull the JSR return address, add one, and continue there. The stack must still match the
; call; flags are unchanged.
    rts
