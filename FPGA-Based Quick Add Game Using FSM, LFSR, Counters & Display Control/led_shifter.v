`timescale 1ns / 1ps

module led_shifter
(
    input clk_in,
    input in_in,
    input shl_in,
    input shr_in,
    
    output [15:0] q_out
);

    wire [15:0] q_o;
    wire [15:0] shifting_left;
    wire [15:0] shifting_right;
    wire [15:0] holding;
    wire [15:0] d_i;
    
    assign shifting_right = {in_in, q_o[15:1]};
    assign shifting_left = {q_o[14:0], in_in};     
    assign holding = q_o;                       
    
    assign d_i = ( {16{shl_in}} & shifting_left ) |
               ( {16{(~shl_in) & shr_in}} & shifting_right ) |
               ( {16{(~shl_in) & (~shr_in)}} & holding );
      
    FDRE ff[15:0] (.R(1'b0), .C(clk_in), .CE(1'b1),  .Q(q_o[15:0]), .D(d_i[15:0]));
    
    assign q_out = q_o;
    
endmodule
