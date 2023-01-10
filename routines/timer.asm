reset_timer:
    ld h,60
    ld l,0
    ld (timer), hl
    ret

timer_event:
    ld hl, (timer)
    ld a, l
    cp 255
    jr nz, continue_count_down
    ld l, 50
continue_count_down:
    dec hl
    ld (timer), hl
    ret

has_timer_expired:
    ld hl, (timer)
    ld a,h
    or l 
    ret   

timer dw 0
