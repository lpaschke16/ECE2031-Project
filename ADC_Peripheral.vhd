LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY ADC_Peripheral IS
    PORT(
        -- SCOMP Interface
        CLOCK      : IN    STD_LOGIC;
        RESETN     : IN    STD_LOGIC;
        IO_WRITE   : IN    STD_LOGIC;
        IO_READ    : IN    STD_LOGIC;
        IO_ADDR    : IN    STD_LOGIC_VECTOR(10 DOWNTO 0);
        IO_DATA    : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        
        ADC_CONVST : OUT   STD_LOGIC;
        ADC_SCLK   : OUT   STD_LOGIC;
        ADC_DIN    : OUT   STD_LOGIC;
        ADC_DOUT   : IN    STD_LOGIC
    );
END ADC_Peripheral;

ARCHITECTURE behavior OF ADC_Peripheral IS
blah blah blah