module output_sram(
  input clk,
  input wen_d1,
  input [15:0] addr_d1,
  input  [7:0] d_d1,
  output  [31:0] q_d1,
  input wen_d2,
  input [15:0] addr_d2,
  input  [7:0] d_d2,
  output  [31:0] q_d2,
  input wen_d3,
  input [15:0] addr_d3,
  input  [7:0] d_d3,
  output  [31:0] q_d3,
  input wen_d4,
  input [15:0] addr_d4,
  input  [7:0] d_d4,
  output  [31:0] q_d4
);

parameter delay = 0;
reg  [7:0] ram [0:65535];
reg [15:0] read_addr_d1;
reg [15:0] read_addr_d2;
reg [15:0] read_addr_d3;
reg [15:0] read_addr_d4;
integer i, j;

  initial begin
    // initial the memory
    for(i=0;i<65536;i=i+1) begin
      ram[i] = 0;
    end
  end

  always @(posedge clk) begin
    if (wen_d1 == 1) begin
      ram[addr_d1] <= d_d1;
    end

    if (wen_d2 == 1) begin
      ram[addr_d2] <= d_d2;
    end

    if (wen_d3 == 1) begin
      ram[addr_d3] <= d_d3;
    end

    if (wen_d4 == 1) begin
      ram[addr_d4] <= d_d4;
    end

    read_addr_d1 <= addr_d1;
    read_addr_d2 <= addr_d2;
    read_addr_d3 <= addr_d3;
    read_addr_d4 <= addr_d4;
  end

  assign #delay q_d1 = ram[read_addr_d1];
  assign #delay q_d2 = ram[read_addr_d2];
  assign #delay q_d3 = ram[read_addr_d3];
  assign #delay q_d4 = ram[read_addr_d4];

endmodule
