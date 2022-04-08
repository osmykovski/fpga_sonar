`timescale 1ns/100ps

module tb ();

    logic clk = 1;
    logic rstn = 0;

    always begin
        #5 clk = ~clk;
    end

    initial begin
        #100;
        rstn <= 1;
    end

    logic [31:0] s_tdata = $urandom();
    logic        s_tvalid;
    logic        s_tready;

    logic [31:0] m_tdata;
    logic        m_tvalid;
    logic        m_tready = 1;

    always @(posedge clk) begin
        if(rstn) begin
            s_tvalid = $urandom();
            if(s_tvalid && s_tready) begin
                s_tdata <= $urandom();
            end
        end;
    end

	logic [3 : 0]  S_AXI_AWADDR = 0;
	logic          S_AXI_AWVALID = 0;
	logic          S_AXI_AWREADY;
	logic [31 : 0] S_AXI_WDATA = 0;  
	logic          S_AXI_WVALID = 0;
	logic          S_AXI_WREADY; 
	logic [1 : 0]  S_AXI_BRESP;  
	logic          S_AXI_BVALID; 
	logic          S_AXI_BREADY = 1;
	logic [3 : 0]  S_AXI_ARADDR; 
	logic          S_AXI_ARVALID = 0;
	logic          S_AXI_ARREADY;
	logic [31 : 0] S_AXI_RDATA;  
	logic [1 : 0]  S_AXI_RRESP;  
	logic          S_AXI_RVALID; 
	logic          S_AXI_RREADY = 0;

    axi_stream_fifo UUT (
        .S_AXI_ACLK     (clk           ),
        .S_AXI_ARESETN  (rstn          ),

        .S_AXI_AWADDR   (S_AXI_AWADDR  ),
        .S_AXI_AWVALID  (S_AXI_AWVALID ),        
        .S_AXI_AWREADY  (S_AXI_AWREADY ),

        .S_AXI_WDATA    (S_AXI_WDATA   ),
        .S_AXI_WSTRB    (4'b1111       ),
        .S_AXI_WVALID   (S_AXI_WVALID  ),
        .S_AXI_WREADY   (S_AXI_WREADY  ),

        .S_AXI_BRESP    (S_AXI_BRESP   ),
        .S_AXI_BVALID   (S_AXI_BVALID  ),
        .S_AXI_BREADY   (S_AXI_BREADY  ),

        .S_AXI_ARADDR   (S_AXI_ARADDR  ),
        .S_AXI_ARVALID  (S_AXI_ARVALID ),
        .S_AXI_ARREADY  (S_AXI_ARREADY ),

        .S_AXI_RDATA    (S_AXI_RDATA   ),
        .S_AXI_RRESP    (S_AXI_RRESP   ),
        .S_AXI_RVALID   (S_AXI_RVALID  ), 
        .S_AXI_RREADY   (S_AXI_RREADY  ),

        .S_AXIS_ACLK    (clk           ),
        .S_AXIS_ARESETN (rstn          ),
        .S_AXIS_TREADY  (s_tready      ),
        .S_AXIS_TDATA   (s_tdata       ),
        .S_AXIS_TVALID  (s_tvalid      ),

        .M_AXIS_ACLK    (clk           ),
        .M_AXIS_TVALID  (m_tvalid      ),
        .M_AXIS_TDATA   (m_tdata       ),
        .M_AXIS_TREADY  (m_tready      )
    );

    initial begin
        // READ TEST
        #1000;
        S_AXI_ARADDR <= 'h0;
        S_AXI_ARVALID <= 1;
        S_AXI_RREADY <= 1;
        while(!S_AXI_ARREADY) begin
            #1;
        end
        while(!S_AXI_RVALID) begin
            #1;
        end
        S_AXI_ARVALID <= 0;
        S_AXI_RREADY <= 0;

        #50;
        S_AXI_ARADDR <= 'h0;
        S_AXI_ARVALID <= 1;
        S_AXI_RREADY <= 1;
        while(!S_AXI_ARREADY) begin
            #1;
        end
        while(!S_AXI_RVALID) begin
            #1;
        end
        S_AXI_ARVALID <= 0;
        S_AXI_RREADY <= 0;
        
        // WRITE TEST
        #1000;
        S_AXI_AWADDR <= 'h8;
        S_AXI_WDATA <= $urandom();
        S_AXI_AWVALID <= 1;
        S_AXI_WVALID <= 1;
        while(!S_AXI_AWREADY) begin
            #1;
        end
        while(!S_AXI_WREADY) begin
            #1;
        end
        #10;
        S_AXI_AWVALID <= 0;
        S_AXI_WVALID <= 0;

    end
    
endmodule
