module SA (
    clk, rst_n, first_round, r1, r2, r3, r4, c1, c2, c3, c4,
    sa1, sa2, sa3, sa4, sa5, sa6, sa7, sa8, sa9, sa10, sa11, sa12, sa13,
    sa14, sa15, sa16
);

input clk;
input rst_n;
input [5:0] first_round;
input [7:0] r1, r2, r3, r4;
input [7:0] c1, c2, c3, c4;

// systolic array stored value
output reg [31:0] sa1, sa2, sa3, sa4, sa5, sa6, sa7, sa8, sa9, sa10, sa11, sa12, sa13, sa14, sa15, sa16;
reg [31:0] next_sa1, next_sa2, next_sa3, next_sa4, next_sa5, next_sa6, next_sa7, next_sa8, next_sa9, next_sa10, next_sa11, next_sa12, next_sa13, next_sa14, next_sa15, next_sa16;

// systolic array output (row & column)
reg [7:0] sa1_r, sa1_c, sa2_r, sa2_c, sa3_r, sa3_c, sa4_r, sa4_c, sa5_r, sa5_c, sa6_r, sa6_c, sa7_r, sa7_c, sa8_r, sa8_c;
reg [7:0] sa9_r, sa9_c, sa10_r, sa10_c, sa11_r, sa11_c, sa12_r, sa12_c, sa13_r, sa13_c, sa14_r, sa14_c, sa15_r, sa15_c, sa16_r, sa16_c;
reg [7:0] next_sa1_r, next_sa1_c, next_sa2_r, next_sa2_c, next_sa3_r, next_sa3_c, next_sa4_r, next_sa4_c, next_sa5_r, next_sa5_c, next_sa6_r, next_sa6_c, next_sa7_r, next_sa7_c, next_sa8_r, next_sa8_c;
reg [7:0] next_sa9_r, next_sa9_c, next_sa10_r, next_sa10_c, next_sa11_r, next_sa11_c, next_sa12_r, next_sa12_c, next_sa13_r, next_sa13_c, next_sa14_r, next_sa14_c, next_sa15_r, next_sa15_c, next_sa16_r, next_sa16_c;

    // combinational
    // next_sa, next_sa_r, next_sa_c
    // next_sa1 = sa1;
    // next_sa2 = sa2;
    // next_sa3 = sa3;
    // next_sa4 = sa4;
    // next_sa5 = sa5;
    // next_sa6 = sa6;
    // next_sa7 = sa7;
    // next_sa8 = sa8;
    // next_sa9 = sa9;
    // next_sa10 = sa10;
    // next_sa11 = sa11;
    // next_sa12 = sa12;
    // next_sa13 = sa13;
    // next_sa14 = sa14;
    // next_sa15 = sa15;
    // next_sa16 = sa16;

    // next_sa1_r = sa1_r;
    // next_sa2_r = sa2_r;
    // next_sa3_r = sa3_r;
    // next_sa4_r = sa4_r;
    // next_sa5_r = sa5_r;
    // next_sa6_r = sa6_r;
    // next_sa7_r = sa7_r;
    // next_sa8_r = sa8_r;
    // next_sa9_r = sa9_r;
    // next_sa10_r = sa10_r;
    // next_sa11_r = sa11_r;
    // next_sa12_r = sa12_r;
    // next_sa13_r = sa13_r;
    // next_sa14_r = sa14_r;
    // next_sa15_r = sa15_r;
    // next_sa16_r = sa16_r;

    // next_sa1_c = sa1_c;
    // next_sa2_c = sa2_c;
    // next_sa3_c = sa3_c;
    // next_sa4_c = sa4_c;
    // next_sa5_c = sa5_c;
    // next_sa6_c = sa6_c;
    // next_sa7_c = sa7_c;
    // next_sa8_c = sa8_c;
    // next_sa9_c = sa9_c;
    // next_sa10_c = sa10_c;
    // next_sa11_c = sa11_c;
    // next_sa12_c = sa12_c;
    // next_sa13_c = sa13_c;
    // next_sa14_c = sa14_c;
    // next_sa15_c = sa15_c;
    // next_sa16_c = sa16_c;

    // sa1
    next_sa1_r = r1;
    next_sa1_c = c1;
    always @(*) begin
        if (first_round == 6'd1) begin
            next_sa1 = r1 * c1;
        end
        else begin
            next_sa1 = sa1 + r1 * c1;
        end
    end

    // sa2
    next_sa2_r = sa1_r;
    next_sa2_c = c2;
    always @(*) begin
        if (first_round == 6'd2) begin
            next_sa2 = sa1_r * c2;
        end
        else begin
            next_sa2 = sa2 + sa1_r * c2;
        end
    end
    

    // sa3
    next_sa3_r = sa2_r;
    next_sa3_c = c3;
    always @(*) begin
        if (first_round == 6'd3) begin
            next_sa3 = sa2_r * c3;
        end
        else begin
            next_sa3 = sa3 + sa2_r * c3;
        end
    end
    

    // sa4
    next_sa4_r = sa3_r;
    next_sa4_c = c4;
    always @(*) begin
        if (first_round == 6'd4) begin
            next_sa4 = sa3_r * c4;
        end
        else begin
            next_sa4 = sa4 + sa3_r * c4;
        end
    end
    

    // sa5
    next_sa5_r = r2;
    next_sa5_c = sa1_c;
    always @(*) begin
        if (first_round == 6'd2) begin
            next_sa5 = r2 * sa1_c;
        end
        else begin
            next_sa5 = sa5 + r2 * sa1_c;
        end
    end
    

    // sa6
    next_sa6_r = sa5_r;
    next_sa6_c = sa2_c;
    always @(*) begin
        if (first_round == 6'd3) begin
            next_sa6 = sa5_r * sa2_c;
        end
        else begin
            next_sa6 = sa6 + sa5_r * sa2_c;
        end
    end
    

    // sa7
    next_sa7_r = sa6_r;
    next_sa7_c = sa3_c;
    always @(*) begin
        if (first_round == 6'd4) begin
            next_sa7 = sa6_r * sa3_c;
        end
        else begin
            next_sa7 = sa7 + sa6_r * sa3_c;
        end    
    end

    // sa8
    next_sa8_r = sa7_r;
    next_sa8_c = sa4_c;
    always @(*) begin
        if (first_round == 6'd5) begin
            next_sa8 = sa7_r * sa4_c;
        end
        else begin
            next_sa8 = sa8 + sa7_r * sa4_c;
        end
    end

    // sa9
    next_sa9_r = r3;
    next_sa9_c = sa5_c;
    always @(*) begin
        if (first_round == 6'd3) begin
            next_sa9 = r3 * sa5_c;
        end
        else begin
            next_sa9 = sa9 + r3 * sa5_c;
        end
    end
    
    // sa10
    next_sa10_r = sa9_r;
    next_sa10_c = sa6_c;
    always @(*) begin
        if (first_round == 6'd4) begin
            next_sa10 = sa9_r * sa6_c;
        end
        else begin
            next_sa10 = sa10 + sa9_r * sa6_c;
        end
    end

    // sa11
    next_sa11_r = sa10_r;
    next_sa11_c = sa7_c;
    always @(*) begin
        if (first_round == 6'd5) begin
            next_sa11 = sa10_r * sa7_c;
        end
        else begin
            next_sa11 = sa11 + sa10_r * sa7_c;
        end
    end

    // sa12
    next_sa12_r = sa11_r;
    next_sa12_c = sa8_c;
    always @(*) begin
        if (first_round == 6'd6) begin
            next_sa12 = sa11_r * sa8_c;
        end
        else begin
            next_sa12 = sa12 + sa11_r * sa8_c;
        end
    end

    // sa13
    next_sa13_r = r4;
    next_sa13_c = sa9_c;
    always @(*) begin
        if (first_round == 6'd4) begin
            next_sa13 = r4 * sa9_c;
        end
        else begin
            next_sa13 = sa13 + r4 * sa9_c;
        end
    end

    // sa14
    next_sa14_r = sa13_r;
    next_sa14_c = sa10_c;
    always @(*) begin
        if (first_round == 6'd5) begin
            next_sa14 = sa13_r * sa10_c;
        end
        else begin
            next_sa14 = sa14 + sa13_r * sa10_c;
        end
    end

    // sa15
    next_sa15_r = sa14_r;
    next_sa15_c = sa11_c;
    always @(*) begin
        if (first_round == 6'd6) begin
            next_sa15 = sa14_r * sa11_c;
        end
        else begin
            next_sa15 = sa15 + sa14_r * sa11_c;
        end
    end

    // sa16
    next_sa16_r = sa15_r;
    next_sa16_c = sa12_c;
    always @(*) begin
        if (first_round == 6'd7) begin
            next_sa16 = sa15_r * sa12_c;
        end
        else begin
            next_sa16 = sa16 + sa15_r * sa12_c;
        end
    end


    // sequential
    // sa, sa_r, sa_c
    always @(posedge clk, negedge rst_n) begin
        if (rst_n == 0) begin
            // sa
            sa1 = 32'd0;
            sa2 = 32'd0;
            sa3 = 32'd0;
            sa4 = 32'd0;
            sa5 = 32'd0;
            sa6 = 32'd0;
            sa7 = 32'd0;
            sa8 = 32'd0;
            sa9 = 32'd0;
            sa10 = 32'd0;
            sa11 = 32'd0;
            sa12 = 32'd0;
            sa13 = 32'd0;
            sa14 = 32'd0;
            sa15 = 32'd0;
            sa16 = 32'd0;

            // sa_c
            sa1_c = 8'd0;
            sa2_c = 8'd0;
            sa3_c = 8'd0;
            sa4_c = 8'd0;
            sa5_c = 8'd0;
            sa6_c = 8'd0;
            sa7_c = 8'd0;
            sa8_c = 8'd0;
            sa9_c = 8'd0;
            sa10_c = 8'd0;
            sa11_c = 8'd0;
            sa12_c = 8'd0;
            sa13_c = 8'd0;
            sa14_c = 8'd0;
            sa15_c = 8'd0;
            sa16_c = 8'd0;

            // sa_r
            sa1_r = 8'd0;
            sa2_r = 8'd0;
            sa3_r = 8'd0;
            sa4_r = 8'd0;
            sa5_r = 8'd0;
            sa6_r = 8'd0;
            sa7_r = 8'd0;
            sa8_r = 8'd0;
            sa9_r = 8'd0;
            sa10_r = 8'd0;
            sa11_r = 8'd0;
            sa12_r = 8'd0;
            sa13_r = 8'd0;
            sa14_r = 8'd0;
            sa15_r = 8'd0;
            sa16_r = 8'd0;

        end
        else begin
            // sa
            sa1 = next_sa1;
            sa2 = next_sa2;
            sa3 = next_sa3;
            sa4 = next_sa4;
            sa5 = next_sa5;
            sa6 = next_sa6;
            sa7 = next_sa7;
            sa8 = next_sa8;
            sa9 = next_sa9;
            sa10 = next_sa10;
            sa11 = next_sa11;
            sa12 = next_sa12;
            sa13 = next_sa13;
            sa14 = next_sa14;
            sa15 = next_sa15;
            sa16 = next_sa16;

            // sa_c
            sa1_c = next_sa1_c;
            sa2_c = next_sa2_c;
            sa3_c = next_sa3_c;
            sa4_c = next_sa4_c;
            sa5_c = next_sa5_c;
            sa6_c = next_sa6_c;
            sa7_c = next_sa7_c;
            sa8_c = next_sa8_c;
            sa9_c = next_sa9_c;
            sa10_c = next_sa10_c;
            sa11_c = next_sa11_c;
            sa12_c = next_sa12_c;
            sa13_c = next_sa13_c;
            sa14_c = next_sa14_c;
            sa15_c = next_sa15_c;
            sa16_c = next_sa16_c;

            // sa_r
            sa1_r = next_sa1_r;
            sa2_r = next_sa2_r;
            sa3_r = next_sa3_r;
            sa4_r = next_sa4_r;
            sa5_r = next_sa5_r;
            sa6_r = next_sa6_r;
            sa7_r = next_sa7_r;
            sa8_r = next_sa8_r;
            sa9_r = next_sa9_r;
            sa10_r = next_sa10_r;
            sa11_r = next_sa11_r;
            sa12_r = next_sa12_r;
            sa13_r = next_sa13_r;
            sa14_r = next_sa14_r;
            sa15_r = next_sa15_r;
            sa16_r = next_sa16_r;
        end
    end 
endmodule
