@INITIALIZE
0;JMP

(INITIALIZE)
  @SCREEN
  M=0
  @_TOGGLE
  0;JMP

(_TOGGLE)
  @SCREEN // Fetch RAM[16384]
  M=-1
  M=0
  @INITIALIZE
  0;JMP // GoTo ROM[0]