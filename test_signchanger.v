`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:  Martine
// 
// Create Date: 10/2/2023 07:29:02 PM
// Design Name: 
// Module Name: test_signchanger
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module test_signchanger( ); // no inputs/outputs, this is a wrapper

// registers to hold values for the inputs to your top level
    reg [7:0] sw;
    reg btnU, btnR, clkin;
// wires to see the values of the outputs of your top level
    wire [6:0] seg;
    wire [3:0] an;
    wire dp;
    wire [15:0] led;
    
    wire signchanger_ovfl;
    // wire [7:0] signchanger_d;
        
// create one instance of your top level
// and attach it to the registers and wires created above
    top_lab2 UUT (
     .sw(sw),
     .btnU(btnU),
     .btnR(btnR), 
     .clkin(clkin),
     .seg(seg),
     .an(an),
     .led(led),
     .dp(dp)
    );
    
    assign signchanger_ovfl = UUT.ovfl;
    // assign signchanger_d = UUT.d;
    
// create an oscillating signal to impersonate the clock provided on the BASYS 3 board
    parameter PERIOD = 10;
    parameter real DUTY_CYCLE = 0.5;
    parameter OFFSET = 2;

    initial    // Clock process for clkin
    begin
        #OFFSET
		  clkin = 1'b1;
        forever
        begin
            #(PERIOD-(PERIOD*DUTY_CYCLE)) clkin = ~clkin;
        end
    end
	
// here is where the values for the registers are provided
// time must be advanced so that the change will have an effect
   initial 
   begin	 
	 //always advance time by multiples of 500ns
	 btnR=1'b0;
	 btnU=1'b0;
	 
	 // Test Vectors
	 sw = 8'h0000;
	 #500; 	 // to advance time by 500ns use the following line
	 btnU=1'b1; // setting signal foo to value 1
     #500;
     btnU=1'b0; // setting signal foo to value 0
     #500;
	 
	 sw = 8'h0001;
	 #500;
	 btnU=1'b1;
     #500;
     btnU=1'b0;
     #500;
     
     sw = 8'h0002;
	 #500;
	 btnU=1'b1;
     #500;
     btnU=1'b0;
     #500;
     
     sw = 8'h0003;
	 #500;
	 btnU=1'b1;
     #500;
     btnU=1'b0;
     #500;
     
     sw = 8'h001B;
	 #500;
	 btnU=1'b1;
     #500;
     btnU=1'b0;
     #500;
     
     sw = 8'h0016;
	 #500;
	 btnU=1'b1;
     #500;
     btnU=1'b0;
     #500;
     
     sw = 8'h00E1;
	 #500;
	 btnU=1'b1;
     #500;
     btnU=1'b0;
     #500;
     
     sw = 8'h00E7;
	 #500;
	 btnU=1'b1;
     #500;
     btnU=1'b0;
     #500;
   
     
     // Overflow Test
     sw =8'h0080;
     btnU=1'b1;
     #500;
     btnU=1'b0;
     #500;
     
    
     #1000;
     $finish;
               
   end

endmodule
