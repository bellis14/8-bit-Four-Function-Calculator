`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Ben Ellis 
// Module Name: debouncer
// Project Name: 8-bit_calculator
// Target Devices: Xilinx Artix-7 FPGA
// Description: This program accounts for the unstable signal that occurs from
// input switches such as buttons and provides a steady high 1 or low 0 value. 
//////////////////////////////////////////////////////////////////////////////////

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

//submodule that divides down the 100MHz clock
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