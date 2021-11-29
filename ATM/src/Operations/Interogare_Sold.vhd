library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity Interogare_Sold is
	port(
	enable: in std_logic;
	clk: in std_logic; 
	segment: out std_logic_vector(6 downto 0); 
	anod: out std_logic_vector(3 downto 0);
	c4, c3, c2, c1: in std_logic_vector(3 downto 0));
end Interogare_Sold; 

architecture afis of Interogare_Sold is

signal clkdiv: std_logic_vector(12 downto 0);
signal clock: std_logic;
signal cifra: std_logic_vector(3 downto 0);	

signal anozi: std_logic_vector(3 downto 0);
signal segm: std_logic_vector(6 downto 0);	

procedure convertire( signal a: in std_logic_vector(3 downto 0); signal afis: out std_logic_vector(6 downto 0)) is

variable b: std_logic_vector(6 downto 0); 



begin
	case a is
			when "0000" => b := "0000001"; --0
			when "0001" => b := "1001111"; --1	
			when "0010" => b := "0010010"; --2
			when "0011" => b := "0000110"; --3
			when "0100" => b := "1001100"; --4
			when "0101" => b := "0100100"; --5
			when "0110" => b := "0100000"; --6
			when "0111" => b := "0001111"; --7
			when "1000" => b := "0000000"; --8
			when "1001" => b := "0000100"; --9
			when others => b := "1111111"; --Eroare la afisare
		end case;
		
		afis <= b;
end procedure;

begin
	
	process( clk )
	begin			
		if( clk'event and clk='1' )then
		clkdiv <= clkdiv+1;
		end if;
	end process;
	
	clock <= clkdiv(12);
	
	process( clock )
	variable i: integer:=0;
	begin					
		if( rising_edge(clock) ) then
			if( i=0 ) then
				--afiseaza pe primul afisor
				anozi <= "0111";	
				cifra <= c4;
				i := i+1;
			elsif ( i=1 )	then
				--afiseaza pe al doilea anod
				anozi <= "1011";  
				cifra <= c3;
				i := i+1;	
			elsif ( i=2 )	then
				 --afiseaza pe al treilea anod
				anozi <= "1101";  
				cifra <= c2;
				i := i+1;	 
			elsif ( i=3 )then
				--afiseaza pe ultimul anod
				anozi <= "1110";  
				cifra <= c1;
				i := 0;	
			end if;
		end if;
	end process;
	
	convertire( a => cifra, afis => segm );
	
	segment <= segm when enable='1' else "0000000";
	anod <= anozi when enable='1' else "0000";
	
end afis;