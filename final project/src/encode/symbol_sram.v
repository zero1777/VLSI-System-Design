module symbol_sram(
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
integer symbol_file;
integer index;

initial begin
    // Read the input weight csv and load the weight
    symbol_file = $fopen(`symbol_SOURCE, "r");
    $display(">> Reading the weight file: %s", `symbol_SOURCE);
        for(i=0; i< `symbol_num; i= i+1) begin
            $fscanf(symbol_file,"%c", ram[i]);
            // $display("index is: %d", i);
            // $display("data is: %c", ram[i]);
        end
    $fclose(symbol_file);
end

always @(posedge clk) begin
    if (wen == 1)
    ram[addr] <= d;
    read_addr <= addr;
    // $display("this income address is: %d", addr);
end

assign #delay q = {ram[read_addr]};

endmodule
