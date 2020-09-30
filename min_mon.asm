;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;MIN_MON -- Simple Signon Monitor for EhBASIC
;
;This version of minmon expects to run on a R6501/R6511
;processor using the built-in UART as the console.
;
;To call it a "monitor" is generous, this is basically the
;I/O module for EhBASIC.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.include "basic.asm"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;R65X1 Equates
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ModeReg		= $14
SerCon		= $15
SerSta		= $16
SerDat		= $17
LowCrA		= $1A
UppCrA		= $19
LowLaA		= $18
UppLaA		= $19

; put the IRQ and MNI code in RAM so that it can be changed
IRQ_vec		= VEC_SV+2	; IRQ code vector
NMI_vec		= IRQ_vec+$0A	; NMI code vector


; now the code. all this does is set up the vectors and interrupt code
; and wait for the user to select [C]old or [W]arm start. nothing else
; fits in less than 128 bytes

;	.ORG	$7F00		;Fits in the top 256 bytes of system RAM

; reset vector points here

RES_vec
	SEI			;Disable interrupts
	CLD			;Clear decimal arithmetic mode.

	; Set MODE register, full address mode, Port D tristate, Port B latch
	; disabled, both timers in interval mode.
	LDA #$00
	STA ModeReg

	;  Set up built-in UART
	LDA #$C0		;* [XMTR Enable][RCVR Enable][XMTR & RCVR Async][8-bits][no parity][odd parity]
	STA SerCon

	LDA #$0C		;* 4800 baud at 1MHz Phi2
	STA LowLaA
	LDA #$00
	STA UppLaA

	LDX	#$FF
	TXS			;Set stack pointer to 0xFF

; set up vectors and interrupt code, copy them to page 2

	LDY	#END_CODE-LAB_vec	
				; set index/count
LAB_stlp
	LDA	LAB_vec-1,Y	; get byte from interrupt code
	STA	VEC_IN-1,Y	; save to RAM
	DEY			; decrement index/count
	BNE	LAB_stlp	; loop if more to do

; now do the signon message, Y = $00 here

LAB_signon
	LDA	LAB_mess,Y	; get byte from sign on message
	BEQ	LAB_nokey	; exit loop if done

	JSR	V_OUTP		; output character
	INY			; increment index
	BNE	LAB_signon	; loop, branch always

LAB_nokey
	JSR	V_INPT		; call scan input device
	BCC	LAB_nokey	; loop if no key

	AND	#$DF		; mask xx0x xxxx, ensure upper case
	CMP	#'W'		; compare with [W]arm start
	BEQ	LAB_dowarm	; branch if [W]arm start

	CMP	#'C'		; compare with [C]old start
	BNE	RES_vec		; loop if not [C]old start

	JMP	COLDST		; do EhBASIC cold start

LAB_dowarm
	JMP	WARMST		; do EhBASIC warm start

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;ACIAout -- Output a character to the UART
;
;Preserves A register.
;
;pre: A register contains character to output
;pre: UART initialized
;post: character from A register output to UART
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ACIAout
	PHA			;Save A register on stack
ACIAO1	LDA SerSta		;Load status register for UART
	AND #$40		;Mask bit 6.
	BEQ ACIAO1		;UART not done yet, wait.
	PLA			;Restore A
	PHA			;Save A
	AND #$7F		;Strip parity
	STA SerDat		;Send it.
	PLA			;Restore A register
	RTS			;Done, over and out...

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;ACIAin -- Get a character from the UART
;
;This subroutine is nonblocking and returns with carry
;clear if there is no character waiting.
;
;If a character is available, set the carry flag and return
;with the character in A register.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ACIAin
	LDA SerSta		;See if we got an incoming char
	AND #$01		;Test bit 0
	BEQ LAB_nobyw		;No byte waiting
	LDA SerDat		;Got byte, load char in A register

	SEC			;Byte received, set carry
	RTS

LAB_nobyw
	CLC			;No byte received, clear carry

no_load				; empty load vector for EhBASIC
no_save				; empty save vector for EhBASIC
	RTS

; vector tables

LAB_vec
	.word	ACIAin		; byte in from simulated ACIA
	.word	ACIAout		; byte out to simulated ACIA
	.word	no_load		; null load vector for EhBASIC
	.word	no_save		; null save vector for EhBASIC

; EhBASIC IRQ support

IRQ_CODE
	PHA			; save A
	LDA	IRQBASE		; get the IRQ flag byte
	LSR			; shift the set b7 to b6, and on down ...
	ORA	IRQBASE		; OR the original back in
	STA	IRQBASE		; save the new IRQ flag byte
	PLA			; restore A
	RTI

; EhBASIC NMI support

NMI_CODE
	PHA			; save A
	LDA	NMIBASE		; get the NMI flag byte
	LSR			; shift the set b7 to b6, and on down ...
	ORA	NMIBASE		; OR the original back in
	STA	NMIBASE		; save the new NMI flag byte
	PLA			; restore A
	RTI

END_CODE

LAB_mess
	.byte	$0D,$0A,"R65X1 EhBASIC [C]old/[W]arm ?",$00
				; sign on string

; system vectors

;	.org	$FFFA

;	.word	NMI_vec		; NMI vector
;	.word	RES_vec		; RESET vector
;	.word	IRQ_vec		; IRQ vector

