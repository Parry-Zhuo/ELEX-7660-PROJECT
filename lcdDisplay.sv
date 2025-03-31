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
//    output logic [7:0]  data // Data bus for actual data
	 output logic [12:0]  data //this is [12:0] to capture stimulation data
//    output logic [15:3] GPIO_0 //this should be in the top module.
);
    logic [12:0] count, next_count;

    // State machine states
    typedef enum logic [2:0] {
        INIT,
        FUNCTION_SET,
        DISPLAY_CONTROL,
        ENTRY_MODE,
        CLEAR_DISPLAY,
        READY,
        WRITE_DATA
    } state_t;

    state_t state, next_state;
    /*Loading data block
    UPON a rising edge of E, data and states are transitioned to next data/state
    changed to provide stable signal when E becomes a falling edge.
    */
    always_ff @(posedge E,negedge  rst) begin
        if (~rst) begin
//            state <= INIT;
            //next_state <= INIT;
            RS    <= 0;
            RW    <= 0;
//            data  <= 8'b0;
        end else begin
//				state <= next_state;
            case (state)
                INIT: begin// Wait for power stabilization
                    //Wait 15ms - if VDD>4.5V
                    //E    <= 1;//my hope with this is that it triggers the timer
                end FUNCTION_SET: begin// set to 8 bit length
                    RS   <= 0;
                    RW   <= 0;
//                    data <= 8'b0011_0000;
                end DISPLAY_CONTROL: begin
                    RS   <= 0;
                    RW   <= 0;
//                    data <= 8'b0000_1100; // Display ON, Cursor OFF, Blink OFF
                end ENTRY_MODE: begin
                    RS   <= 0;
                    RW   <= 0;
//                    data <= 8'b0000_0110; // Increment mode
                end CLEAR_DISPLAY: begin
                    RS   <= 0;
                    RW   <= 0;
//                    data <= 8'b0000_0001; // Clear display
                end READY: begin
                    // Ready for data input load data in
                    RS   <= 1;// ensure we are in write mode always
//                    data <= 8'b0000_0101;  /* should correspond with P*/;
                end WRITE_DATA: begin
                    RS   <= 1;// ensure we are in write mode always
                    RW   <= 0;
                    // Transition back to READY
                end default: begin

					 end
            endcase
        end
    end

/*State changer*/
	always_comb begin
		if (count > 0) begin
			next_state = state;
		end else begin
			if (state == INIT) begin
				next_state = FUNCTION_SET;
			end else if (state == FUNCTION_SET) begin
				next_state = DISPLAY_CONTROL;
			end else if (state == DISPLAY_CONTROL) begin
				next_state = ENTRY_MODE;
			end else if (state == ENTRY_MODE) begin
				next_state = CLEAR_DISPLAY;
			end else if (state == CLEAR_DISPLAY) begin
				next_state = READY;
			end else if (state == READY) begin
				next_state = WRITE_DATA;
			end else if (state == WRITE_DATA) begin
				next_state = READY;
			end else begin
				next_state = INIT;
			end
		end
	end
	
	always_comb begin
		 case (state)
			  INIT:           next_count = 2000; // 150ms * 1.25
			  FUNCTION_SET:   next_count = 513;  // 4.1ms * 1.25
			  DISPLAY_CONTROL:next_count = 150;  // 1.5ms delay
			  ENTRY_MODE:     next_count = 150;
			  CLEAR_DISPLAY:  next_count = 150;
			  READY:          next_count = 150;
			  WRITE_DATA:     next_count = 150;
			  default:        next_count = 150;
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
//			 RW <=0;
//			 RS <=0;
		 end else begin
		 
			 data = count;  //stimulation purposes only
			 state <=next_state;
			 count <= count - 1'b1;
			 if(count < (next_count >> 1) && count > 0) begin
				E <= 0;
			 end else if(count <= 0 )begin
				E <=1;
				count <= next_count;
			 end else begin
				E <=1;
			 end
		 end
	end



endmodule