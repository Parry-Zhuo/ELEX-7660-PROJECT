// File: lfoGenerator.sv
// Description: ELEX 7660 lab project: LFO Generator top-level module. 
// Original Author: Robert Trost 
// Date: 2024-01-11
// Edited by: Bryce Reid and Parry Zhuo
// Date: 2025-02-23
 
module lfoGenerator (
    input logic CLOCK_50,        // 50 MHz clock
    (* altera_attribute = "-name WEAK_PULL_UP_RESISTOR ON" *) 
    input logic enc1_a, enc1_b,  // Encoder 1 pins
    (* altera_attribute = "-name WEAK_PULL_UP_RESISTOR ON" *)
    input logic enc2_a, enc2_b,  // Encoder 2 pins
    input logic s1,              // Active low pushbutton (Reset)
    output logic [15:3] GPIO_0   // GPIO pins for DAC SPI + LCD
);

    // Internal signals
	logic reset_n;           // Reset signal
	logic lcd_RS, lcd_RW, lcd_E;   // LCD control signals
	logic [7:0] lcd_data;          // LCD data bus
   logic [15:0] clk_div_count; // count used to divide clock

    // Assign GPIO outputs
	always_comb begin
		reset_n = s1; // Implement reset button on S1
      
//		GPIO_0[3] = lcd_reset;       // Reset signal,  GPIO_0[3]
		GPIO_0[4] = lcd_RS;        // Register Select GPIO_0[4]
		GPIO_0[5] = lcd_RW;        // Read/Write GPIO_0[5]
		GPIO_0[6] = lcd_E;    //The LCD reads data only on the falling edge of E (from HIGH → LOW). For bits DB7-0:   GPIO_0[6]
		GPIO_0[15:7] = lcd_data; // LCD Data Bus (GPIO_7 to GPIO_15)
    end
	 
    always_ff @(posedge CLOCK_50) 
        clk_div_count <= clk_div_count + 1'b1 ;

    assign clk = clk_div_count[9];//50M/2^9 is approx 100KHz, o97656.25
    // Instantiate LCD Controller
    lcdDisplay lcdInst_0 (
        .clk(clk), 
        .rst(reset_n),     // Use internal reset signal
        .RS(lcd_RS),       
        .RW(lcd_RW),
        .E(lcd_E), 
        .data(lcd_data)    // 8-bit data bus
    );






endmodule
