library ieee;
use ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

-- A 16x4 RAM
entity memorieClient is
	port(
		mode: in std_logic;								 -- 0 pentru a citi si 1 pentru a scrie
		adr: in std_logic_vector(15 downto 0);			 -- adresa
		dataOut: out std_logic_vector(14 downto 0));  	 -- codul memorat la adresa accesata RAM	
end memorieClient;

architecture Ram of memorieClient is
	component BCDtoBin is
		port(		   
		dec: in std_logic_vector(15 downto 0);
		binar: out std_logic_vector(15 downto 0));
	end component;

	-- defineste tipul de structura care va memora codurile 
	type RAM_ARRAY is array (0 to 9999) of std_logic_vector (14 downto 0);
	
	-- valori initiale in RAM
	signal RAM: RAM_ARRAY :=(
		"000000000000000", 
		"000000000000001", 
		"000000000000010", 
		"000000000000011", 
		"000000000000100", 
		others => "000000000000000");
	signal adrBin: std_logic_vector(15 downto 0);
begin
	Convert: BCDtoBin port map(adr, adrBin);
	process(mode, RAM, adrBin)
	begin
		if mode = '0' then
			case adrBin is
				when "0000000000000001" => dataOut <= RAM(1);
				when "0000000000000010" => dataOut <= RAM(2);
				when "0000000000000011" => dataOut <= RAM(3);
				when "0000000000000100" => dataOut <= RAM(4);
				when others => dataOut <= "000000000000000";
			end case;
		else case adrBin is
			when "0000000000000001" => RAM(1)(14) <= '1';
			when "0000000000000010" => RAM(2)(14) <= '1';
			when "0000000000000011" => RAM(3)(14) <= '1';
			when "0000000000000100" => RAM(4)(14) <= '1';
			when others => null;
			end case;
		end if;
	end process;
end Ram;