module output_sram(
    input clk,
    input wen_d1,
    input [15:0] addr_d1,
    input [7:0] len_d1,
    input [7:0] from_d1,
    input  [15:0] d_d1,
    output [15:0] q_d1,
    input wen_d2,
    input [7:0] len_d2,
    input [7:0] from_d2,
    input [15:0] addr_d2,
    input  [15:0] d_d2,
    output  [15:0] q_d2,
    input wen_d3,
    input [7:0] len_d3,
    input [7:0] from_d3,
    input [15:0] addr_d3,
    input  [15:0] d_d3,
    output  [15:0] q_d3,
    input wen_d4,
    input [7:0] len_d4,
    input [7:0] from_d4,
    input [15:0] addr_d4,
    input  [15:0] d_d4,
    output  [15:0] q_d4
);

parameter delay = 0;
// parameter len1 = len_d1;

reg [7:0] ram [0:65535];
// reg [len_d1:0] ram1 [0:65535];
// reg [len_d2:0] ram2 [0:65535];
// reg [len_d3:0] ram3 [0:65535];
// reg [len_d4:0] ram4 [0:65535];
reg [15:0] read_addr_d1;
reg [15:0] read_addr_d2;
reg [15:0] read_addr_d3;
reg [15:0] read_addr_d4;
integer i, j;

    initial begin
        // initial the memory
        for(i=0;i<65536;i=i+1) begin
            // ram1[i] = 0;
            // ram2[i] = 0;
            // ram3[i] = 0;
            // ram4[i] = 0;
            ram[i] = 0;
        end
    end

    always @(posedge clk) begin
        if (wen_d1 == 1) begin
            // $display("w1 first half: %b", d_d1[15:8]);
            // $display("w1 second half: %b", d_d1[7:0]);
            ram[addr_d1] = ram[addr_d1] | d_d1[15:8];
            ram[addr_d1+1] = ram[addr_d1+1] | d_d1[7:0];
        end
        if (wen_d2 == 1) begin
            // $display("w2 first half: %b", d_d2[15:8]);
            // $display("w2 second half: %b", d_d2[7:0]);
            ram[addr_d2] = ram[addr_d2] | d_d2[15:8];
            ram[addr_d2+1] = ram[addr_d2+1] | d_d2[7:0];
        end
        if (wen_d3 == 1) begin
            // $display("w2 first half: %b", d_d2[15:8]);
            // $display("w2 second half: %b", d_d2[7:0]);
            ram[addr_d3] = ram[addr_d3] | d_d3[15:8];
            ram[addr_d3+1] = ram[addr_d3+1] | d_d3[7:0];
        end
        if (wen_d4 == 1) begin
            // $display("w2 first half: %b", d_d2[15:8]);
            // $display("w2 second half: %b", d_d2[7:0]);
            ram[addr_d4] = ram[addr_d4] | d_d4[15:8];
            ram[addr_d4+1] = ram[addr_d4+1] | d_d4[7:0];
        end
        read_addr_d4 = addr_d4;
        read_addr_d3 = addr_d3;
        read_addr_d2 = addr_d2;
        read_addr_d1 = addr_d1;
    end
    assign #delay q_d1 = ram[read_addr_d1];
    assign #delay q_d2 = ram[read_addr_d2];

    // always @(posedge clk) begin
    //     if (wen_d2 == 1) begin
    //         $display("w2 first half: %b", d_d2[15:8]);
    //         $display("w2 second half: %b", d_d2[7:0]);
    //         ram[addr_d2] = ram[addr_d2] | d_d2[15:8];
    //         ram[addr_d2+1] = ram[addr_d2+1] | d_d2[7:0];
    //     end
    //     read_addr_d2 = addr_d2;
    // end
    

    // always @(posedge clk) begin
    //     if (wen_d2 == 1) begin
    //         ram[addr_d2][from_d2:len_d2+from_d2-1] <= d_d2[len_d2-1:0];
    //     end
    //     read_addr_d2 <= addr_d2;
    // end
    // assign #delay q_d2 = ram[read_addr_d2];

    // always @(posedge clk) begin
    //     if (wen_d3 == 1) begin
    //         ram[addr_d3][from_d3:len_d3+from_d3-1] <= d_d3[len_d3-1:0];
    //     end
    //     read_addr_d3 <= addr_d3;
    // end
    // assign #delay q_d3 = ram[read_addr_d3];

    // always @(posedge clk) begin
    //     if (wen_d4 == 1) begin
    //         ram[addr_d4][from_d4:len_d4+from_d4-1] <= d_d4[len_d4-1:0];
    //     end
    //     read_addr_d4 <= addr_d4;
    // end
    // assign #delay q_d4 = ram[read_addr_d4];

endmodule
