library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UartRx is
	generic(
		BIT_WIDTH : integer := 8;
		BAUD_PERIOD : integer := 6510
	);
	port(
		clock : in std_logic;
		reset : in std_logic;
		rxSerialIn : in std_logic;
		rxDataOut : out std_logic_vector( ( BIT_WIDTH - 1 ) downto 0);
		rxOutReady : out std_logic
	);
end UartRx;

architecture A_UartRx of UartRx is
		
	type RxStateType is ( resetState, idleState, startState, receiveState );
	signal rxState : RxStateType := resetState;
	
begin
	
	main : process( clock, rxState, reset, rxSerialIn ) is
		variable clockCounter : integer := 0;
		variable tickCounter : integer := 0;
		variable isTick : boolean := false;
		variable isTickEven : boolean := true;
	begin
if( rising_edge( clock ) ) then

		case rxState is
			
when resetState =>
				
				-- actions
				rxDataOut <= ( others => '0' );
				rxOutReady <= '0';
				clockCounter := 0;
				tickCounter := 0;
				isTick := false;
				isTickEven := true;
				
				-- state change
				if( reset = '1' ) then
					rxState <= resetState;
				else
					if( rxSerialIn = '1' ) then
						rxState <= idleState;
					else
						rxState <= startState;
					end if;	
				end if;
			
-- end resetState
					
when idleState =>
				
				-- actions
				
				-- this is for setting the ready bit high for only ~1 tick
				clockCounter := clockCounter + 1;
				if( clockCounter > BAUD_PERIOD ) then
					rxOutReady <= '0';
				end if;
				
				-- state change
				if( reset = '1' ) then
					rxState <= resetState;
				else
					if( rxSerialIn = '1' ) then
						rxState <= idleState;
					else
						rxState <= startState;
					end if;	
				end if;
			
-- end idleState
									
when startState =>
				
				-- actions
				rxDataOut <= ( others => '0' );
				rxOutReady <= '0';
				clockCounter := 0;
				tickCounter := 0;
				isTick := false;
				isTickEven := true;
				
				-- state change
				if( reset = '1' ) then
					rxState <= resetState;
				else
					rxState <= receiveState;
				end if;
			
-- end startState
				
when receiveState =>


							
				-- actions
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
							rxDataOut( tickCounter - 1 ) <= rxSerialIn;
						elsif( tickCounter = BIT_WIDTH + 1 ) then
							rxOutReady <= '1';
						end if;
						tickCounter := tickCounter + 1;
						isTickEven := false;
					end if;
				end if;
				
				-- state change
				if( reset = '1' ) then
					rxState <= resetState;
				else
					if( tickCounter = BIT_WIDTH + 2 ) then
						rxState <= idleState;
					else
						rxState <= receiveState;
					end if;	
				end if;
				
-- end receiveState
			
		end case;
		
end if;

	end process;
	
end A_UartRx;