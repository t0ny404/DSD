library ieee;
use ieee.std_logic_1164.all;

entity TB is
end TB;

architecture Tba of TB is

component Main is
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
end component;

signal continua: std_logic;
signal		operatie: std_logic_vector(1 downto 0);
signal		cifra: std_logic_vector(3 downto 0);
signal		switch: std_logic;
signal		clk : std_logic := '0';
signal		clkA: std_logic := '0';
signal		chitanta_in: std_logic;	 
signal		afisor: STD_LOGIC_VECTOR(3 downto 0);
signal		segmente: STD_LOGIC_VECTOR(6 downto 0);
signal	chitanta_out: std_logic;	
signal		cardIntrodus: std_logic;
signal		cardBlocat: std_logic;
signal		Fail: std_logic;
signal		AScadeSuma10, AScadeSuma50, AScadeSuma100, AScadeSuma500: std_logic_vector(7 downto 0);

begin

mn: Main port map( continua, operatie, cifra, switch, clk, clkA, chitanta_in, afisor, segmente, chitanta_out, cardIntrodus, cardBlocat, Fail, AScadeSuma10, AScadeSuma50, AScadeSuma100, AScadeSuma500 );
	
	cifra <= "0000";
	switch <= '1';
	continua <='1';
	
	switch <= '0'; 
	cifra <= "0000";
	switch <= '1';
	
	switch <= '0'; 
	cifra <= "0000";
	switch <= '1';
	
	switch <= '0'; 
	cifra <= "0001";
	switch <= '1';	 
	
	switch <= '0';
	
	operatie <= "00";
	
	CLOCK1:
clk <=  '1' after 0.5 ns when clk = '0' else
	'0' after 0.5 ns when clk = '1'; 
	CLOCK2:
clkA <=  '1' after 10 ns when clkA = '0' else
	'0' after 10 ns when clk = '1';	 
	
	cifra <= "0010";
	switch <= '1';
	continua <='1';
	
	switch <= '0'; 
	cifra <= "0111";
	switch <= '1';
	
	switch <= '0'; 
	cifra <= "1001";
	switch <= '1';
	
	switch <= '0'; 
	cifra <= "0001";
	switch <= '1';	 
	
	switch <= '0';
	
	
	cifra <= "0011";
	switch <= '1';
	continua <='1';
	
	switch <= '0'; 
	cifra <= "0000";
	switch <= '1';
	
	switch <= '0'; 
	cifra <= "0000";
	switch <= '1';
	
	switch <= '0'; 
	cifra <= "0001";
	switch <= '1';	 
	
	switch <= '0';
	
	
	
end Tba;
