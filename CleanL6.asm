;***********************************************************
;*
;*	This is the skeleton file for Lab 6 of ECE 375
;*
;*	 Author: Enter your name
;*	   Date: Enter Date
;*
;***********************************************************

.include "m32U4def.inc"			; Include definition file

;***********************************************************
;*	Internal Register Definitions and Constants
;***********************************************************
.def	mpr = r16				; Multipurpose register
.def    comp = r19
.def	check = r20

.equ	EngEnR = 5				; right Engine Enable Bit
.equ	EngEnL = 6				; left Engine Enable Bit
.equ	EngDirR = 4				; right Engine Direction Bit
.equ	EngDirL = 7				; left Engine Direction Bit

;***********************************************************
;*	Start of Code Segment
;***********************************************************
.cseg							; beginning of code segment

;***********************************************************
;*	Interrupt Vectors
;***********************************************************
.org	$0000
		rjmp	INIT			; reset interrupt

		; place instructions in interrupt vectors here, if needed

.org	$0056					; end of interrupt vectors

;***********************************************************
;*	Program Initialization
;***********************************************************
INIT:
        ; Initialize the Stack Pointer

		ldi	mpr, low(RAMEND)	
		out SPL, mpr
		ldi mpr, high(RAMEND)
		out SPH, mpr

        ; Initialize Port D for input

        ldi mpr, $00			
		out DDRD, mpr
		ldi mpr, $FF
		out PORTD, mpr

        ; Initialize PORT B for Output 

		ldi		mpr, $FF		; Set Port B Data Direction Register
		out		DDRB, mpr		; for output
		;ldi		mpr, $90		; Initialize Port B Data Register
		ldi		mpr, 0b11110000
		out		PORTB, mpr		; so all Port B outputs are low

        ;

        ldi mpr, $00			;load mpr with address
		sts TCNT1H, mpr			;copy value from mpr to TCNT1H
		ldi mpr, $00			;load mpr with address
		sts TCNT1L, mpr			;copy value from mpy to TCNT1L

		ldi mpr, $00			;load mpr with address
		sts OCR1AH, mpr			;copy value from mpr to OCR1AH
		ldi mpr, $00			;load mpr with address
		sts OCR1AL, mpr			;copy value from mpr to OCR1AL

		ldi mpr, $00			;load mpr with address
		sts OCR1BH, mpr			;copy value from mpr to OCR1AH
		ldi mpr, $00			;load mpr with address
		sts OCR1BL, mpr			;copy value from mpr to OCR1AL

		ldi mpr, 0b11110001			;load mpr with 177
		sts TCCR1A, mpr			;copy value from mpr to TCCR1A 
		ldi mpr, $09			;load mpr with value of address		
		sts TCCR1B, mpr			;copy value from mpr to TCCR1B

		ldi mpr, $06
		sts TIMSK1, mpr


;***********************************************************
;*	Main Program
;***********************************************************
MAIN:
		in mpr, PIND
		andi mpr, (1<<PIND7)
		cpi mpr, (1<<PIND7)
		brne INC_R

		in mpr, PIND
		andi mpr, (1<<PIND6)
		cpi mpr, (1<<PIND6)
		brne DEC_R

		in mpr, PIND
		andi mpr, (1<<PIND4)
		cpi mpr, (1<<PIND4)
		brne SET_FULL

		rjmp MAIN