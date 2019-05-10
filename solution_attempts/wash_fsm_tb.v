////////////////////////////////////////////////////////////////////////////////
// Design Name:   washing_machine
// Module Name:   testbench.v
// Project Name:  TB
// Target Device: XC2S300E
// Tool versions: ISE 10.1 + ModelSIM or ISIM
// Description:   Washing Machine Controller TestBench
////////////////////////////////////////////////////////////////////////////////
/* 
 *    Notes: 
 *       1) Verilog code
 *       2) Simulation images of the circuit
 *       3) Place and route report for 50MHz
 *       4) Place and route report for the maximum frequency to which the circuit can operate
 *
 *       Clocked at 50 MHz (T = 20 ns) (50M ticks per second)
 *       (ucf diz: T=10ns 50%High)
 *       To reduce simulation time, use smaller time delays in the
 *       state transitions Wash->Drain and Speed->Ready. 
 *       Example: 
 *                Wash->Drain 160 ns     
 *                Speed->Ready 80 ns              
 */

`timescale 1 ns / 1 ns 
/* timescale 1ns/1ns means the time unit and time precision of a module that follow it.
 * The simulation time and delay values are measured using time unit. 
 * The precision factor is needed to measure the degree of accuracy of the time unit,
 * in other words how delay values are rounded before being used in simulation.
 * Whatever times you mensioned in verilog code will be taken in ns.eg.
 * Resolution of 1ns means you can have 1ns as smallest representation of the time.
 */

module testbench;

	// Inputs
	reg reset;
	reg clk;
	reg start;
	reg full;
	reg empty;
	reg cold;

	// Outputs
	wire ready;
	wire water_in;
	wire heat_r;
	wire wash;
	wire drain;
	wire speed;

	// Instantiate the Unit Under Test (UUT) or (DUT) Device Under Test
	wash_fsm uut (
		.reset(reset), 
		.clk(clk), 
		.start(start), 
		.full(full), 
		.empty(empty), 
		.cold(cold), 
		.ready(ready), 
		.water_in(water_in), 
		.heat_r(heat_r), 
		.wash(wash), 
		.drain(drain), 
		.speed(speed)
	);
   
   // Clock generator
   always
   #10.0 clk = ~clk; // Toggle clock every 10 ticks (T=20ns)

   initial begin
      // Initialize Inputs
		reset = 1;
		clk = 1;
		start = 0;
		full = 0;
		empty = 0;
		cold = 0;
      
      // Display initial message
      $display("Washing Machine FSM");
		
		// Add stimulus here
      @(negedge clk) 
         reset = 0;
		$display("Time = %t ns, reset assigned '0'", $time*10);
      @(negedge clk)
         start = 1;
      $display("Time = %t ns, start assigned '1'", $time*10);
      @(negedge clk)
         full = 1;
      $display("Time = %t ns, full assigned '1'", $time*10);
      @(negedge clk)
         cold = 1;
      $display("Time = %t ns, cold assigned '1'", $time*10);
      @(negedge clk)
         cold = 0;
      $display("Time = %t ns, cold assigned '0'", $time*10);
		while(drain != 1) begin #1; end
      @(negedge clk)
         empty = 1;
      while(ready != 1) begin #1; end
      $stop;		
  
				
      @(negedge clk)
         start = 1;
      $display("Time = %t ns, start assigned '1'", $time*10);
      @(negedge clk)
         full = 1;
      $display("Time = %t ns, full assigned '1'", $time*10);
      @(negedge clk)
         cold = 1;
      $display("Time = %t ns, cold assigned '1'", $time*10);
      @(negedge clk)
         cold = 0;
      $display("Time = %t ns, cold assigned '0'", $time*10);
		while(drain != 1) begin #1; end
      @(negedge clk)
         empty = 1;
      while(ready != 1) begin #1; end
      $stop;		
		end 
		
      always @(posedge ready)
         $display("Time = %t ns, entering Ready state", $time*10);
      always @(posedge water_in)
         $display("Time = %t ns, entering Water In state", $time*10);
      always @(posedge wash)
         $display("Time = %t ns, entering Wash state", $time*10);	
      always @(posedge drain)
         $display("Time = %t ns, entering Drain state", $time*10);
      always @(posedge speed)
         $display("Time = %t ns, entering Speed state", $time*10);
      always @(posedge heat_r)
         $display("Time = %t ns, heat_r asserted", $time*10);
      always @(negedge heat_r)
         $display("Time = %t ns, heat_r de-asserted", $time*10);
			
endmodule