library ieee;
use ieee.std_logic_1164.all;

entity VerifSute is
	port(
	Banc10, Banc50: in std_logic_vector(7 downto 0);
	Banc100, Banc500: in std_logic_vector(7 downto 0);
	Sute: in std_logic_vector(7 downto 0); 
	ScadeSuma50, ScadeSuma10: out std_logic_vector(7 downto 0);
	ScadeSuma500, ScadeSuma100: out std_logic_vector(7 downto 0);
	Fail: out std_logic);
end VerifSute;

architecture VerifSute_ARH of VerifSute is	   

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

component Verif50 is
	port(
	Banc10, Banc50: in std_logic_vector(7 downto 0);
	sute: in std_logic_vector(7 downto 0);
	ScadeSuma50, ScadeSuma10: out std_logic_vector(7 downto 0);
	Fail: out std_logic);
end component;

signal sel: std_logic; 
signal suma_de_scazut: std_logic_vector(7 downto 0);
signal less, equal, greater: std_logic;	
signal fail0, fail1: std_logic :='0';
signal enable0, enable1: std_logic;
signal scad_din_zec1, scad_din_zec0: std_logic_vector(7 downto 0);
signal ScadeSuma10_0, ScadeSuma10_1, ScadeSuma50_0, ScadeSuma50_1: std_logic_vector(7 downto 0);

begin 
S:		CompNbit generic map(8) port map( A => Banc500, B => "00000000", AgreaterB => sel);	

--sel 1
S1: 	CompNbit generic map(8) port map( "00000101",  Sute, less, equal, greater);
Sub5:	N_Sub generic map(8) port map( A => Sute, B => "00000101", C_in => '0', S => suma_de_scazut);
S1L:	CompNbit generic map(8) port map( Banc100, suma_de_scazut, enable1);
Sub1: 	N_Sub generic map(8) port map( A => suma_de_scazut, B => Banc100, C_in => '0', S => scad_din_zec1 );
V50_1: Verif50 port map(Banc10, Banc50, scad_din_zec1, ScadeSuma50_1, ScadeSuma10_1, Fail1);

--sel 0
S0:		CompNbit generic map(8) port map( 	Banc100, Sute, enable0); 	
Sub0: 	N_Sub generic map(8) port map( A => Sute, B => Banc100, C_in => '0', S => scad_din_zec0 );
V50_0: Verif50 port map(Banc10, Banc50, scad_din_zec0, ScadeSuma50_0, ScadeSuma10_0, Fail0);


	ScadeSuma500 <= "00000001" when greater='0' and sel='1' else "00000000";
	ScadeSuma100 <= Banc100 when (enable1='1' and greater='0') or (enable0='1' and (sel='0' or greater='1')) else suma_de_scazut when enable1='0' and sel='1' and less='1' else Sute when enable0='0' and (sel='0' or greater='1') else "00000000";
	
	ScadeSuma50 <= ScadeSuma50_1 when enable1='1' and sel='1' and greater='0' else ScadeSuma50_0 when enable0='1' and (sel='0' or greater='1') else "00000000";
	ScadeSuma10 <= ScadeSuma10_1 when enable1='1' and sel='1' and greater='0' else ScadeSuma10_0 when enable0='1' and (sel='0' or greater='1') else "00000000";
	
	Fail <= Fail0 when sel='0' else Fail1 when less='1' and enable1='1' else '0';	 

end VerifSute_ARH;