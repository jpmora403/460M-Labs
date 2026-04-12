`timescale 1ns / 1ps
module multiplier (
    input      [7:0] n1, n2,
    output reg [7:0] F,
    output reg       V
);
    reg [9:0] product;
    reg [3:0] exp;

    always @(n1 or n2) begin
        F = 8'h00;
        V = 1'b0;
            if (n1[6:4] == 3'd0 || n2[6:4] == 3'd0) begin
                F[7:0] = 8'b0;
            end else begin
                F[7] = n1[7] ^ n2[7];
                exp     = n1[6:4] + n2[6:4] - 4'd3;
                product = {1'b1, n1[3:0]} * {1'b1, n2[3:0]};
                if (product[9]) begin
                    F[3:0] = product[8:5];
                    exp    = exp + 1;
                end else begin
                    F[3:0] = product[7:4];
                end
                if (exp[3]) begin
                    V      = 1'b1;
                    F[6:4] = 3'b111;
                end else begin
                    F[6:4] = exp[2:0];
                end
            end
        end
endmodule