`timescale 1ns / 1ps

module countUD16L 
(
    input [15:0] din_in,
    input clk_in,
    input up_in,
    input dw_in,
    input ld_in,
    
    output [15:0] q_out,
    output utc_out,
    output dtc_out
);
    
    wire [3:0] q_0, q_1, q_2, q_3;
    wire utc_0, utc_1, utc_2, utc_3;
    wire dtc_0, dtc_1, dtc_2, dtc_3;
    
    countUD4L count0 
    (
        .clk_in(clk_in),
        .up_in(up_in),
        .dw_in(dw_in),
        .ld_in(ld_in),
        .din_in(din_in[3:0]),
        .q_out(q_0),
        .utc_out(utc_0),
        .dtc_out(dtc_0)
    );
    
    countUD4L count1 
    (
    .clk_in(clk_in),
    .up_in(up_in & utc_0),
    .dw_in(dw_in & dtc_0),
    .ld_in(ld_in),
    .din_in(din_in[7:4]),
    .q_out(q_1),
    .utc_out(utc_1),
    .dtc_out(dtc_1)
    );

    countUD4L count2 
    (
        .clk_in(clk_in),
        .up_in(up_in & utc_0 & utc_1),
        .dw_in(dw_in & dtc_0 & dtc_1),
        .ld_in(ld_in),
        .din_in(din_in[11:8]),
        .q_out(q_2),
        .utc_out(utc_2),
        .dtc_out(dtc_2)
    );

    countUD4L count3 
    (
        .clk_in(clk_in),
        .up_in(up_in & utc_0 & utc_1 & utc_2),
        .dw_in(dw_in & dtc_0 & dtc_1 & dtc_2),
        .ld_in(ld_in),
        .din_in(din_in[15:12]),
        .q_out(q_3),
        .utc_out(utc_3),
        .dtc_out(dtc_3)
    );
    
    assign q_out = {q_3, q_2, q_1, q_0};
    assign utc_out = utc_0 & utc_1 & utc_2 & utc_3;
    assign dtc_out = dtc_0 & dtc_1 & dtc_2 & dtc_3;
    
endmodule
