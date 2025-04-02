// ELEX 7660
// File: lcdDisplay.sv
// Description: provides LCD display
// Author: Parry Zhuo Date: 2025-03-22

/*


*/
module lcdDisplay(
    input logic clk,// 50 MHz clock// System clock
    input  logic        rst,       // Reset signal,  GPIO_0[3]
    output logic        RS,        // Register Select GPIO_0[4]
    output logic        RW,        // Read/Write GPIO_0[5]
    output logic        E,         //The LCD reads data only on the falling edge of E (from HIGH → LOW). For bits DB7-0:   GPIO_0[6]
    output logic [7:0]  data // Data bus for actual data
//	 output logic [12:0]  data //this is [12:0] to capture stimulation data
//    output logic [15:3] GPIO_0 //this should be in the top module.
);
    logic [12:0] count, next_count;
   logic [4:0] write_count; //
	
    // State machine states
    typedef enum logic [4:0] {
        INIT,
        FUNCTION_SET1,
		  FUNCTION_SET2,
		  FUNCTION_SET3,
        DISPLAY_CONTROL,
		  DISPLAY_OFF,
		  DISPLAY_CLEAR,
        ENTRY_MODE,
		  FUNCTION_SET,
        READY,
        WRITE_DATA,
		  STOP
		  
//		  CLEAR_DISPLAY,       // ← Missing
//		  ENTRY_SET_MODE,       // ← Missing
//		  FUNCTION_SET
	 } state_t;

    state_t state, next_state;
    /*Loading data block triggered at posedge E
    UPON a rising edge of E, data and states are transitioned to next data/state
    changed to provide stable signal when E becomes a falling edge.
    */
	always_ff @(posedge E, negedge rst) begin
		 if (~rst) begin
			  RS <= 0;
			  RW <= 0;
		 end else begin
			  case (state)
					INIT: begin
						 RS <= 0;
						 RW <= 0;
						 data <= 8'b0000_0000;
					end FUNCTION_SET1: begin
						RS   <= 0;
						RW   <= 0;
						data <= 8'b0011_0000;// Function set (8-bit mode) x 3 times
					end FUNCTION_SET2: begin
					end FUNCTION_SET3: begin
					end FUNCTION_SET: begin//Function set set 1,DL,N,F
						data <= 8'b0011_1100; // (DL: 8-bit/4-bit),  (N: 2-line/1-line), (F: 5×10 dots/5×8 dots)
					end DISPLAY_OFF: begin//Display ON/OFF 1xxx. display (D), cursor (C), and blinking of cursor (B) 
						 data <= 8'b0000_1110; 
					end DISPLAY_CLEAR: begin
						data <= 8'b0000_0001; // Clear display
					end ENTRY_MODE: begin// entry set MODE
						data <= 8'b0000_0110;//assign curser moving direction and enable shift of display
					end DISPLAY_CONTROL: begin//TEMPORARILY RETURN- HOME
						data <= 8'b0000_0010; // 0 0 0 1 S/C R/L 0 0 – Shift entire display (S/C=1) or move cursor (S/C=0), direction by R/L (0=left, 1=right) without DDRAM change.
					end READY: begin //LOADING data on POSEDGE on E
						 RS <= 1;
//						 data <= 8'b0000_0101; // Write data 'P'
						 data <= 8'b1111_1111; // Write data 'P'
//						 data <= 8'b0000_0000;
					end WRITE_DATA: begin // here the data should be stable to write into the LCD
						 write_count <= write_count + 1;
					end STOP: begin
//						data <= 8'b0000_0000;
						RS <= 0;
					end default: begin
					end
			  endcase
		 end
	end

	/* State changer */
	always_comb begin
		 if (count > 0) begin
			  next_state = state;
		 end else begin
			  case (state)
					INIT:           next_state = FUNCTION_SET1;
					FUNCTION_SET1:  next_state = FUNCTION_SET2;
					FUNCTION_SET2:  next_state = FUNCTION_SET3;
					FUNCTION_SET3:  next_state = DISPLAY_CONTROL;
					DISPLAY_CONTROL:next_state = ENTRY_MODE;
					ENTRY_MODE:     next_state = FUNCTION_SET;
					FUNCTION_SET:   next_state = DISPLAY_CLEAR;
					DISPLAY_CLEAR:  next_state = READY;
					READY:          next_state = WRITE_DATA;
					WRITE_DATA: begin
					    if (write_count < 4) begin
							  next_state = READY;
//							  write_count = write_count + 1;
						 end else
							  next_state = STOP; // Stay here to stop writing
					
					end STOP:     next_state = STOP;
					default:        next_state = INIT;
			  endcase
		 end
	end
	
	always_comb begin
//		 case (state)
//			  INIT:           next_count = 2000; // 150ms * 1.25 = 200
//			  FUNCTION_SET:   next_count = 513;  // 4.1ms * 1.25
//			  DISPLAY_CONTROL:next_count = 150;  // 1.5ms delay
//			  ENTRY_MODE:     next_count = 150;
//			  CLEAR_DISPLAY:  next_count = 150;
//			  READY:          next_count = 150;
//			  WRITE_DATA:     next_count = 150;
//			  default:        next_count = 150;
//		 endcase
		 case (state)
//			  INIT:           next_count = 4000; // 150ms * 1.25
//			  FUNCTION_SET:   next_count = 4000;  // 4.1ms * 1.25
//			  DISPLAY_CONTROL:next_count = 4000;  // 1.5ms delay
//			  ENTRY_MODE:     next_count = 4000;
//			  CLEAR_DISPLAY:  next_count = 4000;
//			  READY:          next_count = 4000;
//			  WRITE_DATA:     next_count = 4000;
			  default:        next_count = 1200000;
		 endcase
	end
	   /*
   Counter block, triggers e 
    if e==next_count/2 then
        e = 0// creates falling edge to trigger reading data on the LCD chip
    else if e == 0 then
        e = 1// creates rising edge to trigger next sequence of data and counters
   */
	always_ff @( posedge clk, negedge rst) begin
		 if (~rst) begin 
			 count <= next_count;
			 state <=INIT;
			 E <= 1;

		 end else begin
//			 data = 8'b1000_0001;
//			 data = count;  //stimulation purposes only
			 state <=next_state;
//			 if(state != STOP) begin
				 count <= count - 1'b1;
				 if(count < (next_count >> 1) && count > 0) begin
					E <= 0;
				 end else if(count <= 0 )begin
					E <=1;
					count <= next_count;
				 end else begin
					E <=1;
				 end
//			 end
		 end
	end

endmodule

/*PIN CHECKOUT

data = 8'b1000_0001;

*/
