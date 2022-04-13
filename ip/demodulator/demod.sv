module demod (
    input  logic               s_axis_aclk,
    input  logic               s_axis_aresetn,

    input  logic signed [31:0] s_axis_tdata,
    input  logic               s_axis_tvalid,
    output logic               s_axis_tready,
    input  logic        [1:0]  s_axis_tuser,

    output logic signed [31:0] m_axis_tdata,
    output logic               m_axis_tvalid,
    input  logic               m_axis_tready,
    output logic        [1:0]  m_axis_tuser
);

    logic signed [23:0] sine_lut [0:4] = {0, 7978040, 4930700, -4930700, -7978040};

    logic [4:0] phase [3:0];
    always @(posedge s_axis_aclk) begin
        if(!s_axis_aresetn) begin
            for(int i=0; i<4; i++) phase[i] <= 0;
        end else if(s_axis_tvalid & s_axis_tready)
            phase[s_axis_tuser] <= (phase[s_axis_tuser] + 2) % 5;
    end

    logic [23:0] tdata_z;
    logic [1:0] tuser_z;
    always @(posedge s_axis_aclk) begin
        if(!s_axis_aresetn) begin
            tuser_z <= 0;
            m_axis_tuser <= 0;
        end else if(s_axis_tvalid & s_axis_tready) begin
            tuser_z <= s_axis_tuser;
            m_axis_tuser <= tuser_z;
        end
    end

    logic signed [23:0] sine_val;
    always @(posedge s_axis_aclk) begin
        if(!s_axis_aresetn)
            sine_val <= 0;
        else if(s_axis_tvalid & s_axis_tready)
            sine_val <= sine_lut[phase[s_axis_tuser]];
    end

    logic signed [47:0] mul_result;
    always @(posedge s_axis_aclk) begin
        if(!s_axis_aresetn) begin
            m_axis_tdata <= 0;
            tdata_z <= 0;
        end else if(s_axis_tvalid & s_axis_tready) begin
            mul_result = sine_val * tdata_z;
            m_axis_tdata <= mul_result >>> 16;
            tdata_z <= s_axis_tdata[23:0];
        end
    end

    logic tvalid_z;
    always @(posedge s_axis_aclk) begin
        if(!s_axis_aresetn) begin
            tvalid_z <= 0;
            m_axis_tvalid <= 0;
        end else if(s_axis_tvalid & s_axis_tready) begin
            tvalid_z <= s_axis_tvalid;
            m_axis_tvalid <= tvalid_z;
        end
    end

    assign s_axis_tready = m_axis_tready;
    
endmodule
