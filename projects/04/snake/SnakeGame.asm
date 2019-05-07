// To mimic the snake game we played when we were younger,
// but built in Assembly

// BuildLevel # i.e., walls
@BUILD_BORDER
0;JMP
@END

(END)
  @2
  0;JMP

(BUILD_BORDER)
  // We could initialize all variables here...
  @INITIALIZE_TOP_BORDER
  0;JMP

(INITIALIZE_TOP_BORDER)
  @SCREEN // (i.e., 16384) Top-left RAM
  D=A
  @CURRENT_POSITION
  M=D
  @16415 // Top-right RAM
  D=A
  @TOP_RIGHT_CORNER
  M=D
  @TOP_BORDER_VALUE
  M=-1
  @DRAW_TOP_BORDER
  0;JMP

(DRAW_TOP_BORDER)
  @TOP_BORDER_VALUE
  D=M
  @CURRENT_POSITION
  A=M
  M=D
  @CURRENT_POSITION
  M=M+1
  D=M
  @TOP_RIGHT_CORNER
  D=D-M
  @DRAW_TOP_BORDER
  D;JLE
  @INITIALIZE_BOTTOM_BORDER
  0;JMP

(INITIALIZE_BOTTOM_BORDER)
  @24544 // Bottom-left RAM
  D=A
  @CURRENT_POSITION
  M=D
  @24575 // Bottom-right RAM
  D=A
  @BOTTOM_RIGHT_CORNER
  M=D
  @BOTTOM_BORDER_VALUE
  M=-1
  @DRAW_BOTTOM_BORDER
  0;JMP

(DRAW_BOTTOM_BORDER)
  @BOTTOM_BORDER_VALUE
  D=M
  @CURRENT_POSITION
  A=M
  M=D
  @CURRENT_POSITION
  M=M+1
  D=M
  @BOTTOM_RIGHT_CORNER
  D=D-M
  @DRAW_BOTTOM_BORDER
  D;JLE
  @INITIALIZE_LEFT_BORDER
  0;JMP

(INITIALIZE_LEFT_BORDER)
  @16416 // Upper-left RAM
  D=A
  @CURRENT_POSITION
  M=D
  @24512 // Lower-left RAM
  D=A
  @LOWER_LEFT_CORNER
  M=D
  @LEFT_BORDER_VALUE
  M=1
  @32
  D=A
  @SCREEN_WIDTH
  M=D
  @DRAW_LEFT_BORDER
  D;JMP

(DRAW_LEFT_BORDER)
  @LEFT_BORDER_VALUE
  D=M
  @CURRENT_POSITION
  A=M
  M=D
  @SCREEN_WIDTH
  D=M
  @CURRENT_POSITION
  M=M+D
  D=M
  @LOWER_LEFT_CORNER
  D=D-M
  @DRAW_LEFT_BORDER
  D;JLE
  @INITIALIZE_RIGHT_BORDER
  0;JMP

(INITIALIZE_RIGHT_BORDER) // LOOK AT FOR LEFT?
  @16447 // Upper-right RAM
  D=A
  @CURRENT_POSITION
  M=D
  @24543 // Lower-right RAM
  D=A
  @LOWER_RIGHT_CORNER
  M=D
  @RIGHT_BORDER_VALUE
  M=0
  @16384 // Used to x2 to get the correct bit/pixel representation: 1000 0000 0000 0000
  D=A
  @RIGHT_BORDER_VALUE
  M=D
  M=D+M // 32768 = 0b1000 0000 0000 0000
  @32
  D=A
  @SCREEN_WIDTH
  M=D
  @DRAW_RIGHT_BORDER
  0;JMP

(DRAW_RIGHT_BORDER)
  @RIGHT_BORDER_VALUE
  D=M
  @CURRENT_POSITION
  A=M
  M=D
  @SCREEN_WIDTH
  D=M
  @CURRENT_POSITION
  M=M+D
  D=M
  @LOWER_RIGHT_CORNER
  D=D-M
  @DRAW_RIGHT_BORDER
  D;JLE
  @INITALIZE_SNAKE

(INITALIZE_SNAKE)
  // @SCREEN = 16384
  // @BOTTOM_BORDER_VALUE = 24575
  // (24575 - 16383) / 2 = 4096 (256 rows & 32 memory columns - 512 pixels across)
  // 16383 + 4096 - 16 (not sure why) = 20463 
  @20463
  M=1 // Just the head: 0b0000 0000 0000 0001
  D=A
  @SNAKE_POSITION
  M=D
  @LEFT
  @RIGHT
  @FORWARD
  @DIRECTION
  @START

(START)
  @MOVE
  @END
  0;JMP


