-------------------------------------------------------------------------------
--
-- LAB #6 - Processor 
--
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Processor is
    Port ( reset : in  std_logic;
	   clock : in  std_logic);
end Processor;

architecture holistic of Processor is
	component Control
   	     Port( clk : in  STD_LOGIC;
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
	end component;

	component ALU
		Port(DataIn1: in std_logic_vector(31 downto 0);
		     DataIn2: in std_logic_vector(31 downto 0);
		     ALUCtrl: in std_logic_vector(4 downto 0);
		     Zero: out std_logic;
		     ALUResult: out std_logic_vector(31 downto 0) );
	end component;
	
	component Registers
	    Port(ReadReg1: in std_logic_vector(4 downto 0); 
                 ReadReg2: in std_logic_vector(4 downto 0); 
                 WriteReg: in std_logic_vector(4 downto 0);
		 WriteData: in std_logic_vector(31 downto 0);
		 WriteCmd: in std_logic;
		 ReadData1: out std_logic_vector(31 downto 0);
		 ReadData2: out std_logic_vector(31 downto 0));
	end component;

	component InstructionRAM
    	    Port(Reset:	  in std_logic;
		 Clock:	  in std_logic;
		 Address: in std_logic_vector(29 downto 0);
		 DataOut: out std_logic_vector(31 downto 0));
	end component;

	component RAM 
	    Port(Reset:	  in std_logic;
		 Clock:	  in std_logic;	 
		 OE:      in std_logic;
		 WE:      in std_logic;
		 Address: in std_logic_vector(29 downto 0);
		 DataIn:  in std_logic_vector(31 downto 0);
		 DataOut: out std_logic_vector(31 downto 0));
	end component;
	
	component BusMux2to1
		Port(selector: in std_logic;
		     In0, In1: in std_logic_vector(31 downto 0);
		     Result: out std_logic_vector(31 downto 0) );
	end component;
	
	component ProgramCounter
	    Port(Reset: in std_logic;
		 Clock: in std_logic;
		 PCin: in std_logic_vector(31 downto 0);
		 PCout: out std_logic_vector(31 downto 0));
	end component;

	component adder_subtracter
		port(	datain_a: in std_logic_vector(31 downto 0);
			datain_b: in std_logic_vector(31 downto 0);
			add_sub: in std_logic;
			dataout: out std_logic_vector(31 downto 0);
			co: out std_logic);
	end component adder_subtracter;

	SIGNAL PC_adder_to_Mux, Branch_adder_to_Mux: std_logic_vector(31 downto 0);
	SIGNAL PC_adder_co, Branch_adder_co, DataOffset_co: std_logic;		--These values are unused
	SIGNAL PCin, PCout: std_logic_vector(31 downto 0);
	SIGNAL ImmGenOut: std_logic_vector(31 downto 0);
	SIGNAL InstructionOut: std_logic_vector(31 downto 0);
	SIGNAL BranchMuxSelect: std_logic := '0';
	SIGNAL Zero: std_logic;
	SIGNAL Branch, ImmGen: std_logic_vector(1 downto 0);
	SIGNAL ALUCtrl: std_logic_vector(4 downto 0);
	SIGNAL MemRead, MemToReg, MemWrite, ALUSrc, RegWrite: std_logic;
	SIGNAL WriteData: std_logic_vector(31 downto 0);
	SIGNAL ALUInA, ALUInB, RegFileOutB, ALUResult: std_logic_vector(31 downto 0);
	SIGNAL DataMemOut: std_logic_vector(31 downto 0);
	SIGNAL ReadReg1, ReadReg2, DestReg: std_logic_vector(4 downto 0);
	SIGNAL OffsetDataAddress: std_logic_vector(31 downto 0);
begin

	ReadReg1 <= InstructionOut(19 downto 15);
	ReadReg2 <= InstructionOut(24 downto 20);
	DestReg <= InstructionOut(11 downto 7);


	PC: ProgramCounter PORT MAP(reset, clock, PCin, PCout);
	PC_adder: adder_subtracter PORT MAP(PCout, x"00000004", '0', PC_adder_to_Mux, PC_adder_co);
	Branch_adder: adder_subtracter PORT MAP(PCout, ImmGenOut, '0', Branch_adder_to_Mux, Branch_adder_co);
	PCMux: BusMux2to1 PORT MAP(BranchMuxSelect, PC_adder_to_Mux, Branch_adder_to_Mux, PCin);
	IMEM: InstructionRAM PORT MAP(reset, clock, PCout(31 downto 2), InstructionOut);
	ControlBlock: Control PORT MAP(clock, InstructionOut(6 downto 0), InstructionOut(14 downto 12), InstructionOut(31 downto 25), Branch, MemRead, MemtoReg, ALUCtrl, MemWrite, ALUSrc, RegWrite, ImmGen);
	RegFile: Registers PORT MAP(ReadReg1, ReadReg2, DestReg, WriteData, RegWrite, ALUInA, RegFileOutB);
	ALUInputMux: BusMux2to1 PORT MAP(ALUSrc, RegFileOutB, ImmGenOut, ALUInB);
	MainALU: ALU PORT MAP(ALUInA, ALUInB, ALUCtrl, Zero, ALUResult);
	DMEM: RAM PORT MAP(reset, clock, MemRead, MemWrite, OffsetDataAddress(31 downto 2), RegFileOutB, DataMemOut);
	ALUOutMux: BusMux2to1 PORT MAP(MemToReg, ALUResult, DataMemOut, WriteData);

	DataOffset: adder_subtracter PORT MAP(ALUResult, x"10000000", '1', OffsetDataAddress, DataOffset_co);

	ImmGenOut(31 downto 12) <= (Others=>InstructionOut(31)) WHEN ImmGen = "00" ELSE
				   (Others=>InstructionOut(31)) WHEN ImmGen = "01" ELSE
				   (Others=>InstructionOut(31)) WHEN ImmGen = "10" ELSE
				   InstructionOut(31 downto 12);
	ImmGenOut(11 Downto 0) <= InstructionOut(31 downto 20) WHEN ImmGen = "00" ELSE
				  InstructionOut(31 downto 25) & InstructionOut(11 downto 7) WHEN ImmGen = "01" ELSE
				  InstructionOut(7) & InstructionOut(30 downto 25) & InstructionOut(11 downto 8) & '0' WHEN ImmGen = "10" ELSE
				  (OTHERS=>'0');

	BranchMuxSelect <= '1' WHEN (Branch = "01" AND Zero = '1') OR (Branch = "10" AND Zero = '0') ELSE
			   '0';
				   
end holistic;