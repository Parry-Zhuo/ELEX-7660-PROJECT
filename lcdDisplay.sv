// ELEX 7660
// File: lcdDisplay.sv
// Description: provides LCD display
// Author: Parry Zhuo Date: 2025-03-22


module lcd_controller (
    input logic CLOCK_50,// 50 MHz clock// System clock
    output  logic        rst,       // Reset signal
    output logic        RS,        // Register Select
    output logic        RW,        // Read/Write
    output logic        E,         //The LCD reads data only on the falling edge of E (from HIGH → LOW). For bits DB7-0
    output logic [7:0]  data       // Data bus
//    output logic [15:3] GPIO_0 //this should be in the top module.
);
    logic [4:0] count, next_count;
    logic [15:0] clk_div_count; // count used to divide clock
    logic clk ; 

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
    always_ff @(posedge E,posedge  rst) begin
        if (rst) begin
            state <= INIT;
            //next_state <= INIT;
            RS    <= 0;
            RW    <= 0;
            data  <= 8'b0;
        end else begin
				state <= next_state;
            case (state)
                INIT: begin// Wait for power stabilization
                    //Wait 15ms - if VDD>4.5V
                    //E    <= 1;//my hope with this is that it triggers the timer
                end FUNCTION_SET: begin// set to 8 bit length
                    RS   <= 0;
                    RW   <= 0;
                    data <= 8'b0011_0000;
                end DISPLAY_CONTROL: begin
                    RS   <= 0;
                    RW   <= 0;
                    data <= 8'b0000_1100; // Display ON, Cursor OFF, Blink OFF
                end ENTRY_MODE: begin
                    RS   <= 0;
                    RW   <= 0;
                    data <= 8'b0000_0110; // Increment mode
                end CLEAR_DISPLAY: begin
                    RS   <= 0;
                    RW   <= 0;
                    data <= 8'b0000_0001; // Clear display
                end READY: begin
                    // Ready for data input load data in
                    RS   <= 1;// ensure we are in write mode always
                    data <= 8'b0000_0101;  /* should correspond with P*/;
                end WRITE_DATA: begin
                    RS   <= 1;// ensure we are in write mode always
                    RW   <= 0;
                    // Transition back to READY
                end default: begin

					 end
            endcase
        end
    end
   /*
   Counter block, triggers e 
    if e==next_count/2 then
        e = 0// creates falling edge to trigger reading data on the LCD chip
    else if e == 0 then
        e = 1// creates rising edge to trigger next sequence of data and counters
   */  
    always_ff @(posedge clk, posedge rst) begin
			if(rst) begin
				count <= 0;
            //next_count <= 0;
				E = 1;
			end else if(count < next_count/2 && count > 0) begin
            E = 0; // creates falling edge for inserting data on steadyWave data waveforms
        end else begin
            E = 1;// Otherwise tie e to 1 to creating rising edge
        end
		  count <= next_count;
    end

    // Next state logic
    always_comb begin

        if(count > 0) begin// if(count > 0) begin <-- changed for inferred latching
            next_count = count - 1'b1; 
				next_state = state;
        end else begin
            if(state == INIT) begin
                next_state = FUNCTION_SET;
                next_count = 150-1;
            end else if (state == FUNCTION_SET) begin
                next_state = DISPLAY_CONTROL;
                next_count = 2;
            end else if (state == DISPLAY_CONTROL) begin
                next_state = ENTRY_MODE;
                next_count = 2;
            end else if (state == ENTRY_MODE) begin
                next_state = CLEAR_DISPLAY;
                next_count = 2;
            end else if (state == CLEAR_DISPLAY) begin
                next_state = READY;
                next_count = 2;
            end else if (state == READY) begin
                next_state = WRITE_DATA;
                next_count = 2;
            end else if (state == WRITE_DATA) begin
                next_state = READY;
                next_count = 2;
            end else begin
                next_state = INIT;
                next_count = 150-1;
            end
        end
    end


    always_ff @(posedge CLOCK_50) 
        clk_div_count <= clk_div_count + 1'b1 ;

    assign clk = clk_div_count[6];//2^6 = 1024

endmodule