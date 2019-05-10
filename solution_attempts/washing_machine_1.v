module counter(clk, reset, cycles, /*done*/);
input clk, reset, cycles;
//output done;
//reg done;
reg [7:0]count;

always @ (posedge clk or posedge reset)
	begin: timer_implementation
		while(count <= cycles && cycles!=0) begin
			if (reset) count <= 0;
			else	count <= count + 1;
		end
		//done <= 1'b1;
	end
endmodule

module washing_machine (clk, reset, start, full, cold, empty, ready, water_in, wash, drain, speed, heat_r, duration);
input clk, reset, start, full, cold, empty;
output ready, water_in, wash, drain, speed, heat_r, duration;
parameter state0=0, state1=1, state2=2, state3=3, state4=4;
reg [2:0] state, nxt_st;
reg ready, water_in, wash, drain, speed, heat_r;
reg [7:0] duration;

always @ (state or start or full or cold or empty)
	begin: next_state_logic
		case(state)
			state0:  begin
								if (start) nxt_st = state1;
								else nxt_st = state0;
						end
			state1:  begin
								if (full) nxt_st = state2;
								else nxt_st = state1;
						end
			state2:  begin
								duration <= 8'd40; 
								//wait 4 seconds - 20 cycles
								nxt_st = state3;
						end
			state3:  begin
								if (empty) nxt_st = state4;
								else nxt_st = state3;
						end
			state4:  begin
							duration <= 8'd20; 
							/*wait 2 seconds - 10 cycles*/
							nxt_st = state0;
						end
			default: begin
							duration <= 8'd0;
							nxt_st = state0;
						end
		endcase
	end
	
// Timer instantiation
counter counter_1(.clk(clk), .reset(reset), .cycles(duration)/*, .done(done)*/);
	
always @ (posedge clk or posedge reset) 
	begin: register_generation
		if (reset) state = state0;
		else state = nxt_st;
	end

always @ (state or cold) 
	begin: output_logic
		case (state)
			state0: ready = 1'b1;
			state1: water_in = 1'b1;
			state2:	begin
							if (cold) heat_r = 1'b1;
							wash = 1'b1;
						end
			state3: drain = 1'b1;
			state4: speed = 1'b1;
			default: ready = 1'b1;
		endcase
	end	
endmodule
		