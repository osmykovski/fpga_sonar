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

    logic enable = 0;
    logic [31:0] pattern = 32'hFF0055AA;

    pulse_generator UUT (
        .clk        (clk),
        .rstn       (rstn),
        .enable     (enable),
        .pattern    (pattern),
        .tx_period  (4999),
        .half_period(9),
        .pulse_len  (9)
    );

    initial begin
        #50000;
        enable <= 1;
        #500000;
        enable <= 0;
    end
    
endmodule
