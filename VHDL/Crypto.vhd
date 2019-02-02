library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Crypto is
	generic(
		BIT_WIDTH : integer := 8
	);
	port(
		sw_0 : in std_logic;
		sw_1 : in std_logic;
		dataIn : in std_logic_vector( ( BIT_WIDTH - 1 ) downto 0);
		dataOut : out std_logic_vector( ( BIT_WIDTH - 1 ) downto 0)
	);
end Crypto;

architecture A_Crypto of Crypto is
begin
	dataOut(0) <= dataIn(0) xor sw_0;
	dataOut(1) <= dataIn(1) xor '1';
	dataOut(2) <= dataIn(2) xor '1';
	dataOut(3) <= dataIn(3) xor '1';
	dataOut(4) <= dataIn(4) xor sw_1;
	dataOut(5) <= dataIn(5) xor '1';
	dataOut(6) <= dataIn(6) xor '1';
	dataOut(7) <= dataIn(7) xor '1';
	
end A_Crypto;