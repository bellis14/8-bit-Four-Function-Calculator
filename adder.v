`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Ben Ellis 
// Module Name: adder8
// Project Name: 8-bit_calculator
// Target Devices: Xilinx Artix-7 FPGA
// Description: This program adds together two 8-bit values to produce a 16-bit sum
//////////////////////////////////////////////////////////////////////////////////

// Adds two 8-bit values together and displays the sum 
module adder8(
    input [7:0] x,      // first 8-bit value
    input [7:0] y,      // second 8-bit value
    //output carry,       // final carry out value
    output [8:0] sum    // sum of the two 8-bit values
    );
    // carry out wires flowing from each full adder circuit into the next
    wire carryOut0, carryOut1, carryOut2, carryOut3, carryOut4, carryOut5, carryOut6, carry;
    
    //full adder circuits 0 through 7 that produce the output for each bit of the output sum
    fulladd B0(x[0], y[0], 1'b0, carryOut0, sum[0]); 
    fulladd B1(x[1], y[1], carryOut0, carryOut1, sum[1]);
    fulladd B2(x[2], y[2], carryOut1, carryOut2, sum[2]);
    fulladd B3(x[3], y[3], carryOut2, carryOut3, sum[3]);
    fulladd B4(x[4], y[4], carryOut3, carryOut4, sum[4]);
    fulladd B5(x[5], y[5], carryOut4, carryOut5, sum[5]);
    fulladd B6(x[6], y[6], carryOut5, carryOut6, sum[6]);
    fulladd B7(x[7], y[7], carryOut6, carry, sum[7]);
    assign sum[8] = carry;
    
endmodule

//Adds two 1-bit values together using a carry in variable
//and produces a 1-bit output value and carryout value
module fulladd(
    input x,            //first 1-bit value
    input y,            //second 1-bit value
    input carryIn,      //1-bit carry in value for output summation
    output carryOut,    //1-bit carry out value to be used in the next full adder instance
    output result       //1-bit output value used in the final 8-bit LED sequence
    );
    wire xorOut, andOut1, andOut2;
    xor x0(xorOut, x, y);
    xor x1(result, xorOut, carryIn);
    and A0(andOut1, carryIn, xorOut);
    and A1(andOut2, x, y);
    or M0(carryOut, andOut1, andOut2);
   
endmodule


