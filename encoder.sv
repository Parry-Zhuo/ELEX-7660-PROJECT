// ELEX 7660
// File: encoder.sv
// Description: Implements a rotary encoder that will be used to increment  
//              and decrement counts that will be displayed on a four digit
//              7-segment LED display.
// Author: Bryce Reid    Student ID: A01298718    Date: 2025-01-15

module encoder (input logic a, b, // input signals from rotary encoder
		output logic cw, ccw, // output signals indicating change in rotary encoder position
		input logic clk ) ; // module clock signal

	logic [1:0] past_ab ; // past signals

	// compare current encoder values with past values to detect changes
	always_ff @(posedge clk) begin

		case ( { a, b, past_ab } )
			4'b1110, 4'b0111, 4'b0001, 4'b1000 : cw <= 1'b1 ; // changes indicate cw rotation
			4'b1101, 4'b0100, 4'b0010, 4'b1011 : ccw <= 1'b1 ; // changes indicate ccw rotation
			default : { cw, ccw } <= '0 ; // no change detected
		endcase

		past_ab <= { a, b } ; // store current encoder signals into memory
	end

endmodule 
 