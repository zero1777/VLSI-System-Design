`define init 8'd0 
`define set1 8'd1
`define set2_get1 8'd2
`define set3_get2 8'd3
`define set4_get3 8'd4
`define get4 8'd5
`define dummy1 8'd6
`define dummy2 8'd7
`define loop1 8'd8
`define loop2 8'd9
`define loop3 8'd10
`define loop4 8'd11
`define wait_to_finish 8'd41
`define last 8'd42
`define done 8'd43

`define clk1 8'd12
`define clk2 8'd13
`define clk3 8'd14
`define clk4 8'd15
`define clk5 8'd16
`define clk6 8'd17
`define clk7 8'd18
`define stl1 8'd22
`define stl2 8'd23
`define idle 8'd24
`define send1 8'd25
`define send2 8'd26
`define send3 8'd27
`define send4 8'd28
`define send5 8'd29
`define send6 8'd30
`define send7 8'd31
`define send8 8'd32
`define send9 8'd33
`define send10 8'd34
`define send11 8'd35
`define send12 8'd36
`define send13 8'd37
`define send14 8'd38
`define send15 8'd39
`define send16 8'd40

`define fc 1'b0
`define conv 1'b1


module top (
    input clk,
    input rst_n,
    input valid,
    input conv,
    output reg Wait,
    output reg Ready,
    output reg [15:0] input_addr,
    input [31:0] input_rdata,
    output reg [15:0] weight_addr,
    input [31:0] weight_rdata,
    output reg output_wen,
    output reg [15:0] output_addr,
    input signed [31:0] output_rdata,
    output reg signed [31:0] output_wdata,
    input [31:0] N,
    input [31:0] C,
    input [31:0] H,
    input [31:0] W,
    input [31:0] R,
    input [31:0] S,
    input [31:0] M,
    input [31:0] P,
    input [31:0] Q
);

// state 
reg [7:0] state, next_state;

// 8 buffer -> 4 row & 4 col
reg signed [31:0] next_row1_buf, next_row2_buf, next_row3_buf, next_row4_buf; 
reg signed [31:0] row1_buf, row2_buf, row3_buf, row4_buf; 
reg signed [31:0] next_col1_buf, next_col2_buf, next_col3_buf, next_col4_buf; 
reg signed [31:0] col1_buf, col2_buf, col3_buf, col4_buf; 
reg [15:0] output_addr_, next_output_addr;

// output data storage
reg signed [31:0] sa1, sa2, sa3, sa4, sa5, sa6, sa7, sa8, sa9, sa10, sa11, sa12, sa13, sa14, sa15, sa16;
reg signed [31:0] next_sa1, next_sa2, next_sa3, next_sa4, next_sa5, next_sa6, next_sa7, next_sa8, next_sa9, next_sa10, next_sa11, next_sa12, next_sa13, next_sa14, next_sa15, next_sa16;
wire signed [31:0] _sa1, _sa2, _sa3, _sa4, _sa5, _sa6, _sa7, _sa8, _sa9, _sa10, _sa11, _sa12, _sa13, _sa14, _sa15, _sa16;

// cnt for input & weight
// cnt for channel 
// num of weight kernel
reg [15:0] ch, next_ch;
reg [15:0] ip_r, ip_c, next_ip_r, next_ip_c; 
reg [15:0] wt_r, wt_c, next_wt_r, next_wt_c, wt_num, next_wt_num;

// output w state
reg [7:0] opw_state, next_opw_state;

// first round
reg [5:0] first_round, next_first_round;

    // -----------------------------------------------------------------------------------
    // flag
    reg flag, next_flag;
    always @(*) begin
        next_flag = flag;
        if (state == `loop4) begin
            next_flag = 1;
        end
    end
    always @(posedge clk, negedge rst_n) begin
        if (rst_n == 0) begin
            flag = 0;
        end
        else begin
            flag = next_flag;
        end
    end

    // -----------------------------------------------------------------------------------

    // row1 buffer
    always @(*) begin
        if (state == `set2_get1 || state == `loop2) begin
            if (conv == `conv) begin
                if (ip_c == 16'd24) begin
                    next_row1_buf = {24'd0, input_rdata[7:0]};
                end
                else begin
                    next_row1_buf = input_rdata;
                end
            end
            else begin
                next_row1_buf = input_rdata;
            end
        end
        else if (state == `dummy1 || state == `dummy2 || state == `loop1
        || state == `loop3 || state == `loop4 || opw_state == `stl1) begin
            next_row1_buf = {8'b00000000, row1_buf[31:8]};
        end
        else begin
            next_row1_buf = row1_buf;
        end
    end

    // row2 buffer
    always @(*) begin
        if (state == `set3_get2 || state == `loop3) begin
            if (conv == `conv) begin
                if (ip_c == 16'd24) begin
                    next_row2_buf = {24'd0, input_rdata[7:0]};
                end
                else begin
                    next_row2_buf = input_rdata;
                end
            end
            else begin
                next_row2_buf = input_rdata;
            end
        end
        else if (state == `dummy2 || state == `loop1
        || state == `loop2 || state == `loop4 || opw_state == `stl1 || opw_state == `stl2) begin
            next_row2_buf = {8'b00000000, row2_buf[31:8]};
        end
        else begin
            next_row2_buf = row2_buf;
        end
    end

    // row3 buffer
    always @(*) begin
        if (state == `set4_get3 || state == `loop4) begin
            if (conv == `conv) begin
                if (ip_c == 16'd24) begin
                    next_row3_buf = {24'd0, input_rdata[7:0]};
                end
                else begin
                    next_row3_buf = input_rdata;
                end
            end
            else begin
                next_row3_buf = input_rdata;
            end
        end
        else if (state == `loop1 || state == `loop2 || state == `loop3 || opw_state == `stl1 || opw_state == `stl2 || opw_state == `clk1) begin
            next_row3_buf = {8'b00000000, row3_buf[31:8]};
        end
        else begin
            next_row3_buf = row3_buf;
        end
    end

    // row4 buffer
    always @(*) begin
        if (state == `get4 || (state == `loop1 && flag == 1) || opw_state == `stl1) begin
            if (conv == `conv) begin
                if (ip_c == 16'd0) begin
                    next_row4_buf = {24'd0, input_rdata[7:0]};
                end
                else begin
                    next_row4_buf = input_rdata;
                end
            end
            else begin
                next_row4_buf = input_rdata;
            end
        end
        else if (state == `loop2 || state == `loop3 || state == `loop4 || opw_state == `clk2 || opw_state == `stl2 || opw_state == `clk1) begin
            next_row4_buf = {8'b00000000, row4_buf[31:8]};
        end
        else begin
            next_row4_buf = row4_buf;
        end
    end

    // col1 buffer
    always @(*) begin
        if (state == `set2_get1 || state == `loop2) begin
            if (conv == `conv) begin
                if (wt_r == 16'd24) begin
                    next_col1_buf = {24'd0, weight_rdata[7:0]};
                end
                else begin
                    next_col1_buf = weight_rdata;
                end
            end
            else begin
                next_col1_buf = weight_rdata;
            end
        end
        else if (state == `dummy1 || state == `dummy2 || state == `loop1
        || state == `loop3 || state == `loop4 || opw_state == `stl1) begin
            next_col1_buf = {8'b00000000, col1_buf[31:8]};
        end
        else begin
            next_col1_buf = col1_buf;
        end
    end

    // col2 buffer
    always @(*) begin
        if (state == `set3_get2 || state == `loop3) begin
            if (conv == `conv) begin
                if (wt_r == 16'd24) begin
                    next_col2_buf = {24'd0, weight_rdata[7:0]};
                end
                else begin
                    next_col2_buf = weight_rdata;
                end
            end
            else begin
                next_col2_buf = weight_rdata;
            end
        end
        else if (state == `dummy2 || state == `loop1
        || state == `loop2 || state == `loop4 || opw_state == `stl1 || opw_state == `stl2) begin
            next_col2_buf = {8'b00000000, col2_buf[31:8]};
        end
        else begin
            next_col2_buf = col2_buf;
        end
    end

    // col3 buffer
    always @(*) begin
        if (state == `set4_get3 || state == `loop4) begin
            if (conv == `conv) begin
                if (wt_r == 16'd24) begin
                    next_col3_buf = {24'd0, weight_rdata[7:0]};
                end
                else begin
                    next_col3_buf = weight_rdata;
                end
            end
            else begin
                next_col3_buf = weight_rdata;
            end
        end
        else if (state == `loop1 || state == `loop2 || state == `loop3 || opw_state == `stl1 || opw_state == `stl2 || opw_state == `clk1) begin
            next_col3_buf = {8'b00000000, col3_buf[31:8]};
        end
        else begin
            next_col3_buf = col3_buf;
        end
    end

    // col4 buffer
    always @(*) begin
        if (state == `get4 || (state == `loop1 && flag == 1) || opw_state == `stl1) begin
            if (conv == `conv) begin
                if (wt_r == 16'd0) begin
                    next_col4_buf = {24'd0, weight_rdata[7:0]};
                end
                else begin
                    next_col4_buf = weight_rdata;
                end
            end
            else begin
                next_col4_buf = weight_rdata;
            end
        end
        else if (state == `loop2 || state == `loop3 || state == `loop4 || opw_state == `clk2 || opw_state == `stl2 || opw_state == `clk1) begin
            next_col4_buf = {8'b00000000, col4_buf[31:8]};
        end
        else begin
            next_col4_buf = col4_buf;
        end
    end

    // sequential 
    always @(posedge clk, negedge rst_n) begin
        if (rst_n == 0) begin
            row1_buf = 32'd0;
            col1_buf = 32'd0;
            row2_buf = 32'd0;
            col2_buf = 32'd0;
            row3_buf = 32'd0;
            col3_buf = 32'd0;
            row4_buf = 32'd0;
            col4_buf = 32'd0;
        end
        else begin
            row1_buf = next_row1_buf;
            col1_buf = next_col1_buf;
            row2_buf = next_row2_buf;
            col2_buf = next_col2_buf;
            row3_buf = next_row3_buf;
            col3_buf = next_col3_buf;
            row4_buf = next_row4_buf;
            col4_buf = next_col4_buf;
        end
    end
    // ----------------------------------------------------------------------

    // input address
    always @(*) begin
        input_addr = 16'd0;
        if (conv == `conv) begin
            case (state)
                `set1: begin
                    input_addr = ch * H * W + ip_r * W + ip_c;
                end 
                `set2_get1: begin
                    input_addr = ch * H * W + ip_r * W + ip_c + W;
                end
                `set3_get2: begin
                    input_addr = ch * H * W + ip_r * W + ip_c + 2 * W;
                end
                `set4_get3: begin
                    input_addr = ch * H * W + ip_r * W + ip_c + 3 * W;
                end
                `loop1: begin
                    input_addr = ch * H * W + ip_r * W + ip_c;
                end
                `loop2: begin
                    input_addr = ch * H * W + ip_r * W + ip_c + W;
                end
                `loop3: begin
                    input_addr = ch * H * W + ip_r * W + ip_c + 2 * W;
                end
                `loop4: begin
                    input_addr = ch * H * W + ip_r * W + ip_c + 3 * W;
                end
            endcase
        end
        else begin // fc
            case (state)
                `set1: begin
                    input_addr = ip_r;
                end 
                `set2_get1: begin
                    input_addr = ip_r;
                end
                `set3_get2: begin
                    input_addr = ip_r;
                end
                `set4_get3: begin
                    input_addr = ip_r;
                end
                `loop1: begin
                    input_addr = ip_r;
                end
                `loop2: begin
                    input_addr = ip_r;
                end
                `loop3: begin
                    input_addr = ip_r;
                end
                `loop4: begin
                    input_addr = ip_r;
                end
            endcase
        end
    end

    // -----------------------------------------------------------------------

    // weight address
    always @(*) begin
        weight_addr = 16'd0;
        if (conv == `conv) begin
            case (state)
                `set1: begin
                    weight_addr = wt_num * C * R + ch * R + wt_r;
                end 
                `set2_get1: begin
                    weight_addr = wt_num * C * R + ch * R + wt_r + C * R;
                end
                `set3_get2: begin
                    weight_addr = wt_num * C * R + ch * R + wt_r + 2 * C * R;
                end
                `set4_get3: begin
                    weight_addr = wt_num * C * R + ch * R + wt_r + 3 * C * R;
                end
                `loop1: begin
                    weight_addr = wt_num * C * R + ch * R + wt_r;
                end 
                `loop2: begin
                    weight_addr = wt_num * C * R + ch * R + wt_r + C * R;
                end
                `loop3: begin
                    weight_addr = wt_num * C * R + ch * R + wt_r + 2 * C * R;
                end
                `loop4: begin
                    weight_addr = wt_num * C * R + ch * R + wt_r + 3 * C * R;
                end
            endcase
        end
        else begin
            case (state)
                `set1: begin
                    weight_addr = wt_r * S + wt_c;
                end 
                `set2_get1: begin
                    weight_addr = wt_r * S + wt_c + S;
                end
                `set3_get2: begin
                    weight_addr = wt_r * S + wt_c + 2 * S;
                end
                `set4_get3: begin
                    weight_addr = wt_r * S + wt_c + 3 * S;
                end
                `loop1: begin
                    weight_addr = wt_r * S + wt_c;
                end 
                `loop2: begin
                    weight_addr = wt_r * S + wt_c + S;
                end
                `loop3: begin
                    weight_addr = wt_r * S + wt_c + 2 * S;
                end
                `loop4: begin
                    weight_addr = wt_r * S + wt_c + 3 * S;
                end
            endcase
        end
    end

    // -----------------------------------------------------------------------

    // output address
    always @(*) begin
        next_output_addr = output_addr;
        if (conv == `conv) begin
            case (opw_state)
                `send1, `send2, `send3, `send5, `send6, `send7, 
                `send9, `send10, `send11, `send13, `send14, `send15: begin
                    next_output_addr = output_addr + H;
                end 
                `send4, `send8, `send12, `send16: begin
                    if (output_addr == 16'd399 || output_addr == 16'd799 || output_addr == 16'd1199) begin
                        next_output_addr = output_addr + 1;
                    end
                    else begin
                        next_output_addr = output_addr - 3 * H + 1;
                    end
                end
            endcase
        end
        else begin 
            if (opw_state == `send1 || opw_state == `send6 || opw_state == `send11 || opw_state == `send16) begin
                next_output_addr = output_addr + 1;
            end
            else begin
                next_output_addr = output_addr;
            end
        end
    end
    // sequential
    always @(posedge clk, negedge rst_n) begin
        if (rst_n == 0) begin
            output_addr = 16'd0;
        end
        else begin
            output_addr = next_output_addr;
        end
    end

    // ------------------------------------------------------------------------


    // output wen
    always @(*) begin
        output_wen = 0;
        case (opw_state) 
            `send1, `send2, `send3, `send4, `send5, `send6, `send7, `send8, `send9, `send10, 
            `send11, `send12, `send13, `send14, `send15, `send16: begin
                output_wen = 1;    
            end 
        endcase
    end

    // -------------------------------------------------------------------------


    // --- state ---
    // combinational 
    always @(*) begin
        next_state = state;
        next_ch = ch;
        next_ip_r = ip_r;
        next_ip_c = ip_c;
        next_wt_r = wt_r;
        next_wt_c = wt_c;
        next_wt_num = wt_num;
        case (state)
            `init: begin
                next_state = `set1;
                next_ch = 16'd0;
                next_ip_r = 16'd0;
                next_ip_c = 16'd0;
                next_wt_r = 16'd0;
                next_wt_c = 16'd0;
                next_wt_num = 16'd0;
            end
            `set1: begin
                next_state = `set2_get1;
            end
            `set2_get1: begin // get 1
                next_state = `set3_get2;
            end
            `set3_get2: begin // get 2
                next_state = `set4_get3;
            end
            `set4_get3: begin // get 3
                next_state = `get4;
                if (conv == `conv) begin
                    next_ip_c = ip_c + 16'd4;
                    next_wt_r = wt_r + 16'd4;
                end
                else begin
                    next_ip_r = ip_r + 16'd4;
                    next_wt_c = wt_c + 16'd4;
                end
            end
            `get4: begin
                next_state = `dummy1;
            end
            `dummy1: begin
                next_state = `dummy2;
            end
            `dummy2: begin
                next_state = `loop1;
            end
            `loop1: begin
                next_state = `loop2;
            end
            `loop2: begin
                next_state = `loop3;
            end
            `loop3: begin
                next_state = `loop4;
            end
            `loop4: begin
                if (conv == `conv) begin
                    if (ip_c + 4 < W) begin
                        next_ch = ch;
                        next_ip_r = ip_r;
                        next_ip_c = ip_c + 16'd4;
                        next_wt_r = wt_r + 16'd4;
                        next_state = `loop1;
                    end
                    else begin
                        if (ch == C - 1) begin
                            if (ip_r + 4 < H) begin
                                next_ip_r = ip_r + 16'd4;
                                next_ip_c = 16'd0;
                                next_ch = 16'd0;
                                next_wt_r = 16'd0;
                                next_wt_num = wt_num;
                                next_state = `loop1;
                            end
                            else begin
                                if (wt_num + 4 < M) begin
                                    next_ip_r = 16'd0;
                                    next_ip_c = 16'd0;
                                    next_ch = 16'd0;
                                    next_wt_r = 16'd0;
                                    next_wt_num = wt_num + 16'd4;
                                    next_state = `loop1;
                                end
                                else begin
                                    // next_ip_r = 16'd0;
                                    next_ip_c = 16'd0;
                                    next_ch = 16'd0;
                                    next_wt_r = 16'd0;
                                    // next_wt_num = wt_num + 16'd4;
                                    next_state = `wait_to_finish;
                                end
                            end
                        end
                        else begin
                            next_ip_r = ip_r;
                            next_ip_c = 16'd0;
                            next_ch = ch + 16'd1;
                            next_wt_r = 16'd0;
                            next_state = `loop1;
                        end
                    end
                end
                else begin // fc
                    if (ip_r + 4 < H) begin
                        next_ip_r = ip_r + 16'd4;
                        next_wt_c = wt_c + 16'd4;
                        next_wt_r = wt_r;
                        next_state = `loop1;
                    end
                    else begin
                        if (wt_r + 4 < R) begin
                            next_ip_r = 16'd0;
                            next_wt_c = 16'd0;
                            next_wt_r = wt_r + 16'd4;
                            next_state = `loop1;
                        end
                        else begin
                            // next_ip_r = 16'd0;
                            // next_wt_c = 16'd0;
                            // next_wt_r = wt_r + 16'd4;
                            next_state = `wait_to_finish;
                        end
                    end
                end
            end
            `wait_to_finish: begin
                if (opw_state == `send16) begin
                    next_state = `last;
                end
            end
            `last: begin
                next_state = `done;
            end
        endcase
    end

    // output write data state
    always @(*) begin
        next_opw_state = opw_state;
        case (opw_state)
            `idle: begin
                if (state == `loop4) begin
                    if (conv == `conv) begin
                        if (ip_c + 4 >= W) begin
                            if (ch == C - 1) begin
                                next_opw_state = `stl1;
                            end
                        end
                    end
                    else begin // fc
                        if (ip_r + 4 >= H) begin
                            next_opw_state = `stl1;
                        end
                    end
                end
            end 
            `stl1: begin
                next_opw_state = `stl2;
            end
            `stl2: begin
                next_opw_state = `clk1;
            end
            `clk1: begin
                next_opw_state = `clk2;
            end
            `clk2: begin
                next_opw_state = `clk3;
            end
            `clk3: begin
                next_opw_state = `clk4;
            end
            `clk4: begin
                next_opw_state = `clk5;
            end
            `clk5: begin
                next_opw_state = `clk6;
            end
            `clk6: begin
                next_opw_state = `clk7;
            end
            `clk7: begin
                next_opw_state = `send1;
            end
            `send1: begin
                if (conv == `conv) next_opw_state = `send2;
                else next_opw_state = `send6;
            end
            `send2: begin
                next_opw_state = `send3;
            end
            `send3: begin
                next_opw_state = `send4;
            end
            `send4: begin
                next_opw_state = `send5;
            end
            `send5: begin
                next_opw_state = `send6;
            end
            `send6: begin
                if (conv == `conv) next_opw_state = `send7;
                else next_opw_state = `send11;
            end
            `send7: begin
                next_opw_state = `send8;
            end
            `send8: begin
                next_opw_state = `send9;
            end
            `send9: begin
                next_opw_state = `send10;
            end
            `send10: begin
                next_opw_state = `send11;
            end
            `send11: begin
                if (conv == `conv) next_opw_state = `send12;
                else next_opw_state = `send16;
            end
            `send12: begin
                next_opw_state = `send13;
            end
            `send13: begin
                next_opw_state = `send14;
            end
            `send14: begin
                next_opw_state = `send15;
            end
            `send15: begin
                next_opw_state = `send16;
            end
            `send16: begin
                next_opw_state = `idle;
            end
        endcase
    end

    // sequential
    always @(posedge clk, negedge rst_n) begin
        if (rst_n == 0) begin
            state = `init;
            opw_state = `idle;
            ch = 16'd0;
            ip_r = 16'd0;
            ip_c = 16'd0;
            wt_r = 16'd0;
            wt_c = 16'd0;
            wt_num = 16'd0;
        end
        else begin
            state = next_state;
            opw_state = next_opw_state;
            ch = next_ch;
            ip_r = next_ip_r;
            ip_c = next_ip_c;
            wt_r = next_wt_r;
            wt_c = next_wt_c;
            wt_num = next_wt_num;
        end
    end



// -------------------------------------------------------
    // ready & wait
    always @(*) begin
        if (state == `done) begin
            Ready = 1;
            Wait = 1;
        end
        else begin
            Ready = 0;
            Wait = 0;
        end
    end

// -------------------------------------------------------
    // first round
    always @(*) begin
        if (state == `get4 || opw_state == `stl2) begin
            next_first_round = 6'd1;
        end
        else begin
            if (first_round == 6'd8) begin
                next_first_round = first_round;
            end
            else begin
                next_first_round = first_round + 6'd1;
            end
        end
    end
    always @(posedge clk, negedge rst_n) begin
        if (rst_n == 0) begin
            first_round = 6'd0;
        end
        else begin
            first_round = next_first_round;
        end
    end

// -------------------------------------------------------
SA systolic_array(
.clk(clk), .rst_n(rst_n), .first_round(first_round),
.r1(row1_buf[7:0]), .r2(row2_buf[7:0]), .r3(row3_buf[7:0]), .r4(row4_buf[7:0]),
.c1(col1_buf[7:0]), .c2(col2_buf[7:0]), .c3(col3_buf[7:0]), .c4(col4_buf[7:0]),
.sa1(_sa1), .sa2(_sa2), .sa3(_sa3), .sa4(_sa4), .sa5(_sa5), .sa6(_sa6), .sa7(_sa7), .sa8(_sa8),
.sa9(_sa9), .sa10(_sa10), .sa11(_sa11), .sa12(_sa12), .sa13(_sa13), .sa14(_sa14), .sa15(_sa15), .sa16(_sa16)
);

    always @(*) begin
        next_sa1 = sa1;
        next_sa2 = sa2;
        next_sa3 = sa3;
        next_sa4 = sa4;
        next_sa5 = sa5;
        next_sa6 = sa6;
        next_sa7 = sa7;
        next_sa8 = sa8;
        next_sa9 = sa9;
        next_sa10 = sa10;
        next_sa11 = sa11;
        next_sa12 = sa12;
        next_sa13 = sa13;
        next_sa14 = sa14;
        next_sa15 = sa15;
        next_sa16 = sa16;
        case (opw_state)
            `clk1: begin
                next_sa1 = _sa1;
            end 
            `clk2: begin
                next_sa2 = _sa2;
                next_sa5 = _sa5;
            end 
            `clk3: begin
                next_sa3 = _sa3;
                next_sa6 = _sa6;
                next_sa9 = _sa9;
            end 
            `clk4: begin
                next_sa4 = _sa4;
                next_sa7 = _sa7;
                next_sa10 = _sa10;
                next_sa13 = _sa13;
            end 
            `clk5: begin
                next_sa8 = _sa8;
                next_sa11 = _sa11;
                next_sa14 = _sa14;
            end 
            `clk6: begin
                next_sa12 = _sa12;
                next_sa15 = _sa15;
            end 
            `clk7: begin
                next_sa16 = _sa16;
            end  
        endcase
    end

    always @(posedge clk, negedge rst_n) begin
        if (rst_n == 0) begin
            sa1 = 32'd0;
            sa2 = 32'd0;
            sa3 = 32'd0;
            sa4 = 32'd0;
            sa5 = 32'd0;
            sa6 = 32'd0;
            sa7 = 32'd0;
            sa8 = 32'd0;
            sa9 = 32'd0;
            sa10 = 32'd0;
            sa11 = 32'd0;
            sa12 = 32'd0;
            sa13 = 32'd0;
            sa14 = 32'd0;
            sa15 = 32'd0;
            sa16 = 32'd0;
        end
        else begin
            sa1 = next_sa1;
            sa2 = next_sa2;
            sa3 = next_sa3;
            sa4 = next_sa4;
            sa5 = next_sa5;
            sa6 = next_sa6;
            sa7 = next_sa7;
            sa8 = next_sa8;
            sa9 = next_sa9;
            sa10 = next_sa10;
            sa11 = next_sa11;
            sa12 = next_sa12;
            sa13 = next_sa13;
            sa14 = next_sa14;
            sa15 = next_sa15;
            sa16 = next_sa16;
        end
    end

// ----------------------------------------------------------

    // output_wdata TODO
    always @(*) begin
        output_wdata = 32'd0;
        case (opw_state)
            `send1: begin
                output_wdata = sa1;
            end
            `send2: begin
                output_wdata = sa2;
            end
            `send3: begin
                output_wdata = sa3;
            end
            `send4: begin
                output_wdata = sa4;
            end
            `send5: begin
                output_wdata = sa5;
            end
            `send6: begin
                output_wdata = sa6;
            end
            `send7: begin
                output_wdata = sa7;
            end
            `send8: begin
                output_wdata = sa8;
            end
            `send9: begin
                output_wdata = sa9;
            end
            `send10: begin
                output_wdata = sa10;
            end
            `send11: begin
                output_wdata = sa11;
            end
            `send12: begin
                output_wdata = sa12;
            end
            `send13: begin
                output_wdata = sa13;
            end
            `send14: begin
                output_wdata = sa14;
            end
            `send15: begin
                output_wdata = sa15;
            end
            `send16: begin
                output_wdata = sa16;
            end
        endcase
    end
endmodule

module SA (
    clk, rst_n, first_round, r1, r2, r3, r4, c1, c2, c3, c4,
    sa1, sa2, sa3, sa4, sa5, sa6, sa7, sa8, sa9, sa10, sa11, sa12, sa13,
    sa14, sa15, sa16
);

input clk;
input rst_n;
input [5:0] first_round;
input signed [7:0] r1, r2, r3, r4;
input signed [7:0] c1, c2, c3, c4;

// systolic array stored value
output reg signed [31:0] sa1, sa2, sa3, sa4, sa5, sa6, sa7, sa8, sa9, sa10, sa11, sa12, sa13, sa14, sa15, sa16;
reg signed [31:0] next_sa1, next_sa2, next_sa3, next_sa4, next_sa5, next_sa6, next_sa7, next_sa8, next_sa9, next_sa10, next_sa11, next_sa12, next_sa13, next_sa14, next_sa15, next_sa16;

// systolic array output (row & column)
reg signed [7:0] sa1_r, sa1_c, sa2_r, sa2_c, sa3_r, sa3_c, sa4_r, sa4_c, sa5_r, sa5_c, sa6_r, sa6_c, sa7_r, sa7_c, sa8_r, sa8_c;
reg signed [7:0] sa9_r, sa9_c, sa10_r, sa10_c, sa11_r, sa11_c, sa12_r, sa12_c, sa13_r, sa13_c, sa14_r, sa14_c, sa15_r, sa15_c, sa16_r, sa16_c;
reg signed [7:0] next_sa1_r, next_sa1_c, next_sa2_r, next_sa2_c, next_sa3_r, next_sa3_c, next_sa4_r, next_sa4_c, next_sa5_r, next_sa5_c, next_sa6_r, next_sa6_c, next_sa7_r, next_sa7_c, next_sa8_r, next_sa8_c;
reg signed [7:0] next_sa9_r, next_sa9_c, next_sa10_r, next_sa10_c, next_sa11_r, next_sa11_c, next_sa12_r, next_sa12_c, next_sa13_r, next_sa13_c, next_sa14_r, next_sa14_c, next_sa15_r, next_sa15_c, next_sa16_r, next_sa16_c;

    // combinational
    always @(*) begin
        // sa1
        next_sa1_r = r1;
        next_sa1_c = c1;
        if (first_round == 6'd1) begin
            next_sa1 = r1 * c1;
        end
        else begin
            next_sa1 = sa1 + r1 * c1;
        end

        // sa2
        next_sa2_r = sa1_r;
        next_sa2_c = c2;
        if (first_round == 6'd2) begin
            next_sa2 = sa1_r * c2;
        end
        else begin
            next_sa2 = sa2 + sa1_r * c2;
        end

        // sa3
        next_sa3_r = sa2_r;
        next_sa3_c = c3;
        if (first_round == 6'd3) begin
            next_sa3 = sa2_r * c3;
        end
        else begin
            next_sa3 = sa3 + sa2_r * c3;
        end
        

        // sa4
        next_sa4_r = sa3_r;
        next_sa4_c = c4;
        if (first_round == 6'd4) begin
            next_sa4 = sa3_r * c4;
        end
        else begin
            next_sa4 = sa4 + sa3_r * c4;
        end
        

        // sa5
        next_sa5_r = r2;
        next_sa5_c = sa1_c;
        if (first_round == 6'd2) begin
            next_sa5 = r2 * sa1_c;
        end
        else begin
            next_sa5 = sa5 + r2 * sa1_c;
        end
        

        // sa6
        next_sa6_r = sa5_r;
        next_sa6_c = sa2_c;
        if (first_round == 6'd3) begin
            next_sa6 = sa5_r * sa2_c;
        end
        else begin
            next_sa6 = sa6 + sa5_r * sa2_c;
        end
        

        // sa7
        next_sa7_r = sa6_r;
        next_sa7_c = sa3_c;
        if (first_round == 6'd4) begin
            next_sa7 = sa6_r * sa3_c;
        end
        else begin
            next_sa7 = sa7 + sa6_r * sa3_c;
        end    

        // sa8
        next_sa8_r = sa7_r;
        next_sa8_c = sa4_c;
        if (first_round == 6'd5) begin
            next_sa8 = sa7_r * sa4_c;
        end
        else begin
            next_sa8 = sa8 + sa7_r * sa4_c;
        end

        // sa9
        next_sa9_r = r3;
        next_sa9_c = sa5_c;
        if (first_round == 6'd3) begin
            next_sa9 = r3 * sa5_c;
        end
        else begin
            next_sa9 = sa9 + r3 * sa5_c;
        end

        // sa10
        next_sa10_r = sa9_r;
        next_sa10_c = sa6_c;
        if (first_round == 6'd4) begin
            next_sa10 = sa9_r * sa6_c;
        end
        else begin
            next_sa10 = sa10 + sa9_r * sa6_c;
        end

        // sa11
        next_sa11_r = sa10_r;
        next_sa11_c = sa7_c;
        if (first_round == 6'd5) begin
            next_sa11 = sa10_r * sa7_c;
        end
        else begin
            next_sa11 = sa11 + sa10_r * sa7_c;
        end

        // sa12
        next_sa12_r = sa11_r;
        next_sa12_c = sa8_c;
        if (first_round == 6'd6) begin
            next_sa12 = sa11_r * sa8_c;
        end
        else begin
            next_sa12 = sa12 + sa11_r * sa8_c;
        end

        // sa13
        next_sa13_r = r4;
        next_sa13_c = sa9_c;
        if (first_round == 6'd4) begin
            next_sa13 = r4 * sa9_c;
        end
        else begin
            next_sa13 = sa13 + r4 * sa9_c;
        end

        // sa14
        next_sa14_r = sa13_r;
        next_sa14_c = sa10_c;
        if (first_round == 6'd5) begin
            next_sa14 = sa13_r * sa10_c;
        end
        else begin
            next_sa14 = sa14 + sa13_r * sa10_c;
        end


        // sa15
        next_sa15_r = sa14_r;
        next_sa15_c = sa11_c;
        if (first_round == 6'd6) begin
            next_sa15 = sa14_r * sa11_c;
        end
        else begin
            next_sa15 = sa15 + sa14_r * sa11_c;
        end

        // sa16
        next_sa16_r = sa15_r;
        next_sa16_c = sa12_c;
        if (first_round == 6'd7) begin
            next_sa16 = sa15_r * sa12_c;
        end
        else begin
            next_sa16 = sa16 + sa15_r * sa12_c;
        end
    end

    // sequential
    // sa, sa_r, sa_c
    always @(posedge clk, negedge rst_n) begin
        if (rst_n == 0) begin
            // sa
            sa1 = 32'd0;
            sa2 = 32'd0;
            sa3 = 32'd0;
            sa4 = 32'd0;
            sa5 = 32'd0;
            sa6 = 32'd0;
            sa7 = 32'd0;
            sa8 = 32'd0;
            sa9 = 32'd0;
            sa10 = 32'd0;
            sa11 = 32'd0;
            sa12 = 32'd0;
            sa13 = 32'd0;
            sa14 = 32'd0;
            sa15 = 32'd0;
            sa16 = 32'd0;

            // sa_c
            sa1_c = 8'd0;
            sa2_c = 8'd0;
            sa3_c = 8'd0;
            sa4_c = 8'd0;
            sa5_c = 8'd0;
            sa6_c = 8'd0;
            sa7_c = 8'd0;
            sa8_c = 8'd0;
            sa9_c = 8'd0;
            sa10_c = 8'd0;
            sa11_c = 8'd0;
            sa12_c = 8'd0;
            sa13_c = 8'd0;
            sa14_c = 8'd0;
            sa15_c = 8'd0;
            sa16_c = 8'd0;

            // sa_r
            sa1_r = 8'd0;
            sa2_r = 8'd0;
            sa3_r = 8'd0;
            sa4_r = 8'd0;
            sa5_r = 8'd0;
            sa6_r = 8'd0;
            sa7_r = 8'd0;
            sa8_r = 8'd0;
            sa9_r = 8'd0;
            sa10_r = 8'd0;
            sa11_r = 8'd0;
            sa12_r = 8'd0;
            sa13_r = 8'd0;
            sa14_r = 8'd0;
            sa15_r = 8'd0;
            sa16_r = 8'd0;

        end
        else begin
            // sa
            sa1 = next_sa1;
            sa2 = next_sa2;
            sa3 = next_sa3;
            sa4 = next_sa4;
            sa5 = next_sa5;
            sa6 = next_sa6;
            sa7 = next_sa7;
            sa8 = next_sa8;
            sa9 = next_sa9;
            sa10 = next_sa10;
            sa11 = next_sa11;
            sa12 = next_sa12;
            sa13 = next_sa13;
            sa14 = next_sa14;
            sa15 = next_sa15;
            sa16 = next_sa16;

            // sa_c
            sa1_c = next_sa1_c;
            sa2_c = next_sa2_c;
            sa3_c = next_sa3_c;
            sa4_c = next_sa4_c;
            sa5_c = next_sa5_c;
            sa6_c = next_sa6_c;
            sa7_c = next_sa7_c;
            sa8_c = next_sa8_c;
            sa9_c = next_sa9_c;
            sa10_c = next_sa10_c;
            sa11_c = next_sa11_c;
            sa12_c = next_sa12_c;
            sa13_c = next_sa13_c;
            sa14_c = next_sa14_c;
            sa15_c = next_sa15_c;
            sa16_c = next_sa16_c;

            // sa_r
            sa1_r = next_sa1_r;
            sa2_r = next_sa2_r;
            sa3_r = next_sa3_r;
            sa4_r = next_sa4_r;
            sa5_r = next_sa5_r;
            sa6_r = next_sa6_r;
            sa7_r = next_sa7_r;
            sa8_r = next_sa8_r;
            sa9_r = next_sa9_r;
            sa10_r = next_sa10_r;
            sa11_r = next_sa11_r;
            sa12_r = next_sa12_r;
            sa13_r = next_sa13_r;
            sa14_r = next_sa14_r;
            sa15_r = next_sa15_r;
            sa16_r = next_sa16_r;
        end
    end 
endmodule
