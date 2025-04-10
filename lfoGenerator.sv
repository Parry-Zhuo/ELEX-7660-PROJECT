// File: lfoGenerator.sv
// Description: ELEX 7660 lab project: LFO Generator top-level module. 
// Original Author: Robert Trost 
// Date: 2024-01-11
// Edited by: Bryce Reid and Parry Zhuo
// Date: 2025-02-23
 
module lfoGenerator (
    input logic CLOCK_50,        // 50 MHz clock
    (* altera_attribute = "-name WEAK_PULL_UP_RESISTOR ON" *) 
    input logic enc1_a, enc1_b,  // Encoder 1 pins
    (* altera_attribute = "-name WEAK_PULL_UP_RESISTOR ON" *)
    input logic enc2_a, enc2_b,  // Encoder 2 pins
    input logic s1,              // Active low pushbutton (Reset)
    output logic [17:3] GPIO_0   // GPIO pins for DAC SPI + LCD
//	 output logic red, green, blue
);

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
	logic lcd_RS, lcd_RW, lcd_E ;							// LCD interface configuration signals
	logic [7:0] lcd_Data ;							// LCD interface data

	 	// use count to divide wave clock for LED rate indicator
  	always_ff @( posedge wclk ) 
   	 	rateLED <= rateLED + 1'b1 ;
  
  	always_comb begin
		reset_n = s1 ; 					// implement reset button on S1
//		GPIO_0[0:2] = { DAC_CSB, DAC_SCLK, DAC_DIN } ; 	// DAC interface SPI communication signals
		GPIO_0[3] = onOff ; 				// on/off LED indicator signal 
		GPIO_0[4] = rateLED[8] ; 			// output waveform rate LED indicator signal
		GPIO_0[5] = lcd_RS;        // Register Select GPIO_0[4]
		//		GPIO_0[5] = lcd_RW;        // Read/Write GPIO_0[5]
		GPIO_0[6] = lcd_E;    //The LCD reads data only on the falling edge of E (from HIGH → LOW). For bits DB7-0:   GPIO_0[6]
		GPIO_0[15:8] = lcd_Data;// LCD Data Bus (GPIO_7 to GPIO_15)
  	end  


    
    // Instantiate LCD Controller6
	 
	encoder encoder_1 ( .clk( CLOCK_50 ), .a( enc1_a ), .b( enc1_b ), .cw( enc1_cw ), .ccw( enc1_ccw ) ) ;
	encoder encoder_2 ( .clk( CLOCK_50 ), .a( enc2_a ), .b( enc2_b ), .cw( enc2_cw ), .ccw( enc2_ccw ) ) ;
	enc2sel enc2sel_0 ( .clk( CLOCK_50 ), .cw( enc1_cw ), .ccw( enc1_ccw ), .sel, .reset_n ) ;
	enc2val enc2val_0 ( .clk( CLOCK_50 ), .reset_n, .cw( enc2_cw ), .ccw( enc2_ccw ), .sel, .shape, .depth, .freq ) ;
//	freqGen #( 50000000 ) freqGen_0 ( .clk( CLOCK_50 ), .reset_n, .freq, .wclk ) ;
//	waveGen waveGen_0 ( .wclk, .s2, .reset_n, .data( dacData ), .shape, .depth, .onOff ) ;
//	dacInterface dacInterface_0 ( .clk( clk_div_count[5] ), .reset_n, .data( dacData ), .DAC_CSB, .DAC_SCLK, .DAC_DIN ) ;
	lcdDisplay lcdDisplay_0 ( 
    .CLOCK_50( CLOCK_50 ), 
    .rst( reset_n ), 
    .RS( lcd_RS ), 
    .RW( lcd_RW ), 
    .E( lcd_E ), 
    .data( lcd_Data ), 
    .sel( sel ), 
    .shape( shape ), 
    .depth( depth ), 
    .freq( freq )
);



endmodule