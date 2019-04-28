// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Mult.asm

// Multiplies R0 and R1 and stores the result in R2.
// (R0, R1, R2 refer to RAM[0], RAM[1], and RAM[2], respectively.)

// Put your code here.

// ruby.rb
// GOAL: z = x * y
// z = 0
// while y > 0
//   z = z + x
//   y = y - 1
// end
// z

// pseudocode
// GOAL:  RAM[2] = RAM[0] * RAM[1]
// RAM[2] = 0
// RAM[3] = RAM[2] // RAM[3] will be the counter
// while RAM[1] > 0
//   RAM[2] + RAM[2] + RAM[0]
//   RAM[1] = RAM[1] - 1
// end

@0
D=A // D = 0
@R2
M=D // RAM[2] is now set to 0
// while loop
@R1 // RAM[1]
D=M
@R3 // RAM[3]
M=D // RAM[2] = D = RAM[1]
@END // set to GOTO END if...
D;JLE // if RAM[3] </= 0 then go to END
@R2 // M = RAM[2] sum/product
D=M
@R0
D=D+M // D = RAM[1]...it was zero
@R2
M=D
@R3 // RAM[3]: the counter
M=M-1
@R3 // unnecessary?
D=M
@8 // BEGIN
D;JGT

(END)
@22
0;JMP
