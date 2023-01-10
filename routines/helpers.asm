rom_open_channel equ #1601
rom_upper_screan_id equ 2

; param hl = null terminated string
show_message:
        push hl
        ld a,rom_upper_screan_id
        call rom_open_channel
        pop hl
next_character:
        ld a,(hl)
        or a
        ret z
        rst #10
        inc hl
        jr next_character

show_score_bar:
        ld a,rom_upper_screan_id
        call rom_open_channel
        ld hl,score_message
        jp next_character

show_timer_bar:
        ld a,rom_upper_screan_id
        call rom_open_channel
        ld hl,timer_message
        jp next_character

;  number in hl
display_num:
        call num2_dec
        ld a,rom_upper_screan_id
        call rom_open_channel
        ld hl,num_as_string
        jp next_character


; de should contain the addres convert to 
; hl is the number to display
num2_dec:
	ld de, num_as_string
        ld bc,-10000
        call num1
        ld bc,-1000
        call num1
        ld bc,-100
        call num1
        ld c,-10
        call num1
        ld c,b

num1:
        ld a,'0'-1
num2:   inc a
        add hl,bc
        jr c,num2 
        sbc hl,bc
        ld (de),a
        inc de
        ret

get_random_number:
        push    hl
        push    de
        ld      hl,(rand_data)
        ld      a,r
        ld      d,a
        ld      e,(hl)
        add     hl,de
        add     a,l
        xor     h
        ld      (rand_data),hl
        pop     de
        pop     hl
        ret

rand_data	dw 0
num_as_string db	32,32,32,32,32,0
score_message:
  db at,1,1
  db bright, 1
  db ink,7
  db "SCORE: "
  db 0  

timer_message:
  db at,1,21
  db bright, 1
  db ink,7
  db "TIME: "
  db 0  
