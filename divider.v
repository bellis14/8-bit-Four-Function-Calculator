`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Ben Ellis 
// Module Name: division
// Project Name: 8-bit_calculator
// Target Devices: Xilinx Artix-7 FPGA
// Description: This submodule is a description of a divider circuit that takes in
// two 8-bit inputs and produces a 16-bit quotient from doing division. 
//////////////////////////////////////////////////////////////////////////////////

module division (
   output [15:0] quotient,
   input [7:0] numerator,
   input [7:0] denominator
    );
    reg [7:0] minuend;
    reg [15:0] result;
    
    integer i;
    always @ (numerator, denominator) begin
       minuend = numerator;
       result = 0;
       for (i = 0; i <= 255; i = i + 1) begin
          if (minuend >= denominator) begin
             minuend = minuend - denominator;
             result = result + 1;
          end
       end
    end
    
    assign quotient = result;
    
endmodule