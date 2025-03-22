// ELEX 7660
// File: waveGen.sv
// Description: Determines which data to send to DAC based on input parameters.
// Author: Bryce Reid    Student ID: A01298718    Date: 2025-03-18

module waveGen ( input logic clk, reset_n,   			// clock and reset 
		 input logic data_ack,
		 input logic test_signal,
		 output logic data_req,				// update data request
		 output logic [11:0] data ) ;     		// data to send to DAC

	logic [1:0] index;
	logic [11:0] next_data ;
	logic [0:3][11:0] test_data ;

	assign test_data = { 12'd0, 12'd819, 12'd2458, 12'd4095 } ; // 0V, 1V, 3V, 5V

	always_ff @( negedge test_signal, negedge reset_n ) begin
		if ( ~reset_n )
			index <= 0 ;
		else 
			index <= index + 1 ;
	end

	always_comb
		next_data = test_data[index] ;

	always_ff @( posedge clk, negedge reset_n ) begin
		if ( ~reset_n )
			{ data_req, data } <= '0 ; // reset conditions
		else begin
			data <= next_data ;

			if ( data != next_data || data_ack )
				data_req <= ~data_req ;
		end
	end
		
endmodule
