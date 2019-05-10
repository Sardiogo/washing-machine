`timescale 1ns / 1ps

module wash(clk, ready, water_in, wash, drain, speed, heat_r, reset, start, full, cold, empty);
	
	input clk, reset, start, full, cold, empty;
	output reg ready, water_in, wash, drain, speed, heat_r;
	
	reg enable;
	reg[2:0] state, next_st;
	reg[31:0] count =32'd0;

	parameter st_ready=0, st_water_in=1, st_wash=2, st_drain=3, st_speed=4, st_heat_r=5;
	
	/*f_clk = 50MHz ->  T=1/50M = 20ns  */
	/* 4 segundos -> 4 * 50M flancos: 4s=200 000 000 flancos */
	/* 2 segundos -> 2 * 50M flancos 2s = 100 000 000*/
	
	parameter flancos = 200000000;
	parameter flancos2 = 100000000;	
	
	always@(state or start or full or cold or empty or count or enable or reset)
		begin: next_state_logic
		
			heat_r = 1'b0;
			enable = 0;
			next_st = state;
			
			case(state)
				st_ready: begin
										enable =0;
										if(start)next_st = st_water_in;
										else next_st = st_ready;
									end										
										
				st_water_in: begin
										enable =0;
										if(full)next_st = st_wash;
										else next_st = st_water_in;
									end
										
				st_wash: begin
										if(cold) heat_r=1;
										else heat_r=0;
										enable =1;
										if(count==flancos-1)
											begin
												next_st= st_drain;
												heat_r=0;
											end	
									end	
				st_drain: begin
										enable =0;
										if(empty)next_st = st_speed;
										else next_st = st_drain;
									end
									
				st_speed: begin
										enable=1;
										if(count==flancos2-1) next_st=st_ready;
										else next_st=st_speed;
									end	
										
				default: next_st = st_ready;
			endcase
		end
		
	/* A qualquer momento (ou estado) a máquina vai para o estado st_ready pressionando o botão reset */

	always@(posedge clk, posedge reset)
		begin: register_generation
			if(reset)
				state <= st_ready;
			else
				state <= next_st;
		end

	/*temporizador*/

	always @(posedge clk)
		begin: contador_de_flancos
			if(enable)
				count <= count +1;
			else
				count = 0;			
		end

	/*Leds a acender nos diferentes estados*/

	always @(state)
		begin:output_logic
			case(state)
				st_ready: begin ready=1;water_in=0;wash=0;drain=0;speed=0;end
				st_water_in: begin ready=0;water_in=1;wash=0;drain=0;speed=0;end
				st_wash: begin ready=0;water_in=0;wash=1;drain=0;speed=0;end
				st_drain: begin ready=0;water_in=0;wash=0;drain=1;speed=0;end
				st_speed: begin ready=0;water_in=0;wash=0;drain=0;speed=1;end
				default begin ready=1;water_in=0;wash=0;drain=0;speed=0;end

			endcase
		end
endmodule
