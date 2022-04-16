`timescale 1ns/100ps

module tb ();

    logic clk = 1;
    logic rstn = 0;

    always begin
        #5 clk = ~clk;
    end

    initial begin
        #100 rstn <= 1;
    end

    logic enable = 0;
    logic [31:0] pattern = 32'hF05A;

    pulse_generator UUT (
        .clk        (clk),
        .rstn       (rstn),
        .enable     (enable),
        .pattern    (pattern),
        .mask       (16'b0001111111111111),
        .tx_period  (4999),
        .pulse_len  (9),
        .wave       ()
    );

    initial begin
        #50000;
        enable <= 1;
        #500000;
        enable <= 0;
    end
    
endmodule
