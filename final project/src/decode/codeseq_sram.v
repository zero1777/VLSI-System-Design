module codeseq_sram(
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
integer codeseq_file;
integer index, cnt;

  initial begin
    // Read the input codeseq csv and load the codeseq
    codeseq_file = $fopen(`codeseq_SOURCE, "r");
    $display(">> Reading the codeseq file: %s", `codeseq_SOURCE);
        index = 0;
        ram[0] = 8'b10001011;
        ram[1] = 8'b01010111;
        ram[2] = 8'b11110101;
        ram[3] = 8'b00111111;
        ram[4] = 8'b00011001;
        ram[5] = 8'b11010000;
        ram[6] = 8'b01100010;
        ram[7] = 8'b11001011;
        ram[8] = 8'b10111110;
        ram[9] = 8'b00000001;

        // ram[0] = 8'b01110101;
        // ram[1] = 8'b00000111;
        // ram[2] = 8'b11100000;
        // ram[3] = 8'b11111111;
        // ram[4] = 8'b01100110;
        // ram[5] = 8'b01100010;
        // ram[6] = 8'b10011101;
        // ram[7] = 8'b00010101;

        // ram[8] = 8'b11011111;
        // ram[9] = 8'b11101110;
        // ram[10] = 8'b00000111;
        // ram[11] = 8'b00010010;
        // ram[12] = 8'b00111011;
        // ram[13] = 8'b01011110;
        // ram[14] = 8'b11110111;
        // ram[15] = 8'b10011010;

        // ram[16] = 8'b10011100;
        // ram[17] = 8'b01000100;
        // ram[18] = 8'b11011101;
        // ram[19] = 8'b10001010;
        // ram[20] = 8'b11101011;
        // ram[21] = 8'b00000001;

        // ram[0] = 8'b01110101;
        // ram[1] = 8'b00000111;
        // ram[2] = 8'b11100000;
        // ram[3] = 8'b11111111;
        // ram[4] = 8'b01100110;
        // ram[5] = 8'b01100010;
        // ram[6] = 8'b10011101;
        // ram[7] = 8'b00010101;

        // ram[8] = 8'b11011111;
        // ram[9] = 8'b11101110;
        // ram[10] = 8'b00000111;
        // ram[11] = 8'b00010010;
        // ram[12] = 8'b00111011;
        // ram[13] = 8'b01011110;
        // ram[14] = 8'b11110111;
        // ram[15] = 8'b10011010;

        // ram[16] = 8'b10011100;
        // ram[17] = 8'b01000100;
        // ram[18] = 8'b11011101;
        // ram[19] = 8'b10001010;
        // ram[20] = 8'b11101011;
        // ram[21] = 8'b10101111;

        // ram[22] = 8'b01110101;
        // ram[23] = 8'b00000111;
        // ram[24] = 8'b11100000;
        // ram[25] = 8'b11111111;
        // ram[26] = 8'b01100110;
        // ram[27] = 8'b01100010;
        // ram[28] = 8'b10011101;
        // ram[29] = 8'b00010101;

        // ram[30] = 8'b11011111;
        // ram[31] = 8'b11101110;
        // ram[32] = 8'b00000111;
        // ram[33] = 8'b00010010;
        // ram[34] = 8'b00111011;
        // ram[35] = 8'b01011110;
        // ram[36] = 8'b11110111;
        // ram[37] = 8'b10011010;

        // ram[38] = 8'b10011100;
        // ram[39] = 8'b01000100;
        // ram[40] = 8'b11011101;
        // ram[41] = 8'b10001010;
        // ram[42] = 8'b11101011;
        // ram[43] = 8'b10101111;
        // ram[44] = 8'b00000000;
        
        
    $fclose(codeseq_file);
  end

  always @(posedge clk) begin
    if (wen == 1)
      ram[addr] <= d;
    read_addr <= addr;
  end

  assign #delay q = {ram[read_addr+3], ram[read_addr+2], ram[read_addr+1], ram[read_addr]};

endmodule
