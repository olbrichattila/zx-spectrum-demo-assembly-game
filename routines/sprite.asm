; deltes the srpite which is 16 line height 3 bites wide
; c, x coordinate
; d, y coorinate 

delete_sprite:			
	call yx2pix		;point de at the corresponding screen address
	ld b,16			;sprite is 16 lines high
delete_sprite_loop:
	xor a			;empty a to delete
	ld (de),a		;repeat a total of 3 times
	inc e			;next column along
	ld (de),a
	inc e
	ld (de),a
	dec e
	dec e			;move de back to start of line
	call get_next_line	;move de down one line
	djnz delete_sprite_loop		;repeat 16 times
	ret

draw_static_sprite:
	push hl
	call yx2pix
	pop hl
	ld b,8
	jp draw_loop

; draw sprite
; c x coordinate
; b y coordinate
; hl points to first stripe frame in memory
draw_sprite:
	push bc
	call yx2pix
	pop bc
	ld a,c
	; chose image by frame index in a
	and 00000111b
	call get_sprite
	ld b,16
draw_loop:
	ld a,(hl)
	ld (de),a
	inc hl
	inc e
	ld a,(hl)
	ld (de),a
	inc hl
	inc e
	ld a,(hl)
	ld (de),a
	inc hl
	dec e
	dec e
	call get_next_line
	djnz draw_loop
	ret
	
; register de contains current line 	
get_next_line:
	inc d
	ld a,d
	and 7
	ret nz
	ld a,e
	add a,32
	ld e,a
	ret c
	ld a,d
	sub 8
	ld d,a
	ret
	
; b=y, 0-192
; c=x, 0-255 	
; return position on screen id de
yx2pix:
	ld a,b
	rra
	rra
	rra
	and 24
	or 64
	ld d,a
	ld a,b
	and 7
	or d
	ld d,a
	ld a,b
	rla
	rla
	and 224
	ld e,a
	ld a,c
	rra
	rra
	rra
	and 31
	or e
	ld e,a
	ret
	
; input a frame indes
; hl first frame address
; return hl pointing to the selected sprite rotated by 0-7 (a)
get_sprite:
	push hl
	ld h,0		
	ld l,a
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	ld b,h
	ld c,l
	add hl,hl
	add hl,bc
	pop bc
	add hl,bc	
	ret
