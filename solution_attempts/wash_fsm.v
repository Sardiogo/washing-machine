//////////////////////////////////////////////////////////////////////////////////
// Module Name:    wash_fsm.v 
// Project Name: 	Laboratory - Digital Circuits - State machine
// Target Devices: Basys 2 Spartan-3E FPGA
// Description: 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ns

module wash_fsm (clk,ready,water_in,wash,drain,speed,heat_r,reset,start,full,cold,empty);

	input clk, reset, start, full, cold, empty;
	output ready, water_in, wash,drain, speed, heat_r; 
	// output is declared reg so that it can be assigned in an always block: 
	reg ready, water_in, wash, drain, speed, heat_r;  
	
	parameter state0=0, state1=1, state2=2, state3=3, state4=4;
	reg[2:0] nxt_st = state0, state = state0;
	
	/* -------------------------------------------------------
	Clock -> f = 50MHz ->  T = 1/50M = 20ns 
	----------------------------------------------------------
	4 seconds -> 4 * 50M clock periods -> 4s = (200 000 000)*T  
	2 seconds -> 2 * 50M clock periods -> 2s = (100 000 000)*T
	----------------------------------------------------------
	200 000 000 = 101 11110 10111 10000 10000 00000 
	Nr of bits needed on register = 28bits 
	--------------------------------------------------------*/
	
	// Clock counter for countdown :
	reg[27:0] t = 0 ; 
	// State countdown start values	:
	parameter st2_counter = 200000000 , st4_counter = 100000000 ;
	// State countdown enabler :
	reg countdown_on = 0; 

	/*-------------------------------------------------------------------/
		 Always Block -> Time countdowns for states transitions
	/----------------------------------------------------------------- */
	always @(posedge clk) 
		begin: state_change_countdown	
				if (countdown_on) t = t + 1;
				else t = 0;
		end 

	/*-------------------------------------------------------------------/
		 		Always Block -> Device Inputs detection
	/----------------------------------------------------------------- */
	always @(*)
		begin : next_state_logic
			heat_r = 0;
			countdown_on = 0;
			nxt_st= state;
				case (state)		
				state0: begin
								countdown_on = 0;
								if (start) nxt_st = state1;
						  end
				state1: begin
								countdown_on = 0;
								if (full) nxt_st = state2;
						  end
				state2: begin
								if (cold) heat_r = 1;
								else heat_r = 0;
								countdown_on = 1;
								if (t == st2_counter-1) 
									begin
										nxt_st = state3;
										heat_r = 0;
									end							
						  end
				state3: begin
								countdown_on = 0;
								if (empty) nxt_st = state4;
						  end
				state4: begin
								countdown_on = 1;
								if (t == st4_counter-1) nxt_st = state0;
						  end
				
				default: nxt_st = state0; // default avoids latches*/
			endcase 
		end 

	/*-----------------------------------------------------------------------------------/
							Always Block -> Reset input detection
	/--------------------------------------------------------------------------------- */
	always @(posedge reset, posedge clk)
		begin : reset_detector
			if (reset) state <= state0;
			else state <= nxt_st;
		end

	/*-----------------------------------------------------------------------------------/
							Always Block -> Output actions on each state 
	/----------------------------------------------------------------------------------*/
	always @(state)
		begin : output_logic
				case (state)
					state0: begin ready=1;water_in=0;wash=0;drain=0;speed=0;end 
					state1: begin ready=0;water_in=1;wash=0;drain=0;speed=0;end 
					state2: begin ready=0;water_in=0;wash=1;drain=0;speed=0;end 
					state3: begin ready=0;water_in=0;wash=0;drain=1;speed=0;end
					state4: begin ready=0;water_in=0;wash=0;drain=0;speed=1;end 
					default begin ready=1;water_in=0;wash=0;drain=0;speed=0;end
				endcase
		end		
		
endmodule