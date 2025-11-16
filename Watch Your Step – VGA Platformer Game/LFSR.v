`timescale 1ns / 1ps

module LFSR
(
    input clk_in,
    input reset_in,
    
    output [7:0] q_out
);
    
    wire[7:0] d_in;
    wire feedback;
    
    assign feedback = q_out[0] ^ q_out[5] ^ q_out[6] ^ q_out[7];
    
    assign d_in[7] = feedback;
    assign d_in[6:0] = q_out[7:1];
    
    FDRE #(.INIT(1'b1)) ff7 (.C(clk_in), .CE(1'b1), .R(reset_in), .D(d_in[7]), .Q(q_out[7]));
    FDRE #(.INIT(1'b0)) ff[6:0] (.C(clk_in), .CE(1'b1), .R(reset_in), .D(d_in[6:0]), .Q(q_out[6:0]));
    
endmodule
