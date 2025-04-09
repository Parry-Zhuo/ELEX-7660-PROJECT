// ELEX 7660
// File: dacInterface_tb.sv
// Description:  Testbench to check functionality of the dacInterface module
// Author: Bryce Reid    Student ID: A01298718    Date: 2025-03-18
// Sections of code taken from: encoder_tb.sv	Author: Robert Trost	Date: 2024-01-15

/*
// function: check_value()
// description: check to see that expected value matches actual value.  
// Returns '1' if test fails, '0' for pass
function logic check_value ( int expected_value, int actual_value ) ;

	if ( expected_value != actual_value ) begin
        	$display( "FAIL: expected value is %d => actual value is %d", expected_value, actual_value ) ;
        	check_value = 1 ;
    	end else begin
		$display( "PASS: expected value is %d => actual value is %d", expected_value, actual_value ) ;
        	check_value = 0 ;
	end

endfunction
*/
module dacInterface_tb ;

	//logic data_req = 0 ;		// update data request
	logic [11:0] data = 12'd819 ;     	// data to send to DAC
	logic DAC_CSB ;
	logic DAC_SCLK ;
	logic DAC_DIN ;
	//logic data_ack = 0 ;
	logic reset_n = 1 ;
	logic clk = 1 ; 		// testbench clock signal
	//logic test_trigger = 0 ;
//	logic tb_fail = 0 ; 		// flag to track if testbench failed

  	dacInterface dut_0 ( .* ) ; // device under test

  	initial begin

      		// reset
		reset_n = 0 ;
      		repeat(2) @(negedge clk) ;
      		reset_n = 1 ;
		repeat(50) @(negedge clk) ;

		reset_n = 0 ;
      		repeat(2) @(negedge clk) ;
      		reset_n = 1 ;
		repeat(100) @(negedge clk) ;

/*
		test_trigger = 1 ;
		repeat(1) @(negedge clk) ;
		test_trigger = 0 ;
		repeat(40) @(negedge clk) ;
		test_trigger = 1 ;
		repeat(1) @(negedge clk) ;
		test_trigger = 0 ;
		repeat(40) @(negedge clk) ;
*/
/*
      		if (tb_fail)
        		$display("Assignment 2 N-bit Sequence Detector Simulation *** FAILED ***  See transcript for details") ;
      		else
        		$display("Assignment 2 N-bit Sequence Detector Simulation *** PASSED ***") ;
*/
      		$stop ;
    
   	end
/*
   	always_ff @( negedge clk ) 
		if ( test_trigger || data_ack )
			data_req = ~data_req ;
*/
	// generate 6.25 MHz clock
   	always #80ns clk = ~clk ;
   
endmodule   
