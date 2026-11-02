; ========================================================================
; 04_input.asm - documented ACME source
; Every code-bearing line has WHAT, WHY and HOW comments.
; WHAT describes the operation. WHY explains its role. HOW explains encoding,
; flags, addressing, hardware effects or control flow.
; Code comments do not change the generated program bytes.
; PURPOSE: Poll joystick port 2 fire and select a border colour.
; ASSUMPTIONS: Dedicated polling loop; it changes CIA input directions and masks IRQs. Reset
; to exit.
; ASSEMBLE: Select CBM format and an output name using the command line.
; Example from the companion root:
; acme --strict-segments -f cbm -o demo.prg programs/04_input.asm
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
; WHAT: Define address label loop.
; WHY: Name the entry or data location used to poll the fire button and choose border colour.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
loop:
; WHAT: Load A from CIA1 port A / joystick 2.
; WHY: Fetch CIA1 port A / joystick 2 while we poll the fire button and choose border colour.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Flags
; updated: N Z.
    lda $dc00
; WHAT: A = A AND #16.
; WHY: Select, combine or constrain the bits used to poll the fire button and choose border
; colour.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    and #16
; WHAT: Branch when Z=0; target is released.
; WHY: Choose the path that continues or completes poll the fire button and choose border
; colour.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne released
; WHAT: Load A from 2 (literal value).
; WHY: Set the literal value needed to poll the fire button and choose border colour.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #2
; WHAT: Branch when Z=0; target is show.
; WHY: Choose the path that continues or completes poll the fire button and choose border
; colour.
; HOW: Test the existing flag; the branch itself changes no flags. Offset is signed -128..+127
; from the next instruction; taken branches cost extra cycles.
    bne show
; WHAT: Define address label released.
; WHY: Name the entry or data location used to choose the released-button border colour.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
released:
; WHAT: Load A from 6 (literal value).
; WHY: Set the literal value needed to choose the released-button border colour.
; HOW: Immediate operand: the value is encoded in the instruction. Flags updated: N Z.
    lda #6
; WHAT: Define address label show.
; WHY: Name the entry or data location used to write the chosen border colour.
; HOW: ACME records the current assembly address; a label alone emits no bytes.
show:
; WHAT: Copy A to border colour.
; WHY: Update border colour while we write the chosen border colour.
; HOW: Read or write the named memory address; ACME chooses its supported encoding. Status flags
; are unchanged.
    sta $d020
; WHAT: Continue execution at loop.
; WHY: Repeat the main loop or join the named control path.
; HOW: Absolute JMP changes PC without stacking a return address; flags are unchanged.
    jmp loop
