;***********************************************************
;*
;*	This is the TRANSMIT skeleton file for Lab 7 of ECE 375
;*
;*  	Rock Paper Scissors
;* 	Requirement:
;* 	1. USART1 communication
;* 	2. Timer/counter1 Normal mode to create a 1.5-sec delay
;***********************************************************
;*
;*	 Author: Paul Lipp and Ryan Muriset
;*	   Date: 2023-03-11
;*
;***********************************************************

.include "m32U4def.inc"         ; Include definition file

;***********************************************************
;*  Internal Register Definitions and Constants
;***********************************************************
.def    mpr = r16               ; Multi-Purpose Register

; Use this signal code between two boards for their game ready
.equ    SendReady = $FF
.equ	PD_seven = 7
.equ	PD_four = 4

;***********************************************************
;*  Start of Code Segment
;***********************************************************
.cseg                           ; Beginning of code segment

;***********************************************************
;*  Interrupt Vectors
;***********************************************************
.org    $0000                   ; Beginning of IVs
	    rjmp    INIT            	; Reset interrupt


.org    $0056                   ; End of Interrupt Vectors

;***********************************************************
;*  Program Initialization
;***********************************************************
INIT:
	;Stack Pointer (VERY IMPORTANT!!!!)

	; Initialize the Stack Pointer

		ldi	mpr, low(RAMEND)	; Initialize Stack Pointer
		out SPL, mpr
		ldi mpr, high(RAMEND)
		out SPH, mpr

	;I/O Ports
		ldi mpr, $00			; Initialize Port D for input
		out DDRD, mpr
		ldi mpr, $FF
		out PORTD, mpr

		ldi mpr, $FF
		out DDRB, mpr
		ldi mpr, $00
		out PORTB, mpr

	;USART1
		;Set baudrate at 2400bps
		ldi mpr, $00
		out	UBRRHn, mpr
		ldi mpr, $CF
		out UBRRLn, mpr

		;Enable receiver and transmitter
		ldi mpr, (1<<RXENn)|(1<<TXENn)
		out	USCRnB, mpr

		;Set frame format: 8 data bits, 2 stop bits
		ldi mpr, (1<<USBSN)|(3<<UCSZN0)
		out UCSRnC, mpr

	;TIMER/COUNTER1
		;Set Normal mode

	;Other

	;Initialize the LCD
		rcall LCDInit
		rcall LCDClr


;***********************************************************
;*  Main Program
;***********************************************************
MAIN:
		in mpr, PIND
		andi mpr, (1<<7)
		cpi mpr, (1<<7)
		breq NEXT
		rcall READY
		rjmp MAIN

NEXT:
		rjmp MAIN

;***********************************************************
;*	Functions and Subroutines
;***********************************************************

READY:
		
		ret

;***********************************************************
;*	Stored Program Data
;***********************************************************

;-----------------------------------------------------------
; An example of storing a string. Note the labels before and
; after the .DB directive; these can help to access the data
;-----------------------------------------------------------

Init_START:
	.DB		"Welcome!"
Init_END:

InitL2_START:
	.DB		"Please Press PD7"
InitL2_END:

PressedL1_START:
	.DB		"Ready. Waiting"
PressedL1_END:

PressedL2_START:
	.DB		"for the opponent"
PressedL2_END:

Rock_START:
    .DB		"Rock"		; Declaring data in ProgMem
Rock_END:

Paper_START:
    .DB		"Paper"		; Declaring data in ProgMem
Paper_END:

Scissor_START:
    .DB		"Scissors"		; Declaring data in ProgMem
Scissor_END:

WIN_START:
    .DB		"WIN!"		; Declaring data in ProgMem
WIN_END:

LOSS_START:
    .DB		"LOSS!"		; Declaring data in ProgMem
LOSS_END:

DRAW_START:
    .DB		"DRAW!"		; Declaring data in ProgMem
DRAW_END:

;***********************************************************
;*	Additional Program Includes
;***********************************************************
.include "LCDDriver.asm"		; Include the LCD Driver
