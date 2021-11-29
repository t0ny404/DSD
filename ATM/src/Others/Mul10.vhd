library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Mul10 is
	port(		   
	nr: in std_logic_vector(7 downto 0);
	nr10: out std_logic_vector(7 downto 0);
	overflow: out std_logic_vector(8 downto 0)
	);
end Mul10;

architecture multiply of Mul10 is	
signal int: natural;
signal bin: std_logic_vector(16 downto 0);
begin
	
	int <= (to_integer(unsigned(nr(7 downto 0))))*10;
	bin <= std_logic_vector(to_unsigned( int, bin'length ));
	nr10 <= bin(7 downto 0);
	overflow <= bin( 16 downto 8);
end multiply;
	