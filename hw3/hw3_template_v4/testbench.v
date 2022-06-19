`define INPUT_SOURCE    "input_fc.csv"
`define WEIGHT_SOURCE   "weight_fc.csv"
`define OUTPUT_GOLDEN   "output_fc.csv"
`define OUTPUT_LOG      "out_log.txt"
`define FSDB_FILE       "filter.fsdb"
`define FSDB_SYN_FILE   "filter_syn.fsdb"
`timescale 1ns/1ps

// define your config
//Conv: 1
//FC  : 0
`define CONV 0

//Conv: 16, 6, 25, 1
//FC  : 1, 1, 84, 120
`define weight_out_channel 1
`define weight_in_channel 1
`define weight_height 84
`define weight_width 120

//Conv: 1, 6, 100, 25
//FC  : 1, 1, 120, 1
`define input_num 1
`define input_channel 1
`define input_height 120
`define input_width 1

//Conv: 1, 16, 100, 1
//FC  : 1, 1, 84, 1
`define output_num 1
`define output_channel 1
`define output_height 84
`define output_width 1

module testbench (
    output reg clk,
    output reg rst_n,
    output reg valid,
    input wire Wait,
    input wire Ready,
    input [15:0] input_addr,
    output signed [31:0] input_rdata,
    input [15:0] weight_addr,
    output signed [31:0] weight_rdata,
    input output_wen,
    input [15:0] output_addr,
    input signed [31:0] output_rdata,
    input signed [31:0] output_wdata,
    output reg conv,
    output [31:0] N,
    output [31:0] C,
    output [31:0] H,
    output [31:0] W,
    output [31:0] R,
    output [31:0] S,
    output [31:0] M,
    output [31:0] P,
    output [31:0] Q
);

assign N = `input_num;
assign C = `input_channel;
assign H = `input_height;
assign W = `input_width;
assign R = `weight_height;
assign S = `weight_width;
assign M = `output_channel;
assign P = `output_height;
assign Q = `output_width;

integer output_file, golden_file;
integer i,j,k,l, index;

reg signed [7:0] temp_data[0:65535];
reg signed [31:0] golden[0:65535];

parameter period = 40;
parameter delay = 10;

input_sram input_ram(
  .clk(clk),
  .wen(1'b0),
  .addr(input_addr),
  .d(32'h0),
  .q(input_rdata)
);

weight_sram weight_ram(
  .clk(clk),
  .wen(1'b0),
  .addr(weight_addr),
  .d(32'h0),
  .q(weight_rdata)
);

output_sram output_ram(
  .clk(clk),
  .wen(output_wen),
  .addr(output_addr),
  .d(output_wdata),
  .q(output_rdata)
);

top top01(
    .clk(clk),
    .rst_n(rst_n),
    .valid(valid),
    .conv(conv),
    .Wait(Wait),
    .Ready(Ready),
    .input_addr(input_addr),
    .input_rdata(input_rdata),
    .weight_addr(weight_addr),
    .weight_rdata(weight_rdata),
    .output_wen(output_wen),
    .output_addr(output_addr),
    .output_rdata(output_rdata),
    .output_wdata(output_wdata),
    .N(N),
    .C(C),
    .H(H),
    .W(W),
    .R(R),
    .S(S),
    .M(M),
    .P(P),
    .Q(Q)
);

// debug flag
integer debug, correct;
integer start_time, end_time;

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
        for(i=0; i< `output_num; i= i+1) begin
            for(j=0; j< `output_channel; j= j+1) begin
                for(k=0; k< `output_height; k= k+1) begin
                    for(l=0; l< `output_width; l=l+1) begin
                        index = ((i * `output_channel + j) * `output_height + k) * `output_width + l;
                        $fscanf(golden_file,"%e", golden[index]);
                    end
                end
            end
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
        conv = `CONV;
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
        for(i=0; i< `output_num; i= i+1) begin
            for(j=0; j< `output_channel; j= j+1) begin
                for(k=0; k< `output_height; k= k+1) begin
                    for(l=0; l< `output_width; l=l+1) begin
                        index = ((i * `output_channel + j) * `output_height + k) * `output_width + l;
                        $fwrite(output_file, "%d\n", output_ram.ram[index]);
                        if (debug >= 3) begin
                            if (!(golden[index] === output_ram.ram[index])) begin
                                correct = 0;
                                $display("[Error  ] golden[%d]=%d | data[%d]=%d", index, golden[index], index, output_ram.ram[index]);
                            end else
                                $display("[Success] golden[%d]=%d | data[%d]=%d", index, golden[index], index, output_ram.ram[index]);
                        end
                    end
                end
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
