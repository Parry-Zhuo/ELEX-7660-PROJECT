
// ELEX 7660
// File: lcdDisplay.sv
// Description: provides LCD display
// Author: Parry Zhuo 		Date: 2025-03-22

/*


*/
module lcdDisplay #(
	parameter int MESSAGE_LENGTH = 64// how many chars for the character
)(
    input logic clk,// 50 MHz clock// System clock
    input  logic        rst,       // Reset signal,  GPIO_0[3]
    output logic        RS,        // Register Select GPIO_0[4]
    output logic        RW,        // Read/Write GPIO_0[5]
    output logic        E,         //The LCD reads data only on the falling edge of E (from HIGH → LOW). For bits DB7-0:   GPIO_0[6]
    output logic [7:0]  data, // Data bus for actual data
//	 output logic [12:0]  data //this is [12:0] to capture stimulation data
//    output logic [15:3] GPIO_0 //this should be in the top module.
	 input logic [1:0] sel,
	 input logic [2:0] shape, depth,
	 input logic [7:0] freq
);
    logic [12:0] count, next_count;
    logic [12:0] write_count; //

    logic [0:MESSAGE_LENGTH - 1][7:0] message ;

    // set static display elements //
    // Line 1: " LFO GENERATOR  " //
    assign message[0:15] = { 8'h20, 8'h4C, 8'h46, 8'h4F, 8'h20, 8'h47, 8'h45, 8'h4E, 8'h45, 8'h52, 8'h41, 8'h54, 8'h4F, 8'h52, 8'h20, 8'h20 } ;
    // Line 3: "  RATE: 100 BPM " // (example)
    assign message[17:23] = { 8'h20, 8'h52, 8'h41, 8'h54, 8'h45, 8'h3A, 8'h20 } ;
    assign message[27:31] = { 8'h20, 8'h42, 8'h50, 8'h4D, 8'h20 } ;
    // Line 2: "  WAVE: SQUARE  " // (example)
    assign message[33:39] = { 8'h20, 8'h57, 8'h41, 8'h56, 8'h45, 8'h3A, 8'h20 } ;
    // Line 4: "  DEPTH: XXX    " // (example)
    assign message[49:56] = { 8'h20, 8'h44, 8'h45, 8'h50, 8'h54, 8'h48, 8'h3A, 8'h20 } ;
    assign message[62:63] = { 8'h20, 8'h20 } ;

    // set variable display elements //
    always_comb begin
	// display parameter select cursor
    	case ( sel )
		// select "WAVE" parameter
		default : begin
			message[16] = 8'h10 ;
			message[32] = 8'h20 ;
			message[48] = 8'h20 ;
		    end
		// select "RATE" parameter
		1 : begin
			message[16] = 8'h20 ;
			message[32] = 8'h10 ;
			message[48] = 8'h20 ;
		    end
		// select "DEPTH" parameter
		2 : begin
			message[16] = 8'h20 ;
			message[32] = 8'h20 ;
			message[48] = 8'h10 ;
		    end
	endcase
	// display "WAVE" parameter selection
	case ( shape )
		// "SINE" //
		default : message[40:47] = { 8'h53, 8'h49, 8'h4E, 8'h45, 8'h20, 8'h20, 8'h20, 8'h20 } ;
		// "SQUARE" //
		1 : message[40:47] = { 8'h53, 8'h51, 8'h55, 8'h41, 8'h52, 8'h45, 8'h20, 8'h20 } ;
		// "TRIANGLE" //
		2 : message[40:47] = { 8'h54, 8'h52, 8'h49, 8'h41, 8'h4E, 8'h47, 8'h4C, 8'h45 } ;
		// "RAMP UP" //
		3 : message[40:47] = { 8'h52, 8'h41, 8'h4D, 8'h50, 8'h20, 8'h55, 8'h50, 8'h20 } ;
		// "RAMPDOWN" //
		4 : message[40:47] = { 8'h52, 8'h41, 8'h4D, 8'h50, 8'h44, 8'h4F, 8'h57, 8'h4E } ;
		// "S & H" //
		5 : message[40:47] = { 8'h53, 8'h20, 8'h26, 8'h20, 8'h48, 8'h20, 8'h20, 8'h20 } ;
	endcase
	// display "DEPTH" parameter selection
	case ( depth )
		// low //
		default : message[57:61] = { 8'hDB, 8'h20, 8'h20, 8'h20, 8'h20 } ;
		// low-mid //
		1 : message[57:61] = { 8'hDB, 8'hDB, 8'h20, 8'h20, 8'h20 } ;
		// mid //
		2 : message[57:61] = { 8'hDB, 8'hDB, 8'hDB, 8'h20, 8'h20 } ;
		// high-mid //
		3 : message[57:61] = { 8'hDB, 8'hDB, 8'hDB, 8'hDB, 8'h20 } ;
		// high //
		3 : message[57:61] = { 8'hDB, 8'hDB, 8'hDB, 8'hDB, 8'hDB } ;
	endcase
	// display "RATE" parameter selection
	case ( freq )
		default : message[24:26] = { 8'h20, 8'h33, 8'h30 } ; // 30
		1 : message[24:26] = { 8'h20, 8'h33, 8'h35 } ;
		2 : message[24:26] = { 8'h20, 8'h34, 8'h30 } ;
		3 : message[24:26] = { 8'h20, 8'h34, 8'h35 } ;
		4 : message[24:26] = { 8'h20, 8'h35, 8'h30 } ;
		5 : message[24:26] = { 8'h20, 8'h35, 8'h35 } ;
		6 : message[24:26] = { 8'h20, 8'h36, 8'h30 } ;
		7 : message[24:26] = { 8'h20, 8'h36, 8'h35 } ;
		8 : message[24:26] = { 8'h20, 8'h37, 8'h30 } ;
		9 : message[24:26] = { 8'h20, 8'h37, 8'h35 } ;
		10 : message[24:26] = { 8'h20, 8'h38, 8'h30 } ;
		11 : message[24:26] = { 8'h20, 8'h38, 8'h35 } ;
		12 : message[24:26] = { 8'h20, 8'h39, 8'h30 } ;
		13 : message[24:26] = { 8'h20, 8'h39, 8'h35 } ;
		14 : message[24:26] = { 8'h31, 8'h30, 8'h30 } ; // 100
		15 : message[24:26] = { 8'h31, 8'h30, 8'h35 } ;
		16 : message[24:26] = { 8'h31, 8'h31, 8'h30 } ;
		17 : message[24:26] = { 8'h31, 8'h31, 8'h35 } ;
		18 : message[24:26] = { 8'h31, 8'h32, 8'h30 } ;
		19 : message[24:26] = { 8'h31, 8'h32, 8'h35 } ;
		20 : message[24:26] = { 8'h31, 8'h33, 8'h30 } ;
		21 : message[24:26] = { 8'h31, 8'h33, 8'h35 } ;
		22 : message[24:26] = { 8'h31, 8'h34, 8'h30 } ;
		23 : message[24:26] = { 8'h31, 8'h34, 8'h35 } ;
		24 : message[24:26] = { 8'h31, 8'h35, 8'h30 } ;
		25 : message[24:26] = { 8'h31, 8'h35, 8'h35 } ;
		26 : message[24:26] = { 8'h31, 8'h36, 8'h30 } ;
		27 : message[24:26] = { 8'h31, 8'h36, 8'h35 } ;
		28 : message[24:26] = { 8'h31, 8'h37, 8'h30 } ;
		29 : message[24:26] = { 8'h31, 8'h37, 8'h35 } ;
		30 : message[24:26] = { 8'h31, 8'h38, 8'h30 } ;
		31 : message[24:26] = { 8'h31, 8'h38, 8'h35 } ;
		32 : message[24:26] = { 8'h31, 8'h39, 8'h30 } ;
		33 : message[24:26] = { 8'h31, 8'h39, 8'h35 } ;
		34 : message[24:26] = { 8'h32, 8'h30, 8'h30 } ; // 200
		35 : message[24:26] = { 8'h32, 8'h30, 8'h35 } ;
		36 : message[24:26] = { 8'h32, 8'h31, 8'h30 } ;
		37 : message[24:26] = { 8'h32, 8'h31, 8'h35 } ;
		38 : message[24:26] = { 8'h32, 8'h32, 8'h30 } ;
		39 : message[24:26] = { 8'h32, 8'h32, 8'h35 } ;
		40 : message[24:26] = { 8'h32, 8'h33, 8'h30 } ;
		41 : message[24:26] = { 8'h32, 8'h33, 8'h35 } ;
		42 : message[24:26] = { 8'h32, 8'h34, 8'h30 } ;
		43 : message[24:26] = { 8'h32, 8'h34, 8'h35 } ;
		44 : message[24:26] = { 8'h32, 8'h35, 8'h30 } ;
		45 : message[24:26] = { 8'h32, 8'h35, 8'h35 } ;
		46 : message[24:26] = { 8'h32, 8'h36, 8'h30 } ;
		47 : message[24:26] = { 8'h32, 8'h36, 8'h35 } ;
		48 : message[24:26] = { 8'h32, 8'h37, 8'h30 } ;
		49 : message[24:26] = { 8'h32, 8'h37, 8'h35 } ;
		50 : message[24:26] = { 8'h32, 8'h38, 8'h30 } ;
		51 : message[24:26] = { 8'h32, 8'h38, 8'h35 } ;
		52 : message[24:26] = { 8'h32, 8'h39, 8'h30 } ;
		53 : message[24:26] = { 8'h32, 8'h39, 8'h35 } ;
		54 : message[24:26] = { 8'h33, 8'h30, 8'h30 } ; // 300
		55 : message[24:26] = { 8'h33, 8'h30, 8'h35 } ;
		56 : message[24:26] = { 8'h33, 8'h31, 8'h30 } ;
		57 : message[24:26] = { 8'h33, 8'h31, 8'h35 } ;
		58 : message[24:26] = { 8'h33, 8'h32, 8'h30 } ;
		59 : message[24:26] = { 8'h33, 8'h32, 8'h35 } ;
		60 : message[24:26] = { 8'h33, 8'h33, 8'h30 } ;
		61 : message[24:26] = { 8'h33, 8'h33, 8'h35 } ;
		62 : message[24:26] = { 8'h33, 8'h34, 8'h30 } ;
		63 : message[24:26] = { 8'h33, 8'h34, 8'h35 } ;
		64 : message[24:26] = { 8'h33, 8'h35, 8'h30 } ;
		65 : message[24:26] = { 8'h33, 8'h35, 8'h35 } ;
		66 : message[24:26] = { 8'h33, 8'h36, 8'h30 } ;
		67 : message[24:26] = { 8'h33, 8'h36, 8'h35 } ;
		68 : message[24:26] = { 8'h33, 8'h37, 8'h30 } ;
		69 : message[24:26] = { 8'h33, 8'h37, 8'h35 } ;
		70 : message[24:26] = { 8'h33, 8'h38, 8'h30 } ;
		71 : message[24:26] = { 8'h33, 8'h38, 8'h35 } ;
		72 : message[24:26] = { 8'h33, 8'h39, 8'h30 } ;
		73 : message[24:26] = { 8'h33, 8'h39, 8'h35 } ;
		74 : message[24:26] = { 8'h34, 8'h30, 8'h30 } ; // 400
		75 : message[24:26] = { 8'h34, 8'h30, 8'h35 } ;
		76 : message[24:26] = { 8'h34, 8'h31, 8'h30 } ;
		77 : message[24:26] = { 8'h34, 8'h31, 8'h35 } ;
		78 : message[24:26] = { 8'h34, 8'h32, 8'h30 } ;
		79 : message[24:26] = { 8'h34, 8'h32, 8'h35 } ;
		80 : message[24:26] = { 8'h34, 8'h33, 8'h30 } ;
		81 : message[24:26] = { 8'h34, 8'h33, 8'h35 } ;
		82 : message[24:26] = { 8'h34, 8'h34, 8'h30 } ;
		83 : message[24:26] = { 8'h34, 8'h34, 8'h35 } ;
		84 : message[24:26] = { 8'h34, 8'h35, 8'h30 } ;
		85 : message[24:26] = { 8'h34, 8'h35, 8'h35 } ;
		86 : message[24:26] = { 8'h34, 8'h36, 8'h30 } ;
		87 : message[24:26] = { 8'h34, 8'h36, 8'h35 } ;
		88 : message[24:26] = { 8'h34, 8'h37, 8'h30 } ;
		89 : message[24:26] = { 8'h34, 8'h37, 8'h35 } ;
		90 : message[24:26] = { 8'h34, 8'h38, 8'h30 } ;
		91 : message[24:26] = { 8'h34, 8'h38, 8'h35 } ;
		92 : message[24:26] = { 8'h34, 8'h39, 8'h30 } ;
		93 : message[24:26] = { 8'h34, 8'h39, 8'h35 } ;
		94 : message[24:26] = { 8'h35, 8'h30, 8'h30 } ; // 500
		95 : message[24:26] = { 8'h35, 8'h30, 8'h35 } ;
		96 : message[24:26] = { 8'h35, 8'h31, 8'h30 } ;
		97 : message[24:26] = { 8'h35, 8'h31, 8'h35 } ;
		98 : message[24:26] = { 8'h35, 8'h32, 8'h30 } ;
		99 : message[24:26] = { 8'h35, 8'h32, 8'h35 } ;
		100 : message[24:26] = { 8'h35, 8'h33, 8'h30 } ;
		101 : message[24:26] = { 8'h35, 8'h33, 8'h35 } ;
		102 : message[24:26] = { 8'h35, 8'h34, 8'h30 } ;
		103 : message[24:26] = { 8'h35, 8'h34, 8'h35 } ;
		104 : message[24:26] = { 8'h35, 8'h35, 8'h30 } ;
		105 : message[24:26] = { 8'h35, 8'h35, 8'h35 } ;
		106 : message[24:26] = { 8'h35, 8'h36, 8'h30 } ;
		107 : message[24:26] = { 8'h35, 8'h36, 8'h35 } ;
		108 : message[24:26] = { 8'h35, 8'h37, 8'h30 } ;
		109 : message[24:26] = { 8'h35, 8'h37, 8'h35 } ;
		110 : message[24:26] = { 8'h35, 8'h38, 8'h30 } ;
		111 : message[24:26] = { 8'h35, 8'h38, 8'h35 } ;
		112 : message[24:26] = { 8'h35, 8'h39, 8'h30 } ;
		113 : message[24:26] = { 8'h35, 8'h39, 8'h35 } ;
		114 : message[24:26] = { 8'h36, 8'h30, 8'h30 } ; // 600
		115 : message[24:26] = { 8'h36, 8'h30, 8'h35 } ;
		116 : message[24:26] = { 8'h36, 8'h31, 8'h30 } ;
		117 : message[24:26] = { 8'h36, 8'h31, 8'h35 } ;
		118 : message[24:26] = { 8'h36, 8'h32, 8'h30 } ;
		119 : message[24:26] = { 8'h36, 8'h32, 8'h35 } ;
		120 : message[24:26] = { 8'h36, 8'h33, 8'h30 } ;
		121 : message[24:26] = { 8'h36, 8'h33, 8'h35 } ;
		122 : message[24:26] = { 8'h36, 8'h34, 8'h30 } ;
		123 : message[24:26] = { 8'h36, 8'h34, 8'h35 } ;
		124 : message[24:26] = { 8'h36, 8'h35, 8'h30 } ;
		125 : message[24:26] = { 8'h36, 8'h35, 8'h35 } ;
		126 : message[24:26] = { 8'h36, 8'h36, 8'h30 } ;
		127 : message[24:26] = { 8'h36, 8'h36, 8'h35 } ;
		128 : message[24:26] = { 8'h36, 8'h37, 8'h30 } ;
		129 : message[24:26] = { 8'h36, 8'h37, 8'h35 } ;
		130 : message[24:26] = { 8'h36, 8'h38, 8'h30 } ;
		131 : message[24:26] = { 8'h36, 8'h38, 8'h35 } ;
		132 : message[24:26] = { 8'h36, 8'h39, 8'h30 } ;
		133 : message[24:26] = { 8'h36, 8'h39, 8'h35 } ;
		134 : message[24:26] = { 8'h37, 8'h30, 8'h30 } ; // 700
		135 : message[24:26] = { 8'h37, 8'h30, 8'h35 } ;
		136 : message[24:26] = { 8'h37, 8'h31, 8'h30 } ;
		137 : message[24:26] = { 8'h37, 8'h31, 8'h35 } ;
		138 : message[24:26] = { 8'h37, 8'h32, 8'h30 } ;
		139 : message[24:26] = { 8'h37, 8'h32, 8'h35 } ;
		140 : message[24:26] = { 8'h37, 8'h33, 8'h30 } ;
		141 : message[24:26] = { 8'h37, 8'h33, 8'h35 } ;
		142 : message[24:26] = { 8'h37, 8'h34, 8'h30 } ;
		143 : message[24:26] = { 8'h37, 8'h34, 8'h35 } ;
		144 : message[24:26] = { 8'h37, 8'h35, 8'h30 } ;
		145 : message[24:26] = { 8'h37, 8'h35, 8'h35 } ;
		146 : message[24:26] = { 8'h37, 8'h36, 8'h30 } ;
		147 : message[24:26] = { 8'h37, 8'h36, 8'h35 } ;
		148 : message[24:26] = { 8'h37, 8'h37, 8'h30 } ;
		149 : message[24:26] = { 8'h37, 8'h37, 8'h35 } ;
		150 : message[24:26] = { 8'h37, 8'h38, 8'h30 } ;
		151 : message[24:26] = { 8'h37, 8'h38, 8'h35 } ;
		152 : message[24:26] = { 8'h37, 8'h39, 8'h30 } ;
		153 : message[24:26] = { 8'h37, 8'h39, 8'h35 } ;
		154 : message[24:26] = { 8'h38, 8'h30, 8'h30 } ; // 800
	endcase
		
    end
/*

	logic [7:0] message [0:MESSAGE_LENGTH - 1] = '{
		// -----------------------------
		// Line 1: "LFO GENERATOR"
		// -----------------------------
		8'h4C, // [ 0] 'L'
		8'h46, // [ 1] 'F'
		8'h4F, // [ 2] 'O'
		8'h20, // [ 3] ' '
		8'h47, // [ 4] 'G'
		8'h45, // [ 5] 'E'
		8'h4E, // [ 6] 'N'
		8'h45, // [ 7] 'E'
		8'h52, // [ 8] 'R'
		8'h41, // [ 9] 'A'
		8'h54, // [10] 'T'
		8'h4F, // [11] 'O'
		8'h52, // [12] 'R'
		8'h20, // [13] ' '
		8'h20, // [14] ' '
		

		// -----------------------------
		// Line 3: "RATE: 100 BPM"
		// -----------------------------

		8'h20, // [15] ' '
		8'h20, // [45] ' '
		8'h52, // [32] 'R'
		8'h41, // [33] 'A'
		8'h54, // [34] 'T'
		8'h45, // [35] 'E'
		8'h3A, // [36] ':'
		8'h31, // [38] '1'
		8'h30, // [39] '0'
		8'h30, // [40] '0'
		8'h42, // [42] 'B'
		8'h50, // [43] 'P'
		8'h4D, // [44] 'M'
		
		8'h20, // [46] ' '
		8'h20, // [47] ' '
		8'h20, // [37] ' '
		8'h20, // [41] ' '

		
		// -----------------------------
		// Line 2: "> WAVE: SQUARE"
		// -----------------------------
		8'h3E, // [16] '>'
		8'h57, // [18] 'W'
		8'h41, // [19] 'A'
		8'h56, // [20] 'V'
		8'h45, // [21] 'E'
		8'h3A, // [22] ':'
		8'h53, // [24] 'S'
		8'h51, // [25] 'Q'
		8'h55, // [26] 'U'
		8'h41, // [27] 'A'
		8'h52, // [28] 'R'
		8'h45, // [29] 'E'
		8'h20, // [30] ' '
		8'h20, // [31] ' '
		8'h20, // [23] ' '
		8'h20, // [17] ' '
		
		// -----------------------------
		// Line 4: "DEPTH: XXX "
		// -----------------------------
		8'h20, // [17] ' '
		8'h44, // [48] 'D'
		8'h45, // [49] 'E'
		8'h50, // [50] 'P'
		8'h54, // [51] 'T'
		8'h48, // [52] 'H'
		8'h3A, // [53] ':'
		8'hDB, // [55] 'BOX'
		8'hDB, // [56] 'BOX' // Alternative box8'hDB,
		8'hDB, // [57] ' '
		8'h20, // [58] ' '
		8'h20, // [59] ' '
		8'h20, // [60] ' '
		8'h20, // [61] ' '
		8'h20, // [62] ' '
		8'h20 // [17] ' '


	};
*/

	
    // State machine states
    typedef enum logic [4:0] {
      INIT,
      FUNCTION_SET1,
		FUNCTION_SET2,
		FUNCTION_SET3,
	   CLEAR_DISPLAY,
		RETURN_HOME,
		ENTRY_MODE,
		DISPLAY_ONOFF,
		CURSORSHIFT,
		FUNCTION_SET,

      READY,
		WRITE_DATA_L13,
		SWITCH_TO_L24,
		WRITE_DATA_L24,
		STOP
		  
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
			write_count <= 0;
			data <= 8'h00;
			state <=INIT;
		end else begin
			state <=next_state;
			case (state)
				INIT: begin// give time delay for bootup
				end FUNCTION_SET1: begin
					RS <= 0;
					RW <= 0;
					data <= 8'b0011_0000;
				end FUNCTION_SET2: begin
//					data <= 8'b0011_1000;
				end FUNCTION_SET3: begin
//					data <= 8'b0011_1000;
				end CLEAR_DISPLAY: begin
					data <= 8'b0000_0001; // Clear display
				end RETURN_HOME: begin
					data <= 8'b0000_0010; // Return home
				end ENTRY_MODE: begin //assign curser moving direction and enable shift of display
					data <= 8'b0000_0110; 
				end DISPLAY_ONOFF: begin//Display ON/OFF 1xxx. display (D), cursor (C), and blinking of cursor (B)  
					data <= 8'b0000_1110; 
				end CURSORSHIFT: begin// 0 0 0 1 S/C R/L 0 0 – Shift entire display (S/C=1) or move cursor (S/C=0), direction by R/L (0=left, 1=right) without DDRAM change.
					data <= 8'b0001_0100; // Example: cursor shift left
				end FUNCTION_SET: begin
					data <= 8'b0011_1100; // Set 8-bit, 2-line, 5x10 dots
				end WRITE_DATA_L13: begin
					 RS <= 1;
					 data <= message[write_count];
					 if (write_count == 31) begin
						  state <= SWITCH_TO_L24;
					 end else begin
						  write_count <= write_count + 1;
					 end
				end SWITCH_TO_L24: begin
					 RS <= 0;
					 data <= 8'hC0; // Jump to Line 4 start
					 state <= WRITE_DATA_L24;
				end WRITE_DATA_L24: begin
					 RS <= 1;
					 data <= message[write_count];
					 if (write_count == MESSAGE_LENGTH-1) begin
						  state <= STOP;
					 end else begin
						  write_count <= write_count + 1;
					 end
				end STOP: begin
					RS <= 0;
					data <= 8'h00;
					write_count  <= 0;
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
					FUNCTION_SET3:  next_state = CLEAR_DISPLAY;
					CLEAR_DISPLAY:  next_state = RETURN_HOME;
					RETURN_HOME:    next_state = ENTRY_MODE;
					ENTRY_MODE:     next_state = DISPLAY_ONOFF;
					DISPLAY_ONOFF:  next_state = CURSORSHIFT;
					CURSORSHIFT:    next_state = FUNCTION_SET;
					FUNCTION_SET:   next_state = WRITE_DATA_L13;

					WRITE_DATA_L13: begin
						 if (write_count == 31)
							  next_state = SWITCH_TO_L24;
						 else
							  next_state = WRITE_DATA_L13;
					end

					SWITCH_TO_L24: next_state = WRITE_DATA_L24;

					WRITE_DATA_L24: begin
						 if (write_count == MESSAGE_LENGTH-1)
							  next_state = STOP;
						 else
							  next_state = WRITE_DATA_L24;
					end

					STOP: next_state = STOP;

					default: next_state = INIT;
			  endcase
		 end
	end
	/*Timing block, used to create */
	always_comb begin
//		 case (state)
//			  INIT:           next_count = 2000; // 150ms * 1.25 = 200
//			  FUNCTION_SET:   next_count = 513;  // 4.1ms * 1.25
//			  DISPLAY_CONTROL:next_count = 150;  // 1.5ms delay
//			  ENTRY_MODE:     next_count = 150;
//			  CLEAR_DISPLAY:  next_count = 150;
//			  READY:          next_count = 150;
//			  WRITE_DATA_L13:     next_count = 150;
//			  default:        next_count = 150;
//		 endcase
		 case (state)
//			  INIT:           next_count = 4000; // 150ms * 1.25
//			  FUNCTION_SET:   next_count = 4000;  // 4.1ms * 1.25
//			  DISPLAY_CONTROL:next_count = 4000;  // 1.5ms delay
//			  ENTRY_MODE:     next_count = 4000;
//			  CLEAR_DISPLAY:  next_count = 4000;
//			  READY:          next_count = 4000;
//			  WRITE_DATA_L13:     next_count = 4000;
			  default:        next_count = 600000;
		 endcase
	end
	   /*
   Counter block, triggers e 
    if e==next_count/2 then
        e = 0// creates falling edge to trigger reading data on the LCD chip
    else if e == 0 then
        e = 1// creates rising edge to trigger loading data
   */
	always_ff @( posedge clk, negedge rst) begin
		 if (~rst) begin 
			 count <= next_count;
			 E <= 1;

		 end else begin
//			 data = count;  //stimulation purposes only
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
