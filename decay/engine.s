; engine.s
; Decay Audio Engine
; By Ryan Sandor Richards


; Initializes the Decay Audio Engine.
decay_init:
	; Zero out the engine state page
	lda #0
	ldx #$ff
@loop:	sta DECAY_PAGE, x
	dex
	bne @loop

	; Enable and initialize all audio channels
	DecayUnmute

	lda #%01111111
	sta DECAY_SQ1_ENV
	sta DECAY_SQ2_ENV

	lda #%11111111
	sta DECAY_TRI_CTRL

	rts


; Loads a song into the engine.
;
; Arguments:
;  $00 - Lobyte of the song address
;  $01 - Hibyte of the song address
decay_load_song:
.scope
	; Params
	song_lo		= $00
	song_hi		= $01

	; Local Variables
	addr_lo 	= $10
	addr_hi 	= $11
	num_patterns	= $12
	pattern_lo	= $13
	pattern_hi	= $14
	offset		= $15

	; Stores the value at [($00), Y] into the given address.
	.macro Store address
		lda (addr_lo), y
		sta address
	.endmacro

	; Loads the value at the offset y of the current
	; address, stores it at the given address and
	; increments y
	.macro StoreAndInc address
		lda (addr_lo), y
		sta address
		iny
	.endmacro




	; Copy the song address into the "current" address
	lda song_lo
	sta addr_lo
	lda song_hi
	sta addr_hi
		
	; Read the song
	ldy #0

	; Skip song format (for now)
	; In the future we'd branch from here to load songs of different
	; formats. Since there is only one format at this time we don't
	; really need to do much.
	iny 

	; Clock Add
	StoreAndInc DECAY_CLOCK_ADD

	; Pattern Size
	StoreAndInc DECAY_PATTERN_SIZE

	; Instruments
	; Skip for now, always assume $00
	iny

	; Reset the matrix position
	lda #0
	sta DECAY_MATRIX_POS

	; Pattern Matrix Size
	StoreAndInc DECAY_MATRIX_SIZE

	; Store the Pattern Matrix Address
	clc
	tya
	adc addr_lo
	bcc :+
	inc addr_hi
:	sta addr_lo
	ldy #0

	lda addr_lo
	sta DECAY_MATRIX_LO
	lda addr_hi
	sta DECAY_MATRIX_HI

	; Skip the matrix bytes
	; Let K = DECAY_MATRIX_SIZE, then
	; 5K = 4K + K = (K << 2) + K = ((K << 1) << 1) + K
	lda DECAY_MATRIX_SIZE
	asl
	asl
	clc
	adc DECAY_MATRIX_SIZE
	adc addr_lo
	bcc :+
	inc addr_hi
:	sta addr_lo

	; Reset the pattern address
	lda DECAY_PATTERN1_LO
	sta pattern_lo
	lda DECAY_PATTERN1_HI
	sta pattern_hi

	; Number of patterns
	Store num_patterns
	inc addr_lo
	bcc @outer
	inc addr_hi

	; Loop through patterns, storing addresses in the pattern banks
@outer:	; PatternAddress <- Current Address
	lda addr_lo
	sta pattern_lo
	lda addr_hi
	sta pattern_hi

	; Pattern Address += 2
	lda #2
	adc pattern_lo
	sta pattern_lo
	lda #2
	adc pattern_hi
	sta pattern_hi

	; Skip through the five channels of the pattern
	ldx #5
@inner:	; A <- number of notes in the pattern's channel
	lda (addr_lo), y
	; Skip the current address ahead 4*A + 1 notes 
	asl
	asl
	adc #1
	adc addr_lo
	bcc :+
	inc addr_hi
:	sta addr_lo
	dex
	bne @inner

	; Repeat unless we've exhausted the patterns
	dec num_patterns
	bne @outer

	; Once all the patterns have been read, we're done!
	rts
.endscope


; Sets the period for an APU channel (Square 1, etc.).
;
; Arguments:
;   $00 - Lobyte of the APU control register to set
;   $01 - Hibyte of the APU control register to set
;   $02 - Index of the note we wish to set
decay_set_period:
	DecayPushXY
	ldx $02
	ldy #0
	lda @lo, x
	sta ($00), y
	inc $00
	lda @hi, x
	sta ($00), y
	DecayPullXY
	rts
@lo:	.byte $00
	.byte $f1,$7f,$13,$ad,$4d,$f3,$9d,$4c,$00,$b8,$74,$34
	.byte $f8,$bf,$89,$56,$26,$f9,$ce,$a6,$80,$5c,$3a,$1a
	.byte $fb,$df,$c4,$ab,$93,$7c,$67,$52,$3f,$2d,$1c,$0c
	.byte $fd,$ef,$e1,$d5,$c9,$bd,$b3,$a9,$9f,$96,$8e,$86
	.byte $7e,$77,$70,$6a,$64,$5e,$59,$54,$4f,$4b,$46,$42
	.byte $3f,$3b,$38,$34,$31,$2f,$2c,$29,$27,$25,$23,$21
	.byte $1f,$1d,$1b,$1a,$18,$17,$15,$14,$00,$00,$00,$00
@hi:	.byte $00
	.byte $07,$07,$07,$06,$06,$05,$05,$05,$05,$04,$04,$04
	.byte $03,$03,$03,$03,$03,$02,$02,$02,$02,$02,$02,$02
	.byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00



