/***************************************************/
/* ECE 327: Digital Hardware Systems - Spring 2025 */
/* Lab 4                                           */
/* Accumulator Module                              */
/***************************************************/

module accum # (
    parameter DATAW = 32,
    parameter ACCUMW = 32
)(
    input  clk,
    input  rst,
    input  signed [DATAW-1:0] data,
    input  ivalid,
    input  first,
    input  last,
    output signed [ACCUMW-1:0] result,
    output ovalid
);

/******* Your code starts here *******/

// internal signals

logic signed [ACCUMW-1:0] accum_reg_r;

logic signed [DATAW-1:0] data_r;
logic ivalid_r, first_r, last_r;

logic signed [ACCUMW-1:0] add_result_r;
logic result_valid_r;

logic do_accumulate, do_reset, do_output;

// register inputs
always_ff @(posedge clk) begin
    if (rst) begin
        data_r <= 0;
        ivalid_r <= 0;
        first_r <= 0;
        last_r <= 0;
    end else begin
        data_r <= data;
        ivalid_r <= ivalid;
        first_r <= first;
        last_r <= last;
    end
end

// accumulator conditions
always_comb begin
    do_accumulate = ivalid_r && !first_r;
    do_reset = ivalid_r && first_r;
    do_output = ivalid_r && last_r;
end

// main accumulator logic
always_ff @(posedge clk) begin
    if (rst) begin
        accum_reg_r <= 0;
        add_result_r <= 0;
        result_valid_r <= 0;
    end else begin

        if (do_reset) begin
            accum_reg_r <= {{(ACCUMW-DATAW){data_r[DATAW-1]}}, data_r};
        end else if (do_accumulate) begin
            accum_reg_r <= accum_reg_r + {{(ACCUMW-DATAW){data_r[DATAW-1]}}, data_r};
        end

        if (do_reset) begin
            add_result_r <= {{(ACCUMW-DATAW){data_r[DATAW-1]}}, data_r};
        end else begin
            add_result_r <= accum_reg_r + {{(ACCUMW-DATAW){data_r[DATAW-1]}}, data_r};
        end

        result_valid_r <= do_output;
    end
end

// continuous assignment
assign result = add_result_r;
assign ovalid = result_valid_r;

/******* Your code ends here ********/

endmodule