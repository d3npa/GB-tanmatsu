mov: MACRO
	ld	a, \2
	ld	\1, a
ENDM

display_menu:
        call	screen_reset
    
	; 矢印を表示する (OAM領域)
	mov		[$FE00], 16+8*2	; Y座標
	mov		[$FE01], 8+8*2 	; X座標
	mov		[$FE02], $B7    ; 矢印のタイルID
	mov		[$FE03], 0      ; 属性？？

	ld		de, str_mainmenu
	call	write
	call 	screen_on
.read_btn:
        call    __wait_vblank
	call	read            ; ↓ ↑ ← → start select B A
	ld	a, b
        and     %01000000
        jr      z, .key_up
	ld	a, b
        and     %10000000
        jr      z, .key_down
        jr      .loop
.key_up:
        ld      a, [$FE00]
        cp      16+8*2
        jr      z, .read_btn
        ld      a, [$FE00]
        sub     a, 16
        ld      [$FE00], a
        jr      .loop
.key_down:
        ld      a, [$FE00]
        cp      16+8*6
        jr      z, .read_btn
        ld      a, [$FE00]
        add     a, 16
        ld      [$FE00], a
        jr      .loop
.loop:
        call    __delay
        jr      .read_btn
	halt
