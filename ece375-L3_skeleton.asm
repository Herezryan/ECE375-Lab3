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
		ldi		mpr, low(RAMEND)
		out		SPL, mpr		; Load SPL with low byte of RAMEND
		ldi		mpr, high(RAMEND)
		out		SPH, mpr		; Load SPH with high byte of RAMEND

		rcall LCDInit			; Initialize LCD Display

		ldi mpr, $00			; Initialize Port D for input
		out DDRD, mpr
		ldi mpr, $FF
		out PORTD, mpr
		
		rcall LCDClr			; Clear LCD

		; NOTE that there is no RET or RJMP from INIT,
		; this is because the next instruction executed is the
		; first instruction of the main program

;***********************************************************
;*	Main Program
;***********************************************************
MAIN:							; The Main program
		; Main function design is up to you. Below is an example to brainstorm.

		in mpr, PIND
		andi mpr, (1<<PD_seven|1<<PD_five|1<<PD_four)
		cpi mpr, (1<<PD_seven)		; Check if pd7 is hit
		brne NEXT1
		;wrap around

NEXT1:	cpi mpr, (1<<PD_five)
		brne NEXT2
		;name and hello world
		rcall WORLD

NEXT2:  cpi mpr, (1<<PD_four)
		brne MAIN
		rcall CLEAR


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
CLEAR:	
		rcall LCDClr

		ret						; End a function with RET

WORLD:
		;move stuff to data memory
		;line 1 $0100 - $010F
		;line 2 $0110 - $011F

		;ldi mpr, 101
		;ldi XL, low($0100)
		;ldi XH, high($0100)

		ldi ZL, low(STRING_BEG<<1)
		ldi ZH, high(STRING_BEG<<1)

		;rcall Bin2ASCII

		;LPM mpr, Z+

		;ldi YL, $00
		;ldi YH, $01
		;ld r16, Y+
		;st Y, r17

		lpm r15, Z+
		lpm r16, Z+

		ldi YL, $00
		ldi YH, $01

		st Y, r16

		rcall LCDWrLn1

		ret
		;rcall LCDWrLn2
		

;***********************************************************
;*	Stored Program Data
;***********************************************************

;-----------------------------------------------------------
; An example of storing a string. Note the labels before and
; after the .DB directive; these can help to access the data
;-----------------------------------------------------------
STRING_BEG:
.DB		"My Test String"		; Declaring data in ProgMem
STRING_END:

;***********************************************************
;*	Additional Program Includes
;***********************************************************
.include "LCDDriver.asm"		; Include the LCD Driver
