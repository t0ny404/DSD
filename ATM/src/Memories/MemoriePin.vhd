library ieee;
use ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

-- A 4x16 RAM
entity memoriePin is
	port(
		mode: in std_logic; 								-- 0 pentru a citi si 1 pentru a scrie
		adr: in std_logic_vector(14 downto 0); 				-- adresa la care se scrie/citeste
		dataIn: in std_logic_vector(15 downto 0); 		    -- noul pin de introdus in RAM
		dataOut: out std_logic_vector(15 downto 0));    	-- pinul memorat la adresa accesata RAM
end memoriePin;

architecture Behavioral of memoriePin is
	-- defineste tipul de structura care va memora pin-urile 
	type RAM_ARRAY is array (0 to 9999) of std_logic_vector (15 downto 0);
	
	-- initial values in the RAM
	signal RAM: RAM_ARRAY :=(
		"0000000000000000",  				-- nu e niciun client cu codul 0
	   	"0010001101110110",  				-- 2376
	   	"0111010101000011",  				-- 7543
	   	"0001001000110100",  				-- 1234
	   	"1001100001100100",  				-- 9864
		others => "0000000000000000");		-- restul vor fi 0000
begin
	process(mode, adr, dataIn)
	begin
		if mode = '1' then 			-- daca avem de scris 
		RAM(to_integer(unsigned(adr))) <= dataIn;
		                            -- index-ul memoriei RAM trebuie sa fie intreg asa ca avem de convertit adresa:
									-- std_logic_vector -> Unsigned -> Interger (numeric_std library)
		else dataOut <= RAM(to_integer(unsigned(adr)));
		end if;
	end process; 
	
end Behavioral;