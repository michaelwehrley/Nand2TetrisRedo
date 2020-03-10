// push constant 10
@10
D=A
@SP
A=M
M=D
@SP
M=M+1
// pop local 0
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
M=D
@SP
M=M-1
// push constant 21
@21
D=A
@SP
A=M
M=D
@SP
M=M+1
// push constant 22
@22
D=A
@SP
A=M
M=D
@SP
M=M+1
// pop argument 2
@SP
A=M
D=M
@stackValue
M=D
@ARG
D=M
@2
D=D+A
@targetLocation
M=D
@stackValue
D=M
@targetLocation
M=D
@SP
M=M-1
// pop argument 1
@SP
A=M
D=M
@stackValue
M=D
@ARG
D=M
@1
D=D+A
@targetLocation
M=D
@stackValue
D=M
@targetLocation
M=D
@SP
M=M-1
// push constant 36
@36
D=A
@SP
A=M
M=D
@SP
M=M+1
// pop this 6
@SP
A=M
D=M
@stackValue
M=D
@THIS
D=M
@6
D=D+A
@targetLocation
M=D
@stackValue
D=M
@targetLocation
M=D
@SP
M=M-1
// push constant 42
@42
D=A
@SP
A=M
M=D
@SP
M=M+1
// push constant 45
@45
D=A
@SP
A=M
M=D
@SP
M=M+1
// pop that 5
@SP
A=M
D=M
@stackValue
M=D
@THAT
D=M
@5
D=D+A
@targetLocation
M=D
@stackValue
D=M
@targetLocation
M=D
@SP
M=M-1
// pop that 2
@SP
A=M
D=M
@stackValue
M=D
@THAT
D=M
@2
D=D+A
@targetLocation
M=D
@stackValue
D=M
@targetLocation
M=D
@SP
M=M-1
// push constant 510
@510
D=A
@SP
A=M
M=D
@SP
M=M+1
// pop temp 6
@SP
A=M
D=M
@stackValue
M=D
@5
D=A
@6
D=D+A
@targetLocation
M=D
@stackValue
D=M
@targetLocation
M=D
@SP
M=M-1
// push local 0
@LCL
D=M
@0
A=D+A
D=M
@SP
A=M
M=D
@SP
M=M+1
// push that 5
@THAT
D=M
@5
A=D+A
D=M
@SP
A=M
M=D
@SP
M=M+1
// add
// push argument 1
@ARG
D=M
@1
A=D+A
D=M
@SP
A=M
M=D
@SP
M=M+1
// sub
// push this 6
@THIS
D=M
@6
A=D+A
D=M
@SP
A=M
M=D
@SP
M=M+1
// push this 6
@THIS
D=M
@6
A=D+A
D=M
@SP
A=M
M=D
@SP
M=M+1
// add
// sub
// push temp 6
@5
D=A
@6
A=D+A
D=M
@SP
A=M
M=D
@SP
M=M+1
// add
