`define init 8'd1
`define buildTree 8'd2
`define stall 8'd10
`define setFirst 8'd3
`define setSecond 8'd4
`define getSecond 8'd5
`define sendDecoder 8'd6
`define execution 8'd7
`define waitToFinish 8'd8
`define done 8'd9
`define A 8'd65
`define B 8'd66
`define C 8'd67
`define D 8'd68
`define E 8'd69
`define F 8'd70
`define G 8'd71

module top (
    input clk,
    input rst_n,
    input valid,
    output reg Wait,
    output reg Ready,
    output [15:0] gaparr_addr,
    input [31:0] gaparr_rdata,
    output [15:0] codeseq_addr,
    input [31:0] codeseq_rdata,
    output [15:0] idx_addr,
    input [31:0] idx_rdata,
    output reg [15:0] tree_addr,
    input [31:0] tree_rdata,
    output output_wen_d1,
    output [15:0] output_addr_d1,
    output [7:0] output_wdata_d1,
    output output_wen_d2,
    output [15:0] output_addr_d2,
    output [7:0] output_wdata_d2,
    output output_wen_d3,
    output [15:0] output_addr_d3,
    output [7:0] output_wdata_d3,
    output output_wen_d4,
    output [15:0] output_addr_d4,
    output [7:0] output_wdata_d4,
    input [31:0] LEN
);

reg [7:0] state, next_state;
reg [63:0] codeseq, next_codeseq;
reg [63:0] gaparr, next_gaparr;
reg [63:0] idx, next_idx;
reg [31:0] backup_codeseq, next_backup_codeseq;
reg [31:0] backup_gaparr, next_backup_gaparr;
reg [31:0] backup_idx, next_backup_idx;
reg [15:0] cnt, next_cnt; 
reg [7:0] remain, next_remain;
reg doing, next_doing;
reg [7:0] tree[0:7];
reg [7:0] next_tree[0:7];
reg [15:0] next_tree_addr;
reg [7:0] tree_cnt, next_tree_cnt;
reg [15:0] d1_codeseq, d2_codeseq, d3_codeseq, d4_codeseq;
reg [15:0] next_d1_codeseq, next_d2_codeseq, next_d3_codeseq, next_d4_codeseq;
reg [15:0] d1_gaparr, d2_gaparr, d3_gaparr, d4_gaparr;
reg [15:0] next_d1_gaparr, next_d2_gaparr, next_d3_gaparr, next_d4_gaparr;
reg [7:0] d1_pos, d2_pos, d3_pos, d4_pos;
reg [7:0] next_d1_pos, next_d2_pos, next_d3_pos, next_d4_pos;
reg [7:0] d1_idx, d2_idx, d3_idx, d4_idx;
reg [7:0] next_d1_idx, next_d2_idx, next_d3_idx, next_d4_idx;
reg d1_start, next_d1_start, d2_start, next_d2_start, d3_start, next_d3_start, d4_start, next_d4_start;
reg d1_done, d2_done, d3_done, d4_done;
reg next_d1_done, next_d2_done, next_d3_done, next_d4_done;

// state
always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        state = `init;
    end
    else begin
        state = next_state;
    end
end

always @(*) begin
    next_state = state;
    case (state)
        `init: begin
            if (valid) next_state = `buildTree;
        end
        `buildTree: begin
            if (tree_addr == 16'd4) begin
                next_state = `setFirst;
            end
            else next_state = `stall;
        end
        `stall: begin
            next_state = `buildTree;
        end
        `setFirst: begin
            next_state = `setSecond;
        end
        `setSecond: begin
            next_state = `getSecond;
        end
        `getSecond: begin
            next_state = `sendDecoder;
        end
        `sendDecoder: begin
            next_state = `execution;
        end
        `execution: begin
            if (d1_done && d2_done && d3_done && d4_done) next_state = `waitToFinish;
        end
        `waitToFinish: begin
            next_state = `done;
        end
        `done: begin
            next_state = `init;
        end
    endcase
end

// tree
always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        tree_addr = 16'd0;
        tree[0] = 8'd0;
        tree[1] = 8'd0;
        tree[2] = 8'd0;
        tree[3] = 8'd0;
        tree[4] = 8'd0;
        tree[5] = 8'd0;
        tree[6] = 8'd0;
        tree[7] = 8'd0;
    end
    else begin
        tree_addr = next_tree_addr;
        tree[0] = next_tree[0];
        tree[1] = next_tree[1];
        tree[2] = next_tree[2];
        tree[3] = next_tree[3];
        tree[4] = next_tree[4];
        tree[5] = next_tree[5];
        tree[6] = next_tree[6];
        tree[7] = next_tree[7];
    end
end
always @(*) begin
    next_tree_addr = tree_addr;
    next_tree[0] = tree[0];
    next_tree[1] = tree[1];
    next_tree[2] = tree[2];
    next_tree[3] = tree[3];
    next_tree[4] = tree[4];
    next_tree[5] = tree[5];
    next_tree[6] = tree[6];
    next_tree[7] = tree[7];

    if (state == `init) begin
        next_tree_addr = 16'd0;
        next_tree[0] = 8'd0;
        next_tree[1] = 8'd0;
        next_tree[2] = 8'd0;
        next_tree[3] = 8'd0;
        next_tree[4] = 8'd0;
        next_tree[5] = 8'd0;
        next_tree[6] = 8'd0;
        next_tree[7] = 8'd0;
    end
    else if (state == `buildTree) begin
        next_tree_addr = tree_addr + 4;
        next_tree[tree_addr] = tree_rdata[7:0];
        next_tree[tree_addr+1] = tree_rdata[15:8];
        next_tree[tree_addr+2] = tree_rdata[23:16];
        next_tree[tree_addr+3] = tree_rdata[31:24];
    end
end


// codeseq, idx, gaparr
always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        codeseq = 64'd0;
        gaparr = 64'd0;
        idx = 64'd0;
        remain = 8'd0;
        doing = 1'b0;
        cnt = 16'd0;
    end
    else begin
        codeseq = next_codeseq;
        gaparr = next_gaparr;
        idx = next_idx;
        remain = next_remain;
        doing = next_doing;
        cnt = next_cnt;
    end
end

// cnt , remain, codeseq, idx, gaparr, doing
always @(*) begin
    next_remain = remain;
    next_cnt = cnt;
    next_codeseq = codeseq;
    next_gaparr = gaparr;
    next_idx = idx;
    next_doing = 1'b0;
    case (state)
        `setFirst: begin
            next_cnt = cnt + 16'd4;
        end
        `setSecond: begin // getFirst
            next_codeseq[31:0] = codeseq_rdata; 
            next_idx[31:0] = idx_rdata; 
            next_gaparr[31:0] = gaparr_rdata; 
            next_cnt = cnt + 16'd4;
        end 
        `getSecond: begin
            next_codeseq[63:32] = codeseq_rdata; 
            next_idx[63:32] = idx_rdata; 
            next_gaparr[63:32] = gaparr_rdata; 
            next_cnt = cnt + 16'd4;
        end
        `sendDecoder: begin
            next_codeseq = {codeseq_rdata, codeseq[63:32]};
            next_gaparr = {gaparr_rdata, gaparr[63:32]};
            next_idx = {idx_rdata, idx[63:32]}; 
            next_remain = 8'd5;
            // next_remain = 8'd8;
        end
        `execution: begin
            case({(d1_pos == d1_gaparr[15:8] + 7), (d2_pos == d2_gaparr[15:8] + 7), (d3_pos == d3_gaparr[15:8] + 7), (d4_pos == d4_gaparr[15:8] + 7)})
                4'b0000: begin
                    if (remain <= 8'd4 && !doing && cnt < LEN) begin
                        next_cnt = cnt + 16'd4;
                        next_remain = (LEN - cnt >= 4) ? remain + 8'd4 : remain + (LEN - cnt);
                        next_doing = 1'b1;
                        case (remain)
                            8'd1: begin
                                next_codeseq = {24'd0, codeseq_rdata, codeseq[7:0]};
                                next_gaparr = {24'd0, gaparr_rdata, gaparr[7:0]};
                                next_idx = {24'd0, idx_rdata, idx[7:0]};
                            end 
                            8'd2: begin
                                next_codeseq = {16'd0, codeseq_rdata, codeseq[15:0]};
                                next_gaparr = {16'd0, gaparr_rdata, gaparr[15:0]};
                                next_idx = {16'd0, idx_rdata, idx[15:0]};
                            end
                            8'd3: begin
                                next_codeseq = {8'd0, codeseq_rdata, codeseq[23:0]};
                                next_gaparr = {8'd0, gaparr_rdata, gaparr[23:0]};
                                next_idx = {8'd0, idx_rdata, idx[23:0]};
                            end
                            8'd4: begin
                                next_codeseq = {codeseq_rdata, codeseq[31:0]};
                                next_gaparr = {gaparr_rdata, gaparr[31:0]};
                                next_idx = {idx_rdata, idx[31:0]};
                            end
                        endcase
                    end
                end
                4'b1000, 4'b0100, 4'b0010, 4'b0001: begin
                    if (remain <= 8'd5 && !doing && cnt < LEN) begin
                        next_cnt = cnt + 16'd4;
                        next_remain = (LEN - cnt >= 4) ? remain + 8'd3 : remain + (LEN - cnt) - 1;
                        next_doing = 1'b1;
                        case (remain)
                            8'd1: begin
                                next_codeseq = {32'd0, codeseq_rdata};
                                next_gaparr = {32'd0, gaparr_rdata};
                                next_idx = {32'd0, idx_rdata};
                            end 
                            8'd2: begin
                                next_codeseq = {24'd0, codeseq_rdata, codeseq[15:8]};
                                next_gaparr = {24'd0, gaparr_rdata, gaparr[15:8]};
                                next_idx = {24'd0, idx_rdata, idx[15:8]};
                            end
                            8'd3: begin
                                next_codeseq = {16'd0, codeseq_rdata, codeseq[23:8]};
                                next_gaparr = {16'd0, gaparr_rdata, gaparr[23:8]};
                                next_idx = {16'd0, idx_rdata, idx[23:8]};
                            end
                            8'd4: begin
                                next_codeseq = {8'd0, codeseq_rdata, codeseq[31:8]};
                                next_gaparr = {8'd0, gaparr_rdata, gaparr[31:8]};
                                next_idx = {8'd0, idx_rdata, idx[31:8]};
                            end
                            8'd5: begin
                                next_codeseq = {codeseq_rdata, codeseq[39:8]};
                                next_gaparr = {gaparr_rdata, gaparr[39:8]};
                                next_idx = {idx_rdata, idx[39:8]};
                            end
                        endcase
                    end
                    else begin
                        next_codeseq = {8'd0, codeseq[63:8]};
                        next_gaparr = {8'd0, gaparr[63:8]};
                        next_idx = {8'd0, idx[63:8]};
                        next_remain = (remain > 1) ? remain - 8'd1 : 8'd0;
                    end
                end
                4'b1100, 4'b1010, 4'b1001, 4'b0110, 4'b0101, 4'b0011: begin
                    if (remain <= 8'd6 && !doing && cnt < LEN) begin
                        next_cnt = cnt + 16'd4;
                        next_remain = (LEN - cnt >= 4) ? remain + 8'd2 : remain + (LEN - cnt) - 2;
                        next_doing = 1'b1;
                        case (remain)
                            8'd2: begin
                                next_codeseq = {31'd0, codeseq_rdata};
                                next_gaparr = {31'd0, gaparr_rdata};
                                next_idx = {31'd0, idx_rdata};
                            end
                            8'd3: begin
                                next_codeseq = {24'd0, codeseq_rdata, codeseq[23:16]};
                                next_gaparr = {24'd0, gaparr_rdata, gaparr[23:16]};
                                next_idx = {24'd0, idx_rdata, idx[23:16]};
                            end
                            8'd4: begin
                                next_codeseq = {16'd0, codeseq_rdata, codeseq[31:16]};
                                next_gaparr = {16'd0, gaparr_rdata, gaparr[31:16]};
                                next_idx = {16'd0, idx_rdata, idx[31:16]};
                            end
                            8'd5: begin
                                next_codeseq = {8'd0, codeseq_rdata, codeseq[39:16]};
                                next_gaparr = {8'd0, gaparr_rdata, gaparr[39:16]};
                                next_idx = {8'd0, idx_rdata, idx[39:16]};
                            end
                            8'd6: begin
                                next_codeseq = {codeseq_rdata, codeseq[47:16]};
                                next_gaparr = {gaparr_rdata, gaparr[47:16]};
                                next_idx = {idx_rdata, idx[47:16]};
                            end
                        endcase
                    end
                    else begin
                        next_codeseq = {16'd0, codeseq[63:16]};
                        next_gaparr = {16'd0, gaparr[63:16]};
                        next_idx = {16'd0, idx[63:16]};
                        next_remain = (remain > 2) ? remain - 8'd2 : 8'd0;
                    end
                end
                4'b1110, 4'b1101, 4'b1011, 4'b0111: begin
                    if (remain <= 8'd7 && !doing && cnt < LEN) begin
                        next_cnt = cnt + 16'd4;
                        next_remain = (LEN - cnt >= 4) ? remain + 8'd1 : remain + (LEN - cnt) - 3;
                        next_doing = 1'b1;
                        case (remain)
                            8'd3: begin
                                next_codeseq = {32'd0, codeseq_rdata};
                                next_gaparr = {32'd0, gaparr_rdata};
                                next_idx = {32'd0, idx_rdata};
                            end
                            8'd4: begin
                                next_codeseq = {24'd0, codeseq_rdata, codeseq[31:24]};
                                next_gaparr = {24'd0, gaparr_rdata, gaparr[31:24]};
                                next_idx = {24'd0, idx_rdata, idx[31:24]};
                            end
                            8'd5: begin
                                next_codeseq = {16'd0, codeseq_rdata, codeseq[39:24]};
                                next_gaparr = {16'd0, gaparr_rdata, gaparr[39:24]};
                                next_idx = {16'd0, idx_rdata, idx[39:24]};
                            end
                            8'd6: begin
                                next_codeseq = {8'd0, codeseq_rdata, codeseq[47:24]};
                                next_gaparr = {8'd0, gaparr_rdata, gaparr[47:24]};
                                next_idx = {8'd0, idx_rdata, idx[47:24]};
                            end
                            8'd7: begin
                                next_codeseq = {codeseq_rdata, codeseq[55:24]};
                                next_gaparr = {gaparr_rdata, gaparr[55:24]};
                                next_idx = {idx_rdata, idx[55:24]};
                            end
                        endcase
                    end
                    else begin
                        next_codeseq = {24'd0, codeseq[63:24]};
                        next_gaparr = {24'd0, gaparr[63:24]};
                        next_idx = {24'd0, idx[63:24]};
                        next_remain = (remain > 3) ? remain - 8'd3 : 8'd0;
                    end
                end
                4'b1111: begin
                    if (remain <= 8'd8 && !doing && cnt < LEN) begin
                        next_cnt = cnt + 16'd4;
                        next_remain = (LEN - cnt >= 4) ? remain : remain + (LEN - cnt) - 4;
                        next_doing = 1'b1;
                        case (remain)
                            8'd4: begin
                                next_codeseq = {32'd0, codeseq_rdata};
                                next_gaparr = {32'd0, gaparr_rdata};
                                next_idx = {32'd0, idx_rdata};
                            end
                            8'd5: begin
                                next_codeseq = {24'd0, codeseq_rdata, codeseq[39:32]};
                                next_gaparr = {24'd0, gaparr_rdata, gaparr[39:32]};
                                next_idx = {24'd0, idx_rdata, idx[39:32]};
                            end
                            8'd6: begin
                                next_codeseq = {16'd0, codeseq_rdata, codeseq[47:32]};
                                next_gaparr = {16'd0, gaparr_rdata, gaparr[47:32]};
                                next_idx = {16'd0, idx_rdata, idx[47:32]};
                            end
                            8'd7: begin
                                next_codeseq = {8'd0, codeseq_rdata, codeseq[55:32]};
                                next_gaparr = {8'd0, gaparr_rdata, gaparr[55:32]};
                                next_idx = {8'd0, idx_rdata, idx[55:32]};
                            end
                            8'd8: begin
                                next_codeseq = {codeseq_rdata, codeseq[63:32]};
                                next_gaparr = {gaparr_rdata, gaparr[63:32]};
                                next_idx = {idx_rdata, idx[63:32]};
                            end
                        endcase
                    end
                    else begin
                        next_codeseq = {32'd0, codeseq[63:32]};
                        next_gaparr = {32'd0, gaparr[63:32]};
                        next_idx = {32'd0, idx[63:32]};
                        next_remain = (remain > 4) ? remain - 8'd4 : 8'd0;
                    end
                end
            endcase
        end
    endcase
end

// codeseq, idx, gaparr
always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        d1_codeseq = 16'd0; d1_gaparr = 16'd0; d1_idx = 16'd0;
        d2_codeseq = 16'd0; d2_gaparr = 16'd0; d2_idx = 16'd0;
        d3_codeseq = 16'd0; d3_gaparr = 16'd0; d3_idx = 16'd0;
        d4_codeseq = 16'd0; d4_gaparr = 16'd0; d4_idx = 16'd0;
        d1_done = 1'b0; d2_done = 1'b0; d3_done = 1'b0; d4_done = 1'b0;
        d1_pos = 8'd0; d2_pos = 8'd0; d3_pos = 8'd0; d4_pos = 8'd0;
    end
    else begin
        d1_codeseq = next_d1_codeseq; d1_gaparr = next_d1_gaparr; d1_idx = next_d1_idx;
        d2_codeseq = next_d2_codeseq; d2_gaparr = next_d2_gaparr; d2_idx = next_d2_idx;
        d3_codeseq = next_d3_codeseq; d3_gaparr = next_d3_gaparr; d3_idx = next_d3_idx;
        d4_codeseq = next_d4_codeseq; d4_gaparr = next_d4_gaparr; d4_idx = next_d4_idx;
        d1_done = next_d1_done; d2_done = next_d2_done; d3_done = next_d3_done; d4_done = next_d4_done;
        d1_pos = next_d1_pos; d2_pos = next_d2_pos; d3_pos = next_d3_pos; d4_pos = next_d4_pos;
    end
end

// d1, d2, d3, d4  (codeseq, gaparr, idx)
always @(*) begin
    next_d1_codeseq = d1_codeseq; next_d1_gaparr = d1_gaparr; next_d1_idx = d1_idx;
    next_d2_codeseq = d2_codeseq; next_d2_gaparr = d2_gaparr; next_d2_idx = d2_idx;
    next_d3_codeseq = d3_codeseq; next_d3_gaparr = d3_gaparr; next_d3_idx = d3_idx;
    next_d4_codeseq = d4_codeseq; next_d4_gaparr = d4_gaparr; next_d4_idx = d4_idx;
    next_d1_done = d1_done;  next_d2_done = d2_done; next_d3_done = d3_done; next_d4_done = d4_done;
    next_d1_pos = d1_pos; next_d2_pos = d2_pos; next_d3_pos = d3_pos; next_d4_pos = d4_pos; 
    case (state)
        `init: begin
            next_d1_done = 1'b0;  next_d2_done = 1'b0; next_d3_done = 1'b0; next_d4_done = 1'b0;
            next_d1_pos = 8'd0; next_d2_pos = 8'd0; next_d3_pos = 8'd0; next_d4_pos = 8'd0;
        end
        `sendDecoder: begin
            // $display("%d %d %d %d", codeseq[7:0], codeseq[15:8], codeseq[23:16], codeseq[31:24]);
            next_d1_codeseq = codeseq[15:0];
            next_d2_codeseq = codeseq[23:8];
            next_d3_codeseq = codeseq[31:16];
            next_d4_codeseq = codeseq[39:24];

            next_d1_gaparr = gaparr[15:0]; next_d1_pos = 8'd0;
            next_d2_gaparr = gaparr[23:8]; next_d2_pos = 8'd0;
            next_d3_gaparr = gaparr[31:16]; next_d3_pos = 8'd0;
            next_d4_gaparr = gaparr[39:24]; next_d4_pos = 8'd0;

            next_d1_idx = idx[7:0];
            next_d2_idx = idx[15:8];
            next_d3_idx = idx[23:16];
            next_d4_idx = idx[31:24];
        end
        `execution: begin
            case({(d1_pos == d1_gaparr[15:8] + 7), (d2_pos == d2_gaparr[15:8] + 7), (d3_pos == d3_gaparr[15:8] + 7), (d4_pos == d4_gaparr[15:8] + 7)})
                4'b0000: begin
                    next_d1_codeseq = {1'b0, d1_codeseq[15:1]};         
                    next_d2_codeseq = {1'b0, d2_codeseq[15:1]};
                    next_d3_codeseq = {1'b0, d3_codeseq[15:1]};
                    next_d4_codeseq = {1'b0, d4_codeseq[15:1]};

                    next_d1_pos = d1_pos + 1;
                    next_d2_pos = d2_pos + 1;
                    next_d3_pos = d3_pos + 1;
                    next_d4_pos = d4_pos + 1;

                    if (output_wen_d1) next_d1_idx = d1_idx + 1;
                    if (output_wen_d2) next_d2_idx = d2_idx + 1;
                    if (output_wen_d3) next_d3_idx = d3_idx + 1;
                    if (output_wen_d4) next_d4_idx = d4_idx + 1;
                end
                4'b1000: begin
                    if (remain > 0) begin
                        next_d1_codeseq = codeseq[15:0];
                        next_d1_gaparr = gaparr[15:0]; next_d1_pos = 8'd0;
                        next_d1_idx = idx[7:0];
                    end
                    else begin
                        next_d1_done = 1;
                    end        

                    next_d2_codeseq = {1'b0, d2_codeseq[15:1]};
                    next_d3_codeseq = {1'b0, d3_codeseq[15:1]};
                    next_d4_codeseq = {1'b0, d4_codeseq[15:1]};

                    next_d2_pos = d2_pos + 1;
                    next_d3_pos = d3_pos + 1;
                    next_d4_pos = d4_pos + 1;

                    if (output_wen_d2) next_d2_idx = d2_idx + 1;
                    if (output_wen_d3) next_d3_idx = d3_idx + 1;
                    if (output_wen_d4) next_d4_idx = d4_idx + 1;
                end
                4'b0100: begin
                    if (remain > 0) begin                      
                        next_d2_codeseq = codeseq[15:0];
                        next_d2_gaparr = gaparr[15:0]; next_d2_pos = 8'd0;
                        next_d2_idx = idx[7:0];
                    end
                    else begin
                        next_d2_done = 1;
                    end

                    next_d1_codeseq = {1'b0, d1_codeseq[15:1]};
                    next_d3_codeseq = {1'b0, d3_codeseq[15:1]};
                    next_d4_codeseq = {1'b0, d4_codeseq[15:1]};

                    next_d1_pos = d1_pos + 1;
                    next_d3_pos = d3_pos + 1;
                    next_d4_pos = d4_pos + 1;

                    if (output_wen_d1) next_d1_idx = d1_idx + 1;
                    if (output_wen_d3) next_d3_idx = d3_idx + 1;
                    if (output_wen_d4) next_d4_idx = d4_idx + 1;
                end
                4'b0010: begin
                    if (remain > 0) begin
                        next_d3_codeseq = codeseq[15:0];
                        next_d3_gaparr = gaparr[15:0]; next_d3_pos = 8'd0;
                        next_d3_idx = idx[7:0];
                    end
                    else begin
                        next_d3_done = 1;
                    end

                    next_d1_codeseq = {1'b0, d1_codeseq[15:1]};
                    next_d2_codeseq = {1'b0, d2_codeseq[15:1]};
                    next_d4_codeseq = {1'b0, d4_codeseq[15:1]};

                    next_d1_pos = d1_pos + 1;
                    next_d2_pos = d2_pos + 1;
                    next_d4_pos = d4_pos + 1;

                    if (output_wen_d1) next_d1_idx = d1_idx + 1;
                    if (output_wen_d2) next_d2_idx = d2_idx + 1;
                    if (output_wen_d4) next_d4_idx = d4_idx + 1;
                end
                4'b0001: begin
                    if (remain > 0) begin
                        next_d4_codeseq = codeseq[15:0];
                        next_d4_gaparr = gaparr[15:0]; next_d4_pos = 8'd0;
                        next_d4_idx = idx[7:0];
                    end
                    else begin
                        next_d4_done = 1;
                    end

                    next_d1_codeseq = {1'b0, d1_codeseq[15:1]};
                    next_d2_codeseq = {1'b0, d2_codeseq[15:1]};
                    next_d3_codeseq = {1'b0, d3_codeseq[15:1]};

                    next_d1_pos = d1_pos + 1;
                    next_d2_pos = d2_pos + 1;
                    next_d3_pos = d3_pos + 1;

                    if (output_wen_d1) next_d1_idx = d1_idx + 1;
                    if (output_wen_d2) next_d2_idx = d2_idx + 1;
                    if (output_wen_d3) next_d3_idx = d3_idx + 1;
                end
                4'b1100: begin
                    if (remain > 0) begin
                        next_d1_codeseq = codeseq[15:0];
                        next_d1_gaparr = gaparr[15:0]; next_d1_pos = 8'd0;
                        next_d1_idx = idx[7:0];
                    end
                    else begin
                        next_d1_done = 1;
                    end
                    
                    if (remain > 1) begin
                        next_d2_codeseq = codeseq[23:8];
                        next_d2_gaparr = gaparr[23:8]; next_d2_pos = 8'd0;
                        next_d2_idx = idx[15:8];
                    end
                    else begin
                        next_d2_done = 1;
                    end

                    next_d3_codeseq = {1'b0, d3_codeseq[15:1]};
                    next_d4_codeseq = {1'b0, d4_codeseq[15:1]};

                    next_d3_pos = d3_pos + 1;
                    next_d4_pos = d4_pos + 1;

                    if (output_wen_d3) next_d3_idx = d3_idx + 1;
                    if (output_wen_d4) next_d4_idx = d4_idx + 1;
                end
                4'b1010: begin
                    if (remain > 0) begin
                        next_d1_codeseq = codeseq[15:0];
                        next_d1_gaparr = gaparr[15:0]; next_d1_pos = 8'd0;
                        next_d1_idx = idx[7:0];
                    end
                    else begin
                        next_d1_done = 1;
                    end
                    
                    if (remain > 1) begin
                        next_d3_codeseq = codeseq[23:8];
                        next_d3_gaparr = gaparr[23:8]; next_d3_pos = 8'd0;
                        next_d3_idx = idx[15:8];
                    end
                    else begin
                        next_d3_done = 1;
                    end

                    next_d2_codeseq = {1'b0, d2_codeseq[15:1]};
                    next_d4_codeseq = {1'b0, d4_codeseq[15:1]};

                    next_d2_pos = d2_pos + 1;
                    next_d4_pos = d4_pos + 1;

                    if (output_wen_d2) next_d2_idx = d2_idx + 1;
                    if (output_wen_d4) next_d4_idx = d4_idx + 1;
                end
                4'b1001: begin
                    if (remain > 0) begin
                        next_d1_codeseq = codeseq[15:0];
                        next_d1_gaparr = gaparr[15:0]; next_d1_pos = 8'd0;
                        next_d1_idx = idx[7:0];
                    end
                    else begin
                        next_d1_done = 1;
                    end
                    
                    if (remain > 1) begin
                        next_d4_codeseq = codeseq[23:8];
                        next_d4_gaparr = gaparr[23:8]; next_d4_pos = 8'd0;
                        next_d4_idx = idx[15:8];
                    end
                    else begin
                        next_d4_done = 1;
                    end

                    next_d2_codeseq = {1'b0, d2_codeseq[15:1]};
                    next_d3_codeseq = {1'b0, d3_codeseq[15:1]};

                    next_d2_pos = d2_pos + 1;
                    next_d3_pos = d3_pos + 1;

                    if (output_wen_d2) next_d2_idx = d2_idx + 1;
                    if (output_wen_d3) next_d3_idx = d3_idx + 1;
                end
                4'b0110: begin
                    if (remain > 0) begin
                        next_d2_codeseq = codeseq[15:0];
                        next_d2_gaparr = gaparr[15:0]; next_d2_pos = 8'd0;
                        next_d2_idx = idx[7:0];
                    end
                    else begin
                        next_d2_done = 1;
                    end
                    
                    if (remain > 1) begin
                        next_d3_codeseq = codeseq[23:8];
                        next_d3_gaparr = gaparr[23:8]; next_d3_pos = 8'd0;
                        next_d3_idx = idx[15:8];
                    end
                    else begin
                        next_d3_done = 1;
                    end

                    next_d1_codeseq = {1'b0, d1_codeseq[15:1]};
                    next_d4_codeseq = {1'b0, d4_codeseq[15:1]};

                    next_d1_pos = d1_pos + 1;
                    next_d4_pos = d4_pos + 1;

                    if (output_wen_d1) next_d1_idx = d1_idx + 1;
                    if (output_wen_d4) next_d4_idx = d4_idx + 1;
                end
                4'b0101: begin
                    if (remain > 0) begin
                        next_d2_codeseq = codeseq[15:0];
                        next_d2_gaparr = gaparr[15:0]; next_d2_pos = 8'd0;
                        next_d2_idx = idx[7:0];
                    end
                    else begin
                        next_d2_done = 1;
                    end

                    if (remain > 1) begin
                        next_d4_codeseq = codeseq[23:8];
                        next_d4_gaparr = gaparr[23:8]; next_d4_pos = 8'd0;
                        next_d4_idx = idx[15:8];
                    end
                    else begin
                        next_d4_done = 1;
                    end
                    

                    next_d1_codeseq = {1'b0, d1_codeseq[15:1]};
                    next_d3_codeseq = {1'b0, d3_codeseq[15:1]};

                    next_d1_pos = d1_pos + 1;
                    next_d3_pos = d3_pos + 1;

                    if (output_wen_d1) next_d1_idx = d1_idx + 1;
                    if (output_wen_d3) next_d3_idx = d3_idx + 1;
                end
                4'b0011: begin
                    if (remain > 0) begin
                        next_d3_codeseq = codeseq[15:0];
                        next_d3_gaparr = gaparr[15:0]; next_d3_pos = 8'd0;
                        next_d3_idx = idx[7:0];
                    end
                    else begin
                        next_d3_done = 1;
                    end

                    if (remain > 1) begin
                        next_d4_codeseq = codeseq[23:8];
                        next_d4_gaparr = gaparr[23:8]; next_d4_pos = 8'd0;
                        next_d4_idx = idx[15:8];
                    end
                    else begin
                        next_d4_done = 1;
                    end
                    

                    next_d1_codeseq = {1'b0, d1_codeseq[15:1]};
                    next_d2_codeseq = {1'b0, d2_codeseq[15:1]};

                    next_d1_pos = d1_pos + 1;
                    next_d2_pos = d2_pos + 1;

                    if (output_wen_d1) next_d1_idx = d1_idx + 1;
                    if (output_wen_d2) next_d2_idx = d2_idx + 1;
                end
                4'b1110: begin
                    if (remain > 0) begin
                        next_d1_codeseq = codeseq[15:0];
                        next_d1_gaparr = gaparr[15:0]; next_d1_pos = 8'd0;
                        next_d1_idx = idx[7:0];
                    end
                    else begin
                        next_d1_done = 1;
                    end
                    
                    if (remain > 1) begin
                        next_d2_codeseq = codeseq[23:8];
                        next_d2_gaparr = gaparr[23:8]; next_d2_pos = 8'd0;
                        next_d2_idx = idx[15:8];
                    end
                    else begin
                        next_d2_done = 1;
                    end

                    if (remain > 2) begin
                        next_d3_codeseq = codeseq[31:16];
                        next_d3_gaparr = gaparr[31:16]; next_d3_pos = 8'd0;
                        next_d3_idx = idx[23:16];
                    end
                    else begin
                        next_d3_done = 1;
                    end

                    next_d4_codeseq = {1'b0, d4_codeseq[15:1]};
                    next_d4_pos = d4_pos + 1;
                    if (output_wen_d4) next_d4_idx = d4_idx + 1;
                end
                4'b1101: begin
                    if (remain > 0) begin
                        next_d1_codeseq = codeseq[15:0];
                        next_d1_gaparr = gaparr[15:0]; next_d1_pos = 8'd0;
                        next_d1_idx = idx[7:0];
                    end
                    else begin
                        next_d1_done = 1;
                    end

                    if (remain > 1) begin
                        next_d2_codeseq = codeseq[23:8];
                        next_d2_gaparr = gaparr[23:8]; next_d2_pos = 8'd0;
                        next_d2_idx = idx[15:8];
                    end
                    else begin
                        next_d2_done = 1;
                    end

                    if (remain > 2) begin
                        next_d4_codeseq = codeseq[31:16];
                        next_d4_gaparr = gaparr[31:16]; next_d4_pos = 8'd0;
                        next_d4_idx = idx[23:16];
                    end
                    else begin
                        next_d4_done = 1;
                    end
                    


                    next_d3_codeseq = {1'b0, d3_codeseq[15:1]};
                    next_d3_pos = d3_pos + 1;
                    if (output_wen_d3) next_d3_idx = d3_idx + 1;
                end
                4'b1011: begin
                    if (remain > 0) begin
                        next_d1_codeseq = codeseq[15:0];
                        next_d1_gaparr = gaparr[15:0]; next_d1_pos = 8'd0;
                        next_d1_idx = idx[7:0];
                    end
                    else begin
                        next_d1_done = 1;
                    end

                    if (remain > 1) begin
                        next_d3_codeseq = codeseq[23:8];
                        next_d3_gaparr = gaparr[23:8]; next_d3_pos = 8'd0;
                        next_d3_idx = idx[15:8];
                    end
                    else begin
                        next_d3_done = 1;
                    end

                    if (remain > 2) begin
                        next_d4_codeseq = codeseq[31:16];
                        next_d4_gaparr = gaparr[31:16]; next_d4_pos = 8'd0;
                        next_d4_idx = idx[23:16];
                    end
                    else begin
                        next_d4_done = 1;
                    end
                    


                    next_d2_codeseq = {1'b0, d2_codeseq[15:1]};
                    next_d2_pos = d2_pos + 1;
                    if (output_wen_d2) next_d2_idx = d2_idx + 1;
                end
                4'b0111: begin
                    if (remain > 0) begin
                        next_d2_codeseq = codeseq[15:0];
                        next_d2_gaparr = gaparr[15:0]; next_d2_pos = 8'd0;
                        next_d2_idx = idx[7:0];
                    end
                    else begin
                        next_d2_done = 1;
                    end

                    if (remain > 1) begin
                        next_d3_codeseq = codeseq[23:8];
                        next_d3_gaparr = gaparr[23:8]; next_d3_pos = 8'd0;
                        next_d3_idx = idx[15:8];
                    end
                    else begin
                        next_d3_done = 1;
                    end

                    if (remain > 2) begin
                        next_d4_codeseq = codeseq[31:16];
                        next_d4_gaparr = gaparr[31:16]; next_d4_pos = 8'd0;
                        next_d4_idx = idx[23:16];
                    end
                    else begin
                        next_d4_done = 1;
                    end
                    


                    next_d1_codeseq = {1'b0, d1_codeseq[15:1]};
                    next_d1_pos = d1_pos + 1;
                    if (output_wen_d1) next_d1_idx = d1_idx + 1;
                end
                4'b1111: begin
                    if (remain > 0) begin
                        next_d1_codeseq = codeseq[15:0];
                        next_d1_gaparr = gaparr[15:0]; next_d1_pos = 8'd0;
                        next_d1_idx = idx[7:0];
                    end
                    else begin
                        next_d1_done = 1;
                    end
                    if (remain > 1) begin
                        next_d2_codeseq = codeseq[23:8];
                        next_d2_gaparr = gaparr[23:8]; next_d2_pos = 8'd0;
                        next_d2_idx = idx[15:8];
                    end
                    else begin
                        next_d2_done = 1;
                    end
                    if (remain > 2) begin
                        next_d3_codeseq = codeseq[31:16];
                        next_d3_gaparr = gaparr[31:16]; next_d3_pos = 8'd0;
                        next_d3_idx = idx[23:16];
                    end
                    else begin
                        next_d3_done = 1;
                    end
                    if (remain > 3) begin
                        next_d4_codeseq = codeseq[39:24];
                        next_d4_gaparr = gaparr[39:24]; next_d4_pos = 8'd0;
                        next_d4_idx = idx[31:24];
                    end
                    else begin
                        next_d4_done = 1;
                    end
                
                    
                end
            endcase
        end
    endcase
end

// gaparr, codeseq, idx addr
assign gaparr_addr = cnt;
assign codeseq_addr = cnt;
assign idx_addr = cnt;
assign output_addr_d1 = d1_idx;
assign output_addr_d2 = d2_idx;
assign output_addr_d3 = d3_idx;
assign output_addr_d4 = d4_idx;

always @(*) begin
    d1_start = 1'b0;
    d2_start = 1'b0;
    d3_start = 1'b0;
    d4_start = 1'b0;
    case (state)
        `sendDecoder: begin
            d1_start = 1'b1;
            d2_start = 1'b1;
            d3_start = 1'b1;
            d4_start = 1'b1;
        end 
        `execution: begin
            d1_start = d1_done;
            d2_start = d2_done;
            d3_start = d3_done;
            d4_start = d4_done;
        end
    endcase
end

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

decoder de1(
    .clk(clk),
    .rst_n(rst_n),
    .tree_0(tree[0]),
    .tree_1(tree[1]),
    .tree_2(tree[2]),
    .tree_3(tree[3]),
    .tree_4(tree[4]),
    .tree_5(tree[5]),
    .tree_6(tree[6]),
    .codeseq(d1_codeseq),
    .start(d1_start),
    .yet((d1_pos<d1_gaparr[7:0])),
    .symbol(output_wdata_d1),
    .finish(output_wen_d1)
);

decoder de2(
    .clk(clk),
    .rst_n(rst_n),
    .tree_0(tree[0]),
    .tree_1(tree[1]),
    .tree_2(tree[2]),
    .tree_3(tree[3]),
    .tree_4(tree[4]),
    .tree_5(tree[5]),
    .tree_6(tree[6]),
    .codeseq(d2_codeseq),
    .start(d2_start),
    .yet((d2_pos<d2_gaparr[7:0])),
    .symbol(output_wdata_d2),
    .finish(output_wen_d2)
);

decoder de3(
    .clk(clk),
    .rst_n(rst_n),
    .tree_0(tree[0]),
    .tree_1(tree[1]),
    .tree_2(tree[2]),
    .tree_3(tree[3]),
    .tree_4(tree[4]),
    .tree_5(tree[5]),
    .tree_6(tree[6]),
    .codeseq(d3_codeseq),
    .start(d3_start),
    .yet((d3_pos<d3_gaparr[7:0])),
    .symbol(output_wdata_d3),
    .finish(output_wen_d3)
);

decoder de4(
    .clk(clk),
    .rst_n(rst_n),
    .tree_0(tree[0]),
    .tree_1(tree[1]),
    .tree_2(tree[2]),
    .tree_3(tree[3]),
    .tree_4(tree[4]),
    .tree_5(tree[5]),
    .tree_6(tree[6]),
    .codeseq(d4_codeseq),
    .start(d4_start),
    .yet((d4_pos<d4_gaparr[7:0])),
    .symbol(output_wdata_d4),
    .finish(output_wen_d4)
);
    

endmodule


module decoder(
    input clk,
    input rst_n,
    input [7:0] tree_0,
    input [7:0] tree_1,
    input [7:0] tree_2,
    input [7:0] tree_3,
    input [7:0] tree_4,
    input [7:0] tree_5,
    input [7:0] tree_6,
    input codeseq,
    input start,
    input yet,
    output reg [7:0] symbol,
    output reg finish
);

reg [7:0] idx, next_idx;

always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        idx = 8'd0;
    end
    else begin
        idx = next_idx;
    end
end

always @(*) begin
    next_idx = idx;
    symbol = 0;
    finish = 1'b0;
    if (start == 1 || yet) begin
        next_idx = 8'd0;
    end
    else begin
        if (codeseq == 1'b1) begin
            if (tree_0 == idx * 2 + 2) begin
                $display("A");
                symbol = `A;
                next_idx = 8'd0;
                finish = 1'b1;
            end
            else if (tree_1 == idx * 2 + 2) begin
                $display("B");
                symbol = `B;
                finish = 1'b1;
                next_idx = 8'd0;
            end
            else if (tree_2 == idx * 2 + 2) begin
                $display("C");
                symbol = `C;
                finish = 1'b1;
                next_idx = 8'd0;
            end
            else if (tree_3 == idx * 2 + 2) begin
                $display("D");
                symbol = `D;
                finish = 1'b1;
                next_idx = 8'd0;
            end
            else if (tree_4 == idx * 2 + 2) begin
                $display("E");
                symbol = `E;
                finish = 1'b1;
                next_idx = 8'd0;
            end
            else if (tree_5 == idx * 2 + 2) begin
                $display("F");
                symbol = `F;
                finish = 1'b1;
                next_idx = 8'd0;
            end
            else if (tree_6 == idx * 2 + 2) begin
                symbol = `G;
                finish = 1'b1;
                next_idx = 8'd0;
            end
            else begin
                next_idx = idx * 2 + 2;
            end
        end
        else begin
            if (tree_0 == idx * 2 + 1) begin
                $display("A");
                symbol = `A;
                finish = 1'b1;
                next_idx = 8'd0;
            end
            else if (tree_1 == idx * 2 + 1) begin
                $display("B");
                symbol = `B;
                finish = 1'b1;
                next_idx = 8'd0;
            end
            else if (tree_2 == idx * 2 + 1) begin
                $display("C");
                symbol = `C;
                finish = 1'b1;
                next_idx = 8'd0;
            end
            else if (tree_3 == idx * 2 + 1) begin
                $display("D");
                symbol = `D;
                finish = 1'b1;
                next_idx = 8'd0;
            end
            else if (tree_4 == idx * 2 + 1) begin
                $display("E");
                symbol = `E;
                finish = 1'b1;
                next_idx = 8'd0;
            end
            else if (tree_5 == idx * 2 + 1) begin
                $display("F");
                symbol = `F;
                finish = 1'b1;
                next_idx = 8'd0;
            end
            else if (tree_6 == idx * 2 + 1) begin
                symbol = `G;
                finish = 1'b1;
                next_idx = 8'd0;
            end
            else begin
                next_idx = idx * 2 + 1;
            end
        end
    end
end

endmodule