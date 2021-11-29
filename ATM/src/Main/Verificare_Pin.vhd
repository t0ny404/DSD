library ieee;
use ieee.std_logic_1164.all;

entity Verificare_Pin is
	port(
	codPin: in std_logic_vector(15 downto 0);
	enable: in std_logic;					   			--CradIntrodus and not(IDintern(15))
	pinOK: out std_logic; 
	IDintern: in std_logic_vector(14 downto 0));
end Verificare_Pin;

architecture VerificarePin of Verificare_Pin is

	component memoriePin is
		port(
		mode: in std_logic; 								-- 0 pentru a citi si 1 pentru a scrie
		adr: in std_logic_vector(14 downto 0); 				-- adresa la care se scrie/citeste
		dataIn: in std_logic_vector(15 downto 0); 		    -- noul pin de introdus in RAM
		dataOut: out std_logic_vector(15 downto 0));    	-- pinul memorat la adresa accesata RAM
	end component; 	
	
	component CompNbit is
	generic(
	n: in natural);								   --nr de bits
	port(
	A: in std_logic_vector(n-1 downto 0);		  --numerele de comparat
	B: in std_logic_vector(n-1 downto 0);
	AlessB: out std_logic;
	AequalB: out std_logic;
	AgreaterB: out std_logic);
	end component;

signal Pin: std_logic_vector(15 downto 0);
signal equal: std_logic;

begin
M:	memoriePin port map('0', IDintern, "0000000000000000", Pin);
Comp: CompNbit generic map (16) port map( A => codPin, B => Pin, AequalB => equal );
	pinOK <= equal and enable;

end VerificarePin;