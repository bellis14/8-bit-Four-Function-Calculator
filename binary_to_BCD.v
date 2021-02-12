`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Ben Ellis 
// Module Name: binary_to_BCD
// Project Name: 8-bit_calculator
// Target Devices: Xilinx Artix-7 FPGA
// Description: This program converts a value in binary to binary encoded decimal
// so the correct value can be displayed to the user. Example: 6+6 = 12 or 1100 in
// binary but that needs to be converted to 0001 0010 so each seven segment display
// can display the correct numbers.
//////////////////////////////////////////////////////////////////////////////////

module binary_to_BCD(
    input [15:0] binaryCode,
    output [15:0] BCDcode
    );
    reg [3:0] thousands, hundreds, tens, ones;
    integer i;
    
    always @ (binaryCode) begin
       if (binaryCode <= 9999) begin
          thousands = 4'd0;
          hundreds = 4'd0;
          tens = 4'd0;
          ones = 4'd0;
          for (i = 15; i >= 0; i = i - 1) begin
             if (thousands >= 5) thousands = thousands + 3;
             if (hundreds >= 5) hundreds = hundreds + 3;
             if (tens >= 5) tens = tens + 3;
             if (ones >= 5) ones = ones + 3;
             thousands = thousands << 1;
             thousands[0] = hundreds[3];
             hundreds = hundreds << 1;
             hundreds[0] = tens[3];
             tens = tens << 1;
             tens[0] = ones[3];
             ones = ones << 1;
             ones[0] = binaryCode[i];
          end
       end
       else begin
          thousands = binaryCode[15:12];
          hundreds = binaryCode [11:8];
          tens = binaryCode[7:4];
          ones = binaryCode[3:0];
       end
    end
    
    assign BCDcode[15:12] = thousands;
    assign BCDcode[11:8] = hundreds;
    assign BCDcode[7:4] = tens;
    assign BCDcode[3:0] = ones;
        
endmodule