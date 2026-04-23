`timescale 1ns / 1ps


module Complete_MIPS(CLK, RST);
  // This is your top module for synthesis.
  // You define what signals the top module needs.
  input CLK;
  input RST;

  wire CS, WE;
  wire [6:0] ADDR;
  wire [31:0] Mem_Bus;

  MIPS CPU(CLK, RST, CS, WE, ADDR, Mem_Bus);
  Memory MEM(CS, WE, CLK, ADDR, Mem_Bus);

endmodule
