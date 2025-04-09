// File: lfoGenerator.sv
// Description: ELEX 7660 lab project: LFO Generator top-level module. 
// Original Author: Robert Trost 
// Date: 2024-01-11
// Edited by: Bryce Reid
// Date: 2025-02-23

module lfoGenerator ( input logic CLOCK_50,       			// 50 MHz clock
              	    (* altera_attribute = "-name WEAK_PULL_UP_RESISTOR ON" *) 
              	    input logic enc1_a, enc1_b, 			// encoder 1 pins
	       	    (* altera_attribute = "-name WEAK_PULL_UP_RESISTOR ON" *)
	      	    input logic enc2_a, enc2_b, 			// encoder 2 pins
	      	    input logic s1, //s2, 				// S1/S2 active low pushbuttons on the BoosterPack
		    output logic [2:0] GPIO_0 ) ;			// GPIO pins for DAC Interface SPI Communication
	  			
	logic [15:0] clk_div_count ; 					// count used to divide clock
   	logic enc1_cw, enc1_ccw, enc2_cw, enc2_ccw ; 			// encoder module outputs
  	logic reset_n ; 						// reset signal
	logic DAC_CSB, DAC_SCLK, DAC_DIN ;	
	//logic data_req, data_ack ;	
	logic [11:0] data ;

 	// instantiate modules to implement design
  	encoder encoder_1 ( .clk( CLOCK_50 ), .a( enc1_a ), .b( enc1_b ), .cw( enc1_cw ), .ccw( enc1_ccw ) ) ;
	encoder encoder_2 ( .clk( CLOCK_50 ), .a( enc2_a ), .b( enc2_b ), .cw( enc2_cw ), .ccw( enc2_ccw ) ) ;
	//dacInterface dacInterface_0 ( .clk( clk_div_count[5] ), .reset_n, .data_req, .data, .DAC_CSB, .DAC_SCLK, .DAC_DIN, .data_ack ) ;
	dacInterface dacInterface_0 ( .clk( clk_div_count[5] ), .reset_n, .data, .DAC_CSB, .DAC_SCLK, .DAC_DIN ) ;
	//waveGen waveGen_0 ( .clk( CLOCK_50 ), .test_signal(s2), .reset_n, .data_req, .data, .data_ack ) ;

	// use count to divide clock
  	always_ff @( posedge CLOCK_50 ) 
   	 	clk_div_count <= clk_div_count + 1'b1 ;
  
  	always_comb begin
		reset_n = s1 ; // implement reset button on S1
		// implement DAC Interface SPI Communication signals
		GPIO_0[0] = DAC_CSB ;
		GPIO_0[1] = DAC_SCLK ;
		GPIO_0[2] = DAC_DIN ;
  	end  

	assign data = 12'd819 ;


endmodule


