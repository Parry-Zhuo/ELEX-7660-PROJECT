// ELEX 7660
// File: freqGen.sv
// Description:  generates a clock for the waveform generator at the desired frequency  
// Author: Bryce Reid    Student ID: A01298718    Date: 2025-03-05

module freqGen #( parameter FCLK ) // system clock frequency, Hz 
		( input logic [6:0] freq, // index of desired waveform frequency 
		  output logic wclk, // wave clock 
		  input logic reset_n, clk ) ; // reset and system clock 

	logic [11:0] count ; // clock cycle count

	// frequency of wclk required to generate a waveform at the desired bpm with a 9-bit resolution
	// frequency of wclk must be 2^9 times faster than desired waveform frequency
	// available frequencies range from 30 bpm to 400 bpm in 5 bpm increments
	logic [0:74][11:0] freq_wclk ;

	assign freq_wclk = { 12'd256,  12'd299,  12'd341,  12'd384,  12'd427,  12'd469,  12'd512,  12'd555,  12'd597,  12'd640,  
			     12'd683,  12'd725,  12'd768,  12'd811,  12'd853,  12'd896,  12'd939,  12'd981,  12'd1024, 12'd1067,  
			     12'd1109, 12'd1152, 12'd1195, 12'd1237, 12'd1280, 12'd1323, 12'd1365, 12'd1408, 12'd1451, 12'd1493,  
			     12'd1536, 12'd1579, 12'd1621, 12'd1664, 12'd1707, 12'd1749, 12'd1792, 12'd1835, 12'd1877, 12'd1920,  
			     12'd1963, 12'd2005, 12'd2048, 12'd2091, 12'd2133, 12'd2176, 12'd2219, 12'd2261, 12'd2304, 12'd2347,  
			     12'd2389, 12'd2432, 12'd2475, 12'd2517, 12'd2560, 12'd2603, 12'd2645, 12'd2688, 12'd2731, 12'd2773,  
			     12'd2816, 12'd2859, 12'd2901, 12'd2944, 12'd2987, 12'd3029, 12'd3072, 12'd3115, 12'd3157, 12'd3200,  
			     12'd3243, 12'd3285, 12'd3328, 12'd3371, 12'd3413 } ;

	always_ff @( posedge clk, negedge reset_n ) begin
		
		// reset conditions
		if ( ~reset_n ) 
			{ count, wclk } <= '0 ;

		// divide system clock frequency to generate wclk at desired frequency
		else if ( count < FCLK - ( freq_wclk[freq] << 1 ) ) 
			count <= count + ( freq_wclk[freq] << 1 ) ;
		else begin
			wclk <= ~wclk ;
			count <= '0 ;
		end
	end

endmodule
