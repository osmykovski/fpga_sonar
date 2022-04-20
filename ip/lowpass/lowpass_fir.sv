module lowpass_fir (
    input  logic               s_axis_aclk,
    input  logic               s_axis_arstn,

    input  logic signed [23:0] s_axis_tdata,
    input  logic               s_axis_tvalid,
    output logic               s_axis_tready,
    input  logic        [2:0]  s_axis_tuser,
    input  logic               s_axis_tlast,

    output logic signed [23:0] m_axis_tdata,
    output logic               m_axis_tvalid,
    input  logic               m_axis_tready,
    output logic        [2:0]  m_axis_tuser,
    output logic               m_axis_tlast
);

    localparam filter_order = 128;

    logic [2:0] tuser;
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

    logic signed [23:0] delay_reg [(filter_order*8)-1:0];
    logic signed [23:0] sample;
    always @(posedge s_axis_aclk) begin
        if(s_axis_arstn & sample_cnt < filter_order)
            sample <= delay_reg[{tuser, sample_cnt[6:0]}];
    end

    always @(posedge s_axis_aclk) begin
        if(s_axis_arstn & sample_cnt < filter_order)
            delay_reg[{tuser, sample_cnt[6:0]}] <= sample_cnt == 0 ? tdata : sample;
    end

    // TODO: recalculate coefficients
    logic signed [23:0] coe [0:filter_order-1] = {
             4,      15,      34,      51,      32,     -94,    -441,   -1145,   -2332,
         -4047,   -6182,   -8418,  -10226,  -10948,   -9979,   -7003,   -2227,    3502,
          8772,   11922,   11562,    7152,    -578,   -9564,  -16833,  -19392,  -15343,
         -4846,    9487,   23055,   30603,   28103,   14558,   -6999,  -29878,  -45598,
        -46820,  -30414,     543,   36797,   65358,   73845,   55380,   12247,  -43335,
        -92128, -113990,  -95444,  -36050,   49013,  131766,  179523,  166196,   83281,
        -53403, -204190, -314134, -327915, -206996,   56181,  431739,  856305, 1246966,
       1521700, 1620588, 1521700, 1246966,  856305,  431739,   56181, -206996, -327915,
       -314134, -204190,  -53403,   83281,  166196,  179523,  131766,   49013,  -36050,
        -95444, -113990,  -92128,  -43335,   12247,   55380,   73845,   65358,   36797,
           543,  -30414,  -46820,  -45598,  -29878,   -6999,   14558,   28103,   30603,
         23055,    9487,   -4846,  -15343,  -19392,  -16833,   -9564,    -578,    7152,
         11562,   11922,    8772,    3502,   -2227,   -7003,   -9979,  -10948,  -10226,
         -8418,   -6182,   -4047,   -2332,   -1145,    -441,     -94,      32,      51,
            34,      15
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
