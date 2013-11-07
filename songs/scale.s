.scope


;################### Note Refs ################################################
	
	REST = 0
	C3 = 16
	D3 = 18
	E3 = 20
	F3 = 21
	G3 = 23
	A4 = 25
	B4 = 27
	C4 = 28


;################### Header ###################################################

	; Decay Song Format Version (1 byte)
	.byte $00

	; Initial Clock Add (Speed)
	.byte $07 ; ~100 BPM

	; Pattern Size
	.byte $10

;################### Instruments ##############################################

	; Number of instruments to load
	.byte $00


;################### Pattern Matrix ###########################################

	; Number of entries in the matrix
	.byte $02 

	; Matrix Definition
	; Byte order: Square1, Square2, Triangle, Noise, DMC
	.byte $00, $00, $00, $00, $00
	.byte $01, $00, $00, $00, $00


;################### Patterns #################################################

	; Number of Patterns (Max: 32 or $20)
	.byte $02



;################### Pattern 1 ################################################

	; Square 1 Channel

	; Square 1 entries
	.byte $08

	;
	; Each square channel note is 4-byte entry, like so:
	; 
	; Byte 1: Position
	; Byte 2: Period Index (see decay_set_period routine)
	; Byte 3: Instrument
	;         D---IIII 
	;         |   |
	;         |   +--- Instrument Index
	;         +------- Disable (0: enabled, 1: disabled)
	; Byte 4: Environment
	;         CC--VVVV
	;         |   |
	;         |   +--- Volume
	;         +------- Duty Cycle
	;
	.byte $00, C3, $80, %01000111
	.byte $02, D3, $80, %01000111
	.byte $04, E3, $80, %01000111
	.byte $06, F3, $80, %01000111
	.byte $08, G3, $80, %01000111
	.byte $0A, A4, $80, %01000111
	.byte $0C, B4, $80, %01000111
	.byte $0E, C4, $80, %01000111

	; Square 2 Channel
	.byte $04
	.byte $00, C4, $80, %00011111
	.byte $04, A4, $80, %00011111
	.byte $08, F3, $80, %00011111
	.byte $0C, C3, $80, %00011111

	; Triangle Channel
	.byte $02

	;
	; Each triangle channel note is 4-byte entry, like so:
	; 
	; Byte 1: Position
	; Byte 2: Period Index (see decay_set_period routine)
	; Byte 3: D---IIII
	;         |   |
	;         |   +--- Instrument Index
	;         +------- Disable (0: enabled, 1: disabled)
	; Byte 4: -------V
	;                |
	;                +- Volume (0: off, 1: full)
	;
	.byte $00, C3, $80, $01
	.byte $00, G3, $80, $01


	; Noise Channel
	.byte $00

	; DMC Channel
	.byte $00


;################### Pattern 1 ################################################

	.byte $08
	.byte $00, C3, $80, %00011111
	.byte $02, E3, $80, %00011111
	.byte $04, D3, $80, %00011111
	.byte $06, F3, $80, %00011111
	.byte $08, E3, $80, %00011111
	.byte $0A, G3, $80, %00011111
	.byte $0C, F3, $80, %00011111
	.byte $0E, A4, $80, %00011111

	.byte $04
	.byte $00, C3, $80, %00011111
	.byte $04, G3, $80, %00011111
	.byte $08, C3, $80, %00011111
	.byte $0C, G3, $80, %00011111

	.byte $02
	.byte $00, C3, $80, $01
	.byte $00, G3, $80, $01

	.byte $00, $00


.endscope