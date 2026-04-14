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
	AND 12Down ;mod 12 bits
	OUT Hex0

Loop:
    LOAD chan0
    OUT ADCconfig

ADCwait: 
    IN ADCstatus
    SUB chan2 ;checks for status 1 busy 0
    JZERO ADCread
    JUMP ADCwait

ADCread:
    IN ADCout
	OUT Hex0
    ADD sum
    STORE sum
    AND chan0 ; AC=0
    ADDI 1
    ADD count
    STORE count
    CALL averageCalc
    LOAD count
    ADDI -256 ; pick number for sample number, X=2^n
    JZERO Finish
    JUMP Loop

Finish:
    LOAD sum
    SHIFT X ; X=n
    OUT Hex0

averageCalc:
	LOAD sum
    SHIFT -8 ;X=n
    OUT Hex0
    RETURN

;Vars
chan0: DW &B0000000000
chan2: DW &B0000000010
count: DW &B0000000000
sum:   DW &B0000000000
randNum: DW 0
Bit9: DW &B01000000000
12down: DW &B0111111111111

;IO address constants
Switches:   EQU 000
Hex0:       EQU 004
Hex1:       EQU 005
ADCout:     EQU 194
ADCstatus:  EQU 193
ADCconfig:  EQU 192
