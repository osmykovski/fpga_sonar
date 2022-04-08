`timescale 1 ns / 1 ps

module axi_stream_fifo #
(
	parameter integer DATA_WIDTH	= 32,
	parameter integer ADDR_WIDTH	= 4
)
(
	input  logic                        S_AXI_ACLK,
	input  logic                        S_AXI_ARESETN,

	input  logic [ADDR_WIDTH-1 : 0]     S_AXI_AWADDR,
	input  logic                        S_AXI_AWVALID,                          
	output logic                        S_AXI_AWREADY,
	input  logic [DATA_WIDTH-1 : 0]     S_AXI_WDATA,      
	input  logic [(DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
	input  logic                        S_AXI_WVALID,
	output logic                        S_AXI_WREADY,       
	output logic [1 : 0]                S_AXI_BRESP,                
	output logic                        S_AXI_BVALID,                  
	input  logic                        S_AXI_BREADY,
	input  logic [ADDR_WIDTH-1 : 0]     S_AXI_ARADDR,          
	input  logic                        S_AXI_ARVALID,                
	output logic                        S_AXI_ARREADY,                 
	output logic [DATA_WIDTH-1 : 0]     S_AXI_RDATA,      
	output logic [1 : 0]                S_AXI_RRESP,             
	output logic                        S_AXI_RVALID,                   
	input  logic                        S_AXI_RREADY,

	input  logic                        S_AXIS_ACLK,
	input  logic                        S_AXIS_ARESETN,
	output logic                        S_AXIS_TREADY,
	input  logic [31 : 0]               S_AXIS_TDATA,
	input  logic                        S_AXIS_TVALID,

	input  logic                        M_AXIS_ACLK,
	output logic                        M_AXIS_TVALID,
	output logic [31 : 0]               M_AXIS_TDATA,
	input  logic                        M_AXIS_TREADY
);

	// AXI4LITE signals
	reg [ADDR_WIDTH-1 : 0] axi_awaddr;
	reg  	               axi_awready;
	reg  	               axi_wready;
	reg [1 : 0] 	       axi_bresp;
	reg  	               axi_bvalid;
	reg [ADDR_WIDTH-1 : 0] axi_araddr;
	reg  	               axi_arready;
	reg [DATA_WIDTH-1 : 0] axi_rdata;
	reg [1 : 0] 	       axi_rresp;
	reg  	               axi_rvalid;

	// Example-specific design signals
	// local parameter for addressing 32 bit / 64 bit DATA_WIDTH
	// ADDR_LSB is used for addressing 32/64 bit registers/memories
	// ADDR_LSB = 2 for 32 bits (n downto 2)
	// ADDR_LSB = 3 for 64 bits (n downto 3)
	localparam integer ADDR_LSB = (DATA_WIDTH/32) + 1;
	localparam integer OPT_MEM_ADDR_BITS = 1;
	//----------------------------------------------
	//-- Signals for user logic register space example
	//------------------------------------------------
	//-- Number of Slave Registers 4
	wire	             slv_reg_rden;
	wire	             slv_reg_wren;
	reg [DATA_WIDTH-1:0] reg_data_out;
	reg	                 aw_en;

	// I/O Connections assignments

	assign S_AXI_AWREADY = axi_awready;
	assign S_AXI_WREADY	 = axi_wready;
	assign S_AXI_BRESP	 = axi_bresp;
	assign S_AXI_BVALID	 = axi_bvalid;
	assign S_AXI_ARREADY = axi_arready;
	assign S_AXI_RDATA	 = axi_rdata;
	assign S_AXI_RRESP	 = axi_rresp;
	assign S_AXI_RVALID	 = axi_rvalid;
	// Implement axi_awready generation
	// axi_awready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
	// de-asserted when reset is low.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awready <= 1'b0;
	      aw_en <= 1'b1;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
	        begin
	          // slave is ready to accept write address when 
	          // there is a valid write address and write data
	          // on the write address and data bus. This design 
	          // expects no outstanding transactions. 
	          axi_awready <= 1'b1;
	          aw_en <= 1'b0;
	        end
	        else if (S_AXI_BREADY && axi_bvalid)
	            begin
	              aw_en <= 1'b1;
	              axi_awready <= 1'b0;
	            end
	      else           
	        begin
	          axi_awready <= 1'b0;
	        end
	    end 
	end       

	// Implement axi_awaddr latching
	// This process is used to latch the address when both 
	// S_AXI_AWVALID and S_AXI_WVALID are valid. 

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awaddr <= 0;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
	        begin
	          // Write Address latching 
	          axi_awaddr <= S_AXI_AWADDR;
	        end
	    end 
	end       

	// Implement axi_wready generation
	// axi_wready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
	// de-asserted when reset is low. 

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_wready <= 1'b0;
	    end 
	  else
	    begin    
	      if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID && aw_en )
	        begin
	          // slave is ready to accept write data when 
	          // there is a valid write address and write data
	          // on the write address and data bus. This design 
	          // expects no outstanding transactions. 
	          axi_wready <= 1'b1;
	        end
	      else
	        begin
	          axi_wready <= 1'b0;
	        end
	    end 
	end       

	// Implement memory mapped register select and write logic generation
	// The write data is accepted and written to memory mapped registers when
	// axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
	// select byte enables of slave registers while writing.
	// These registers are cleared when reset (active low) is applied.
	// Slave register write enable is asserted when valid address and data are available
	// and the slave is ready to accept the write address and write data.
	assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;

	// Implement write response logic generation
	// The write response and response valid signals are asserted by the slave 
	// when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
	// This marks the acceptance of address and indicates the status of 
	// write transaction.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_bvalid  <= 0;
	      axi_bresp   <= 2'b0;
	    end 
	  else
	    begin    
	      if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID)
	        begin
	          // indicates a valid write response is available
	          axi_bvalid <= 1'b1;
	          axi_bresp  <= 2'b0; // 'OKAY' response 
	        end                   // work error responses in future
	      else
	        begin
	          if (S_AXI_BREADY && axi_bvalid) 
	            //check if bready is asserted while bvalid is high) 
	            //(there is a possibility that bready is always asserted high)   
	            begin
	              axi_bvalid <= 1'b0; 
	            end  
	        end
	    end
	end   

	// Implement axi_arready generation
	// axi_arready is asserted for one S_AXI_ACLK clock cycle when
	// S_AXI_ARVALID is asserted. axi_awready is 
	// de-asserted when reset (active low) is asserted. 
	// The read address is also latched when S_AXI_ARVALID is 
	// asserted. axi_araddr is reset to zero on reset assertion.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_arready <= 1'b0;
	      axi_araddr  <= 32'b0;
	    end 
	  else
	    begin    
	      if (~axi_arready && S_AXI_ARVALID)
	        begin
	          // indicates that the slave has acceped the valid read address
	          axi_arready <= 1'b1;
	          // Read address latching
	          axi_araddr  <= S_AXI_ARADDR;
	        end
	      else
	        begin
	          axi_arready <= 1'b0;
	        end
	    end 
	end       

	// Implement axi_arvalid generation
	// axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
	// S_AXI_ARVALID and axi_arready are asserted. The slave registers 
	// data are available on the axi_rdata bus at this instance. The 
	// assertion of axi_rvalid marks the validity of read data on the 
	// bus and axi_rresp indicates the status of read transaction.axi_rvalid 
	// is deasserted on reset (active low). axi_rresp and axi_rdata are 
	// cleared to zero on reset (active low).  
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rvalid <= 0;
	      axi_rresp  <= 0;
	    end 
	  else
	    begin    
	      if (axi_arready && S_AXI_ARVALID && ~axi_rvalid)
	        begin
	          // Valid read data is available at the read data bus
	          axi_rvalid <= 1'b1;
	          axi_rresp  <= 2'b0; // 'OKAY' response
	        end   
	      else if (axi_rvalid && S_AXI_RREADY)
	        begin
	          // Read data is accepted by the master
	          axi_rvalid <= 1'b0;
	        end                
	    end
	end    

	// Implement memory mapped register select and read logic generation
	// Slave register read enable is asserted when valid address is available
	// and the slave is ready to accept the read address.
	assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;
	always @(*)
	begin
	      // Address decoding for reading registers
	      case ( axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
	        2'h0   : reg_data_out <= rx_data;
	        2'h1   : reg_data_out <= {'b0, rd_data_count};
	        2'h3   : reg_data_out <= {'b0, wr_data_count};
	        default : reg_data_out <= 0;
	      endcase
	end

	// Output register or memory read data
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rdata  <= 0;
	    end 
	  else
	    begin    
	      // When there is a valid read address (S_AXI_ARVALID) with 
	      // acceptance of read address by the slave (axi_arready), 
	      // output the read dada 
	      if (slv_reg_rden)
	        begin
	          axi_rdata <= reg_data_out;     // register read data
	        end   
	    end
	end

	logic rx_empty, rx_full;
	logic [31:0] rx_data;
	logic [9:0] rd_data_count;
	logic rx_wr_rst_busy;
	logic rx_rd_rst_busy;

	xpm_fifo_async #(
		.CDC_SYNC_STAGES    (2),        
		.DOUT_RESET_VALUE   ("0"),      
		.ECC_MODE           ("no_ecc"), 
		.FIFO_MEMORY_TYPE   ("auto"),   
		.FIFO_READ_LATENCY  (1),        
		.FIFO_WRITE_DEPTH   (1024), 
		.FULL_RESET_VALUE   (0),        
		.PROG_EMPTY_THRESH  (10),       
		.PROG_FULL_THRESH   (10),       
		.RD_DATA_COUNT_WIDTH(10),        
		.READ_DATA_WIDTH    (32),       
		.READ_MODE          ("fwft"),    
		.RELATED_CLOCKS     (0),        
		.SIM_ASSERT_CHK     (0),        
		.USE_ADV_FEATURES   ("0400"),   
		.WAKEUP_TIME        (0),        
		.WRITE_DATA_WIDTH   (32),       
		.WR_DATA_COUNT_WIDTH(1)         
	) xpm_fifo_rx (
		.wr_rst_busy    (rx_wr_rst_busy),
		.rd_rst_busy    (rx_rd_rst_busy),
		.dout           (rx_data),
		.rd_data_count  (rd_data_count),
		.empty          (rx_empty),
		.full           (rx_full),
		.din            (S_AXIS_TDATA),
		.rd_clk         (S_AXI_ACLK),
		.rd_en          (slv_reg_rden && axi_araddr == 0),
		.rst            (~S_AXIS_ARESETN),
		.wr_clk         (S_AXIS_ACLK),
		.wr_en          (S_AXIS_TVALID)
	);

	assign S_AXIS_TREADY = ~rx_full & ~rx_wr_rst_busy & ~rx_rd_rst_busy;
	logic tx_full, tx_empty;
	logic [9:0] wr_data_count;

	xpm_fifo_async #(
		.CDC_SYNC_STAGES    (2),        
		.DOUT_RESET_VALUE   ("0"),      
		.ECC_MODE           ("no_ecc"), 
		.FIFO_MEMORY_TYPE   ("auto"),   
		.FIFO_READ_LATENCY  (1),        
		.FIFO_WRITE_DEPTH   (1024), 
		.FULL_RESET_VALUE   (0),        
		.PROG_EMPTY_THRESH  (10),       
		.PROG_FULL_THRESH   (10),       
		.RD_DATA_COUNT_WIDTH(1),        
		.READ_DATA_WIDTH    (32),       
		.READ_MODE          ("fwft"),    
		.RELATED_CLOCKS     (0),        
		.SIM_ASSERT_CHK     (0),        
		.USE_ADV_FEATURES   ("1004"),   
		.WAKEUP_TIME        (0),        
		.WRITE_DATA_WIDTH   (32),       
		.WR_DATA_COUNT_WIDTH(10)         
	) xpm_fifo_tx (
		.data_valid   (M_AXIS_TVALID),
		.wr_data_count(wr_data_count),
		.dout         (M_AXIS_TDATA),
		.empty        (tx_empty),
		.full         (tx_full),
		.din          (S_AXI_WDATA),
		.rd_clk       (M_AXIS_ACLK),
		.rd_en        (M_AXIS_TREADY),
		.rst          (~S_AXI_ARESETN),
		.wr_clk       (S_AXI_ACLK),
		.wr_en        (slv_reg_wren && axi_awaddr == 8)
   );

endmodule
