library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CompNbit is
	generic(
	n: in natural);								-- nr de bits
	port(
	A: in std_logic_vector(n-1 downto 0);		-- numerele de comparat
	B: in std_logic_vector(n-1 downto 0);
	AlessB: out std_logic;
	AequalB: out std_logic;				 
	AgreaterB: out std_logic);
end CompNbit;

architecture Comp of CompNbit is
begin												
	process(A, B) is
	begin  
	AlessB <= '0';
	AequalB <= '0';
	AgreaterB <= '0'; 
							
		
	if unsigned(A) < unsigned(B) then AlessB <= '1';										  
	elsif unsigned(A) > unsigned(B) then AgreaterB <= '1'; 
	else AequalB <= '1';
	
	end if;
	end process;
end Comp;
	
	