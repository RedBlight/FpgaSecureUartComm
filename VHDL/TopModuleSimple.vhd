library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TopModuleSimple is
	port(
--		led4_b : out std_logic;
--		led5_r : out std_logic;
--		led5_g : out std_logic;
--		led5_b : out std_logic;
--		led_0 : out std_logic;
--		led_1 : out std_logic;
--		led_2 : out std_logic;
		
		sw_0 : in std_logic;
		sw_1 : in std_logic;
		
		clock : in std_logic;
		reset : in std_logic;
		rxIn : in std_logic;
		txOut : out std_logic;
		modemIn : in std_logic;
		modemOut : out std_logic
	);
end TopModuleSimple;

architecture A_TopModuleSimple of TopModuleSimple is
	
	component UartRx
		generic(
			BIT_WIDTH : integer
		);
		port(
			clock : in std_logic;
			reset : in std_logic;
			rxSerialIn : in std_logic;
			rxDataOut : out std_logic_vector( ( BIT_WIDTH - 1 ) downto 0 );
			rxOutReady : out std_logic
		);
	end component UartRx;
	
	component UartTx is
		generic(
			BIT_WIDTH : integer
		);
		port(
			clock : in std_logic;
			reset : in std_logic;
			txInReady : in std_logic;
			txDataIn : in std_logic_vector( ( BIT_WIDTH - 1 ) downto 0 );
			txSerialOut : out std_logic;
			txTransmissionDone : out std_logic
		);
	end component UartTx;
	
	component Transmitter is
		generic(
			BIT_WIDTH : integer
		);
		port(
			clock : in std_logic;
			reset : in std_logic;
			dataReady : in std_logic;
			dataIn : in std_logic_vector( ( BIT_WIDTH - 1 ) downto 0 );
			serialOut : out std_logic
		);
	end component Transmitter;
	
	component Receiver is
		generic(
			BIT_WIDTH : integer
		);
		port(
			clock : in std_logic;
			reset : in std_logic;
			txReady : in std_logic;
			serialIn : in std_logic;
			dataOut : out std_logic_vector( ( BIT_WIDTH - 1 ) downto 0 );
			dataReady : out std_logic
		);
	end component Receiver;
			
	component Crypto is
		generic(
			BIT_WIDTH : integer
		);
		port(
			sw_0 : in std_logic;
			sw_1 : in std_logic;
			dataIn : in std_logic_vector( ( BIT_WIDTH - 1 ) downto 0 );
			dataOut : out std_logic_vector( ( BIT_WIDTH - 1 ) downto 0 )
		);
	end component Crypto;
	
	signal u2tDataPlain : std_logic_vector( 7 downto 0 );
	signal u2tDataEncrypted : std_logic_vector( 7 downto 0 );
	signal u2tReady : std_logic;
	
	signal u2rDataPlain : std_logic_vector( 7 downto 0 );
	signal u2rDataEncrypted : std_logic_vector( 7 downto 0 );
	signal u2rReady : std_logic;
	
	signal txReady : std_logic;
	
	signal txOutSignal : std_logic;
	signal modemOutSignal : std_logic;
	

	
	--signal dataInBetween : std_logic_vector( 7 downto 0 );
	--signal readyInBetween : std_logic;
	--signal transDone : std_logic;
	
begin

	uartRx1 : UartRx
	generic map(
		BIT_WIDTH => 8
	)
	port map(
		clock => clock,
		reset => reset,
		rxSerialIn => rxIn,
		rxDataOut => u2tDataPlain,
		rxOutReady => u2tReady
	);
	
	uartTx1 : UartTx
	generic map(
		BIT_WIDTH => 8
	)
	port map(
		clock => clock,
		reset => reset,
		txInReady => u2rReady,
		txDataIn => u2rDataPlain,
		txSerialOut => txOutSignal,
		txTransmissionDone => txReady
	);
	
	receiver1 : Receiver
	generic map(
		BIT_WIDTH => 8
	)
	port map(
		clock => clock,
		reset => reset,
		txReady => txReady,
		serialIn => modemIn,
		dataOut => u2rDataEncrypted,
		dataReady => u2rReady
	);
	
	transmitter1 : Transmitter
	generic map(
		BIT_WIDTH => 8
	)
	port map(
		clock => clock,
		reset => reset,
		dataReady => u2tReady,
		dataIn => u2tDataEncrypted,
		serialOut => modemOutSignal
	);
	
	encryptor : Crypto
	generic map(
		BIT_WIDTH => 8
	)
	port map(
		sw_0 => sw_0,
		sw_1 => sw_1,
		dataIn => u2tDataPlain,
		dataOut => u2tDataEncrypted
	);
	
	deccryptor : Crypto
	generic map(
		BIT_WIDTH => 8
	)
	port map(
		sw_0 => sw_0,
		sw_1 => sw_1,
		dataIn => u2rDataEncrypted,
		dataOut => u2rDataPlain
	);
	
	
	txOut <= txOutSignal;
	modemOut <= modemOutSignal;
	
	--led4_b <= not rxIn;
	--led5_b <= not txOutSignal;
	--led_0 <= readyInBetween;
	
end A_TopModuleSimple;