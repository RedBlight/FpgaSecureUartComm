library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Transmitter is
	generic(
		BIT_WIDTH : integer := 8;
		FRAME_SIZE : integer := 20;
		DATA_SIZE : integer := 16;
		BAUD_PERIOD : integer := 13020
	);
	port(
		clock : in std_logic;
		reset : in std_logic;
		dataReady : in std_logic;
		dataIn : in std_logic_vector( ( BIT_WIDTH - 1 ) downto 0 );
		serialOut : out std_logic
	);
end Transmitter;

architecture A_Transmitter of Transmitter is
	
	type TransmitterStateType is ( resetState, idleState, startState, listenState, transmitState );
	signal transmitterState : TransmitterStateType := resetState;
	
begin
	
	main : process( clock, reset, dataReady, dataIn ) is
		variable dataReadyPrev : std_logic;
		variable dataFrame : std_logic_vector( ( BIT_WIDTH * FRAME_SIZE - 1 ) downto 0);
		variable dataListenCount : integer;
		variable sentCounter : integer;
		
		variable clockCounter : integer := 0;
		variable tickCounter : integer := 0;
		variable isTick : boolean := false;
		
		variable endTransmissionFlag : boolean := false;
	begin
		if( rising_edge( clock ) ) then
			case transmitterState is
		
when resetState =>
					-- actions
					serialOut <= '1';
					dataReadyPrev := '0';
					dataFrame := ( others => '0' );
					dataListenCount := 0;
					sentCounter := 0;
					clockCounter := 0;
					tickCounter := 0;
					isTick := false;
					endTransmissionFlag := false;
					
					-- state change
					if( reset = '1' ) then
						transmitterState <= resetState;
					else
						if( dataReady = '1' ) then
							transmitterState <= startState;
						else
							transmitterState <= idleState;
						end if;	
					end if;
-- end resetState

when idleState =>
					-- actions
					serialOut <= '1';
					dataReadyPrev := '0';
					dataFrame := ( others => '0' );
					dataListenCount := 0;
					sentCounter := 0;
					clockCounter := 0;
					tickCounter := 0;
					isTick := false;
					endTransmissionFlag := false;
					
					-- state change
					if( reset = '1' ) then
						transmitterState <= resetState;
					else
						if( dataReady = '1' ) then
							transmitterState <= startState;
						else
							transmitterState <= idleState;
						end if;	
					end if;
					
					
-- end idleState

when startState =>
					-- actions
					serialOut <= '1';
					dataReadyPrev := '0';
					dataListenCount := 0;
					sentCounter := 0;
					clockCounter := 0;
					tickCounter := 0;
					isTick := false;
					endTransmissionFlag := false;
					
					--
					dataFrame := ( others => '0' );
					dataFrame( ( BIT_WIDTH * FRAME_SIZE - 1 ) downto ( BIT_WIDTH * FRAME_SIZE - 16 ) ) := ( others => '1' );
					--
					
					-- 00101011
					--dataFrame := ( others => '0' );
					--dataFrame( 15 downto 0 ) := "0010101100101011";
					--dataFrame( ( BIT_WIDTH * FRAME_SIZE - 1 ) downto ( BIT_WIDTH * FRAME_SIZE - 16 ) ) := "0010101100101011";
					--
					
					-- state change
					if( reset = '1' ) then
						transmitterState <= resetState;
					else
						transmitterState <= listenState;	
					end if;
					
-- end startState
					
when listenState =>
					-- actions
					if( dataReady = '1' ) then
						if( dataReadyPrev = '0' ) then
							dataReadyPrev := '1';
							dataFrame( BIT_WIDTH * ( 3 + dataListenCount ) - 1 downto BIT_WIDTH * ( 2 + dataListenCount ) ) := dataIn;
							dataListenCount := dataListenCount + 1;
						else
							-- do nothing
						end if;
					else
						if( dataReadyPrev = '1' ) then
							dataReadyPrev := '0';
						else
							-- do nothing
						end if;
					end if;
					
					if( dataListenCount = DATA_SIZE ) then
						serialOut <= '0';
					end if;
					
					-- state change
					if( reset = '1' ) then
						transmitterState <= resetState;
					else
						if( dataListenCount = DATA_SIZE ) then
							transmitterState <= transmitState;
						else
							transmitterState <= listenState;
						end if;	
					end if;
					
					
-- end listenState
										
when transmitState =>
					-- actions
					clockCounter := clockCounter + 1;
					if( clockCounter = BAUD_PERIOD ) then
						clockCounter := 0;
						isTick := true;
					else
						isTick := false;
					end if;
					
					if( isTick ) then
						if( tickCounter >= 0 and tickCounter < BIT_WIDTH ) then
							serialOut <= dataFrame( tickCounter + sentCounter * BIT_WIDTH );
						elsif( tickCounter = BIT_WIDTH ) then
							serialOut <= '1';
						elsif( tickCounter = BIT_WIDTH + 1 ) then
							serialOut <= '1';
						end if;
						tickCounter := tickCounter + 1;
					end if;
					
					if( tickCounter = BIT_WIDTH + 2 ) then
						serialOut <= '0';
						clockCounter := 0;
						tickCounter := 0;
						isTick := false;
						sentCounter := sentCounter + 1;
					end if;
					
					if( sentCounter = FRAME_SIZE ) then
						serialOut <= '1';
						sentCounter := 0;
						endTransmissionFlag := true;
					end if;
					
					-- state change
					if( reset = '1' ) then
						transmitterState <= resetState;
					else
						if( endTransmissionFlag ) then
							transmitterState <= idleState;
						else
							transmitterState <= transmitState;
						end if;	
					end if;
					
					
-- end transmitState
		
			end case;
		end if;
	end process;

end A_Transmitter;
