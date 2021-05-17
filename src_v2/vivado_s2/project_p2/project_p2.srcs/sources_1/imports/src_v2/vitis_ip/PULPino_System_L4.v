// This is a generated file. Use and modify at your own risk.
////////////////////////////////////////////////////////////////////////////////
// Description: Pipelined adder.  This is an adder with pipelines before and
//   after the adder datapath.  The output is fed into a FIFO and prog_full is
//   used to signal ready.  This design allows for high Fmax.

// default_nettype of none prevents implicit wire declaration.
`default_nettype none
`timescale 1ps / 1ps

module PULPino_System_L4 #(
  parameter integer C_AXIS_TDATA_WIDTH = 512, // Data width of both input and output data
  parameter integer C_ADDER_BIT_WIDTH  = 32,
  parameter integer C_NUM_CLOCKS       = 1
)
(

  input wire                             s_axis_aclk,
  input wire                             s_axis_areset,
  input wire                             s_axis_tvalid,
  output wire                            s_axis_tready,
  input wire  [C_AXIS_TDATA_WIDTH-1:0]   s_axis_tdata,
  input wire  [C_AXIS_TDATA_WIDTH/8-1:0] s_axis_tkeep,
  input wire                             s_axis_tlast,

  input wire                             m_axis_aclk,
  output wire                            m_axis_tvalid,
  input  wire                            m_axis_tready,
  output wire [C_AXIS_TDATA_WIDTH-1:0]   m_axis_tdata,
  output wire [C_AXIS_TDATA_WIDTH/8-1:0] m_axis_tkeep,
  output wire                            m_axis_tlast,
  input wire                             ap_start,
  input wire                             read_done,
  // Scalar
  input  wire                            spi_enable_i,
  input  wire                            use_qspi_i,
  input  wire [32-1:0]                   spi_addr_idx_i
);

localparam integer LP_NUM_LOOPS = C_AXIS_TDATA_WIDTH/C_ADDER_BIT_WIDTH;
localparam         LP_CLOCKING_MODE = C_NUM_CLOCKS == 1 ? "common_clock" : "independent_clock";
/////////////////////////////////////////////////////////////////////////////
// Variables
/////////////////////////////////////////////////////////////////////////////
reg                              d1_tvalid = 1'b0;
reg                              d1_tready = 1'b0;
reg   [C_AXIS_TDATA_WIDTH-1:0]   d1_tdata;
reg   [C_AXIS_TDATA_WIDTH/8-1:0] d1_tkeep;
reg                              d1_tlast;
//reg   [C_ADDER_BIT_WIDTH-1:0]    d1_constant;


integer i;

reg                              d2_tvalid = 1'b0;
reg   [C_AXIS_TDATA_WIDTH-1:0]   d2_tdata;
reg   [C_AXIS_TDATA_WIDTH/8-1:0] d2_tkeep;
reg                              d2_tlast;

wire  [C_AXIS_TDATA_WIDTH/8-1:0] d2_tstrb;
wire  [0:0]                      d2_tid;
wire  [0:0]                      d2_tdest;
wire  [0:0]                      d2_tuser;

wire                             prog_full_axis;
wire                             fifo_tvalid;
reg                              fifo_ready_r = 1'b0;


// LFC stage
reg rd_tready_spi, lfc_tvalid, lfc_tlast, uart_tvalid, spi_enable, use_qspi;
reg [31:0] spi_addr_idx;
// JTAG
wire tck, trstn, tdi, tms, tdo;
// SPI
wire spi_sdi0, spi_sdi1, spi_sdi2, spi_sdi3;
wire spi_csn, spi_sck, fetch_enable;
wire spi_sdo0, spi_sdo1, spi_sdo2, spi_sdo3;
// Uart
reg rx, tx, gpio_out_8, d1_gpio_out_8;
reg [7:0] uart_data;
wire [31:0]gpio_out; 

/*
//JTAG
reg tck, trstn, tdi, tms;
wire tdo;  
//SPI
reg spi_sdi0, spi_sdi1, spi_sdi2, spi_sdi3;
wire spi_sdo0, spi_sdo1, spi_sdo2, spi_sdo3, tx;
reg spi_csn, spi_sck, fetch_enable;
reg rx, d1_gpio_out_8;
*/


/////////////////////////////////////////////////////////////////////////////
// RTL Logic
/////////////////////////////////////////////////////////////////////////////



// Register s_axis_interface/inputs
always @(posedge s_axis_aclk) begin
  d1_tvalid <= s_axis_tvalid;
  d1_tready <= s_axis_tready;
  d1_tdata  <= s_axis_tdata;
  d1_tkeep  <= s_axis_tkeep;
  d1_tlast  <= s_axis_tlast;

  d1_gpio_out_8 <= gpio_out[8];
  d2_tdata <= uart_data;
end


/*
// Adder function
always @(posedge s_axis_aclk) begin
  for (i = 0; i < LP_NUM_LOOPS; i = i + 1) begin
    d2_tdata[i*C_ADDER_BIT_WIDTH+:C_ADDER_BIT_WIDTH] <= d1_tdata[C_ADDER_BIT_WIDTH*i+:C_ADDER_BIT_WIDTH] + d1_constant;
  end
end
*/

// Register inputs to fifo
always @(posedge s_axis_aclk) begin
  d2_tvalid <= d1_tvalid & d1_tready;
  d2_tkeep  <= d1_tkeep;
  d2_tlast  <= d1_tlast;
end

// Tie-off unused inputs to FIFO.
assign d2_tstrb = {C_AXIS_TDATA_WIDTH/8{1'b1}};
assign d2_tid   = 1'b0;
assign d2_tdest = 1'b0;
assign d2_tuser = 1'b0;

always @(posedge s_axis_aclk) begin
  fifo_ready_r <= ~prog_full_axis;
end

assign s_axis_tready = fifo_ready_r & rd_tready_spi;
assign m_axis_tvalid = fifo_tvalid & uart_tvalid 

pulpino pulpino_wrap(
  .clk(s_axis_aclk),
  .rst_n(~s_axis_areset),

  .fetch_enable_i(fetch_enable),

  .spi_clk_i(spi_sck),
  .spi_cs_i(spi_csn),
  .spi_mode_o( ),
  .spi_sdo0_o(spi_sdo0),
  .spi_sdo1_o(spi_sdo1),
  .spi_sdo2_o(spi_sdo2),
  .spi_sdo3_o(spi_sdo3),
  .spi_sdi0_i(spi_sdi0),
  .spi_sdi1_i(spi_sdi1),
  .spi_sdi2_i(spi_sdi2),
  .spi_sdi3_i(spi_sdi3),
  // Not used
  .spi_master_clk_o( ),
  .spi_master_csn0_o( ),
  .spi_master_csn1_o( ),
  .spi_master_csn2_o( ),
  .spi_master_csn3_o( ),
  .spi_master_mode_o( ),
  .spi_master_sdo0_o( ),
  .spi_master_sdo1_o( ),
  .spi_master_sdo2_o( ),
  .spi_master_sdo3_o( ),
  .spi_master_sdi0_i(1'b0),
  .spi_master_sdi1_i(1'b0),
  .spi_master_sdi2_i(1'b0),
  .spi_master_sdi3_i(1'b0),
  .uart_tx(tx),
  .uart_rx(rx),
  .uart_rts( ),
  .uart_dtr( ),
  .uart_cts(1'b0),
  .uart_dsr(1'b0),
  // Not used
  .scl_i(1'b0),
  .scl_o( ),
  .scl_oen_o( ),
  .sda_i(1'b0),
  .sda_o( ),
  .sda_oen_o( ),
  // Not used
  .gpio_in(32'b0),
  .gpio_out(gpio_out),
  .gpio_dir( ),

  .tck_i(tck),
  .trstn_i(trstn),
  .tms_i(tms),
  .tdi_i(tdi),
  .tdo_o(tdo)
  );

Loading_file_controller inst_LFC (
    .clk_1(s_axis_aclk),
	.clk_2(m_axis_aclk),
	.rst_n(~s_axis_areset),
	//JTAG input
	.tdo(tdo),
	.tck(tck),
	//JTAG output
	.trstn_o(trstn),
	.tdi_o(tdi),
	.tms_o(tms),
	//SPI input
	.spi_data(d1_tdata),
	.r_valid_i(d1_tvalid),
	.r_last_i(d1_tlast),
	.ap_start(ap_start),
	.rb_done(read_done),
	.spi_sdi0(spi_sdo0),
	.spi_sdi1(spi_sdo1),
	.spi_sdi2(spi_sdo2),
	.spi_sdi3(spi_sdo3),
	.start_spi(spi_enable),
	.spi_addr_idx(spi_addr_idx),
	.use_qspi(use_qspi),
	//SPI output
	.r_valid_o( ),
	.r_last_o( ),
	.rb_start( ),
	.rb_ready(rd_tready_spi),
	.spi_sdo0_o(spi_sdi0),
	.spi_sdo1_o(spi_sdi1),
	.spi_sdo2_o(spi_sdi2),
	.spi_sdo3_o(spi_sdi3),
	.spi_csn_o(spi_csn),
	.spi_sck_o(spi_sck),
	.fetch_enable_o(fetch_enable),
	//Uart
	.gpio_out_8(gpio_out_8),
	.uart_rx(tx),
	.uart_tx(rx),
	.recv_data(uart_data),
	.w_valid_o(uart_tvalid),
	.uart_done()
);



xpm_fifo_axis #(
   .CDC_SYNC_STAGES     ( 2                      ) , // DECIMAL
   .CLOCKING_MODE       ( LP_CLOCKING_MODE       ) , // String
   .ECC_MODE            ( "no_ecc"               ) , // String
   .FIFO_DEPTH          ( 32                     ) , // DECIMAL
   .FIFO_MEMORY_TYPE    ( "distributed"          ) , // String
   .PACKET_FIFO         ( "false"                ) , // String
   .PROG_EMPTY_THRESH   ( 5                      ) , // DECIMAL
   .PROG_FULL_THRESH    ( 32-5                   ) , // DECIMAL
   .RD_DATA_COUNT_WIDTH ( 6                      ) , // DECIMAL
   .RELATED_CLOCKS      ( 0                      ) , // DECIMAL
   .TDATA_WIDTH         ( C_AXIS_TDATA_WIDTH     ) , // DECIMAL
   .TDEST_WIDTH         ( 1                      ) , // DECIMAL
   .TID_WIDTH           ( 1                      ) , // DECIMAL
   .TUSER_WIDTH         ( 1                      ) , // DECIMAL
   .USE_ADV_FEATURES    ( "1002"                 ) , // String: Only use prog_full
   .WR_DATA_COUNT_WIDTH ( 6                      )   // DECIMAL
)
inst_xpm_fifo_axis (
   .s_aclk             ( s_axis_aclk    ) ,
   .s_aresetn          ( ~s_axis_areset ) ,
   .s_axis_tvalid      ( d2_tvalid      ) ,
   .s_axis_tready      (                ) ,
   .s_axis_tdata       ( d2_tdata       ) ,
   .s_axis_tstrb       ( d2_tstrb       ) ,
   .s_axis_tkeep       ( d2_tkeep       ) ,
   .s_axis_tlast       ( d2_tlast       ) ,
   .s_axis_tid         ( d2_tid         ) ,
   .s_axis_tdest       ( d2_tdest       ) ,
   .s_axis_tuser       ( d2_tuser       ) ,
   .almost_full_axis   (                ) ,
   .prog_full_axis     ( prog_full_axis ) ,
   .wr_data_count_axis (                ) ,
   .injectdbiterr_axis ( 1'b0           ) ,
   .injectsbiterr_axis ( 1'b0           ) ,

   .m_aclk             ( m_axis_aclk   ) ,
   .m_axis_tvalid      ( fifo_tvalid ) ,
   .m_axis_tready      ( m_axis_tready ) ,
   .m_axis_tdata       ( m_axis_tdata  ) ,
   .m_axis_tstrb       (               ) ,
   .m_axis_tkeep       ( m_axis_tkeep  ) ,
   .m_axis_tlast       ( m_axis_tlast  ) ,
   .m_axis_tid         (               ) ,
   .m_axis_tdest       (               ) ,
   .m_axis_tuser       (               ) ,
   .almost_empty_axis  (               ) ,
   .prog_empty_axis    (               ) ,
   .rd_data_count_axis (               ) ,
   .sbiterr_axis       (               ) ,
   .dbiterr_axis       (               )
);

endmodule

`default_nettype wire

