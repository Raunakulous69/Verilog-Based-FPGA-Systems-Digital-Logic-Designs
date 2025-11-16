`timescale 1ns / 1ps

module Pixel_Address 
(
  input wire [9:0] x_val,
  input wire [9:0] y_val,
  input wire [9:0] x_val_pixel,
  input wire [9:0] y_val_pixel,
  input wire [9:0] x_val_coin,
  input wire [9:0] y_val_coin,
  input wire [9:0] x_val_ball,
  input wire [9:0] y_val_ball,
  input wire [9:0] ending_hole,
  input wire [9:0] x_hole,
  input wire [6:0] y_hole,
  input wire [6:0] power_bar,
  input wire moving_left_hole,
  input wire ball,
  input wire flashing_ball,
  input wire flashing_player,
  input wire tagging,
  input wire clk_in,
  input wire reset_in,
  input wire active_region,
  
  output wire [3:0] Blue_VGA,
  output wire [3:0] Green_VGA,
  output wire [3:0] Red_VGA
);

  // Picking out random colors for the players
  wire [7:0] color_random;
  LFSR player_colors (.clk_in(clk_in), .reset_in(reset_in), .q_out(color_random));
  
  // Detecting tagging's rising positive edge
  wire detect_tagging;
  wire pulse_tagging = tagging & ~detect_tagging;
  FDRE #(.INIT(1'b0)) tag_reg (.R(reset_in), .C(clk_i),.CE(1'b1),.D(tagging),.Q(detect_tagging));
  
  // Holding the player's current color
  wire [3:0] blue_player, green_player, red_player;
  
  // Splitting and mixxing random bits and turning them into (3×4-bit) channels
  wire [3:0] new_Blue = color_random[7:4] ^ color_random[3:0];  
  wire [3:0] new_Green = color_random[3:0];
  wire [3:0] new_Red = color_random[7:4];

  // Generating a load when either the pluse_tagging or reset_in is on high
  wire loading_color  = pulse_tagging | reset_in;
  
  // when reset is on, choose original default option and if reset is off, go for the color bits
  wire [3:0] loading_blue = reset_in ? 4'b0000 : new_Blue;
  wire [3:0] loading_green = reset_in ? 4'b1111 : new_Green;
  wire [3:0] loading_red = reset_in ? 4'b0000 : new_Red;

  // Holding the current color of the player 
  FDRE #(.INIT(4'b0000)) ff_B [3:0] (.R(1'b0), .C(clk_in),.CE(loading_color),.D(loading_blue),.Q(blue_player));
  FDRE #(.INIT(4'b1111)) ff_G [3:0] (.R(1'b0), .C(clk_in),.CE(loading_color),.D(loading_green),.Q(green_player));
  FDRE #(.INIT(4'b0000)) ff_R [3:0] (.R(1'b0), .C(clk_in),.CE(loading_color),.D(loading_red),.Q(red_player));
  
  
  // Game's borders
  wire game_borders = (y_val < 8) || (y_val >= 472) || (x_val < 8) || (x_val >= 632);

  // Game's platform
  wire game_platform = (y_val < 380) && (y_val >= 360) && !game_borders;
 
  // Game's hole
  wire game_hole = game_platform                 
                   && ((x_val < x_hole + y_hole && x_val >= x_hole && !moving_left_hole) 
                   || (x_val < ending_hole && moving_left_hole));

  
  // Game hole's vertical range       
  wire inside_hole = (!moving_left_hole && x_val >= x_hole && x_val < x_hole + y_hole) 
                      || (x_val < ending_hole && moving_left_hole);           
  
  // Fall zone of the game (area below the platform)
  wire below_platform = (y_val >= 380) && !game_borders && !inside_hole;   
  
  // Game's playing character
  wire game_player = (x_val < x_val_pixel + 66) && (x_val >= x_val_pixel + 50) 
                     && (y_val < y_val_pixel + 32) && (y_val >= y_val_pixel + 16);  
  
  // Game's coins
  wire game_coins = (x_val < x_val_coin + 8) && (x_val >= x_val_coin)
                    && (y_val < y_val_coin + 8) && (y_val >= y_val_coin);  
  
  // Game's power bar
  wire game_power_bar = (x_val < 48) && (x_val >= 32)  
                        && (y_val < 96) && (y_val >= 96 - power_bar);
  
  // Game's ball
  wire game_ball = ball && (x_val < x_val_ball + 8) && (x_val >= x_val_ball) 
                   && (y_val < y_val_ball + 8) && (y_val >= y_val_ball);  
  
  // When the player gets hit by ball (tagged)
  wire player_tagged  = game_player && tagging;
  
    
  // Logic for Game's Blue Channel
  wire [3:0] BVGA = (!active_region) ? 4'b0000 
                    : game_borders ? 4'b0000 
                    : game_power_bar ? 4'b0000 
                    : (game_player && flashing_player) ? 4'b1111 
                    : (game_ball   && flashing_ball) ? 4'b1111 
                    : game_player ? 4'b0000 
                    : game_coins ? 4'b0000 
                    : (game_platform && !game_hole) ? 4'b1000 
                    : 4'b0000;
  

  // Logic for Game's Green Channel Logic
  wire [3:0] GVGA = (!active_region) ? 4'b0000 
                    : game_hole ? 4'b0000 
                    : game_borders ? 4'b0000 
                    : game_power_bar ? 4'b1111 
                    : (game_player && flashing_player) ? 4'b1111 
                    : game_ball ? 4'b1111 
                    : game_player ? 4'b1100 
                    : game_coins ? 4'b1100 
                    : (game_platform && !game_hole) ? 4'b1000 
                    : 4'b0000;

  
  // Logic for Game's Red Channel
  wire [3:0] RVGA = (!active_region) ? 4'b0000 
                    : game_borders ? 4'b1111 
                    : game_power_bar ? 4'b0000 
                    : (game_player && flashing_player) ? 4'b1111 
                    : (game_ball   && flashing_ball) ? 4'b1111 
                    : game_ball ? 4'b0000 
                    : game_player ? 4'b0000 
                    : game_coins ? 4'b1111 
                    : (game_platform && !game_hole) ? 4'b0000 
                    : 4'b0000;
   
  // Outputs for the color registers w/ asynchronous reset (using the flip-flops)
  FDRE #(.INIT(1'b0)) ff_BLUE  [3:0](.R(reset_in), .C(clk_in), .CE(1'b1), .D(BVGA),  .Q(Blue_VGA));
  FDRE #(.INIT(1'b0)) ff_GREEN [3:0](.R(reset_in), .C(clk_in), .CE(1'b1), .D(GVGA), .Q(Green_VGA));
  FDRE #(.INIT(1'b0)) ff_RED   [3:0](.R(reset_in), .C(clk_in), .CE(1'b1), .D(RVGA),  .Q(Red_VGA));

endmodule