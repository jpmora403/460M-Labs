`timescale 1ns / 1ps

module Matrix(
input clk, reset, start,
input [7:0]a00,
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

output [7:0] 
M1_out,
M2_out,
M3_out,
M4_out,
M5_out,
M6_out,
M7_out,
M8_out,
M9_out,
done
);

localparam IDLE = 4'b0000;
localparam SHIFT0 = 4'b0001;
localparam SHIFT1 = 4'b0010;
localparam SHIFT2 = 4'b0011;
localparam SHIFT3 = 4'b0100;
localparam SHIFT4 = 4'b0101;
localparam SHIFT5 = 4'b0110;
localparam SHIFT6 = 4'b1000;
localparam _WAIT = 4'b0111;
localparam _DONE = 4'b1001;

reg [3:0] current_state, next_state;
reg [3:0] state_counter;

reg [7:0] side0, side1, side2, top0, top1, top2;
wire [7:0] w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11;
reg [3:0] wait_next_state;
wire [8:0] pe_done;
reg [8:0] pe_start;

//PE instantiations and wire connections
PE pe0(.start(pe_start[0]), .clk(clk), .a_in(side0), .a_out(w0), .b_in(top0), .b_out(w2), .acc(M1_out), .done(pe_done[0]));
PE pe1(.start(pe_start[1]), .clk(clk), .a_in(w0), .a_out(w1), .b_in(top1), .b_out(w3), .acc(M2_out), .done(pe_done[1]));
PE pe2(.start(pe_start[2]), .clk(clk), .a_in(w1), .a_out(), .b_in(top2), .b_out(w4), .acc(M3_out), .done(pe_done[2]));
PE pe3(.start(pe_start[3]), .clk(clk), .a_in(side1), .a_out(w5), .b_in(w2), .b_out(w7), .acc(M4_out), .done(pe_done[3]));
PE pe4(.start(pe_start[4]), .clk(clk), .a_in(w5), .a_out(w6), .b_in(w3), .b_out(w8), .acc(M5_out), .done(pe_done[4]));
PE pe5(.start(pe_start[5]), .clk(clk), .a_in(w6), .a_out(), .b_in(w4), .b_out(w9), .acc(M6_out), .done(pe_done[5]));
PE pe6(.start(pe_start[6]), .clk(clk), .a_in(side2), .a_out(w10), .b_in(w7), .b_out(), .acc(M7_out), .done(pe_done[6]));
PE pe7(.start(pe_start[7]), .clk(clk), .a_in(w10), .a_out(w11), .b_in(w8), .b_out(), .acc(M8_out), .done(pe_done[7]));
PE pe8(.start(pe_start[8]), .clk(clk), .a_in(w11), .a_out(), .b_in(w9), .b_out(), .acc(M9_out), .done(pe_done[8]));
//Sequencer
always @(*) begin
    case (current_state)
        IDLE: next_state = start ? SHIFT0 : IDLE;
        SHIFT0: next_state = _WAIT;
        SHIFT1: next_state = _WAIT;
        SHIFT2: next_state = _WAIT;
        SHIFT3: next_state = _WAIT;
        SHIFT4: next_state = _WAIT;
        SHIFT5: next_state = _WAIT;
        SHIFT6: next_state = _WAIT;
        _WAIT: next_state = wait_next_state;
    endcase     
end

always @(*) begin
    case (state_counter)
        1: wait_next_state = pe_done[0] ? SHIFT1 : _WAIT;
        2: wait_next_state = (pe_done[0] & pe_done[1] & pe_done[3]) ? SHIFT2 : _WAIT;
        3: wait_next_state = (&pe_done[4:0] & pe_done[6]) ? SHIFT3 : _WAIT;
        4: wait_next_state = &pe_done[7:1] ? SHIFT4 : _WAIT;
        5: wait_next_state = (&pe_done[8:4] & &pe_done[3:2]) ? SHIFT5 : _WAIT;
        6: wait_next_state = (pe_done[5] & pe_done[7] & pe_done[8]) ? SHIFT6 : _WAIT;
        7: wait_next_state = pe_done[8] ? _DONE : _WAIT;
        8: wait_next_state = _DONE;
    endcase
end

always @(*) begin
    pe_start = 9'b000000000;
    case (current_state)
        0: pe_start = 9'b000000000;
        1: pe_start[0] = 9'b000000001;
        2: begin
            pe_start[0] = 1'b1;
            pe_start[1] = 1'b1;
            pe_start[2] = 1'b0;
            pe_start[3] = 1'b1;
            pe_start[8:4] = 5'b00000;
        end
        3: begin
            pe_start[4:0] = 5'b11111;
            pe_start[6] = 1'b1;
            pe_start[8:7] = 2'b00;
            pe_start[5] = 1'b0;
        end
        4: begin
            pe_start[7:1] = 7'b1111111;
            pe_start[8] = 1'b0;
            pe_start[0] = 1'b0;
        end
        5: begin
            pe_start[2] = 1'b1;
            pe_start[8:4] = 5'b11111;
            pe_start[1:0] = 2'b00;
            pe_start[3] = 1'b0;
        end 
        6: begin
            pe_start[5] = 1'b1;
            pe_start[7] = 1'b1;
            pe_start[8] = 1'b1;
            pe_start[4:0] = 5'b00000;
            pe_start[6] = 1'b0;
        end
        8: begin
            pe_start = 9'b100000000;
        end
        7: pe_start = 9'b000000000;
        9: pe_start = 9'b000000000;
        
        default: pe_start = 9'b000000000;
    endcase
end
        
always @(posedge clk or posedge reset) begin
    if (reset)
        current_state <= IDLE;
    else
        current_state <= next_state;
end

//Load regs
always @(posedge clk) begin
    case(next_state)
        IDLE: begin
            state_counter <= 0;
        end
        SHIFT0: begin
            state_counter <= state_counter + 1;
            side0 <= a00;
            top0 <= b00;
        end
        SHIFT1: begin
            state_counter <= state_counter + 1;
            side0 <= a01;
            side1 <= a10;
            top0 <= b10;
            top1 <= b01;
        end
        SHIFT2: begin
            state_counter <= state_counter + 1;
            side0 <= a02;
            side1 <= a11;
            side2 <= a20;
            top0 <= b20;
            top1 <= b11;
            top2 <= b02;
        end
        SHIFT3: begin
            state_counter <= state_counter + 1;
            side1 <= a12;
            side2 <= a21;
            top1 <= b21;
            top2 <= b12;
        end
        SHIFT4: begin
            state_counter <= state_counter + 1;
            side2 <= a22;
            top2 <= b22;
        end
        SHIFT5: state_counter <= state_counter + 1;
        SHIFT6: state_counter <= state_counter + 1;
    endcase
end
        

endmodule
