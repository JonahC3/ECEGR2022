Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity bitstorage is
	port(bitin: in std_logic;
	     enout: in std_logic;
	     writein: in std_logic;
	     bitout: out std_logic);
end entity bitstorage;

architecture memlike of bitstorage is
	signal q: std_logic := '0';
begin
	process(writein) is
	begin
		if (rising_edge(writein)) then
			q <= bitin;
		end if;
	end process;
	
	-- Note that data is output only when enout = 0	
	bitout <= q when enout = '0' else 'Z';
end architecture memlike;

--------------------------------------------------------------------------------
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity register8 is
	port(datain: in std_logic_vector(7 downto 0);
	     enout:  in std_logic;
	     writein: in std_logic;
	     dataout: out std_logic_vector(7 downto 0));
end entity register8;

architecture memmy of register8 is
	component bitstorage
		port(bitin: in std_logic;
		     enout: in std_logic;
		     writein: in std_logic;
		     bitout: out std_logic);
	end component;
begin
s1: bitstorage port map(datain(0), enout, writein, dataout(0)); 
s2: bitstorage port map(datain(1), enout, writein, dataout(1)); 
s3: bitstorage port map(datain(2), enout, writein, dataout(2)); 
s4: bitstorage port map(datain(3), enout, writein, dataout(3)); 
s5: bitstorage port map(datain(4), enout, writein, dataout(4)); 
s6: bitstorage port map(datain(5), enout, writein, dataout(5)); 
s7: bitstorage port map(datain(6), enout, writein, dataout(6)); 
s8: bitstorage port map(datain(7), enout, writein, dataout(7)); 

end architecture memmy;
--------------------------------------------------------------------------------
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity register32 is
	port(datain: in std_logic_vector(31 downto 0);
	     enout32,enout16,enout8: in std_logic;
	     writein32, writein16, writein8: in std_logic;
	     dataout: out std_logic_vector(31 downto 0));
end entity register32;

architecture biggermem of register32 is
	component register8
		port(datain: in std_logic_vector(7 downto 0);
		     enout: in std_logic;
		     writein: in std_logic;
		     dataout: out std_logic_vector(7 downto 0));
	end component;

signal enableo,wrtin: std_logic_vector(3 downto 0);
signal a,b: std_logic_vector(2 downto 0);


begin

	a <= enout32 & enout16 & enout8;	
	b <= writein32 & writein16 & writein8;

	process(a) is
	begin 
		if a = "110" then enableo <= "1110";
		elsif a = "101" then enableo <= "1100";
		elsif a = "011" then enableo <= "0000";
		else enableo <= "1111";
		end if;
	end process;
	
	process(b) is
	begin
		if b = "001" then wrtin <= "0001";
		elsif b = "010" then wrtin <= "0011";
		elsif b = "100" then wrtin <= "1111";
		else wrtin <= "0000";
		end if;
	end process;

	s1: register8 port map(datain(7 downto 0), enableo(0), wrtin(0), dataout(7 downto 0));
	s2: register8 port map(datain(15 downto 8), enableo(1), wrtin(1), dataout(15 downto 8));
	s3: register8 port map(datain(23 downto 16), enableo(2), wrtin(2), dataout(23 downto 16));
	s4: register8 port map(datain(31 downto 24), enableo(3), wrtin(3), dataout(31 downto 24)); 
end architecture biggermem;
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

    if falling_edge(Clock) then
	if WE = '1' then 
	     i_ram(to_integer(unsigned(Address))) <= DataIn;
	elsif WE = '0' then 
	      temp_address <= address;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
	end if;	
    end if;

    if rising_edge(Clock) then
	if OE = '0' then 
		DataOut <= i_ram(to_integer(unsigned(Address)));
	end if;
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
	 ReadData1: out std_logic_vector(31 downto 0);
	 ReadData2: out std_logic_vector(31 downto 0));
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
process(WriteData, WriteCmd)
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
	end if;
end process

    a0: register32(Writedata, 0, 1, 1, enablew0, 0, 0, register_array(0));
    a1: register32(Writedata, 0, 1, 1, enablew1, 0, 0, register_array(1));
    a2: register32(Writedata, 0, 1, 1, enablew2, 0, 0, register_array(2));
    a3: register32(Writedata, 0, 1, 1, enablew3, 0, 0, register_array(3));
    a4: register32(Writedata, 0, 1, 1, enablew4, 0, 0, register_array(4));
    a5: register32(Writedata, 0, 1, 1, enablew5, 0, 0, register_array(5));
    a6: register32(Writedata, 0, 1, 1, enablew6, 0, 0, register_array(6));
    a7: register32(Writedata, 0, 1, 1, enablew7, 0, 0, register_array(7));


end remember;

----------------------------------------------------------------------------------------------------------------------------------------------------------------
