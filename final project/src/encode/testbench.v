`define gaparr_SOURCE   "gaparr.txt"
`define codeseq_SOURCE  "codeseq.txt"
`define idx_SOURCE      "idx.txt"
`define OUTPUT_GOLDEN   "output.txt"
`define OUTPUT_LOG      "out_log.txt"
`define input_SOURCE    "input.txt"
`define symbol_SOURCE   "symbol.txt"
`define length_SOURCE   "length.txt"
`define encode_SOURCE   "encode.txt"
`define FSDB_FILE       "filter.fsdb"
`define FSDB_SYN_FILE   "filter_syn.fsdb"
`timescale 1ns/1ps

// define your config
`define length 65
`define symbol_num 5

module testbench (
    output reg clk,
    output reg rst_n,
    output reg valid,
    input wire Wait,
    input wire Ready,
    input [15:0] input_addr,
    output [31:0] input_rdata,
    input [15:0] symbol_addr,
    output [31:0] symbol_rdata,
    input [15:0] length_addr,
    output [31:0] length_rdata,
    input [15:0] encode_addr,
    output [31:0] encode_rdata,
    input output_wen_d1,
    input [7:0] output_len_d1,
    input [7:0] output_from_d1,
    input [15:0] output_addr_d1,
    input [15:0] output_rdata_d1,
    input [15:0] output_wdata_d1,
    input output_wen_d2,
    input [7:0] output_len_d2,
    input [7:0] output_from_d2,
    input [15:0] output_addr_d2,
    input [15:0] output_rdata_d2,
    input [15:0] output_wdata_d2,
    input output_wen_d3,
    input [7:0] output_len_d3,
    input [7:0] output_from_d3,
    input [15:0] output_addr_d3,
    input [15:0] output_rdata_d3,
    input [15:0] output_wdata_d3,
    input output_wen_d4,
    input [7:0] output_len_d4,
    input [7:0] output_from_d4,
    input [15:0] output_addr_d4,
    input [15:0] output_rdata_d4,
    input [15:0] output_wdata_d4,
    output [31:0] LEN,
    output [31:0] NUM
);


assign LEN = `length;
assign NUM = `symbol_num;

integer output_file, golden_file;
integer i,j,k,l, index;

reg signed [7:0] temp_data[0:65535];
reg signed [7:0] golden[0:65535];

parameter period = 40;
parameter delay = 10;

`ifdef SYNTHESIS
    input_sram  #(.delay(`MEM_DELAY)) input_ram(.clk(clk),.wen(1'b0),.addr(input_addr),.d(32'h0),.q(input_rdata));
    symbol_sram #(.delay(`MEM_DELAY)) symbol_ram(.clk(clk),.wen(1'b0),.addr(symbol_addr),.d(32'h0),.q(symbol_rdata));
    length_sram #(.delay(`MEM_DELAY)) length_ram(.clk(clk),.wen(1'b0),.addr(length_addr),.d(32'h0),.q(length_rdata));
    encode_sram #(.delay(`MEM_DELAY)) encode_ram(.clk(clk),.wen(1'b0),.addr(encode_addr),.d(32'h0),.q(encode_rdata));
    output_sram #(.delay(`MEM_DELAY)) output_ram(.clk(clk),
    .wen_d1(output_wen_d1),.len_d1(output_len_d1),.from_d1(output_from_d1),.addr_d1(output_addr_d1),.d_d1(output_wdata_d1),.q_d1(output_rdata_d1),
    .wen_d2(output_wen_d2),.len_d2(output_len_d2),.from_d2(output_from_d2),.addr_d2(output_addr_d2),.d_d2(output_wdata_d2),.q_d2(output_rdata_d2),
    .wen_d3(output_wen_d3),.len_d3(output_len_d3),.from_d3(output_from_d3),.addr_d3(output_addr_d3),.d_d3(output_wdata_d3),.q_d3(output_rdata_d3),
    .wen_d4(output_wen_d4),.len_d4(output_len_d4),.from_d4(output_from_d4),.addr_d4(output_addr_d4),.d_d4(output_wdata_d4),.q_d4(output_rdata_d4));
`else
    input_sram  #(.delay(0)) input_ram(.clk(clk),.wen(1'b0),.addr(input_addr),.d(32'h0),.q(input_rdata));
    symbol_sram #(.delay(0)) symbol_ram(.clk(clk),.wen(1'b0),.addr(symbol_addr),.d(32'h0),.q(symbol_rdata));
    length_sram #(.delay(0)) length_ram(.clk(clk),.wen(1'b0),.addr(length_addr),.d(32'h0),.q(length_rdata));
    encode_sram #(.delay(0)) encode_ram(.clk(clk),.wen(1'b0),.addr(encode_addr),.d(32'h0),.q(encode_rdata));
    output_sram #(.delay(0)) output_ram(.clk(clk),
    .wen_d1(output_wen_d1),.len_d1(output_len_d1),.from_d1(output_from_d1),.addr_d1(output_addr_d1),.d_d1(output_wdata_d1),.q_d1(output_rdata_d1),
    .wen_d2(output_wen_d2),.len_d2(output_len_d2),.from_d2(output_from_d2),.addr_d2(output_addr_d2),.d_d2(output_wdata_d2),.q_d2(output_rdata_d2),
    .wen_d3(output_wen_d3),.len_d3(output_len_d3),.from_d3(output_from_d3),.addr_d3(output_addr_d3),.d_d3(output_wdata_d3),.q_d3(output_rdata_d3),
    .wen_d4(output_wen_d4),.len_d4(output_len_d4),.from_d4(output_from_d4),.addr_d4(output_addr_d4),.d_d4(output_wdata_d4),.q_d4(output_rdata_d4));
`endif

top top01(
    .clk(clk),
    .rst_n(rst_n),
    .valid(valid),
    .Wait(Wait),
    .Ready(Ready),
    .input_addr(input_addr),
    .input_rdata(input_rdata),
    .symbol_addr(symbol_addr),
    .symbol_rdata(symbol_rdata),
    .length_addr(length_addr),
    .length_rdata(length_rdata),
    .encode_addr(encode_addr),
    .encode_rdata(encode_rdata),
    .output_wen_d1(output_wen_d1),
    .output_len_d1(output_len_d1),
    .output_from_d1(output_from_d1),
    .output_addr_d1(output_addr_d1),
    .output_wdata_d1(output_wdata_d1),
    .output_wen_d2(output_wen_d2),
    .output_len_d2(output_len_d2),
    .output_from_d2(output_from_d2),
    .output_addr_d2(output_addr_d2),
    .output_wdata_d2(output_wdata_d2),
    .output_wen_d3(output_wen_d3),
    .output_len_d3(output_len_d3),
    .output_from_d3(output_from_d3),
    .output_addr_d3(output_addr_d3),
    .output_wdata_d3(output_wdata_d3),
    .output_wen_d4(output_wen_d4),
    .output_len_d4(output_len_d4),
    .output_from_d4(output_from_d4),
    .output_addr_d4(output_addr_d4),
    .output_wdata_d4(output_wdata_d4),
    .LEN(LEN),
    .NUM(NUM)
);

// debug flag
integer debug, correct;
integer start_time, end_time;
integer cc;

    initial begin
        `ifdef SYNTHESIS
            $sdf_annotate("./top_syn.sdf", top01);
            $fsdbDumpfile(`FSDB_SYN_FILE);
        `else
            $fsdbDumpfile(`FSDB_FILE);
        `endif
            $fsdbDumpvars;
    end

    initial begin
        // setting the debug level
        if ($value$plusargs("debug=%d", debug)) begin
            $display(">> Debug level =%d", debug);
        end else begin
            debug = 0;
        end

        golden_file = $fopen(`OUTPUT_GOLDEN, "r");
        output_file = $fopen(`OUTPUT_LOG, "w");

        // Read the golden csv
        $display(">> Reading the golden file: %s", `OUTPUT_GOLDEN);
        index = 0;
        while ($fscanf(golden_file, "%b", cc) != -1) begin
          golden[index] = cc;
          index = index + 1;
        end
        $fclose(golden_file);

    end

    // create the clock
    always #(period/2) clk = ~clk;

    // test pattern
    initial begin
        clk = 0;
        rst_n = 1;
        valid = 0;
        #(delay) rst_n = 0;
        #(period) rst_n = 1;
        #(period) valid = 1;
        start_time = $time;

        @(posedge Ready)
        end_time = $time;
        valid = 0;

        // Read and check the output with golden data
        $display(">> Check the output data");
        correct = 1;
        for (index=0; index<29; index=index+1) begin
            if (debug >= 3) begin
                if (!(golden[index] === output_ram.ram[index])) begin
                    correct = 0;
                    $display("[Error  ] golden[%d]=%b | data[%d]=%b", index, golden[index], index, output_ram.ram[index]);
                end else
                    $display("[Success] golden[%d]=%b | data[%d]=%b", index, golden[index], index, output_ram.ram[index]);
            end
        end

        if (correct)
            $display("[\033[0;32mCongratulation!\033[0m] all value are correct!");
        else
            $display("[\033[0;31mWrong\033[0m] debug and try it again!");

        $display("[\033[0;34mTime usage\033[0m] %d ns", end_time - start_time);
        #(period*100)
        $finish;
    end
endmodule
