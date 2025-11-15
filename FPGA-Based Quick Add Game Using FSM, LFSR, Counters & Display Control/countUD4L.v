`timescale 1ns / 1ps

module countUD4L 
(
    input [3:0] din_in,
    input clk_in,
    input reset_in, 
    input up_in,
    input dw_in,
    input ld_in,
    
    output [3:0] q_out,
    output utc_out,
    output dtc_out
);

    wire [3:0] d_i;
    wire [3:0] q_o;

    wire up_i;
    wire dw_i;
    wire hold_i; 

    assign up_i = up_in & ~dw_in & ~ld_in;
    assign dw_i = ~up_in & dw_in & ~ld_in;
    assign hold_i = ~(up_i | dw_i) & ~ld_in;
    
    assign d_i[0] = (ld_in & din_in[0]) |
                  (up_i & ~q_o[0]) |
                  (dw_i & ~q_o[0]) |
                  (hold_i & q_o[0]);
    
    assign d_i[1] = (ld_in & din_in[1]) | 
                  (up_i & (q_o[1] ^ q_o[0])) |    
                  (dw_i & (q_o[1] ^ ~q_o[0])) |   
                  (hold_i & q_o[1]);

    assign d_i[2] = (ld_in & din_in[2]) |
                  (up_i & (q_o[2] ^ (q_o[1] & q_o[0]))) |
                  (dw_i & (q_o[2] ^ (~q_o[1] & ~q_o[0]))) |
                  (hold_i & q_o[2]);

    assign d_i[3] = (ld_in & din_in[3]) |
                  (up_i & (q_o[3] ^ (q_o[2] & q_o[1] & q_o[0]))) |
                  (dw_i & (q_o[3] ^ (~q_o[2] & ~q_o[1] & ~q_o[0]))) |
                  (hold_i & q_o[3]);
      
    FDRE #(.INIT(1'b0)) ff[3:0] (.C(clk_in), .CE(1'b1), .R(reset_in), .D(d_i[3:0]), .Q(q_o[3:0])); 

    assign q_out = q_o;
    assign utc_out = &q_o;
    assign dtc_out = ~|q_o;

endmodule
