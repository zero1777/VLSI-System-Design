module weight_sram(
  input clk,
  input wen,
  input [15:0] addr,
  input signed [31:0] d, 
  output [31:0] q
);
 
reg signed [7:0] ram [0:65535];
reg [15:0] read_addr;

integer i, j, k, l;
integer weight_file;
integer index;

  initial begin
    // Read the input weight csv and load the weight
    weight_file = $fopen(`WEIGHT_SOURCE, "r");
    $display(">> Reading the weight file: %s", `WEIGHT_SOURCE);
        for(i=0; i< `weight_out_channel; i= i+1) begin
            for(j=0; j< `weight_in_channel; j= j+1) begin
                for(k=0; k< `weight_height; k= k+1) begin
                    for(l=0; l< `weight_width; l= l+1) begin
                        index = ((i * `weight_in_channel + j) * `weight_height + k) * `weight_width + l;
                        $fscanf(weight_file,"%e", ram[index]);
                    end
                end
            end
        end
    $fclose(weight_file);
  end

  always @(posedge clk) begin
    if (wen == 1)
      ram[addr] <= d;
    read_addr <= addr;
  end

  assign q = {ram[read_addr+3], ram[read_addr+2], ram[read_addr+1], ram[read_addr]};

endmodule
