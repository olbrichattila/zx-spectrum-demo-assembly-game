output_zap_sound:
	ld d,16
	ld e,0
	ld b,255
beep_loop1:
	and 248
	out (254),a
	cpl
	ld d,a
	ld c,e
beep_loop2:	
	dec c
	jr nz,beep_loop2
	dec e
	djnz beep_loop1
	ret

output_hit_sound:
	ld b,100
	ld a,0
output_hit_sound_loop:
	xor 248
	ld e,a
	out (254),a
	dec b
	ret z
	ld hl,300
output_hit_sound_loop2:
	dec hl
	ld a,h
	or l
	jr nz, output_hit_sound_loop2 	 
	ld a,e
	jp output_hit_sound_loop

output_game_over_sound:
	ld bc,400
	ld a,0
beep_game_over_loop:
	xor 248
	ld e,a
	out (254),a
	dec bc
	ld a, c
	or b
	ret z
	ld hl,500
beep_game_overloop2:
	dec hl
	ld a,h
	or l
	jr nz, beep_game_overloop2 	 
	ld a,e
	jp beep_game_over_loop
