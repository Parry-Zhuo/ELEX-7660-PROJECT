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
    output logic [15:0] GPIO_0   // GPIO pins for DAC SPI + LCD
);

    // Internal signals
    logic reset_n;           // Reset signal
    logic DAC_CSB, DAC_SCLK, DAC_DIN; // SPI signals
    logic lcd_RS, lcd_RW, lcd_E;   // LCD control signals
    logic [7:0] lcd_data;          // LCD data bus

    // Assign GPIO outputs
    always_comb begin
        reset_n = s1; // Implement reset button on S1
        
        // DAC SPI Communication signals
        GPIO_0[0] = DAC_CSB;
        GPIO_0[1] = DAC_SCLK;
        GPIO_0[2] = DAC_DIN;
        
        // LCD Control signals
        GPIO_0[4] = lcd_RS;
        GPIO_0[5] = lcd_RW;
        GPIO_0[6] = lcd_E;
        
        // LCD Data Bus (GPIO_7 to GPIO_15)
        GPIO_0[15:7] = lcd_data;
    end

    // Instantiate LCD Controller
    lcd_controller lcdInst_0 (
        .CLOCK_50(CLOCK_50), 
        .rst(reset_n),     // Use internal reset signal
        .RS(lcd_RS),       
        .RW(lcd_RW),
        .E(lcd_E), 
        .data(lcd_data)    // 8-bit data bus
    );

endmodule
