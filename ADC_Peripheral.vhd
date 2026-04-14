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
			tx_cmd   : in  std_logic_vector(11 downto 0);
			busy     : out std_logic;
			sclk     : out std_logic; 
			conv     : out std_logic; 
			mosi     : out std_logic; 
			miso     : in  std_logic  	
		
		);
	END COMPONENT;
	
	SIGNAL control_reg : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL status : STD_LOGIC;
	SIGNAL tx_data : STD_LOGIC_VECTOR(11 DOWNTO 0);
	
	SIGNAL tx_shift_reg : STD_LOGIC_VECTOR(5 DOWNTO 0);
    SIGNAL adc_busy : STD_LOGIC;
    SIGNAL adc_start : STD_LOGIC;
    SIGNAL adc_rx_data : STD_LOGIC_VECTOR(11 DOWNTO 0);
    SIGNAL busy_previous : STD_LOGIC;

	TYPE MODE_TYPE IS (send_conversion, access_status, access_data, ignore);
	SIGNAL mode : MODE_TYPE;
	SIGNAL send_something : STD_LOGIC := '0';


 	BEGIN

	 	send_something <= IO_WRITE;
		WITH IO_ADDR SELECT
		    mode <= send_conversion WHEN "00011000000", -- 0x0C0
		            access_status   WHEN "00011000001", -- 0x0C1
		            access_data     WHEN "00011000010", -- 0x0C2
		            ignore          WHEN OTHERS;
	 
		WITH control_reg SELECT
			tx_shift_reg <= "100010" WHEN "0000",
						"110010" WHEN "0001",
						"100100" WHEN "0010",
						"110100" WHEN "0011",
						"101000" WHEN "0100",
						"111000" WHEN "0101",
						"101100" WHEN "0110",
						"111100" WHEN "0111",
						"100010" WHEN OTHERS;

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
		-- reg map stuff + actual control 
		PROCESS(CLOCK, RESETN)
		BEGIN
		 	IF (RESETN = '0') THEN
					control_reg <= "0000";
					status <= '0';
					adc_start <= '0';
					busy_previous <= '0';
			ELSIF RISING_EDGE(CLOCK) THEN
				adc_start <= '0';
				busy_previous <= adc_busy;
	            IF (busy_previous = '1' AND adc_busy = '0') THEN
	                status <= '1';
				END IF;
	
				IF (send_something = '1') THEN
					CASE mode IS
						WHEN send_conversion =>
							control_reg <= IO_DATA(3 DOWNTO 0);
							adc_start <= '1';
							status <= '0';
						
						WHEN OTHERS =>
							NULL;
						
					END CASE;
				END IF;
	
				IF (IO_READ = '1') THEN
					CASE mode IS
						WHEN access_data =>
							status <= '0';
						WHEN OTHERS =>
							NULL;
					END CASE;
				END IF;
			END IF;
		END PROCESS;

		-- tri-state driver logic
		IO_DATA <=
			("000000000000" & control_reg) WHEN (IO_READ = '1' AND mode = send_conversion) ELSE
			("00000000000000" & status & adc_busy) WHEN (IO_READ = '1' AND mode = access_status) ELSE
			("0000" & adc_rx_data) WHEN (IO_READ = '1' AND mode = access_data) ELSE
			"ZZZZZZZZZZZZZZZZ"; -- High impedence disconnect


	END behavior;
	
	
