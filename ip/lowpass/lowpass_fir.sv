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

    logic signed [23:0] coe [0:filter_order-1] = {
        -1,      -1,      2,       16,      48,      110,     208,     339,
        488,     620,     690,     654,     484,     191,     -170,    -503,
        -698,    -665,    -377,    103,     626,     996,     1038,    673,
        -30,     -849,    -1473,   -1612,   -1118,   -80,     1174,    2164,
        2434,    1747,    222,     -1651,   -3154,   -3597,   -2618,   -387,
        2374,    4599,    5268,    3840,    558,     -3519,   -6816,   -7811,
        -5670,   -717,    5495,    10594,   12193,   8853,    848,     -9590,
        -18688,  -22182,  -16682,  -933,    23484,   52276,   79431,   98802,
        105820,  98802,   79431,   52276,   23484,   -933,    -16682,  -22182,
        -18688,  -9590,   848,     8853,    12193,   10594,   5495,    -717,
        -5670,   -7811,   -6816,   -3519,   558,     3840,    5268,    4599,
        2374,    -387,    -2618,   -3597,   -3154,   -1651,   222,     1747,
        2434,    2164,    1174,    -80,     -1118,   -1612,   -1473,   -849,
        -30,     673,     1038,    996,     626,     103,     -377,    -665,
        -698,    -503,    -170,    191,     484,     654,     690,     620,  
        488,     339,     208,     110,     48,      16,      2,       -1,
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
