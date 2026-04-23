`timescale 1ns / 1ps


module MIPS_Testbench ();
  reg CLK;
  reg RST;
  wire CS;
  wire WE;
  wire [31:0] Mem_Bus;
  wire [6:0] Address;
  
  integer i;
  parameter N = 10;
  reg[31:0] expected[N:1];

  initial
  begin
    CLK = 0;
  end
  
  initial begin
    expected[1] = 32'h00000006;
    expected[2] = 32'h00000012;
    expected[3] = 32'h00000018;
    expected[4] = 32'h0000000C;
    expected[5] = 32'h00000002;
    expected[6] = 32'h00000016;
    expected[7] = 32'h00000001;
    expected[8] = 32'h00000120;
    expected[9] = 32'h00000003;
    expected[10] = 32'h00412022;
  end

  MIPS CPU(CLK, RST, CS, WE, Address, Mem_Bus);
  Memory MEM(CS, WE, CLK, Address, Mem_Bus);

  always #5 CLK <= ~CLK;

  initial
  begin
    RST <= 1'b1; //reset the processor

    //Notice that the memory is initialize in the in the memory module not here

    @(posedge CLK);
    @(posedge CLK);
    // driving reset low here puts processor in normal operating mode
    RST <= 1'b0;

    for(i = 1; i <= N; i = i + 1) begin
        @(posedge WE);
        @(negedge CLK);
        if (Mem_Bus != expected[i])
            $display("Output mismatch: got %d, expect %d", Mem_Bus, expected[i]);
    end
    $display("TEST COMPLETE");
    $stop;
  end

endmodule

