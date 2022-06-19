module output_sram(
  input clk,
  input wen,
  input [15:0] addr,
  input signed [31:0] d,
  output signed [31:0] q
);
 
reg signed [31:0] ram [0:65535];
reg [15:0] read_addr;
integer i, j;

  initial begin
    // load the image

    for(i=0;i<65536;i=i+1) begin
      ram[i] = 0;
    end
  end

  always @(posedge clk) begin
    if (wen == 1)
      ram[addr] <= d;
    read_addr <= addr;
  end

  assign q = ram[read_addr];

endmodule
