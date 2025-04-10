// ELEX 7660
// File: enc2val.sv
// Description: implement value change to selected parameter using rotary encoder
// Author: Bryce Reid    Student ID: A01298718    Date: 2025-03-27

module enc2val ( input logic reset_n, clk, 	// reset and clock
		 input logic cw, ccw,		// outputs from lab 2 encoder module 
		 input logic [1:0] sel,  	// parameter select 
		 output logic [2:0] shape,	// wave shape selected (0-5)
		 output logic [2:0] depth,	// wave depth selected (0-4)
		 output logic [7:0] freq ) ; 	// index of desired waveform frequency (0-154)

	logic [3:0] cw_count, ccw_count ; 	// counts of cw/ccw pulses
	logic cw_flag, ccw_flag ; 		// flags to initiate debounce timer
	logic [15:0] debounce_timer ; 		// timer to implement 1ms debounce

	// parameter select based on cw/ccw signal pulses
	always_ff @( posedge clk, negedge reset_n ) begin
		if (~reset_n ) begin
			// reset conditions 
			{ cw_count, ccw_count, cw_flag, ccw_flag, debounce_timer } <= '0 ;
			// shape: sine // Depth: 3 // Rate: 100 bpm
			shape <= 3'd0 ;
			depth <= 3'd2 ;
			freq <= 8'd14 ;
		end else begin
			// set flags to initiate debounce timer when cw/ccw signal recieved
			case ( { cw, cw_flag, ccw, ccw_flag } )
				4'b1000 : cw_flag <= 1'b1 ;
				4'b0010 : ccw_flag <= 1'b1 ; 
			endcase

			if ( cw_flag || ccw_flag ) 
				debounce_timer <= debounce_timer + 1'b1 ; // increment debounce timer if cw/ccw flag set

			if ( ccw_flag && cw_count < 4 ) 
				cw_count <= '0 ; // reset cw counter if ccw signal is recieved

			if ( cw_flag && ccw_count < 4 ) 
				ccw_count <= '0 ; // reset ccw counter if cw signal is recieved

			// increment cw signal counter after 1ms debounce
			if ( debounce_timer == 50000 && cw_flag ) begin
				cw_count <= cw_count + 1'b1 ;
				{ debounce_timer, cw_flag } <= '0 ; // reset debounce timer and cw flag
			end

			// increment ccw signal counter after 1ms debounce
			if ( debounce_timer == 50000 && ccw_flag ) begin
				ccw_count <= ccw_count + 1'b1 ;
				{ debounce_timer, ccw_flag } <= '0 ; // reset debounce timer and ccw flag
			end
		
			// increment select every four consecutive cw signals recieved
			if ( cw_count == 4 ) begin
				case ( sel )
					default : if ( shape == 3'd5 )
					    	shape <= 3'd0 ;
					    else
						shape <= shape + 3'd1 ;
					1 : if ( freq == 8'd154 )
					    	freq <= freq ;
					    else
						freq <= freq + 8'd1 ;
					2 : if ( depth == 3'd4 )
					    	depth <= depth ;
					    else
						depth <= depth + 3'd1 ;
				endcase
				cw_count <= 0 ; // reset cw signal counter
			end
	
			// decrement select every four consecutive ccw signals recieved
			if ( ccw_count == 4 ) begin
				case ( sel )
					default : if ( shape == 3'd0 )
					    	shape <= 3'd5 ;
					    else
						shape <= shape - 3'd1 ;
					1 : if ( freq == 8'd0 )
					    	freq <= freq ;
					    else
						freq <= freq - 8'd1 ;
					2 : if ( depth == 3'd0 )
					    	depth <= depth ;
					    else
						depth <= depth - 3'd1 ;
				endcase
				ccw_count <= 0 ; // reset ccw signal counter
			end
		end
	end

endmodule 
