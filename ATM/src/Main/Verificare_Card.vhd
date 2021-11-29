library ieee;
use ieee.std_logic_1164.all;

entity Verificare_Card is
	port(
	enable: in std_logic;
	codCard: in std_logic_vector(15 downto 0);
	CardIntrodus: out std_logic;
	IDintern: in std_logic_vector(14 downto 0));
	
end Verificare_Card;

architecture VerificareCard of Verificare_Card is
	
	--signal IDintern_OR: std_logic := '0';
begin
	P1: process (IDintern)
	variable IDintern_OR: std_logic;
	begin 
		if enable ='1' then
		IDintern_OR := '0';
		L1: for i in 0 to 13 loop
			IDintern_OR := IDintern_OR or IDintern(i);
		end loop;
		CardIntrodus <= not(IDintern(14)) and IDintern_OR;
		end if;
	end process P1;
	-- cardul este introdus (exista) daca primul bit este diferit de 1 si restul bitilor au cel putin un 1
	--CardIntrodus <= not(IDintern(14)) and IDintern_OR;
end VerificareCard;
