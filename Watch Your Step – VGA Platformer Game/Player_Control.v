`timescale 1ns / 1ps

module Player_Control 
(
  input  wire clk_in,       
  input  wire reset_in,     
  input  wire tick_frame,
  input  wire btnU,        
   
  output wire [9:0] player_out,        
  output wire [6:0] power_bar   
);

  // current states
  wire [9:0] po;
  wire [6:0] pb;

  // on platform when po == 328
  wire game_platform = (po == 10'd328);

  // Power logic's clock enabler
  wire pb_CE = tick_frame;
  
  // Y-pos's logic clock enabler
  wire po_CE = reset_in | tick_frame;
    
  // charge up only when btnU + game_platform
  wire charge_up = game_platform && btnU;
  
  // discharge whenever not charge_up + pb>0 
  wire discharge = (pb != 7'd0) && !charge_up;

  // When charging, increase power bar and if discharging. decrease power bar
  wire [6:0] increase_pb = pb + 7'd1;
  wire [6:0] decrease_pb = pb - 7'd1;
  wire [6:0] pb_next = charge_up ? (pb == 7'd64 ? 7'd64 : increase_pb) 
                       : discharge ? decrease_pb 
                       : pb;

  // vertical motion 
  wire going_upward   = discharge;
  wire going_downward = (pb == 7'd0) && (po < 10'd328);

  // Calculating the next position for Y-val
  wire [9:0] po_upward   = po - 10'd2;
  wire [9:0] po_downward = po + 10'd2;
  wire [9:0] po_next = charge_up ? 10'd328 
                       : going_upward ? po_upward 
                       : going_downward ? po_downward 
                       : po;

  // Flip-flop for the game's power register 
  FDRE #(.INIT(1'b0)) ff_PB [6:0] (.R(reset_in), .C(clk_in), .CE(pb_CE), .D(pb_next[6:0]), .Q(pb[6:0]));
  
  // Flip-flop for the position of Y's register   
  FDRE #(.INIT(1'b0)) ff0_PO (.R(1'b0), .C(clk_in), .CE(po_CE), .D(po_next[0]), .Q(po[0]));
  FDRE #(.INIT(1'b0)) ff1_PO (.R(1'b0), .C(clk_in), .CE(po_CE), .D(po_next[1]), .Q(po[1]));
  FDRE #(.INIT(1'b0)) ff2_PO (.R(1'b0), .C(clk_in), .CE(po_CE), .D(po_next[2]), .Q(po[2]));
  FDRE #(.INIT(1'b1)) ff3_PO (.R(1'b0), .C(clk_in), .CE(po_CE), .D(po_next[3]), .Q(po[3]));
  FDRE #(.INIT(1'b0)) ff4_PO (.R(1'b0), .C(clk_in), .CE(po_CE), .D(po_next[4]), .Q(po[4]));
  FDRE #(.INIT(1'b0)) ff5_PO (.R(1'b0), .C(clk_in), .CE(po_CE), .D(po_next[5]), .Q(po[5]));
  FDRE #(.INIT(1'b1)) ff6_PO (.R(1'b0), .C(clk_in), .CE(po_CE), .D(po_next[6]), .Q(po[6]));
  FDRE #(.INIT(1'b0)) ff7_PO (.R(1'b0), .C(clk_in), .CE(po_CE), .D(po_next[7]), .Q(po[7]));
  FDRE #(.INIT(1'b1)) ff8_PO (.R(1'b0), .C(clk_in), .CE(po_CE), .D(po_next[8]), .Q(po[8]));
  FDRE #(.INIT(1'b0)) ff9_PO (.R(1'b0), .C(clk_in), .CE(po_CE), .D(po_next[9]), .Q(po[9]));
  
  // Player Control Outputs
  assign power_bar = pb;
  assign player_out = po;

endmodule