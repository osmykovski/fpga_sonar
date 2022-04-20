module decimator (
    input  logic               s_axis_aclk,
    input  logic               s_axis_aresetn,

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

    logic [2:0] word_cnt [7:0];
    always @(posedge s_axis_aclk) begin
        if(!s_axis_aresetn)
            word_cnt <= {0, 0, 0, 0, 0, 0, 0, 0};
        else if(s_axis_tvalid & s_axis_tready)
            word_cnt[s_axis_tuser] <= (word_cnt[s_axis_tuser] + 1) % 5;
    end

    logic [23:0] tdata;
    logic [2:0] tuser;

    enum logic [1:0] {
        ST_READ  = 2'b01,
        ST_WRITE = 2'b10
    } dec_state;

    always @(posedge s_axis_aclk) begin
        if (!s_axis_aresetn)
            dec_state <= ST_READ;
        else begin
            case (dec_state)
                ST_READ: begin
                    if(s_axis_tvalid & word_cnt[s_axis_tuser] == 4)
                        dec_state <= ST_WRITE;
                end
                // ================================ //
                ST_WRITE: begin
                    if(m_axis_tready)
                        dec_state <= ST_READ;
                end
            endcase
        end
    end

    always @(posedge s_axis_aclk) begin
        if(s_axis_aresetn & s_axis_tvalid & s_axis_tready) begin
            tdata <= s_axis_tdata;
            tuser <= s_axis_tuser;
        end
    end
    
    logic [7:0] tlast;
    always @(posedge s_axis_aclk) begin
        if(!s_axis_aresetn)
            tlast <= 0;
        else begin
            if(s_axis_tvalid & s_axis_tready & s_axis_tlast)
                tlast[s_axis_tuser] = 1;
            if(m_axis_tvalid & m_axis_tready)
                tlast[m_axis_tuser] = 0;
        end
    end

    assign m_axis_tdata = tdata;
    assign m_axis_tvalid = dec_state == ST_WRITE;
    assign m_axis_tuser = tuser;
    assign m_axis_tlast = tlast[tuser];
    assign s_axis_tready = dec_state == ST_READ;

endmodule