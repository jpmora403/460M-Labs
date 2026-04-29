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
  output reg [0:6] seg,
  output reg [3:0] an
  );


  wire CS, WE;
  wire btnR_d, btnL_d;
  wire btnR_s, btnL_s;
  wire [6:0] ADDR;
  wire [31:0] Mem_Bus;
  wire SCLK;
  wire displayClk;
  wire convert;
  wire [31:0] r2_out;
  wire [31:0] r1_out;
  reg [1:0] an_counter;
  reg [15:0] display;
  reg [15:0] digit;

  slow_clock sclk(CLK, SCLK);
  complexDivider c1 (.clk100Mhz(CLK), .slowClk(displayClk));
  MIPS CPU(SCLK, RST, halt, CS, WE, ADDR, Mem_Bus, r1_out, r2_out, switch);
  Memory MEM(CS, WE, SCLK, ADDR, Mem_Bus);
  debouncer d1(.btn_in(btnR), .clk(CLK), .btn_out(btnR_d));
  debouncer d2(.btn_in(btnL), .clk(CLK), .btn_out(btnL_d));
  //single_pulser s1(.clk(CLK), .btn_in(btnR_d), .pulse(btnR_s));
  //single_pulser s2(.clk(CLK), .btn_in(btnL_d), .pulse(btnL_s));
  
  
  //assign led [7:0] = r1_out [7:0];
  
  always @(*)
  begin
  //Choose what to display on 7-segment
  if(btnR_s) begin
    display <= r2_out[31:16];
  end else begin
    display <= r2_out[15:0];
  end
  
  end
  
  
    always @(*) begin
        
    case(an_counter)
        2'b00: an = 4'b1110;
        2'b01: an = 4'b1101;
        2'b10: an = 4'b1011;
        2'b11: an = 4'b0111;
    endcase
    
    end
    
    
  
    always @(posedge displayClk)
    begin       
    an_counter <= an_counter + 1;
    
    case (an)
        4'b1110: digit <= display % 10;
        4'b1101: digit <= (display/10) % 10;
        4'b1011: digit <= (display/100) % 10;
        4'b0111: digit <= (display/1000) %10;
        
    
    endcase

    
    case (digit) 
        4'd0: seg <= 7'b0000001; 
        4'd1: seg <= 7'b1001111; 
        4'd2: seg <= 7'b0010010;
        4'd3: seg <= 7'b0000110;
        4'd4: seg <= 7'b1001100;
        4'd5: seg <= 7'b0100100; 
        4'd6: seg <= 7'b0100000;
        4'd7: seg <= 7'b0001111;
        4'd8: seg <= 7'b0000000;
        4'd9: seg <= 7'b0000100;
        4'd10: seg <= 7'b1110111;
        default: seg <= 7'b1111111; 
    endcase
    end

  


endmodule
