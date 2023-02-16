;***********************************************************
;*	This is the skeleton file for Lab 4 of ECE 375
;*
;*	 Author: Paul Lipp and Ryan Muriset
;*	   Date: 2023-02-10
;*
;***********************************************************

.include "m128def.inc"			; Include definition file

;***********************************************************
;*	Internal Register Definitions and Constants
;***********************************************************
.def	mpr = r16				; Multipurpose register
.def	rlo = r0				; Low byte of MUL result
.def	rhi = r1				; High byte of MUL result
.def	zero = r2				; Zero register, set to zero in INIT, useful for calculations
.def	A = r3					; A variable
.def	B = r4					; Another variable
.def	counter = r19

.def	oloop = r17				; Outer Loop Counter
.def	iloop = r18				; Inner Loop Counter


;***********************************************************
;*	Start of Code Segment
;***********************************************************
.cseg							; Beginning of code segment

;-----------------------------------------------------------
; Interrupt Vectors
;-----------------------------------------------------------
.org	$0000					; Beginning of IVs
		rjmp 	INIT			; Reset interrupt

.org	$0056					; End of Interrupt Vectors

;-----------------------------------------------------------
; Program Initialization
;-----------------------------------------------------------
INIT:							; The initialization routine

		; Initialize Stack Pointer
		ldi	mpr, low(RAMEND)	; Initialize Stack Pointer
		out SPL, mpr
		ldi mpr, high(RAMEND)
		out SPH, mpr
		; TODO

		clr		zero			; Set the zero register to zero, maintain
										; these semantics, meaning, don't
										; load anything else into it.

;-----------------------------------------------------------
; Main Program
;-----------------------------------------------------------
MAIN:							; The Main program

		; Call function to load ADD16 operands
		rcall ADD16_PM
		nop ; Check load ADD16 operands (Set Break point here #1)

		; Call ADD16 function to display its results (calculate FCBA + FFFF)	; 1FCB9
		rcall ADD16
		nop ; Check ADD16 result (Set Break point here #2)


		; Call function to load SUB16 operands
		rcall SUB16_PM
		nop ; Check load SUB16 operands (Set Break point here #3)

		; Call SUB16 function to display its results (calculate FCB9 - E420)q	; 1899
		rcall SUB16
		nop ; Check SUB16 result (Set Break point here #4)

		; Call function to load MUL24 operands
		rcall MUL24_PM
		nop ; Check load MUL24 operands (Set Break point here #5)

		; Call MUL24 function to display its results (calculate FFFFFF * FFFFFF) ; FF FF FE 00 00 01
		rcall MUL24
		nop ; Check MUL24 result (Set Break point here #6)

		; Setup the COMPOUND function direct test
		nop ; Check load COMPOUND operands (Set Break point here #7)

		; Call the COMPOUND function
		rcall COMPOUND
		nop ; Check COMPOUND result (Set Break point here #8)					; FC A8 CE E9 

DONE:	rjmp	DONE			; Create an infinite while loop to signify the
								; end of the program.

;***********************************************************
;*	Functions and Subroutines
;***********************************************************

;-----------------------------------------------------------
; Func: ADD16
; Desc: Adds two 16-bit numbers and generates a 24-bit number
;       where the high byte of the result contains the carry
;       out bit.
;-----------------------------------------------------------
ADD16:
		; Load beginning address of first operand into X
		ldi		XL, low(ADD16_OP1)	; Load low byte of address
		ldi		XH, high(ADD16_OP1)	; Load high byte of address

		ldi		YL, low(ADD16_OP2)	; load low byte of second operand into Y
		ldi		YH, high(ADD16_OP2) ; load high byte of second operand into Y

		ldi		ZL, low(ADD16_Result)  ; load low byte of result into Z
		ldi		ZH, high(ADD16_Result) ; load high byte of result into Z

		ld		A, X+				; load A into X, increment X
		ld		B, Y+				; load B into Y, increment Y
		add		A, B				; add A and B
		st		Z+, A				; Store low byte of result
		ld		A, X				; Load next operand byte
		ld		B, Y				; load next operand byte
		adc		A, B				; add with carry
		st		Z+, A				; store high byte of result
		brcc	EXIT				; exit if carry cleared
		st		Z, XH				; Add carry if necessary
		EXIT: 
			ret

;-----------------------------------------------------------
; Func: SUB16
; Desc: Subtracts two 16-bit numbers and generates a 16-bit
;       result. Always subtracts from the bigger values.
;-----------------------------------------------------------
SUB16:
		; Load beginning address of first operand into X
		ldi		XL, low(SUB16_OP1)	; Load low byte of address
		ldi		XH, high(SUB16_OP1)	; Load high byte of address

		ldi		YL, low(SUB16_OP2)  ; load low byte of second operand into Y
		ldi		YH, high(SUB16_OP2) ; load high byte of second operand into Y

		ldi		ZL, low(SUB16_Result) ; load low byte of result into Z
		ldi		ZH, high(SUB16_Result) ; load high byte of result into Z

		ld		A, X+
		ld		B, Y+
		sub		A, B
		st		Z+, A
		ld		A, X
		ld		B, Y
		sbc		A, B
		st		Z+, A
		brcc	EXIT2
		st		Z, XH
		; same logic as add, just with subtract for low byte and subtract with carry for high byte
		EXIT2: 
			ret
;-----------------------------------------------------------
; Func: MUL24
; Desc: Multiplies two 24-bit numbers and generates a 48-bit
;       result.
;-----------------------------------------------------------
MUL24:
;* - Simply adopting MUL16 ideas to MUL24 will not give you steady results. You should come up with different ideas.
		push 	A				; Save A register
		push	B				; Save B register
		push	rhi				; Save rhi register
		push	rlo				; Save rlo register
		push	zero			; Save zero register
		push	XH				; Save X-ptr
		push	XL
		push	YH				; Save Y-ptr
		push	YL
		push	ZH				; Save Z-ptr
		push	ZL
		push	oloop			; Save counters
		push	iloop

		clr		zero			; Maintain zero semantics

		; Set Y to beginning address of B
		ldi		YL, low(MUL24_OP2)	; Load low byte
		ldi		YH, high(MUL24_OP2)	; Load high byte

		; Set Z to begginning address of resulting Product
		ldi		ZL, low(MUL24_Result)	; Load low byte
		ldi		ZH, high(MUL24_Result); Load high byte

		; Begin outer for loop
		ldi		oloop, 3		; Load counter
MUL24_OLOOP:
		; Set X to beginning address of A
		ldi		XL, low(MUL24_OP1)	; Load low byte
		ldi		XH, high(MUL24_OP1)	; Load high byte

		; Begin inner for loop
		ldi		iloop, 3		; Load counter, 3 as 24 bits
MUL24_ILOOP:
		ld		A, X+			; Get byte of A operand
		ld		B, Y			; Get byte of B operand
		mul		A,B				; Multiply A and B
		ld		A, Z+			; Get a result byte from memory
		ld		B, Z+			; Get the next result byte from memory		; FF x FF = FE01	ld F, ld F, MUL FxF = E1, ld Z, ld Z, add rlo, A (E1), adc rhi(E) [E1], 
		add		rlo, A			; rlo <= rlo + A
		adc		rhi, B			; rhi <= rhi + B + carry
		; -------------------------------
		ld		A, Z+			; Get a third byte from the result
		adc		A, zero			; Add carry to A
		ld		B, Z			; Get a fourth byte from the result
		adc		B, zero			; Add carry to A
		; -------------------------------
		st		Z, B			; Store fourth byte to memory
		st		-Z, A			; Store third byte to memory
		; -------------------------------
		st		-Z, rhi			; Store second byte to memory
		st		-Z, rlo			; Store first byte to memory	
		adiw	ZH:ZL, 1		; Z <= Z + 1
		dec		iloop			; Decrement counter
		brne	MUL24_ILOOP		; Loop if iLoop != 0					
		; End inner for loop

		sbiw	ZH:ZL, 2		; Z <= Z - 2
		adiw	YH:YL, 1		; Y <= Y + 1
		dec		oloop			; Decrement counter
		brne	MUL24_OLOOP		; Loop if oLoop != 0
		; End outer for loop

		pop		iloop			; Restore all registers in reverves order
		pop		oloop
		pop		ZL
		pop		ZH
		pop		YL
		pop		YH
		pop		XL
		pop		XH
		pop		zero
		pop		rlo
		pop		rhi
		pop		B
		pop		A
		ret						; End a function with RET

;-----------------------------------------------------------
; Func: COMPOUND
; Desc: Computes the compound expression ((G - H) + I)^2
;       by making use of SUB16, ADD16, and MUL24.
;		
;       D, E, and F are declared in program memory, and must
;       be moved into data memory for use as input operands.
;
;       All result bytes should be cleared before beginning.
;-----------------------------------------------------------
COMPOUND:
		; WERE ASSUMING G = D, H = E, F = I
		; Setup SUB16 with operands G and H
		rcall COMPOUND_PM_SUB
		; Perform subtraction to calculate G - H
		rcall SUB16
		; Setup the ADD16 function with SUB16 result and operand I
		rcall COMPOUND_PM_ADD
		; Perform addition next to calculate (G - H) + I
		rcall ADD16
		; Setup the MUL24 function with ADD16 result as both operands
		rcall COMPOUND_PM_MUL
		; Perform multiplication to calculate ((G - H) + I)^2
		rcall MUL24

		ret						; End a function with RET

;-----------------------------------------------------------
; Func: MUL16
; Desc: An example function that multiplies two 16-bit numbers
;       A - Operand A is gathered from address $0101:$0100
;       B - Operand B is gathered from address $0103:$0102
;       Res - Result is stored in address
;             $0107:$0106:$0105:$0104
;       You will need to make sure that Res is cleared before
;       calling this function.
;-----------------------------------------------------------
MUL16:
		push 	A				; Save A register
		push	B				; Save B register
		push	rhi				; Save rhi register
		push	rlo				; Save rlo register
		push	zero			; Save zero register
		push	XH				; Save X-ptr
		push	XL
		push	YH				; Save Y-ptr
		push	YL
		push	ZH				; Save Z-ptr
		push	ZL
		push	oloop			; Save counters
		push	iloop

		clr		zero			; Maintain zero semantics

		; Set Y to beginning address of B
		ldi		YL, low(addrB)	; Load low byte
		ldi		YH, high(addrB)	; Load high byte

		; Set Z to begginning address of resulting Product
		ldi		ZL, low(LAddrP)	; Load low byte
		ldi		ZH, high(LAddrP); Load high byte

		; Begin outer for loop
		ldi		oloop, 2		; Load counter
MUL16_OLOOP:
		; Set X to beginning address of A
		ldi		XL, low(addrA)	; Load low byte
		ldi		XH, high(addrA)	; Load high byte

		; Begin inner for loop
		ldi		iloop, 2		; Load counter
MUL16_ILOOP:
		ld		A, X+			; Get byte of A operand
		ld		B, Y			; Get byte of B operand
		mul		A,B				; Multiply A and B
		ld		A, Z+			; Get a result byte from memory
		ld		B, Z+			; Get the next result byte from memory
		add		rlo, A			; rlo <= rlo + A
		adc		rhi, B			; rhi <= rhi + B + carry
		ld		A, Z			; Get a third byte from the result
		adc		A, zero			; Add carry to A
		st		Z, A			; Store third byte to memory
		st		-Z, rhi			; Store second byte to memory
		st		-Z, rlo			; Store first byte to memory
		adiw	ZH:ZL, 1		; Z <= Z + 1
		dec		iloop			; Decrement counter
		brne	MUL16_ILOOP		; Loop if iLoop != 0					
			
																		; XXXX    XXXX    XXXX
																		; HIGHER  HIGH    LOW
																		; FCBA	-> LOW = BA; HIGH = FC
																		; FFFF	-> LOW = FF; HIGH + FF
																		; BA x LOW FF -> OUTPUT LOW + CARRY
																		; (FC x LOW FF) + CARRY -> OUTPUT HIGH
																		; LOOP 1	Y -> Y HIGH, OUTPUT LOW = OUTPUT HIGH
																		; BA x HIGH FF -> OUTPUT HIGH + CARRY
																		; (FC x HIGH FF) + CARRY-> OUTPUT HIGHER
																		; LOOP 2	Y -> Y HIGHER, OUTPUT LOW = OUTPUT HIGHER
																		; BA x HIGH FF -> OUTPUT HIGH + CARRY
																		; (FC x HIGH FF) + CARRY-> OUTPUT HIGHER
		; End inner for loop

		sbiw	ZH:ZL, 1		; Z <= Z - 1
		adiw	YH:YL, 1		; Y <= Y + 1
		dec		oloop			; Decrement counter
		brne	MUL16_OLOOP		; Loop if oLoop != 0
		; End outer for loop

		pop		iloop			; Restore all registers in reverves order
		pop		oloop
		pop		ZL
		pop		ZH
		pop		YL
		pop		YH
		pop		XL
		pop		XH
		pop		zero
		pop		rlo
		pop		rhi
		pop		B
		pop		A
		ret						; End a function with RET

;-----------------------------------------------------------
; Func: ADD16_PM
; Desc: This function moves the Operands A and B from PM 
;		into DM for the ADD16 Function
;-----------------------------------------------------------


ADD16_PM:
		ldi ZL, low(OperandA<<1)
		ldi ZH, high(OperandA<<1)

		ldi YL, $10
		ldi YH, $01

		lpm mpr, Z+
		st Y+, mpr

		lpm mpr, Z
		st Y, mpr

		ldi ZL, low(OperandB<<1)
		ldi ZH, high(OperandB<<1)

		ldi YL, $12
		ldi YH, $01

		lpm mpr, Z+
		st Y+, mpr

		lpm mpr, Z
		st Y, mpr

		ret

;-----------------------------------------------------------
; Func: SUB16_PM
; Desc: This function moves the Operands C and D from PM 
;		into DM for the SUB16 Function
;-----------------------------------------------------------

SUB16_PM:
		ldi ZL, low(OperandC<<1)
		ldi ZH, high(OperandC<<1)

		ldi YL, $30
		ldi YH, $01

		lpm mpr, Z+
		st Y+, mpr

		lpm mpr, Z
		st Y, mpr

		ldi ZL, low(OperandD<<1)
		ldi ZH, high(OperandD<<1)

		ldi YL, $32
		ldi YH, $01

		lpm mpr, Z+
		st Y+, mpr

		lpm mpr, Z
		st Y, mpr

		ret

;-----------------------------------------------------------
; Func: MUL24_PM
; Desc: This function moves the Operands E1, E2 and F1, F2 from PM 
;		into DM for the MUL24 Function
;-----------------------------------------------------------

MUL24_PM:
		ldi ZL, low(OperandE1<<1)
		ldi ZH, high(OperandE1<<1)

		ldi YL, $60
		ldi YH, $01

		lpm mpr, Z+
		st Y+, mpr

		lpm mpr, Z
		st Y, mpr

		;------------------------
		ldi ZL, low(OperandE2<<1)
		ldi ZH, high(OperandE2<<1)

		ldi YL, $62
		ldi YH, $01

		lpm mpr, Z+
		st Y+, mpr

		lpm mpr, Z
		st Y, mpr

		;--------------------------------------------------------
		ldi ZL, low(OperandF1<<1)
		ldi ZH, high(OperandF1<<1)

		ldi YL, $64
		ldi YH, $01

		lpm mpr, Z+
		st Y+, mpr

		lpm mpr, Z
		st Y, mpr

		;------------------------
		
		ldi ZL, low(OperandF2<<1)
		ldi ZH, high(OperandF2<<1)

		ldi YL, $66
		ldi YH, $01

		lpm mpr, Z+
		st Y+, mpr

		lpm mpr, Z
		st Y, mpr

		ret

;-----------------------------------------------------------
; Func: COMPOUND_PM_SUB
; Desc: This function moves the Operands G and H from PM into
;       the right addresses in DM for the SUB16 function to work
;-----------------------------------------------------------

COMPOUND_PM_SUB:
		ldi ZL, low(OperandG<<1)
		ldi ZH, high(OperandG<<1)
		
		ldi YL, $30
		ldi YH, $01
		
		lpm mpr, Z+
		st Y+, mpr
		
		lpm mpr, Z
		st Y, mpr 

		; ------------------------

		ldi ZL, low(OperandH<<1)
		ldi ZH, high(OperandH<<1)
		
		ldi YL, $32
		ldi YH, $01
		
		lpm mpr, Z+
		st Y+, mpr
		
		lpm mpr, Z
		st Y, mpr

		ret

;-----------------------------------------------------------
; Func: COMPOUND_PM_ADD
; Desc: This function moves the Operand I and the result from 
;		the previous SUB16 function call from PM into
;       the right addresses in DM for the ADD16 function to work
;-----------------------------------------------------------

COMPOUND_PM_ADD:
		ldi ZL, $40
		ldi ZH, $01
		
		ldi YL, $10
		ldi YH, $01
		
		ld mpr, Z+
		st Y+, mpr
		
		ld mpr, Z
		st Y, mpr 

		; ------------------------

		ldi ZL, low(OperandI<<1)
		ldi ZH, high(OperandI<<1)
		
		ldi YL, $12
		ldi YH, $01
		
		lpm mpr, Z+
		st Y+, mpr
		
		lpm mpr, Z
		st Y, mpr

		ret

;-----------------------------------------------------------
; Func: COMPOUND_PM_MUL
; Desc: This function grabs the result from the prior ADD16 
;		function call and loads it into DM where the MUl24
;		operands are pointing at, so the MUL24 function works
;-----------------------------------------------------------

COMPOUND_PM_MUL:
		ldi ZL, $20
		ldi ZH, $01
		
		ldi YL, $60
		ldi YH, $01
		
		ld mpr, Z+
		st Y+, mpr

		ld mpr, Z+
		st Y+, mpr
		
		ld mpr, Z
		st Y, mpr

		; ------------------------

		ldi ZL, $20
		ldi ZH, $01
		
		ldi YL, $64
		ldi YH, $01
		
		ld mpr, Z+
		st Y+, mpr

		ld mpr, Z+
		st Y+, mpr
		
		ld mpr, Z
		st Y, mpr

		ret

;***********************************************************
;*	Stored Program Data
;*	Do not  section.
;***********************************************************
; ADD16 operands
OperandA:
	.DW 0xFCBA
OperandB:
	.DW 0xFFFF

; SUB16 operands
OperandC:
	.DW 0XFCB9
OperandD:
	.DW 0XE420

; MUL24 operands
OperandE1:
	.DW	0XFFFF
OperandE2:
	.DW	0X00FF
OperandF1:
	.DW	0XFFFF
OperandF2:
	.DW	0X00FF

; Compoud operands
OperandG:
	.DW	0xFCBA				; test value for operand G
OperandH:
	.DW	0x2022				; test value for operand H
OperandI:
	.DW	0x21BB				; test value for operand I

;***********************************************************
;*	Data Memory Allocation
;***********************************************************
.dseg
.org	$0100				; data memory allocation for MUL16 example
addrA:	.byte 2
addrB:	.byte 2
LAddrP:	.byte 4

; Below is an example of data memory allocation for ADD16.
; Consider using something similar for SUB16 and MUL24.
.org	$0110				; data memory allocation for operands
ADD16_OP1:
		.byte 2				; allocate two bytes for first operand of ADD16
ADD16_OP2:
		.byte 2				; allocate two bytes for second operand of ADD16

.org	$0120				; data memory allocation for results
ADD16_Result:
		.byte 3				; allocate three bytes for ADD16 result

.org	$0130				; data memory allocation for operands
SUB16_OP1:
		.byte 2				; allocate two bytes for first operand of SUB16
SUB16_OP2:
		.byte 2				; allocate two bytes for second operand of SUB16

.org	$0140				; data memory allocation for results
SUB16_Result:
		.byte 2				; allocate three bytes for SUB16 result

.org	$0160				; data memory allocation for operands
MUL24_OP1:
		.byte 4				; allocate two bytes for first operand of MUL24
MUL24_OP2:
		.byte 4				; allocate two bytes for second operand of MUL24	

.org	$0180				; data memory allocation for results
MUL24_Result:
		.byte 6				; allocate three bytes for MUL24 result

.org	$0220
COMPOUND_OP1:
		.byte 2
COMPOUND_OP2:
		.byte 2
COMPOUND_OP3:
		.byte 2

;***********************************************************
;*	Additional Program Includes
;***********************************************************
; There are no additional file includes for this program


