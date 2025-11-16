module Hole_Control 
(
  input  wire [7:0] rand_num,
  input  wire clk_in,
  input  wire reset_in,
  input  wire tick_frame,
  input  wire going_in,
  
  output wire [9:0] ending_hole,
  output wire [9:0] x_hole,
  output wire [6:0] y_hole,
  output wire moving_left_hole
);

  // Computing random_module = rand_num % 31
  wire greater_equal_31_1 = (rand_num >= 8'd31);
  wire [7:0] difference_1 = rand_num - 8'd31;
  wire [7:0] temp_1 = greater_equal_31_1 ? difference_1 : rand_num;

  wire greater_equal_31_1 = (temp_1 >= 8'd31);
  wire [7:0] difference_2 = temp_1 - 8'd31;
  wire [4:0] random_module = greater_equal_31_1 ? difference_2[4:0] : temp_1[4:0];

  // New Width for game's hole
  wire [6:0] new_width = 7'd41 + random_module;

  // Starting Latch
  wire starting; 
  wire starting_next;
  assign starting_next = starting | going_in;
  
  FDRE #(.INIT(1'b0)) ff_starting (.R(reset_in), .C(clk_in), .CE(1'b1), .D(starting_next), .Q(starting));

  // Registering the Position in Game w/ a signed 11-bit (tracking the hole's position)
  wire [10:0] position, next_position;
  wire [10:0] s_width = {4'b0, y_hole};
  assign moving_left_hole = position[10];
  
  // Computing the ending position
  
  wire [10:0] ending_position = s_width + position;
  assign ending_hole = ending_position[10] ? 10'd0 : ending_position[9:0];

  // Wrapping it once the right edge is leaving x=0
  wire edge_moving_left = (ending_position == 11'd0);

  assign next_position = going_in ? 11'd640
                         :!starting ? 11'd640
                         : edge_moving_left ? 11'd640
                         : tick_frame ? position - 11'd1
                         : position;

  // Position FF
  FDRE #(.INIT(1'b0)) ff_positon [10:0] (.R(reset_in), .C(clk_in), .CE(1'b1), .D(next_position[10:0]), .Q(position[10:0]));

  // On wrap, loading the width
  wire loading_width = edge_moving_left | going_in;
  wire [6:0] next_width = loading_width ? new_width : y_hole;
  FDRE #(.INIT(1'b0)) ff_width [6:0] (.R(reset_in), .C(clk_in), .CE(1'b1), .D(next_width[6:0]), .Q(y_hole[6:0]));

  // Clamping the neg position to 0 for the x_hole
  assign x_hole = position[10] ? 10'd0 : position[9:0];

endmodule