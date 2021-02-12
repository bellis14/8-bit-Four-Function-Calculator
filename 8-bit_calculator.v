`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/30/2020 03:12:26 PM
// Design Name: 
// Module Name: 8-bit_calculator
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

//////////////////////////////////////////////////////////////////

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

/////////////////////////////////////////////////////////////
module subtraction (
    output [15:0] difference,  //The result of the operation
    input [7:0] x,  //The number to be taken from
    input [7:0] y  //The number that is subtracted
    );
    
    // carry out wires flowing from each full adder circuit into the next
    wire carryOut0, carryOut1, carryOut2, carryOut3, carryOut4, carryOut5, carryOut6, carry;
    
    //full adder circuits 0 through 7 that produce the output for each bit of the output sum
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

////////////////////////////////////////////////////////////
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

////////////////////////////////////////////////////////////
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
////////////////////////////////////////////////////////////
module debounce_div(
    input clk,
    output clk_deb
    );
    reg [15:0] cnt;
    
    assign clk_deb = cnt[15];
    
    initial cnt = 0;
    always @(posedge clk)
        cnt <= cnt + 1;
        
endmodule
//////////////////////////////////////////////////////////////////////////
module btn_debounce(
    input clk,
    input btn_in,
    output wire btn_status
    );
    reg [19:0] btn_shift;
        
    always @ (posedge clk)
        btn_shift <= {btn_shift[18:0], btn_in};
    
    assign btn_status = &btn_shift;
endmodule
//////////////////////////////////////////////////////////////////////////
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
