`timescale 1ns / 1ps

module top
(
    input [15:0] sw,
    input clkin,
    input btnL,
    input btnD,
    input btnC,
    input btnR,
    
    output [15:0] led,
    output [6:0] seg,
    output [3:0] an,
    output dp
    );

    // Lab 5 Clks Instantiation
    wire clk, digsel, qsec;
    lab5_clks slowit(.clkin(clkin), .greset(btnD), .clk(clk), .digsel(digsel),.qsec(qsec));
    
    
    // Time Counter Instantiation
    wire [5:0] q_sec;
    wire resetting_for_timer;
    time_counter TC(.clk_in(clk), .inc_in(qsec), .reset_in(resetting_for_timer), .q_out(q_sec));
    
    wire two_seconds  = ~q_sec[4] & q_sec[3] & q_sec[2] & ~q_sec[1] & ~q_sec[0];        
    wire four_seconds = q_sec[4] & q_sec[3] & ~q_sec[2] & ~q_sec[1] & ~q_sec[0]; 
    
    // LFSR Instantiation
    wire [7:0] rand;
    lfsr LFSR (.clk_in(clk), .q_out(rand));
    
    wire [15:0] out;
    wire [7:0] out_o;
    FDRE #(.INIT(1'b0)) NUMBERS[7:0] (.C({8{clk}}), .R({8{1'b0}}), .CE({8{loading_num}}), .D(rand), .Q(out_o[7:0]));
    FDRE #(.INIT(1'b0)) TARGET[3:0]  (.C({4{clk}}), .R({4{1'b0}}), .CE({4{loading_targ}}), .D(rand[3:0]), .Q(out[15:12]));
    
    assign out[7:4] = (out_o[7:4] & ~{4{sw[14]}}) | ({4{sw[14]}} & 4'b0000); 
    assign out[3:0] = (out_o[3:0] & ~{4{sw[14]}}) | ({4{sw[14]}} & out[15:12]); 
    
    
    // Adder8 Instantiation
    wire [7:0] sum_8;
    wire ovfl, cout;
    adder8 A8(.a({4'b0, out[7:4]}), .b({4'b0, out[3:0]}), .cin(1'b0), .s(sum_8), .ovfl(ovfl),.cout(cout));
    assign out[11:8] = sum_8[3:0];
    
    wire matching;
    assign matching = ~|(out[15:12] ^ out[11:8]);

    wire num_on, stopping, stopping_r, game_ending, going_left, going_right, game_finished;
    FDRE #(.INIT(1'b0)) NUM_ON  (.C(clk), .R(loading_targ), .CE(loading_num), .D(1'b1), .Q(num_on));
    FDRE #(.INIT(1'b0)) STOPPING        (.C(clk), .R(loading_targ&~game_finished), .CE((btnL | btnR) & num_on), .D(1'b1), .Q(stopping));
    FDRE #(.INIT(1'b0)) STOPPING_R      (.C(clk), .R(loading_targ & ~game_finished), .CE(1'b1), .D(stopping), .Q(stopping_r));
    FDRE #(.INIT(1'b0)) GAME_ENDING (.C(clk), .R(loading_targ&~game_finished_temp&~two_seconds), .CE(two_seconds&stopping), .D(1'b1), .Q(game_ending));
    FDRE #(.INIT(1'b0)) GOING_LEFT        (.C(clk), .R(loading_targ&~game_finished), .CE(btnL&~game_ending&num_on), .D(1'b1), .Q(going_left));
    FDRE #(.INIT(1'b0)) RIGHT       (.C(clk), .R(loading_targ&~game_finished), .CE(btnR&~game_ending&num_on), .D(1'b1), .Q(going_right));
    
    // FSM Instantiation
    wire changing_score;
    fsm FSM 
    (
        .clk_in(clk),
        .going_in(btnC),
        .stopping_in(stopping_r),
        .four_secs_in(four_seconds),
        .two_secs_in(two_seconds),
        .match_in(matching),
        .gameOver_in(game_finished_temp),
        .load_target_out(loading_targ),
        .reset_timer_out(resetting_for_timer),
        .load_numbers_out(loading_num),
        .changing_scoreboard_out(changing_score),
        .flashing_both_out(flashing_both),
        .flashing_alt_out(flashing_alt)
    );

    // Ring Counter Instantiation
    wire [3:0] data_in;
    ring_counter RC(.advance_in(digsel), .clk_in(clk), .data_out(data_in));

    // Selector Instantiation
    wire [3:0] H;
    selector sel(.n(out), .Sel(data_in), .h(H));

    // Hex7Seg Instantiation
    wire [6:0] segment_out;
    wire round_above_four_secs;
    hex7seg H7S (.N(H), .Seg(segment_out));
    assign seg = segment_out |(~{7{1'b0}} & {7{game_finished}} & {7{round_above_four_secs}}); 

    // LED Shifter Instantiation
    led_shifter LS(.clk_in(clk), .left_in(going_left), .right_in(going_right), .match_in(matching), .changing_scoreboard_in(changing_score), .gameOver_out(game_finished_temp), .q_out(led));

    FDRE #(.INIT(1'b0)) GAME_FINISHED           (.C(clk), .R(btnC&~game_finished_temp), .CE(game_finished_temp), .D(1'b1), .Q(game_finished)); 
    FDRE #(.INIT(1'b0)) ROUND_ABOVE_FOUR_SECS   (.C(clk), .R(btnC&~game_finished_temp), .CE(four_seconds&game_finished), .D(1'b1), .Q(round_above_four_secs)); 
    
    wire flashing;
    FDRE #(.INIT(1'b0)) FLASHING (.C(clk), .R(1'b0), .CE(qsec), .D(~flashing), .Q(flashing));
    
    wire right_blank;
    FDRE #(.INIT(1'b0)) RIGHT_BLANK (.C(clk),.R(loading_num|game_finished), .CE(loading_targ), .D(1'b1), .Q(right_blank));
    
    
    assign an[3] = ~((~flashing_both & ~flashing_alt & data_in[3] ) 
                   | (flashing_both & ~flashing_alt & flashing & data_in[3] ) 
                   | (~flashing_both & flashing_alt & ~flashing & data_in[3] ) 
                   | (round_above_four_secs & ~flashing_both & ~flashing_alt & data_in[3])); 
    
    
    assign an[2] = ~((sw[15] & data_in[2]) 
                   | (round_above_four_secs & ~flashing_both & ~flashing_alt & data_in[2]));
    
    
    assign an[1] = right_blank 
                   | ~((~flashing_both & ~flashing_alt & data_in[1]) 
                   | (flashing_both & ~flashing_alt & flashing & data_in[1]) 
                   | (~flashing_both &  flashing_alt & flashing & data_in[1]) 
                   | (round_above_four_secs & ~flashing_both & ~flashing_alt & data_in[1]));
                   
                   
    assign an[0] = right_blank 
                   | ~((~flashing_both & ~flashing_alt & data_in[0]) 
                   | (flashing_both & ~flashing_alt & flashing & data_in[0]) 
                   | (~flashing_both &  flashing_alt & flashing & data_in[0]) 
                   | (round_above_four_secs & ~flashing_both & ~flashing_alt & data_in[0])); 


    assign dp = ~round_above_four_secs; //on after gameover

    endmodule