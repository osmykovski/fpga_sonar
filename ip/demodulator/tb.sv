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

    int fid_out;
    logic signed [31:0] test_data[0:9999];
    int fid;

    initial begin
        fid_out = $fopen("C:/Users/Public/out.bin", "wb");
        fid = $fopen("audio.bin", "rb");
        $fread(test_data, fid);
        $fclose(fid);
    end

    logic [13:0] sample_cnt;
    always @(posedge clk) begin
        if(!rstn)
            sample_cnt <= 0;
        else if(s_tvalid & s_tready)
            sample_cnt <= (sample_cnt + 1) % 10000;
    end

    always @(posedge clk) begin
        if(sample_cnt == 9999) begin
            $fclose(fid_out);
            $finish();
        end
    end

    logic [31:0] s_tdata;
    logic s_tvalid, s_tready;
    logic [1:0] s_tuser = 0;

    int tvalid_cnt;
    always @(posedge clk) begin
        if(!rstn)
            tvalid_cnt <= 0;
        else begin
            if(tvalid_cnt < 20)
                tvalid_cnt <= tvalid_cnt + 1;
            else
                tvalid_cnt <= 0;
        end
    end
    assign s_tvalid = tvalid_cnt == 20;

    // reversing bit order
    always @(posedge clk) begin
        for(int i=0;i<32;i++) begin
            s_tdata[31-i] = test_data[sample_cnt][i];
        end
    end

    logic signed [23:0] m_tdata;
    logic tvalid;

    always @(posedge clk) begin
        if(tvalid) begin
            $fwrite(fid_out, "%c", m_tdata[7:0]);
            $fwrite(fid_out, "%c", m_tdata[15:8]);
            $fwrite(fid_out, "%c", m_tdata[23:16]);
            $fwrite(fid_out, "%c", 0);
        end
    end

    logic tready = 1;

    demod UUT(
        .s_axis_aclk    (clk),
        .s_axis_aresetn (rstn),

        .s_axis_tdata   (s_tdata[31:8]),
        .s_axis_tvalid  (s_tvalid),
        .s_axis_tready  (s_tready),
        .s_axis_tuser   (s_tuser),

        .m_axis_tdata   (m_tdata),
        .m_axis_tvalid  (tvalid),
        .m_axis_tready  (tready),
        .m_axis_tuser   ()
    );
    
endmodule