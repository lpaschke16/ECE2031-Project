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
			sclk     : out std_logic; 
			conv     : out std_logic; 
			mosi     : out std_logic; 
			miso     : in  std_logic  	
		
		);
	END COMPONENT;
	
	-- PLACEHOLDER -- More ADC logic?
	SIGNAL control_reg : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL data_ready : STD_LOGIC;
	
	SIGNAL status : STD_LOGIC;
	SIGNAL tx_shift_reg : STD_LOGIC_VECTOR(5 DOWNTO 0);
	SIGNAL tx_data : STD_LOGIC_VECTOR(11 DOWNTO 0);
    
   SIGNAL data_ready : STD_LOGIC;
   SIGNAL adc_busy : STD_LOGIC;
   SIGNAL adc_start : STD_LOGIC;
   SIGNAL adc_rx_data : STD_LOGIC_VECTOR(11 DOWNTO 0);
   SIGNAL busy_previous : STD_LOGIC;


--	case control_reg(3 downto 0) is
  --  	when "0000" => tx_shift_reg <= "100010";
 BEGIN
	WITH control_reg SELECT
		tx_shift_reg <= "100010" WHEN "0000",
							"110010" WHEN "0001",
							"100100" WHEN "0010",
							"110100" WHEN "0011",
							"101000" WHEN "0100",
							"111000" WHEN "0101",
							"101100" WHEN "0110",
							"111100" WHEN "0111";

	tx_data(11 downto 6) <= tx_shift_reg;
	tx_data(5 DOWNTO 0)  <= "000000";
	
	ADC : LTC2308_ctrl
    PORT MAP(
        -- connect up peripheral's clock and reset to SCOMP's 
		  clk => CLOCK,
        nrst => RESETN,
        -- connects SPI controller to SCOMP's state machine
		  start => adc_start,
        tx_cmd => tx_data,
        rx_data => adc_rx_data,
        busy => adc_busy,
        
		  -- conects the SPI controller's outputs off the FPGA to the ADC chip
		  sclk => ADC_SCLK,
        conv => ADC_CONVST,
        mosi => ADC_DIN,
        miso => ADC_DOUT
    );
	
	PROCESS (CLOCK, RESETN)
		BEGIN
			-- Register map stuff
		
		
	END PROCESS
	
	
	
	
