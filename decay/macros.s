; macros.s
; Decay Audio Engine
; By Ryan Sandor Richards


;################### Utility Macros ###########################################

; Sets a full 16-bit address into the ($00, $01)the zero page.
.macro DecayAddr address
	lda #.LOBYTE(address)
	sta $00
	lda #.HIBYTE(address)
	sta $01
.endmacro

; Pushes the X and Y Register to the stack
.macro DecayPushXY
	txa
	pha
	tya
	pha
.endmacro

; Pulls the X and Y registers from the stack
.macro DecayPullXY
	pla
	tay
	pla
	tax
.endmacro

; Pushes the A, X, and Y registers onto the stack
.macro DecayPushAXY
	pha
	txa
	pha
	tya
	pha
.endmacro

; Pulls the Y, X, and A registers from the stack
.macro DecayPullAXY
	pla
	tay
	pla
	tax
	pla
.endmacro

;################### APU Flag Macros ##########################################


; Toggles a given APU audio channel
.macro DecayToggleChannel channel
.if channel = DecayChannel::Square1
	lda #%00000001
.elseif channel = DecayChannel::Square2
	lda #%00000010
.elseif channel = DecayChannel::Triangle
	lda #%00000100
.elseif channel = DecayChannel::Noise
	lda #%00001000
.else
	.error "DecayToggleChannel: Unknown channel"
.endif
	eor DECAY_FLAGS
	sta DECAY_FLAGS
	sta DECAY_APU_FLAGS
.endmacro

; Turns on all audio channels
.macro DecayUnmute
	lda #%00011111
	sta DECAY_FLAGS
	sta DECAY_APU_FLAGS
.endmacro

; Turns off all audio channels
.macro DecayMute
	lda #%00000000
	sta DECAY_FLAGS
	sta DECAY_APU_FLAGS
.endmacro



;################### Subroutine Macros ########################################

; Initializes the audio engine
.macro DecayInit
	jsr decay_init
.endmacro

; Sets the wave period for a channel
.macro DecaySetPeriod channel, index
.if channel <> DecayChannel::Noise
	DecayAddr channel
	lda #index
	sta $02
	jsr decay_set_period
.else
	lda #index
	sta channel
.endif
.endmacro

; Loads a song into the engine
.macro DecayLoadSong
	
.endmacro