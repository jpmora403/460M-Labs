`timescale 1ns / 1ps


module REG(
  input CLK,
  input RegW,
  input [4:0] DR,
  input [4:0] SR1,
  input [4:0] SR2,
  input [31:0] Reg_In,
  
  output reg [31:0] ReadReg1,
  output reg [31:0] ReadReg2,
  output [31:0] r1_out,
  output [31:0] r2_out,
  input [2:0] switch
  );


  reg [31:0] REG [0:31];
  integer i;
   

  assign r2_out = REG[2];
  
  
  initial begin
    ReadReg1 = 0;
    ReadReg2 = 0;
        for (i = 0; i < 32; i = i + 1) begin
            REG[i] = 0;
        end
  end

  always @(posedge CLK)
  begin

    if(RegW == 1'b1)
      REG[DR] <= Reg_In[31:0];


    ReadReg1 <= REG[SR1];
    ReadReg2 <= REG[SR2];
    REG[1] <= {29'b0,switch[2:0]};
  end
endmodule

