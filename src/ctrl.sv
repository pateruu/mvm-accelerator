
/***************************************************/
/* ECE 327: Digital Hardware Systems - Spring 2025 */
/* Lab 4                                           */
/* MVM Control FSM                                 */
/***************************************************/

module ctrl # (
    parameter VEC_ADDRW = 8,
    parameter MAT_ADDRW = 9,
    parameter VEC_SIZEW = VEC_ADDRW + 1,
    parameter MAT_SIZEW = MAT_ADDRW + 1
    
)(
    input  clk,
    input  rst,
    input  start,
    input  [VEC_ADDRW-1:0] vec_start_addr,
    input  [VEC_SIZEW-1:0] vec_num_words,
    input  [MAT_ADDRW-1:0] mat_start_addr,
    input  [MAT_SIZEW-1:0] mat_num_rows_per_olane,
    output [VEC_ADDRW-1:0] vec_raddr,
    output [MAT_ADDRW-1:0] mat_raddr,
    output accum_first,
    output accum_last,
    output ovalid,
    output busy
);

/******* Your code starts here *******/
enum {IDLE, COMPUTE} state, next_state;

logic [VEC_ADDRW-1:0] vec_start_addr_r, vec_raddr_r;
logic [VEC_SIZEW-1:0] vec_num_words_r;
logic [MAT_ADDRW-1:0] mat_start_addr_r, mat_raddr_r;
logic [MAT_SIZEW-1:0] mat_num_rows_per_olane_r;

logic [VEC_SIZEW-1:0] vec_words_remaining;
logic [MAT_SIZEW-1:0] mat_rows_remaining;

logic [VEC_ADDRW-1:0] vec_addr_next;
logic [MAT_ADDRW-1:0] mat_addr_next;
logic [MAT_ADDRW-1:0] mat_row_start_addr;

logic ovalid_r, busy_r;
logic done;

logic accum_first_r [10:0];
logic accum_last_r [10:0];

logic ovalid_w, busy_w;

always_ff @(posedge clk) begin
    if (rst) begin
        vec_start_addr_r <= 0;
        vec_num_words_r <= 0;
        mat_start_addr_r <= 0;
        mat_num_rows_per_olane_r <= 0;
        vec_words_remaining <= 0;
        mat_rows_remaining <= 0;
        vec_addr_next <= 0;
        mat_addr_next <= 0;
        mat_row_start_addr <= 0;
        ovalid_r <= 0;
        busy_r <= 0;
        done <= 0;
        vec_raddr_r <= 0;
        mat_raddr_r <= 0;
        state <= IDLE;
        
        for (int i = 0; i < 11; i++) begin
            accum_first_r[i] <= 0;
            accum_last_r[i] <= 0;
        end
    end else begin
        state <= next_state;

        if (state == IDLE && start) begin
            vec_start_addr_r <= vec_start_addr;
            mat_start_addr_r <= mat_start_addr;
            vec_num_words_r <= vec_num_words;
            mat_num_rows_per_olane_r <= mat_num_rows_per_olane;
            
            vec_words_remaining <= vec_num_words;
            mat_rows_remaining <= mat_num_rows_per_olane;
            
            vec_addr_next <= vec_start_addr;
            mat_addr_next <= mat_start_addr;
            mat_row_start_addr <= mat_start_addr;
            
        end else if (state == COMPUTE) begin
            if (vec_words_remaining == 1) begin
                vec_words_remaining <= vec_num_words_r;
                vec_addr_next <= vec_start_addr_r;
                
                if (mat_rows_remaining == 1) begin
                    mat_rows_remaining <= mat_num_rows_per_olane_r;
                    mat_addr_next <= mat_start_addr_r;
                    mat_row_start_addr <= mat_start_addr_r;
                end else begin
                    mat_rows_remaining <= mat_rows_remaining - 1;
                    mat_addr_next <= mat_row_start_addr + vec_num_words_r;
                    mat_row_start_addr <= mat_row_start_addr + vec_num_words_r;
                end
            end else begin
                vec_words_remaining <= vec_words_remaining - 1;
                vec_addr_next <= vec_addr_next + 1;
                mat_addr_next <= mat_addr_next + 1;
            end
        end

        done <= (state == COMPUTE && vec_words_remaining == 1 && mat_rows_remaining == 1);

        vec_raddr_r <= vec_addr_next;
        mat_raddr_r <= mat_addr_next;
        ovalid_r <= ovalid_w;
        busy_r <= busy_w;

        if (state == COMPUTE) begin
            accum_first_r[0] <= (vec_words_remaining == vec_num_words_r);
            accum_last_r[0] <= (vec_words_remaining == 1);
        end else begin
            accum_first_r[0] <= 0;
            accum_last_r[0] <= 0;
        end
        
        for (int i = 1; i < 11; i++) begin
            accum_first_r[i] <= accum_first_r[i-1];
            accum_last_r[i] <= accum_last_r[i-1];
        end
    end
end

always_comb begin
    case(state)
        IDLE: next_state = start ? COMPUTE : IDLE;
        COMPUTE: next_state = done ? IDLE : COMPUTE;
        default: next_state = IDLE;
    endcase
end

always_comb begin
    ovalid_w = (state == COMPUTE);
    busy_w = (state == COMPUTE);
end

assign vec_raddr = vec_raddr_r;
assign mat_raddr = mat_raddr_r;
assign accum_first = accum_first_r[10];
assign accum_last = accum_last_r[10];
assign ovalid = ovalid_r;
assign busy = busy_r;

/******* Your code ends here ********/

endmodule