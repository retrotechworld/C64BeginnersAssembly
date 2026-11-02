C64 Assembly Language Programming for the Absolute Beginner
BOOK LINE-MATCHED SOURCE PACK

USE THESE FILES WHEN FOLLOWING THE BOOK'S L REFERENCES.

For example:
  Every line / Chapter_06_main.asm
  L001 !cpu 6510

Open Chapter_06_main.asm and turn on line numbers in your editor.
Line 1 is !cpu 6510.
Line 2 is intentionally blank.
Line 3 is * = $0801, matching L003 in the book.

L001 is the book's label for physical line 1. It is not part of the assembly source and must not be typed into the file.

Blank lines preserve the book's numbering, including gaps left by comment-only lines in the original teaching listing. Do not delete those blank lines, insert extra header comments, or auto-format a file if you want the line numbers to continue matching.

All 36 files with L-numbered walkthroughs were reconstructed directly from the corrected book's actual printed source statements. Every one of its 2,090 numbered code lines has been checked against the corresponding physical file line. All 36 assemble successfully and produce byte-for-byte identical programs to the documented teaching copies.

architecture_demo.asm is also included because it appears in the architecture chapter. Its explanation is not L-numbered. This brings the pack to 37 distinct ASM files.

The earlier fully commented pack contains What / Why / How comments before each instruction. Those added comments change physical editor line numbers. Keep that pack for the extended explanations; use THIS pack for direct L001/L002/etc. lookup. The book itself supplies the explanations beside these statements.

FILES
The ASM files are together in this folder so that a heading such as Every line / Chapter_06_main.asm names the exact filename to open.
Book_Line_Index.csv lists all 2,090 numbered statements and their editor line numbers, for searching or opening in a spreadsheet.
No archived originals, duplicate annotated copies or compiled PRGs are included.

BUILD EXAMPLES, FROM THIS FOLDER
acme --strict-segments -f cbm -o chapter06.prg Chapter_06_main.asm
acme --strict-segments -f cbm -o balls.prg balls.asm
acme --strict-segments -f cbm -o grid.prg grid.asm

Use RUN / SYS 2064 where the lesson specifies the standard launcher.
macro_and_data.asm is an assembly demonstration at $2000, not a BASIC launcher; follow Appendix D (SYS 8192 if loaded as a C64 PRG).
Reset before switching examples that take over interrupts or hardware. Follow the book's PAL and joystick-port requirements.

Assembly and byte comparison verify the source reconstruction; they do not replace emulator or hardware testing.
