`timescale 1ns / 1ps

module fsm
(
    input clk_in,
    input going_in,
    input stopping_in,
    input two_secs_in,
    input four_secs_in,
    input match_in,
    input gameOver_in,
    
    output load_target_out,
    output load_numbers_out,
    output reset_timer_out,
    output changing_scoreboard_out,
    output flashing_alt_out,
    output flashing_both_out 
);

    wire inactive, round, flashing, game_finished;
    wire next_inactive, next_round, next_flashing, next_game_finished;
    
    assign inactive = (next_inactive & ~going_in) | (next_flashing & four_secs_in & ~gameOver_in);
    assign round = (next_round & ~two_secs_in) | (next_inactive & going_in) | (next_round & two_secs_in & ~stopping_in);
    assign flashing = (next_round & stopping_in & two_secs_in) | (next_flashing & ~four_secs_in);
    assign game_finished = (next_flashing & gameOver_in & four_secs_in);

    assign load_target_out = (next_inactive & going_in);
    assign load_numbers_out = (next_round & two_secs_in & ~stopping_in);
    assign reset_timer_out = (next_inactive & going_in) | (next_round & two_secs_in);
    assign changing_scoreboard_out = next_round & stopping_in & two_secs_in;
    assign flashing_alt_out = next_flashing & match_in & ~four_secs_in;
    assign flashing_both_out = next_flashing & ~match_in & ~four_secs_in;
    
    FDRE #(.INIT(1'b1)) NEXT_INACTIVE  (.CE(1'b1), .R(1'b0), .C(clk_in), .D(inactive), .Q(next_inactive));
    FDRE #(.INIT(1'b0)) NEXT_ROUND     (.CE(1'b1), .R(1'b0), .C(clk_in), .D(round), .Q(next_round));
    FDRE #(.INIT(1'b0)) NEXT_FLASHING  (.CE(1'b1), .R(1'b0), .C(clk_in), .D(flashing), .Q(next_flashing));
    FDRE #(.INIT(1'b0)) NEXT_GF        (.CE(1'b1), .R(1'b0), .C(clk_in), .D(game_finished), .Q(next_game_finished));

endmodule