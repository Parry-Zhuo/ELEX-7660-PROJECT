// ELEX 7660
// File: dacInterface.sv
// Description: Implements a circuit to interface to the MAX5715 DAC.
// Author: Bryce Reid    Student ID: A01298718    Date: 2025-03-17

module dacInterface ( input logic clk, reset_n,   			// clock and reset 
		      //input logic data_req,				// update data request
		      input logic [11:0] data,     			// data to send to DAC
		      output logic DAC_CSB, DAC_SCLK, DAC_DIN ) ; //,		// DAC signals
		      //output logic data_ack ) ; 			// data update acknowledge 

	logic [5:0] count ; // count clock periods per conversation window
	//logic DAC_SCLK_flag ; // gate signal for ADC_SCK signal
	logic [23:0] data_stream ; // DAC configuration byte + 12-bit data + 4-bit dont care
	logic [1:0] power_up ; // Power up configuration flag

	assign DAC_SCLK = clk ;
	//	DAC_SCLK = DAC_SCLK_flag ? clk : 1'b0 ; // gate clock output to DAC_SCLK signal
	
	always_comb begin
		case ( power_up )
			//3 : data_stream = 32'b0100_0000_0000_0001_0000_0000 ; // configure DAC A for normal power mode
			//2 : data_stream = 32'b0110_0000_0000_0001_0000_0000 ; // configure DAC A for normal operation
			//1 : data_stream = 32'b0111_0000_0000_0000_0000_0000 ; // configure DAC for external voltage referance
			default : data_stream = { 8'b00110000, data, 4'b0000 } ; // select DAC A on MAX5715 to update
		endcase
	end

	always_ff @( posedge clk, negedge reset_n ) begin
		// reset conditions
		if ( ~reset_n ) 
			//{ count, DAC_SCLK_flag, DAC_DIN, DAC_CSB, power_up } <= { 6'd0, 1'b0, 1'b0, 1'b1, 2'd3 } ;
			{ count, DAC_DIN, DAC_CSB, power_up } <= { 6'd0, 1'b0, 1'b1, 2'd3 } ;
		//else if ( data_req ) begin
		else begin
			// configure DAC conversation
			case ( count )
				0  : begin
					DAC_CSB <= ~DAC_CSB ; // signal start of conversation window
					//DAC_SCLK_flag <= ~DAC_SCLK_flag ; // initialize DAC_SCLK output
					DAC_DIN <= data_stream[23] ;
				     end
				1  : DAC_DIN <= data_stream[22] ;
				2  : DAC_DIN <= data_stream[21] ;
				3  : DAC_DIN <= data_stream[20] ;
				4  : DAC_DIN <= data_stream[19] ;
				5  : DAC_DIN <= data_stream[18] ;
				6  : DAC_DIN <= data_stream[17] ;
				7  : DAC_DIN <= data_stream[16] ;
				8  : DAC_DIN <= data_stream[15] ;
				9  : DAC_DIN <= data_stream[14] ;
				10 : DAC_DIN <= data_stream[13] ;
				11 : DAC_DIN <= data_stream[12] ;
				12 : DAC_DIN <= data_stream[11] ;
				13 : DAC_DIN <= data_stream[10] ;
				14 : DAC_DIN <= data_stream[9] ;
				15 : DAC_DIN <= data_stream[8] ;
				16 : DAC_DIN <= data_stream[7] ;
				17 : DAC_DIN <= data_stream[6] ;
				18 : DAC_DIN <= data_stream[5] ;
				19 : DAC_DIN <= data_stream[4] ;
				20 : DAC_DIN <= data_stream[3] ;
				21 : DAC_DIN <= data_stream[2] ;
				22 : DAC_DIN <= data_stream[1] ;
				23 : DAC_DIN <= data_stream[0] ;
				24 : begin
					DAC_CSB <= ~DAC_CSB ; // signal end of conversation window
					//DAC_SCLK_flag <= ~DAC_SCLK_flag ; // deinitialize DAC_SCLK output
					if ( power_up )
						power_up <= power_up - 1'b1 ;
				     end
				default : DAC_DIN <= 1'b0 ;
			endcase
			if ( count == 30 )  // extra cycles added to achieve minimum of 100 ns delay between conversations
				count <= 1'b0 ; // reset count sequence
			else
				count <= count + 1'b1 ;
		end
	end
/*
	// data_req low signals acknowledge recieved, thus data_ack reset to low
	always_ff @( posedge clk, negedge data_req, negedge reset_n ) begin
		if ( ~data_req || ~reset_n )
			data_ack <= 1'b0 ;
		else if ( count == 30 )
			data_ack <= 1'b1 ; // send data update acknowledge
	end
*/
		
endmodule
