;***********************************************************
;*	This is the skeleton file for Lab 3 of ECE 375
;*
;*	 Author: Enter your name
;*	   Date: Enter date
;*
;***********************************************************

.include "m32U4def.inc"			; Include definition file

;***********************************************************
;*	Internal Register Definitions and Constants
;***********************************************************
.def	mpr = r16				; Multipurpose register is required for LCD Driver
.def	counter = r17
.equ	PD_seven = 7
.equ	PD_five = 5
.equ	PD_four = 4
;***********************************************************
;*	Start of Code Segment
;***********************************************************
.cseg							; Beginning of code segment

;***********************************************************
;*	Interrupt Vectors
;***********************************************************
.org	$0000					; Beginning of IVs
		rjmp INIT				; Reset interrupt

.org	$0056					; End of Interrupt Vectors

;***********************************************************
;*	Program Initialization
;***********************************************************
INIT:							; The initialization routine

		ldi	mpr, low(RAMEND)	; Initialize Stack Pointer
		out SPL, mpr
		ldi mpr, high(RAMEND)
		out SPH, mpr

		rcall LCDInit			; Initialize LCD Display

        ; Initialize Port D for input
		ldi		mpr, $00		; Set Port D Data Direction Register
		out		DDRD, mpr		; for input
		ldi		mpr, $FF		; Initialize Port D Data Register
		out		PORTD, mpr		; so all Port D inputs are Tri-State

        ;Setting our counter to 9
        ldi counter, 13


;***********************************************************
;*	Main Program
;***********************************************************
MAIN:							; The Main program
		; Main function design is up to you. Below is an example to brainstorm.
        in		mpr, PIND		; Get input from Port D
		andi	mpr, (1<<PD_five|1<<PD_four)
		cpi		mpr, (1<<PD_five)	; Check for button d5
		brne	NEXT			; If five is not pressed wait
		rcall	PRINT		; Call the subroutine HitRight
		rjmp	MAIN			; Continue through main 
NEXT:
        cpi		mpr, (1<<PD_four)	; Check for Left Whisker input (Recall Active)
		brne	MAIN			; No Whisker input, continue program
		rcall	CLEAR			; Call subroutine HitLeft
		rjmp	MAIN			; Continue through main
;***********************************************************
;*	Functions and Subroutines
;***********************************************************

;-----------------------------------------------------------
; Func: Template function header
; Desc: Cut and paste this and fill in the info at the
;		beginning of your functions
;-----------------------------------------------------------
PRINT:	
        ;strings from program mem to data mem
        ldi ZL, low(STRING_BEG_L2<<1)
		ldi ZH, high(STRING_BEG_L2<<1)

        ;pointing y to address of line1
        ldi YL, $00
		ldi YH, $01


        ;load from program memory
        lpm mpr, Z+
		st Y+, mpr
		dec counter
		brne PRINT

        rcall LCDWrLn1


		ret						; End subroutine

CLEAR:
        rcall LCDClr            ;Clear LCD
        ret                     ;End subroutine
;***********************************************************
;*	Stored Program Data
;***********************************************************

;-----------------------------------------------------------
; An example of storing a string. Note the labels before and
; after the .DB directive; these can help to access the data
;-----------------------------------------------------------
STRING_BEG:
.DB		"Paul and Ryan"		; Declaring data in ProgMem
STRING_END:

;***********************************************************
;*	Additional Program Includes
;***********************************************************
.include "LCDDriver.asm"		; Include the LCD Driver
