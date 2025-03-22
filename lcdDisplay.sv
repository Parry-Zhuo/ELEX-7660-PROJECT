
module lcd_controller (
    input logic CLOCK_50,// 50 MHz clock// System clock
    input  logic        rst,       // Reset signal
    output logic        RS,        // Register Select
    output logic        RW,        // Read/Write
    output logic        E,         //The LCD reads data only on the falling edge of E (from HIGH → LOW). For bits DB7-0
    output logic [7:0]  data,       // Data bus
    output logic [15:3] GPIO_0 //this should be in the top module.
	 
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

    // Initialization sequence
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= INIT;
            RS    <= 0;
            RW    <= 0;
            E     <= 0;
            data  <= 8'b0;
        end else begin
            state <= next_state;
            case (state)
                INIT: begin
                    // Wait for power stabilization
                    // Transition to FUNCTION_SET after delay
                    //Wait 15ms - if VDD>4.5V
                end FUNCTION_SET: begin
                    RS   <= 0;
                    RW   <= 0;
                    data <= 8'b0011_1000; // 8-bit, 2-line, 5x8 dots <-- may
                    E    <= 1;// <- not exactly sure what this does

                    // Transition to DISPLAY_CONTROL wait 4.1ms
                end DISPLAY_CONTROL: begin
                    RS   <= 0;
                    RW   <= 0;
                    data <= 8'b0000_1100; // Display ON, Cursor OFF, Blink OFF
                    E    <= 1;
                    // Transition to ENTRY_MODE
                    //wait 100us
                end ENTRY_MODE: begin
                    RS   <= 0;
                    RW   <= 0;
                    data <= 8'b0000_0110; // Increment mode
                    E    <= 1;
                    // Transition to CLEAR_DISPLAY

                    //maybe delay 1.6ms
                end CLEAR_DISPLAY: begin
                    RS   <= 0;
                    RW   <= 0;
                    data <= 8'b0000_0001; // Clear display
                    E    <= 1;
                    // Transition to READY

                    //maybe delay 40us. 
                end READY: begin
                    // Ready for data input load data in
                    RS   <= 1;// ensure we are in write mode always
                    data <= /* data to write */;
                    EN <= 0 
                    //wait maybe 1ms or something
                end WRITE_DATA: begin
                    RS   <= 1;// ensure we are in write mode always
                    RW   <= 0;
                    E    <= 1; //WRITE DATA TRIGGERS UPON FALLING EDGE from E

                    // Transition back to READY
                end
            endcase
        end
    end
   // use count to divide clock and generate a 2 bit digit counter to determine which digit to display
    always_ff @(posedge CLOCK_50) 
        clk_div_count <= clk_div_count + 1'b1 ;

    assign clk = clk_div_count[6];//2^6 = 1024

    // Next state logic
    always_comb begin
        if(count > 0) begin
            next_count = count - 1'b1;
            next_state = state; 
        end else begin
            if(state == INIT) begin
                next_state = FUNCTION_SET;
                next_count = 150-1;
            end else if (state == FUNCTION_SET) begin
                next_state = DISPLAY_CONTROL;
                next_count = 0;
            end else if (state == DISPLAY_CONTROL) begin
                next_state = ENTRY_MODE;
                next_count = 0;
            end else if (state == ENTRY_MODE) begin
                next_state = CLEAR_DISPLAY;
                next_count = 0;
            end else if (state == CLEAR_DISPLAY) begin
                next_state = READY;
                next_count = 0;
            end else if (state == READY) begin
                next_state = WRITE_DATA;
                next_count = 0;
            end else if (state == WRITE_DATA) begin
                next_state = READY;
                next_count = 0;
            end else begin
                next_state = INIT;
                next_count = 150-1;
            end
        end
    end
	always_comb begin
		GPIO[3] = rst;
		GPIO[4] = RS;        // Register Select
		GPIO[5] = RW;        // Read/Write
		GPIO[6] = E;         // Enable
		GPIO[15:7] =data[7:0];       // Data bus
	end 


endmodule