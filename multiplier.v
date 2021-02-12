`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Ben Ellis 
// Module Name: multiplication
// Project Name: 8-bit_calculator
// Target Devices: Xilinx Artix-7 FPGA
// Description: This program multiplies two 8-bit values to produce a 16-bit product.
// Principles of pipelining/parallel processing were implemented for speed enhancements.
//////////////////////////////////////////////////////////////////////////////////

// Multiplies two 8-bit values together and displays a 16-bit product
module multiplication(
    input [7:0] value,  // 8-bit multiplicand
    input [7:0] multiplier, // 8-bit multiplier
    output [15:0] product,  // 16-bit product of the multiplication
    input clk
    );
    
    // 8-bit wire buses to use as input in computing the partial product for each bit in the multiplier 
    wire [7:0] partial0, partial1, partial2, partial3, partial4, partial5, partial6, partial7;
    // 16-bit partial products that will be assigned the correct amount of lagging zeros
    wire [15:0] sum0, sum1, sum2, sum3, sum4, sum5, sum6, sum7; 
    reg [15:0] zero_one, two_three, four_five, six_seven, zeroTothree, fourToseven;
    initial begin 
       zero_one <= 16'h0000;
       two_three <= 16'h0000;
       four_five <= 16'h0000;
       six_seven <= 16'h0000;
       zeroTothree <= 16'h0000;
       fourToseven <= 16'h0000;
    end
    
    // Compute the partial product of the multiplier bits 0 through 7 then assign the appropriate
    // amount of lagging zeros using concatenation operator 
    findPartial P0(multiplier[0], value, partial0);
    assign sum0 = partial0;
    findPartial P1(multiplier[1], value, partial1);
    assign sum1 = {partial1, 1'b0};
    findPartial P2(multiplier[2], value, partial2);
    assign sum2 = {partial2, 2'b00};
    findPartial P3(multiplier[3], value, partial3);
    assign sum3 = {partial3, 3'b000};
    findPartial P4(multiplier[4], value, partial4);
    assign sum4 = {partial4, 4'b0000};
    findPartial P5(multiplier[5], value, partial5);
    assign sum5 = {partial5, 5'b00000};
    findPartial P6(multiplier[6], value, partial6);
    assign sum6 = {partial6, 6'b000000};
    findPartial P7(multiplier[7], value, partial7);
    assign sum7 = {partial7, 7'h00};
    
    always @ (posedge clk) begin
       zero_one <= sum0 + sum1;
       two_three <= sum2 + sum3;
       four_five <= sum4 + sum5;
       six_seven <= sum6 + sum7;
       zeroTothree <= zero_one + two_three;
       fourToseven <= four_five + six_seven;
    end
    // Assign the 16-bit final product to the summation of all the shifted partial products
    //assign product = sum0 + sum1 + sum2 + sum3 + sum4 + sum5 + sum6 + sum7;
    assign product = zeroTothree + fourToseven;
    
endmodule

// Computes the partial product without lagging zeroes
module findPartial(
    input mult,  //The one bit multiplier assigned to each bit in the multiplicand 
    input [7:0] value, // 8-bit multiplicand
    output [7:0] partial  // Partial 8-bit product
    );
    
    // Make the multiplier bit 8-bits wide so it can be multiplied with the multiplicand
    // and assigned to the partial product output
    assign partial[7:0] = {8{mult}} & value[7:0];
    
endmodule
