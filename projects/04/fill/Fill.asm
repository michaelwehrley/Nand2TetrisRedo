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

@KBD
D=M
@BLACK_OUT
D;JGT
@WHITE_OUT
D;JMP
// @RESTART // Maybe unnecessary in future

(BLACK_OUT)
  @foo
  @bar
  @RESTART
  0;JMP

(WHITE_OUT)
  @RESTART
  0;JMP

(RESTART)
  // For jumping it ignores D and focuses on A
  // D is used for comparisons and whatever
  // is in A gets sent to the PC for jumping
  @0
  0;JMP