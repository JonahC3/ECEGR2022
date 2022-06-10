--------------------------------------------------------------------------------
--                                                                            --
-- LAB #5 - Memory and Register Bank                                          --
--                                                                            --
--------------------------------------------------------------------------------
LIBRARY ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity RAM is
    Port(Reset:	  in std_logic;
	 Clock:	  in std_logic;	 
	 OE:      in std_logic; -- Output enable
	 WE:      in std_logic;  -- Write enable 
	 Address: in std_logic_vector(29 downto 0);
	 DataIn:  in std_logic_vector(31 downto 0);
	 DataOut: out std_logic_vector(31 downto 0));
end entity RAM;

architecture staticRAM of RAM is

   type ram_type is array (0 to 127) of std_logic_vector(31 downto 0); -- ram array 
   signal i_ram : ram_type;
   signal temp_address: std_logic_vector(29 downto 0);

begin

  RamProc: process(Clock, Reset, OE, WE, Address) is

  begin
    if Reset = '1' then
      for i in 0 to 127 loop   
          i_ram(i) <= X"00000000";
      end loop;
    end if;

    -- WRITING TO MEMORY
    if falling_edge(Clock) then
	if WE = '1' and to_integer(unsigned(Address)) >= 0 and to_integer(unsigned(Address)) <= 127 then 
	     i_ram(to_integer(unsigned(Address))) <= DataIn;
	elsif WE = '0' then 
	      temp_address <= address;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
	end if;	
    end if;
 
    -- READING FROM MEMORY
    if to_integer(unsigned(Address)) >= 0 and to_integer(unsigned(Address)) <= 127 then 
	if OE = '0' then 
		DataOut <= i_ram(to_integer(unsigned(Address)));
	else 
		DataOut <= (others => 'Z');
	end if;
    else
	DataOut <= (others => 'Z');
    end if;

  end process RamProc;

end staticRAM;	


--------------------------------------------------------------------------------
LIBRARY ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity Registers is
    Port(ReadReg1: in std_logic_vector(4 downto 0);   -- The registers you are reading values from a0 - a7 (x10 - x12) 
         ReadReg2: in std_logic_vector(4 downto 0); 
         WriteReg: in std_logic_vector(4 downto 0);   -- The register you writing to
	 WriteData: in std_logic_vector(31 downto 0); -- Data being written into the register 
	 WriteCmd: in std_logic;                      -- Wrtie enable
	 ReadData1: out std_logic_vector(31 downto 0); -- Data that was read out of register
	 ReadData2: out std_logic_vector(31 downto 0)); -- Data that was read out of register
end entity Registers;

architecture remember of Registers is
	component register32
  	    port(datain: in std_logic_vector(31 downto 0);
		 enout32,enout16,enout8: in std_logic;
		 writein32, writein16, writein8: in std_logic;
		 dataout: out std_logic_vector(31 downto 0));
	end component;

   -- REGISTER ARRAY 
   type reg_type is array (7 downto 0) of std_logic_vector(31 downto 0);
   signal register_array : reg_type;

   -- ENABLE SIGNALS FOR EACH REGISTER
   signal enablew0: std_logic;
   signal enablew1: std_logic;
   signal enablew2: std_logic;
   signal enablew3: std_logic;
   signal enablew4: std_logic;
   signal enablew5: std_logic;
   signal enablew6: std_logic;
   signal enablew7: std_logic;


begin
-- WRITING TO REGISTER --
process(WriteData, WriteCmd) is
begin
	if WriteReg = "01010" and WriteCmd = '1' then 
		enablew0 <= '1';
	elsif WriteReg = "01011" and WriteCmd = '1' then 
		enablew1 <= '1';
	elsif WriteReg = "01100" and WriteCmd = '1' then 
		enablew2 <= '1';
	elsif WriteReg = "01101" and WriteCmd = '1' then 
		enablew3 <= '1';
	elsif WriteReg = "01110" and WriteCmd = '1' then 
		enablew4 <= '1';
	elsif WriteReg = "01111" and WriteCmd = '1' then 
		enablew5 <= '1';
	elsif WriteReg = "10000" and WriteCmd = '1' then 
		enablew6 <= '1';
	elsif WriteReg = "10001" and WriteCmd = '1' then 
		enablew7 <= '1';
	else
		enablew0 <= '0';
		enablew1 <= '0';
		enablew2 <= '0';
		enablew3 <= '0';
		enablew4 <= '0';
		enablew5 <= '0';
		enablew6 <= '0';
		enablew7 <= '0'; 
	end if;
end process;

    a0: register32 port map(Writedata, '0', '1', '1', enablew0, '0', '0', register_array(0));
    a1: register32 port map(Writedata, '0', '1', '1', enablew1, '0', '0', register_array(1));
    a2: register32 port map(Writedata, '0', '1', '1', enablew2, '0', '0', register_array(2));
    a3: register32 port map(Writedata, '0', '1', '1', enablew3, '0', '0', register_array(3));
    a4: register32 port map(Writedata, '0', '1', '1', enablew4, '0', '0', register_array(4));
    a5: register32 port map(Writedata, '0', '1', '1', enablew5, '0', '0', register_array(5));
    a6: register32 port map(Writedata, '0', '1', '1', enablew6, '0', '0', register_array(6));
    a7: register32 port map(Writedata, '0', '1', '1', enablew7, '0', '0', register_array(7));

-- READING FROM REGISTER --
process(ReadReg1) is 
begin
	if ReadReg1 = "01010" then 
		ReadData1 <= register_array(0);
	elsif ReadReg1 = "01011" then 
		ReadData1 <= register_array(1);
	elsif ReadReg1 = "01100" then 
		ReadData1 <= register_array(2);
	elsif ReadReg1 = "01101" then 
		ReadData1 <= register_array(3);
	elsif ReadReg1 = "01110" then 
		ReadData1 <= register_array(4);
	elsif ReadReg1 = "01111" then 
		ReadData1 <= register_array(5);
	elsif ReadReg1 = "10000" then 
		ReadData1 <= register_array(6);
	elsif ReadReg1 = "10001" then 
		ReadData1 <= register_array(7);
	else -- Hard Wired Zero Register
		ReadData1 <= X"00000000";
	end if;
end process; 

process(ReadReg2) is 
begin
	if ReadReg2 = "01010" then 
		ReadData2 <= register_array(0);
	elsif ReadReg2 = "01011" then 
		ReadData2 <= register_array(1);
	elsif ReadReg2 = "01100" then 
		ReadData2 <= register_array(2);
	elsif ReadReg2 = "01101" then 
		ReadData2 <= register_array(3);
	elsif ReadReg2 = "01110" then 
		ReadData2 <= register_array(4);
	elsif ReadReg2 = "01111" then 
		ReadData2 <= register_array(5);
	elsif ReadReg2 = "10000" then 
		ReadData2 <= register_array(6);
	elsif ReadReg2 = "10001" then 
		ReadData2 <= register_array(7);
	else -- Hard Wired Zero Register
		ReadData2 <= X"00000000";
	end if;
end process; 
end remember;

----------------------------------------------------------------------------------------------------------------------------------------------------------------
