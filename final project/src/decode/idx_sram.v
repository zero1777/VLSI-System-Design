module idx_sram(
  input clk,
  input wen,
  input [15:0] addr,
  input [31:0] d,
  output [31:0] q
);

parameter delay = 0;
reg [7:0] ram [0:65535];
reg [15:0] read_addr;

integer i, j, k, l;
integer idx_file;
integer index, cc;

  initial begin
    // Read the input idx csv and load the idx
    idx_file = $fopen(`idx_SOURCE, "r");
    $display(">> Reading the idx file: %s", `idx_SOURCE);
        index = 0;
        while ($fscanf(idx_file, "%d", cc) != -1) begin
          ram[index] = cc;
          index = index + 1;
        end
    $fclose(idx_file);
  end

  always @(posedge clk) begin
    if (wen == 1)
      ram[addr] <= d;
    read_addr <= addr;
  end

  assign #delay q = {ram[read_addr+3], ram[read_addr+2], ram[read_addr+1], ram[read_addr]};

endmodule
