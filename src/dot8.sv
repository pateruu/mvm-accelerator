/***************************************************/
/* ECE 327: Digital Hardware Systems - Spring 2025 */
/* Lab 4                                           */
/* 8-Lane Dot Product Module                       */
/***************************************************/

module dot8 # (
    parameter IWIDTH = 8,
    parameter OWIDTH = 32
)(
    input clk,
    input rst,
    input signed [8*IWIDTH-1:0] vec0,
    input signed [8*IWIDTH-1:0] vec1,
    input ivalid,
    output signed [OWIDTH-1:0] result,
    output ovalid
);

/******* Your code starts here *******/

// internal signals

logic signed [IWIDTH-1:0] a0, a1, a2, a3, a4, a5, a6, a7;
logic signed [IWIDTH-1:0] b0, b1, b2, b3, b4, b5, b6, b7;
logic signed [2*IWIDTH-1:0] r_mul0, r_mul1, r_mul2, r_mul3, r_mul4, r_mul5, r_mul6, r_mul7;
logic signed [2*IWIDTH:0] r0_add0, r0_add1, r0_add2, r0_add3;
logic signed [2*IWIDTH+1:0] r1_add0, r1_add1;
logic signed [2*IWIDTH+2:0] r1p_add0, r1p_add1;
logic signed [OWIDTH-1:0] r2_add0;
logic r_valid0, r_valid1, r_valid2, r_valid3, r_valid4, r_valid5, r_valid6, r_valid7, r_valid8;

// reset and register vector elements

always_ff @(posedge clk) begin
    if (rst) begin
        a0 <= 0; a1 <= 0; a2 <= 0; a3 <= 0; 
        a4 <= 0; a5 <= 0; a6 <= 0; a7 <= 0;
        b0 <= 0; b1 <= 0; b2 <= 0; b3 <= 0; 
        b4 <= 0; b5 <= 0; b6 <= 0; b7 <= 0;
        r_valid0 <= 0;
    end else begin
        a0 <= vec0[8*IWIDTH-1:7*IWIDTH];
        a1 <= vec0[7*IWIDTH-1:6*IWIDTH];
        a2 <= vec0[6*IWIDTH-1:5*IWIDTH];
        a3 <= vec0[5*IWIDTH-1:4*IWIDTH];
        a4 <= vec0[4*IWIDTH-1:3*IWIDTH];
        a5 <= vec0[3*IWIDTH-1:2*IWIDTH];
        a6 <= vec0[2*IWIDTH-1:1*IWIDTH];
        a7 <= vec0[1*IWIDTH-1:0];
        
        b0 <= vec1[8*IWIDTH-1:7*IWIDTH];
        b1 <= vec1[7*IWIDTH-1:6*IWIDTH];
        b2 <= vec1[6*IWIDTH-1:5*IWIDTH];
        b3 <= vec1[5*IWIDTH-1:4*IWIDTH];
        b4 <= vec1[4*IWIDTH-1:3*IWIDTH];
        b5 <= vec1[3*IWIDTH-1:2*IWIDTH];
        b6 <= vec1[2*IWIDTH-1:1*IWIDTH];
        b7 <= vec1[1*IWIDTH-1:0];
        
        r_valid0 <= ivalid;
    end
end

// dsp instantiations
MULT_MACRO #(
    .DEVICE("7SERIES"),
    .LATENCY(4),
    .WIDTH_A(8),
    .WIDTH_B(8)
) MULT_MACRO_inst0 (
    .P(r_mul0), .A(a0), .B(b0),
    .CE(1'b1), .CLK(clk), .RST(rst)
);

MULT_MACRO #(
    .DEVICE("7SERIES"),
    .LATENCY(4),
    .WIDTH_A(8),
    .WIDTH_B(8)
) MULT_MACRO_inst1 (
    .P(r_mul1), .A(a1), .B(b1),
    .CE(1'b1), .CLK(clk), .RST(rst)
);

MULT_MACRO #(
    .DEVICE("7SERIES"),
    .LATENCY(4),
    .WIDTH_A(8),
    .WIDTH_B(8)
) MULT_MACRO_inst2 (
    .P(r_mul2), .A(a2), .B(b2),
    .CE(1'b1), .CLK(clk), .RST(rst)
);

MULT_MACRO #(
    .DEVICE("7SERIES"),
    .LATENCY(4),
    .WIDTH_A(8),
    .WIDTH_B(8)
) MULT_MACRO_inst3 (
    .P(r_mul3), .A(a3), .B(b3),
    .CE(1'b1), .CLK(clk), .RST(rst)
);

MULT_MACRO #(
    .DEVICE("7SERIES"),
    .LATENCY(4),
    .WIDTH_A(8),
    .WIDTH_B(8)
) MULT_MACRO_inst4 (
    .P(r_mul4), .A(a4), .B(b4),
    .CE(1'b1), .CLK(clk), .RST(rst)
);

MULT_MACRO #(
    .DEVICE("7SERIES"),
    .LATENCY(4),
    .WIDTH_A(8),
    .WIDTH_B(8)
) MULT_MACRO_inst5 (
    .P(r_mul5), .A(a5), .B(b5),
    .CE(1'b1), .CLK(clk), .RST(rst)
);

MULT_MACRO #(
    .DEVICE("7SERIES"),
    .LATENCY(4),
    .WIDTH_A(8),
    .WIDTH_B(8)
) MULT_MACRO_inst6 (
    .P(r_mul6), .A(a6), .B(b6),
    .CE(1'b1), .CLK(clk), .RST(rst)
);

MULT_MACRO #(
    .DEVICE("7SERIES"),
    .LATENCY(4),
    .WIDTH_A(8),
    .WIDTH_B(8)
) MULT_MACRO_inst7 (
    .P(r_mul7), .A(a7), .B(b7),
    .CE(1'b1), .CLK(clk), .RST(rst)
);

// adder tree pipelined
always_ff @(posedge clk) begin
    if (rst) begin
        r0_add0 <= 0; r0_add1 <= 0; r0_add2 <= 0; r0_add3 <= 0;
        r1_add0 <= 0; r1_add1 <= 0;
        r1p_add0 <= 0; r1p_add1 <= 0;
        r2_add0 <= 0;
        r_valid1 <= 0; r_valid2 <= 0; r_valid3 <= 0; r_valid4 <= 0; 
        r_valid5 <= 0; r_valid6 <= 0; r_valid7 <= 0; r_valid8 <= 0;
    end else begin

        r_valid1 <= r_valid0;
        r_valid2 <= r_valid1;
        r_valid3 <= r_valid2;
        r_valid4 <= r_valid3;
        
        r0_add0 <= r_mul0 + r_mul1;
        r0_add1 <= r_mul2 + r_mul3;
        r0_add2 <= r_mul4 + r_mul5;
        r0_add3 <= r_mul6 + r_mul7;
        r_valid5 <= r_valid4;

        r1_add0 <= r0_add0 + r0_add1;
        r1_add1 <= r0_add2 + r0_add3;
        r_valid6 <= r_valid5;

        r1p_add0 <= r1_add0;
        r1p_add1 <= r1_add1;
        r_valid7 <= r_valid6;

        r2_add0 <= r1p_add0 + r1p_add1;
        r_valid8 <= r_valid7;
    end
end

// continuous assignment

assign result = r2_add0;
assign ovalid = r_valid8;

/******* Your code ends here ********/

endmodule