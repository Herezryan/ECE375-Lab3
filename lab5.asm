;***********************************************************
;*	This is the skeleton file for Lab 5 of ECE 375
;*
;*	 Author: Paul Lipp and Ryan Muriset
;*	   Date: 2023-02-17
;*
;***********************************************************

.include "m32U4def.inc"			; Include definition file

;***********************************************************
;*	Internal Register Definitions and Constants
;***********************************************************
.def	mpr = r16				; Multipurpose register
.def	waitcnt = r17
.def	ilcnt = r18				; Inner Loop Counter
.def	olcnt = r19
.def	ascii = r23				; Register for ascii chars
.def	asciiT = r24			; Register for ascii chars line 2

.equ	WskrR = 0				; Right Whisker Input Bit
.equ	WskrL = 1				; Left Whisker Input Bit
.equ	EngDirR = 4				; Right Engine Direction Bit
.equ	EngDirL = 7
.equ	MovFwd = (1<<EngDirR|1<<EngDirL)
.equ	WTime = 100
.equ	MovBck = $00
.equ	TurnR = (1<<EngDirL)			; Turn Right Command
.equ	TurnL = (1<<EngDirR)

;***********************************************************
;*	Start of Code Segment
;***********************************************************
.cseg							; Beginning of code segment

;***********************************************************
;*	Interrupt Vectors
;***********************************************************
.org	$0000					; Beginning of IVs
		rjmp 	INIT			; Reset interrupt

		; Set up interrupt vectors for any interrupts being used

		; This is just an example:
;.org	$002E					; Analog Comparator IV
;		rcall	HandleAC		; Call function to handle interrupt
;		reti					; Return from interrupt

.org	$0002
		rcall HandleINT0		; Handle INT0
		reti

.org	$0004
		rcall HandleINT1		; Handle INT1
		reti	
		
.org	$0008
		rcall HandleINT3
		reti	

.org	$0056					; End of Interrupt Vectors

;***********************************************************
;*	Program Initialization
;***********************************************************
INIT:							; The initialization routine
		; Initialize Stack Pointer

		ldi		mpr, low(RAMEND)
		out		SPL, mpr		; Load SPL with low byte of RAMEND
		ldi		mpr, high(RAMEND)
		out		SPH, mpr

		rcall LCDInit			; Initialize LCD 

		ldi		ascii, 0b00000000	; load 0 into ascii
		ldi		asciiT, 0b00000000	; load 0 into asciiT

		; Initialize Port B for output

		ldi		mpr, $FF		; Set Port B Data Direction Register
		out		DDRB, mpr		; for output
		ldi		mpr, $00		; Initialize Port B Data Register
		out		PORTB, mpr

		; Initialize Port D for input

		ldi		mpr, $00		; Set Port D Data Direction Register
		out		DDRD, mpr		; for input
		ldi		mpr, $FF		; Initialize Port D Data Register
		out		PORTD, mpr

		rcall ResetLCD			; Set LCD to 0

		; Initialize external interrupts
		ldi mpr, 0b10001010	; Set the Interrupt Sense Control to falling edge
		sts EICRA, mpr

		; Configure the External Interrupt Mask
		ldi mpr, 0b00001011
		out EIMSK, mpr

		; Turn on interrupts
		sei	; NOTE: This must be the last thing to do in the INIT function

;***********************************************************
;*	Main Program
;***********************************************************
MAIN:							; The Main program

		; TODO
		ldi		mpr, MovFwd		; Load Move Forward Command
		out		PORTB, mpr	

		rjmp	MAIN			; Create an infinite while loop to signify the
								; end of the program.

;***********************************************************
;*	Functions and Subroutines
;***********************************************************

;-----------------------------------------------------------
; Func: HandleINT0
; Desc: Handler function for Interrupt 0 (Push Button 4)
;-----------------------------------------------------------
HandleINT0:
		cli				; disable interrupts
		rcall HitRight	; call hit right
		ldi mpr, $0B	; set mpr to 1011
		out EIFR, mpr	; clear all flags in EIFR
		sei				; re-enable interrupts

		ret

;-----------------------------------------------------------
; Func: HandleINT1
; Desc: Handler function for Interrupt 1 (Push Button 5)
;-----------------------------------------------------------
HandleINT1:
		cli				; disable interrupts
		rcall HitLeft
		ldi mpr, $0B	; set mpr to 1011
		out EIFR, mpr	; clear all flags in EIFR to avoid queueing
		sei				; re-enble interrupts

		ret

;-----------------------------------------------------------
; Func: HandleINT3
; Desc: Handler function for Interrupt 3 (Push Button 6)
;-----------------------------------------------------------
HandleINT3:
		cli				; disable interrupts
		rcall ResetLCD	; reset to 0's on LCD
		ldi mpr, $0B	; set mpr to 1011 (INT 0, INT1, INT3)
		out EIFR, mpr	; clear all flags in EIFR
		sei				; re-enble interrupts

		ret

;-----------------------------------------------------------
; Func: ResetLCD
; Desc: Clears LCD and writes 0 to line 1 and 2 of LCD
;		Also resets counters ascii and asciiT to 0
;-----------------------------------------------------------
ResetLCD:
		rcall LCDClr		; clear LCD

		ldi YL, $00			; set Y to address of line 1
		ldi YH, $01

		ldi mpr, 0b00000000	; load 0 into mpr
		st Y+, mpr			; store 0 in line 1 address

		rcall LCDWrLn1		; write line 1

		; --------------------------

		ldi YL, $10			; set Y to address of line 2
		ldi YH, $01

		ldi mpr, 0b00000000 ; load 0 into mpr
		st Y+, mpr			; store 0 in line 2 address
		
		rcall LCDWrLn2		; write line 2

		ldi ascii, 0b00000000	; reset line 1 counter and line 2 counter to 0
		ldi asciiT, 0b00000000

		ret

;-----------------------------------------------------------
; Func: IncreaseRight
; Desc: Increases the counter for line 1 (hit right routine)
;		writes updated value to LCD
;-----------------------------------------------------------
IncreaseRight:
		rcall LCDClr

		inc ascii			; increment counter for line 1

		ldi XL, $00			; set X to address of line 1
		ldi XH, $01

		mov mpr, ascii		; copy value from ascii counter to mpr

		rcall Bin2ASCII		; call BIN2ASCII from LCDDriver.asm

		rcall LCDWrLn1		; Write line 1

		ldi XL, $10			; set X to address of line 2
		ldi XH, $01

		mov mpr, asciiT     ; copy value from ascii counter to mpr

		rcall Bin2ASCII		; call BIN2ASCII from LCDDriver.asm
		
		rcall LCDWrLn2

		ret

;-----------------------------------------------------------
; Func: IncreaseLeft
; Desc: Increases the counter for line 2 (hit left routine)
;		writes updated value to LCD
;-----------------------------------------------------------
IncreaseLeft:
		rcall LCDClr

		inc asciiT			; increment counter for line 1

		ldi XL, $00			; set X to address of line 1
		ldi XH, $01

		mov mpr, ascii		; copy value from ascii counter to mpr

		rcall Bin2ASCII

		rcall LCDWrLn1

		ldi XL, $10			; set X to address of line 2
		ldi XH, $01

		mov mpr, asciiT		; copy value from asciiT counter to mpr

		rcall Bin2ASCII
		
		rcall LCDWrLn2

		ret

HitRight:
		push	mpr			; Save mpr register
		push	waitcnt			; Save wait register
		in		mpr, SREG	; Save program state
		push	mpr			;

		; Move Backwards for a second
		ldi		mpr, MovBck	; Load Move Backward command
		out		PORTB, mpr	; Send command to port
		ldi		waitcnt, WTime	; Wait for 2 second
		rcall	Wait			; Call wait function

		; Turn left for a second
		ldi		mpr, TurnL	; Load Turn Left Command
		out		PORTB, mpr	; Send command to port
		ldi		waitcnt, WTime	; Wait for 1 second
		rcall	Wait			; Call wait function

		; Move Forward again
		ldi		mpr, MovFwd	; Load Move Forward command
		out		PORTB, mpr	; Send command to port

		pop		mpr		; Restore program state
		out		SREG, mpr	;
		pop		waitcnt		; Restore wait register
		pop		mpr		; Restore mpr

		rcall IncreaseRight	; increase counter in line 1
		ret	
		
HitLeft:
		push	mpr			; Save mpr register
		push	waitcnt			; Save wait register
		in		mpr, SREG	; Save program state
		push	mpr			;

		; Move Backwards for a second
		ldi		mpr, MovBck	; Load Move Backward command
		out		PORTB, mpr	; Send command to port
		ldi		waitcnt, WTime	; Wait for 2 second
		rcall	Wait			; Call wait function

		; Turn right for a second
		ldi		mpr, TurnR	; Load Turn Left Command
		out		PORTB, mpr	; Send command to port
		ldi		waitcnt, WTime	; Wait for 1 second
		rcall	Wait			; Call wait function

		; Move Forward again
		ldi		mpr, MovFwd	; Load Move Forward command
		out		PORTB, mpr	; Send command to port

		pop		mpr		; Restore program state
		out		SREG, mpr	;
		pop		waitcnt		; Restore wait register
		pop		mpr		; Restore mpr

		rcall IncreaseLeft	; Increase counter in line 2
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
;-----------------------------------------------------------
; Func: Template function header
; Desc: Cut and paste this and fill in the info at the
;		beginning of your functions
;-----------------------------------------------------------
FUNC:							; Begin a function with a label

		; Save variable by pushing them to the stack

		; Execute the function here

		; Restore variable by popping them from the stack in reverse order

		ret						; End a function with RET

;***********************************************************
;*	Stored Program Data
;***********************************************************

; Enter any stored data you might need here

;***********************************************************
;*	Additional Program Includes
;***********************************************************
.include "LCDDriver.asm"

;***********************************************************
; EOF
;***********************************************************
