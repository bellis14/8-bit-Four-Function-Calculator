`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Ben Ellis 
// Module Name: four_function_calculator
// Project Name: 8-bit_calculator
// Target Devices: Xilinx Artix-7 FPGA
// Description: This program describes a circuit that takes in two 8 bit 
// values as inputs and performs one of four arithmetic operations of addition, 
// subtraction, multiplication, and division. The output of this circuit will produce
// a 16-bit value but the seven segment display used to display the arithemtic operation
// will only show a max value of 9999 as only 4 seven segment displays are used in this
// implementation. 
//////////////////////////////////////////////////////////////////////////////////

module four_function_calculator(
    input btnT, btnB, btnR, btnL, btnC,
    input clk, 
    input [15:0] sw,
    output dp,
    output [3:0] an,
    output [6:0] seg,
    output [15:0] led
    );
       
    wire clk_deb;  //debounced clock
    wire add, subtract, multiply, divide, reset;  //debounced buttons
    wire [15:0] data_in_mem;  //bi-directional wire used to read and write to memory
    wire [15:0] BCD_data;  //output of binary to BCD converter
    wire [15:0] binary_data;  //binary value selected from the ALU
    reg [1:0] opcode;  //address used to select the operation and place in memory
    reg [15:0] result;  //value of the math operation
    reg we_in, oe_in;  //write/output enable signals
    reg [1:0] addr;  //address used to place data in memory cells
    initial begin 
       opcode = 0;
       result = 0;
    end
   
    // submodule instantiations
    debounce_div A1 (clk, clk_deb);
    btn_debounce B1 (clk_deb, btnT, multiply);
    btn_debounce B2 (clk_deb, btnB, divide);
    btn_debounce B3 (clk_deb, btnR, subtract);
    btn_debounce B4 (clk_deb, btnL, add);
    btn_debounce B5 (clk_deb, btnC, reset);
    memory in_mem (data_in_mem, oe_in, we_in, clk, addr); 
    binary_to_BCD D1 (data_in_mem, BCD_data);
    sseg_x4_top D0 (BCD_data, clk, 1'b0, an, dp, seg);
    alu A0 (binary_data, result[15:8], result[7:0], opcode, clk);
    assign led = binary_data;
    assign data_in_mem = we_in ? binary_data : 16'hZZZZ;
    
    always @ (posedge clk) begin
       if (reset) begin opcode = 0; result = 16'h0000; we_in = 1; oe_in = 0; addr = 0; end
       else if (add) begin opcode = 3; result = sw; we_in = 1; oe_in = 0; addr = 3;end
       else if (subtract) begin opcode = 2; result = sw; we_in = 1; oe_in = 0; addr = 2;end
       else if (multiply) begin opcode = 0; result = sw; we_in = 1; oe_in = 0; addr = 0;end
       else if (divide) begin opcode = 1; result = sw; we_in = 1; oe_in = 0; addr = 1; end
       else begin oe_in = 1; we_in = 0; end
    end
    
endmodule