`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Ben Ellis 
// Module Name: memory
// Project Name: 8-bit_calculator
// Target Devices: Xilinx Artix-7 FPGA
// Description: This program provides the functionality to read and write to 
// memory in real time.  
//////////////////////////////////////////////////////////////////////////////////

module memory(
    inout [15:0] data,
    input oe, we, clk,
    input [1:0] addr
    );
    
    reg [15:0] mem [0:3];
    reg [15:0] data_temp;
    assign data = (oe && !we) ? data_temp:16'hzzzz;
    
    always @ (posedge clk)  begin 
       if (we) mem[addr] <= data; 
       else if (oe) data_temp <= mem[addr]; 
    end
     
endmodule