;############### Macro Includes ###############################################

; Utility Includes
.include "include/util.s"
.include "include/ppu.s"
.include "include/apu.s"

; Decay Includes
.include "decay/header.s"
.include "decay/macros.s"

;############### Constants & Variables ########################################

;############### iNES Header ##################################################
.segment "HEADER"    
.byte "NES", $1A	; iNES header identifier
.byte 2			; 2x 16KB PRG code
.byte 1			; 1x  8KB CHR data
.byte 1 		; Vertical Mirroring
.byte 0 		; Mapper 0 (no mapper)

;############### iNES Header ##################################################
.segment "VECTORS"
.word 0, 0, 0, nmi, reset, 0

.segment "STARTUP"
.segment "CODE"

;############### Library Includes #############################################
reset: .include "include/reset.s"

;############### Main Program #################################################
main:
	; Initialize the audio engine
	DecayInit
	;DecaySetPeriod DecayChannel::Square1, 16
	;DecaySetPeriod DecayChannel::Triangle, 32

	; Set a nice blue background and begin rendering
	jsr set_palette
	enable_rendering
	loop_forever


;############### NMI ##########################################################
nmi:
	rti

;############### Suboutines ###################################################

.include "decay/engine.s"


set_palette:
	vram #$3f, #$00
	ldx #0
@loop:	lda @pal, x
	sta PPU_DATA
	inx
	cpx #4
	bne @loop
	rts
@pal:	.byte $03, $00, $10, $20



;############### Songs ########################################################

scale: .include "songs/scale.s"


;############### Pattern Tables ###############################################
.segment "CHARS"

; Clear Pattern
.byte $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00
