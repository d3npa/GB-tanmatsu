SECTION "library", ROM0[$0500]

__wait_vblank:
	; LCDの書き込みが終わるまでループする
	ld	a, [$FF44]	; LCDC Y座標
	cp	$91
	jr	nz, __wait_vblank
	ret

__nullka:
	; deからbcバイトをヌル化する
	ld	a, b
	or	c
	jr	z, .return
	ld	a, 0
	ld	[de], a
	dec	bc
	inc	de
	jr	__nullka
.return:
	ld	bc, 0
	ld	de, 0
	ret

__memcpy:
	; hlからdeにbcバイトをコピーする
	ld	a, b
	or	c
	jr	z, .return
	ld	a, [hl]
	ld	[de], a
	dec	bc
	inc	de
	inc	hl	
	jr	__memcpy
.return:
	ld	bc, 0
	ld	de, 0
	ld	hl, 0
	ret

__delay:
	ld	bc, $8000
.loop:
	dec	bc
	ld	a, c
	or	b
	jr	nz, .loop
	ret

screen_on:
	; LCDをオンにする
	ld	a, %10010011
	ld	[$FF40], a
	call 	__wait_vblank
	ret

screen_off:
	; LCDが既にオフになっていたら抜ける
	ld	a, [$FF44]	; LCDC Y座標
	rlca
	ret	nc

	call	__wait_vblank

	; LCDをオフにする
	ld	a, %00010011
	ld	[$FF40], a
	ret


screen_reset:
	call	screen_off

	; VRAM領域をヌル化
	ld	bc, $1fff
	ld	de, $8000
	call	__nullka

	; OAM領域をヌル化
	ld	bc, 4*40
	ld	de, $FE00
	call	__nullka

	; タイルテーブルを読み込み
	ld	bc, 16*256
	ld	de, $8000
	ld	hl, Tiles
	call	__memcpy
	ret

write:
	; 0xFFを読み込むまで出力する
	; de	文字列
	ld	bc, $9800+1*01+32*01
	ld	hl, 0
.read_byte:
	ld	a, [de]
	cp	$FF
	jr	z, .return	; 終了文字
	cp	$FE
	jr	z, .kaigyou	; 改行文字
	cp	$FD
	jr	z, .fukki	; 復帰文字
	cp	$AE
	jr	z, .dakuten
	cp	$AF
	jr	z, .dakuten
	jr	.write_byte
.kaigyou:
	ld	a, c
	add	64
	ld	c, a
	ld	a, b
	adc	0
	ld	b, a
	inc	de
	jr	.read_byte
.fukki:
	ld	a, c
	and	%11100000
	inc	a
	ld	c, a
	inc	de
	jr	.read_byte
.dakuten:
	ld	h, a
	inc	de
	jr	.read_byte
.write_byte:
	; 濁点か空を本行に出力
	ld	a, h
	ld	[bc], a
	; hlを次の行にし
	ld	a, c
	add	32
	ld	l, a
	ld	a, b
	adc	0
	ld	h, a
	; hlに文字を出力
	ld	a, [de]
	ld	[hl], a
	; 片付け
	inc	bc
	inc	de
	ld	hl, 0
	jr	.read_byte
.return
	ld	bc, 0
	ld	de, 0
	ld	hl, 0
	ret

read: 
	; ボタンの状況をbレジスタに読み込む
	; ↓ ↑ ← → start select B A
	ld	a, %00100000
	ld	[$FF00], a
	ld	a, [$FF00]
	ld	a, [$FF00]
	ld	a, [$FF00]
	ld	a, [$FF00]
	and	$0F
	swap	a
	ld	b, a
	ld	a, %00010000
	ld	[$FF00], a
	ld	a, [$FF00]
	ld	a, [$FF00]
	ld	a, [$FF00]
	ld	a, [$FF00]
	and	$0F
	or	a, b
	ld	b, a
	ret
