`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/07/2021 11:36:12 AM
// Design Name: 
// Module Name: testbench
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


module Loading_file_controller(
    input clk_1,
    input clk_2,
    input rst_n,
    
    //JTAG
    input tdo,
    output tck,
    output trstn_o,
    output tdi_o,
    output tms_o,
    
    //SPI
    // Recieve from Read buffer
    input [31:0] spi_data, //tdata_2
    input r_valid_i,
    input r_last_i,
    // Read_buffer control
    input ap_start,
    output rb_start,
    output rb_ready,
    // Control FSM
    input rb_done,
    //Output to PULP_System_L4
    output r_valid_o,
    output r_last_o,
    // SPI Slave I/O ports
    input spi_sdi0,
    input spi_sdi1,
    input spi_sdi2,
    input spi_sdi3,
    output spi_sdo0_o,
    output spi_sdo1_o,
    output spi_sdo2_o,
    output spi_sdo3_o,
    output spi_csn_o,
    output spi_sck_o,
    output fetch_enable_o,
    
    // Scalar control signals
    input start_spi,
    input[31:0] spi_addr_idx,
    input use_qspi,
    
    // Uart signals
    //gpio_out[8]
    input gpio_out_8,
    // uart_rx connect to PULPino's tx
    input uart_rx,
    // uart_tx connect to PULPino's rx
    output uart_tx,
    output[7:0] recv_data,
    output w_valid_o,
    output uart_done
    );
    
    wire spi_start_load,jtag_start;
    
    JTAG_init_parser jtag_i (
    .clk(clk_2),
    .rst_n(rst_n),
    .start(jtag_start),
    .tdo(tdo),
    .tck_o(tck),
    .trstn_o(trstn_o),
    .tdi_o(tdi_o),
    .tms_o(tms_o),
    .jtag_done(spi_start_load)
    );
    
    SPI_load_file spi_i (
    //Input
    .clk(clk_2),
    .rst_n(rst_n),
    .spi_data(spi_data),
    .valid_i(r_valid_i),
    .last_i(r_last_i),
    .ap_start(ap_start),
    .ap_done(rb_done),
    .spi_sdi0(spi_sdi0),
    .spi_sdi1(spi_sdi1),
    .spi_sdi2(spi_sdi2),
    .spi_sdi3(spi_sdi3),
    .start_load(spi_start_load),
    .start_spi(start_spi),
    .spi_addr_idx(spi_addr_idx),
    .use_qspi(use_qspi),
    //Output
    .valid(r_valid_o),
    .last(r_last_o),
    .rb_start(rb_start),
    .rb_ready(rb_ready),
    .jtag_setup(jtag_start),
    .spi_sdo0_o(spi_sdo0_o),
    .spi_sdo1_o(spi_sdo1_o),
    .spi_sdo2_o(spi_sdo2_o),
    .spi_sdo3_o(spi_sdo3_o),
    .spi_csn_o(spi_csn_o),
    .spi_sck_o(spi_sck_o),
    .fetch_enable_o(fetch_enable_o)
    );
    
    uart uart_i (
    // Input
    .clk (clk_1),
    .rst_n (rst_n),
    .gpio(gpio_out_8),
    .rx_en (1'b1),
    .rx (uart_rx),
    // Output
    .tx (uart_tx),
    .char(recv_data),
    .uart_w_valid(w_valid_o),
    .done(uart_done)
    );
   
endmodule