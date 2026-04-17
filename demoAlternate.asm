ORG 0

Reset:
	IN Switches
	JNZ Reset

Rand: 
	IN Switches
	AND Bit9
	JNZ Next
	LOAD randNum
	ADDI 1
	STORE randNum
	JUMP Rand

Next: 
	LOAD randNum
	AND down12 ;mod 12 bits
	OUT Hex0
	AND chan0       ; AC = 0 (chan0 = 0)
    STORE sum
    STORE count
    JUMP Loop

Loop:
	JUMP chanSelect
C0:
	LOAD chan0
    OUT ADCconfig
	JUMP ADCwait
C2:
    LOAD chan2
    OUT ADCconfig

ADCwait: 
    IN ADCstatus
    SUB chan2 ;checks for status 1 busy 0
    JZERO ADCread
    JUMP ADCwait

ADCread:
    IN ADCout
	OUT Hex0
	IN Switches
	AND Bit8 ;switch 8 to submit guess
	ADDI -256 
	JNZ Loop
	IN ADCout
    ADD sum
    STORE sum
    LOADI 0 ; AC=0
    ADDI 1
    ADD count
    STORE count
    LOAD count
    ADDI -4 ; pick number for sample number, X=2^n=4
    JZERO Finish
    JUMP Loop

Finish:
    LOAD sum
    SHIFT -2 ; X=n
    OUT Hex0
	JUMP Reset


chanSelect:
	IN Switches ; MAKE SURE SWITCH 9 IS DOWN BEFFORE YOU START
	ADDI -1
	JZERO C0
	IN Switches
	ADDI -4
	JZERO C2
	JUMP chanSelect

;Vars
chan0: DW &B0000000000
chan2: DW &B0000000010
count: DW &B0000000000
sum:   DW &B0000000000
randNum: DW 0
Bit0: DW &B00000000001
Bit2: DW &B00000000100
Bit8: DW &B00100000000
Bit9: DW &B01000000000
down12: DW &B0111111111111

;IO address constants
Switches:   EQU 000
Hex0:       EQU 004
Hex1:       EQU 005
ADCout:     EQU 194
ADCstatus:  EQU 193
ADCconfig:  EQU 192
