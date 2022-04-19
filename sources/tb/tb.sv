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

    int sample_cnt;
    always @(posedge clk) begin
        if(!rstn)
            sample_cnt <= 0;
        else if(s_tvalid & s_tready)
            sample_cnt <= sample_cnt + 1;
    end

    logic signed [23:0] sine_lut [0:4] = {0, 7978040, 4930700, -4930700, -7978040};

    logic signed [23:0] s_tdata;
    logic s_tvalid, s_tready;
    logic [1:0] s_tuser = 0;
    logic s_tlast;

    int tvald_cnt;
    always @(posedge clk) begin
        if(!rstn)
            tvald_cnt <= 0;
        else begin
            if(tvald_cnt < 2500-1)
                tvald_cnt <= tvald_cnt + 1;
            else if(s_tready)
                tvald_cnt <= 0;
        end
    end

    assign s_tvalid = tvald_cnt == 2500-1;

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
    logic m_tvalid, m_tready;
    logic [2:0] m_tuser;
    logic m_tlast;

`ifdef DATA_TRACE
    int fid_out;
    initial begin
        fid_out = $fopen("C:/Users/Public/out.bin", "wb");
    end

    always @(posedge clk) begin
        if(m_tvalid & m_tready & m_tuser == 0) begin
            $fwrite(fid_out, "%c", m_tdata[7:0]);
            $fwrite(fid_out, "%c", m_tdata[15:8]);
            $fwrite(fid_out, "%c", m_tdata[23:16]);
            $fwrite(fid_out, "%c", 0);
        end
    end
`endif

    always @(posedge clk) begin
        if(sample_cnt == 9999) begin
            `ifdef DATA_TRACE
            $fclose(fid_out);
            `endif
            $finish();
        end
    end

    always @(posedge clk) begin
        m_tready <= $urandom();
    end
    
    int last_cnt;
    always @(posedge clk) begin
        if(!rstn)
            last_cnt <= 0;
        else if(s_tvalid & s_tready)
            last_cnt <= (last_cnt + 1) % 10;
    end

    assign s_tlast = last_cnt == 9;

    highpass_fir_0 hp_inst (
        .s_axis_aclk  (clk),
        .s_axis_arstn (rstn),

        .s_axis_tdata (s_tdata),
        .s_axis_tvalid(s_tvalid),
        .s_axis_tready(s_tready),
        .s_axis_tuser (s_tuser),
        .s_axis_tlast (s_tlast),

        .m_axis_tdata (hp_tdata),
        .m_axis_tvalid(hp_tvalid),
        .m_axis_tready(hp_tready),
        .m_axis_tuser (hp_tuser) ,
        .m_axis_tlast (hp_tlast)
    );

    logic signed [23:0] hp_tdata;
    logic               hp_tvalid;
    logic               hp_tready;
    logic        [1:0]  hp_tuser;
    logic               hp_tlast;

    demod_0 demod_inst (
        .s_axis_aclk   (clk),
        .s_axis_aresetn(rstn),

        .s_axis_tdata  (hp_tdata),
        .s_axis_tvalid (hp_tvalid),
        .s_axis_tready (hp_tready),
        .s_axis_tuser  (hp_tuser),
        .s_axis_tlast  (hp_tlast),

        .m_axis_tdata  (d_tdata),
        .m_axis_tvalid (d_tvalid),
        .m_axis_tready (d_tready),
        .m_axis_tuser  (d_tuser),
        .m_axis_tlast  (d_tlast)
    );

    logic signed [23:0] d_tdata;
    logic               d_tvalid;
    logic               d_tready;
    logic        [2:0]  d_tuser;
    logic               d_tlast;
    
    logic signed [23:0] d_tdata_0;
    logic signed [23:0] d_tdata_1;

    lowpass_fir_0 lp_inst (
        .s_axis_aclk  (clk),
        .s_axis_arstn (rstn),

        .s_axis_tdata (d_tdata),
        .s_axis_tvalid(d_tvalid),
        .s_axis_tready(d_tready),
        .s_axis_tuser (d_tuser),
        .s_axis_tlast (d_tlast),

        .m_axis_tdata (m_tdata ),
        .m_axis_tvalid(m_tvalid),
        .m_axis_tready(m_tready),
        .m_axis_tuser (m_tuser ),
        .m_axis_tlast (m_tlast )
    );

    assign d_tdata_0 = d_tvalid & d_tready & d_tuser == 0 ? d_tdata : d_tdata_0;
    assign d_tdata_1 = d_tvalid & d_tready & d_tuser == 4 ? d_tdata : d_tdata_1;
    
    logic signed [23:0] m_tdata_0;
    logic signed [23:0] m_tdata_1;

    assign m_tdata_0 = m_tvalid & m_tready & m_tuser == 0 ? m_tdata : m_tdata_0;
    assign m_tdata_1 = m_tvalid & m_tready & m_tuser == 4 ? m_tdata : m_tdata_1;
    
endmodule
