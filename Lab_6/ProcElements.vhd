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
    WITH selector SELECT
        Result <= In0 WHEN '0',
                  In1 WHEN OTHERS;
end architecture selection;

--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Control is
      Port(clk : in  STD_LOGIC;
           opcode : in  STD_LOGIC_VECTOR (6 downto 0);
           funct3  : in  STD_LOGIC_VECTOR (2 downto 0);
           funct7  : in  STD_LOGIC_VECTOR (6 downto 0);
           Branch : out  STD_LOGIC_VECTOR(1 downto 0);
           MemRead : out  STD_LOGIC;
           MemtoReg : out  STD_LOGIC;
           ALUCtrl : out  STD_LOGIC_VECTOR(4 downto 0);
           MemWrite : out  STD_LOGIC;
           ALUSrc : out  STD_LOGIC;
           RegWrite : out  STD_LOGIC;
           ImmGen : out STD_LOGIC_VECTOR(1 downto 0));
end Control;

architecture Boss of Control is
begin
	ALUCtrl <= "00000" WHEN opcode = "0110011" AND funct3 = "000" AND funct7 = "0000000" ELSE	--ADD
		"00001" WHEN opcode = "0110011" AND funct3 = "000" AND funct7 = "0100000" ELSE		--SUB
		"00011" WHEN opcode = "0110011" AND funct3 = "110" AND funct7 = "0000000" ELSE		--OR
		"00010" WHEN opcode = "0110011" AND funct3 = "111" AND funct7 = "0000000" ELSE		--AND
		"01001" WHEN opcode = "0110011" AND funct3 = "001" AND funct7 = "0000000" ELSE		--SLL
		"00101" WHEN opcode = "0110011" AND funct3 = "101" AND funct7 = "0000000" ELSE		--SRL
		"10000"	WHEN opcode = "0010011" AND funct3 = "000" ELSE					--ADDI 
		"10011" WHEN opcode = "0010011" AND funct3 = "110" ELSE					--ORI
		"10010" WHEN opcode = "0010011" AND funct3 = "111" ELSE					--ANDI
		"11001" WHEN opcode = "0010011" AND funct3 = "001" ELSE					--SLLI
		"10101" WHEN opcode = "0010011" AND funct3 = "101" ELSE					--SRLI
		"00001" WHEN opcode = "1100011" AND (funct3 = "000" OR funct3 = "001") ELSE		--BEQ or BNE	(Subraction)
		"10000" WHEN opcode = "0000011" OR opcode = "0100011" ELSE				--LW/SW		(Addition)
		"11111" WHEN opcode = "0110111" ELSE							--LUI
		"01111";										--Pass Through otherwise

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
    PROCESS(Reset, Clock) IS
    BEGIN
        IF(Reset = '1') THEN
            PCout <= x"00400000";
        end IF;
	IF rising_edge(Clock) THEN
		PCout <= PCin;
	END IF;
    END PROCESS;
end executive;
--------------------------------------------------------------------------------