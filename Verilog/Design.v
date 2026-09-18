
module mux2x1 (input d0, d1, sel, output y);
    wire not_sel;
    wire nand0, nand1;
    not  (not_sel, sel);
    nand (nand0, d0, not_sel);
    nand (nand1, d1, sel);
    nand (y, nand0, nand1);
    
endmodule

module mux8x1 (input [7:0] d, input [2:0] sel, output y);
    wire m00, m01, m02, m03, m10, m11;
    
    //First stage
    mux2x1 u0 (.d0(d[0]), .d1(d[1]), .sel(sel[0]), .y(m00));
    mux2x1 u1 (.d0(d[2]), .d1(d[3]), .sel(sel[0]), .y(m01));
    mux2x1 u2 (.d0(d[4]), .d1(d[5]), .sel(sel[0]), .y(m02));
    mux2x1 u3 (.d0(d[6]), .d1(d[7]), .sel(sel[0]), .y(m03));
    
    //Second stage
    mux2x1 u4 (.d0(m00), .d1(m01), .sel(sel[1]), .y(m10));
    mux2x1 u5 (.d0(m02), .d1(m03), .sel(sel[1]), .y(m11));
    
    //Third stage
    mux2x1 u6 (.d0(m10), .d1(m11), .sel(sel[2]), .y(y));
endmodule

//1-bit Full Adder 
module full_adder (input a, b, cin, output sum, cout);
    wire w_xor_ab;
    wire n1, n2;

    // Sum Logic 
    xor (w_xor_ab, a, b);
    xor (sum, w_xor_ab, cin);

    // Concept: cout = (a & b) | (cin & w_xor_ab)  ==>  ~(~(a & b) & ~(cin & w_xor_ab))
    nand (n1, a, b);
    nand (n2, cin, w_xor_ab);
    nand (cout, n1, n2);
    
endmodule


// 1-Bit Logic Slice
module logic_slice (input a_bit, b_bit, input [2:0] sel, output out);
    wire not_a, not_b;
    wire nand_ab, nor_ab;
    wire and_ab, or_ab;
    wire xor_ab, xnor_ab;

    not (not_a, a_bit);
    not (not_b, b_bit);

    nand (nand_ab, a_bit, b_bit);
    nor  (nor_ab, a_bit, b_bit);

    not (and_ab, nand_ab); 
    not (or_ab, nor_ab);   

    xor  (xor_ab, a_bit, b_bit);
    xnor (xnor_ab, a_bit, b_bit);

    mux8x1 mux_log (
        .d({nor_ab, nand_ab, xnor_ab, xor_ab, or_ab, and_ab, not_b, not_a}),
        .sel(sel),
        .y(out)
    );
endmodule

//1-Bit Arithmetic Slice
module arith_slice (input a_bit, b_bit, input [2:0] sel, input cin, output sum, cout);
    wire x_val, y_val;
    wire not_b;
    
    not (not_b, b_bit);

    //X Input MUX routing to the adder
    mux8x1 mux_x (
        .d({a_bit, a_bit, 1'b1, a_bit, 1'b0, a_bit, 1'b0, a_bit}),
        .sel(sel),
        .y(x_val)
    );

    //Y Input MUX routing to the adder
    mux8x1 mux_y (
        .d({not_b, b_bit, b_bit, 1'b1, b_bit, 1'b0, b_bit, 1'b0}),
        .sel(sel),
        .y(y_val)
    );

    full_adder fa (
        .a(x_val), .b(y_val), .cin(cin),
        .sum(sum), .cout(cout)
    );
endmodule


module ALU_Top (
    input  [3:0] a,
    input  [3:0] b,
    input  [3:0] sel,
    output [7:0] y
);

    //Sign Extension
    wire [7:0] a_ext = {{4{a[3]}}, a};
    wire [7:0] b_ext = {{4{b[3]}}, b};

    //Logic Unit (4-bit)
    wire [3:0] logic_out;
    logic_slice ls0 (.a_bit(a[0]), .b_bit(b[0]), .sel(sel[2:0]), .out(logic_out[0]));
    logic_slice ls1 (.a_bit(a[1]), .b_bit(b[1]), .sel(sel[2:0]), .out(logic_out[1]));
    logic_slice ls2 (.a_bit(a[2]), .b_bit(b[2]), .sel(sel[2:0]), .out(logic_out[2]));
    logic_slice ls3 (.a_bit(a[3]), .b_bit(b[3]), .sel(sel[2:0]), .out(logic_out[3]));
    
    wire [7:0] logic_ext = {{4{logic_out[3]}}, logic_out};

    //Arithmetic Unit (8-bit)
    wire [7:0] arith_out;
    wire [8:0] carry;

    //Cin generator for the first arithmetic stage
    mux8x1 cin_mux (
        .d({1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b1}),
        .sel(sel[2:0]),
        .y(carry[0])
    );

    genvar i;
    generate
        for(i=0; i<8; i=i+1) begin : arith_inst
            arith_slice aslice (
                .a_bit(a_ext[i]), 
                .b_bit(b_ext[i]), 
                .sel(sel[2:0]), 
                .cin(carry[i]), 
                .sum(arith_out[i]), 
                .cout(carry[i+1])
            );
        end
    endgenerate

    //Final Output MUX
    generate
        for(i=0; i<8; i=i+1) begin : out_mux
            mux2x1 m_out (
                .d0(arith_out[i]), 
                .d1(logic_ext[i]), 
                .sel(sel[3]), 
                .y(y[i])
            );
        end
    endgenerate

endmodule