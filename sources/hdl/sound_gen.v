module sound_gen #(
    parameter clk_div = 10
) (
    input  wire        clk,
    input  wire        rstn,
    output reg         wave
);

    reg [31:0] clkdiv_cnt;
    always @(posedge clk) begin
        if(!rstn) begin
            clkdiv_cnt <= 0;
            wave <= 0;
        end else begin
            if(clkdiv_cnt < clk_div-1)
                clkdiv_cnt <= clkdiv_cnt + 1;
            else begin
                clkdiv_cnt <= 0;
                wave <= ~wave;
            end
        end
    end
    
endmodule