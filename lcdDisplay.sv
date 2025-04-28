// ELEX 7660
// File: lcdDisplay.sv
// Description: provides LCD display for the LFO generator
// Author: Parry Zhuo 		Date: 2025-03-22


module lcdDisplay #(
    parameter int MESSAGE_LENGTH = 63
)(
    input  logic        CLOCK_50,       // 50 MHz clock
    input  logic        rst,        	// Reset signal, GPIO_0[3]
    output logic        RS,         	// Register Select GPIO_0[4]
    output logic        RW,         	// Read/Write GPIO_0[5]
    output logic        E,          	// Enable signal GPIO_0[6]
    output logic [7:0]  data,       	// Data bus for LCD
    input  logic [1:0]  sel,
    input  logic [2:0]  shape, depth,
    input  logic [7:0]  freq
);

    logic [12:0] count, next_count;
    logic [12:0] write_count;
    logic [15:0] clk_div_count ; 	// count used to divide clock
	 
	 
    state_t state, next_state;

    /*INITIAL MESSAGE*/
    // Line 1 message: "LFO GENERATOR   "
    logic [7:0] line1 [0:15] = '{
        8'h4C, 8'h46, 8'h4F, 8'h20, 8'h47, 8'h45, 8'h4E, 8'h45,
        8'h52, 8'h41, 8'h54, 8'h4F, 8'h52, 8'h20, 8'h20, 8'h20
    };
    // Line 2 message: "> WAVE: SQUARE  "
    logic [7:0] line2 [0:15] = '{
        8'h20, 8'h20, 8'h57, 8'h41, 8'h56, 8'h45, 8'h3A, 8'h20,
        8'h53, 8'h51, 8'h55, 8'h41, 8'h52, 8'h45, 8'h20, 8'h20
    };
    // Line 3 message: "  RATE: 100 BPM "
    logic [7:0] line3 [0:15] = '{
        8'h20, 8'h20, 8'h52, 8'h41, 8'h54, 8'h45, 8'h3A, 8'h20,
        8'h31, 8'h30, 8'h30, 8'h20, 8'h42, 8'h50, 8'h4D, 8'h20
    };
    // Line 4 message: "  DEPTH: xxx    "
    logic [7:0] line4 [0:15] = '{
        8'h20, 8'h20, 8'h44, 8'h45, 8'h50, 8'h54, 8'h48, 8'h3A,
        8'h3A, 8'hDB, 8'hDB, 8'h20, 8'h20, 8'h20, 8'h20, 8'h20
    };

    typedef enum logic [4:0] {
        INIT, FUNCTION_SET1, FUNCTION_SET2, FUNCTION_SET3,
        CLEAR_DISPLAY, RETURN_HOME, ENTRY_MODE, DISPLAY_ONOFF,
        CURSORSHIFT, FUNCTION_SET,
        WRITE_LINE1, JUMP_LINE2, WRITE_LINE2, JUMP_LINE3,
        WRITE_LINE3, JUMP_LINE4, WRITE_LINE4, JUMP_LINE1,
        STOP
    } state_t;


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
            state <= INIT;
        end else begin
            state <= next_state;
            case (state)
                INIT:           ;
                FUNCTION_SET1:  begin RS <= 0; RW <= 0; data <= 8'b0011_0000; end
                FUNCTION_SET2:  ;
                FUNCTION_SET3:  ;
                CLEAR_DISPLAY:  data <= 8'b0000_0001; // Clear display
                RETURN_HOME:    data <= 8'b0000_0010; // Return home
                ENTRY_MODE:     data <= 8'b0000_0110; //assign curser moving direction and enable shift of display
                DISPLAY_ONOFF:  data <= 8'b0000_1100;  //Display ON/OFF 1xxx. display (D), cursor (C), and blinking of cursor (B)  
                CURSORSHIFT:    data <= 8'b0001_0100; // 0 0 0 1 S/C R/L 0 0 ? Shift entire display (S/C=1) or move cursor (S/C=0), direction by R/L (0=left, 1=right) without DDRAM change.
                FUNCTION_SET:   data <= 8'b0011_1100;  // Set 8-bit, 2-line, 5x10 dots

					
                WRITE_LINE1:    begin RS <= 1; data <= line1[write_count]; write_count <= write_count + 1; end
                WRITE_LINE2:    begin RS <= 1; data <= line2[write_count]; write_count <= write_count + 1; end
                WRITE_LINE3:    begin RS <= 1; data <= line3[write_count]; write_count <= write_count + 1; end
                WRITE_LINE4:    begin RS <= 1; data <= line4[write_count]; write_count <= write_count + 1; end

                JUMP_LINE2:     begin RS <= 0; data <= 8'hC1; write_count <= 0; end
                JUMP_LINE3:     begin RS <= 0; data <= 8'h91; write_count <= 0; end
                JUMP_LINE4:     begin RS <= 0; data <= 8'hD1; write_count <= 0; end
                JUMP_LINE1:     begin RS <= 0; data <= 8'h81; write_count <= 0; end

                STOP:           begin RS <= 0; data <= 8'h00; write_count <= 0; end
                default:        ;
            endcase
        end
    end

    // State Changer initilization. LINE1->LINE2->LINE3->LINE4->LINE 1->....
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
                FUNCTION_SET:   next_state = WRITE_LINE1;

                WRITE_LINE1:    next_state = (write_count == 15) ? JUMP_LINE2 : WRITE_LINE1;
                JUMP_LINE2:     next_state = WRITE_LINE2;
                WRITE_LINE2:    next_state = (write_count == 15) ? JUMP_LINE3 : WRITE_LINE2;
                JUMP_LINE3:     next_state = WRITE_LINE3;
                WRITE_LINE3:    next_state = (write_count == 15) ? JUMP_LINE4 : WRITE_LINE3;
                JUMP_LINE4:     next_state = WRITE_LINE4;
                WRITE_LINE4:    next_state = (write_count == 15) ? JUMP_LINE2 : WRITE_LINE4;
                JUMP_LINE1:     next_state = WRITE_LINE1;

                STOP:           next_state = STOP;
                default:        next_state = INIT;
            endcase
        end
    end

    //E pin timing block( which sends commands to LCD)
	always_comb begin
		 case (state) 
			  INIT:           next_count = 2000; // 150ms * 1.25 = 200 need long wait for proper LCD bootup
			  FUNCTION_SET1:  next_count = 513;// 4.1ms * 1.25
			  default:        next_count = 150; // every other command can be 1.5ms
		 endcase
	end

	   /*
   Counter block, triggers e 
    if e==next_count/2 then
        e = 0// creates falling edge to trigger reading data on the LCD chip
    else if e == 0 then
        e = 1// creates rising edge to trigger loading data
   */
    always_ff @(posedge clk, negedge rst) begin
        if (~rst) begin
            count <= next_count;
            E <= 1;
        end else begin
            count <= count - 1;
            if (count < (next_count >> 1) && count > 0) begin
                E <= 0;
            end else if (count <= 0) begin
                E <= 1;
                count <= next_count;
            end else begin
                E <= 1;
            end
        end
    end
	 
	 /*BELOW IS GUI MANAGEMENT FOR TURNING ENCODERS*/
    // Cursor Management
    always_comb begin
        line2[0] = 8'h20;
        line3[0] = 8'h20;
        line4[0] = 8'h20;

        case (sel)
            2'd0: begin
                line2[0] = 8'h3E; // '>' at WAVE
            end
            2'd1: begin
                line3[0] = 8'h3E; // '>' at RATE
            end
            2'd2: begin
                line4[0] = 8'h3E; // '>' at DEPTH
            end
            default: begin
                line2[0] = 8'h3E;
            end
        endcase
		  
		  //choosing shape for LINE 2
		  case ( shape )
				// "SINE" //
				default : line2[7:14] = '{ 8'h53, 8'h49, 8'h4E, 8'h45, 8'h20, 8'h20, 8'h20, 8'h20 } ;
				// "SQUARE" //
				1 : line2[7:14] = '{ 8'h53, 8'h51, 8'h55, 8'h41, 8'h52, 8'h45, 8'h20, 8'h20 } ;
				// "TRIANGLE" //
				2 : line2[7:14] = '{ 8'h54, 8'h52, 8'h49, 8'h41, 8'h4E, 8'h47, 8'h4C, 8'h45 } ;
				// "RAMP UP" //
				3 : line2[7:14] = '{ 8'h52, 8'h41, 8'h4D, 8'h50, 8'h20, 8'h55, 8'h50, 8'h20 } ;
				// "RAMPDOWN" //
				4 : line2[7:14] = '{ 8'h52, 8'h41, 8'h4D, 8'h50, 8'h44, 8'h4F, 8'h57, 8'h4E } ;
				// "S & H" //
				5 : line2[7:14] = '{ 8'h53, 8'h20, 8'h26, 8'h20, 8'h48, 8'h20, 8'h20, 8'h20 } ;
		endcase
				  //choosing depth for LINE 4
		case ( depth )
			// low //
			default : line4[8:12] = '{ 8'hDB, 8'h20, 8'h20, 8'h20, 8'h20 } ;
			// low-mid //
			1 :line4[8:12] = '{ 8'hDB, 8'hDB, 8'h20, 8'h20, 8'h20 } ;
			// mid //
			2 : line4[8:12] = '{ 8'hDB, 8'hDB, 8'hDB, 8'h20, 8'h20 } ;
			// high-mid //
			3 : line4[8:12] ='{ 8'hDB, 8'hDB, 8'hDB, 8'hDB, 8'h20 } ;
			// high //
			4 : line4[8:12] = '{ 8'hDB, 8'hDB, 8'hDB, 8'hDB, 8'hDB } ;
		endcase
		case ( freq )
				default : line3[8:10] = '{ 8'h20, 8'h33, 8'h30 } ; // 30
				1 : line3[8:10] = '{ 8'h20, 8'h33, 8'h35 } ;
				2 : line3[8:10] = '{ 8'h20, 8'h34, 8'h30 } ;
				3 : line3[8:10] = '{ 8'h20, 8'h34, 8'h35 } ;
				4 : line3[8:10] = '{ 8'h20, 8'h35, 8'h30 } ;
				5 : line3[8:10] = '{ 8'h20, 8'h35, 8'h35 } ;
				6 : line3[8:10] = '{ 8'h20, 8'h36, 8'h30 } ;
				7 : line3[8:10] = '{ 8'h20, 8'h36, 8'h35 } ;
				8 : line3[8:10] = '{ 8'h20, 8'h37, 8'h30 } ;
				9 : line3[8:10] = '{ 8'h20, 8'h37, 8'h35 } ;
				10 : line3[8:10] = '{ 8'h20, 8'h38, 8'h30 } ;
				11 : line3[8:10] = '{ 8'h20, 8'h38, 8'h35 } ;
				12 : line3[8:10] = '{ 8'h20, 8'h39, 8'h30 } ;
				13 : line3[8:10] = '{ 8'h20, 8'h39, 8'h35 } ;
				14 : line3[8:10] = '{ 8'h31, 8'h30, 8'h30 } ; // 100
				15 : line3[8:10] = '{ 8'h31, 8'h30, 8'h35 } ;
				16 : line3[8:10] = '{ 8'h31, 8'h31, 8'h30 } ;
				17 : line3[8:10] = '{ 8'h31, 8'h31, 8'h35 } ;
				18 : line3[8:10] = '{ 8'h31, 8'h32, 8'h30 } ;
				19 : line3[8:10] = '{ 8'h31, 8'h32, 8'h35 } ;
				20 : line3[8:10] = '{ 8'h31, 8'h33, 8'h30 } ;
				21 : line3[8:10] = '{ 8'h31, 8'h33, 8'h35 } ;
				22 : line3[8:10] = '{ 8'h31, 8'h34, 8'h30 } ;
				23 : line3[8:10] = '{ 8'h31, 8'h34, 8'h35 } ;
				24 : line3[8:10] = '{ 8'h31, 8'h35, 8'h30 } ;
				25 : line3[8:10] = '{ 8'h31, 8'h35, 8'h35 } ;
				26 : line3[8:10] = '{ 8'h31, 8'h36, 8'h30 } ;
				27 : line3[8:10] = '{ 8'h31, 8'h36, 8'h35 } ;
				28 : line3[8:10] = '{ 8'h31, 8'h37, 8'h30 } ;
				29 : line3[8:10] = '{ 8'h31, 8'h37, 8'h35 } ;
				30 : line3[8:10] = '{ 8'h31, 8'h38, 8'h30 } ;
				31 : line3[8:10] = '{ 8'h31, 8'h38, 8'h35 } ;
				32 : line3[8:10] = '{ 8'h31, 8'h39, 8'h30 } ;
				33 : line3[8:10] = '{ 8'h31, 8'h39, 8'h35 } ;
				34 : line3[8:10] = '{ 8'h32, 8'h30, 8'h30 } ; // 200
				35 : line3[8:10] = '{ 8'h32, 8'h30, 8'h35 } ;
				36 : line3[8:10] = '{ 8'h32, 8'h31, 8'h30 } ;
				37 : line3[8:10] = '{ 8'h32, 8'h31, 8'h35 } ;
				38 : line3[8:10] = '{ 8'h32, 8'h32, 8'h30 } ;
				39 : line3[8:10] = '{ 8'h32, 8'h32, 8'h35 } ;
				40 : line3[8:10] = '{ 8'h32, 8'h33, 8'h30 } ;
				41 : line3[8:10] = '{ 8'h32, 8'h33, 8'h35 } ;
				42 : line3[8:10] = '{ 8'h32, 8'h34, 8'h30 } ;
				43 : line3[8:10] = '{ 8'h32, 8'h34, 8'h35 } ;
				44 : line3[8:10] = '{ 8'h32, 8'h35, 8'h30 } ;
				45 : line3[8:10] = '{ 8'h32, 8'h35, 8'h35 } ;
				46 : line3[8:10] = '{ 8'h32, 8'h36, 8'h30 } ;
				47 : line3[8:10] = '{ 8'h32, 8'h36, 8'h35 } ;
				48 : line3[8:10] = '{ 8'h32, 8'h37, 8'h30 } ;
				49 : line3[8:10] = '{ 8'h32, 8'h37, 8'h35 } ;
				50 : line3[8:10] = '{ 8'h32, 8'h38, 8'h30 } ;
				51 : line3[8:10] = '{ 8'h32, 8'h38, 8'h35 } ;
				52 : line3[8:10] = '{ 8'h32, 8'h39, 8'h30 } ;
				53 : line3[8:10] = '{ 8'h32, 8'h39, 8'h35 } ;
				54 : line3[8:10] = '{ 8'h33, 8'h30, 8'h30 } ; // 300
				55 : line3[8:10] = '{ 8'h33, 8'h30, 8'h35 } ;
				56 : line3[8:10] = '{ 8'h33, 8'h31, 8'h30 } ;
				57 : line3[8:10] = '{ 8'h33, 8'h31, 8'h35 } ;
				58 : line3[8:10] = '{ 8'h33, 8'h32, 8'h30 } ;
				59 : line3[8:10] = '{ 8'h33, 8'h32, 8'h35 } ;
				60 : line3[8:10] = '{ 8'h33, 8'h33, 8'h30 } ;
				61 : line3[8:10] = '{ 8'h33, 8'h33, 8'h35 } ;
				62 : line3[8:10] = '{ 8'h33, 8'h34, 8'h30 } ;
				63 : line3[8:10] = '{ 8'h33, 8'h34, 8'h35 } ;
				64 : line3[8:10] = '{ 8'h33, 8'h35, 8'h30 } ;
				65 : line3[8:10] = '{ 8'h33, 8'h35, 8'h35 } ;
				66 : line3[8:10] = '{ 8'h33, 8'h36, 8'h30 } ;
				67 : line3[8:10] = '{ 8'h33, 8'h36, 8'h35 } ;
				68 : line3[8:10] = '{ 8'h33, 8'h37, 8'h30 } ;
				69 : line3[8:10] = '{ 8'h33, 8'h37, 8'h35 } ;
				70 : line3[8:10] = '{ 8'h33, 8'h38, 8'h30 } ;
				71 : line3[8:10] = '{ 8'h33, 8'h38, 8'h35 } ;
				72 : line3[8:10] = '{ 8'h33, 8'h39, 8'h30 } ;
				73 : line3[8:10] = '{ 8'h33, 8'h39, 8'h35 } ;
				74 : line3[8:10] = '{ 8'h34, 8'h30, 8'h30 } ; // 400
				75 : line3[8:10] = '{ 8'h34, 8'h30, 8'h35 } ;
				76 : line3[8:10] = '{ 8'h34, 8'h31, 8'h30 } ;
				77 : line3[8:10] = '{ 8'h34, 8'h31, 8'h35 } ;
				78 : line3[8:10] = '{ 8'h34, 8'h32, 8'h30 } ;
				79 : line3[8:10] = '{ 8'h34, 8'h32, 8'h35 } ;
				80 : line3[8:10] = '{ 8'h34, 8'h33, 8'h30 } ;
				81 : line3[8:10] = '{ 8'h34, 8'h33, 8'h35 } ;
				82 : line3[8:10] = '{ 8'h34, 8'h34, 8'h30 } ;
				83 : line3[8:10] = '{ 8'h34, 8'h34, 8'h35 } ;
				84 : line3[8:10] = '{ 8'h34, 8'h35, 8'h30 } ;
				85 : line3[8:10] = '{ 8'h34, 8'h35, 8'h35 } ;
				86 : line3[8:10] = '{ 8'h34, 8'h36, 8'h30 } ;
				87 : line3[8:10] = '{ 8'h34, 8'h36, 8'h35 } ;
				88 : line3[8:10] = '{ 8'h34, 8'h37, 8'h30 } ;
				89 : line3[8:10] = '{ 8'h34, 8'h37, 8'h35 } ;
				90 : line3[8:10] = '{ 8'h34, 8'h38, 8'h30 } ;
				91 : line3[8:10] = '{ 8'h34, 8'h38, 8'h35 } ;
				92 : line3[8:10] = '{ 8'h34, 8'h39, 8'h30 } ;
				93 : line3[8:10] = '{ 8'h34, 8'h39, 8'h35 } ;
				94 : line3[8:10] = '{ 8'h35, 8'h30, 8'h30 } ; // 500
				95 : line3[8:10] = '{ 8'h35, 8'h30, 8'h35 } ;
				96 : line3[8:10] = '{ 8'h35, 8'h31, 8'h30 } ;
				97 : line3[8:10] = '{ 8'h35, 8'h31, 8'h35 } ;
				98 : line3[8:10] = '{ 8'h35, 8'h32, 8'h30 } ;
				99 : line3[8:10] = '{ 8'h35, 8'h32, 8'h35 } ;
				100 : line3[8:10] = '{ 8'h35, 8'h33, 8'h30 } ;
				101 : line3[8:10] = '{ 8'h35, 8'h33, 8'h35 } ;
				102 : line3[8:10] = '{ 8'h35, 8'h34, 8'h30 } ;
				103 : line3[8:10] = '{ 8'h35, 8'h34, 8'h35 } ;
				104 : line3[8:10] = '{ 8'h35, 8'h35, 8'h30 } ;
				105 : line3[8:10] = '{ 8'h35, 8'h35, 8'h35 } ;
				106 : line3[8:10] = '{ 8'h35, 8'h36, 8'h30 } ;
				107 : line3[8:10] = '{ 8'h35, 8'h36, 8'h35 } ;
				108 : line3[8:10] = '{ 8'h35, 8'h37, 8'h30 } ;
				109 : line3[8:10] = '{ 8'h35, 8'h37, 8'h35 } ;
				110 : line3[8:10] = '{ 8'h35, 8'h38, 8'h30 } ;
				111 : line3[8:10] = '{ 8'h35, 8'h38, 8'h35 } ;
				112 : line3[8:10] = '{ 8'h35, 8'h39, 8'h30 } ;
				113 : line3[8:10] = '{ 8'h35, 8'h39, 8'h35 } ;
				114 : line3[8:10] = '{ 8'h36, 8'h30, 8'h30 } ; // 600
				115 : line3[8:10] = '{ 8'h36, 8'h30, 8'h35 } ;
				116 : line3[8:10] = '{ 8'h36, 8'h31, 8'h30 } ;
				117 : line3[8:10] = '{ 8'h36, 8'h31, 8'h35 } ;
				118 : line3[8:10] = '{ 8'h36, 8'h32, 8'h30 } ;
				119 : line3[8:10] = '{ 8'h36, 8'h32, 8'h35 } ;
				120 : line3[8:10] = '{ 8'h36, 8'h33, 8'h30 } ;
				121 : line3[8:10] = '{ 8'h36, 8'h33, 8'h35 } ;
				122 : line3[8:10] = '{ 8'h36, 8'h34, 8'h30 } ;
				123 : line3[8:10] = '{ 8'h36, 8'h34, 8'h35 } ;
				124 : line3[8:10] = '{ 8'h36, 8'h35, 8'h30 } ;
				125 : line3[8:10] = '{ 8'h36, 8'h35, 8'h35 } ;
				126 : line3[8:10] = '{ 8'h36, 8'h36, 8'h30 } ;
				127 : line3[8:10] = '{ 8'h36, 8'h36, 8'h35 } ;
				128 : line3[8:10] = '{ 8'h36, 8'h37, 8'h30 } ;
				129 : line3[8:10] = '{ 8'h36, 8'h37, 8'h35 } ;
				130 : line3[8:10] = '{ 8'h36, 8'h38, 8'h30 } ;
				131 : line3[8:10] = '{ 8'h36, 8'h38, 8'h35 } ;
				132 : line3[8:10] = '{ 8'h36, 8'h39, 8'h30 } ;
				133 : line3[8:10] = '{ 8'h36, 8'h39, 8'h35 } ;
				134 : line3[8:10] = '{ 8'h37, 8'h30, 8'h30 } ; // 700
				135 : line3[8:10] = '{ 8'h37, 8'h30, 8'h35 } ;
				136 : line3[8:10] = '{ 8'h37, 8'h31, 8'h30 } ;
				137 : line3[8:10] = '{ 8'h37, 8'h31, 8'h35 } ;
				138 : line3[8:10] = '{ 8'h37, 8'h32, 8'h30 } ;
				139 : line3[8:10] = '{ 8'h37, 8'h32, 8'h35 } ;
				140 : line3[8:10] = '{ 8'h37, 8'h33, 8'h30 } ;
				141 : line3[8:10] = '{ 8'h37, 8'h33, 8'h35 } ;
				142 : line3[8:10] = '{ 8'h37, 8'h34, 8'h30 } ;
				143 : line3[8:10] = '{ 8'h37, 8'h34, 8'h35 } ;
				144 : line3[8:10] = '{ 8'h37, 8'h35, 8'h30 } ;
				145 : line3[8:10] = '{ 8'h37, 8'h35, 8'h35 } ;
				146 : line3[8:10] = '{ 8'h37, 8'h36, 8'h30 } ;
				147 : line3[8:10] = '{ 8'h37, 8'h36, 8'h35 } ;
				148 : line3[8:10] = '{ 8'h37, 8'h37, 8'h30 } ;
				149 : line3[8:10] = '{ 8'h37, 8'h37, 8'h35 } ;
				150 : line3[8:10] = '{ 8'h37, 8'h38, 8'h30 } ;
				151 : line3[8:10] = '{ 8'h37, 8'h38, 8'h35 } ;
				152 : line3[8:10] = '{ 8'h37, 8'h39, 8'h30 } ;
				153 : line3[8:10] = '{ 8'h37, 8'h39, 8'h35 } ;
				154 : line3[8:10] = '{ 8'h38, 8'h30, 8'h30 } ; // 800
			endcase
	end
	 always_ff @(posedge CLOCK_50) 
        clk_div_count <= clk_div_count + 1'b1 ;
	 assign clk = clk_div_count[9];//50M/2^9 is approx 100KHz, o97656.25
	 
	 
endmodule
