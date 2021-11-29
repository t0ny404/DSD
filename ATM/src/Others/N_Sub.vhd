library ieee;
use ieee.std_logic_1164.all;

entity N_Sub is 
	generic(N: natural);
	port(
	A, B: in std_logic_vector (N-1 downto 0);
	C_in: in std_logic;
	S: out std_logic_vector (N-1 downto 0);
	C_out: out std_logic);
end N_Sub;

architecture ARH_N_Sub of N_Sub is	

component Full_Adder is
	port(
	A, B, C_in: in std_logic;
	S, C_out: out std_logic);
end component Full_Adder;	

signal INT: std_logic_vector (N-2 downto 0);
signal nB: std_logic_vector (N-1 downto 0);
signal Cin: std_logic;
begin  
	Cin <= not C_in;
	L1: for i in 0 to N-1 generate
	L2: 	if i=0 generate
				nB(i) <= not B(i);
	L3:			Full_Adder port map(A(i), nB(i), Cin, S(i), INT(i));
			end generate;
	L4: 	if i>0 and i<N-1 generate
				nB(i) <= not B(i);
	L5:			Full_Adder port map(A(i), nB(i), INT(i-1), S(i), INT(i));
			end generate;
	L6:		if i=N-1 generate
				nB(i) <= not B(i);
	L5:			Full_Adder port map(A(i), nB(i), INT(i-1), S(i), C_out);
			end generate;
		end generate;
end ARH_N_Sub;
