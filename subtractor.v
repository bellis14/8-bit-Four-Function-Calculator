`timescale 1ns / 1ps
// Author: Ben Ellis
// Module Name: subtraction
// Project Name: 8-bit_calculator
// Target Devices: Xilinx Artix-7 FPGA
// Description: This submodule is a description of a subtractor circuit
// that finds the difference between two 8-bit values and produces a 16-bit output
//////////////////////////////////////////////////////////////////////////////////


module subtraction (
    output [15:0] difference,  //The result of the operation
    input [7:0] x,  //The number to be taken from
    input [7:0] y  //The number that is subtracted
    );
    
    // carry out wires flowing from each full subtractor circuit into the next
    wire carryOut0, carryOut1, carryOut2, carryOut3, carryOut4, carryOut5, carryOut6, carry;
    
    //full subtractor circuits 0 through 7 that produce the output for each bit of the output difference
    fullsubtract B0(x[0], y[0], 1'b0, carryOut0, difference[0]); 
    fullsubtract B1(x[1], y[1], carryOut0, carryOut1, difference[1]);
    fullsubtract B2(x[2], y[2], carryOut1, carryOut2, difference[2]);
    fullsubtract B3(x[3], y[3], carryOut2, carryOut3, difference[3]);
    fullsubtract B4(x[4], y[4], carryOut3, carryOut4, difference[4]);
    fullsubtract B5(x[5], y[5], carryOut4, carryOut5, difference[5]);
    fullsubtract B6(x[6], y[6], carryOut5, carryOut6, difference[6]);
    fullsubtract B7(x[7], y[7], carryOut6, carry, difference[7]);
    assign difference[8] = carry;
endmodule

//////////////////////////////////////////////////////////////

//submodule that performs subtraction between two 1-bit values
module fullsubtract(
    input a,            //first 1-bit value
    input b,            //second 1-bit value
    input carryIn,      //1-bit carry in value for output summation
    output carryOut,    //1-bit carry out value to be used in the next full subtractor instance
    output result       
    );
    wire xorOut1, notOut1, notOut2, andOut1, andOut2;
    
    xor x1(xorOut1, a, b);
    xor x2(result, carryIn, xorOut1);
    not N1 (notOut1, a);
    not N2 (notOut2, xorOut1);
    and A1(andOut1, notOut1, b);
    and A2(andOut2, notOut2, carryIn);
    or M0(carryOut, andOut2, andOut1);
   
endmodule