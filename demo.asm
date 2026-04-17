ORG 0

Reset:
    IN    Switches
    JNZ   Reset       

Rand:
    IN    Switches
    AND   Bit9
    JNZ   Next        
    LOAD  randNum
    ADDI  1
    STORE randNum
    JUMP  Rand

Next:
    
    LOAD  Zero
    STORE sum
    STORE count
    
    
Loop:
    LOAD  chan0
    OUT   ADCconfig

ADCwait:
    IN    ADCstatus
    SUB   chan2       ; Check if busy (bit 1)
    JZERO ADCread
    JUMP  ADCwait

ADCread:
    IN    ADCout
    OUT   Hex0        
    ADD   sum
    STORE sum
    LOAD  count
    ADDI  1
    STORE count
    ADDI   -256        
    JZERO Finish
    JUMP  Loop

Finish:
    LOAD  sum
    SHIFT -8          
    STORE target      
    OUT   Hex0

WaitGuess:
    IN    Switches
    AND   Bit0        
    JZERO WaitGuess   

ReadPot:
    LOAD  chan0
    OUT   ADCconfig
    
PotWait:              
    IN    ADCstatus
    SUB   chan2
    JZERO PotRead
    JUMP  PotWait

PotRead:
    IN    ADCout      
    SUB   target      
    JPOS  AbsValue    

AbsValue:
    SUB   Threshold   
    JNEG  Correct
    JUMP  WaitGuess   

Correct:
    LOAD  score
    ADDI  1
    STORE score
    OUT   Hex1        
    
    
ReleaseWait:
    IN    Switches
    AND   Bit0
    JNZ   ReleaseWait 
    JUMP  Next        
    
;Vars
target:    DW 0
score:     DW 0
count:     DW 0
sum:       DW 0
randNum:   DW 0
Threshold: DW 10      
Zero:      DW 0


; Bit Masks
Bit0:      DW &B000000000001
Bit9:      DW &B010000000000
chan0:     DW &B000000000000
chan2:     DW &B000000000010
12Down:    DW &B011111111111

; I/O Address Constants
Switches:  EQU 000
Hex0:      EQU 004
Hex1:      EQU 005
ADCout:    EQU 194
ADCstatus: EQU 193
ADCconfig: EQU 192
