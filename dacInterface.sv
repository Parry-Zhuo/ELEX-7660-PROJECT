// ELEX 7660
// File: dacInterface.sv
// Description: Implements a circuit to interface to the MAX5715 DAC.
// Author: Bryce Reid    Student ID: A01298718    Date: 2025-03-17

module dacInterface ( input logic clk, reset_n,   			// system clock and reset 
		      input logic [11:0] data, 				// data to send to DAC
		      output logic DAC_CSB, DAC_SCLK, DAC_DIN ) ;	// DAC interface signals			

	logic [5:0] count ; 			// count clock periods per conversation window
	logic DAC_SCLK_flag ; 			// gate signal for ADC_SCK signal
	logic [23:0] data_stream ; 		// DAC configuration byte + 12-bit data + 4-bit dont care

	assign DAC_SCLK = DAC_SCLK_flag ? clk : 1'b0 ; // latch clock output to DAC_SCLK signal
	
	always_comb 
		data_stream = { 8'b00110000, data, 4'b0000 } ; // select DAC A on MAX5715 to update

	always_ff @( posedge clk, negedge reset_n ) begin
		// reset conditions
		if ( ~reset_n ) 
			{ count, DAC_SCLK_flag, DAC_DIN, DAC_CSB } <= { '0, 1'b1 } ;
		else begin
			// configure DAC conversation
			case ( count )
				0  : begin
					DAC_CSB <= ~DAC_CSB ; // signal start of conversation window
					DAC_DIN <= 1'b0 ;
				     end
				1  : begin
					DAC_DIN <= data_stream[23] ;
					DAC_SCLK_flag <= ~DAC_SCLK_flag ; // initialize DAC_SCLK output to transmit 1st byte of configuration data
				     end
				2  : DAC_DIN <= data_stream[22] ;
				3  : DAC_DIN <= data_stream[21] ;
				4  : DAC_DIN <= data_stream[20] ;
				5  : DAC_DIN <= data_stream[19] ;
				6  : DAC_DIN <= data_stream[18] ;
				7  : DAC_DIN <= data_stream[17] ;
				8  : DAC_DIN <= data_stream[16] ;
				9  : begin
					DAC_DIN <= 1'b0 ;
					DAC_SCLK_flag <= ~DAC_SCLK_flag ; // end DAC_SCLK output to deliniate between bytes of data
				     end
				10 : begin
					DAC_DIN <= data_stream[15] ;
					DAC_SCLK_flag <= ~DAC_SCLK_flag ; // initialize DAC_SCLK output to transmit 2nd byte of configuration data
				     end
				11 : DAC_DIN <= data_stream[14] ;
				12 : DAC_DIN <= data_stream[13] ;
				13 : DAC_DIN <= data_stream[12] ;
				14 : DAC_DIN <= data_stream[11] ;
				15 : DAC_DIN <= data_stream[10] ;
				16 : DAC_DIN <= data_stream[9] ;
				17 : DAC_DIN <= data_stream[8] ;
				18 : begin
					DAC_DIN <= 1'b0 ;
					DAC_SCLK_flag <= ~DAC_SCLK_flag ; // end DAC_SCLK output to deliniate between bytes of data
				     end
				19 : begin
					DAC_DIN <= data_stream[7] ;
					DAC_SCLK_flag <= ~DAC_SCLK_flag ; // initialize DAC_SCLK output to transmit 3rd byte of configuration data
				     end
				20 : DAC_DIN <= data_stream[6] ;
				21 : DAC_DIN <= data_stream[5] ;
				22 : DAC_DIN <= data_stream[4] ;
				23 : DAC_DIN <= data_stream[3] ;
				24 : DAC_DIN <= data_stream[2] ;
				25 : DAC_DIN <= data_stream[1] ;
				26 : DAC_DIN <= data_stream[0] ;
				27 : begin
					DAC_DIN <= 1'b0 ;
					DAC_SCLK_flag <= ~DAC_SCLK_flag ; // end DAC_SCLK output
				     end
				31 : DAC_CSB <= ~DAC_CSB ; // signal end of conversation window
				default : DAC_DIN <= 1'b0 ;
			endcase
			if ( count == 32 )  // extra cycles added to achieve minimum delay between conversations
				count <= 1'b0 ; // reset count sequence
			else
				count <= count + 1'b1 ;
		end
	end
endmodule
