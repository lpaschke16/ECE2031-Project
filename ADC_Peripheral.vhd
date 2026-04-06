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
	COMPONENT LTC2308_ctrl IS
		PORT (
			clk      : in  std_logic;
			nrst     : in  std_logic;
			start    : in  std_logic;
			rx_data  : out std_logic_vector(11 downto 0);
			busy     : out std_logic;
			-- SPI Physical Interface
			sclk     : out std_logic; -- Serial clock
			conv     : out std_logic; -- Conversion start control
			mosi     : out std_logic; -- Data out from this device, in to ADC
			miso     : in  std_logic  -- Data out from ADC, in to this device	
		
		);
