module highpass_fir (
    input  logic               s_axis_aclk,
    input  logic               s_axis_arstn,

    input  logic signed [31:0] s_axis_tdata,
    input  logic               s_axis_tvalid,
    output logic               s_axis_tready,
    input  logic        [1:0]  s_axis_tuser,

    output logic signed [31:0] m_axis_tdata,
    output logic               m_axis_tvalid,
    input  logic               m_axis_tready,
    output logic        [1:0]  m_axis_tuser
);

    localparam filter_order = 128;

    logic [1:0] tuser;
    always @(posedge s_axis_aclk) begin
        if(!s_axis_arstn)
            tuser <= 0;
        else if(s_axis_tvalid & s_axis_tready)
            tuser <= s_axis_tuser;
    end
    
    assign m_axis_tuser = tuser;

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
    logic signed  [23:0] sample;
    always @(posedge s_axis_aclk) begin
        if(s_axis_arstn) begin
            if(s_axis_tvalid & s_axis_tready)
                sample <= s_axis_tdata[23:0];
            else if(sample_cnt < filter_order)
                sample <= delay_reg[{tuser, sample_cnt[6:0]}];
        end
    end

    always @(posedge s_axis_aclk) begin
        if(s_axis_arstn & sample_cnt < filter_order)
            delay_reg[{tuser, sample_cnt[6:0]}] <= sample;
    end

    logic signed [23:0] coe [0:filter_order-1] = {
           -1,        6,      -12,        8,       32,     -150,      382,     -726,
         1106,    -1360,     1274,     -689,     -366,     1582,    -2401,     2226,
         -770,    -1643,     4003,    -4943,     3418,      542,    -5468,     8829,
        -8186,     2684,     5937,   -13591,    15569,    -9165,    -4159,    18501,
       -25820,    20127,    -1532,   -22305,    38845,   -36851,    13271,    23109,
       -54121,    60716,   -33831,   -18187,    70700,   -93546,    67271,     3421,
       -87282,   138771,  -121004,    28594,   102369,  -205300,   213279,   -96016,
      -114465,   324662,  -411098,   272035,   122296,  -704419,  1323484, -1795715,
      1972144, -1795715,  1323484,  -704419,   122296,   272035,  -411098,   324662,
      -114465,   -96016,   213279,  -205300,   102369,    28594,  -121004,   138771,
       -87282,     3421,    67271,   -93546,    70700,   -18187,   -33831,    60716,
       -54121,    23109,    13271,   -36851,    38845,   -22305,    -1532,    20127,
       -25820,    18501,    -4159,    -9165,    15569,   -13591,     5937,     2684,
        -8186,     8829,    -5468,      542,     3418,    -4943,     4003,    -1643,
         -770,     2226,    -2401,     1582,     -366,     -689,     1274,    -1360,
         1106,     -726,      382,     -150,       32,        8,      -12,        6
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

    logic signed [47:0] accum;
    always @(posedge s_axis_aclk) begin
        if(!s_axis_arstn)
            accum <= 0;
        else begin
            if(sample_cnt < filter_order)
                accum <= accum + (sample * coe_fir);
            else if(m_axis_tready & m_axis_tvalid)
                accum <= 0;
        end
    end

    assign s_axis_tready = (sample_cnt >= filter_order) & m_axis_tready;
    assign m_axis_tdata = accum >>> 16;

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