--------------------------------------------------------------------------------
--
-- Test Bench for LAB #4
--
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

ENTITY testALU_vhd IS
END testALU_vhd;

ARCHITECTURE behavior OF testALU_vhd IS 

	-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT ALU
		Port(	DataIn1: in std_logic_vector(31 downto 0);
			DataIn2: in std_logic_vector(31 downto 0);
			ALUCtrl: in std_logic_vector(4 downto 0);
			Zero: out std_logic;
			ALUResult: out std_logic_vector(31 downto 0) );
	end COMPONENT ALU;

	--Inputs
	SIGNAL datain_a : std_logic_vector(31 downto 0) := (others=>'0');
	SIGNAL datain_b : std_logic_vector(31 downto 0) := (others=>'0');
	SIGNAL control	: std_logic_vector(4 downto 0)	:= (others=>'0');

	--Outputs
	SIGNAL result   :  std_logic_vector(31 downto 0);
	SIGNAL zeroOut  :  std_logic;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut: ALU PORT MAP(
		DataIn1 => datain_a,
		DataIn2 => datain_b,
		ALUCtrl => control,
		Zero => zeroOut,
		ALUResult => result
	);
	

	tb : PROCESS
	BEGIN

		-- Wait 100 ns for global reset to finish
		wait for 100 ns;

		-- Start testing the ALU
		datain_a <= X"01234567";	-- DataIn in hex
		datain_b <= X"11223344";
		control  <= "00000";	-- Control in binary (ADD and ADDI test)
		wait for 20 ns; 			-- result = 0x124578AB  and zeroOut = 0
		control  <= "00001";	-- Subtraction
		wait for 20 ns;
		control <= "00010"; 	-- AND
		wait for 20 ns;
		control <= "00011"; 	-- OR
		wait for 20 ns;
		control <= "00101";     -- Shift right by one
		wait for 20 ns;
		control <= "00110";     -- Shift right by two
		wait for 20 ns;
		control <= "00111";     -- Shift right by three
		wait for 20 ns;
		control <= "01001";     -- Shift left by one
		wait for 20 ns;
		control <= "01010";     -- Shift left by two
		wait for 20 ns;
		control <= "01011";     -- Shift left by three
		wait for 20 ns;
		datain_a <= X"44332211";  -- New Data to test zero output
		datain_b <= X"44332211";
		control <= "00001";
		wait for 20 ns;


		wait; -- will wait forever
	END PROCESS;

END;