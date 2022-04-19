`timescale 1ns/100ps

// `define DATA_TRACE

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

    int fid_out;

`ifdef DATA_TRACE
    initial begin
        $display("DATA TRACING ON");
        fid_out = $fopen("C:/Users/Public/out.bin", "wb");
    end
`endif

    logic [13:0] sample_cnt;
    always @(posedge clk) begin
        if(!rstn)
            sample_cnt <= 0;
        else if(s_tvalid & s_tready)
            sample_cnt <= (sample_cnt + 1) % 10000;
    end

    always @(posedge clk) begin
        if(sample_cnt == 9999) begin
            `ifdef DATA_TRACE
            $fclose(fid_out);
            `endif
            $finish();
        end
    end

    logic [31:0] s_tdata;
    logic s_tvalid, s_tready;
    logic [1:0] s_tuser = 0;
    logic s_tlast;

    int tvalid_cnt;
    always @(posedge clk) begin
        if(!rstn)
            tvalid_cnt <= 0;
        else
            tvalid_cnt <= (tvalid_cnt + 1) % 20;
    end
    assign s_tvalid = tvalid_cnt == 19;


    logic signed [23:0] sine_lut [0:4] = {0, 7978040, 4930700, -4930700, -7978040};
    logic signed [23:0] rand_data;
    logic signed [23:0] sine_wave;
    always @(posedge clk) begin
        if(!rstn)
            s_tdata <= 0;
        else if(s_tvalid & s_tready) begin
            sine_wave = sine_lut[(sample_cnt*2) % 5];
            rand_data = $random();
            s_tdata <= sine_wave/2 + rand_data/8;
        end
    end

    logic signed [23:0] m_tdata;
    logic m_tlast;
    logic tvalid;

`ifdef DATA_TRACE
    always @(posedge clk) begin
        if(tvalid) begin
            $fwrite(fid_out, "%c", m_tdata[7:0]);
            $fwrite(fid_out, "%c", m_tdata[15:8]);
            $fwrite(fid_out, "%c", m_tdata[23:16]);
            $fwrite(fid_out, "%c", 0);
        end
    end
`endif

    logic tready = 1;

    int last_cnt;
    always @(posedge clk) begin
        if(!rstn)
            last_cnt <= 0;
        else if(s_tvalid & s_tready)
            last_cnt <= (last_cnt + 1) % 10;
    end

    assign s_tlast = last_cnt == 9;

    demod UUT(
        .s_axis_aclk    (clk),
        .s_axis_aresetn (rstn),

        .s_axis_tdata   (s_tdata[31:8]),
        .s_axis_tvalid  (s_tvalid),
        .s_axis_tready  (s_tready),
        .s_axis_tuser   (s_tuser),
        .s_axis_tlast   (s_tlast),

        .m_axis_tdata   (m_tdata),
        .m_axis_tvalid  (tvalid),
        .m_axis_tready  (tready),
        .m_axis_tuser   (),
        .m_axis_tlast   (m_tlast)
    );
    
endmodule