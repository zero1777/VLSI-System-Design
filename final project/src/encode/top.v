`define init 8'd1
`define readInput 8'd2
`define findSymbol 8'd3
`define getIndex 8'd4
`define readSymbol 8'd5
`define store 8'd6
`define store2 8'd7
`define DONE 8'd8
`define readLength 8'd9
`define store3 8'd10
`define readEncode 8'd11
`define store4 8'd12
`define generateEncodeSeq 8'd13
`define store5 8'd14
`define check 8'd15
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
    output [15:0] input_addr,
    input [31:0] input_rdata,
    output [15:0] symbol_addr,
    input [31:0] symbol_rdata,
    output [15:0] length_addr,
    input [31:0] length_rdata,
    output [15:0] encode_addr,
    input [31:0] encode_rdata,
    output output_wen_d1,
    output [7:0] output_len_d1,
    output [7:0] output_from_d1,
    output [15:0] output_addr_d1,
    output [15:0] output_wdata_d1,
    output output_wen_d2,
    output [7:0] output_len_d2,
    output [7:0] output_from_d2,
    output [15:0] output_addr_d2,
    output [15:0] output_wdata_d2,
    output output_wen_d3,
    output [7:0] output_len_d3,
    output [7:0] output_from_d3,
    output [15:0] output_addr_d3,
    output [15:0] output_wdata_d3,
    output output_wen_d4,
    output [7:0] output_len_d4,
    output [7:0] output_from_d4,
    output [15:0] output_addr_d4,
    output [15:0] output_wdata_d4,
    input [31:0] LEN,
    input [31:0] NUM
);

    



    reg [7:0] state, next_state;
    reg [15:0] inputADDR, next_inputADDR;
    reg [15:0] input_i, next_input_i;
    reg [15:0] symbolADDR, next_symbolADDR;
    reg [15:0] lengthADDR, next_lengthADDR;
    reg [15:0] encodeADDR, next_encodeADDR;
    reg [15:0] outputADDR_1, next_outputADDR_1;
    reg [7:0] temp_outputADDR_1;
    reg [15:0] outputADDR_2, next_outputADDR_2;
    reg [15:0] outputADDR_3, next_outputADDR_3;
    reg [15:0] outputADDR_4, next_outputADDR_4;
    reg [15:0] output_1, output_2, output_3, output_4, next_output_1, next_output_2, next_output_3, next_output_4;
    reg [7:0] index, next_index;
    reg [7:0] in[0:11];
    reg [7:0] next_in[0:11];
    reg [7:0] length[0:4]; 
    reg [7:0] next_length[0:4];
    reg [7:0] symbol[0:4]; 
    reg [7:0] next_symbol[0:4];
    wire [7:0] symbol_index[0:11];
    wire [7:0] symbol_len[0:11]; 
    wire [7:0] individualPreSum[0:4];
    wire [7:0] prefixSum[0:11];
    reg [7:0] encode [0:4];
    reg [7:0] next_encode [0:4];
    wire [15:0] encode_seq[0:11];
    reg wen_1, wen_2, wen_3, wen_4, next_wen_1, next_wen_2, next_wen_3, next_wen_4;
    reg [7:0] round, next_round;

    reg [63:0] codeseq, next_codeseq;
    reg [63:0] gaparr, next_gaparr;
    reg [63:0] idx, next_idx;
    reg [15:0] cnt, next_cnt; 
    reg [7:0] remain, next_remain;
    reg changed, next_changed;
    reg [7:0] tree[0:7];
    reg [7:0] next_tree[0:7];
    reg [15:0] next_tree_addr;
    reg [6:0] count, next_count;

    indEncoder ind1(.clk(clk), .rst_n(rst_n), .symbol_0(symbol[0]), .symbol_1(symbol[1]), .symbol_2(symbol[2]), .symbol_3(symbol[3]), .symbol_4(symbol[4]), .in_a(in[0]), .in_b(in[1]), .in_c(in[2]), .out_a(symbol_index[0]), .out_b(symbol_index[1]), .out_c(symbol_index[2]));
    indEncoder ind2(.clk(clk), .rst_n(rst_n), .symbol_0(symbol[0]), .symbol_1(symbol[1]), .symbol_2(symbol[2]), .symbol_3(symbol[3]), .symbol_4(symbol[4]), .in_a(in[3]), .in_b(in[4]), .in_c(in[5]), .out_a(symbol_index[3]), .out_b(symbol_index[4]), .out_c(symbol_index[5]));
    indEncoder ind3(.clk(clk), .rst_n(rst_n), .symbol_0(symbol[0]), .symbol_1(symbol[1]), .symbol_2(symbol[2]), .symbol_3(symbol[3]), .symbol_4(symbol[4]), .in_a(in[6]), .in_b(in[7]), .in_c(in[8]), .out_a(symbol_index[6]), .out_b(symbol_index[7]), .out_c(symbol_index[8]));
    indEncoder ind4(.clk(clk), .rst_n(rst_n), .symbol_0(symbol[0]), .symbol_1(symbol[1]), .symbol_2(symbol[2]), .symbol_3(symbol[3]), .symbol_4(symbol[4]), .in_a(in[9]), .in_b(in[10]), .in_c(in[11]), .out_a(symbol_index[9]), .out_b(symbol_index[10]), .out_c(symbol_index[11]));

    lenEncoder len1(.clk(clk), .rst_n(rst_n), .length_a(length[symbol_index[0]]), .length_b(length[symbol_index[1]]), .length_c(length[symbol_index[2]]), .len_a(symbol_len[0]), .len_b(symbol_len[1]), .len_c(symbol_len[2]));
    lenEncoder len2(.clk(clk), .rst_n(rst_n), .length_a(length[symbol_index[3]]), .length_b(length[symbol_index[4]]), .length_c(length[symbol_index[5]]), .len_a(symbol_len[3]), .len_b(symbol_len[4]), .len_c(symbol_len[5]));
    lenEncoder len3(.clk(clk), .rst_n(rst_n), .length_a(length[symbol_index[6]]), .length_b(length[symbol_index[7]]), .length_c(length[symbol_index[8]]), .len_a(symbol_len[6]), .len_b(symbol_len[7]), .len_c(symbol_len[8]));
    lenEncoder len4(.clk(clk), .rst_n(rst_n), .length_a(length[symbol_index[9]]), .length_b(length[symbol_index[10]]), .length_c(length[symbol_index[11]]), .len_a(symbol_len[9]), .len_b(symbol_len[10]), .len_c(symbol_len[11]));

    individualPreSum i1(.clk(clk), .rst_n(rst_n), .previous_sum(7'd0), .len_a(symbol_len[0]), .len_b(symbol_len[1]), .len_c(symbol_len[2]), .currentSum(individualPreSum[0]));
    individualPreSum i2(.clk(clk), .rst_n(rst_n), .previous_sum(individualPreSum[0]), .len_a(symbol_len[3]), .len_b(symbol_len[4]), .len_c(symbol_len[5]), .currentSum(individualPreSum[1]));
    individualPreSum i3(.clk(clk), .rst_n(rst_n), .previous_sum(individualPreSum[1]), .len_a(symbol_len[6]), .len_b(symbol_len[7]), .len_c(symbol_len[8]), .currentSum(individualPreSum[2]));
    individualPreSum i4(.clk(clk), .rst_n(rst_n), .previous_sum(individualPreSum[2]), .len_a(symbol_len[9]), .len_b(symbol_len[10]), .len_c(symbol_len[11]), .currentSum(individualPreSum[3]));

    prefixSum p1(.clk(clk), .rst_n(rst_n), .individualPreSum(individualPreSum[0]), .len_a(symbol_len[0]), .len_b(symbol_len[1]), .len_c(symbol_len[2]), .prefix_a(prefixSum[0]), .prefix_b(prefixSum[1]), .prefix_c(prefixSum[2]));
    prefixSum p2(.clk(clk), .rst_n(rst_n), .individualPreSum(individualPreSum[1]), .len_a(symbol_len[3]), .len_b(symbol_len[4]), .len_c(symbol_len[5]), .prefix_a(prefixSum[3]), .prefix_b(prefixSum[4]), .prefix_c(prefixSum[5]));
    prefixSum p3(.clk(clk), .rst_n(rst_n), .individualPreSum(individualPreSum[2]), .len_a(symbol_len[6]), .len_b(symbol_len[7]), .len_c(symbol_len[8]), .prefix_a(prefixSum[6]), .prefix_b(prefixSum[7]), .prefix_c(prefixSum[8]));
    prefixSum p4(.clk(clk), .rst_n(rst_n), .individualPreSum(individualPreSum[3]), .len_a(symbol_len[9]), .len_b(symbol_len[10]), .len_c(symbol_len[11]), .prefix_a(prefixSum[9]), .prefix_b(prefixSum[10]), .prefix_c(prefixSum[11]));
    
    encodeSeq e1(.clk(clk), .rst_n(rst_n), .encode_a(encode[symbol_index[0]]), .encode_b(encode[symbol_index[1]]), .encode_c(encode[symbol_index[2]]), .encodeSeq_a(encode_seq[0]), .encodeSeq_b(encode_seq[1]), .encodeSeq_c(encode_seq[2]));
    encodeSeq e2(.clk(clk), .rst_n(rst_n), .encode_a(encode[symbol_index[3]]), .encode_b(encode[symbol_index[4]]), .encode_c(encode[symbol_index[5]]), .encodeSeq_a(encode_seq[3]), .encodeSeq_b(encode_seq[4]), .encodeSeq_c(encode_seq[5]));
    encodeSeq e3(.clk(clk), .rst_n(rst_n), .encode_a(encode[symbol_index[6]]), .encode_b(encode[symbol_index[7]]), .encode_c(encode[symbol_index[8]]), .encodeSeq_a(encode_seq[6]), .encodeSeq_b(encode_seq[7]), .encodeSeq_c(encode_seq[8]));
    encodeSeq e4(.clk(clk), .rst_n(rst_n), .encode_a(encode[symbol_index[9]]), .encode_b(encode[symbol_index[10]]), .encode_c(encode[symbol_index[11]]), .encodeSeq_a(encode_seq[9]), .encodeSeq_b(encode_seq[10]), .encodeSeq_c(encode_seq[11]));

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
                if (valid) begin
                    next_state = `readInput;
                end
            end
            `readInput: begin
                if (input_i == 16'd3) begin
                    // $display("input data are: %c, %c, %c", in[9], in[10], in[11]);
                    // $display("change state");
                    next_state = `readSymbol;
                end
                else begin
                    // $display("input data are: %c, %c, %c", in[inputADDR], in[inputADDR+1], in[inputADDR+2]);
                    next_state = `store;
                end
            end
            `store: begin
                next_state = `readInput;
            end
            `readSymbol: begin
                // $display("input data are: %c, %c, %c, %c, %c, %c, %c, %c, %c, %c, %c, %c", in[0], in[1], in[2], in[3], in[4], in[5], in[6], in[7], in[8], in[9], in[10], in[11]);
                if(symbolADDR == 16'd4) next_state = `getIndex;
                else next_state = `store2;
            end
            `store2: begin
                next_state = `readSymbol;
            end
            `getIndex: begin
                // $display("Indexs are: %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d", symbol_index[0], symbol_index[1], symbol_index[2], symbol_index[3], symbol_index[4], symbol_index[5], symbol_index[6], symbol_index[7], symbol_index[8], symbol_index[9], symbol_index[10], symbol_index[11]);
                // $display("DONE");
                next_state = `readLength;
            end
            `readLength: begin
                if(lengthADDR == 16'd4) begin
                    next_state = `readEncode;
                end
                else begin
                    next_state = `store3;
                end
            end
            `store3: begin
                next_state = `readLength;
            end
            `readEncode: begin  
                if(encodeADDR == 16'd4) begin
                    next_state = `generateEncodeSeq;
                end
                else begin
                    next_state = `store4;
                end
                $display("Prefix sum are: %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d", prefixSum[0], prefixSum[1], prefixSum[2], prefixSum[3], prefixSum[4], prefixSum[5], prefixSum[6], prefixSum[7], prefixSum[8], prefixSum[9], prefixSum[10], prefixSum[11]);
            end
            `store4: begin
                next_state = `readEncode;
            end
            `generateEncodeSeq: begin
                // next_wen_1 = 1;
                if(index == 8'd3) begin
                    next_state = `check;
                end
                else begin
                    next_state = `store5;
                end
            end
            `store5: begin
                next_state = `generateEncodeSeq;
            end
            `check: begin
                if(inputADDR == 12) begin
                    $display(" done ");
                    next_state = `DONE;
                end
                else begin
                    next_state = `init;
                end
            end
            `DONE: begin
                next_wen_1 = 0;
                next_wen_2 = 0;
                next_wen_3 = 0;
                next_wen_4 = 0;
                Ready = 1;
  
                // $display("Indexs are: %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d", symbol_index[0], symbol_index[1], symbol_index[2], symbol_index[3], symbol_index[4], symbol_index[5], symbol_index[6], symbol_index[7], symbol_index[8], symbol_index[9], symbol_index[10], symbol_index[11]);
                // $display("Lengths are: %d, %d, %d, %d, %d", length[0], length[1], length[2], length[3], length[4]);
                // $display("Each symbol lengths are: %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d", symbol_len[0], symbol_len[1], symbol_len[2], symbol_len[3], symbol_len[4], symbol_len[5], symbol_len[6], symbol_len[7], symbol_len[8], symbol_len[9], symbol_len[10], symbol_len[11]);
                $display("Individual prefix sum is: %d, %d, %d, %d", individualPreSum[0], individualPreSum[1], individualPreSum[2], individualPreSum[3]);
                // $display("Prefix sum are: %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d", prefixSum[0], prefixSum[1], prefixSum[2], prefixSum[3], prefixSum[4], prefixSum[5], prefixSum[6], prefixSum[7], prefixSum[8], prefixSum[9], prefixSum[10], prefixSum[11]);
                // $display("Encodes are: %d, %d, %d, %d, %d", encode[0], encode[1], encode[2], encode[3], encode[4]);
                // $display("Encode sequence are: %b, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d", encode_seq[0], encode_seq[1], encode_seq[2], encode_seq[3], encode_seq[4], encode_seq[5], encode_seq[6], encode_seq[7], encode_seq[8], encode_seq[9], encode_seq[10], encode_seq[11]);
                // $display(encode_seq[0][1]);
                $display("it's done");
                // $display("%b", 8'd10 >> 3);
            end
            default: begin
                next_state = `init;
            end
        endcase
    end

    // generate encode sequence
    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            index = 255;
            outputADDR_1 = 16'd0;
            wen_1 = 0;
            round = 0;
            output_1 = 0;

            outputADDR_2 = 16'd0;
            wen_2 = 0;
            output_2 = 0;

            outputADDR_3 = 16'd0;
            wen_3 = 0;
            output_3 = 0;

            outputADDR_4 = 16'd0;
            wen_4 = 0;
            output_4 = 0;
        end
        else begin
            index = next_index;
            outputADDR_1 = next_outputADDR_1;
            wen_1 = next_wen_1;
            round = next_round;
            output_1 = next_output_1;
   
            outputADDR_2 = next_outputADDR_2;
            wen_2 = next_wen_2;
            output_2 = next_output_2;

            outputADDR_3 = next_outputADDR_3;
            wen_3 = next_wen_3;
            output_3 = next_output_3;

            outputADDR_4 = next_outputADDR_4;
            wen_4 = next_wen_4;
            output_4 = next_output_4;
        end
    end

    always @(*) begin
        next_index = index;
        next_outputADDR_1 = outputADDR_1;
        next_wen_1 = 0;
        next_round = round;
        next_output_1 = output_1;

        next_outputADDR_2 = outputADDR_2;
        next_wen_2 = 0;
        next_output_2 = output_2;

        next_outputADDR_3 = outputADDR_3;
        next_wen_3 = 0;
        next_output_3 = output_3;

        next_outputADDR_4 = outputADDR_4;
        next_wen_4 = 0;
        next_output_4 = output_4;
        if(state == `init) begin
            next_index = 255;
            next_round = round + 1;
        end
        else if(state == `generateEncodeSeq) begin
            next_index = index + 1;
            next_wen_1 = 1;
            next_outputADDR_1 = prefixSum[index] >> 3;
            next_output_1 = encode_seq[index] << (16 - symbol_len[index] - (prefixSum[index]-(prefixSum[index] >> 3)*8));
            // $display(encode_seq[index]);
            $display("%d", next_outputADDR_1);
            next_wen_2 = 1;
            next_outputADDR_2 = prefixSum[3+index] >> 3;
            next_output_2 = encode_seq[3+index] << (16 - symbol_len[3+index] - (prefixSum[3+index]-(prefixSum[3+index] >> 3)*8));
            // $display(prefixSum[index+3]);
            // $display("%b", next_output_2);
            next_wen_3 = 1;
            next_outputADDR_3 = prefixSum[6+index] >> 3;
            next_output_3 = encode_seq[6+index] << (16 - symbol_len[6+index] - (prefixSum[6+index]-(prefixSum[6+index] >> 3)*8));

            next_wen_4 = 1;
            next_outputADDR_4 = prefixSum[9+index] >> 3;
            next_output_4 = encode_seq[9+index] << (16 - symbol_len[9+index] - (prefixSum[9+index]-(prefixSum[9+index] >> 3)*8));
            // $display("%b", next_output_4);
            // $display(count);
        end
    end

    // input
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            inputADDR = 16'd0;
            count = 0;
            input_i = 0;
            in[0]  = 8'd0;
            in[1]  = 8'd0;
            in[2]  = 8'd0;
            in[3]  = 8'd0;
            in[4]  = 8'd0;
            in[5]  = 8'd0;
            in[6]  = 8'd0;
            in[7]  = 8'd0;
            in[8]  = 8'd0;
            in[9]  = 8'd0;
            in[10] = 8'd0;
            in[11] = 8'd0;
        end
        else begin
            inputADDR = next_inputADDR;
            input_i = next_input_i;
            count = next_count;
            in[0]  = next_in[0];
            in[1]  = next_in[1];
            in[2]  = next_in[2];
            in[3]  = next_in[3];
            in[4]  = next_in[4];
            in[5]  = next_in[5];
            in[6]  = next_in[6];
            in[7]  = next_in[7];
            in[8]  = next_in[8];
            in[9]  = next_in[9];
            in[10] = next_in[10];
            in[11] = next_in[11];
        end
    end
    always @(*) begin
        next_inputADDR = inputADDR;
        next_count = count;
        next_input_i = input_i;
        next_in[0] = in[0];
        next_in[1] = in[1];
        next_in[2] = in[2];
        next_in[3] = in[3];
        next_in[4] = in[4];
        next_in[5] = in[5];
        next_in[6] = in[6];
        next_in[7] = in[7];
        next_in[8] = in[8];
        next_in[9] = in[9];
        next_in[10] = in[10];
        next_in[11] = in[11];
        
        // $display(count);
        if (state == `init) begin
            next_input_i = 0;
            next_in[0] = 8'd0;
            next_in[1] = 8'd0;
            next_in[2] = 8'd0;
            next_in[3] = 8'd0;
            next_in[4] = 8'd0;
            next_in[5] = 8'd0;
            next_in[6] = 8'd0;
            next_in[7] = 8'd0;
            next_in[8] = 8'd0;
            next_in[9] = 8'd0;
            next_in[10] = 8'd0;
            next_in[11] = 8'd0;
        end
        else if (state == `readInput) begin
            // $display("%d", inputADDR);
            // if(input_i < 3) begin
            //     next_input_i = input_i + 1;
            // end
            // else begin
            //     next_input_i = 0;
            //     next_count = count + 1;
            // end
            next_input_i = input_i + 1;
            next_inputADDR = inputADDR + 3;
            // $display(count);
            next_in[input_i*3] = input_rdata[7:0];
            next_in[input_i*3+1] = input_rdata[15:8];
            next_in[input_i*3+2] = input_rdata[23:16];
            // $display("input data are: %c, %c, %c", input_rdata[7:0], input_rdata[15:8], input_rdata[23:16]);
        end
    end
    // symbol
    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            symbolADDR = 16'd0;
            symbol[0] = 8'd0;
            symbol[1] = 8'd0;
            symbol[2] = 8'd0;
            symbol[3] = 8'd0;
            symbol[4] = 8'd0;
        end
        else  begin
            symbolADDR = next_symbolADDR;
            symbol[0] = next_symbol[0];
            symbol[1] = next_symbol[1];
            symbol[2] = next_symbol[2];
            symbol[3] = next_symbol[3];
            symbol[4] = next_symbol[4];
        end
    end

    always @(*) begin
        next_symbolADDR = symbolADDR;
        next_symbol[0] = symbol[0];
        next_symbol[1] = symbol[1];
        next_symbol[2] = symbol[2];
        next_symbol[3] = symbol[3];
        next_symbol[4] = symbol[4];

        if(state == `init) begin
            next_symbolADDR = 16'd0;
            symbol[0] = 8'd0;
            symbol[1] = 8'd0;
            symbol[2] = 8'd0;
            symbol[3] = 8'd0;
            symbol[4] = 8'd0;
        end
        else if(state == `readSymbol) begin
            next_symbolADDR = symbolADDR + 1;
            next_symbol[symbolADDR] = symbol_rdata[7:0];
        end
    end
    // length
    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            lengthADDR = 16'd0;
            length[0] = 8'd0;
            length[1] = 8'd0;
            length[2] = 8'd0;
            length[3] = 8'd0;
            length[4] = 8'd0;
        end
        else  begin
            lengthADDR = next_lengthADDR;
            length[0] = next_length[0];
            length[1] = next_length[1];
            length[2] = next_length[2];
            length[3] = next_length[3];
            length[4] = next_length[4];
        end
    end

    always @(*) begin
        next_lengthADDR = lengthADDR;
        next_length[0] = length[0];
        next_length[1] = length[1];
        next_length[2] = length[2];
        next_length[3] = length[3];
        next_length[4] = length[4];

        if(state == `init) begin
            next_lengthADDR = 16'd0;
            length[0] = 8'd0;
            length[1] = 8'd0;
            length[2] = 8'd0;
            length[3] = 8'd0;
            length[4] = 8'd0;
        end
        else if(state == `readLength) begin
            next_lengthADDR = lengthADDR + 1;
            next_length[lengthADDR] = length_rdata[7:0];
        end
    end
    // Encode
    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            encodeADDR = 16'd0;
            encode[0] = 8'd0;
            encode[1] = 8'd0;
            encode[2] = 8'd0;
            encode[3] = 8'd0;
            encode[4] = 8'd0;
        end
        else  begin
            encodeADDR = next_encodeADDR;
            encode[0] = next_encode[0];
            encode[1] = next_encode[1];
            encode[2] = next_encode[2];
            encode[3] = next_encode[3];
            encode[4] = next_encode[4];
        end
    end

    always @(*) begin
        next_encodeADDR = encodeADDR;
        next_encode[0] = encode[0];
        next_encode[1] = encode[1];
        next_encode[2] = encode[2];
        next_encode[3] = encode[3];
        next_encode[4] = encode[4];

        if(state == `init) begin
            next_encodeADDR = 16'd0;
            encode[0] = 8'd0;
            encode[1] = 8'd0;
            encode[2] = 8'd0;
            encode[3] = 8'd0;
            encode[4] = 8'd0;
        end
        else if(state == `readEncode) begin
            next_encodeADDR = encodeADDR + 1;
            next_encode[encodeADDR] = encode_rdata[7:0];
        end
    end

    assign input_addr = inputADDR;
    assign symbol_addr = symbolADDR;
    assign length_addr = lengthADDR;
    assign encode_addr = encodeADDR;
    assign output_addr_d1 = outputADDR_1;
    assign output_addr_d2 = outputADDR_2;
    assign output_addr_d3 = outputADDR_3;
    assign output_addr_d4 = outputADDR_4;
    assign output_wen_d1 = wen_1;
    assign output_wen_d2 = wen_2;
    assign output_wen_d3 = wen_3;
    assign output_wen_d4 = wen_4;
    assign output_wdata_d1 = output_1;
    assign output_wdata_d2 = output_2;
    assign output_wdata_d3 = output_3;
    assign output_wdata_d4 = output_4;



endmodule

module indEncoder (
    input clk, 
    input rst_n, 
    input [7:0] symbol_0,
    input [7:0] symbol_1,
    input [7:0] symbol_2,
    input [7:0] symbol_3,
    input [7:0] symbol_4,
    input [7:0] in_a,
    input [7:0] in_b,
    input [7:0] in_c,
    output [7:0] out_a,
    output [7:0] out_b,
    output [7:0] out_c
);

    reg [7:0] temp_a, temp_b, temp_c;

    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            temp_a = 0;
            temp_b = 0;
            temp_c = 0;
        end
        else begin
            if(in_a == symbol_0) begin
                temp_a = 8'd0;
            end
            else if(in_a == symbol_1) begin
                temp_a = 8'd1;
            end
            else if(in_a == symbol_2) begin
                temp_a = 8'd2;
            end
            else if(in_a == symbol_3) begin
                temp_a = 8'd3;
            end
            else if(in_a == symbol_4) begin
                temp_a = 8'd4;
            end

            if(in_b == symbol_0) begin
                temp_b = 8'd0;
            end
            else if(in_b == symbol_1) begin
                temp_b = 8'd1;
            end
            else if(in_b == symbol_2) begin
                temp_b = 8'd2;
            end
            else if(in_b == symbol_3) begin
                temp_b = 8'd3;
            end
            else if(in_b == symbol_4) begin
                temp_b = 8'd4;
            end

            if(in_c == symbol_0) begin
                temp_c = 8'd0;
            end
            else if(in_c == symbol_1) begin
                temp_c = 8'd1;
            end
            else if(in_c == symbol_2) begin
                temp_c = 8'd2;
            end
            else if(in_c == symbol_3) begin
                temp_c = 8'd3;
            end
            else if(in_c == symbol_4) begin
                temp_c = 8'd4;
            end
        end
    end

    assign out_a = temp_a;
    assign out_b = temp_b;
    assign out_c = temp_c;
    
endmodule

module encodeSeq (
    input clk,
    input rst_n,
    input [7:0] encode_a,
    input [7:0] encode_b,
    input [7:0] encode_c,
    output [15:0] encodeSeq_a,
    output [15:0] encodeSeq_b,
    output [15:0] encodeSeq_c
);
    reg [7:0] temp_a;
    reg [7:0] temp_b;
    reg [7:0] temp_c;

    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            temp_a = 0;
            temp_b = 0;
            temp_b = 0;
        end
        else begin
            temp_a = encode_a;
            temp_b = encode_b;
            temp_c = encode_c;
        end
    end

    assign encodeSeq_a = temp_a;
    assign encodeSeq_b = temp_b;
    assign encodeSeq_c = temp_c;
    
endmodule


module lenEncoder (
    input clk,
    input rst_n,
    input [7:0] length_a,
    input [7:0] length_b,
    input [7:0] length_c,
    output [7:0] len_a,
    output [7:0] len_b,
    output [7:0] len_c
);
    reg [7:0] temp_a, temp_b, temp_c;

    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            temp_a = 0;
            temp_b = 0;
            temp_c = 0;
        end
        else begin
            temp_a = length_a;
            temp_b = length_b;
            temp_c = length_c;
        end
    end

    assign len_a = temp_a;
    assign len_b = temp_b;
    assign len_c = temp_c;
    
endmodule

module prefixSum (
    input clk,
    input rst_n,
    input [7:0] individualPreSum,
    input [7:0] len_a,
    input [7:0] len_b,
    input [7:0] len_c,
    output [7:0] prefix_a,
    output [7:0] prefix_b,
    output [7:0] prefix_c
);

    reg [7:0] temp_a, temp_b, temp_c;

    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            temp_a = 0;
            temp_b = 0;
            temp_c = 0;
        end
        else begin
            temp_c = individualPreSum - len_c;
            temp_b = temp_c - len_b;
            temp_a = temp_b - len_a;
        end
    end

    assign prefix_a = temp_a;
    assign prefix_b = temp_b;
    assign prefix_c = temp_c;

    
endmodule

module individualPreSum (
    input clk,
    input rst_n,
    input [7:0] previous_sum,
    input [7:0] len_a,
    input [7:0] len_b,
    input [7:0] len_c,
    output [7:0] currentSum
);
    reg [7:0] temp;

    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            temp = 0;
        end
        else begin
            temp = previous_sum + len_a + len_b+ len_c;
        end

    end

    assign currentSum = temp;
    
endmodule