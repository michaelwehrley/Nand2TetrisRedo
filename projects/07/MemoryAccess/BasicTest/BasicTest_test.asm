// push const 10 ...on the stack
// push 10
@10
D=A
@SP
A=M
M=D
@SP
M=M+1

// pop local 0 ...to the stack
@LCL
D=M
@0
D=D+A
@SP
M=M-1
@SP
A=M
M=D

// push const 21 ...on the stack
// push 21
@21
D=A
@SP
A=M
M=D
// increment stack pointer
@SP
M=M+1

// push const 22 ...on the stack
// push 22
@22
D=A
@SP
A=M
M=D
// increment stack pointer
@SP
M=M+1