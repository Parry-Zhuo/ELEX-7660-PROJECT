// File: lfoGenerator.sv
// Description: ELEX 7660 lab project: LFO Generator top-level module. 
// Author: Bryce Reid
// Date: 2025-02-23

module lfoGenerator ( input logic CLOCK_50,       				// 50 MHz clock
              	      (* altera_attribute = "-name WEAK_PULL_UP_RESISTOR ON" *) 
              	      input logic enc1_a, enc1_b, 				// encoder 1 pins
	       	      (* altera_attribute = "-name WEAK_PULL_UP_RESISTOR ON" *)
	      	      input logic enc2_a, enc2_b, 				// encoder 2 pins
	      	      input logic s1, s2, 					// S1/S2 active low pushbuttons on the BoosterPack
		      output logic [0:15] GPIO_0 ) ;				// GPIO pins
	  			
	logic [15:0] clk_div_count ; 						// count used to divide clock
	logic reset_n ; 							// reset signal
   	logic enc1_cw, enc1_ccw, enc2_cw, enc2_ccw ; 				// encoder module outputs
	logic [1:0] sel ;  							// parameter select
	logic [2:0] shape ;							// index for wave shape selection
	logic [2:0] depth ;							// index for wave depth selection
	logic [7:0] freq ;							// frequency index for selecting output waveform rate
	logic wclk ;								// wave clock for frequency generator 
	logic [15:0] rateLED ; 							// count used to divide wave clock for LED rate indicator
	logic onOff ;								// on/off signal	
	logic DAC_CSB, DAC_SCLK, DAC_DIN ;					// DAC interface SPI communication signals
	logic [11:0] dacData ;							// DAC interface data
	logic RS, RW, E ;							// LCD interface configuration signals
	logic [7:0] lcdData ;							// LCD interface data

 	// instantiate modules to implement design
  	encoder encoder_1 ( .clk( CLOCK_50 ), .a( enc1_a ), .b( enc1_b ), .cw( enc1_cw ), .ccw( enc1_ccw ) ) ;
	encoder encoder_2 ( .clk( CLOCK_50 ), .a( enc2_a ), .b( enc2_b ), .cw( enc2_cw ), .ccw( enc2_ccw ) ) ;
	enc2sel enc2sel_0 ( .clk( CLOCK_50 ), .cw( enc1_cw ), .ccw( enc1_ccw ), .sel, .reset_n ) ;
	enc2val enc2val_0 ( .clk( CLOCK_50 ), .reset_n, .cw( enc2_cw ), .ccw( enc2_ccw ), .sel, .shape, .depth, .freq ) ;
	freqGen #( 50000000 ) freqGen_0 ( .clk( CLOCK_50 ), .reset_n, .freq, .wclk ) ;
	waveGen waveGen_0 ( .wclk, .s2, .reset_n, .data( dacData ), .shape, .depth, .onOff ) ;
	dacInterface dacInterface_0 ( .clk( clk_div_count[5] ), .reset_n, .data( dacData ), .DAC_CSB, .DAC_SCLK, .DAC_DIN ) ;
	lcdDisplay #( 63 ) lcdDisplay_0 ( .CLOCK_50, .rst( reset_n ), .RS, .RW, .E, .data( lcdData ), .sel, .shape, .depth, .freq ) ;

	// use count to divide clock
  	always_ff @( posedge CLOCK_50 ) 
   	 	clk_div_count <= clk_div_count + 1'b1 ;

	// use count to divide wave clock for LED rate indicator
  	always_ff @( posedge wclk ) 
   	 	rateLED <= rateLED + 1'b1 ;
  
  	always_comb begin
		reset_n = s1 ; 					// implement reset button on S1
		GPIO_0[0:2] = { DAC_CSB, DAC_SCLK, DAC_DIN } ; 	// DAC interface SPI communication signals
		GPIO_0[3] = onOff ; 				// on/off LED indicator signal 
		GPIO_0[4] = rateLED[8] ; 			// output waveform rate LED indicator signal
		GPIO_0[5] = RS ;				// LCD interface configuration signal
		GPIO_0[6] = RW ;				// LCD interface configuration signal
		GPIO_0[7] = E ;					// LCD interface configuration signal
		GPIO_0[8:15] = lcdData ;			// LCD Interface data
  	end  

endmodule
