// Testbench: lfoGenerator_tb.sv
module lfoGenerator_tb;

    // Testbench signals
    logic CLOCK_50;
    logic enc1_a = 0, enc1_b = 0;
    logic enc2_a = 0, enc2_b = 0;
    logic s1 = 1;
    logic [15:3] GPIO_0;

    // Instantiate the Unit Under Test (UUT)
    lfoGenerator uut (
        .CLOCK_50(CLOCK_50),
        .enc1_a(enc1_a), .enc1_b(enc1_b),
        .enc2_a(enc2_a), .enc2_b(enc2_b),
        .s1(s1),
        .GPIO_0(GPIO_0)
    );

    // Generate 50 MHz clock (20 ns period)
    initial CLOCK_50 = 0;
    always #10 CLOCK_50 = ~CLOCK_50;

    // Monitor E pin (GPIO_0[6])
    initial begin
        $display("Time\tE_Pin");
        $monitor("%t\t%b", $time, GPIO_0[6]);
        #1_000_000_000; // Run simulation for 1 second (1e9 ns)
        $finish;
    end

endmodule
