// This is a generated file. Use and modify at your own risk.
////////////////////////////////////////////////////////////////////////////////
// default_nettype of none prevents implicit wire declaration.
`default_nettype none

module PULPino_System_L3 #(
  parameter integer C_M_AXI_ADDR_WIDTH       = 64 ,
  parameter integer C_M_AXI_DATA_WIDTH       = 512,
  parameter integer C_XFER_SIZE_WIDTH        = 32,
  parameter integer C_ADDER_BIT_WIDTH        = 32
)
(
  // System Signals
  input wire                                    aclk               ,
  input wire                                    areset             ,
  // Extra clocks
  input wire                                    kernel_clk         ,
  input wire                                    kernel_rst         ,
  // AXI4 master interface
  output wire                                   m_axi_awvalid      ,
  input wire                                    m_axi_awready      ,
  output wire [C_M_AXI_ADDR_WIDTH-1:0]          m_axi_awaddr       ,
  output wire [8-1:0]                           m_axi_awlen        ,
  output wire                                   m_axi_wvalid       ,
  input wire                                    m_axi_wready       ,
  output wire [C_M_AXI_DATA_WIDTH-1:0]          m_axi_wdata        ,
  output wire [C_M_AXI_DATA_WIDTH/8-1:0]        m_axi_wstrb        ,
  output wire                                   m_axi_wlast        ,
  output wire                                   m_axi_arvalid      ,
  input wire                                    m_axi_arready      ,
  output wire [C_M_AXI_ADDR_WIDTH-1:0]          m_axi_araddr       ,
  output wire [8-1:0]                           m_axi_arlen        ,
  input wire                                    m_axi_rvalid       ,
  output wire                                   m_axi_rready       ,
  input wire [C_M_AXI_DATA_WIDTH-1:0]           m_axi_rdata        ,
  input wire                                    m_axi_rlast        ,
  input wire                                    m_axi_bvalid       ,
  output wire                                   m_axi_bready       ,
  input wire                                    ap_start           ,
  output wire                                   ap_done            ,
  input wire [C_M_AXI_ADDR_WIDTH-1:0]           ctrl_addr_offset   ,
  input wire [C_XFER_SIZE_WIDTH-1:0]            ctrl_xfer_size_in_bytes,
  // Scalar
  input  wire                              		spi_enable_i	       ,
  input  wire                              		use_qspi_i      	   ,
  input  wire [32-1:0]                     		spi_addr_idx_i,
  input  wire [32-1:0]                          instr_num_i   
);

timeunit 1ps;
timeprecision 1ps;


///////////////////////////////////////////////////////////////////////////////
// Local Parameters
///////////////////////////////////////////////////////////////////////////////
localparam integer LP_DW_BYTES             = C_M_AXI_DATA_WIDTH/8;
localparam integer LP_AXI_BURST_LEN        = 4096/LP_DW_BYTES < 256 ? 4096/LP_DW_BYTES : 256;
localparam integer LP_LOG_BURST_LEN        = $clog2(LP_AXI_BURST_LEN);
localparam integer LP_BRAM_DEPTH           = 512;
localparam integer LP_RD_MAX_OUTSTANDING   = LP_BRAM_DEPTH / LP_AXI_BURST_LEN;
localparam integer LP_WR_MAX_OUTSTANDING   = 32;

///////////////////////////////////////////////////////////////////////////////
// Wires and Variables
///////////////////////////////////////////////////////////////////////////////

// Control logic
logic                          done = 1'b0;
// AXI read master stage
logic                          read_done;
logic                          rd_tvalid;
logic                          rd_tready;
logic                          rd_tlast;
logic [C_M_AXI_DATA_WIDTH-1:0] rd_tdata;
logic                          rd_rready;
// L4 stage
logic                          L4_tvalid;
logic                          L4_tready;
logic [C_M_AXI_DATA_WIDTH-1:0] L4_tdata;
//logic [C_ADDER_BIT_WIDTH-1:0]  ctrl_constant_kernel_clk;
// AXI write master stage
logic                          write_done;

logic                          gpio_out_en;
logic						   spi_enable;
logic						   use_qspi;
logic [31:0]				   spi_addr_idx, instr_num;

///////////////////////////////////////////////////////////////////////////////
// Begin RTL
///////////////////////////////////////////////////////////////////////////////

// AXI4 Read Master, output format is an AXI4-Stream master, one stream per thread.
axi_read_master #(
  .C_M_AXI_ADDR_WIDTH  ( C_M_AXI_ADDR_WIDTH    ) ,
  .C_M_AXI_DATA_WIDTH  ( C_M_AXI_DATA_WIDTH    ) ,
  .C_XFER_SIZE_WIDTH   ( C_XFER_SIZE_WIDTH     ) ,
  .C_MAX_OUTSTANDING   ( LP_RD_MAX_OUTSTANDING ) ,
  .C_INCLUDE_DATA_FIFO ( 1                     )
)
inst_axi_read_master (
  .aclk                    ( aclk                    ) ,
  .areset                  ( areset                  ) ,
  .ctrl_start              ( ap_start                ) ,
  .ctrl_done               ( read_done               ) ,
  .ctrl_addr_offset        ( ctrl_addr_offset        ) ,
  .ctrl_xfer_size_in_bytes ( ctrl_xfer_size_in_bytes ) ,
  .m_axi_arvalid           ( m_axi_arvalid           ) ,
  .m_axi_arready           ( m_axi_arready           ) ,
  .m_axi_araddr            ( m_axi_araddr            ) ,
  .m_axi_arlen             ( m_axi_arlen             ) ,
  .m_axi_rvalid            ( m_axi_rvalid            ) ,
  .m_axi_rready            ( m_axi_rready            ) ,
  //.m_axi_rready            ( rd_rready            ) ,
  .m_axi_rdata             ( m_axi_rdata             ) ,
  .m_axi_rlast             ( m_axi_rlast             ) ,
  .m_axis_aclk             ( aclk                    ) ,
  .m_axis_areset           ( kernel_rst              ) ,
  .m_axis_tvalid           ( rd_tvalid               ) ,
  .m_axis_tready           ( rd_tready               ) ,
  .m_axis_tlast            ( rd_tlast                ) ,
  .m_axis_tdata            ( rd_tdata                )
);

/*
// Generate constant.
xpm_cdc_array_single #(
  .DEST_SYNC_FF   ( 4                 ) ,
  .INIT_SYNC_FF   ( 0                 ) ,
  .SRC_INPUT_REG  ( 1                 ) ,
  .SIM_ASSERT_CHK ( 1                 ) ,
  .WIDTH          ( C_ADDER_BIT_WIDTH )
)
inst_ctrl_constant_kernel_clk (
  .src_in   ( ctrl_constant            ) ,
  .src_clk  ( aclk                     ) ,
  .dest_out ( ctrl_constant_kernel_clk ) ,
  .dest_clk ( kernel_clk               )
);
*/

PULPino_System_L4 #(
  .C_AXIS_TDATA_WIDTH ( C_M_AXI_DATA_WIDTH ) ,
  .C_ADDER_BIT_WIDTH  ( C_ADDER_BIT_WIDTH  ) ,
  .C_NUM_CLOCKS       ( 1                  )
)
inst_L4  (
  .s_axis_aclk   ( aclk                         ) ,
  .s_axis_areset ( kernel_rst                   ) ,
  .s_axis_tvalid ( rd_tvalid                    ) ,
  .s_axis_tready ( rd_tready                    ) ,
  .s_axis_tdata  ( rd_tdata                     ) ,
  .s_axis_tkeep  ( {C_M_AXI_DATA_WIDTH/8{1'b1}} ) ,
  .s_axis_tlast  ( rd_tlast                     ) ,
  .m_axis_aclk   ( kernel_clk                   ) ,
  .m_axis_tvalid ( L4_tvalid                 ) ,
  .m_axis_tready ( L4_tready                 ) ,
  .m_axis_tdata  ( L4_tdata                  ) ,
  .m_axis_tkeep  (                              ) , // Not used
  .m_axis_tlast  (                              ) , // Not used
  //.ap_start (ap_start),
  //.read_done (read_done),
  .gpio_out_en(gpio_out_en),
  .spi_enable_i(spi_enable),
  .use_qspi_i(use_qspi),
  .spi_addr_idx_i(spi_addr_idx),
  .instr_num_i(instr_num)
);

// AXI4 Write Master
axi_write_master #(
  .C_M_AXI_ADDR_WIDTH  ( C_M_AXI_ADDR_WIDTH    ) ,
  .C_M_AXI_DATA_WIDTH  ( C_M_AXI_DATA_WIDTH    ) ,
  .C_XFER_SIZE_WIDTH   ( C_XFER_SIZE_WIDTH     ) ,
  .C_MAX_OUTSTANDING   ( LP_WR_MAX_OUTSTANDING ) ,
  .C_INCLUDE_DATA_FIFO ( 1                     )
)
inst_axi_write_master (
  .aclk                    ( aclk                    ) ,
  .areset                  ( areset                  ) ,
  .ctrl_start              ( ap_start                ) ,
  .ctrl_done               ( write_done              ) ,
  .ctrl_addr_offset        ( ctrl_addr_offset        ) ,
  .ctrl_xfer_size_in_bytes ( ctrl_xfer_size_in_bytes ) ,
  .m_axi_awvalid           ( m_axi_awvalid           ) ,
  .m_axi_awready           ( m_axi_awready           ) ,
  .m_axi_awaddr            ( m_axi_awaddr            ) ,
  .m_axi_awlen             ( m_axi_awlen             ) ,
  .m_axi_wvalid            ( m_axi_wvalid            ) ,
  .m_axi_wready            ( m_axi_wready            ) ,
  .m_axi_wdata             ( m_axi_wdata             ) ,
  .m_axi_wstrb             ( m_axi_wstrb             ) ,
  .m_axi_wlast             ( m_axi_wlast             ) ,
  .m_axi_bvalid            ( m_axi_bvalid            ) ,
  .m_axi_bready            ( m_axi_bready            ) ,
  .s_axis_aclk             ( aclk                    ) ,
  .s_axis_areset           ( kernel_rst              ) ,
  .s_axis_tvalid           ( L4_tvalid            ) ,
  .s_axis_tready           ( L4_tready            ) ,
  .s_axis_tdata            ( L4_tdata             )
);

always @(posedge aclk) begin
  spi_enable <= spi_enable_i;
  use_qspi <= use_qspi_i;
  spi_addr_idx <= spi_addr_idx_i;
  instr_num <= instr_num_i;
end

assign ap_done = write_done;
//assign ap_done = gpio_out_en;
//assign ap_done = 1'b1;
always @(*) begin
    //$display("m_axi_wlast = %b", m_axi_wlast);
    //if(gpio_out_en)
    //    $display($time, " gpio_out enable !! ");
    //$display($time, " ap_done = %b", ap_done);
end
endmodule : PULPino_System_L3
`default_nettype wire
