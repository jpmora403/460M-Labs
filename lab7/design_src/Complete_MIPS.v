`timescale 1ns / 1ps


module Complete_MIPS(
  // This is your top module for synthesis.
  // You define what signals the top module needs.
  input halt,
  input CLK,
  input RST,
  input [2:0] switch,
  input btnL, btnR,
  output [7:0] led,
  output [6:0] seg,
  output [3:0] an
  );


  wire CS, WE;
  wire [6:0] ADDR;
  wire [31:0] Mem_Bus;
  wire SCLK;
  wire displayClk;
  wire convert;
  reg [31:0] r1_out;

  slow_clock sclk(CLK, SCLK);
  complexDivider c1 (.clk100Mhz(CLK), .slowClk(displayClk));
  MIPS CPU(halt, SCLK, RST, CS, WE, ADDR, Mem_Bus, r1_out, switch);
  Memory MEM(CS, WE, SCLK, ADDR, Mem_Bus);
  
  assign led [7:0] = r1_out [7:0];
  


endmodule
