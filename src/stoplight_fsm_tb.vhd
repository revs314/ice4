--+----------------------------------------------------------------------------
--| 
--| COPYRIGHT 2017 United States Air Force Academy All rights reserved.
--| 
--| United States Air Force Academy     __  _______ ___    _________ 
--| Dept of Electrical &               / / / / ___//   |  / ____/   |
--| Computer Engineering              / / / /\__ \/ /| | / /_  / /| |
--| 2354 Fairchild Drive Ste 2F6     / /_/ /___/ / ___ |/ __/ / ___ |
--| USAF Academy, CO 80840           \____//____/_/  |_/_/   /_/  |_|
--| 
--| ---------------------------------------------------------------------------
--|
--| FILENAME      : stoplight_fsm_tb.vhd (TEST BENCH)
--| AUTHOR(S)     : Maj Jeff Falkinburg, Capt Phillip Warner, Capt Dan johnson, Capt Brian Yarbrough
--|					**Your Name**
--| CREATED       : Spring 2017 Last modified 06/24/2020
--| DESCRIPTION   : This file provides a solution testbench for the stoplight entity
--|
--+----------------------------------------------------------------------------
--|
--| REQUIRED FILES :
--|
--|    Libraries : ieee
--|    Packages  : std_logic_1164, numeric_std, unisim
--|    Files     : stoplight.vhd
--|
--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
 
entity stoplight_fsm_tb is
end stoplight_fsm_tb;
 
architecture behavior of stoplight_fsm_tb is 
 
    -- Component Declaration for the Unit Under Test (UUT)
    component stoplight_fsm
    port(
         i_C 	 : in  std_logic;
         i_reset : in  std_logic;
         i_clk 	 : in  std_logic;
         o_R 	 : out  std_logic;
         o_Y 	 : out  std_logic;
         o_G 	 : out  std_logic
        );
    end component;
    

	--Inputs
	signal w_C : std_logic := '0';
	signal w_reset : std_logic := '0';
	signal w_clk : std_logic := '0';
	
	--Outputs
	signal w_stoplight : std_logic_vector(2 downto 0) := "000"; -- RYG one-hot
		
	-- Clock period definitions
	constant k_clk_period : time := 10 ns;
 
begin
  	-- PORT MAPS ---------------------------------------------------
	-- Instantiate the Unit Under Test (UUT)
   uut: stoplight_fsm port map (
          i_C => w_C,
          i_reset => w_reset,
          i_clk => w_clk,
          o_R => w_stoplight(2),
          o_Y => w_stoplight(1),
          o_G => w_stoplight(0)
        );
	----------------------------------------------------------------
  
	-- PROCESSES --------------------------------------------------- 
	-- Clock process
	-- makes it blinking signal (0 to 1 to 0 to 1...)
	clk_proc : process
	begin
		w_clk <= '0';
        wait for k_clk_period/2; --makes low for half cycle
		w_clk <= '1';
		wait for k_clk_period/2; --makes high for half cycle
	end process;
	
	-- Simulation process
	-- Use 220 ns for simulation
	sim_proc: process
	begin
		-- sequential timing		
		w_reset <= '1';
		wait for k_clk_period*1;
		  assert w_stoplight = "010" report "bad reset" severity failure;
		
		w_reset <= '0';
		wait for k_clk_period*1;
		
		-- red light
		w_C <= '0'; wait for k_clk_period;
          assert w_stoplight = "100" report "should be red when no car" severity failure;
		-- car shows up at red light
        w_C <= '1'; wait for k_clk_period;
            assert w_stoplight = "001" report "should be green when car present" severity failure;
        wait for k_clk_period * 3; -- stay green
            assert w_stoplight = "001" report "should be green when car present" severity failure;
        -- go to yellow
        w_C <= '0'; wait for k_clk_period;
            assert w_stoplight = "010" report "should be yellow when cars done" severity failure;
        wait for k_clk_period; -- time to go to red
            assert w_stoplight = "100" report "did not go red after yellow" severity failure;
        
        -- reset and test yellow to red even if car
        w_reset <= '1'; w_C <= '1';
            wait for k_clk_period;
        w_reset <= '0';
          assert w_stoplight = "010" report "bad reset" severity failure;
        wait for k_clk_period;
            assert w_stoplight = "100" report "skipped red after yellow" severity failure;
        wait for k_clk_period;
            assert w_stoplight = "001" report "should be green when car present" severity failure;
	
		wait;
	end process;
	----------------------------------------------------------------
end;
