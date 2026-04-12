`timescale 1ns / 1ps
module PE (
    input  wire       clk,
    input  wire [7:0] a_in,
    output reg  [7:0] a_out,
    input  wire [7:0] b_in,
    output reg  [7:0] b_out,
    output reg  [7:0] acc,
    input  wire       start,
    output reg        done
);

    // FSM states
    localparam IDLE      = 3'd0,
               ADD_START = 3'd1,
               ADD_BUFFER = 3'd2,
               ADD_WAIT  = 3'd3,
               PASS      = 3'd4;

    reg [2:0] state;

    wire [7:0] product;
    wire mult_v;

    wire [7:0] sum;
    wire add_v, add_done;
    reg  add_start;

    multiplier u_mult (
        .n1   (a_in),
        .n2   (b_in),
        .F    (product),
        .V    (mult_v)
    );

    float_adder u_add (
        .clk   (clk),
        .start (add_start),
        .a     (acc),     
        .b     (product),
        .sum   (sum),      
        .v     (add_v),
        .done  (add_done)
    );
   initial begin
    state = 2'b00;
    a_out = 8'h00;
    b_out = 8'h00;
    done = 1'b0;
    acc = 8'h00;
    add_start = 1'b0;
   end
   
    always @(*) begin
        done = state == PASS;
    end

    always @(posedge clk) begin

        case (state)
            IDLE: begin
                if (start) begin
                    state      <= ADD_START;
                end
            end

            ADD_START: begin
                add_start <= 1'b1; 
                state     <= ADD_BUFFER;
            end
            
            ADD_BUFFER: begin
                state <= ADD_WAIT;
            end

            ADD_WAIT: begin
                add_start  <= 1'b0;
                if (add_done) begin
                    acc   <= sum;
                    state <= PASS;

                end else begin
                    state <= ADD_WAIT;
                end
            end

            PASS: begin
                a_out <= a_in;
                b_out <= b_in;
                if (start) begin
                    state <= ADD_START;
                end else begin
                    state <= PASS;
                end
            end
        endcase
        end
endmodule
