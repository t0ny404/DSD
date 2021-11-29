library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Retragere_Numerar is
	port(
	enable: in std_logic_vector(0 downto 0);
	suma: in std_logic_vector(15 downto 0);	                             -- suma de retras
	sumaMem: in std_logic_vector(15 downto 0);							 -- suma din memoria clientului
	Banc10, Banc50, Banc100, Banc500: in std_logic_vector(7 downto 0); 	  -- nr de bancnote din ATM
	Suma_noua_10, Suma_noua_50, Suma_noua_100, Suma_noua_500: out std_logic_vector(7 downto 0);		   -- noile cantitati de bancnote din ATM
	AScadeSuma10, AScadeSuma50, AScadeSuma100, AScadeSuma500: out std_logic_vector(7 downto 0);			-- nr de bancnote care s-au extras (pt afisare)
	Suma_noua_client: out std_logic_vector(15 downto 0);
	Fail: out std_logic);							   -- daca nu s-a putut retrage
end Retragere_Numerar;

architecture retragere of Retragere_Numerar is	

component CompNbit is
	generic(
	n: in natural);								-- nr de bits
	port(
	A: in std_logic_vector(n-1 downto 0);		-- numerele de comparat
	B: in std_logic_vector(n-1 downto 0);
	AlessB: out std_logic;
	AequalB: out std_logic;				 
	AgreaterB: out std_logic);
end component;	

component Mux1to4 is
	generic(
	n: in natural);
	port(
	dataIn: in std_logic_vector(n-1 downto 0);
	sel: in std_logic_vector(1 downto 0);
	zero: out std_logic_vector(n-1 downto 0);   
	one: out std_logic_vector(n-1 downto 0);
	two: out std_logic_vector(n-1 downto 0);
	three: out std_logic_vector(n-1 downto 0));
end component;

component VerifZeci is
	port(
	Banc10, Banc50: in std_logic_vector(7 downto 0);
	Zeci: in std_logic_vector(7 downto 0); 
	ScadeSuma50, ScadeSuma10: out std_logic_vector(7 downto 0);
	Fail: out std_logic);
end component;

component VerifSute is
	port(
	Banc10, Banc50: in std_logic_vector(7 downto 0);
	Banc100, Banc500: in std_logic_vector(7 downto 0);
	Sute: in std_logic_vector(7 downto 0); 
	ScadeSuma50, ScadeSuma10: out std_logic_vector(7 downto 0);
	ScadeSuma500, ScadeSuma100: out std_logic_vector(7 downto 0);
	Fail: out std_logic);
end component;

component Mul10 is
	port(		   
	nr: in std_logic_vector(7 downto 0);
	nr10: out std_logic_vector(7 downto 0);
	overflow: out std_logic_vector(8 downto 0)
	);
end component;	

component N_Adder is 
	generic(N: natural);
	port(
	A, B: in std_logic_vector (N-1 downto 0);
	C_in: in std_logic;
	S: out std_logic_vector (N-1 downto 0);
	C_out: out std_logic);
end component;
	
component N_Sub is 
	generic(N: natural);
	port(
	A, B: in std_logic_vector (N-1 downto 0);
	C_in: in std_logic;
	S: out std_logic_vector (N-1 downto 0);
	C_out: out std_logic);
end component;

signal zeci: std_logic_vector(7 downto 0);
signal sute: std_logic_vector(7 downto 0);
signal mii: std_logic_vector(7 downto 0); 
signal sel: std_logic_vector(1 downto 0);

signal zero: std_logic_vector(0 downto 0);
signal one: std_logic_vector(0 downto 0);
signal two: std_logic_vector(0 downto 0);

signal NuAre, Fail1, Fail2, Fail3, cond1, cond2, Faill: std_logic;
signal Banc10up, Banc50up, mii_in_sute: std_logic_vector(7 downto 0); 

signal ScadeSuma10_z, ScadeSuma10_s, ScadeSuma10_tot, ScadeSuma10_m: std_logic_vector(7 downto 0);
signal ScadeSuma50_z, ScadeSuma50_s, ScadeSuma50_tot, ScadeSuma50_m: std_logic_vector(7 downto 0);
signal ScadeSuma100_s, ScadeSuma100_m: std_logic_vector(7 downto 0);
signal ScadeSuma500_s, ScadeSuma500_m: std_logic_vector(7 downto 0);

signal Ramas10, Ramas50, Ramas100, Ramas500: std_logic_vector(7 downto 0);
signal ScadeSuma10, ScadeSuma50, ScadeSuma100, ScadeSuma500: std_logic_vector(7 downto 0);
signal Ramas: std_logic_vector(15 downto 0);

begin
	process(enable)
	begin
		if enable(0) = '1' then
	mii(3 downto 0) <= suma(15 downto 12);	mii(7 downto 4) <= "0000";
	sute(3 downto 0) <= suma(11 downto 8);	sute(7 downto 4) <= "0000";
	zeci(3 downto 0) <= suma(7 downto 4);	zeci(7 downto 4) <= "0000";
	end if;
	end process;
	
ConditieMaxim1000: CompNbit generic map(8) port map( "00000001", mii, sel(1), sel(0) );

Mux: Mux1to4 generic map(1) port map(enable, sel, zero, one, two );

ClientulAreDestul:	CompNbit generic map(16) port map (sumaMem, suma, NuAre ); 

VerifZec: VerifZeci port map( Banc10, Banc50, zeci, ScadeSuma50_z, ScadeSuma10_z, Fail1 );
Update10:  N_Sub generic map(8) port map( Banc10, ScadeSuma10_z, '0', Banc10up ); 
Update50:  N_Sub generic map(8) port map( Banc50, ScadeSuma50_z, '0', Banc50up );
VerifSut: VerifSute port map( Banc10up, Banc50up, Banc100, Banc500, sute, ScadeSuma50_s, ScadeSuma10_s, ScadeSuma500_s, ScadeSuma100_s, Fail2 );
ScadeSuma10_t: N_Adder generic map(8) port map( ScadeSuma10_z, ScadeSuma10_s, '0', ScadeSuma10_tot );
ScadeSuma50_t: N_Adder generic map(8) port map( ScadeSuma50_z, ScadeSuma50_s, '0', ScadeSuma50_tot ); 

MulZec:   Mul10 port map( mii, mii_in_sute );
CmpZeci:  CompNbit generic map(8) port map(A => zeci, B => "00000000", AequalB => cond1 );	
CmpSute:  CompNbit generic map(8) port map( A => sute, B => "00000000", AequalB => cond2 );
VerifMii: VerifSute port map( Banc10, Banc50, Banc100, Banc500, mii_in_sute, ScadeSuma50_m, ScadeSuma10_m, ScadeSuma500_m, ScadeSuma100_m, Fail3 );

process(zero, ScadeSuma10_tot, ScadeSuma100_s, ScadeSuma50_tot, ScadeSuma500_s, one, ScadeSuma10_m,	 ScadeSuma100_m, ScadeSuma50_m,	 ScadeSuma500_m, enable)
	begin
	if enable(0) = '1' then
		if zero(0) = '1' then
			ScadeSuma10 <= ScadeSuma10_tot;
			ScadeSuma50 <= ScadeSuma50_tot;
			ScadeSuma100 <= ScadeSuma100_s;
			ScadeSuma500 <= ScadeSuma500_s;
		elsif one(0) = '1' then
			ScadeSuma10 <= ScadeSuma10_m; 
			ScadeSuma50 <= ScadeSuma50_m; 
			ScadeSuma100 <= ScadeSuma100_m;
			ScadeSuma500 <= ScadeSuma500_m;
		else ScadeSuma10 <=  "00000000"; 
			 ScadeSuma50 <=  "00000000"; 
			 ScadeSuma100 <=  "00000000";
			 ScadeSuma500 <=  "00000000";
			
			
		end if;
	end if;	
end process;
process(ScadeSuma10, ScadeSuma50, ScadeSuma100, ScadeSuma500, enable)
begin
	if enable(0) = '1' then
	AScadeSuma10 <=	ScadeSuma10;
	AScadeSuma50 <=	ScadeSuma50;
	AScadeSuma100 <= ScadeSuma100;
	AScadeSuma500 <= ScadeSuma500; 
	end if;
end process;

ScadeDinAtm10: N_Sub generic map(8) port map( Banc10, ScadeSuma10, '0', Ramas10 );
ScadeDinAtm50: N_Sub generic map(8) port map( Banc50, ScadeSuma50, '0', Ramas50 );
ScadeDinAtm100: N_Sub generic map(8) port map( Banc100, ScadeSuma100, '0', Ramas100 );
ScadeDinAtm500: N_Sub generic map(8) port map( Banc500, ScadeSuma500, '0', Ramas500 );

process (Banc10, Banc50, Banc100, Banc500, Ramas10, Ramas50, Ramas100, Ramas500, Faill, enable)
begin
	if Faill = '1'  and enable(0) = '1' then
		Suma_noua_10 <= Banc10 ;
		Suma_noua_50 <= Banc50;
		Suma_noua_100 <= Banc100;
		Suma_noua_500 <= Banc500;
	else Suma_noua_10 <=   Ramas10;   
		 Suma_noua_50 <=   Ramas50;   
		 Suma_noua_100 <=  Ramas100;
		 Suma_noua_500 <=  Ramas500;
	end if;
end process;
	
ScadeDeLaClient: N_Sub generic map(16) port map( SumaMem, suma, '0', Ramas ); 
process (SumaMem, Ramas, Faill, enable)
begin
	if Faill = '1' and enable(0) = '1' then
		Suma_noua_client <= SumaMem;
	else Suma_noua_client <= Ramas; 
	end if;
end process;
	
process(two, NuAre, zero, Fail1, Fail2, one, cond1, cond2, Fail3, enable)
begin
	if enable(0) = '1'	then
		Faill <= two(0) or NuAre or ( zero(0) and ( Fail1 or Fail2 )) or ( one(0) and ( not cond1 or not cond2 or Fail3 ));
	end if;
end process;
process (Faill, enable)
begin
	if enable(0) = '1' then
		Fail <= Faill;
	end if;
end process;

		
end retragere;