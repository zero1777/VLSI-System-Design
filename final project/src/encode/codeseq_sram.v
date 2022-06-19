module codeseq_sram(
  input clk,
  input wen,
  input [15:0] addr,
  input signed [31:0] d,
  output [31:0] q
);

parameter delay = 0;
reg signed [7:0] ram [0:65535];
reg [15:0] read_addr;

integer i, j, k, l;
integer codeseq_file;
integer index, cnt;

  initial begin
    // Read the input codeseq csv and load the codeseq
    codeseq_file = $fopen(`codeseq_SOURCE, "r");
    $display(">> Reading the codeseq file: %s", `codeseq_SOURCE);
        index = 0;
        ram[0] = 8'b11010001;
        ram[1] = 8'b11101010;
        ram[2] = 8'b10101111;
        ram[3] = 8'b11111100;
        ram[4] = 8'b10011000;
        ram[5] = 8'b00001011;
        ram[6] = 8'b01000110;
        ram[7] = 8'b11010011;
        ram[8] = 8'b01111101;
        ram[9] = 8'b10000000;
    $fclose(codeseq_file);
  end

  always @(posedge clk) begin
    if (wen == 1)
      ram[addr] <= d;
    read_addr <= addr;
  end

  assign #delay q = {ram[read_addr+3], ram[read_addr+2], ram[read_addr+1], ram[read_addr]};

endmodule
