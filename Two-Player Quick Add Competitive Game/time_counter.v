`timescale 1ns / 1ps

module time_counter
(
    input clk_in,
    input inc_in,
    input reset_in,
    
    output [5:0] q_out
);

    wire [15:0] entire_q;
    
    countUD16L counter 
    (
        .clk_in(clk_in),
        .up_in(inc_in),        
        .dw_in(),             
        .ld_in(reset_in),      
        .din_in(16'b0000000000000000),    
        .q_out(entire_q),              
        .utc_out(),                  
        .dtc_out()                   
    );
    
    assign q_out = entire_q[5:0];
    
endmodule
