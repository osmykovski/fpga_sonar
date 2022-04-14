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

    logic [23:0] tdata;
    logic        tvalid;
    logic        tready;
    logic [1:0]  tuser;

    initial begin
        tuser <= 0;
        #10000000;
        tuser <= 1;
        #10000000;
        tuser <= 2;
        #10000000;
        tuser <= 3;
        #10000000;
        $finish();
    end

    int data_cnt;
    always @(posedge clk) begin
        if(!rstn)
            data_cnt <= 0;
        else begin
            if(data_cnt < 255) begin
                data_cnt <= data_cnt + 1;
                tvalid <= 0;
            end else if(tready) begin
                data_cnt <= 0;
                tdata <= $random();
                tvalid <= 1;
            end
        end
    end
    
    logic [23:0] m_tdata;
    logic        m_tvalid;
    logic [1:0]  m_tuser;

    logic m_tready = 1;
    always @(posedge clk) begin
        m_tready <= $urandom();
    end

    lowpass_fir UUT (
        .s_axis_aclk    (clk),
        .s_axis_arstn   (rstn),
        .s_axis_tdata   (tdata),
        .s_axis_tvalid  (tvalid),
        .s_axis_tready  (tready),
        .s_axis_tuser   (tuser),
        .m_axis_tdata   (m_tdata),
        .m_axis_tvalid  (m_tvalid),
        .m_axis_tready  (m_tready),
        .m_axis_tuser   (m_tuser)
    );
    
endmodule