`timescale 1ns / 1ps

module fsm
(
    input clk_in,
    input stop_in,
    input four_secs_in,
    input two_secs_in,
    input match_in,
    input go_in,
    
    output load_target_out,
    output reset_timer_out,
    output load_numbers_out,
    output shr_out,
    output shl_out,
    output flash_both_out,
    output flash_alt_out
);
    wire inactive;
    wire round;
    wire checking_sum;
    wire flashing_win;
    wire flashing_loss;
    
    wire next_inactive;
    wire next_round;
    wire next_checking_sum;
    wire next_flashing_win;
    wire next_flashing_loss;
    
    FDRE #(.INIT(1'b1)) ff_inactive (.C(clk_in), .R(1'b0), .CE(1'b1), .D(next_inactive), .Q(inactive));
    FDRE #(.INIT(1'b0)) ff_round (.C(clk_in), .R(1'b0), .CE(1'b1), .D(next_round), .Q(round));
    FDRE #(.INIT(1'b0)) ff_checking (.C(clk_in), .R(1'b0), .CE(1'b1), .D(next_checking_sum), .Q(checking_sum));
    FDRE #(.INIT(1'b0)) ff_losing (.C(clk_in), .R(1'b0), .CE(1'b1), .D(next_flashing_loss), .Q(flashing_loss));
    FDRE #(.INIT(1'b0)) ff_winning (.C(clk_in), .R(1'b0), .CE(1'b1), .D(next_flashing_win), .Q(flashing_win));
    
    assign next_inactive = ~go_in & inactive | flashing_win & four_secs_in | flashing_loss & four_secs_in;
    assign next_round = go_in & inactive | round & two_secs_in & ~stop_in | round & ~two_secs_in & ~stop_in;  
    assign next_checking_sum = stop_in & round;
    assign next_flashing_win = checking_sum & match_in | flashing_win & ~four_secs_in;
    assign next_flashing_loss = checking_sum & ~match_in | flashing_loss & ~four_secs_in;
    
    assign load_target_out = inactive & go_in;
    assign reset_timer_out = inactive | next_checking_sum | ~go_in & two_secs_in & round;
    assign load_numbers_out = round & two_secs_in;
    assign shl_out = flashing_win & four_secs_in;
    assign shr_out = flashing_loss & four_secs_in;
    assign flash_both_out = flashing_loss;
    assign flash_alt_out = flashing_win;

endmodule