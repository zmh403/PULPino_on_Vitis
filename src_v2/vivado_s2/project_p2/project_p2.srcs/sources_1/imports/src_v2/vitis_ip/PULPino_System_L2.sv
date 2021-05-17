// This is a generated file. Use and modify at your own risk.
//////////////////////////////////////////////////////////////////////////////// 
// default_nettype of none prevents implicit wire declaration.
`default_nettype none
module PULPino_System_L2 #(
  parameter integer C_SPI_AXI_ADDR_WIDTH = 64,
  parameter integer C_SPI_AXI_DATA_WIDTH = 32
)
(
  // System Signals
  input  wire                              ap_clk         ,
  input  wire                              ap_rst_n       ,
  input  wire                              ap_clk_2       ,
  input  wire                              ap_rst_n_2     ,
  // AXI4 master interface spi_axi
  output wire                              spi_axi_awvalid,
  input  wire                              spi_axi_awready,
  output wire [C_SPI_AXI_ADDR_WIDTH-1:0]   spi_axi_awaddr ,
  output wire [8-1:0]                      spi_axi_awlen  ,
  output wire                              spi_axi_wvalid ,
  input  wire                              spi_axi_wready ,
  output wire [C_SPI_AXI_DATA_WIDTH-1:0]   spi_axi_wdata  ,
  output wire [C_SPI_AXI_DATA_WIDTH/8-1:0] spi_axi_wstrb  ,
  output wire                              spi_axi_wlast  ,
  input  wire                              spi_axi_bvalid ,
  output wire                              spi_axi_bready ,
  output wire                              spi_axi_arvalid,
  input  wire                              spi_axi_arready,
  output wire [C_SPI_AXI_ADDR_WIDTH-1:0]   spi_axi_araddr ,
  output wire [8-1:0]                      spi_axi_arlen  ,
  input  wire                              spi_axi_rvalid ,
  output wire                              spi_axi_rready ,
  input  wire [C_SPI_AXI_DATA_WIDTH-1:0]   spi_axi_rdata  ,
  input  wire                              spi_axi_rlast  ,
  // Control Signals
  input  wire                              ap_start       ,
  output wire                              ap_idle        ,
  output wire                              ap_done        ,
  output wire                              ap_ready       ,
  input  wire                              spi_enable     ,
  input  wire                              use_qspi       ,
  input  wire [32-1:0]                     spi_addr_idx   ,
  input  wire [64-1:0]                     spi_data       
);


timeunit 1ps;
timeprecision 1ps;

///////////////////////////////////////////////////////////////////////////////
// Local Parameters
///////////////////////////////////////////////////////////////////////////////
// Large enough for interesting traffic.
localparam integer  LP_DEFAULT_LENGTH_IN_BYTES = 16384;
localparam integer  LP_NUM_EXAMPLES    = 1;

///////////////////////////////////////////////////////////////////////////////
// Wires and Variables
///////////////////////////////////////////////////////////////////////////////
(* KEEP = "yes" *)
logic                                areset                         = 1'b0;
logic                                kernel_rst                     = 1'b0;
logic                                ap_start_r                     = 1'b0;
logic                                ap_idle_r                      = 1'b1;
logic                                ap_start_pulse                ;
logic [LP_NUM_EXAMPLES-1:0]          ap_done_i                     ;
logic [LP_NUM_EXAMPLES-1:0]          ap_done_i_1                     ;
logic [LP_NUM_EXAMPLES-1:0]          ap_done_r                      = {LP_NUM_EXAMPLES{1'b0}};
logic [32-1:0]                       ctrl_xfer_size_in_bytes        = LP_DEFAULT_LENGTH_IN_BYTES;
//logic [32-1:0]                       ctrl_constant                  = 32'd1;

logic spi_enable_s;
logic use_qspi_s;
logic spi_addr_idx_s;

///////////////////////////////////////////////////////////////////////////////
// Begin RTL
///////////////////////////////////////////////////////////////////////////////

// Register and invert reset signal.
always @(posedge ap_clk) begin
  areset <= ~ap_rst_n;
  spi_enable_s <= spi_enable;
  use_qspi_s <= use_qspi;
  spi_addr_idx_s <= spi_addr_idx;
end

// create pulse when ap_start transitions to 1
always @(posedge ap_clk) begin
  begin
    ap_start_r <= ap_start;
  end
end

assign ap_start_pulse = ap_start & ~ap_start_r;

// ap_idle is asserted when done is asserted, it is de-asserted when ap_start_pulse
// is asserted
always @(posedge ap_clk) begin
  if (areset) begin
    ap_idle_r <= 1'b1;
  end
  else begin
    ap_idle_r <= ap_done ? 1'b1 :
      ap_start_pulse ? 1'b0 : ap_idle;
  end
end

assign ap_idle = ap_idle_r;

// Done logic
always @(posedge ap_clk) begin
  if (areset) begin
    ap_done_r <= '0;
  end
  else begin
    ap_done_r <= (ap_done) ? '0 : ap_done_r | ap_done_i;
  end
end

assign ap_done = &ap_done_r;


// Ready Logic (non-pipelined case)
assign ap_ready = ap_done;


// Register and invert kernel reset signal.
always @(posedge ap_clk_2) begin
  kernel_rst <= ~ap_rst_n_2;
end


// Vadd example
PULPino_System_L3 #(
  .C_M_AXI_ADDR_WIDTH ( C_SPI_AXI_ADDR_WIDTH ),
  .C_M_AXI_DATA_WIDTH ( C_SPI_AXI_DATA_WIDTH ),
  .C_ADDER_BIT_WIDTH  ( 32                   ),
  .C_XFER_SIZE_WIDTH  ( 32                   )
)
inst_L3 (
  .aclk                    ( ap_clk                  ),
  .areset                  ( areset                  ),
  .kernel_clk              ( ap_clk_2                ),
  .kernel_rst              ( kernel_rst              ),
  .ctrl_addr_offset        ( spi_data                ),
  .ctrl_xfer_size_in_bytes ( ctrl_xfer_size_in_bytes ),
//  .ctrl_constant           ( ctrl_constant           ),
  .ap_start                ( ap_start_pulse          ),
  .ap_done                 ( ap_done_i[0]            ),
  .m_axi_awvalid           ( spi_axi_awvalid         ),
  .m_axi_awready           ( spi_axi_awready         ),
  .m_axi_awaddr            ( spi_axi_awaddr          ),
  .m_axi_awlen             ( spi_axi_awlen           ),
  .m_axi_wvalid            ( spi_axi_wvalid          ),
  .m_axi_wready            ( spi_axi_wready          ),
  .m_axi_wdata             ( spi_axi_wdata           ),
  .m_axi_wstrb             ( spi_axi_wstrb           ),
  .m_axi_wlast             ( spi_axi_wlast           ),
  .m_axi_bvalid            ( spi_axi_bvalid          ),
  .m_axi_bready            ( spi_axi_bready          ),
  .m_axi_arvalid           ( spi_axi_arvalid         ),
  .m_axi_arready           ( spi_axi_arready         ),
  .m_axi_araddr            ( spi_axi_araddr          ),
  .m_axi_arlen             ( spi_axi_arlen           ),
  .m_axi_rvalid            ( spi_axi_rvalid          ),
  .m_axi_rready            ( spi_axi_rready          ),
  .m_axi_rdata             ( spi_axi_rdata           ),
  .m_axi_rlast             ( spi_axi_rlast           ),
  .spi_enable_i			   (spi_enable_s			 ), 
  .use_qspi_i  			   (use_qspi_s				 ),
  .spi_addr_idx_i		   (spi_addr_idx_s			 )
);


endmodule : PULPino_System_L2
`default_nettype wire
