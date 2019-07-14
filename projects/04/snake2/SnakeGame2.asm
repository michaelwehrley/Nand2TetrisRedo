// To mimic the snake game we played when we were younger,
// but built in Assembly

// BuildLevel # i.e., walls & obstacles
@BUILD_BORDER
0;JMP
@END

(END)
  @2
  0;JMP

(BUILD_BORDER)
  // Build Border...
  @INITALIZE_SNAKE
  0;JMP

(INITALIZE_SNAKE)
  // get height variable
  @16
  D=A
  @HEIGHT
  M=D
  // @SCREEN = 16384
  // @BOTTOM_BORDER_VALUE = 24575
  // (24575 - 16383) / 2 = 4096 (256 rows & 32 memory columns - 512 pixels across 32x16)
  // 16383 + 4096 - 16 (not sure why) = 20463 

  // Initialize snake position
  @20463 // get address (i.e., 20463)
  D=A // set D to address (D register is a temp register)
  @SNAKE_POSITION // Get a memory location that will store the snake position
  M=D // set that memory location to the value of where the snake currently is

  // Initialize snake body
  @SNAKE_BODY
  D=-1 // set the body to (@SNAKE_BODY) to 0b1111 1111 1111 1111

  // Build Snake with value of `D`
  @SNAKE_POSITION
  A=M
  M=D

  // // Initialize Directions
  // @UP
  // M=0
  // @RIGHT
  // M=1
  // @2
  // D=A
  // @DOWN
  // M=D
  // @3
  // D=A
  // @LEFT
  // M=D

  // // Set Initial Direction RIGHT
  // @RIGHT
  // D=M
  // @DIRECTION
  // M=D
  @END
  0;JMP
//   @START

// (START)
//   @MOVE_RIGHT
//   0;JMP

// (MOVE_RIGHT)
//   // Shift RIGHT in binary is created by doubling!
//   @SNAKE_POSITION
//   A=M
//   D=M // The current 'head/body'
//   M=D+M
//   D=M
//   @SNAKE_BODY
//   M=D
//   @RIGHT_BORDER_VALUE // 0b1000 0000 0000 0000
//   D=M-D
//   @JUMP_RIGHT
//   D;JEQ
//   @MOVE_RIGHT
//   0;JMP

// (JUMP_RIGHT)
//   @SNAKE_POSITION
//   M=M+1
//   A=M
//   M=1
//   @SNAKE_BODY
//   M=1
//   @MOVE_RIGHT
//   0;JMP
