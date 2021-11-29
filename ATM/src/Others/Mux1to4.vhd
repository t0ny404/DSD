library ieee;
use ieee.std_logic_1164.all;

entity Mux1to4 is
	generic(
	n: in natural);
	port(
	dataIn: in std_logic_vector(n-1 downto 0);
	sel: in std_logic_vector(1 downto 0);
	zero: out std_logic_vector(n-1 downto 0);   
	one: out std_logic_vector(n-1 downto 0);
	two: out std_logic_vector(n-1 downto 0);
	three: out std_logic_vector(n-1 downto 0));
end Mux1to4;

architecture mux of Mux1to4 is

begin  
	process(sel, dataIn) is
	begin
	L:	for i in 0 to n-1 loop
			zero(i) <= '0';
			one(i) <= '0';
			two(i) <= '0';
			three(i) <= '0';
		end loop;
		
			if sel = "00" then			
				zero <= dataIn;		
			elsif sel = "01" then
				one <= dataIn;
			elsif sel = "10" then
				two <= dataIn;
			elsif sel = "11" then
				three <= dataIn;
			end if;
	end process; 
end mux;