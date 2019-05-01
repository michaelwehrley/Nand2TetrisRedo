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

@R2
M=0 // RAM[2]; i.e., the sum is now set to 0 

@R0
D=M
@R1
D=D-M
@SWAP
D;JLT

@R1 // RAM[1]
D=M
@counter // Starting @ RAM[16]
M=D // @counter is now set to D; i.e., the number of times we need to ADD!

@END // set to A to instruction/ROM label `END`
D;JLE // if `@counter` </= 0 then go to `END`

@R2 // M = RAM[2] is the sum
D=M // grab anything that is in sum so we can add more to it.
@R0 // grab the first operand
D=D+M // new_sum = previous_sum + operand
@R2
M=D // set sum in RAM[2]
@counter // RAM[16]: decrement the counter
M=M-1
@counter // We need to evaluate D
D=M
@12 // Set A to `BEGIN`
D;JGT

(END)
  @26 // @END?
  0;JMP

(SWAP)
  @R0
  D=M
  @temp
  M=D
  @R1
  D=M
  @R0
  M=D
  @temp
  D=M
  @R1
  M=D
  @8
  0;JMP