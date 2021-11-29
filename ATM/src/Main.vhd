library ieee;
use ieee.std_logic_1164.all;

entity Main is
	port(
		continua: in std_logic;
		operatie: in std_logic_vector(1 downto 0);
		cifra:in std_logic_vector(3 downto 0);
		switch: in std_logic;
		clk : in std_logic;
		clkA: in std_logic;
		chitanta_in: in std_logic;	 
		afisor: out STD_LOGIC_VECTOR(3 downto 0);
		segmente: out STD_LOGIC_VECTOR(6 downto 0);
		chitanta_out: out std_logic;	
		cardIntrodus: out std_logic;
		cardBlocat: out std_logic;
		Fail: out std_logic;
		AScadeSuma10, AScadeSuma50, AScadeSuma100, AScadeSuma500: out std_logic_vector(7 downto 0));
end Main;

architecture Main of Main is
-- componentele utilizate
component Citire is							  -- ma gandeam sa folosim aceeasi citire la toate ca oricum se face in acelasi fel
	port(
	cifra: in std_logic_vector(3 downto 0);	   -- cifra introdusa pe cele 4 switch-uri
	switchCifre: in std_logic;				   -- schimbarea intre unitati/zeci/sute/mii
	enable: in std_logic;
	clk: in std_logic;						   -- numarul cardului / pinul / suma
	cod: out std_logic_vector(15 downto 0));
end component;

component Verificare_Card is
	port(
	enable: in std_logic;
	codCard: in std_logic_vector(15 downto 0);
	CardIntrodus: out std_logic;
	IDintern: in std_logic_vector(14 downto 0));	
end component;

component Verificare_Pin is
	port(
	codPin: in std_logic_vector(15 downto 0);
	enable: in std_logic;					   			--CradIntrodus and not(IDintern(15))
	pinOK: out std_logic; 
	IDintern: in std_logic_vector(14 downto 0));
end component;

component Retragere_Numerar is
	port(
	enable: in std_logic_vector(0 downto 0);
	suma: in std_logic_vector(15 downto 0);	                             -- suma de retras
	sumaMem: in std_logic_vector(15 downto 0);							 -- suma din memoria clientului
	Banc10, Banc50, Banc100, Banc500: in std_logic_vector(7 downto 0); 	  -- nr de bancnote din ATM
	Suma_noua_10, Suma_noua_50, Suma_noua_100, Suma_noua_500: out std_logic_vector(7 downto 0);		   -- noile cantitati de bancnote din ATM
	AScadeSuma10, AScadeSuma50, AScadeSuma100, AScadeSuma500: out std_logic_vector(7 downto 0);			-- nr de bancnote care s-au extras (pt afisare)
	Suma_noua_client: out std_logic_vector(15 downto 0);
	Fail: out std_logic);							   -- daca nu s-a putut retrage
end component;

component COUNTER is
	generic(n: in natural; 			-- numarul de biti
			max: in natural); 		-- valoarea maxima pana la care se numara
	port(
        clk: in  std_logic; 							-- system clock
        dataIN: in  std_logic_vector(N-1 downto 0);    	-- datele pentru parallel load
        load: in  std_logic; 							-- semnalul pentru load
        enable: in  std_logic; 							-- permite numararea crescatoare
        reset: in  std_logic; 							-- reset
		terminalCount: out std_logic;					-- terminal count
        Q: out std_logic_vector(N-1 downto 0) 			-- output
        );
end component;	


component Depunere_Numerar is
	port(
	enable: in std_logic;
	Suma_Depusa: in std_logic_vector(15 downto 0);	       -- BCD (primii 4 biti rep nr bancnote de 500, urmatorii 4 de 100....)
	atmBanc10, atmBanc50, atmBanc100, atmBanc500: in std_logic_vector(7 downto 0);	  -- bancnotele din ATM
	uBanc10, uBanc50, uBanc100, uBanc500: out std_logic_vector(7 downto 0);		-- bancnotele actualizate din atm
	Suma_VecheClient: in std_logic_vector(15 downto 0);					   -- suma din contul clienului
	Suma_totala: out std_logic_vector(15 downto 0));					   -- suma noua (dupa depunere)  a clientului
end component;


-- memorii
component memorieClient is
	port(
	mode: in std_logic;								 -- 0 pentru a citi si 1 pentru a scrie
	adr: in std_logic_vector(15 downto 0);			 -- adresa
	dataOut: out std_logic_vector(14 downto 0));  	 -- codul memorat la adresa accesata RAM
end component;

component memoriePin is
	port(							
	mode: in std_logic; 								-- 0 pentru a citi si 1 pentru a scrie
	adr: in std_logic_vector(14 downto 0); 				-- adresa la care se scrie/citeste
	dataIn: in std_logic_vector(15 downto 0); 		    -- noul pin de introdus in RAM
	dataOut: out std_logic_vector(15 downto 0));    	-- pinul memorat la adresa accesata RAM
end component;

component memorieSumaClient is
	port(
		mode: in std_logic; 								-- 0 pentru a citi si 1 pentru a scrie
		adr: in std_logic_vector(14 downto 0); 				-- adresa la care se scrie/citeste
		dataOut: out std_logic_vector(15 downto 0); 		-- suma memorata la adresa accesata RAM
		dataIn: in std_logic_vector(15 downto 0));    		-- noua suma de introdus in RAM
end component;

component Interogare_Sold is 
	port(
	enable: in std_logic;
	clk: in std_logic; 
	segment: out std_logic_vector(6 downto 0); 
	anod: out std_logic_vector(3 downto 0);
	c4, c3, c2, c1: in std_logic_vector(3 downto 0));
end component; 

signal newPinRAM: std_logic_vector(15 downto 0);

-- definim starile
type stari is (s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11);
signal st_curenta, st_urmatoare: stari := s1;

-- semnalele utilizate
signal sumaClient, numar, sumaNoua, sumaNouaR, sumaNouaD: std_logic_vector(15 downto 0);
signal IDintern: std_logic_vector(14 downto 0);
signal codCard, pinCard: std_logic_vector(15 downto 0);
signal Banc10, Banc50, Banc100, Banc500: std_logic_vector(7 downto 0):= "10011111";
signal ScadeSuma10, ScadeSuma50, ScadeSuma100, ScadeSuma500: std_logic_vector(7 downto 0);
signal uBanc10, uBanc50, uBanc100, uBanc500: std_logic_vector(7 downto 0);
						   
signal mode, dep: std_logic:= '0';
signal cit_cod, cit_pin, cit_num, blocare, int_sold, schimb_pin, ok_card, ok_pin: std_logic;
signal count3: integer:= 0;
signal card_introdus, chitanta: std_logic;
signal afis10, afis50, afis100, afis500: std_logic_vector(6 downto 0);
signal ret: std_logic_vector(0 downto 0):= "0";

begin
	Parcurgere: process( st_curenta )
	begin
		case st_curenta is
			when s1 => 	chitanta <= '0';
						blocare <= '0';
						if cit_cod = '1' then
							st_urmatoare <= s2;
						else cit_cod <= '1';
							st_urmatoare <= s11;
						end if;
			when s2 => if ok_card = '1' then
							st_urmatoare <= s3;
							cit_cod <= '0';
							cit_pin <= '1';
						else st_urmatoare <= s1;
						end if;
			when s3 =>  if ok_pin = '1' then
							cit_pin <= '0';
							st_urmatoare <= s4;
						elsif count3 = 2 then
					 		blocare <= '1';
							cit_pin <= '0';
							st_urmatoare <= s1;
						else count3 <= count3 + 1;
							st_urmatoare <= s2;
						end if;
			when s4 => if operatie = "11" then
							cit_num <= '0';
							st_urmatoare <= s5;
						else cit_num <= '1'; 
							st_urmatoare <= s6;
						end if;
			when s5 => int_sold <= '1';
						st_urmatoare <= s10;
			
			when s6 => if operatie = "00" then
							st_urmatoare <= s7;
						elsif operatie = "01" then
							st_urmatoare <= s8;
						elsif operatie = "10" then
							st_urmatoare <= s9;
						end if;
			when s7 => cit_num <= '0';
						ret <= "1";
						st_urmatoare <= s10;
			when s8 => cit_num <= '0';
						dep <= '1';
						st_urmatoare <= s10;
			when s9 => cit_num <= '0';
						schimb_pin <= '1';
						st_urmatoare <= s10;
			when s10 => chitanta <= chitanta_in;
						schimb_pin <= '0';
						dep <= '0';
						ret <= "0";
						int_sold <= '0';
						st_urmatoare <= s1;
			when s11 => st_urmatoare <= s1;
		end case;
	end process Parcurgere;
	
	Continuare: process( continua )
	begin
		if continua'EVENT and continua = '1' then
			st_curenta <= st_urmatoare;
		end if;
	end process Continuare;
	chitanta_out <= chitanta;
	cardIntrodus <= ok_card and not(blocare);
	cardBlocat <= blocare;
	
	process( uBanc10, uBanc50, uBanc100, uBanc500, ScadeSuma10, ScadeSuma50, ScadeSuma100, ScadeSuma500 )
	begin
		if ret = "1" then 
		Banc10 <= uBanc10;
		Banc50 <= uBanc50;
		Banc100 <= uBanc100;
		Banc500 <= uBanc500;	
		end if;
		
		if dep='1' then 
		Banc10 <= ScadeSuma10;
		Banc50 <= ScadeSuma50;
		Banc100 <= ScadeSuma100;
		Banc500 <= ScadeSuma500;
		end if;
		
	end process;
	
	process(sumaNouaR, sumaNouaD)
	begin
		if ret= "1"	then
			sumaNoua <= sumaNouaR;
		end if;
		if dep='1' then
			sumaNoua <= sumaNouaD;
		end if;
		
	end process;
	
	process( sumaNoua )
	begin
		mode <= ret(0) or dep;
	end process;

Citire_Card: 	Citire port map( cifra, switch, cit_cod, clk, codCard );
Verif_Card: 	Verificare_Card port map( cit_cod, codCard, ok_card, IDintern ); 

Citire_pin: 	Citire port map( cifra, switch, cit_pin, clk, pinCard );
Verif_Pin: 		Verificare_Pin port map( pinCard, cit_pin, ok_pin, IDintern );	

Blocare_Card:	memorieClient port map( blocare, codCard, IDintern );  

Modif_Suma_Client:	memorieSumaClient port map(mode, IDintern, sumaClient, sumaNoua);

Citire_numar: 	Citire port map( cifra, switch, cit_num, clk, numar );
Schimba_Pin:	memoriePin port map ( schimb_pin, IDintern, numar, newPinRAM );	    -- suprascrie noul pin la adresa numarului clientului
Retrag:			Retragere_Numerar port map( ret, numar, sumaClient, Banc10, Banc50, Banc100, Banc500, ScadeSuma10, ScadeSuma50, ScadeSuma100, ScadeSuma500,
					AScadeSuma10, AScadeSuma50, AScadeSuma100, AScadeSuma500, sumaNouaR, Fail );
Depun:			Depunere_Numerar port map( dep, numar, Banc10, Banc50, Banc100, Banc500, 
								uBanc10, uBanc50, uBanc100, uBanc500, SumaClient, sumaNouaD );
Interogare: 	Interogare_Sold port map( int_sold, clkA, segmente, afisor, sumaClient(15 downto 12), sumaClient(11 downto 8), sumaClient(7 downto 4), sumaClient(3 downto 0) ); 

end Main;

