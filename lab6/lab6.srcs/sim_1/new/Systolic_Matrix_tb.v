`timescale 1ns / 1ps


module Systolic_Matrix_tb();
    reg clk;
    reg start; 
    reg reset;
    reg [7:0] a00, a01, a02, a10, a11, a12, a20, a21, a22;
    reg [7:0] b00, b01, b02, b10, b11, b12, b20, b21, b22;
    
    wire done;
    wire [7:0] M1_out, M2_out, M3_out, M4_out, M5_out, M6_out, M7_out, M8_out, M9_out;
    
    always #5 clk <= ~clk;
    
    initial begin
	clk = 0;
        start = 0;
        reset = 1;
        a00 = 8'b00100000; a01 = 8'b00110000; a02 = 8'b00111000;    //  0.5    1    1.5
        a10 = 8'b00110000; a11 = 8'b01000000; a12 = 8'b01001000;    //   1     2     3
        a20 = 8'b10100000; a21 = 8'b10110000; a22 = 8'b10111000;    // -0.5   -1   -1.5
    
        b00 = 8'b00100000; b01 = 8'b00110000; b02 = 8'b00111000;    //  0.5    1    1.5
        b10 = 8'b00100000; b11 = 8'b00110000; b12 = 8'b00111000;    //  0.5    1    1.5
        b20 = 8'b00100000; b21 = 8'b00110000; b22 = 8'b00111000;    //  0.5    1    1.5

//        EXPECTED RESULT:
//        c00 = 8'b00111000; c01 = 8'b01001000; c02 = 8'b01010010;    //  1.5    3    4.5
//        c10 = 8'b01001000; c11 = 8'b01011000; c12 = 8'b01100010;    //   3     6     9
//        c20 = 8'b10111000; c01 = 8'b11001000; c02 = 8'b11010010;    // -1.5   -3   -4.5
        
        
        #10;
        reset = 0;
        
        #100;
        start = 1;
     
    end
    
    Matrix DUT( clk, 
                reset, 
                start, 
                a00, 
                a01, 
                a02, 
                a10, 
                a11, 
                a12, 
                a20, 
                a21, 
                a22, 
                b00, 
                b01, 
                b02, 
                b10, 
                b11, 
                b12, 
                b20, 
                b21, 
                b22,
                //make sure the above wires/ports are identicaly
                
                //You can choose not to have below wires/ports in your design
                M1_out, 
                M2_out, 
                M3_out, 
                M4_out, 
                M5_out, 
                M6_out, 
                M7_out, 
                M8_out, 
                M9_out, 
                done); 
    
endmodule
