/***************************************************/
/* ECE 327: Digital Hardware Systems - Spring 2025 */
/* Lab 4                                           */
/* Matrix Vector Multiplication (MVM) Module       */
/***************************************************/

module mvm # (
    parameter IWIDTH = 8,
    parameter OWIDTH = 32,
    parameter MEM_DATAW = IWIDTH * 8,
    parameter VEC_MEM_DEPTH = 256,
    parameter VEC_ADDRW = $clog2(VEC_MEM_DEPTH),
    parameter MAT_MEM_DEPTH = 512,
    parameter MAT_ADDRW = $clog2(MAT_MEM_DEPTH),
    parameter NUM_OLANES = 27
)(
    input clk,
    input rst,
    input [MEM_DATAW-1:0] i_vec_wdata,
    input [VEC_ADDRW-1:0] i_vec_waddr,
    input i_vec_wen,
    input [MEM_DATAW-1:0] i_mat_wdata,
    input [MAT_ADDRW-1:0] i_mat_waddr,
    input [NUM_OLANES-1:0] i_mat_wen,
    input i_start,
    input [VEC_ADDRW-1:0] i_vec_start_addr,
    input [VEC_ADDRW:0] i_vec_num_words,
    input [MAT_ADDRW-1:0] i_mat_start_addr,
    input [MAT_ADDRW:0] i_mat_num_rows_per_olane,
    output o_busy,
    output [OWIDTH-1:0] o_result [0:NUM_OLANES-1],
    output o_valid
);

/******* Your code starts here *******/

// internal signals

logic [MEM_DATAW-1:0] vec_rdata;
logic [MEM_DATAW-1:0] mat_rdata [NUM_OLANES-1:0];
logic [OWIDTH-1:0] dot8_result [NUM_OLANES-1:0];
logic ovalid_mvm [NUM_OLANES-1:0];
logic [OWIDTH-1:0] accum_result [NUM_OLANES-1:0];
logic ovalid_accum [NUM_OLANES-1:0];

logic [VEC_ADDRW-1:0] vec_raddr;
logic [MAT_ADDRW-1:0] mat_raddr;
logic accum_first, accum_last, ctrl_ovalid;

// ctrl fsm and vector memory instantiation

ctrl # (
    .VEC_ADDRW(VEC_ADDRW), 
    .MAT_ADDRW(MAT_ADDRW), 
    .VEC_SIZEW(VEC_ADDRW+1), 
    .MAT_SIZEW(MAT_ADDRW+1)
) ctrl_inst (
    .clk(clk),
    .rst(rst),
    .start(i_start),
    .vec_start_addr(i_vec_start_addr),
    .vec_num_words(i_vec_num_words),
    .mat_start_addr(i_mat_start_addr),
    .mat_num_rows_per_olane(i_mat_num_rows_per_olane),
    .vec_raddr(vec_raddr),
    .mat_raddr(mat_raddr),
    .accum_first(accum_first),
    .accum_last(accum_last),
    .ovalid(ctrl_ovalid),
    .busy(o_busy) 
);

mem # (
    .DATAW(MEM_DATAW), 
    .DEPTH(VEC_MEM_DEPTH), 
    .ADDRW(VEC_ADDRW)
) vec_mem (
    .clk(clk),
    .wdata(i_vec_wdata),
    .waddr(i_vec_waddr),
    .wen(i_vec_wen),
    .raddr(vec_raddr),
    .rdata(vec_rdata)
);

// generating matrix memory, dot product, and accumulator modules

genvar i;
generate
for (i = 0; i < NUM_OLANES; i = i + 1) begin : compute_lane
    mem # (
        .DATAW(MEM_DATAW), 
        .DEPTH(MAT_MEM_DEPTH), 
        .ADDRW(MAT_ADDRW)
    ) matrix_mem (
        .clk(clk),
        .wdata(i_mat_wdata),
        .waddr(i_mat_waddr),
        .wen(i_mat_wen[i]),
        .raddr(mat_raddr),
        .rdata(mat_rdata[i])
    );
    
    dot8 # (
        .IWIDTH(IWIDTH), 
        .OWIDTH(OWIDTH)
    ) dot8_inst (
        .clk(clk),
        .rst(rst),
        .vec0(vec_rdata),
        .vec1(mat_rdata[i]),
        .ivalid(ctrl_ovalid),
        .result(dot8_result[i]),
        .ovalid(ovalid_mvm[i])
    );
    
    accum # (
        .DATAW(OWIDTH), 
        .ACCUMW(OWIDTH)
    ) accum_inst (
        .clk(clk),
        .rst(rst),
        .data(dot8_result[i]),
        .ivalid(ovalid_mvm[i]),
        .first(accum_first),
        .last(accum_last),
        .result(accum_result[i]),
        .ovalid(ovalid_accum[i])
    );
    // assigning all results
    assign o_result[i] = accum_result[i];
end
endgenerate

// continous assignments
assign o_valid = ovalid_accum[0];

/******* Your code ends here ********/
endmodule