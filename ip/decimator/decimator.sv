module decimator (
    input  logic               s_axis_aclk,
    input  logic               s_axis_aresetn,

    input  logic signed [23:0] s_axis_tdata,
    input  logic               s_axis_tvalid,
    output logic               s_axis_tready,
    input  logic        [1:0]  s_axis_tuser,

    output logic signed [23:0] m_axis_tdata,
    output logic               m_axis_tvalid,
    input  logic               m_axis_tready,
    output logic        [1:0]  m_axis_tuser
);

    assign s_axis_tready = word_cnt[s_axis_tuser] ? 1 : m_axis_tready;
    assign m_axis_tdata = s_axis_tdata;
    assign m_axis_tuser = s_axis_tuser;
    assign m_axis_tvalid = word_cnt[s_axis_tuser] ? 0 : s_axis_tvalid;

    logic [2:0] word_cnt [3:0];
    always @(posedge s_axis_aclk) begin
        if(!s_axis_aresetn) begin
            for(int i=0; i<4; i++)
                word_cnt[i] <= 0;
        end else if(s_axis_tvalid & s_axis_tready)
                word_cnt[s_axis_tuser] <= (word_cnt[s_axis_tuser] + 1) % 5;
    end

endmodule