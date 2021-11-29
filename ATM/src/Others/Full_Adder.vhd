library ieee;
use ieee.std_logic_1164.all;

entity Full_Adder is
	port(
	A, B, C_in: in std_logic;
	S, C_out: out std_logic);
end Full_Adder;

architecture Full_Adder_ARH of Full_Adder is
signal INTERN: std_logic;
begin
	INTERN <= B xor A;
	S <= INTERN xor C_in;
	C_out <= (A and B) or (A and C_in) or (B and C_in);
end Full_Adder_ARH;
