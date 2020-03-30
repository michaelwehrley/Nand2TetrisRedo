// push constant 0
@0
D=A
@SP
A=M
M=D
@SP
M=M+1
// pop local 0
@SP
M=M-1
@SP
A=M
D=M
@stackValue
M=D
@LCL
D=M
@0
D=D+A
@targetLocation
M=D
@stackValue
D=M
@targetLocation
A=M
M=D
// label LOOP_START
