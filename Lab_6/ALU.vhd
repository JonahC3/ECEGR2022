--------------------------------------------------------------------------------
--
-- LAB #4
--
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

-------------------------------------------------------------------------------------------------------------------
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

------------------------------------------------------------------------------------------------------------------------------
--                                                                                                                          --
--                                                            ALU                                                           --
--                                                                                                                          --
------------------------------------------------------------------------------------------------------------------------------

Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity ALU is
	Port(	DataIn1: in std_logic_vector(31 downto 0);
		DataIn2: in std_logic_vector(31 downto 0);
		ALUCtrl: in std_logic_vector(4 downto 0);
		Zero: out std_logic;
		ALUresult: out std_logic_vector(31 downto 0) );
end entity ALU;

architecture ALU_Arch of ALU is
	-- ALU components	
	component adder_subtracter
		port(	datain_a: in std_logic_vector(31 downto 0);
			datain_b: in std_logic_vector(31 downto 0);
			add_sub: in std_logic;
			dataout: out std_logic_vector(31 downto 0);
			co: out std_logic);
	end component adder_subtracter;

	component shift_register
		port(	datain: in std_logic_vector(31 downto 0);
		   	dir: in std_logic;
			shamt:	in std_logic_vector(4 downto 0);
			dataout: out std_logic_vector(31 downto 0));
	end component shift_register;
	
	-- Non-immediates
	signal carry: std_logic;
	signal output_add_sub : std_logic_vector(31 downto 0);
	signal output_shift : std_logic_vector(31 downto 0);
	signal output_and : std_logic_vector(31 downto 0);
	signal output_or : std_logic_vector(31 downto 0);

	-- Immediates
	signal output_add_sub_i: std_logic_vector(31 downto 0);
	signal output_shift_i : std_logic_vector(31 downto 0);
	signal output_and_i : std_logic_vector(31 downto 0);
	signal output_or_i : std_logic_vector(31 downto 0);	

	-- Extra Signals
	signal addorsub : std_logic;
	signal output_temp: std_logic_vector(31 downto 0);

begin

	with ALUCtrl select
		addorsub <= '0' when "00000", -- add
			    '0' when "10000",	
			    '1' when others; -- sub

	-- Non-immediates
	c1: adder_subtracter port map(DataIn1, DataIn2, addorsub, output_add_sub, carry);
	c2: shift_register port map(DataIn1, ALUCtrl(2), DataIn2(4 downto 0), output_shift);
	output_and <= DataIn1 AND DataIn2;
	output_or <= DataIn1 OR DataIn2;
	
	-- Immediates
	c3: adder_subtracter port map(DataIn1, DataIn2, addorsub, output_add_sub_i, carry);
	c4: shift_register port map(DataIn1, ALUCtrl(2), DataIn2(4 downto 0), output_shift_i);
	output_and_i <= DataIn1 AND DataIn2;
	output_or_i <= DataIn1 OR DataIn2;
	
	with ALUCtrl select
		output_temp <= output_add_sub when "00000",
			     output_add_sub when "00001",
			     output_and when "00010",
			     output_or when "00011",
			     output_shift when "00101",
 			     output_shift when "00110",
                             output_shift when "00111",
                             output_shift when "01001",
                             output_shift when "01010",
                             output_shift when "01011",
                             ---------Immediates-----------
			     output_add_sub_i when "10000",
			     output_and_i when "10010",
			     output_or_i when "10011",
			     output_shift_i when "10101",
 			     output_shift_i when "10110",
                             output_shift_i when "10111",
                             output_shift_i when "11001",
                             output_shift_i when "11010",
                             output_shift_i when "11011",
			     DataIn2 when others;

	ALUResult <= output_temp;
	with output_temp select
		Zero <= '1' when x"00000000",
			'0' when others;

end architecture ALU_Arch;