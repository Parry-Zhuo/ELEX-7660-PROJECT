module lcdDisplay_tb ;

 		logic clk = 1;// 50 MHz clock// System clock
    	logic        rst = 1;      // Reset signal,  GPIO_0[3]
    	logic        RS;    // Register Select GPIO_0[4]
    	logic        RW;     // Read/Write GPIO_0[5]
    	logic        E;         //The LCD reads data only on the falling edge of E (from HIGH → LOW). For bits DB7-0:   GPIO_0[6]
    	logic [12:0]  data;       // Data bus GPIO_0[7:15]   bcitid uut1 (.*);
   



	lcdDisplay displayUT_0(.*);
   	
    /* 
	GOAL: 
	1. Verify E is toggling properly
	2. Ensure initial states are transitioning correctly
	---
	Test plan
	1. Verify RESET WORKS - done
	2. Verify E toggles at half_way point for the first 3 states. Read value of (E == 1)
		state 1 - togglePoint = 2000/2 posedge  + 1 negedge
		state 2 - togglePoint = 513/2 posedge + 1 negedge
		state 3 - togglePoint = 150/2 posedge + 1 negedge
	This will be checked by temporarily putting COUNTER INTO DATA to verify the correct waveforms
	*/
	logic tb_fail = 0 ;	
	initial begin
        // Apply reset

        rst = 0;
		repeat(20) @(negedge clk) ;
        rst = 1;
		repeat(20) @(negedge clk) ;
        rst = 0;
		repeat(20) @(negedge clk) ;
		rst = 1;
		repeat(20) @(negedge clk) ;
        // Run simulation

		//state 1 - togglePoint = 2000/2 posedge  + 1 negedge
		@(posedge E)
		@(negedge clk);
		tb_fail |=(~E);

//		//state 2 - togglePoint = 513/2 posedge + 1 negedge
		@(posedge E)
		@(negedge clk);
		tb_fail |=(~E);
//
//		//state 3 - togglePoint = 150/2 posedge + 1 negedge
		@(posedge E)
		@(negedge clk);
		tb_fail |=(~E);

		repeat(3000) @ (negedge clk);


		if (tb_fail) begin
			$display("FAIL: E not high at half-period for first 3 states of initialization");
		end else begin
			$display("PASS: E is high at INIT half-period");
		end
        $stop;
    end

   	initial clk = 0;
	always #5120 clk = ~clk; // 10.24 μs clock

endmodule