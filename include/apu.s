; NES Audio Processing Unit (APU) Constants and Macros
; By Ryan Sandor Richards
; Adapted from the "Nerdy Nights" sounds tutorials
; http://www.nintendoage.com/forum/messageview.cfm?catid=22&threadid=7155

; Audio Processing Unit Flags
;
; 76543210
;    |||||
;    ||||+- Square 1 (0: disable; 1: enable)
;    |||+-- Square 2
;    ||+--- Triangle
;    |+---- Noise
;    +----- DMC
APU_FLAGS = $4015

; Square 1 Environment
;
; 76543210
; ||||||||
; ||||++++- Volume
; |||+----- Saw Envelope Disable (0: use internal counter for volume; 1: use Volume for volume)
; ||+------ Length Counter Disable (0: use Length Counter; 1: disable Length Counter)
; ++------- Duty Cycle
;		00 - 12.5%
;		01 - 25.0%
;		10 - 50.0%
;		11 - 25.0% negated
SQ1_ENV = $4000

; Square 1 Sweep
; TODO Document me
SQ1_SWEEP = $4001

; Square 1 Period Low Bits
;
; 76543210
; ||||||||
; ++++++++- Low 8-bits of period
SQ1_LO = $4002

; Square 1 Period High Bits + Length Counter
;
; 76543210
; ||||||||
; |||||+++- High 3-bits of period
; +++++---- Length Counter
SQ1_HI = $4003

; Square 2 Environment
;
; 76543210
; ||||||||
; ||||++++- Volume
; |||+----- Saw Envelope Disable (0: use internal counter for volume; 1: use Volume for volume)
; ||+------ Length Counter Disable (0: use Length Counter; 1: disable Length Counter)
; ++------- Duty Cycle
SQ2_ENV = $4004

; Square 2 Sweep
; TODO Document me
SQ2_SWEEP = $4005

; Square 2 Period Low Bits
;
; 76543210
; ||||||||
; ++++++++- Low 8-bits of period
SQ2_LO = $4006

; Square 2 Period Hight Bits + Length Counter
;
; 76543210
; ||||||||
; |||||+++- High 3-bits of period
; +++++---- Length Counter
SQ2_HI = $4007

; Triangle Control
;
; 76543210
; ||||||||
; |+++++++- Value
; +-------- Control Flag (0: use internal counters; 1: disable internal counters)
TRI_CTRL = $4008

; Triangle Low Bits
;
; 76543210
; ||||||||
; ++++++++- Low 8-bits of period
TRI_LO = $400a

; Triangle High Bits + Length Counter
;
; 76543210
; ||||||||
; |||||+++- High 3-bits of period
; +++++---- Length Counter
TRI_HI = $400b