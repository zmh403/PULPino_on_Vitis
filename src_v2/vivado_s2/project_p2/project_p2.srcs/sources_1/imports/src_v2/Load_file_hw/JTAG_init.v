`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/06/2021 02:00:59 PM
// Design Name: 
// Module Name: JTAG_init
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module JTAG_init(
    input clk,
    input rst_n,
    input start,
    input tdo,
    output tck_o,
    output trstn_o,
    output tdi_o,
    output tms_o,
    output jtag_done
    );
    
    //Define state parameters
    parameter INIT = 5'b00001;
    parameter JTAG_RESET = 5'b00010;
    parameter JTAG_SOFTRESET = 5'b00011;
    // JTAG_INIT
    parameter JTAG_goto_SHIFT_IR = 5'b00100;
    parameter JTAG_shift_SHIFT_IR = 5'b00101;
    parameter JTAG_IDLE = 5'b00110;
    parameter JTAG_goto_SHIFT_DR = 5'b00111;
    parameter JTAG_shift_NBITS_SHIFT_DR_1 = 5'b01000; // 6 bits
    parameter JTAG_shift_NBITS_SHIFT_DR_2 = 5'b01001; // 53 bits
    parameter JTAG_shift_nbits_noex = 5'b01010;
    parameter JTAG_shift_NBITS_SHIFT_DR_3 = 5'b01011; // 33 bits
    parameter SPI_start_load_file = 5'b01100;

    reg [4:0] PRES_STATE;
    reg [4:0] NEXT_STATE;
    
    reg [7:0] numbits;
    reg [3:0] jtag_instr;
    reg [63:0] jtag_datain;
    reg [255:0] jtag_dataout;
    
    //state_index
    integer i;
    
    // Output reg
    reg spi_csn, trstn, tdi, tms, tck;
    reg tck_zero, reset_i;
    
    //state control signal
    reg SEQ_done;
    reg JRST_done;
    reg JSWRST_done;
    reg GSIR_done;
    reg SSIR_done;
    reg JIDLE_done;
    reg JGSDR_done;
    reg JSSDR1_done;
    reg JSSDR2_done;
    reg JSSDR3_done;
    reg JSNN_done; //shift_nbits_noex
    
    //JTAG finish setup, and start Loading File.
    reg START_LF;
    
    assign tck_o = tck;
    assign trstn_o = trstn;
    assign tdi_o = tdi;
    assign tms_o = tms;
    assign jtag_done = START_LF;
    
    // Control tck
    always @(*) begin
        if (tck_zero) begin
            tck = 1'b0;
        end else begin
            tck = clk;
        end
    end
    
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            jtag_instr <= 4'b1000;
            i<=0;
        end else begin
            $display("i: %d", i);
            if(reset_i)
                i<=0;
            else
                i<=i+1;
        end
    end
 
    // Control path sequential circuit.
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            PRES_STATE <= INIT;
        end else begin
            PRES_STATE <= NEXT_STATE;
            $display("Current STATE: %b", PRES_STATE);
        end
    end
    
    // Control path combinational circuit.
    always @(*) begin
        NEXT_STATE = INIT;
        reset_i = 1'b0;
        numbits = 8'b0;
        jtag_datain = 64'b0;
        case (PRES_STATE)
        INIT:begin
            if(start) begin
                NEXT_STATE = JTAG_RESET;
                reset_i = 1'b1;
            end else begin
                NEXT_STATE = INIT;
            end
        end
        JTAG_RESET:begin
            if(!JRST_done) begin
                NEXT_STATE = JTAG_RESET;
            end else begin
                NEXT_STATE = JTAG_SOFTRESET;
                reset_i = 1'b1;
            end
        end
        JTAG_SOFTRESET:begin
            if(!JSWRST_done) begin
                NEXT_STATE = JTAG_SOFTRESET;
            end else begin
                NEXT_STATE = JTAG_goto_SHIFT_IR;
                reset_i = 1'b1;
            end
        end
        JTAG_goto_SHIFT_IR:begin
            if(!GSIR_done) begin
                NEXT_STATE = JTAG_goto_SHIFT_IR;
            end else begin
                NEXT_STATE = JTAG_shift_SHIFT_IR;
                reset_i = 1'b1;
            end
        end
        JTAG_shift_SHIFT_IR:begin
            if(!SSIR_done) begin
                NEXT_STATE = JTAG_shift_SHIFT_IR;
            end else begin
                NEXT_STATE = JTAG_IDLE;
                reset_i = 1'b1;
            end
        end
        JTAG_IDLE:begin
            if(!JIDLE_done) begin
                NEXT_STATE = JTAG_IDLE;
            end else begin
                NEXT_STATE = JTAG_goto_SHIFT_DR;
                reset_i = 1'b1;
            end
        end
        JTAG_goto_SHIFT_DR:begin
            if(!JGSDR_done) begin
                NEXT_STATE = JTAG_goto_SHIFT_DR;
            end else begin
                NEXT_STATE = JTAG_shift_NBITS_SHIFT_DR_1;
                reset_i = 1'b1;
            end
        end
        JTAG_shift_NBITS_SHIFT_DR_1:begin
            if(!JSSDR1_done) begin
                NEXT_STATE = JTAG_shift_NBITS_SHIFT_DR_1;
                //6 bits in DR_1
                numbits = 8'h06;
                jtag_datain = 64'h20;
            end else begin
                NEXT_STATE = JTAG_shift_NBITS_SHIFT_DR_2;
                reset_i = 1'b1;
            end
        end
        JTAG_shift_NBITS_SHIFT_DR_2:begin
            if(!JSSDR2_done) begin
                NEXT_STATE = JTAG_shift_NBITS_SHIFT_DR_2;
                //53 bits in DR_2
                numbits = 8'h35;
                jtag_datain = 64'h03_1A10_7008_0001;
            end else begin
                NEXT_STATE = JTAG_shift_nbits_noex;
                reset_i = 1'b1;
            end
        end
        JTAG_shift_nbits_noex:begin
            if(!JSNN_done) begin
                NEXT_STATE = JTAG_shift_nbits_noex;
                //17 bits in noex
                numbits = 8'h11;
                jtag_datain = 64'h1;
            end else begin
                NEXT_STATE = JTAG_shift_NBITS_SHIFT_DR_3;
                reset_i = 1'b1;
            end
        end
        JTAG_shift_NBITS_SHIFT_DR_3:begin
            if(!JSSDR3_done) begin
                NEXT_STATE = JTAG_shift_NBITS_SHIFT_DR_3;
                //34 bits in DR_3
                numbits = 8'h22;
                jtag_datain = 64'h11111111;
            end else begin
                NEXT_STATE = SPI_start_load_file;
                reset_i = 1'b1;
            end
        end
        SPI_start_load_file:begin
            //i=0;
            reset_i = 1'b1;
            NEXT_STATE = SPI_start_load_file;
        end
        endcase
    end

    // Data path sequential circuit.
    always @(posedge clk) begin
        tck_zero <= 1'b0;
        SEQ_done <= 1'b0;
        JRST_done <= 1'b0;
        JSWRST_done <= 1'b0;
        GSIR_done <= 1'b0;
        SSIR_done <= 1'b0;
        JIDLE_done <= 1'b0;
        JGSDR_done <= 1'b0;
        JSSDR1_done <= 1'b0;
        JSSDR2_done <= 1'b0;
        JSSDR3_done <= 1'b0;
        JSNN_done <= 1'b0;
        START_LF <= 1'b0;
        
        case (PRES_STATE)
        INIT:begin
            tck_zero <= 1'b1;
            tms <= 1'b0;
            trstn <= 1'b0;
            tdi <= 1'b0;
        end
        JTAG_RESET:begin
            if(i==0) begin
                tck_zero <= 1'b1;
                tms <= 1'b0;
                trstn <= 1'b0;
                tdi <= 1'b0;
            end else if(i==1) begin
                trstn <= 1'b1;
                JRST_done <= 1'b1;
            end
        end
        JTAG_SOFTRESET:begin
            if(i<5) begin
                tms <= 1'b1;
                trstn <= 1'b1;
                tdi <= 1'b0;
            end else if(i==5) begin
                tms <= 1'b0;
            end else if(i>5) begin
                JSWRST_done <= 1'b1;
            end
        end
        JTAG_goto_SHIFT_IR:begin
            if(i<2) begin
                trstn <= 1'b1;
                tdi <= 1'b0;
                // from IDLE to SHIFT_IR : tms sequence 1100
                tms <= 1'b1;
            end else if(i==2) begin
                tms <= 1'b0;
            end else if(i>3) begin
                GSIR_done <= 1'b1;
            end
        end
        JTAG_shift_SHIFT_IR:begin
            if(i<4) begin
                trstn <= 1'b1;
                tms <= 1'b0;
                if(i==3) begin
                    tms <= 1'b1;
                end
                tdi <= jtag_instr[i];
            end else if(i==4) begin
                SSIR_done <= 1'b1;
            end
        end
        JTAG_IDLE:begin
            if(i==0) begin
                trstn <= 1'b1;
                tms <= 1'b1;
                tdi <= 1'b0;
            end else if(i==1) begin
                tms <= 1'b0;
            end else if(i==2) begin
                JIDLE_done <= 1'b1;
            end
        end
        JTAG_goto_SHIFT_DR:begin
            if(i==0) begin
                trstn <= 1'b1;
                tdi <= 1'b0;
                // from IDLE to SHIFT_IR : tms sequence 100
                tms <= 1'b1;
            end else if(i==1) begin
                tms <= 1'b0;
            end else if(i==3) begin
                JGSDR_done <= 1'b1;
            end
        end
        // state:1000
        JTAG_shift_NBITS_SHIFT_DR_1:begin
            //numbits = 6
            if(i<numbits) begin
                trstn <= 1'b1;
                tms <= 1'b0;
                if(i==(numbits-1))
                    tms <= 1'b1;
                tdi <= jtag_datain[i];
            end
            //access tdo delay 1 cycle
            if(i>0 && i<(numbits+1))
                jtag_dataout[i-1] <= tdo;
            //update_and_goto_shift
            if(i==numbits) begin
                trstn <= 1'b1;
                // from SHIFT_DR to RUN_TEST : tms sequence 110
                tms <= 1'b1;
                tdi <= 1'b0;
            end else if(i==(numbits+1)) begin
                tms <= 1'b1;
            end else if(i==(numbits+2)) begin
                tms <= 1'b0;
                JSSDR1_done <= 1'b1;
            end
        end
        // state:1001
        JTAG_shift_NBITS_SHIFT_DR_2:begin
            //numbits = 53
            //03_1A10_7008_0001
            if(i<numbits) begin
                trstn <= 1'b1;
                tms <= 1'b0;
                if(i==(numbits-1))
                    tms <= 1'b1;
                tdi <= jtag_datain[i];
            end
            //access tdo delay 1 cycle
            if(i>0 && i<(numbits+1))
                jtag_dataout[i-1] <= tdo;
            //update_and_goto_shift
            if(i==numbits) begin
                trstn <= 1'b1;
                // from SHIFT_DR to RUN_TEST : tms sequence 110
                tms <= 1'b1;
                tdi <= 1'b0;
            end else if(i==(numbits+1)) begin
                tms <= 1'b1;
            end else if(i==(numbits+2)) begin
                tms <= 1'b0;
                JSSDR2_done <= 1'b1;
            end
        end
        // state:1010
        JTAG_shift_nbits_noex:begin
            trstn <= 1'b1;
            tms <= 1'b0;
            //numbits = 33
            if(i<numbits)
                tdi <= jtag_datain[i];

            //access tdo delay 1 cycle
            if(i>0 && i<numbits+1)
                jtag_dataout[i-1] <= tdo;
            if(i==numbits)
                JSNN_done <= 1'b1;
        end
        // state:1011
        JTAG_shift_NBITS_SHIFT_DR_3:begin
            //numbits = 34
            if(i<numbits) begin
                trstn <= 1'b1;
                tms <= 1'b0;
                if(i==(numbits-1))
                    tms <= 1'b1;
                tdi <= jtag_datain[i];
            end
            //access tdo delay 1 cycle
            if(i>0 && i<(numbits+1))
                jtag_dataout[i-1] <= tdo;
            //idle
            if(i==numbits) begin
                trstn <= 1'b1;
                tms <= 1'b1;
                tdi <= 1'b0;
            end else if(i==(numbits+1)) begin
                tms <= 1'b0;
            end else if(i==numbits+2) begin
                JSSDR3_done <= 1'b1;
            end
        end
        //End: Configure JTAG and set boot address  
        SPI_start_load_file: begin
            START_LF <= 1'b1;
            tck_zero <= 1'b1;
        end
        endcase
    end
endmodule