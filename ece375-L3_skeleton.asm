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

		ldi mpr, $00			; Initialize Port D for input
		out DDRD, mpr
		ldi mpr, $FF
		out PORTD, mpr

		ldi mpr, $FF
		out DDRB, mpr
		ldi mpr, $00
		out PORTB, mpr

		rcall LCDClr

		ldi ZL, low(STRING_BEG_L1<<1)
		ldi ZH, high(STRING_BEG_L1<<1)

		ldi YL, $00
		ldi YH, $01

		ldi counter, 9

		; NOTE that there is no RET or RJMP from INIT,
		; this is because the next instruction executed is the
		; first instruction of the main program

;***********************************************************
;*	Main Program
;***********************************************************
MAIN:							; The Main program
		; Main function design is up to you. Below is an example to brainstorm.

		in mpr, PIND
		andi mpr, (1<<PD_five|1<<PD_four)
		cpi mpr, (1<<PD_four)
		brne NAMES

		in mpr, PIND
		andi mpr, (1<<PD_five|1<<PD_four)
		cpi mpr, (1<<PD_five)
		brne CLEAR

		rjmp MAIN

NAMES:
		lpm mpr, Z+
		st Y+, mpr
		dec counter
		brne MAIN

		rcall LCDWrLn1

		clr r28
		clr r29
		clr r26
		clr r27
		clr r30

		ldi ZL, low(STRING_BEG_L2<<1)
		ldi ZH, high(STRING_BEG_L2<<1)

		ldi YL, $10
		ldi YH, $01

		clr counter

		ldi counter, 12

		rcall NAMES2

		ret

NAMES2:
			; Check if pd7 is hit
		lpm mpr, Z+
		st Y+, mpr
		dec counter
		brne NAMES2
		;wrap around

		rcall LCDWrLn2
		
		ret

		

CLEAR:	
		rcall LCDClr

		ret
		


		; Move strings from Program Memory to Data Memory

		; Display the strings on the LCD Display

		rjmp	MAIN			; jump back to main and create an infinite
								; while loop.  Generally, every main program is an
								; infinite while loop, never let the main program
								; just run off

;***********************************************************
;*	Functions and Subroutines
;***********************************************************

;-----------------------------------------------------------
; Func: Template function header
; Desc: Cut and paste this and fill in the info at the
;		beginning of your functions
;-----------------------------------------------------------
;***********************************************************
;*	Stored Program Data
;***********************************************************

;-----------------------------------------------------------
; An example of storing a string. Note the labels before and
; after the .DB directive; these can help to access the data
;-----------------------------------------------------------
STRING_BEG_L1:
.DB		"Paul Lipp"
STRING_END_1:
STRING_BEG_L2:
.DB		"and Ryan Muriest"	; Declaring data in ProgMem	9
STRING_END_2:
;.DB		"Ryan Muriset"	;	12
;STRING_END_L2:

;***********************************************************
;*	Additional Program Includes
;***********************************************************
.include "LCDDriver.asm"		; Include the LCD Driver


