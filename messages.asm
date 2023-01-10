at        equ #16
ink       equ #10
bright    equ #13
new_line  equ #0d

instructions_message:
  db at,1,10
  db bright, 1
  db ink,6
  db "instructions"
  db at,3,1
  db bright, 1
  db ink,7
  db new_line, "You have to shoot the fighter."
  db new_line, "If you are closer to the entry"
  db new_line, "point of the jet you will"
  db new_line, "receive higher score, but more"
  db new_line, "dangerous to shoot it down."
  db new_line, "You have to get as much score as"
  db new_line, "you can while you time is off."
  db new_line, "If you crash with the jet, then"
  db new_line, "the game is over."
  db new_line, new_line, "Keys:"
  db new_line
  db " A = up", new_line
  db " Z = down", new_line 
  db " N = left", new_line 
  db " M = right", new_line 
  db "Space = shoot", new_line 
  db at,21,3
  db bright, 1
  db ink,6
  db "Press S to start the game"
  db 0

game_over_message:
  db at,10,12
  db bright, 1
  db ink,6
  db "GAME OVER!"
  db at,11,9
  db bright, 1
  db ink,9
  db "Try again later"
  db at,21,3
  db bright, 1
  db ink,6
  db "Press S to start the game"
  db 0

start_over_message:
  db at,21,3
  db bright, 1
  db ink,6
  db "Press S to start the game"
  db 0
