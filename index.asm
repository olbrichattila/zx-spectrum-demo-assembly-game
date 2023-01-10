    device zxspectrum48
    org 32768
    include "routines/definitions.asm"
begin:

    jp main
    include "routines/sprite.asm"
    include "routines/helpers.asm"
    include "routines/sound.asm"
    include "routines/timer.asm"
main: 
    ; we want a black screen, green default icons.
    ld a,%0000100
    ld (var_permanent_current_colours),a
    xor a
    call rom_set_permanent_colors
    call rom_clear_screen
    call display_instructions
    call wait_for_s_key_pressed
game_begin:
    call reset_game_variables
    call reset_timer
    call rom_clear_screen
    call display_score_bar
    call display_timer_if_necessary
    call draw_grass

main_loop:	
    halt			
    call timer_event	
    call display_timer_if_necessary
    call has_timer_expired
    jr z, time_expired	
    call delete_player_sprite
    call delete_fighter_sprite
    call move_player_by_keyboard
    call draw_player_sprite
    call move_fighter
    call draw_fighter_sprite
    call detect_soot_key_pressed
    call delete_prevous_bullet 
    call shoot
    call detect_player_fighter_collision
    jr c, game_over_due_to_crash
    call detect_bullet_hit
    jr main_loop

game_over_due_to_crash:
    call wait_for_s_key_pressed
    jp game_begin

time_expired:
    ld hl,start_over_message
    call show_message
    call wait_for_s_key_pressed
    jp game_begin

move_fighter:
    ld a, (fighter_xcoordinate)
    dec a
    jr nz, continue_to_move_fighter
    call reset_fighter_to_randomized_position
    ret
continue_to_move_fighter:
    ld (fighter_xcoordinate), a
    ret

reset_fighter_to_randomized_position:
    call get_random_number
    cp 167
    jr nc, reset_fighter_to_randomized_position
    cp 16
    jr c, reset_fighter_to_randomized_position
    ld (fighter_ycoordinate), a
    ld a, 232
    ld (fighter_xcoordinate), a
    ret

move_player_by_keyboard
    ld a,(player_ycoordinate)
    inc a
    cp 170
    jr nc, already_at_bottom_position
    ld (player_ycoordinate),a
already_at_bottom_position:
    ld bc,#7ffe
    in a,(c)
    bit 3, a
    jr z, is_n_key_pressed 
    bit 2, a
    jr z, is_m_key_pressed
move_vertically:
    ld bc,#fdfe
    in a,(c)
    bit 0, a
    jr z, is_a_key_pressed
    ld bc,#fefe
    in a,(c)
    bit 1, a
    jr z, is_z_key_pressed
    ret
is_n_key_pressed:
    ld a,(player_xcoordinate)
    dec a
    ret z
    ld (player_xcoordinate),a
    jp move_vertically
is_m_key_pressed:
    ld a,(player_xcoordinate)
    inc a
    cp 232
    ret nc
    ld (player_xcoordinate),a
    jp move_vertically
is_a_key_pressed:
    ld a,(player_ycoordinate)
    dec a
    dec a
    dec a
    cp 16
    ret c
    ld (player_ycoordinate),a
    ret
is_z_key_pressed:
    ld a,(player_ycoordinate)
    inc a
    cp 167
    ret nc
    ld (player_ycoordinate),a
    ret

detect_soot_key_pressed:
    ld bc,#7ffe
    in a,(c)
    bit 0, a
    jr z, space_key_pressed
    ret

space_key_pressed:
    ld a, (is_shooting)
    cp a, 1
    ret z 
    call output_zap_sound
    ld a, (player_xcoordinate)
    add a,16
    ld (bullet_xcoordinate), a
    ld a, (player_ycoordinate)
    add a,8 
    ld (bullet_ycoordinate), a
    ld a, 1
    ld (is_shooting), a
    ret

delete_prevous_bullet:
    ld a, (is_shooting)
    cp a, 1
    ret nz
    ld a,(del_bullet_xcoordinate)
    ld c,a
    ld a, (del_bullet_ycoordinate)
    ld b,a
    call yx2pix
    ld a, 0
    ld (de), a
    ret

shoot:
    ld a, (is_shooting)
    cp a, 1
    ret nz
    ld a,(bullet_xcoordinate)
    ld (del_bullet_xcoordinate), a
    cp 232
    jr c, bullet_stillflying
    ld a, 0
    ld (is_shooting), a
    ret

bullet_stillflying:
    ld c,a
    ld a,(bullet_ycoordinate)
    ld (del_bullet_ycoordinate), a
    ld b,a
    call yx2pix
    ld a, %10101010
    ld (de), a
    ld a,(bullet_xcoordinate)  
    add a, 8
    ld (bullet_xcoordinate),a
    ret

detect_player_fighter_collision:
    ld a, (player_ycoordinate)
    ld b, a
    ld a, (fighter_ycoordinate)
    sub b
    cp 16
    ret nc
    ld a, (player_xcoordinate)
    ld b, a
    ld a, (fighter_xcoordinate)
    sub b
    cp 20 
    ret nc
    call output_game_over_sound
    ld hl,game_over_message
    call show_message
    ld a, 1
    rrc a
    ret

detect_bullet_hit:
    ld a, (is_shooting)
    cp a, 1
    ret nz
    ld a, (fighter_ycoordinate)
    ld b, a
    ld a, (del_bullet_ycoordinate)
    sub b
    cp 16
    ret nc
    ld a, (fighter_xcoordinate)
    ld b, a
    ld a, (del_bullet_xcoordinate)
    sub b
    cp 20 
    ret nc
    ; if the player is closer to the end of the screen, gets more score
    ld hl, (score)
    inc hl
    ld a, (player_xcoordinate)
    ld e,a
    ld d, 0
    add hl, de
    ld (score), hl
    call output_hit_sound
    call display_score_bar
    call delete_fighter_sprite
    call reset_fighter_to_randomized_position
    ret

delete_player_sprite:
    ld a,(player_xcoordinate)
    ld c,a
    ld a,(player_ycoordinate)
    ld b,a
    call delete_sprite
    ret

delete_fighter_sprite:
    ld a,(fighter_xcoordinate)
    ld c,a
    ld a,(fighter_ycoordinate)
    ld b,a
    call delete_sprite
    ret;

draw_player_sprite:
    ld a,(player_xcoordinate)
    ld c,a
    ld a,(player_ycoordinate)
    ld b,a
    ld hl,player_sprite_data0
    call draw_sprite
    ret

draw_fighter_sprite:
    ld a,(fighter_xcoordinate)
    ld c,a
    ld a,(fighter_ycoordinate)
    ld b,a
    ld hl,fighter_sprite_data0
    call draw_sprite
    ret

display_instructions:
    ld hl,instructions_message
    call show_message
    ret

wait_for_s_key_pressed:
    ld bc,#fbfe
    in a,(c)
    bit 0, a
    ; hidden function Q to quit
    jr nz, no_quit
    pop bc
    ret
no_quit:
    ld bc,#fdfe
    in a,(c)
    bit 1, a
    jr nz, wait_for_s_key_pressed
    ret
    
reset_game_variables:
    ld a, 0
    ld (player_xcoordinate), a
    ld (bullet_xcoordinate), a
    ld (bullet_ycoordinate), a
    ld (del_bullet_xcoordinate), a
    ld (del_bullet_ycoordinate), a
    ld (is_shooting), a
    ld hl, 0
    ld (score), hl
    ld a, 232
    ld (fighter_xcoordinate), a
    ld a, 32
    ld (fighter_ycoordinate), a
    ld a, 166
    ld (player_ycoordinate), a
    ret

display_timer_if_necessary:
    ld hl, (timer)
    ld a,l
    cp 0
    ret nz
    call show_timer_bar
    ld de, (timer)
    ld h,0
    ld l,d
    call display_num
    ret

display_score_bar:
    call show_score_bar
    ld hl, (score)
    call display_num
    ret

draw_grass:
    ld c,232
    ld b, 191 - 8
draw_grass_loop:
    ld hl,grass_sprite
    push bc
    call draw_static_sprite
    pop bc
    ld a, c
    sub 16
    ld c,a
    jr nc, draw_grass_loop
    ld c,0
    ld b, 191 - 8
    ld hl,grass_sprite
    call draw_static_sprite
    ret

    include "data.asm"
    include "sprites.asm"
    include "messages.asm"

lenght        equ     $-begin

code	=	#af
usr	=	#c0
load	=	#ef
clear	=	#fd
randomize =	#f9

    org	#5c00
baszac	db	0,1			;; line number
	dw	linlen			;; line length
linzac
	db	clear,'32768',#0e,0,0
    dw 32768
	db	0,':'
	db	load,'"'
codnam	ds	10,32
	org	codnam
	db	"code"
	org	codnam+10
	db	'"',code,':'
	db	randomize,usr,'32768',#0e,0,0
    dw 32768
	db	0,13
linlen	=	$-linzac
baslen	=	$-baszac
	
    emptytap "game.tap"
    savetap  "game.tap",basic,"test-game",baszac,baslen,1
    savetap "game.tap",code,"code",begin, lenght
    SAVESNA "game.sna", begin

