`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/20/2021 12:02:20 PM
// Design Name: 
// Module Name: uart
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
/*
BAUD_RATE = 781250
BIT_PERIOD = 1280000 ps = 1280 ns
=> 32 cycles
parameter BIT_PERIOD = (1000000000/BAUD_RATE*1000);
*/
module uart (
    input clk,
    input rst_n,
    input rx_en,
    input gpio,
    input rx,
    output tx,
    output [7:0] char,
    output uart_w_valid,
    output done
    );
    
    parameter BIT_PERIOD = 1280;
    parameter WAIT_NEG_RX = 4'b0001;
    parameter WAIT_15_CYCLE = 4'b0010;
    parameter STORE_CHAR = 4'b0011;
    parameter WAIT_31_CYCLE = 4'b0100;
    parameter DONE = 4'b0101;
    
    reg[3:0] PRES_STATE, NEXT_STATE;
    reg[7:0] character;
    reg start_wait, start_access, update_idx, update_char, next_char, valid, uart_done;
    reg reset_i;
    
    integer i,k;
    
    assign tx = 1'b1;
    assign char = character;
    assign uart_w_valid = valid;
    assign done = uart_done;

    // State Control index
    always @(posedge clk) begin
        if(reset_i) begin
            i<=0;
        end else begin
            i<=i+1;
        end
    end

        // Control path sequential circuit.
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            PRES_STATE <= WAIT_NEG_RX;
        end else begin
            PRES_STATE <= NEXT_STATE;
            if(gpio) begin
                PRES_STATE <= DONE;
            end
            //$display($time, " Current STATE: %b ", PRES_STATE);
        end
    end
    
    always @(*) begin
        reset_i = 1'b0;
        case (PRES_STATE)
        WAIT_NEG_RX:begin
            reset_i = 1'b1;
            k=0;
        end
        WAIT_15_CYCLE:begin
             if(start_access) begin
                reset_i = 1'b1;
            end
        end
        STORE_CHAR:begin
            if(update_idx) begin
                k=k+1;
                reset_i = 1'b1;
            end else if(update_char) begin
                reset_i = 1'b1;
            end
        end
        WAIT_31_CYCLE:begin
            if(next_char) begin
                k=0;
                reset_i = 1'b1;
            end
        end
        DONE:begin
        end
        endcase
    end
    
    // Control path combinational circuit.
    always @(*) begin
        NEXT_STATE = WAIT_NEG_RX;
        case (PRES_STATE)
        WAIT_NEG_RX:begin
            if(start_wait) begin
                NEXT_STATE = WAIT_15_CYCLE;
            end
        end
        WAIT_15_CYCLE:begin
            if(start_access) begin
                NEXT_STATE = STORE_CHAR;
            end else begin
                NEXT_STATE = WAIT_15_CYCLE;
            end
        end
        STORE_CHAR:begin
            //$display("en_Char = %b, en_idx = %b", update_char, update_idx);
            if(update_char) begin
                NEXT_STATE = WAIT_31_CYCLE;
            end else begin
                NEXT_STATE = STORE_CHAR;
            end
        end
        WAIT_31_CYCLE:begin
            if(next_char) begin
                NEXT_STATE = WAIT_NEG_RX;
            end else begin
                NEXT_STATE = WAIT_31_CYCLE;
            end
        end
        DONE:begin
            NEXT_STATE = DONE;
        end
        endcase
    end
    
    // Data path sequential circuit.
    always @(posedge clk) begin
        start_wait <= 1'b0;
        start_access <= 1'b0;
        next_char <= 1'b0;
        update_idx <= 1'b0;
        update_char <= 1'b0;
        valid <= 1'b0;
        uart_done <= 1'b0;
        
        case (PRES_STATE)
        WAIT_NEG_RX:begin
            if(rx==0) begin
                start_wait <= 1'b1;
            end
        end
        WAIT_15_CYCLE:begin
            // 15-1 cycles
            //$display($time, " i = %d", i);
            if(i==14) begin
                start_access <= 1'b1;
            end
        end
        STORE_CHAR:begin
            if(rx_en) begin
                //$display($time, " i = %d", i);
                if(i==30) begin
                    character[k] <= rx;
                    update_idx <= 1'b1;
                    //$display($time, " k = %d, rx = %b", k, rx);
                    if(k==7) begin
                        update_char <= 1'b1;
                        valid <= 1'b1;
                    end
                end
            end
        end
        WAIT_31_CYCLE:begin
            if(i==30) begin
                next_char <= 1'b1;
                //$display($time, " CHAR = %b  %s", character, character);
            end
        end
        DONE:begin
            uart_done <= 1'b1;
        end
        endcase
    end
endmodule
