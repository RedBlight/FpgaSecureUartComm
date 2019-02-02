library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Receiver is
	generic(
		BIT_WIDTH : integer := 8;
		FRAME_SIZE : integer := 20;
		DATA_SIZE : integer := 16;
		BAUD_PERIOD : integer := 6510
	);
	port(
		clock : in std_logic;
		reset : in std_logic;
		txReady : in std_logic;
		serialIn : in std_logic;
		dataOut : out std_logic_vector( ( BIT_WIDTH - 1 ) downto 0 );
		dataReady : out std_logic
	);
end Receiver;

architecture A_Receiver of Receiver is
	
	type ReceiverStateType is ( resetState, idleState, startState, listenState, transmitState );
	type InnerRxStateType is ( idleState, startState, receiveState );
	signal receiverState : ReceiverStateType := resetState;
	
begin
	
	main : process( clock, reset, txReady, serialIn ) is
		variable txReadyPrev : std_logic;
		variable receiveCounter : integer;
		variable isTickEven : boolean := true;
		variable innerRxState : innerRxStateType := startState;
		variable innerRxCaseFlag : boolean;
		
		
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
			case receiverState is
		
when resetState =>


					-- actions
					dataReady <= '0';
					txReadyPrev := '0';
					receiveCounter := 0;
					isTickEven := true;
					innerRxState := startState;
					
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
						receiverState <= resetState;
					else
						if( serialIn = '1' ) then
							receiverState <= idleState;
						else
							receiverState <= startState;
						end if;	
					end if;
-- end resetState

when idleState =>

					-- actions
					dataReady <= '0';
					txReadyPrev := '0';
					receiveCounter := 0;
					isTickEven := true;
					innerRxState := startState;
					
					
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
						receiverState <= resetState;
					else
						if( serialIn = '1' ) then
							receiverState <= idleState;
						else
							receiverState <= startState;
						end if;	
					end if;
					
					
-- end idleState

when startState =>


					-- actions
					dataReady <= '0';
					txReadyPrev := '0';
					receiveCounter := 0;
					isTickEven := true;
					innerRxState := startState;
					
					dataReadyPrev := '0';
					dataListenCount := 0;
					sentCounter := 0;
					clockCounter := 0;
					tickCounter := 0;
					isTick := false;
					endTransmissionFlag := false;
					
					--
					dataFrame := ( others => '0' );
					--dataFrame( ( BIT_WIDTH * FRAME_SIZE - 1 ) downto ( BIT_WIDTH * FRAME_SIZE - 16 ) ) := ( others => '1' );
					--
					
					-- 00101011
					--dataFrame := ( others => '0' );
					--dataFrame( 15 downto 0 ) := "0010101100101011";
					--dataFrame( ( BIT_WIDTH * FRAME_SIZE - 1 ) downto ( BIT_WIDTH * FRAME_SIZE - 16 ) ) := "0010101100101011";
					--
					
					-- state change
					if( reset = '1' ) then
						receiverState <= resetState;
					else
						receiverState <= listenState;	
					end if;
					
-- end startState
					
when listenState =>



					-- actions
					
					innerRxCaseFlag := true;
					
					if( innerRxState = idleState and innerRxCaseFlag ) then
						if( serialIn = '1' ) then
							innerRxState := idleState;
						else
							innerRxState := startState;
						end if;
						
						innerRxCaseFlag := false;
					end if;
											
					if( innerRxState = startState and innerRxCaseFlag ) then
						clockCounter := 0;
						tickCounter := 0;
						isTick := false;
						isTickEven := true;
						innerRxState := receiveState;
						
						innerRxCaseFlag := false;
					end if;
					
					if( innerRxState = receiveState and innerRxCaseFlag ) then
						clockCounter := clockCounter + 1;
						if( clockCounter = BAUD_PERIOD ) then
							clockCounter := 0;
							isTick := true;
						else
							isTick := false;
						end if;
						
						if( isTick ) then
							if( isTickEven = false ) then
								isTickEven := true;
							else
								if( tickCounter = 0 ) then
									-- do nothing
								elsif( tickCounter > 0 and tickCounter < BIT_WIDTH + 1 ) then
									dataFrame( ( tickCounter - 1 ) + receiveCounter * BIT_WIDTH ) := serialIn;
									--rxDataOut( tickCounter - 1 ) <= rxSerialIn;
								elsif( tickCounter = BIT_WIDTH + 1 ) then
									--rxOutReady <= '1';
								end if;
								tickCounter := tickCounter + 1;
								isTickEven := false;
							end if;
						end if;
						innerRxCaseFlag := false;
					end if;
					
					if( tickCounter = BIT_WIDTH + 2 ) then
						clockCounter := 0;
						tickCounter := 0;
						isTick := false;
						isTickEven := true;
						receiveCounter := receiveCounter + 1;
						innerRxState := idleState;
					end if;
					
					if( receiveCounter = FRAME_SIZE ) then
						--
					end if;
					
					-- state change
					if( reset = '1' ) then
						receiverState <= resetState;
					else
						if( receiveCounter = FRAME_SIZE ) then
							receiverState <= transmitState;
						else
							receiverState <= listenState;
						end if;	
					end if;
					
-- end listenState
										
when transmitState =>



					-- actions
					if( txReady = '1' ) then
						if( txReadyPrev = '0' ) then
							txReadyPrev := '1';
							dataOut <= dataFrame( BIT_WIDTH * ( 3 + sentCounter ) - 1 downto BIT_WIDTH * ( 2 + sentCounter ) );
							dataReady <= '1';
							sentCounter := sentCounter + 1;
						else
							-- do nothing
						end if;
					else
						if( txReadyPrev = '1' ) then
							dataReady <= '0';
							txReadyPrev := '0';
						else
							-- do nothing
						end if;
					end if;
						
					if( sentCounter = DATA_SIZE ) then
						--dataReady <= '1';
					end if;
					
					-- state change
					if( reset = '1' ) then
						receiverState <= resetState;
					else
						if( sentCounter = DATA_SIZE ) then
							receiverState <= idleState;
						else
							receiverState <= transmitState;
						end if;	
					end if;










					
					
-- end transmitState
		
			end case;
		end if;
	end process;

end A_Receiver;
