// ELEX 7660
// File: freqGen.sv
// Description:  generates a clock for the waveform generator at the desired frequency  
// Author: Bryce Reid    Student ID: A01298718    Date: 2025-03-05

module freqGen #( parameter FCLK ) 			// system clock frequency, Hz 
		( input logic [7:0] freq, 		// index of desired waveform frequency 
		  output logic wclk, 			// wave clock
		  input logic reset_n, clk ) ; 		// reset and system clock 

	logic [31:0] count ; 				// clock cycle count

	// frequency of wclk required to generate a waveform at the desired bpm with a 8-bit resolution
	// frequency of wclk must be 2^8 times faster than desired waveform frequency
	// available frequencies range from 30 bpm to 800 bpm in 5 bpm increments
	logic [0:154][15:0] freq_wclk ;

	assign freq_wclk = { 16'd128, 16'd149, 16'd171, 16'd192, 16'd213, 16'd235, 16'd256, 16'd277, 16'd299, 16'd320, 16'd341, 16'd363, 16'd384, 16'd405, 16'd427, 16'd448, 16'd469, 16'd491, 16'd512, 16'd533, 16'd555, 16'd576, 16'd597, 16'd619, 16'd640, 16'd661, 16'd683, 16'd704, 16'd725, 16'd747, 16'd768, 16'd789, 16'd811, 16'd832, 16'd853, 16'd875, 16'd896, 16'd917, 16'd939, 16'd960, 16'd981, 16'd1003, 16'd1024, 16'd1045, 16'd1067, 16'd1088, 16'd1109, 16'd1131, 16'd1152, 16'd1173, 16'd1195, 16'd1216, 16'd1237, 16'd1259, 16'd1280, 16'd1301, 16'd1323, 16'd1344, 16'd1365, 16'd1387, 16'd1408, 16'd1429, 16'd1451, 16'd1472, 16'd1493, 16'd1515, 16'd1536, 16'd1557, 16'd1579, 16'd1600, 16'd1621, 16'd1643, 16'd1664, 16'd1685, 16'd1707, 16'd1728, 16'd1749, 16'd1771, 16'd1792, 16'd1813, 16'd1835, 16'd1856, 16'd1877, 16'd1899, 16'd1920, 16'd1941, 16'd1963, 16'd1984, 16'd2005, 16'd2027, 16'd2048, 16'd2069, 16'd2091, 16'd2112, 16'd2133, 16'd2155, 16'd2176, 16'd2197, 16'd2219, 16'd2240, 16'd2261, 16'd2283, 16'd2304, 16'd2325, 16'd2347, 16'd2368, 16'd2389, 16'd2411, 16'd2432, 16'd2453, 16'd2475, 16'd2496, 16'd2517, 16'd2539, 16'd2560, 16'd2581, 16'd2603, 16'd2624, 16'd2645, 16'd2667, 16'd2688, 16'd2709, 16'd2731, 16'd2752, 16'd2773, 16'd2795, 16'd2816, 16'd2837, 16'd2859, 16'd2880, 16'd2901, 16'd2923, 16'd2944, 16'd2965, 16'd2987, 16'd3008, 16'd3029, 16'd3051, 16'd3072, 16'd3093, 16'd3115, 16'd3136, 16'd3157, 16'd3179, 16'd3200, 16'd3221, 16'd3243, 16'd3264, 16'd3285, 16'd3307, 16'd3328, 16'd3349, 16'd3371, 16'd3392, 16'd3413 } ;

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
