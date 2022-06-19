module encode_sram(
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
integer encode_file;
integer index, cnt;

  initial begin
    // Read the input codeseq csv and load the codeseq
    encode_file = $fopen(`encode_SOURCE, "r");
    $display(">> Reading the codeseq file: %s", `encode_SOURCE);
        for(i=0; i< `symbol_num; i= i+1) begin
            $fscanf(encode_file,"%d", ram[i]);
            // $display("index is: %d", i);
            // $display("data is: %d", ram[i]);
        end
    $fclose(encode_file);
  end

  always @(posedge clk) begin
    if (wen == 1)
      ram[addr] <= d;
    read_addr <= addr;
  end

  assign #delay q = {ram[read_addr+3], ram[read_addr+2], ram[read_addr+1], ram[read_addr]};

endmodule
