@333
D=A
@255
M=D

// pop local 0

@SP
M=M-1

@SP
A=M

D=M
@value
M=D

@LCL
D=M
@0
D=D+A
@targetLCL
M=D

@value
D=M
@targetLCL
A=M
M=D

