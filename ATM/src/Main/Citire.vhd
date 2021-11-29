library ieee;
use ieee.std_logic_1164.all;

entity Citire is							  
	port(
	cifra: in std_logic_vector(3 downto 0);	   -- cifra introdusa pe cele 4 switch-uri
	switchCifre: in std_logic;				   -- schimbarea intre unitati/zeci/sute/mii
	enable: in std_logic;
	clk: in std_logic;						   -- numarul cardului / pinul / suma
	cod: out std_logic_vector(15 downto 0));
end Citire;

architecture Construieste_Cod of Citire is
component COUNTER is
	generic(n: in  natural; 		-- number of bits
			max: in natural); 		-- maximum value of the counter
	port(
        clk: in  std_logic; 							-- system clock
        dataIN: in  std_logic_vector(N-1 downto 0);    	-- data in for parallel load
        load: in  std_logic; 							-- load signal
        enable: in  std_logic; 							-- count up enable
        reset: in  std_logic; 							-- reset the counter
		terminalCount: out std_logic;					-- terminal count
        Q: out std_logic_vector(N-1 downto 0) 			-- data out
        );
end component;	
signal ordinCifra: std_logic_vector(2 downto 0);
signal TC: std_logic;
begin
L1:	COUNTER  generic map(3, 4) port map(clk, "000", '1', switchCifre, '1', TC, ordinCifra);
	process (ordinCifra)
	begin
		if enable = '1' then
		if switchCifre = '1' then				-- am facut mii->sute->zeci->unitati
			if ordinCifra = "001" then			-- se poate modifica si in unitati->zeci->sute->mii
				cod(15 downto 12) <= cifra;		
			elsif ordinCifra = "010" then
				cod(11 downto 8) <= cifra;
			elsif ordinCifra = "011" then
				cod(7 downto 4) <= cifra;
			elsif ordinCifra = "100" then
				cod(3 downto 0) <= cifra;
			end if;
		end if;
		end if;
	end process;
end Construieste_Cod;
