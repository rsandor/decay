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
.proc DecayLoadSongSub
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
	; need to do this :)
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
.endproc



; Plays the song. Should be called every frame (either via NMI or custom
; frame handling routines).
decay_play_song:
.proc
	; Local Variables
	matrix_lo 	= $10
	matrix_hi 	= $11
	pattern_lo	= $12
	pattern_hi	= $13
	

	; Inline macro for handling the playing of a channel
	.macro PlayChannel flag, apu, channel
		; Skip if the channel if it is off
		lda DECAY_FLAGS
		and #flag
		beq :++

		; Skip unless we've reached the next position
		lda channel + $02
		cmp DECAY_PATTERN_POS
		bne :++

		; Load the pattern address into the zero page
		lda channel
		sta pattern_lo
		lda channel + $01
		sta pattern_hi

		ldy #1

		; Set the period
		lda #.LOBYTE(apu + $02)
		sta $00
		lda #.HIBYTE(apu + $02)
		sta $01
		lda (pattern_lo), y
		sta $02
		jsr decay_set_period
		iny

		; Skip the instrument (for now)
		iny

		; Set the environment
		lda (pattern_lo), y
		sta apu
		iny

		; Set the next position
		lda (pattern_lo), y
		sta addr + $02

		; Advance the pattern pointer
		tya
		clc
		adc pattern_lo
		bcc :+
		inc pattern_hi
	:	sta addr
		lda pattern_lo
		sta addr+1
	:
	.endmacro


	; Tempo Clock
	clc
	lda DECAY_CLOCK_ADD
	adc DECAY_CLOCK
	bcc advance_frame

	PlayChannel DECAY_FLAG_SQUARE1, DECAY_APU_SQUARE1_ENV, DECAY_SQUARE1_PATTERN_LO
	; PlayChannel 2, DECAY_SQ2_LO, DECAY_SQUARE2_PATTERN_LO
	; PlayChannel 4, DECAY_TRI_LO, DECAY_TRIANGLE_PATTERN_LO

advance_position:
	clc
	lda DECAY_PATTERN_POS
	adc #1
	cmp DECAY_PATTERN_SIZE
	bne advance_frame
	
advance_matrix:
	lda DECAY_MATRIX_POS
	adc #1
	cmp DECAY_MATRIX_SIZE
	bne :+
	lda #0
:	sta DECAY_MATRIX_POS

	; Load the patterns
	tay
	lda DECAY_MATRIX_LO
	sta matrix_lo
	lda DECAY_MATRIX_HI
	sta matrix_hi

	; Square 1 Pattern
	sty #0
	
	lda (matrix_lo), y
	asl
	tax
	lda DECAY_PATTERN, x
	sta pattern_lo
	lda DECAY_PATTERN + 1, x
	sta pattern_hi
 
	; Set the pattern pointer
	lda pattern_lo
	adc #1
	bcc :+
	inc pattern_hi
:	sta DECAY_SQUARE1_PATTERN_LO
	lda pattern_hi
	sta DECAY_SQUARE1_PATTERN_HI

	; Set the next position
	sty #0
	lda (pattern_lo), y
	sta DECAY_SQUARE1_NEXT_POS

	
	; Square 2 pattern
	sty #1
	; ...


advance_frame:
	; TODO Implement me (used for instruments)

.endproc
	rts


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



