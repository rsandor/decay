; NES Programming Utility Library
; By Ryan Sandor Richards

; Loops forever (aka while 1)
; Example:
;	loop_forever
.macro loop_forever
.scope
@__forever_loop:
	jmp @__forever_loop
.endscope
.endmacro

; Places the 16-bit address for the given label
; into the zero page at $00 (lo) and $01 (hi).
.macro addr label
	pha
	lda #.LOBYTE(label)
	sta $00
	lda #.HIBYTE(label)
	sta $01
	pla
.endmacro

; Places the 16-bit addresses for two given labels
; into the zero page at $00 through $03.
.macro addr2 l1, l2
	pha
	lda #.LOBYTE(l1)
	sta $00
	lda #.HIBYTE(l1)
	sta $01
	lda #.LOBYTE(l2)
	sta $02
	lda #.HIBYTE(l2)
	sta $03
	pla
.endmacro

