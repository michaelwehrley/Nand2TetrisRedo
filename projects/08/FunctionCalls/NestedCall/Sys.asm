// function Sys.init 0
(Sys.init)
// push constant 4000
@4000
D=A
@SP
A=M
M=D
@SP
M=M+1
// pop pointer 0
@SP
M=M-1
@SP
A=M
D=M
@THIS
M=D
// push constant 5000
@5000
D=A
@SP
A=M
M=D
@SP
M=M+1
// pop pointer 1
@SP
M=M-1
@SP
A=M
D=M
@THAT
M=D
// call Sys.main 0
@Sys.main
// pop temp 1
@SP
M=M-1
@SP
A=M
D=M
@stackValue
M=D
@5
D=A
@1
D=D+A
@targetLocation
M=D
@stackValue
D=M
@targetLocation
A=M
M=D
// label LOOP
(Sys.init$LOOP)
// goto LOOP
@Sys.init$LOOP
0;JMP
// function Sys.main 5
(Sys.main)
@SP
M=M+1
@SP
M=M+1
@SP
M=M+1
@SP
M=M+1
@SP
M=M+1
// push constant 4001
@4001
D=A
@SP
A=M
M=D
@SP
M=M+1
// pop pointer 0
@SP
M=M-1
@SP
A=M
D=M
@THIS
M=D
// push constant 5001
@5001
D=A
@SP
A=M
M=D
@SP
M=M+1
// pop pointer 1
@SP
M=M-1
@SP
A=M
D=M
@THAT
M=D
// push constant 200
@200
D=A
@SP
A=M
M=D
@SP
M=M+1
// pop local 1
@SP
M=M-1
@SP
A=M
D=M
@stackValue
M=D
@LCL
D=M
@1
D=D+A
@targetLocation
M=D
@stackValue
D=M
@targetLocation
A=M
M=D
// push constant 40
@40
D=A
@SP
A=M
M=D
@SP
M=M+1
// pop local 2
@SP
M=M-1
@SP
A=M
D=M
@stackValue
M=D
@LCL
D=M
@2
D=D+A
@targetLocation
M=D
@stackValue
D=M
@targetLocation
A=M
M=D
// push constant 6
@6
D=A
@SP
A=M
M=D
@SP
M=M+1
// pop local 3
@SP
M=M-1
@SP
A=M
D=M
@stackValue
M=D
@LCL
D=M
@3
D=D+A
@targetLocation
M=D
@stackValue
D=M
@targetLocation
A=M
M=D
// push constant 123
@123
D=A
@SP
A=M
M=D
@SP
M=M+1
// call Sys.add12 1
@Sys.add12
// pop temp 0
@SP
M=M-1
@SP
A=M
D=M
@stackValue
M=D
@5
D=A
@0
D=D+A
@targetLocation
M=D
@stackValue
D=M
@targetLocation
A=M
M=D
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
// push local 1
@LCL
D=M
@1
A=D+A
D=M
@SP
A=M
M=D
@SP
M=M+1
// push local 2
@LCL
D=M
@2
A=D+A
D=M
@SP
A=M
M=D
@SP
M=M+1
// push local 3
@LCL
D=M
@3
A=D+A
D=M
@SP
A=M
M=D
@SP
M=M+1
// push local 4
@LCL
D=M
@4
A=D+A
D=M
@SP
A=M
M=D
@SP
M=M+1
// add
@SP
M=M-1
A=M
D=M
@SP
M=M-1
A=M
M=M+D
@SP
M=M+1
// add
@SP
M=M-1
A=M
D=M
@SP
M=M-1
A=M
M=M+D
@SP
M=M+1
// add
@SP
M=M-1
A=M
D=M
@SP
M=M-1
A=M
M=M+D
@SP
M=M+1
// add
@SP
M=M-1
A=M
D=M
@SP
M=M-1
A=M
M=M+D
@SP
M=M+1
// return
@LCL
D=M
@Sys.main$FRAME
M=D
@SP
M=M-1
A=M
D=M
@ARG
A=M
M=D
@ARG
D=M+1
@SP
M=D
@1
D=A
@Sys.main$FRAME
D=M-D
A=D
D=M
@THAT
M=D
@2
D=A
@Sys.main$FRAME
D=M-D
A=D
D=M
@THIS
M=D
@3
D=A
@Sys.main$FRAME
D=M-D
A=D
D=M
@ARG
M=D
@4
D=A
@Sys.main$FRAME
D=M-D
A=D
D=M
@LCL
M=D
@SP
A=M
0;JMP
// function Sys.add12 0
(Sys.add12)
// push constant 4002
@4002
D=A
@SP
A=M
M=D
@SP
M=M+1
// pop pointer 0
@SP
M=M-1
@SP
A=M
D=M
@THIS
M=D
// push constant 5002
@5002
D=A
@SP
A=M
M=D
@SP
M=M+1
// pop pointer 1
@SP
M=M-1
@SP
A=M
D=M
@THAT
M=D
// push argument 0
@ARG
D=M
@0
A=D+A
D=M
@SP
A=M
M=D
@SP
M=M+1
// push constant 12
@12
D=A
@SP
A=M
M=D
@SP
M=M+1
// add
@SP
M=M-1
A=M
D=M
@SP
M=M-1
A=M
M=M+D
@SP
M=M+1
// return
@LCL
D=M
@Sys.add12$FRAME
M=D
@SP
M=M-1
A=M
D=M
@ARG
A=M
M=D
@ARG
D=M+1
@SP
M=D
@1
D=A
@Sys.add12$FRAME
D=M-D
A=D
D=M
@THAT
M=D
@2
D=A
@Sys.add12$FRAME
D=M-D
A=D
D=M
@THIS
M=D
@3
D=A
@Sys.add12$FRAME
D=M-D
A=D
D=M
@ARG
M=D
@4
D=A
@Sys.add12$FRAME
D=M-D
A=D
D=M
@LCL
M=D
@SP
A=M
0;JMP
