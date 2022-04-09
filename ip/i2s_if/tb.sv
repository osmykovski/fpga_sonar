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

    logic [31:0] tdata;
    logic        tvalid;
    logic        tready = 1;

    typedef enum logic [1:0] {
        LEFT_LOW   = 2'b00,
        LEFT_HIGH  = 2'b01,
        RIGHT_LOW  = 2'b10,
        RIGHT_HIGH = 2'b11
    } mic_enum;
    mic_enum tuser;

    logic WS;
    logic SCK;
    logic [1:0] SD;

    logic [4:0] bit_cnt;
    always @(negedge SCK) begin
        if(!rstn)
            bit_cnt <= 31;
        else
            bit_cnt <= bit_cnt - 1;
    end

    logic [23:0] rnd_data;
    logic [31:0] true_data;
    always @(WS) begin
        rnd_data <= $random();
    end
    assign true_data = {1'b0, rnd_data, 7'b0};

    assign SD = {true_data[bit_cnt], ~true_data[bit_cnt]};

    i2s_if UUT (
        .m_axis_aclk   (clk   ),
        .m_axis_aresetn(rstn  ),
        .WS            (WS    ),
        .SCK           (SCK   ),
        .SD            (SD    ),
        .m_axis_tdata  (tdata ),
        .m_axis_tvalid (tvalid),
        .m_axis_tready (tready),
        .m_axis_tuser  ({tuser})
    );
    
endmodule