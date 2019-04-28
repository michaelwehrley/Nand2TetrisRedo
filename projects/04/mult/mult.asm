// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Mult.asm

// Multiplies R0 and R1 and stores the result in R2.
// (R0, R1, R2 refer to RAM[0], RAM[1], and RAM[2], respectively.)

// Put your code here.

// .rb
// GOAL: z = x * y
// z = 0
// while y > 0
//   z = z + x
//   y = y - 1
// end
// z

// pseudocode
// GOAL:  RAM[2] = RAM[0]* RAM[1]
// RAM[2] = 0
// while RAM[1] > 0
//   RAM[2] + RAM[2] + RAM[0]
//   RAM[1] = RAM[1] - 1
// end

@0
D=M // D = 0
@R2
M=D // RAM[2] is now set to 0
@4
0;JMP
