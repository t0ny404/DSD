library ieee;
use ieee.std_logic_1164.all;

entity Verif50 is
	port(
	Banc10, Banc50: in std_logic_vector(7 downto 0);
	sute: in std_logic_vector(7 downto 0);
	ScadeSuma50, ScadeSuma10: out std_logic_vector(7 downto 0);
	Fail: out std_logic);
end Verif50;

architecture Verif50_ARH of Verif50 is	   

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
	BCD: in std_logic; 							-- 1 daca numerele sunt in BCD, 0 altfel
	A: in std_logic_vector(n-1 downto 0);		-- numerele de comparat
	B: in std_logic_vector(n-1 downto 0);
	AlessB: out std_logic;
	AequalB: out std_logic;				 
	AgreaterB: out std_logic);
end Component;	 

component Mul10 is
	port(		   
	nr: in std_logic_vector(7 downto 0);
	nr10: out std_logic_vector(7 downto 0);
	overflow: out std_logic_vector(8 downto 0)
	);
end component;	

component Mul5 is
	port(		   
	nr: in std_logic_vector(7 downto 0);
	nr5: out std_logic_vector(7 downto 0);
	overflow: out std_logic_vector(8 downto 0)
	);
end component;

component VerifZeci is
	port(
	Banc10, Banc50: in std_logic_vector(7 downto 0);
	Zeci: in std_logic_vector(7 downto 0); 
	ScadeSuma50, ScadeSuma10: out std_logic_vector(7 downto 0);
	Fail: out std_logic);
end component;

signal scad_5zec, scazute_50, sute_in_zec, scad_zec: std_logic_vector(7 downto 0);
signal zero, Scade50, ori5: std_logic_vector(7 downto 0);	
signal Fail0: std_logic := '0';

begin
		scad_5zec(7 downto 1) <= sute(6 downto 0); scad_5zec(0) <= '0';   --*2	
V50:	VerifZeci port map( Banc50, "00000000", scad_5zec, zero, Scade50, Fail0 );
scazute_50 <= Banc50 when Fail0='1' else Scade50;
M5: 	Mul5 port map( scazute_50, ori5 );
M10:	Mul10 port map( sute, sute_in_zec );
Rest:	N_Sub generic map(8) port map( A => sute_in_zec, B => ori5, C_in => '0', S => scad_zec );
V10:	VerifZeci port map( Banc10, "00000000", scad_zec, zero, ScadeSuma10, Fail );

ScadeSuma50 <= scazute_50;
end Verif50_ARH;