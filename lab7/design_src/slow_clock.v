`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/23/2026 02:46:41 PM
// Design Name: 
// Module Name: slow_clock
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


module slow_clock(
input CLK,
output SCLK
    );
    
    reg [24:0] count; //1 second clk
    
    initial count <= 0;
    
    always @(posedge CLK) count <= count + 1;
    
    assign SCLK = count[24];
endmodule
