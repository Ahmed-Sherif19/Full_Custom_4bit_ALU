`timescale 1ns / 1ps

module tb_ALU_Top;

    //Signals
    reg  [3:0] a;
    reg  [3:0] b;
    reg  [3:0] sel;
    wire [7:0] y;

    //Internal Testbench Variables
    reg  [7:0] expected_y;
    integer error_count = 0;
    integer test_count = 0;
    integer i;

    //Instantiate the ALU 
    ALU_Top uut (
        .a(a),
        .b(b),
        .sel(sel),
        .y(y)
    );

    //The "Golden Model"
    task calculate_expected;
        input  [3:0] a_in, b_in, sel_in;
        output [7:0] y_out;
        
        reg [7:0] a_ext, b_ext;
        begin
            a_ext = {{4{a_in[3]}}, a_in};
            b_ext = {{4{b_in[3]}}, b_in};

            if (sel_in[3] == 1'b0) begin
                //Arithmetic Operations
                case (sel_in[2:0])
                    3'b000: y_out = a_ext + 1;
                    3'b001: y_out = b_ext + 1;
                    3'b010: y_out = a_ext;
                    3'b011: y_out = b_ext;
                    3'b100: y_out = a_ext - 1;
                    3'b101: y_out = b_ext - 1;
                    3'b110: y_out = a_ext + b_ext;
                    3'b111: y_out = a_ext - b_ext; 
                endcase
            end else begin
                //Logical Operations
                case (sel_in[2:0])
                    3'b000: y_out = ~a_ext;
                    3'b001: y_out = ~b_ext;
                    3'b010: y_out = a_ext & b_ext;
                    3'b011: y_out = a_ext | b_ext;
                    3'b100: y_out = a_ext ^ b_ext;
                    3'b101: y_out = ~(a_ext ^ b_ext);
                    3'b110: y_out = ~(a_ext & b_ext);
                    3'b111: y_out = ~(a_ext | b_ext);
                endcase
            end
        end
    endtask

    //Test Execution Task
    task apply_test;
        input [3:0] test_a, test_b, test_sel;
        begin
            a   = test_a;
            b   = test_b;
            sel = test_sel;
            
            calculate_expected(a, b, sel, expected_y);
            
            //Wait a small delay to let the structural gates calculate
            #5; 
            
            test_count = test_count + 1;
            
            //Self-checking logic
            if (y !== expected_y) begin
                $display("[ERROR] a=%0d, b=%0d, sel=%b | Expected: %b, Got: %b", 
                         $signed(a), $signed(b), sel, expected_y, y);
                error_count = error_count + 1;
            end
        end
    endtask

    //Main Test Sequence
    initial begin
        $display("==================================================");
        $display(" Starting ALU Verification...");
        $display("==================================================");

        $display("-> Running Corner Cases...");
        for (i = 0; i < 16; i = i + 1) begin
            apply_test(4'b0000, 4'b0000, i); 
            apply_test(4'b0111, 4'b0111, i); 
            apply_test(4'b1000, 4'b1000, i); 
            apply_test(4'b0111, 4'b1000, i); 
        end

        $display("-> Running 500 Randomized Tests...");
        for (i = 0; i < 500; i = i + 1) begin
            apply_test($random % 16, $random % 16, $random % 16);
        end

        $display("==================================================");
        $display(" Verification Complete.");
        $display(" Total Tests Run : %0d", test_count);
        $display(" Total Errors    : %0d", error_count);
        
        if (error_count == 0)
            $display(" RESULT          : PASSED \n");
        else
            $display(" RESULT          : FAILED \n");
        $display("==================================================");
        
        $finish;
    end

endmodule