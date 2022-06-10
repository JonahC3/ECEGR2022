--------------------------------------------------------------------------------
--
-- LAB #3
--
--------------------------------------------------------------------------------

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

entity fulladder is
    port (a : in std_logic;
          b : in std_logic;
          cin : in std_logic;
          sum : out std_logic;
          carry : out std_logic
         );
end fulladder;

architecture addlike of fulladder is
begin
  sum   <= a xor b xor cin; 
  carry <= (a and b) or (a and cin) or (b and cin); 
end architecture addlike;


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
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity adder_subtracter is
	port(	datain_a: in std_logic_vector(31 downto 0);
		datain_b: in std_logic_vector(31 downto 0);
		add_sub: in std_logic;
		dataout: out std_logic_vector(31 downto 0);
		co: out std_logic);
end entity adder_subtracter;

architecture calc of adder_subtracter is
	component fulladder
		port(a : in std_logic;
          	     b : in std_logic;
                     cin : in std_logic;
                     sum : out std_logic;
                     carry : out std_logic);
	end component;

	signal temp: std_logic_vector(31 downto 0);
	signal addorsub: std_logic_vector(32 downto 0);
begin
	addorsub(0) <= add_sub;
	co <= addorsub(32);

	process(add_sub, datain_a, datain_b) is 
	begin 
		if add_sub = '0' then temp <= datain_b;
		else temp <= not datain_b;
		end if;
	end process;


	adderloop: for i in 31 downto 0 generate
	addi: fulladder port map (datain_a(i), temp(i),addorsub(i), dataout(i), addorsub(i+1));
	end generate;

end architecture calc;

--------------------------------------------------------------------------------
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity shift_register is
	port(	datain: in std_logic_vector(31 downto 0);
	   	dir: in std_logic;
		shamt:	in std_logic_vector(4 downto 0);
		dataout: out std_logic_vector(31 downto 0));
end entity shift_register;

architecture shifter of shift_register is

signal x: std_logic_vector(2 downto 0);

begin
	x <= dir & shamt(1 downto 0);
	
	process(x, datain, dir, shamt) is 
	begin 
		if x = "001" then dataout <= datain(30 downto 0) & '0';
		elsif x = "101" then dataout <= '0' & datain(31 downto 1);
		elsif x = "010" then dataout <= datain(29 downto 0) & "00";
		elsif x = "110" then dataout <= "00" & datain(31 downto 2);
		elsif x = "011" then dataout <= datain(28 downto 0) & "000";
		elsif x = "111" then dataout <= "000" & datain(31 downto 3);
		else dataout <= datain;
		end if;
	end process;
end architecture shifter;



