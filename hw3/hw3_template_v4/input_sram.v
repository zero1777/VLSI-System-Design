module input_sram(
  input clk,
  input wen,
  input [15:0] addr,
  input signed [31:0] d,
  output [31:0] q
);
 
reg signed [7:0] ram [0:65535];
reg [15:0] read_addr;

integer i, j, k, l;
integer input_file;
integer index;

  initial begin
    // Read the input image csv and load the image
    input_file = $fopen(`INPUT_SOURCE, "r");
    $display(">> Reading the image file: %s", `INPUT_SOURCE);
        for(i=0; i< `input_num; i= i+1) begin
            for(j=0; j< `input_channel; j= j+1) begin
                for(k=0; k< `input_height; k= k+1) begin
                    for(l=0; l< `input_width; l=l+1) begin
                        index = ((i * `input_channel + j) * `input_height + k) * `input_width + l;
                        $fscanf(input_file,"%e", ram[index]);
                    end
                end
            end
        end
    $fclose(input_file);
  end

  always @(posedge clk) begin
    if (wen == 1)
      ram[addr] <= d;
    read_addr <= addr;
  end

  assign q = {ram[read_addr+3], ram[read_addr+2], ram[read_addr+1], ram[read_addr]};

endmodule
