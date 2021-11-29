library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity Depunere_Numerar is
	port(
	enable: in std_logic;
	Suma_Depusa: in std_logic_vector(15 downto 0);	       -- BCD (primii 4 biti rep nr bancnote de 500, urmatorii 4 de 100....)
	atmBanc10, atmBanc50, atmBanc100, atmBanc500: in std_logic_vector(7 downto 0);	  -- bancnotele din ATM
	uBanc10, uBanc50, uBanc100, uBanc500: out std_logic_vector(7 downto 0);		-- bancnotele actualizate din atm
	Suma_VecheClient: in std_logic_vector(15 downto 0);					   -- suma din contul clienului
	Suma_totala: out std_logic_vector(15 downto 0));					   -- suma noua (dupa depunere)  a clientului
end Depunere_Numerar;


architecture ARH_Depunere of Depunere_Numerar is   

component N_Adder is 
	generic(N: natural);
	port(
	A, B: in std_logic_vector (N-1 downto 0);
	C_in: in std_logic;
	S: out std_logic_vector (N-1 downto 0);
	C_out: out std_logic);
end component;

component Full_Adder is
	port(
	A, B, C_in: in std_logic;
	S, C_out: out std_logic);
end component;

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

signal add_10, add_50, add_50_i, add_100, add_100_i, add_500, add_500_i, add_500_i2: std_logic_vector(7 downto 0);
signal overflow_50, overflow_100, overflow_500_1, overflow_500_2: std_logic_vector(8 downto 0);
signal Suma_TotalaDep, Suma_tot: std_logic_vector(15 downto 0);
signal suma1, suma2, suma3, Banc500u, Banc100u, Banc50u, Banc10u: std_logic_vector(7 downto 0);
signal suma4, suma5, suma6: std_logic_vector(8 downto 0);
signal c_out1, c_out2, c_out3, c_out4, c_out5, c_out6: std_logic; 
signal Banc10, Banc50, Banc100, Banc500, nou10, nou50, nou100, nou500: std_logic_vector(7 downto 0);

begin
	Banc500(3 downto 0) <= Suma_Depusa(15 downto 12); Banc500(7 downto 4) <= "0000"; 
	Banc100(3 downto 0) <= Suma_Depusa(11 downto 8);  Banc100(7 downto 4) <= "0000";  
	Banc50(3 downto 0) <= Suma_Depusa(7 downto 4);	  Banc50(7 downto 4) <= "0000";	 
	Banc10(3 downto 0) <= Suma_Depusa(3 downto 0);	  Banc10(7 downto 4) <= "0000";	 
	
add10:	Mul10 port map( Banc10, add_10);
	
add50:	Mul10 port map( Banc50, add_50_i);
same:	Mul5 port map( add_50_i, add_50, overflow_50 );
	
add100:	Mul10 port map( Banc100, add_100_i );
same0:	Mul10 port map( add_100_i, add_100, overflow_100 );
	
add500:	Mul10 port map( Banc500, add_500_i );
same1:	Mul10 port map( add_500_i, add_500_i2, overflow_500_1 );
same2:	Mul5 port map( add_500_i2, add_500, overflow_500_2 );	

i1: N_Adder generic map(8) port map( add_10, add_50, '0', suma1, c_out1 );
i2: N_Adder generic map(8) port map( suma1, add_100, '0', suma2, c_out2 );
i3: N_Adder generic map(8) port map( suma2, add_500, '0', suma3, c_out3 ); --
i4: N_Adder generic map(9) port map( overflow_50, overflow_100, c_out1, suma4, c_out4 );
i5: N_Adder generic map(9) port map( suma4, overflow_500_1, c_out2, suma5, c_out5 );
i6: N_Adder generic map(9) port map( suma5, overflow_500_2, c_out3, suma6, c_out6 );--

		--se pierd
--Suma_TotalaDep(17) <= suma7; 
process(suma6, suma3, enable)
begin
	if enable = '1' then		
		Suma_TotalaDep(15 downto 8) <= suma6(7 downto 0);	
		Suma_TotalaDep(7 downto 0) <= suma3; 
	end if;
end process;

i8: N_Adder generic map(16) port map( Suma_TotalaDep, Suma_VecheClient, '0', Suma_tot ); 


process (enable, Suma_tot)
begin
	if enable = '1' then
		Suma_totala <= Suma_tot;
	else Suma_totala <= "0000000000000000";
	end if;
end process;
	
	
b1: N_Adder generic map(8) port map( atmBanc10, Banc10, '0', nou10, c_out6 );
b2: N_Adder generic map(8) port map( atmBanc50, Banc50, '0', nou50, c_out6 );
b3: N_Adder generic map(8) port map( atmBanc100, Banc100, '0', nou100, c_out6 );
b4: N_Adder generic map(8) port map( atmBanc500, Banc500, '0', nou500, c_out6 );

process(atmBanc10, atmBanc50, atmBanc100, atmBanc500, nou10, nou50, nou100, nou500, enable)
begin
	if enable = '1' then
		uBanc10 <= nou10;   
		uBanc50 <= nou50;   
		uBanc100 <= nou100;
		uBanc500 <= nou500;	
	else
		uBanc10 <= atmBanc10 ;
		uBanc50 <= atmBanc50 ;
		uBanc100 <= atmBanc100;
		uBanc500 <= atmBanc500;
	end if;
end process;
end ARH_Depunere;

