module gaparr_sram(
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
integer gaparr_file;
integer index, cc;

  initial begin
    // Read the gaparr gaparr csv and load the gaparr
    gaparr_file = $fopen(`gaparr_SOURCE, "r");
    $display(">> Reading the gaparr file: %s", `gaparr_SOURCE);
        index = 0;
        while ($fscanf(gaparr_file, "%d", cc) != -1) begin
          ram[index] = cc;
          index = index + 1;
        end
    $fclose(gaparr_file);
  end

  always @(posedge clk) begin
    if (wen == 1)
      ram[addr] <= d;
    read_addr <= addr;
  end

  assign #delay q = {ram[read_addr+3], ram[read_addr+2], ram[read_addr+1], ram[read_addr]};

endmodule
