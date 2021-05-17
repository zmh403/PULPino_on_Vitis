`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/27/2021 06:44:24 PM
// Design Name: 
// Module Name: JTAG_init_parser
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


module JTAG_init_parser(
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
    
    parameter INIT = 3'b001;
    parameter JTAG_SETUP = 3'b010;
    parameter JTAG_DONE = 3'b100;
    
    reg [2:0] PRES_STATE;
    reg [2:0] NEXT_STATE;
    
    //state_index
    integer i;
    
    // Output reg
    reg spi_csn, trstn, tdi, tms, tck;
    reg tck_zero, reset_done;
    //JTAG finish setup, and start Loading File.
    reg jset_done;
    
    assign tck_o = tck;
    assign trstn_o = trstn;
    assign tdi_o = tdi;
    assign tms_o = tms;
    assign jtag_done = jset_done;
    
    // Control tck
    always @(*) begin
        if (tck_zero) begin
            tck = 1'b0;
        end else begin
            tck = clk;
        end
    end    
    // Control index
    always @(negedge clk) begin
        if(start) begin
            i<=0;
        end else begin
            i<=i+1;
        end
        //$display("i = %d", i);
    end
    
    // Control path sequential circuit.
    always @(negedge clk, negedge rst_n) begin
        if (!rst_n) begin
            PRES_STATE <= INIT;
        end else begin
            PRES_STATE <= NEXT_STATE;
            //$display("Current STATE: %b", PRES_STATE);
        end
    end
    
    // Control path combinational circuit.
    always @(*) begin
        NEXT_STATE = INIT;
    case (PRES_STATE)
    INIT:begin
        if(start) begin
            NEXT_STATE = JTAG_SETUP;
        end else begin
            NEXT_STATE = INIT;
        end
    end
    JTAG_SETUP:begin
        if(reset_done) begin
            NEXT_STATE = JTAG_DONE;
        end else begin
            NEXT_STATE = JTAG_SETUP;
        end
    end
    JTAG_DONE:begin
        NEXT_STATE = JTAG_DONE;
    end
    endcase
    end
    
    // Control path sequential circuit.
    always @(negedge clk) begin
        tck_zero <= 1'b1;
        reset_done <= 1'b0;
        tms <= 1'b0;
        tdi <= 1'b0;
        trstn <= 1'b1;
        jset_done <= 1'b0;
    case (PRES_STATE)
    INIT:begin
        tck_zero <= 1'b1;
        tms <= 1'b0;
        tdi <= 1'b0;
        trstn <= 1'b0;
    end
    JTAG_SETUP:begin
        tck_zero <= 1'b0;
        if(i<5 || i==6 || i==7 || i==13 || i==14 || i==16 || i==24 || i==25 || i==26 || i==81 || i==82 || i==83 || i==152 || i==153) begin
            tms <= 1'b1;
        end
        if(i==13 || i==24 || i==29 || i==48 || i==57 || i==58 || i==59 || i==65 || i==70 || i==72 || i==73 || i==77) begin
            tdi <= 1'b1;
        end else if(i==78 || i==86 || i==119 || i==123 || i==127 || i==131 || i==135 || i==139 || i==143 || i==147) begin 
            tdi <= 1'b1;
        end
        if(i==153) begin
            reset_done <= 1'b1;
        end
    end
    JTAG_DONE:begin
        tck_zero <= 1'b0;
        tck_zero <= 1'b1;
        jset_done <= 1'b1;
    end
    endcase
    end
endmodule
