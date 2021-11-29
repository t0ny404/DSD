library ieee;
use ieee.std_logic_1164.all;

entity VerifZeci is
	port(
	Banc10, Banc50: in std_logic_vector(7 downto 0);
	Zeci: in std_logic_vector(7 downto 0); 
	ScadeSuma50, ScadeSuma10: out std_logic_vector(7 downto 0);
	Fail: out std_logic);
end VerifZeci;

architecture VerifZeci_ARH of VerifZeci is	   

component N_Sub is 
	generic(N: natural);
	port(
	A, B: in std_logic_vector (N-1 downto 0);
	C_in: in std_logic;
	S: out std_logic_vector (N-1 downto 0);
	C_out: out std_logic);
end component; 

component CompNbit is
	generic(
	n: in natural);								-- nr de bits
	port(
	A: in std_logic_vector(n-1 downto 0);		-- numerele de comparat
	B: in std_logic_vector(n-1 downto 0);
	AlessB: out std_logic;
	AequalB: out std_logic;				 
	AgreaterB: out std_logic);
end Component;	

signal sel: std_logic; 
signal suma_de_scazut: std_logic_vector(7 downto 0);
signal less, equal, greater: std_logic;	
signal fail0, fail1: std_logic := '0';

begin
	
S:		CompNbit generic map(8) port map( A => Banc50, B => "00000000", AgreaterB => sel);	
S1: 	CompNbit generic map(8) port map( "00000101",  Zeci, less, equal, greater); -- comparam nr de bancnote de zece dorite cu 5
Sub5:	N_Sub generic map(8) port map( A => Zeci, B => "00000101", C_in => '0', S => suma_de_scazut);
S1L:	CompNbit generic map(8) port map( Banc10, suma_de_scazut, fail1);
S0:		CompNbit generic map(8) port map( 	Banc10, Zeci, fail0);

	ScadeSuma50 <= "00000001" when equal='1' or ( fail1='0' and less='1') else "00000000";
	ScadeSuma10 <= Zeci when fail0='0' and ( sel='0' or greater='1') else suma_de_scazut when sel='1' and less='1' and fail1='0' else "00000000";
	Fail <= Fail0 when ( sel='0' or greater='1') else Fail1;
end VerifZeci_ARH;
			
			
			
			
			
			
			
		
		