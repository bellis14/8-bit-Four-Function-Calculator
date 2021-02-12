`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Ben Ellis 
// Module Name: sseg_x4_top
// Project Name: 8-bit_calculator
// Target Devices: Xilinx Artix-7 FPGA
// Description: This program takes in a 16-bit input value and displays each nibble
// on a seven segment display. 
//////////////////////////////////////////////////////////////////////////////////


module sseg_x4_top(
    input [15:0] sw,   // 16 input switches
    input clk,         // 100 MHz clock input
    input btnC,        // reset
    output [3:0] an,   // four seven segment digits
    output dp,         // decimal point
    //output [4:0] JA, // five of the PMOD JA pins
    output [6:0] seg   // seven segment signals to construct the digit
    );
    wire [1:0] clkdiv;  //output of the clock_gen module
    wire [3:0] digit;   //output of which seven segment dislay to use from digit_selector module
    wire [3:0] hex_num; //output of the group of DIP switches to use from digit_selector module
    clk_gen A0(clk, btnC, clkdiv);  //divide down the frequency into a two-bit clkdiv variable
    digit_selector A1(sw, clkdiv, btnC, digit, hex_num); //select 1 of 4 7seg dislays with DIP switches
    assign an = digit; 
    decoder_7seg A2(hex_num, dp, seg);  //Display the numbers on the 4 7seg displays
    
    
endmodule

/////////////////////////////////////////////////////////////
module digit_selector(
    input [15:0] sw,
    input [1:0] dig_cnt,     //two bit counter to be decoded
    input rst,               //resets it all
    output [3:0] digit_sel,  //returns the four bit display
    output [3:0] hex_num
    ); 
     reg [3:0] sele;
     reg [3:0] hex_holder;
     
     always @ (rst, dig_cnt) begin
        if (dig_cnt == 0) begin 
           sele <= 4'b1110;
           hex_holder <= sw[3:0];
        end 
        else if (dig_cnt == 1) begin 
           sele <= 4'b1101;
           hex_holder <= sw[7:4];
        end
        else if (dig_cnt == 2) begin 
           sele <= 4'b1011;
           hex_holder <= sw[11:8];
        end
        else if (dig_cnt == 3) begin
           sele <= 4'b0111;
           hex_holder <= sw[15:12];
        end 
        
     end
     
     assign digit_sel = sele;
     assign hex_num = hex_holder;
     
endmodule

//////////////////////////////////////////////////////
module clk_gen(
    input clk,
    input btnC,
    output [1:0] clock
    );
    reg [26:0] clkdiv;
    always @ (posedge btnC, posedge clk) begin
       if (btnC) clkdiv <= 27'b0;
       else if (clkdiv == 67108863) clkdiv <= 27'b0;
       else clkdiv <= clkdiv + 1;
    end
    
    assign clock = clkdiv[19:18];
    //assign clock = clkdiv[1:0];
    
endmodule

/////////////////////////////////////////////////
module decoder_7seg(
    input [3:0] sw,  // 4-bit switch input
    output reg dp,  
    //output reg [3:0] an, // The four different segment displays 
    output reg [6:0] seg  // 7-bit output display
    );
    
    // Give starting values for the outputs
    initial begin
       //an <= 4'b1110;
       dp <= 1'b1;
       seg <= 7'b1111111;
    end
    
    // Every time the switch input is changed re-evaluate the output value
    always @ (sw)
    begin  // Could have used a switch statement here but if statements work too
       if (sw == 4'b0000) seg <= 7'b1000000;  // Display 0
       else if (sw == 4'b0001) seg <= 7'b1111001;  // Display 1
       else if (sw == 4'b0010) seg <= 7'b0100100;  // Display 2
       else if (sw == 4'b0011) seg <= 7'b0110000;  // Display 3
       else if (sw == 4'b0100) seg <= 7'b0011001;  // Display 4
       else if (sw == 4'b0101) seg <= 7'b0010010;  // Display 5
       else if (sw == 4'b0110) seg <= 7'b0000010;  // Display 6
       else if (sw == 4'b0111) seg <= 7'b1111000;  // Display 7
       else if (sw == 4'b1000) seg <= 7'b0000000;  // Display 8
       else if (sw == 4'b1001) seg <= 7'b0011000;  // Display 9
       else if (sw == 4'b1010) seg <= 7'b0001000;   //Display A
       else if (sw == 4'b1011) seg <= 7'b0000011;   //display B
       else if (sw == 4'b1100) seg <= 7'b1000110;   //display C
       else if (sw == 4'b1101) seg <= 7'b0100001;   //display D
       else if (sw == 4'b1110) seg <= 7'b0000110;   //display E
       else if (sw == 4'b1111) seg <= 7'b0001110;   //display F
       else seg = 7'b1000000;  
end

endmodule