module i2s_if #(
    parameter clkdiv_val = 20,
    parameter fifo_depth = 256
) (
    input  logic        m_axis_aclk,
    input  logic        m_axis_arstn,

    output logic        WS,
    output logic        SCK,
    input  logic [1:0]  SD,

    output logic [63:0] m_axis_tdata,
    output logic        m_axis_tvalid,
    input  logic        m_axis_tready,
    output logic        m_axis_tuser
);

    logic [1:0] sd_cdc;
    xpm_cdc_array_single #(
        .DEST_SYNC_FF         (2),
        .INIT_SYNC_FF         (0),
        .SRC_INPUT_REG        (0),
        .WIDTH                (2)
    )
    SD_CDC_INST (
        .dest_out             (sd_cdc),
        .dest_clk             (m_axis_aclk),
        .src_in               (SD)
    );

    logic [31:0] clkdiv_cnt;
    always @(posedge m_axis_aclk) begin
        if(!m_axis_arstn)
            clkdiv_cnt <= 0;
        else begin
            if(clkdiv_cnt == clkdiv_val)
                clkdiv_cnt <= 0;
            else
                clkdiv_cnt <= clkdiv_cnt + 1;
        end
    end
    
    logic clk_en;
    assign clk_en = clkdiv_cnt == clkdiv_val;

    always @(posedge m_axis_aclk) begin
        if(!m_axis_arstn)
            SCK <= 0;
        else begin
            if(clkdiv_cnt == clkdiv_val)
                SCK <= 0;
            else if(clkdiv_cnt == clkdiv_val/2)
                SCK <= 1;
        end
    end

    logic [4:0] bit_cnt;
    always @(posedge m_axis_aclk) begin
        if(!m_axis_arstn)
            bit_cnt <= 0;
        else if(clk_en)
            bit_cnt <= bit_cnt + 1;
    end

    always @(posedge m_axis_aclk) begin
        if(!m_axis_arstn)
            WS <= 0;
        else if(clk_en && bit_cnt == 31)
            WS <= ~WS;
    end

    logic [31:0] din_reg_l;
    logic [31:0] din_reg_h;
    always @(posedge m_axis_aclk) begin
        if(!m_axis_arstn) begin
            din_reg_l <= 0;
            din_reg_h <= 0;
        end else if(clkdiv_cnt == clkdiv_val/2) begin
            din_reg_h = {din_reg_h[30:0], sd_cdc[1]};
        end else if(clkdiv_cnt == clkdiv_val/2 - 1)
            din_reg_l = {din_reg_l[30:0], sd_cdc[0]};
    end
    
    xpm_fifo_axis #(
        .CDC_SYNC_STAGES    (2             ),
        .CLOCKING_MODE      ("common_clock"),
        .ECC_MODE           ("no_ecc"      ),
        .FIFO_DEPTH         (fifo_depth    ),
        .FIFO_MEMORY_TYPE   ("auto"        ),
        .PACKET_FIFO        ("false"       ),
        .TDATA_WIDTH        (64            )
    )
    xpm_fifo_axis_inst (
        .m_aclk       (m_axis_aclk           ),
        .m_axis_tready(m_axis_tready         ),
        .m_axis_tdata (m_axis_tdata          ),
        .m_axis_tuser (m_axis_tuser          ),
        .m_axis_tvalid(m_axis_tvalid         ),

        .s_aclk       (m_axis_aclk           ),
        .s_aresetn    (m_axis_arstn          ),
        .s_axis_tdata ({din_reg_h, din_reg_l}),
        .s_axis_tuser (WS                    ),
        .s_axis_tvalid(bit_cnt == 31 && clk_en)
    );
    
endmodule