while
  if @KBD
    (black out screen)
  else
    (white out screen)
end

(black out screen)
  i = @SCREEN
  while i < @KBD
    if key is NOT pressed then @BREAKOUT
    @i = -1
    i++
  end

(white out screen)
  i = @SCREEN
  while i < @KBD
    if key is pressed then @BREAKOUT
    @i = 0
    i++
  end