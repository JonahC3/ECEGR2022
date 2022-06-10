--------------------------------------------------------------------------------
--
-- LAB #6 - Processor Elements
--
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity BusMux2to1 is
	Port(	selector: in std_logic;
			In0, In1: in std_logic_vector(31 downto 0);
			Result: out std_logic_vector(31 downto 0) );
end entity BusMux2to1;

architecture selection of BusMux2to1 is
begin
	with selector select
		Result <= In0 when '0',
			  In1 when others;
end architecture selection;

--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Control is
      Port(clk : in  STD_LOGIC;
           opcode : in  STD_LOGIC_VECTOR (6 downto 0); -- Part of Instrcution 
           funct3  : in  STD_LOGIC_VECTOR (2 downto 0); -- Part of Instruction
           funct7  : in  STD_LOGIC_VECTOR (6 downto 0); -- Part of Instruction
           Branch : out  STD_LOGIC_VECTOR(1 downto 0); -- Determines weather BNE or BEQ
           MemRead : out  STD_LOGIC; -- Line that enables to read from memory
           MemtoReg : out  STD_LOGIC; -- Line that enables reading from memory and storing to register
           ALUCtrl : out  STD_LOGIC_VECTOR(4 downto 0); -- Line that Controls the ALU
           MemWrite : out  STD_LOGIC; -- Line that enables to write to memory
           ALUSrc : out  STD_LOGIC; -- Line that chooses if its Immediate or Register value
           RegWrite : out  STD_LOGIC; -- Line that enables to write to register
           ImmGen : out STD_LOGIC_VECTOR(1 downto 0)); -- Immedieate Generator
end Control;

architecture Boss of Control is
begin

	-- Process for Branch line
	process(clk, opcode, funct3, funct7)is 
	begin
		if (opcode = "1100011" and funct3 = "00") then Branch <= "01"; -- BEQ
		elsif (opcode = "1100011" and funct3 = "01") then Branch <= "10"; -- BNE
		else Branch <= "00"; -- Nothing
		end if;
	end process;


	-- Process for MemRead line
	process(clk, opcode, funct3, funct7)is 
	begin
		if opcode = "0000011" then MemRead <= '0'; -- all load insructions
		else MemRead <= '1';
		end if; 	
	end process;	
	

	-- Process for MemtoReg line
	process(clk, opcode, funct3, funct7)is 
	begin
		if opcode = "0000011" then MemtoReg <= '1'; -- all load insturctions which reads data from memory and writes to register
		else MemtoReg <= '0';
		end if;
	end process;


	-- Process for the ALUCtrl line (following same truth table according to the instruction)
	process(clk, opcode, funct3, funct7) is
	begin 
		if (opcode = "0110011" and funct3 = "000" and funct7 = "0000000") then ALUCtrl <= "00000"; -- add
		elsif (opcode = "0110011" and funct3 = "000" and funct7 = "0100000") then ALUCtrl <= "00001"; -- sub
		elsif (opcode = "0110011" and funct3 = "111" and funct7 = "0000000") then ALUCtrl <= "00010"; -- and
		elsif (opcode = "0110011" and funct3 = "110" and funct7 = "0000000") then ALUCtrl <= "00011"; -- or
		elsif (opcode = "0110011" and funct3 = "000" and funct7 = "0000000") then ALUCtrl <= "00101"; -- srl 
		elsif (opcode = "0110011" and funct3 = "000" and funct7 = "0000000") then ALUCtrl <= "01001"; -- sll 
		elsif (opcode = "0010011" and funct3 = "000") then ALUCtrl <= "10000"; -- addi
		elsif (opcode = "0010011" and funct3 = "111") then ALUCtrl <= "10010"; -- andi
		elsif (opcode = "0110011" and funct3 = "110") then ALUCtrl <= "10011"; -- ori
		elsif (opcode = "0110011" and funct3 = "000" and funct7 = "0000000") then ALUCtrl <= "10101"; -- srli
		elsif (opcode = "0110011" and funct3 = "000" and funct7 = "0000000") then ALUCtrl <= "11001"; -- slli
		elsif (opcode = "1100011" and funct3 = "000") then ALUCtrl <= "00001"; -- beq (subtract to test if they equal zero. If equal zero, it means they are the same value)
		elsif (opcode = "1100011" and funct3 = "001") then ALUCtrl <= "00001"; -- bne (subtract to test if they equal zero. If equal zero, it means they are the same value)
		elsif (opcode = "0000011") then ALUCtrl <= "10000"; -- lw
		elsif (opcode = "0100011") then ALUCtrl <= "10000"; -- sw 
		elsif (opcode = "0110111") then ALUCtrl <= "10010"; -- lui
		else ALUCtrl <= "11111"; -- random ALUCtrl value that has no function 
		end if;
	end process;


	-- Process for MemWrite line
	process(clk, opcode, funct3, funct7)is 
	begin
		if opcode = "0100011" then MemWrite <= '1'; -- All store instructions
		else MemWrite <= '0';
		end if;
	end process;


	-- Process for ALUSrc line
	process(clk, opcode, funct3, funct7)is 
	begin
		if opcode = "0110011"  or opcode = "1100011"  or opcode = "XXXXXXX" then ALUSrc <= '0'; -- Specifies registers 
		else ALUSrc <= '1'; -- Specifies Immedieates 
		end if;
	end process;


	-- Process for RegWrite line
	process(clk, opcode, funct3, funct7)is 
	begin
		if clk = '0' and (opcode = "0000011" or opcode = "0110111" or opcode = "0110011" or opcode = "0010011")  -- any insruction that writes to registers (load instructions, lui, and all immediate and non-immediate operations)
			then RegWrite <= '1';
		else RegWrite <= '0';
		end if;
	end process;


	-- Process for ImmGen line
	process(clk, opcode, funct3, funct7)is 
	begin
		if opcode = "0010011" then ImmGen <= "00"; -- I type
		elsif opcode = "0100011" then ImmGen <= "01"; -- S type
		elsif opcode = "1100011" then ImmGen <= "10"; -- SB type
		else ImmGen <= "11";  -- R type and U type
		end if;
	end process;
end Boss;

--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ProgramCounter is
    Port(Reset: in std_logic;
	 Clock: in std_logic;
	 PCin: in std_logic_vector(31 downto 0);
	 PCout: out std_logic_vector(31 downto 0));
end entity ProgramCounter;

architecture executive of ProgramCounter is
begin
	process(Reset, Clock) is
	begin
		if (rising_edge(Clock)) then PCOut <= PCin;
		end if;
		
		if Reset = '1' then PCout <= x"00400000";
		end if ;
	end process; 
		

end executive;
--------------------------------------------------------------------------------