library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UartTx is
	generic(
		BIT_WIDTH : integer := 8;
		BAUD_PERIOD : integer := 13020
	);
	port(
		clock : in std_logic;
		reset : in std_logic;
		txInReady : in std_logic;
		txDataIn : in std_logic_vector( ( BIT_WIDTH - 1 ) downto 0);
		txSerialOut : out std_logic;
		txTransmissionDone : out std_logic
	);
end UartTx;

architecture A_UartTx of UartTx is
	
	type TxStateType is ( resetState, idleState, startState, transmitState );
	signal txState : TxStateType := resetState;
	
begin
	
	main : process( clock, txState, reset, txInReady, txDataIn ) is
		variable clockCounter : integer := 0;
		variable tickCounter : integer := 0;
		variable isTick : boolean := false;
		variable hasTransmissionStarted : boolean := false;
		variable txDataCopy : std_logic_vector( ( BIT_WIDTH - 1 ) downto 0);
	begin
if( rising_edge( clock ) ) then

		case txState is
		
when resetState =>

				-- actions
				txSerialOut <= '1';
				txTransmissionDone <= '1';
				clockCounter := 0;
				tickCounter := 0;
				isTick := false;
				
				-- state change
				if( reset = '1' ) then
					txState <= resetState;
				else
					if( txInReady = '1' ) then
						txState <= startState;
					else
						txState <= idleState;
					end if;	
				end if;

-- end resetState

when idleState =>

				-- actions
				txSerialOut <= '1';
				txTransmissionDone <= '1';
				clockCounter := 0;
				tickCounter := 0;
				isTick := false;
				
				-- state change
				if( reset = '1' ) then
					txState <= resetState;
				else
					if( txInReady = '1' ) then
						txState <= startState;
					else
						txState <= idleState;
					end if;	
				end if;

-- end idleState

when startState =>

				-- actions
				txDataCopy := txDataIn;
				txSerialOut <= '0';
				txTransmissionDone <= '0';
				clockCounter := 0;
				tickCounter := 0;
				isTick := false;
				
				-- state change
				if( reset = '1' ) then
					txState <= resetState;
				else
					txState <= transmitState;	
				end if;

-- end startState

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
						txSerialOut <= txDataCopy( tickCounter );
						txTransmissionDone <= '0';
					elsif( tickCounter = BIT_WIDTH ) then
						txSerialOut <= '1';
						txTransmissionDone <= '0';
					elsif( tickCounter = BIT_WIDTH + 1 ) then
						txSerialOut <= '1';
						txTransmissionDone <= '1';
					end if;
					tickCounter := tickCounter + 1;
				end if;
				
				-- state change
				if( reset = '1' ) then
					txState <= resetState;
				else
					if( tickCounter = BIT_WIDTH + 2 ) then
						txState <= idleState;
					else
						txState <= transmitState;
					end if;	
				end if;

-- end transmitState
				
		end case;
		
end if;
	
	end process;
	
end A_UartTx;
	
	
	
	
	
	
	
--	copyData : process( clock, tick, txInReady ) is
--	begin
--		if( rising_edge( txInReady ) ) then
--			txDataCopy <= txDataIn;
--			txStarted <= '1';
--		end if;
--	end process;
	
--	maina : process( clock, tick ) is
--		variable tickCounter : integer := 0;
--		variable hasTransmissionStarted : boolean := false;
--	begin
--		if( rising_edge( tick ) ) then
--			if( reset = '1' ) then
--				txSerialOut <= '0';
--				txTransmissionDone <= '0';
--				tickCounter := 0;
--			else
--				if( txStarted = '1' ) then
--					if( tickCounter = 0 ) then
--						txSerialOut <= '0';
--						txTransmissionDone <= '0';
--						tickCounter := tickCounter + 1;
--					elsif( tickCounter > 0 and tickCounter < BIT_WIDTH + 1 ) then
--						txSerialOut <= txDataCopy( tickCounter );
--						txTransmissionDone <= '0';
--						tickCounter := tickCounter + 1;
--					elsif( tickCounter = BIT_WIDTH + 1 ) then
--						txSerialOut <= '1';
--						txTransmissionDone <= '1';
--						tickCounter := 0;
--						txStarted <= '0';
--					end if;
--				else
--					txSerialOut <= '0';
--					tickCounter := 0;
--				end if;
--			end if;
--		end if;
--	end process;
	
