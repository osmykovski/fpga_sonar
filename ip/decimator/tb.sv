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

    logic [13:0] sample_cnt;
    always @(posedge clk) begin
        if(!rstn)
            sample_cnt <= 0;
        else if(s_tvalid & s_tready)
            sample_cnt <= sample_cnt + 1;
    end

    always @(posedge clk) begin
        if(sample_cnt == 9999) begin
            $finish();
        end
    end

    logic [23:0] s_tdata;
    logic s_tvalid, s_tready;
    logic [2:0] s_tuser;
    logic       s_tlast;

    always @(posedge clk) begin
        s_tvalid <= $random();
    end

    always @(posedge clk) begin
        if(!rstn)
            s_tuser <= 0;
        else if(s_tvalid & s_tready)
            s_tuser <= s_tuser + 1;
    end

    always @(posedge clk) begin
        if(!rstn)
            s_tdata <= 0;
        else if(s_tvalid & s_tready)
            s_tdata <= $random();
    end

    logic signed [23:0] m_tdata;
    logic [2:0] m_tuser;
    logic tvalid;
    logic m_tlast;

    logic tready = 1;

    int tlast_cnt;
    always @(posedge clk) begin
        if(!rstn)
            tlast_cnt <= 0;
        else if(s_tvalid & s_tready & s_tuser == 7)
            tlast_cnt <= (tlast_cnt + 1) % 33;
    end

    assign s_tlast = tlast_cnt == 32;

    decimator UUT(
        .s_axis_aclk    (clk),
        .s_axis_aresetn (rstn),

        .s_axis_tdata   (s_tdata),
        .s_axis_tvalid  (s_tvalid),
        .s_axis_tready  (s_tready),
        .s_axis_tuser   (s_tuser),
        .s_axis_tlast   (s_tlast),

        .m_axis_tdata   (m_tdata),
        .m_axis_tvalid  (tvalid),
        .m_axis_tready  (tready),
        .m_axis_tuser   (m_tuser),
        .m_axis_tlast   (m_tlast)
    );
    
endmodule