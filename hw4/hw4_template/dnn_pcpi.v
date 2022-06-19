module DNN_PCPI(
	input             clk, resetn,
	input             pcpi_valid,
	input      [31:0] pcpi_insn,
	input      [31:0] pcpi_rs1,
	input      [31:0] pcpi_rs2,
	output            pcpi_wr,
	output     [31:0] pcpi_rd,
	output            pcpi_wait,
	output            pcpi_ready,

	//memory interface 0
	input      [31:0] mem_rdata_0,
	input             mem_ready_0,
	output            mem_valid_0,
	output            mem_write_0,
	output     [31:0] mem_addr_0,
	output     [31:0] mem_wdata_0,

	//memory interface 1
	input      [31:0] mem_rdata_1,
	input             mem_ready_1,
	output            mem_valid_1,
	output            mem_write_1,
	output     [31:0] mem_addr_1,
	output     [31:0] mem_wdata_1,
		
	//memory interface 2
	input      [31:0] mem_rdata_2,
	input             mem_ready_2,
	output            mem_valid_2,
	output            mem_write_2,
	output     [31:0] mem_addr_2,
	output     [31:0] mem_wdata_2
);
	// your DNN wire
	wire conv, output_wen;
	wire [15:0] input_addr, weight_addr, output_addr;
	wire [31:0] input_rdata, weight_rdata, output_rdata, output_wdata;
	wire [31:0] N, C, H, W, R, S, M, P, Q;
	wire [31:0] input_offset, weight_offset, output_offset;

	wire pcpi_insn_valid = pcpi_valid && pcpi_insn[6:0] == 7'b0101011 && pcpi_insn[31:25] == 7'b0000001;

	// PCPI interface. Modify these values to fit your needs
	assign pcpi_wr = 1;
	assign pcpi_rd = 0;

	// Memory interface. Modify these values to fit your needs
	assign mem_valid_0 = 1;
	assign mem_write_0 = 0;
	assign mem_wdata_0 = 0;
	assign mem_addr_0 = input_addr  + input_offset;
	assign input_rdata = mem_rdata_0;

	assign mem_valid_1 = 1;
	assign mem_write_1 = 0;
	assign mem_wdata_1 = 0;
	assign mem_addr_1 = weight_addr + weight_offset;
	assign weight_rdata = mem_rdata_1;

	assign mem_valid_2 = 1;
	assign mem_write_2 = output_wen;
	assign mem_wdata_2 = output_wdata;
	assign mem_addr_2 = (output_addr << 2) + output_offset;
	assign output_rdata = mem_rdata_2;

	// Implement your DNN design below
	assign conv = 0;
	assign N = 0;
	assign C = 0;
	assign H = 0;
	assign W = 0;
	assign R = 0;
	assign S = 0;
	assign M = 0;
	assign P = 0;
	assign Q = 0;

	top top01(
    	.clk(clk),
    	.rst_n(resetn),
    	.valid(pcpi_insn_valid),
    	.conv(conv),
    	.Wait(pcpi_wait),
    	.Ready(pcpi_ready),
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
endmodule

module top (
    input clk,
    input rst_n,
    input valid,
    input conv,
    output reg Wait,
    output reg Ready,
    output [15:0] input_addr,
    input [31:0] input_rdata,
    output [15:0] weight_addr,
    input [31:0] weight_rdata,
    output output_wen,
    output [15:0] output_addr,
    input  signed [31:0] output_rdata,
    output signed [31:0] output_wdata,
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

// remove this block and add your code
always @(posedge clk) begin
    Ready <= valid;
end

endmodule