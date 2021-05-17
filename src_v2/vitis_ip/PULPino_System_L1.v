// This is a generated file. Use and modify at your own risk.
//////////////////////////////////////////////////////////////////////////////// 
// default_nettype of none prevents implicit wire declaration.
`default_nettype none
`timescale 1 ns / 1 ps
// Top level of the kernel. Do not modify module name, parameters or ports.
module PULPino_System_L1 #(
  parameter integer C_S_AXI_CONTROL_ADDR_WIDTH = 12,
  parameter integer C_S_AXI_CONTROL_DATA_WIDTH = 32,
  parameter integer C_SPI_AXI_ADDR_WIDTH       = 64,
  parameter integer C_SPI_AXI_DATA_WIDTH       = 32
)
(
  // System Signals
  input  wire                                    ap_clk               ,
  input  wire                                    ap_rst_n             ,
  input  wire                                    ap_clk_2             ,
  input  wire                                    ap_rst_n_2           ,
  //  Note: A minimum subset of AXI4 memory mapped signals are declared.  AXI
  // signals omitted from these interfaces are automatically inferred with the
  // optimal values for Xilinx accleration platforms.  This allows Xilinx AXI4 Interconnects
  // within the system to be optimized by removing logic for AXI4 protocol
  // features that are not necessary. When adapting AXI4 masters within the RTL
  // kernel that have signals not declared below, it is suitable to add the
  // signals to the declarations below to connect them to the AXI4 Master.
  // 
  // List of ommited signals - effect
  // -------------------------------
  // ID - Transaction ID are used for multithreading and out of order
  // transactions.  This increases complexity. This saves logic and increases Fmax
  // in the system when ommited.
  // SIZE - Default value is log2(data width in bytes). Needed for subsize bursts.
  // This saves logic and increases Fmax in the system when ommited.
  // BURST - Default value (0b01) is incremental.  Wrap and fixed bursts are not
  // recommended. This saves logic and increases Fmax in the system when ommited.
  // LOCK - Not supported in AXI4
  // CACHE - Default value (0b0011) allows modifiable transactions. No benefit to
  // changing this.
  // PROT - Has no effect in current acceleration platforms.
  // QOS - Has no effect in current acceleration platforms.
  // REGION - Has no effect in current acceleration platforms.
  // USER - Has no effect in current acceleration platforms.
  // RESP - Not useful in most acceleration platforms.
  // 
  // AXI4 master interface spi_axi
  output wire                                    spi_axi_awvalid      ,
  input  wire                                    spi_axi_awready      ,
  output wire [C_SPI_AXI_ADDR_WIDTH-1:0]         spi_axi_awaddr       ,
  output wire [8-1:0]                            spi_axi_awlen        ,
  output wire                                    spi_axi_wvalid       ,
  input  wire                                    spi_axi_wready       ,
  output wire [C_SPI_AXI_DATA_WIDTH-1:0]         spi_axi_wdata        ,
  output wire [C_SPI_AXI_DATA_WIDTH/8-1:0]       spi_axi_wstrb        ,
  output wire                                    spi_axi_wlast        ,
  input  wire                                    spi_axi_bvalid       ,
  output wire                                    spi_axi_bready       ,
  output wire                                    spi_axi_arvalid      ,
  input  wire                                    spi_axi_arready      ,
  output wire [C_SPI_AXI_ADDR_WIDTH-1:0]         spi_axi_araddr       ,
  output wire [8-1:0]                            spi_axi_arlen        ,
  input  wire                                    spi_axi_rvalid       ,
  output wire                                    spi_axi_rready       ,
  input  wire [C_SPI_AXI_DATA_WIDTH-1:0]         spi_axi_rdata        ,
  input  wire                                    spi_axi_rlast        ,
  // AXI4-Lite slave interface
  input  wire                                    s_axi_control_awvalid,
  output wire                                    s_axi_control_awready,
  input  wire [C_S_AXI_CONTROL_ADDR_WIDTH-1:0]   s_axi_control_awaddr ,
  input  wire                                    s_axi_control_wvalid ,
  output wire                                    s_axi_control_wready ,
  input  wire [C_S_AXI_CONTROL_DATA_WIDTH-1:0]   s_axi_control_wdata  ,
  input  wire [C_S_AXI_CONTROL_DATA_WIDTH/8-1:0] s_axi_control_wstrb  ,
  input  wire                                    s_axi_control_arvalid,
  output wire                                    s_axi_control_arready,
  input  wire [C_S_AXI_CONTROL_ADDR_WIDTH-1:0]   s_axi_control_araddr ,
  output wire                                    s_axi_control_rvalid ,
  input  wire                                    s_axi_control_rready ,
  output wire [C_S_AXI_CONTROL_DATA_WIDTH-1:0]   s_axi_control_rdata  ,
  output wire [2-1:0]                            s_axi_control_rresp  ,
  output wire                                    s_axi_control_bvalid ,
  input  wire                                    s_axi_control_bready ,
  output wire [2-1:0]                            s_axi_control_bresp  ,
  output wire                                    interrupt            
);

///////////////////////////////////////////////////////////////////////////////
// Local Parameters
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Wires and Variables
///////////////////////////////////////////////////////////////////////////////
(* DONT_TOUCH = "yes" *)
reg                                 areset                         = 1'b0;
wire                                ap_start                      ;
wire                                ap_idle                       ;
wire                                ap_done                       ;
wire                                ap_ready                      ;
wire [1-1:0]                        spi_enable                    ;
wire [1-1:0]                        use_qspi                      ;
wire [32-1:0]                       spi_addr_idx                  ;
wire [32-1:0]                       instr_num                     ;
wire [64-1:0]                       spi_data                      ;

// Register and invert reset signal.
always @(posedge ap_clk) begin
  areset <= ~ap_rst_n;
end

///////////////////////////////////////////////////////////////////////////////
// Begin control interface RTL.  Modifying not recommended.
///////////////////////////////////////////////////////////////////////////////


// AXI4-Lite slave interface
PULPino_System_control_s_axi #(
  .C_S_AXI_ADDR_WIDTH ( C_S_AXI_CONTROL_ADDR_WIDTH ),
  .C_S_AXI_DATA_WIDTH ( C_S_AXI_CONTROL_DATA_WIDTH )
)
inst_control_s_axi (
  .ACLK         ( ap_clk                ),
  .ARESET       ( areset                ),
  .ACLK_EN      ( 1'b1                  ),
  .AWVALID      ( s_axi_control_awvalid ),
  .AWREADY      ( s_axi_control_awready ),
  .AWADDR       ( s_axi_control_awaddr  ),
  .WVALID       ( s_axi_control_wvalid  ),
  .WREADY       ( s_axi_control_wready  ),
  .WDATA        ( s_axi_control_wdata   ),
  .WSTRB        ( s_axi_control_wstrb   ),
  .ARVALID      ( s_axi_control_arvalid ),
  .ARREADY      ( s_axi_control_arready ),
  .ARADDR       ( s_axi_control_araddr  ),
  .RVALID       ( s_axi_control_rvalid  ),
  .RREADY       ( s_axi_control_rready  ),
  .RDATA        ( s_axi_control_rdata   ),
  .RRESP        ( s_axi_control_rresp   ),
  .BVALID       ( s_axi_control_bvalid  ),
  .BREADY       ( s_axi_control_bready  ),
  .BRESP        ( s_axi_control_bresp   ),
  .interrupt    ( interrupt             ),
  .ap_start     ( ap_start              ),
  .ap_done      ( ap_done               ),
  .ap_ready     ( ap_ready              ),
  .ap_idle      ( ap_idle               ),
  .spi_enable   ( spi_enable            ),
  .use_qspi     ( use_qspi              ),
  .spi_addr_idx ( spi_addr_idx          ),
  .instr_num    ( instr_num             ),
  .spi_data     ( spi_data              )
);

///////////////////////////////////////////////////////////////////////////////
// Add kernel logic here.  Modify/remove example code as necessary.
///////////////////////////////////////////////////////////////////////////////

// Example RTL block.  Remove to insert custom logic.
PULPino_System_L2 #(
  .C_SPI_AXI_ADDR_WIDTH ( C_SPI_AXI_ADDR_WIDTH ),
  .C_SPI_AXI_DATA_WIDTH ( C_SPI_AXI_DATA_WIDTH )
)
inst_L2 (
  .ap_clk          ( ap_clk          ),
  .ap_rst_n        ( ap_rst_n        ),
  .ap_clk_2        ( ap_clk_2        ),
  .ap_rst_n_2      ( ap_rst_n_2      ),
  .spi_axi_awvalid ( spi_axi_awvalid ),
  .spi_axi_awready ( spi_axi_awready ),
  .spi_axi_awaddr  ( spi_axi_awaddr  ),
  .spi_axi_awlen   ( spi_axi_awlen   ),
  .spi_axi_wvalid  ( spi_axi_wvalid  ),
  .spi_axi_wready  ( spi_axi_wready  ),
  .spi_axi_wdata   ( spi_axi_wdata   ),
  .spi_axi_wstrb   ( spi_axi_wstrb   ),
  .spi_axi_wlast   ( spi_axi_wlast   ),
  .spi_axi_bvalid  ( spi_axi_bvalid  ),
  .spi_axi_bready  ( spi_axi_bready  ),
  .spi_axi_arvalid ( spi_axi_arvalid ),
  .spi_axi_arready ( spi_axi_arready ),
  .spi_axi_araddr  ( spi_axi_araddr  ),
  .spi_axi_arlen   ( spi_axi_arlen   ),
  .spi_axi_rvalid  ( spi_axi_rvalid  ),
  .spi_axi_rready  ( spi_axi_rready  ),
  .spi_axi_rdata   ( spi_axi_rdata   ),
  .spi_axi_rlast   ( spi_axi_rlast   ),
  .ap_start        ( ap_start        ),
  .ap_done         ( ap_done         ),
  .ap_idle         ( ap_idle         ),
  .ap_ready        ( ap_ready        ),
  .spi_enable      ( spi_enable      ),
  .use_qspi        ( use_qspi        ),
  .spi_addr_idx    ( spi_addr_idx    ),
  .instr_num       ( instr_num       ),
  .spi_data        ( spi_data        )
);

endmodule
`default_nettype wire
