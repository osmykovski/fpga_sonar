
module sonar_top (
    inout  wire [14:0] DDR_0_addr,
    inout  wire [2:0]  DDR_0_ba,
    inout  wire        DDR_0_cas_n,
    inout  wire        DDR_0_ck_n,
    inout  wire        DDR_0_ck_p,
    inout  wire        DDR_0_cke,
    inout  wire        DDR_0_cs_n,
    inout  wire [3:0]  DDR_0_dm,
    inout  wire [31:0] DDR_0_dq,
    inout  wire [3:0]  DDR_0_dqs_n,
    inout  wire [3:0]  DDR_0_dqs_p,
    inout  wire        DDR_0_odt,
    inout  wire        DDR_0_ras_n,
    inout  wire        DDR_0_reset_n,
    inout  wire        DDR_0_we_n,
    output wire        SCK_H,
    output wire        SCK_L,
    input  wire        SD_H,
    input  wire        SD_L,
    output wire        WS_H,
    output wire        WS_L,
    output wire        wave
);

    wire SCK, WS;
    wire [1:0] SD;

    assign SCK_H = SCK;
    assign SCK_L = SCK;
    assign SD[1] = SD_H;
    assign SD[0] = SD_L;
    assign WS_H  = WS;
    assign WS_L  = WS;

    design_1_wrapper BD (
        .DDR_0_addr    (DDR_0_addr   ),
        .DDR_0_ba      (DDR_0_ba     ),
        .DDR_0_cas_n   (DDR_0_cas_n  ),
        .DDR_0_ck_n    (DDR_0_ck_n   ),
        .DDR_0_ck_p    (DDR_0_ck_p   ),
        .DDR_0_cke     (DDR_0_cke    ),
        .DDR_0_cs_n    (DDR_0_cs_n   ),
        .DDR_0_dm      (DDR_0_dm     ),
        .DDR_0_dq      (DDR_0_dq     ),
        .DDR_0_dqs_n   (DDR_0_dqs_n  ),
        .DDR_0_dqs_p   (DDR_0_dqs_p  ),
        .DDR_0_odt     (DDR_0_odt    ),
        .DDR_0_ras_n   (DDR_0_ras_n  ),
        .DDR_0_reset_n (DDR_0_reset_n),
        .DDR_0_we_n    (DDR_0_we_n   ),
        .SCK           (SCK          ),
        .SD            (SD           ),
        .WS            (WS           ),
        .wave          (wave         )
    );

endmodule
