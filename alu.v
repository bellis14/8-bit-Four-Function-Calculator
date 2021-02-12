`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Ben Ellis 
// Module Name: alu
// Project Name: 8-bit_calculator
// Target Devices: Xilinx Artix-7 FPGA
// Description: This submodule is a description of an arithmetic logic unit circuit
// that determines which math operation result gets sent to be stored in the SRAM
// block to be sent to the seven segment display
//////////////////////////////////////////////////////////////////////////////////

// Combinational logic to choose operation
module alu(
    output [15:0] aluout,
    input [7:0] regoutA,
    input [7:0] regoutB,
    input [1:0] ALUFuncSel,
    input clk
    );
    
    wire [15:0] q, h, j, k;
    wire [15:0] mux1, mux2;
    multiplication M0(regoutA, regoutB, h, clk);
    division D0(q, regoutA, regoutB);
    subtraction S0(j, regoutA, regoutB);
    adder8 A0(regoutA, regoutB, k);                   
    assign mux1 = ALUFuncSel[0] ? q : h;
    assign mux2 = ALUFuncSel[0] ? k : j;
    assign aluout = ALUFuncSel[1] ? mux2 : mux1;
endmodule