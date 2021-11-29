library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity BCDtoBin is
	port(		   
	dec: in std_logic_vector(15 downto 0);
	binar: out std_logic_vector(15 downto 0));
end BCDtoBin;

architecture convert of BCDtoBin is	

signal mii: natural;  
signal sute: natural;
signal zeci: natural;
signal unit: natural;
signal nr: natural;

begin
	mii <= to_integer(unsigned(dec(15 downto 12)))*1000;
	sute <= to_integer(unsigned(dec(11 downto 8)))*100;
	zeci <= to_integer(unsigned(dec(7 downto 4)))*10;
	unit <= to_integer(unsigned(dec(3 downto 0)));
	
	nr <= mii+sute+zeci+unit;
	
	binar <= std_logic_vector(to_unsigned( nr, binar'length ));	
end convert;
	