; NES Picture Processing Unit (PPU) Constants and Macros
; By Ryan Sandor Richards

; PPU Registers

; Controller ($2000) > write
;
; 7654 3210
; |||| ||||
; |||| ||++- Base nametable address
; |||| ||    (0 = $2000; 1 = $2400; 2 = $2800; 3 = $2C00)
; |||| |+--- VRAM address increment per CPU read/write of PPUDATA
; |||| |     (0: add 1, going across; 1: add 32, going down)
; |||| +---- Sprite pattern table address for 8x8 sprites
; ||||       (0: $0000; 1: $1000; ignored in 8x16 mode)
; |||+------ Background pattern table address (0: $0000; 1: $1000)
; ||+------- Sprite size (0: 8x8; 1: 8x16)
; |+-------- PPU master/slave select
; |          (0: read backdrop from EXT pins; 1: output color on EXT pins)
; +--------- Generate an NMI at the start of the
;            vertical blanking interval (0: off; 1: on)
;
; Equivalently, bits 0 and 1 are the most significant bit of the scrolling 
; coordinates (see Nametables and PPU scroll):
;
; 7654 3210
;        ||
;        |+- 1: Add 256 to the X scroll position
;        +-- 1: Add 240 to the Y scroll position
PPUCTRL 	= $2000

; Mask ($2001) > write
;
; 76543210
; ||||||||
; |||||||+- Grayscale (0: normal color; 1: produce a monochrome display)
; ||||||+-- 1: Show background in leftmost 8 pixels of screen; 0: Hide
; |||||+--- 1: Show sprites in leftmost 8 pixels of screen; 0: Hide
; ||||+---- 1: Show background
; |||+----- 1: Show sprites
; ||+------ Intensify reds (and darken other colors)
; |+------- Intensify greens (and darken other colors)
; +-------- Intensify blues (and darken other colors)
PPUMASK 	= $2001


; Status ($2002) < read
;
; 7654 3210
; |||| ||||
; |||+-++++- Least significant bits previously written into a PPU register
; |||        (due to register not being updated for this address)
; ||+------- Sprite overflow. The intent was for this flag to be set
; ||         whenever more than eight sprites appear on a scanline, but a
; ||         hardware bug causes the actual behavior to be more complicated
; ||         and generate false positives as well as false negatives; see
; ||         PPU sprite evaluation. This flag is set during sprite
; ||         evaluation and cleared at dot 1 (the second dot) of the
; ||         pre-render line.
; |+-------- Sprite 0 Hit.  Set when a nonzero pixel of sprite 0 overlaps
; |          a nonzero background pixel; cleared at dot 1 of the pre-render
; |          line.  Used for raster timing.
; +--------- Vertical blank has started (0: not in VBLANK; 1: in VBLANK).
;            Set at dot 1 of line 241 (the line *after* the post-render
;            line); cleared after reading $2002 and at dot 1 of the
;            pre-render line.
PPUSTATUS	= $2002

; OAM address ($2003) > write / OAM data ($2004) > write
; Set the "sprite" address using OAMADDR ($2003)
; Then write the following bytes via OAMDATA ($2004)

; - Byte 0 (Y Position)

; - Byte 1 (Tile Index)
;
; 76543210
; ||||||||
; |||||||+- Bank ($0000 or $1000) of tiles
; +++++++-- Tile number of top of sprite (0 to 254; bottom half gets the next tile)

; - Byte 2 (Attributes)
;
; 76543210
; ||||||||
; ||||||++- Palette (4 to 7) of sprite
; |||+++--- Unimplemented
; ||+------ Priority (0: in front of background; 1: behind background)
; |+------- Flip sprite horizontally
; +-------- Flip sprite vertically

; - Byte 3 (X Position)

OAMADDR		= $2003
OAMDATA		= $2004

; Scroll ($2005) >> write x2
; http://wiki.nesdev.com/w/index.php/The_skinny_on_NES_scrolling#2006-2005-2005-2006_example
PPUSCROLL	= $2005

; Address ($2006) >> write x2
PPUADDR		= $2006

; Data ($2007) <> read/write
PPUDATA		= $2007

; Easily readable versions:
PPU_CTRL 	= $2000
PPU_MASK 	= $2001
PPU_STATUS	= $2002
OAM_ADDR	= $2003
OAM_DATA	= $2004
PPU_SCROLL	= $2005
PPU_ADDR	= $2006
PPU_DATA	= $2007


; Nametable addresses

NAMETABLE_A = $2000
NAMETABLE_B = $2400
NAMETABLE_C = $2800
NAMETABLE_D = $2c00

; Attribute table addresses

ATTR_A = $23c0
ATTR_B = $27c0
ATTR_C = $2bc0
ATTR_D = $2fc0


; Emables NMI, Sprite & Background Rendering
; Example:
;	enable_rendering	
.macro enable_rendering
	pha
	
	; Set Nametable and NMI
	lda #%10000000
	sta PPU_CTRL

	; Show sprites and backgound
	lda #%00011110
	sta PPU_MASK

	pla
.endmacro


; Enables the NMI
; Example:
;	enable_nmi
.macro enable_nmi
	pha 
	lda #%10000000
	sta PPU_CTRL
	pla
.endmacro


; Sets the VRAM address using a high byte and low byte
; Example:
;	vram #$24, #$00
.macro vram hi, lo
	pha
	lda hi
	sta PPU_ADDR
	lda lo
	sta PPU_ADDR
	pla
.endmacro


; Sets VRAM address given a full 16-bit address
; Example:
; 	vram $23c0
.macro vram_addr address
	pha
	lda #.HIBYTE(address)
	sta PPU_ADDR
	lda #.LOBYTE(address)
	sta PPU_ADDR
	pla
.endmacro

; Sets vram to point to a specific column and row in the given nametable
; 
.macro vram_xy col, row, nametable
	pha
	vram_addr (nametable + row*$20 + col)
	pla
.endmacro


; Resets the VRAME address to 0
; Example:
;	vram_reset
.macro vram_reset
	pha
	lda #0
	sta PPU_ADDR
	sta PPU_ADDR
	pla
.endmacro

; Resets OAM Address to 0
.macro oam_reset
	pha
	lda #0
	sta OAM_ADDR
	pla
.endmacro

; Loads a color palette starting at the given address
; Example
;	load_palette my_palette
.macro load_palette address
.scope
	PALETTE_LEN = 4 * 8
	pha
	txa
	pha
	vram #$3f, #$00
	ldx #0
@__load_palette_loop:	
	lda address, x
	sta PPU_DATA
	inx
	cpx #PALETTE_LEN
	bne @__load_palette_loop
	pla
	tax
	pla
.endscope
.endmacro



; Loads a nametable consisting of 32x30 (960) bytes. One can also
; specify an optional attributes table as well.
; Example
;	vram_nametable_a
;	load_nametable my_nametable, my_attributes
.macro load_nametable nametable_label, attr_label
.scope
	pha
	txa
	pha
	tya
	pha

	lobyte = $fe
	hibyte = $ff
	last_length = $c0
	attr_length = $40

	lda #.LOBYTE(nametable_label)
	sta lobyte
	lda #.HIBYTE(nametable_label)
	sta hibyte

	ldx #0
	ldy #0
@__load_nametable_loop:
	lda (lobyte), y
	sta PPU_DATA
	cpx #3
	beq @__load_nametable_cmp_alt
	iny
	bne @__load_nametable_loop
	jmp @__load_nametable_next
@__load_nametable_cmp_alt:
	cpy #last_length
	bne @__load_nametable_loop
@__load_nametable_next:
	inx
	cpx #4
	bne @__load_nametable_loop


.if attr_label
	ldx #0
@__load_nametable_loop2:
	lda attr_label, x
	sta PPU_DATA
	inx
	cpx #attr_length
	bne @__load_nametable_loop2
	rts
.endif

	pla
	tay
	pla
	tax
	pla
.endscope
.endmacro


; Palette, Nametable & Attr Table Address Macros
.macro vram_palette
	vram #$3f, #$00
.endmacro

.macro vram_nametable_a
	vram #$20, #$00
.endmacro

.macro vram_nametable_b
	vram #$24, #$00
.endmacro

.macro vram_nametable_c
	vram #$28, #$00
.endmacro

.macro vram_nametable_d
	vram #$2C, #$00
.endmacro

.macro vram_attr_table_a
	vram #$23, #$c0
.endmacro

.macro vram_attr_table_b
	vram #$27, #$c0
.endmacro

.macro vram_attr_table_c
	vram #$2b, #$c0
.endmacro

.macro vram_attr_table_d
	vram #$2f, #$c0
.endmacro

