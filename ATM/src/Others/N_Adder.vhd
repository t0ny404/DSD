library ieee;
use ieee.std_logic_1164.all;

entity N_Adder is 
	generic(N: natural);
	port(
	A, B: in std_logic_vector (N-1 downto 0);
	C_in: in std_logic;
	S: out std_logic_vector (N-1 downto 0);
	C_out: out std_logic);
end N_Adder;

architecture ARH_N_Adder of N_Adder is
component Full_Adder is
	port(
	A, B, C_in: in std_logic;
	S, C_out: out std_logic);
end component Full_Adder;
signal INT: std_logic_vector (N-2 downto 0);
begin
	L1: for i in 0 to N-1 generate
	L2: 	if i=0 generate
	L3:			Full_Adder port map(A(i), B(i), C_in, S(i), INT(i));
			end generate;
	L4: 	if i>0 and i<N-1 generate
	L5:			Full_Adder port map(A(i), B(i), INT(i-1), S(i), INT(i));
			end generate;
	L6:		if i=N-1 generate
	L5:			Full_Adder port map(A(i), B(i), INT(i-1), S(i), C_out);
			end generate;
		end generate;
end ARH_N_Adder;
