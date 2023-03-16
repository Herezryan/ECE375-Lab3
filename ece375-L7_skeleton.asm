
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
.def	counter = r19
.def	play = r23
.def	time = r25

; Use this signal code between two boards for their game ready
.equ    ReadyComp = $FF
.equ	PD_seven = 7
.equ	PD_four = 4
.def	waitcnt = r17				; Wait Loop Counter
.def	ilcnt = r18				; Inner Loop Counter
.def	olcnt = r24				; Outer Loop Counter

.equ	WTime = 15

;***********************************************************
;*  Start of Code Segment
;***********************************************************
.cseg                           ; Beginning of code segment

;***********************************************************
;*  Interrupt Vectors
;***********************************************************
.org    $0000                   ; Beginning of IVs
	    rjmp    INIT            	; Reset interrupt

.org	$0004
		rcall HandleTC1
		reti

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
		;Enable receiver and transmitter
		;Set frame format: 8 data bits, 2 stop bits
		;Set baudrate at 2400bps
		ldi mpr, $00
		sts	UBRR1H, mpr
		ldi mpr, $CF
		sts UBRR1L, mpr

		;Enable receiver and transmitter
		ldi mpr, (1<<RXEN1)|(1<<TXEN1)
		sts	UCSR1B, mpr

		;Set frame format: 8 data bits, 2 stop bits
		ldi mpr, (1<<USBS1)|(3<<UCSZ10)
		sts UCSR1C, mpr

	;TIMER/COUNTER1
		;Set Normal mode

		ldi time, $0A
		
		ldi mpr, 0b11000000
		sts TCCR1A, mpr

		ldi mpr, 0b00000010
		sts TCCR1B, mpr

		ldi mpr, $00
		sts TCNT1L, mpr
		sts TCNT1H, mpr

		ldi mpr, 0b00000001
		sts TIMSK1, mpr
		

	;Other

		rcall LCDInit
		rcall LCDClr
		
		ldi ZL, low(Init_START<<1)
		ldi ZH, high(Init_START<<1)
		ldi YL, $00
		ldi YH, $01
		ldi counter, 8

		rcall InitWriteL1

		ldi ZL, low(InitL2_START<<1)
		ldi ZH, high(InitL2_START<<1)
		ldi YL, $10
		ldi YH, $01
		ldi counter, 16

		rcall InitWriteL2

		ldi play, $00
	;Initialize the LCD
		


;***********************************************************
;*  Main Program
;***********************************************************
MAIN:
		in mpr, PIND
		andi mpr, (1<<7)
		cpi mpr, (1<<7)
		breq NEXT
		rcall WAITING
		rjmp MAIN

NEXT:
		rjmp MAIN

;***********************************************************
;*	Functions and Subroutines
;***********************************************************

InitWriteL1:
		lpm mpr, Z+
		st Y+, mpr
		dec counter
		brne InitWriteL1

		rcall LCDWrLn1
		ret

InitWriteL2:
		lpm mpr, Z+
		st Y+, mpr
		dec counter
		brne InitWriteL2

		rcall LCDWrLn2
		ret

WAITING:
		ldi ZL, low(PressedL1_START<<1)
		ldi ZH, high(PressedL1_START<<1)
		ldi YL, $00
		ldi YH, $01
		ldi counter, 14

		rcall ReadyWrLn1

		ldi ZL, low(PressedL2_START<<1)
		ldi ZH, high(PressedL2_START<<1)
		ldi YL, $10
		ldi YH, $01
		ldi counter, 16

		rcall ReadyWrLn2

		rcall SendReady
		;rcall CheckOpp
		rcall LCDClr
		sei
		rcall Game

		ret

ReadyWrLn1:
		lpm mpr, Z+
		st Y+, mpr
		dec counter
		brne ReadyWrLn1

		rcall LCDWrLn1
		ret

ReadyWrLn2:
		lpm mpr, Z+
		st Y+, mpr
		dec counter
		brne ReadyWrLn2

		rcall LCDWrLn2
		ret

SendReady:
		ldi mpr, $FF
		sts UDR1, mpr

		lds mpr, UDR1
		cpi mpr, $FF
		brne SendReady
		ret

Game:
		;in PINB
		;cpi mpr
		cpi play, $03
		brne Game2
		rcall Reset
Game2:
		rcall WriteLine1Start
		rcall WritePlay1
		in mpr, PIND
		andi mpr, (1<<4)
		cpi mpr, (1<<4)
		breq Game
		inc play
		ldi waitcnt, WTime
		rcall Wait
		rjmp Game

		ret

Reset:
		ldi play, $00
		rcall LCDClr
		ret

WriteLine1Start:
		ldi ZL, low(Start_START<<1)
		ldi ZH, high(Start_START<<1)
		ldi YL, $00
		ldi YH, $01
		ldi counter, 10

		rcall WriteLine1Helper
		ret

WriteLine1Helper:
		lpm mpr, Z+
		st Y+, mpr
		dec counter
		brne WriteLine1Helper

		rcall LCDWrLn1
		ret

WritePlay1:
		cpi play, $00
		brne WritePlay2
		ldi ZL, low(Rock_START<<1)
		ldi ZH, high(Rock_START<<1)
		ldi YL, $10
		ldi YH, $01
		ldi counter, 4

		rcall WriteRock
		ret
WritePlay2:
		cpi play, $01
		brne WritePlay3
		ldi ZL, low(Paper_START<<1)
		ldi ZH, high(Paper_START<<1)
		ldi YL, $10
		ldi YH, $01
		ldi counter, 5

		rcall WritePaper
		ret
WritePlay3:
		;cpi play, $02
		;brne WritePlay4
		ldi ZL, low(Scissor_START<<1)
		ldi ZH, high(Scissor_START<<1)
		ldi YL, $10
		ldi YH, $01
		ldi counter, 8
		rcall WriteScissors
		ret

WritePlay4:
		ret

WriteRock:
		lpm mpr, Z+
		st Y+, mpr
		dec counter
		brne WriteRock

		rcall LCDWrLn2
		ret

WritePaper:
		lpm mpr, Z+
		st Y+, mpr
		dec counter
		brne WritePaper

		rcall LCDWrLn2
		ret

WriteScissors:
		lpm mpr, Z+
		st Y+, mpr
		dec counter
		brne WriteScissors

		rcall LCDWrLn2
		ret

HandleTC1:
		cli
		ldi mpr, $00
		out TIFR1, mpr	; clear EIFR

		dec time
		cpi time, $00
		brne Finish
		rcall KillLED
		ret
Finish:
		sei
		ret

KillLED:
		ldi mpr, 0b00000000
		out PORTB, mpr
		ret

Wait:
		push	waitcnt			; Save wait register
		push	ilcnt			; Save ilcnt register
		push	olcnt			; Save olcnt register

Loop:	ldi		olcnt, 224		; load olcnt register
OLoop:	ldi		ilcnt, 237		; load ilcnt register
ILoop:	dec		ilcnt			; decrement ilcnt
		brne	ILoop			; Continue Inner Loop
		dec		olcnt		; decrement olcnt
		brne	OLoop			; Continue Outer Loop
		dec		waitcnt		; Decrement wait
		brne	Loop			; Continue Wait loop

		pop		olcnt		; Restore olcnt register
		pop		ilcnt		; Restore ilcnt register
		pop		waitcnt		; Restore wait register
		ret				; Return from subroutine

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

Start_START:
	.DB		"Game Start"
Start_END:

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


