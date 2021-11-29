library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity COUNTER is
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
end COUNTER;

architecture COUNTER_N of COUNTER is
	signal iQ : unsigned (N-1 downto 0):= (others => '0'); 
begin
	Q <= std_logic_vector(iQ); 
	process(clk, reset) 
	begin
		if enable = '1' then 					-- daca e permis, counter-ul functioneaza 
  			if reset = '0' then 				-- reset asincron pe logica negativa
     			iQ <= (others => '0');			-- seteaza counter-ul la 0
				terminalCount <= '0';			-- terminal count e 0 pentru ca nu s-a terminat bucla de numarare
  			elsif clk'EVENT and clk = '1' then
				terminalCount <= '0';
    			if load = '0' then  			-- load sincron pe logica negativa (prioritar incrementarii)
           			iQ <= unsigned(dataIN);
       			elsif (iQ = max) then 			-- daca s-a atins lmita maxima, 
         			iQ <= (others=>'0');		-- reseteaza conter-ul la 0
					terminalCount <= '1';		-- terminal count devine 1 pentru ca bucla de numarare s-a terminat
       			else   
					terminalCount <= '0';
					iQ <= iQ + 1; 				-- incrementeaza valoarea curenta a counter-ului
      			end if; 
    		end if;
   		end if;
	end process;

end COUNTER_N;