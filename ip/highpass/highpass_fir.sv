module highpass_fir (
    input  logic               s_axis_aclk,
    input  logic               s_axis_arstn,

    input  logic signed [23:0] s_axis_tdata,
    input  logic               s_axis_tvalid,
    output logic               s_axis_tready,
    input  logic        [1:0]  s_axis_tuser,
    input  logic               s_axis_tlast,

    output logic signed [23:0] m_axis_tdata,
    output logic               m_axis_tvalid,
    input  logic               m_axis_tready,
    output logic        [1:0]  m_axis_tuser,
    output logic               m_axis_tlast
);

    localparam filter_order = 128;

    logic [1:0] tuser;
    logic tlast;
    logic signed [23:0] tdata;
    always @(posedge s_axis_aclk) begin
        if(!s_axis_arstn) begin
            tuser <= 0;
            tlast <= 0;
        end else if(s_axis_tvalid & s_axis_tready) begin
            tuser <= s_axis_tuser;
            tlast <= s_axis_tlast;
            tdata <= s_axis_tdata;
        end
    end
    
    assign m_axis_tuser = tuser;
    assign m_axis_tlast = tlast;

    logic [7:0] sample_cnt;
    always @(posedge s_axis_aclk) begin
        if(!s_axis_arstn)
            sample_cnt <= 255;
        else begin
            if(s_axis_tvalid & s_axis_tready)
                sample_cnt <= 0;
            else if(sample_cnt < filter_order)
                sample_cnt <= sample_cnt + 1;
        end
    end

    logic signed [23:0] delay_reg [(filter_order*4)-1:0];
    logic signed [23:0] sample;
    always @(posedge s_axis_aclk) begin
        if(s_axis_arstn & sample_cnt < filter_order)
            sample <= delay_reg[{tuser, sample_cnt[6:0]}];
    end

    always @(posedge s_axis_aclk) begin
        if(s_axis_arstn & sample_cnt < filter_order)
            delay_reg[{tuser, sample_cnt[6:0]}] <= sample_cnt == 0 ? tdata : sample;
    end

    logic signed [23:0] coe [0:filter_order-1] = {
        -2,       5,        -5,       3,        5,        -15,      20,       -11,
        -13,      41,       -53,      30,       26,       -91,      118,      -71,
        -47,      180,      -237,     147,      78,       -328,     436,      -278,
        -120,     560,      -751,     490,      175,      -905,     1227,     -817,
        -241,     1403,     -1925,    1305,     317,      -2106,    2924,     -2020,
        -399,     3086,     -4349,    3062,     484,      -4470,    6410,     -4613,
        -564,     6510,     -9551,    7063,     635,      -9821,    14913,    -11492,
        -690,     16452,    -26714,   22441,    726,      -39458,   83070,    -117353,
        130334,   -117353,  83070,    -39458,   726,      22441,    -26714,   16452,
        -690,     -11492,   14913,    -9821,    635,      7063,     -9551,    6510,
        -564,     -4613,    6410,     -4470,    484,      3062,     -4349,    3086,
        -399,     -2020,    2924,     -2106,    317,      1305,     -1925,    1403,
        -241,     -817,     1227,     -905,     175,      490,      -751,     560,
        -120,     -278,     436,      -328,     78,       147,      -237,     180,
        -47,      -71,      118,      -91,      26,       30,       -53,      41,
        -13,      -11,      20,       -15,      5,        3,        -5,       5
    };

    logic [6:0] coe_cnt;
    always @(posedge s_axis_aclk) begin
        if(!s_axis_arstn)
            coe_cnt <= 0;
        else begin
            if(s_axis_tvalid & s_axis_tready)
                coe_cnt <= 1;
            else if(coe_cnt != 0)
                coe_cnt <= coe_cnt + 1;
        end
    end

    logic signed [23:0] coe_fir;
    always @(posedge s_axis_aclk) begin
        if(s_axis_arstn & sample_cnt < filter_order)
            coe_fir <= coe[coe_cnt];
    end

    logic signed [41:0] accum;
    always @(posedge s_axis_aclk) begin
        if(!s_axis_arstn)
            accum <= 0;
        else begin
            if(sample_cnt == 0)
                accum <= accum + (tdata * (coe_fir >>> 6));
            else if(sample_cnt < filter_order)
                accum <= accum + (sample * (coe_fir >>> 6));
            else if(m_axis_tready & m_axis_tvalid)
                accum <= 0;
        end
    end

    assign s_axis_tready = (sample_cnt >= filter_order) & m_axis_tready;
    assign m_axis_tdata = accum >>> 18;

    always @(posedge s_axis_aclk) begin
        if(!s_axis_arstn)
            m_axis_tvalid <= 0;
        else begin
            if(sample_cnt == filter_order-1)
                m_axis_tvalid <= 1;
            if(m_axis_tvalid & m_axis_tready)
                m_axis_tvalid <= 0;
        end
    end
    
endmodule
