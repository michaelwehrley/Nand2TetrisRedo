// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Fill.asm

// Runs an infinite loop that listens to the keyboard input.
// When a key is pressed (any key), the program blackens the screen,
// i.e. writes "black" in every pixel;
// the screen should remain fully black as long as the key is pressed. 
// When no key is pressed, the program clears the screen, i.e. writes
// "white" in every pixel;
// the screen should remain fully clear as long as no key is pressed.

// Put your code here.

@KBD // 24576
D=M
@BLACK_OUT
D;JGT // Jump to @BLACK_OUT `if` a key is being pressed
@WHITE_OUT
D;JMP

(BLACK_OUT)
  @SCREEN // 16384
  D=A
  @index
  M=D // set i=@SCREEN
  @BLACK_OUT_CONDITIONAL_LOOP
  0;JMP

(WHITE_OUT)
  @SCREEN // 16384
  D=A
  @index
  M=D // set i=@SCREEN
  @WHITE_OUT_CONDITIONAL_LOOP
  0;JMP

(RESTART)
  // For jumping it ignores D and focuses on A
  // D is used for comparisons and whatever
  // is in A gets sent to the PC for jumping
  @0
  0;JMP

(BLACK_OUT_CONDITIONAL_LOOP)
  @KBD // restart here (i.e., 24576)
  // D *was* set to the @SCREEN the 1st time
  D=A-D // keyboard - i = will always be positive until a jump
  @RESTART
  D;JEQ
  @index
  A=M // set A to be the value (the current register) in `index` !IMPORTANT!
  M=-1 // set this (i.e., registory A) to -1 (i.e., BLACK)
  @index
  M=M+1 // increment the index register RAM[index]
  D=M // rest D b/c it isn't set by @SCREEN anymore
  @BLACK_OUT_CONDITIONAL_LOOP
  0;JMP

(WHITE_OUT_CONDITIONAL_LOOP)
  @KBD // restart here (i.e., 24576)
  // D *was* set to the @SCREEN the 1st time
  D=A-D // keyboard - i = will always be positive until a jump
  @RESTART
  D;JEQ
  @index
  A=M // set A to be the value (the current register) in `index` !IMPORTANT!
  M=0 // set this (i.e., registory A) to 0  (i.e., WHITE)
  @index
  M=M+1 // increment the index register RAM[index]
  D=M // rest D b/c it isn't set by @SCREEN anymore
  @WHITE_OUT_CONDITIONAL_LOOP
  0;JMP