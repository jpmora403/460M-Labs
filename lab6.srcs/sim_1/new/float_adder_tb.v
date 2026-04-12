`timescale 1ns / 1ps

module float_adder_tb_v3();

    // UUT Signals
    reg [7:0] a, b;
    reg clk, start;
    wire [7:0] sum;
    wire v, done;

    // Waveform Reference
    reg [7:0] expected_sum;

    // Instantiate Unit Under Test
    float_adder uut (
        .a(a), .b(b), .clk(clk), .start(start), 
        .sum(sum), .v(v), .done(done)
    );

    // Clock Generation (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    // Task to manage the handshake and verification
    task run_test(input [7:0] t_a, input [7:0] t_b, input [7:0] t_exp);
        begin
            // 1. Set inputs and Expected Value for the wave window
            a = t_a; 
            b = t_b;
            expected_sum = t_exp;
            
            // 2. Trigger Start
            @(posedge clk);
            start = 1;
            
            // 3. Handshake: Wait for FSM to leave DONE/IDLE and clear 'done'
            @(posedge clk);
            while (done === 1'b1) @(posedge clk);
            
            // 4. Release Start once FSM has acknowledged
            start = 0;
            
            // 5. Wait for FSM to reach the DONE state
            wait(done === 1'b1);
            
            // 6. Final verification
            @(posedge clk); 
            if (sum === t_exp)
                $display("SUCCESS: A=%b B=%b | Sum=%b", t_a, t_b, sum);
            else
                $display("ERROR:   A=%b B=%b | Sum=%b (Expected %b)", t_a, t_b, sum, t_exp);
            
            #20; // Observation gap
        end
    endtask

    initial begin
        // Initialize
        a = 0; b = 0; start = 0; expected_sum = 0;
        #100;

        $display("--- Starting Implicit Normalization (f_sum[4]) Tests ---");

        // TEST 1: Addition (2 + 3 = 5 -> Normalized to 1.0100 * 2^0)
        run_test(8'b00100010, 8'b00100011, 8'b00000100);

        // TEST 2: Alignment (Exp 3 vs Exp 2)
        run_test(8'b00110010, 8'b00100100, 8'b00010000);

        // TEST 3: Subtraction (8 - 2 = 6 -> Normalized to 1.1000 * 2^1)
        run_test(8'b00101000, 8'b10100010, 8'b00011000);

        // TEST 4: Fractional Overflow (12 + 8 = 20 -> 1.0100 * 2^2)
        run_test(8'b00101100, 8'b00101000, 8'b00100100);

        $display("--- Testing Complete ---");
        $stop;
    end

endmodule