module demod (
    input  logic               s_axis_aclk,
    input  logic               s_axis_aresetn,

    input  logic signed [23:0] s_axis_tdata,
    input  logic               s_axis_tvalid,
    output logic               s_axis_tready,
    input  logic        [1:0]  s_axis_tuser,

    output logic signed [23:0] m_axis_tdata,
    output logic               m_axis_tvalid,
    input  logic               m_axis_tready,
    output logic        [2:0]  m_axis_tuser
);

    logic signed [23:0] sine_lut_i [0:4] = {      0, 7978039,  4930699, -4930701, -7978041};
    logic signed [23:0] sine_lut_q [0:4] = {8388607, 2592221, -6786527, -6786527,  2592221};

    enum logic [4:0] {
        ST_READ   = 5'b00001,
        ST_CALC_I = 5'b00010,
        ST_TX_I   = 5'b00100,
        ST_CALC_Q = 5'b01000,
        ST_TX_Q   = 5'b10000
    } demod_state;

    logic signed [23:0] tdata;
    always @(posedge s_axis_aclk) begin
        if(!s_axis_aresetn)
            tdata <= 0;
        else if(s_axis_tvalid & s_axis_tready)
            tdata <= s_axis_tdata;
    end

    logic [1:0] tuser;
    always @(posedge s_axis_aclk) begin
        if(!s_axis_aresetn)
            tuser <= 0;
        else if(s_axis_tvalid & s_axis_tready)
            tuser <= s_axis_tuser;
    end

    logic signed [23:0] sine_val;
    always @(posedge s_axis_aclk) begin
        if(!s_axis_aresetn)
            sine_val <= 0;
        else if(demod_state == ST_READ)
            sine_val <= sine_lut_i[phase[s_axis_tuser]];
        else if(demod_state == ST_TX_I)
            sine_val <= sine_lut_q[phase[tuser]];
    end

    logic signed [47:0] mul_res;
    always @(posedge s_axis_aclk) begin
        if(!s_axis_aresetn)
            m_axis_tdata <= 0;
        else if(demod_state == ST_CALC_I | demod_state == ST_CALC_Q)
            mul_res = sine_val * tdata;
            m_axis_tdata <= mul_res >>> 24;
    end

    logic [2:0] phase [3:0];
    always @(posedge s_axis_aclk) begin
        if(!s_axis_aresetn)
            phase <= {0, 0, 0, 0};
        else if(demod_state == ST_TX_Q & m_axis_tvalid & m_axis_tready)
            phase[tuser] <= (phase[tuser] + 1) % 5;
    end

    always @(posedge s_axis_aclk) begin
        if (!s_axis_aresetn)
            demod_state <= ST_READ;
        else begin
            case (demod_state)
                ST_READ: begin
                    if(s_axis_tvalid)
                        demod_state <= ST_CALC_I;
                end
                // ================================ //
                ST_CALC_I: begin
                    demod_state <= ST_TX_I;
                end
                // ================================ //
                ST_TX_I: begin
                    if(m_axis_tvalid & m_axis_tready)
                        demod_state <= ST_CALC_Q;
                end
                // ================================ //
                ST_CALC_Q: begin
                    demod_state <= ST_TX_Q;
                end
                // ================================ //
                ST_TX_Q: begin
                    if(m_axis_tvalid & m_axis_tready)
                        demod_state <= ST_READ;
                end
            endcase
        end
    end

    assign s_axis_tready = demod_state == ST_READ;
    assign m_axis_tvalid = demod_state == ST_TX_I | demod_state == ST_TX_Q;
    assign m_axis_tuser = {demod_state == ST_TX_Q, tuser};
    
endmodule
