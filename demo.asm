ORG 0

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
    ADD sum
    STORE sum
    AND chan0 ; AC=0
    ADDI 1
    ADD count
    STORE count
    CALL averageCalc
    LOAD count
    SUB X ; pick number for sample number, X=2^n
    JZERO Finish
    JUMP Loop

Finish:
    LOAD sum
    SHIFT X ; X=n
    OUT Hex0

averageCalc:
	LOAD sum
    SHIFT X ;X=n
    OUT Hex0
    RETURN

;Vars
chan0: DW &B0000000000
chan2: DW &B0000000010
count: DW &B0000000000
sum:   DW &B0000000000

;IO address constants
Hex0:       EQU 004
Hex1:       EQU 005
ADCout:     EQU 194
ADCstatus:  EQU 193
ADCconfig:  EQU 192
