`timescale 1ns / 1ps

module float_adder(
input [7:0] a, b,
input clk, start,
output reg [7:0] sum,
output reg v, done
    );
    localparam IDLE = 4'b0000;
    localparam ADD_ZERO = 4'b0001;
    localparam BEGIN = 4'b1101;
    localparam SHIFT_SMALL_RIGHT = 4'b0010;
    localparam ADD = 4'b0011;
    localparam SET_ZERO = 4'b0100;
    localparam FRAC_OVF = 4'b0101;
    localparam NORMALIZE = 4'b0110;
    localparam GENERATE_EXCEPTION = 4'b0111;
    localparam ROUND = 4'b1000;
    localparam DONE = 4'b1001;
    localparam COMBINE = 4'b1100;
    
    
    reg [3:0] current_state, next_state;
    reg [4:0] a_f, b_f;
    reg [3:0] a_e, b_e;
    reg [5:0] f_sum;
    reg [3:0] e;
    reg [7:0] a1,b1;
    
   initial begin
         current_state = 0;
         next_state = 0;
         a_f = 0;
         b_f =0;
         a_e =0;
         b_e =0;
         f_sum =0;
         e = 0;
         v = 0;
         sum = 0;
         done = 0;
     end
     
     //ctrl signals
     wire sign = (a1[7] == b1[7]) ? a1[7] : ((a_f > b_f) ? a1[7] : b1[7]);
     wire alu = (a1[7] == b1[7]) ? 1'b0 : 1'b1; //0 is add 1 is subtract
     wire exp_equal = (a_e == b_e) ? 1'b1 : 1'b0;
     wire is_zero = (f_sum == 5'b00000) ? 1'b1 : 1'b0;
     wire f_ovf = f_sum[5];
     wire is_normalized = f_sum[4];
     wire e_ovf = a_e[3];
     wire addzero_ctrl = (a == 0) | (b == 0);
     
    //Sequencer
    always @(*) begin
        case (current_state)
            IDLE: next_state = start? BEGIN : IDLE;
            BEGIN: next_state = addzero_ctrl? ADD_ZERO : SHIFT_SMALL_RIGHT;
            ADD_ZERO: next_state = DONE;
            SHIFT_SMALL_RIGHT: next_state = exp_equal ? ADD : SHIFT_SMALL_RIGHT;
            ADD: next_state = is_zero ? SET_ZERO : (f_ovf ? FRAC_OVF : ( is_normalized ? (e_ovf ? GENERATE_EXCEPTION : ROUND ) : NORMALIZE )); 
            SET_ZERO: next_state = DONE;
            FRAC_OVF: next_state = is_normalized ? (e_ovf ? GENERATE_EXCEPTION : ROUND) : NORMALIZE;
            NORMALIZE: next_state = is_normalized ? (e_ovf ? GENERATE_EXCEPTION : ROUND) : NORMALIZE;
            GENERATE_EXCEPTION: next_state = DONE;
            ROUND: next_state = is_normalized ? COMBINE : (is_zero ? SET_ZERO : (f_ovf ? FRAC_OVF : ( is_normalized ? (e_ovf ? GENERATE_EXCEPTION : ROUND ) : NORMALIZE )));
            COMBINE: next_state = DONE;
            DONE: next_state = start? BEGIN : DONE;
        endcase
    end
    
    always @(posedge clk) current_state <= next_state;
    
    //Load registers
    always @(posedge clk) begin
        case (next_state)               
            BEGIN: begin
                a1 <= a;
                b1 <= b;
                a_f <= {1'b1,a[3:0]};
                b_f <= {1'b1,b[3:0]};
                a_e <= a[6:4];
                b_e <= b[6:4];
                done <= 0;
                v <= 0;
                f_sum <= 0;
                
            end
            ADD_ZERO: sum <= (a == 0) ? b : a;
            ADD: begin
                if (~alu)
                    f_sum <= a_f + b_f;
                else
                    f_sum <= (a_f > b_f) ? (a_f - b_f) : (b_f - a_f);
            end
            SET_ZERO: sum <= 0; 
            SHIFT_SMALL_RIGHT: begin
                if (a_e < b_e) begin
                    a_f <= a_f >> 1;
                    a_e <= a_e + 1;
                end
                else begin
                    b_f <= b_f >> 1;
                    b_e <= b_e + 1;
                end
            end
            FRAC_OVF: begin
                f_sum <= f_sum >> 1;
                a_e <= a_e + 1;
            end
            NORMALIZE: begin
                a_e <= a_e - 1;
                f_sum <= f_sum << 1;
            end
            COMBINE: begin
                sum[7] <= sign;
                sum[6:4] <= a_e[2:0];
                sum[3:0] <= f_sum[3:0];
            end
            DONE: done <= 1'b1;
            GENERATE_EXCEPTION: v <= 1'b1;
        endcase
    end   
    
endmodule
