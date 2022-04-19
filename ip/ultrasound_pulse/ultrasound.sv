module pulse_generator #(
    parameter half_period = 9      // sound half-period time
)(
    input  logic        clk,
    input  logic        rstn,
    input  logic        enable,
    input  logic [15:0] pattern,   // signal pattern
    input  logic [15:0] mask,      // soun wave mask
    input  logic [15:0] pulse_len, // signal pulse lenght in sound wave periods
    input  logic [31:0] tx_period, // signal transmission period in clock cycles
    output logic        wave,
    output logic        frame_sync
);

    // TX interval counter
    logic [31:0] tx_period_cnt;
    always @(posedge clk) begin
        if(!rstn)
            tx_period_cnt <= 32'hFFFFFFFF;
        else if(enable) begin
            if(tx_period_cnt < tx_period)
                tx_period_cnt <= tx_period_cnt + 1;
            else
                tx_period_cnt <= 0;
        end else
            tx_period_cnt <= 32'hFFFFFFFF;
    end

    // TX enable signal
    logic en_pulse;
    assign en_pulse = tx_period_cnt == 0;
    assign frame_sync = en_pulse;

    logic pulse_en;
    always @(posedge clk) begin
        if(!rstn)
            pulse_en <= 0;
        else if(en_pulse)
            pulse_en <= 1;
        else if(bit_number == 16)
            pulse_en <= 0;
    end

    // Sound wave generation
    logic pulse;
    logic [31:0] clkdiv_cnt;
    always @(posedge clk) begin
        if(!rstn) begin
            clkdiv_cnt <= 0;
            pulse <= 0;
        end else if(pulse_en) begin
            if(clkdiv_cnt < half_period-1)
                clkdiv_cnt <= clkdiv_cnt + 1;
            else begin
                clkdiv_cnt <= 0;
                pulse <= ~pulse;
            end
        end else
            pulse <= 0;
    end

    // Modulation
    logic [15:0] pulse_cnt;
    logic [5:0] bit_number;
    always @(posedge clk) begin
        if(!rstn | !pulse_en) begin
            pulse_cnt <= 0;
            bit_number <= 0;
        end else if(clkdiv_cnt == half_period-1) begin
            if(pulse_cnt < pulse_len-1)
                pulse_cnt <= pulse_cnt + 1;
            else begin
                pulse_cnt <= 0;
                bit_number <= bit_number + 1;
            end
        end
    end

    assign wave = (pattern[bit_number[4:0]] ^ pulse) & pulse_en & mask[bit_number[4:0]];
    
endmodule
