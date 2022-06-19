`timescale 1 ns / 1 ps

`define FSDB_FILE    "testbench.fsdb"
`define CONV_INPUT_SOURCE   "conv2_input.csv"
`define CONV_WEIGHT_SOURCE 	"weight_conv.csv"
`define FC_INPUT_SOURCE   	"input_fc.csv"
`define FC_WEIGHT_SOURCE   	"weight_fc.csv"

`define CONV_IMAGE_OFFSET 			65536	//0x00010000
`define UNFOLDED_CONV_IMAGE_OFFSET	131072	//0x00020000

`define CONV_WEIGHT_OFFSET			196608	//0x00030000
`define SOFT_CONV_OUTPUT_OFFSET		262144	//0x00040000
`define HARD_CONV_OUTPUT_OFFSET		327680	//0x00050000

`define FC_IMAGE_OFFSET 			393216	//0x00060000
`define FC_WEIGHT_OFFSET			458752	//0x00070000
`define SOFT_FC_OUTPUT_OFFSET		524288	//0x00080000
`define HARD_FC_OUTPUT_OFFSET		589824	//0x00090000

`define IMG_OFFSET   16384 //0x00010000
`define MEM_SIZE     3145728 //0x00C00000

`ifndef VERILATOR
module testbench ();
	reg clk = 1;
	reg resetn = 0;
	wire trap;

	always #20 clk = ~clk;

	initial begin
		repeat (100) @(posedge clk);
		resetn <= 1;
	end

	initial begin
		if ($test$plusargs("fsdb")) begin
			$fsdbDumpfile(`FSDB_FILE);
			$fsdbDumpvars(0, testbench);
		end
		repeat (1000000000) @(posedge clk);
		$display("TIMEOUT");
		$finish;
	end

	wire trace_valid;
	wire [35:0] trace_data;
	integer trace_file;

	initial begin
		if ($test$plusargs("trace")) begin
			trace_file = $fopen("testbench.trace", "w");
			repeat (10) @(posedge clk);
			while (!trap) begin
				@(posedge clk);
				if (trace_valid)
					$fwrite(trace_file, "%x\n", trace_data);
			end
			$fclose(trace_file);
			$display("Finished writing testbench.trace.");
		end
	end
	
	integer dnn_in;
	integer i, j, k, cc;
	integer debug;
	
	initial begin
		for(i=0; i<`MEM_SIZE;i=i+1) begin
			top.memory[i] = 32'b0;
		end
		$readmemh("firmware/firmware.hex", top.memory, 0, `IMG_OFFSET-1);

		if ($value$plusargs("debug=%d", debug)) begin
			$display(">> Debug level = %d", debug);
		end else begin
			debug = 0;
		end
		
		dnn_in = $fopen(`CONV_INPUT_SOURCE, "r");
		i = 0;
		while($fscanf(dnn_in,"%e", cc)!= -1) begin
			case(i % 4) 
				0: top.memory[(`CONV_IMAGE_OFFSET >> 2) + (i >> 2)][7: 0] = cc;
				1: top.memory[(`CONV_IMAGE_OFFSET >> 2) + (i >> 2)][ 15: 8] = cc;
				2: top.memory[(`CONV_IMAGE_OFFSET >> 2) + (i >> 2)][ 23: 16] = cc;
				3: top.memory[(`CONV_IMAGE_OFFSET >> 2) + (i >> 2)][ 31: 24] = cc;
			endcase
			i = i+1;
		end  
		top.memory[(`CONV_IMAGE_OFFSET >> 2) + (i >> 2) + 1] = 0;
		$fclose(dnn_in);

		dnn_in = $fopen(`CONV_WEIGHT_SOURCE, "r");
		i = 0;
		while ($fscanf(dnn_in,"%e", cc)!= -1) begin
			case(i % 4) 
				0: top.memory[(`CONV_WEIGHT_OFFSET >> 2) + (i >> 2)][7: 0] = cc;
				1: top.memory[(`CONV_WEIGHT_OFFSET >> 2) + (i >> 2)][ 15: 8] = cc;
				2: top.memory[(`CONV_WEIGHT_OFFSET >> 2) + (i >> 2)][ 23: 16] = cc;
				3: top.memory[(`CONV_WEIGHT_OFFSET >> 2) + (i >> 2)][ 31: 24] = cc;
			endcase
			i = i+1;
		end  
		$fclose(dnn_in);

		dnn_in = $fopen(`FC_INPUT_SOURCE, "r");
		i = 0;
		while ($fscanf(dnn_in,"%e", cc)!= -1) begin
			case(i % 4) 
				0: top.memory[(`FC_IMAGE_OFFSET >> 2) + (i >> 2)][7: 0] = cc;
				1: top.memory[(`FC_IMAGE_OFFSET >> 2) + (i >> 2)][ 15: 8] = cc;
				2: top.memory[(`FC_IMAGE_OFFSET >> 2) + (i >> 2)][ 23: 16] = cc;
				3: top.memory[(`FC_IMAGE_OFFSET >> 2) + (i >> 2)][ 31: 24] = cc;
			endcase
			i = i+1;
		end  
		$fclose(dnn_in);

		dnn_in = $fopen(`FC_WEIGHT_SOURCE, "r");
		i = 0;
		while ($fscanf(dnn_in,"%e", cc)!= -1) begin
			case(i % 4) 
				0: top.memory[(`FC_WEIGHT_OFFSET >> 2) + (i >> 2)][7: 0] = cc;
				1: top.memory[(`FC_WEIGHT_OFFSET >> 2) + (i >> 2)][ 15: 8] = cc;
				2: top.memory[(`FC_WEIGHT_OFFSET >> 2) + (i >> 2)][ 23: 16] = cc;
				3: top.memory[(`FC_WEIGHT_OFFSET >> 2) + (i >> 2)][ 31: 24] = cc;
			endcase
			i = i+1;
		end  
		$fclose(dnn_in);

	end
	
	picorv32_wrapper top (
		.clk(clk),
		.resetn(resetn),
		.trap(trap),
		.trace_valid(trace_valid),
		.trace_data(trace_data)
	);
endmodule
`endif

module picorv32_wrapper (
	input clk,
	input resetn,
	output trap,
	output trace_valid,
	output [35:0] trace_data
);
	reg tests_finshed;
	wire [31:0] irq;
    wire [31:0] eoi;

	assign irq = 0;

	// set this to 0 for better timing but less performance/MHz
	parameter FAST_MEMORY = 1;

	reg mem_ready;
	wire mem_valid;
	wire mem_instr;
	wire [31:0] mem_addr;
	wire [31:0] mem_wdata;
	wire [3:0] mem_wstrb;
	reg [31:0] mem_rdata;
	wire mem_la_read;
	wire mem_la_write;
	wire [31:0] mem_la_addr;
	wire [31:0] mem_la_wdata;
	wire [3:0] mem_la_wstrb;
	
	wire pcpi_ready;
	wire pcpi_valid;
	wire [31:0] pcpi_insn;
	wire [31:0] pcpi_rs1;
	wire [31:0] pcpi_rs2;
	wire [31:0] pcpi_rd;
	wire pcpi_wr;
	wire pcpi_wait;

	wire pcpi_mem_valid_0;
	reg  pcpi_mem_ready_0;
	wire pcpi_mem_write_0;
	wire [31:0] pcpi_mem_addr_0;
	reg  [31:0] pcpi_mem_rdata_0;
	wire [31:0] pcpi_mem_wdata_0;
	
	wire pcpi_mem_valid_1;
	reg  pcpi_mem_ready_1;
	wire pcpi_mem_write_1;
	wire [31:0] pcpi_mem_addr_1;
	reg  [31:0] pcpi_mem_rdata_1;
	wire [31:0] pcpi_mem_wdata_1;

	wire pcpi_mem_valid_2;
	reg  pcpi_mem_ready_2;
	wire pcpi_mem_write_2;
	wire [31:0] pcpi_mem_addr_2;
	reg  [31:0] pcpi_mem_rdata_2;
	wire [31:0] pcpi_mem_wdata_2;

	wire memory_valid;
	wire [31:0] memory_addr;
	wire [31:0] memory_wdata;
	wire memory_write;
	wire [3:0] memory_wstrb;

	picorv32 #(
`ifndef SYNTH_TEST
`ifdef SP_TEST
		.ENABLE_REGS_DUALPORT(0),
`endif
`ifdef COMPRESSED_ISA
		.COMPRESSED_ISA(1),
`endif
		.ENABLE_PCPI(1),
		.ENABLE_MUL(1),
		.ENABLE_DIV(1),
		.ENABLE_IRQ(1),
		.ENABLE_TRACE(1)
`endif) picorv32 (
		.clk         (clk         ),
		.resetn      (resetn      ),
		.trap        (trap        ),
		.mem_valid   (mem_valid   ),
		.mem_instr   (mem_instr   ),
		.mem_ready   (mem_ready   ),
		.mem_addr    (mem_addr    ),
		.mem_wdata   (mem_wdata   ),
		.mem_wstrb   (mem_wstrb   ),
		.mem_rdata   (mem_rdata   ),
		.mem_la_read (mem_la_read ),
		.mem_la_write(mem_la_write),
		.mem_la_addr (mem_la_addr ),
		.mem_la_wdata(mem_la_wdata),
		.mem_la_wstrb(mem_la_wstrb),
		.irq		 (irq	      ),
        .eoi         (eoi         ),
		.trace_valid (trace_valid ),
		.trace_data  (trace_data  ),
		.pcpi_valid  (pcpi_valid  ),
		.pcpi_insn   (pcpi_insn   ),
		.pcpi_rs1    (pcpi_rs1    ),
		.pcpi_rs2    (pcpi_rs2    ),
		.pcpi_wr     (pcpi_wr     ),
		.pcpi_rd     (pcpi_rd     ),
		.pcpi_wait   (pcpi_wait   ),
		.pcpi_ready  (pcpi_ready  )
	);

	DNN_PCPI dnn_pcpi (
		.clk       (clk            ),
		.resetn    (resetn         ),
		.pcpi_valid(pcpi_valid     ),
		.pcpi_insn (pcpi_insn      ),
		.pcpi_rs1  (pcpi_rs1       ),
		.pcpi_rs2  (pcpi_rs2       ),
		.pcpi_wr   (pcpi_wr        ),
		.pcpi_rd   (pcpi_rd        ),
		.pcpi_wait (pcpi_wait      ),
		.pcpi_ready(pcpi_ready     ),

		//memory interface 0
		.mem_ready_0(pcpi_mem_ready_0),
		.mem_valid_0(pcpi_mem_valid_0),
		.mem_write_0(pcpi_mem_write_0),
		.mem_addr_0 (pcpi_mem_addr_0),
		.mem_wdata_0(pcpi_mem_wdata_0),
		.mem_rdata_0(pcpi_mem_rdata_0),
		
		//memory interface 1
		.mem_ready_1(pcpi_mem_ready_1),
		.mem_valid_1(pcpi_mem_valid_1),
		.mem_write_1(pcpi_mem_write_1),
		.mem_addr_1 (pcpi_mem_addr_1),
		.mem_wdata_1(pcpi_mem_wdata_1),
		.mem_rdata_1(pcpi_mem_rdata_1),

		//memory interface 2
		.mem_ready_2(pcpi_mem_ready_2),
		.mem_valid_2(pcpi_mem_valid_2),
		.mem_write_2(pcpi_mem_write_2),
		.mem_addr_2 (pcpi_mem_addr_2),
		.mem_wdata_2(pcpi_mem_wdata_2),
		.mem_rdata_2(pcpi_mem_rdata_2)
	);
	
	reg [31:0] memory [0: `MEM_SIZE-1];
	reg [31:0] m_read_data;
	reg m_read_en;

	assign memory_valid = mem_valid;
	assign memory_addr = FAST_MEMORY ? mem_la_addr : mem_addr;
	assign memory_wdata = FAST_MEMORY ? mem_la_wdata : mem_wdata;
	assign memory_write = mem_la_write;
	assign memory_wstrb = FAST_MEMORY ? mem_la_wstrb : mem_wstrb;

	//Port1: PCPI memory access
	always @(posedge clk) begin
		pcpi_mem_ready_0 <= pcpi_mem_valid_0;
		pcpi_mem_rdata_0 <= 0;
		if (pcpi_mem_valid_0 && !pcpi_mem_write_0 && (pcpi_mem_addr_0 >> 2) < `MEM_SIZE) begin
			case(pcpi_mem_addr_0[1:0])
				2'd0: pcpi_mem_rdata_0 <= memory[pcpi_mem_addr_0 >> 2];
				2'd1: pcpi_mem_rdata_0 <= {memory[(pcpi_mem_addr_0 >> 2)+1][7:0], memory[pcpi_mem_addr_0 >> 2][31:8]};
				2'd2: pcpi_mem_rdata_0 <= {memory[(pcpi_mem_addr_0 >> 2)+1][15:0], memory[pcpi_mem_addr_0 >> 2][31:16]};
				2'd3: pcpi_mem_rdata_0 <= {memory[(pcpi_mem_addr_0 >> 2)+1][23:0], memory[pcpi_mem_addr_0 >> 2][31:24]};
			endcase
		end
		if (pcpi_mem_valid_0 && |pcpi_mem_write_0 && (pcpi_mem_addr_0 >> 2) < `MEM_SIZE) begin
			case(pcpi_mem_addr_0[1:0])
				2'd0: memory[pcpi_mem_addr_0 >> 2] <= pcpi_mem_wdata_0;
				2'd1: {memory[(pcpi_mem_addr_0 >> 2)+1][7:0], memory[pcpi_mem_addr_0 >> 2][31:8]} <= pcpi_mem_wdata_0;
				2'd2: {memory[(pcpi_mem_addr_0 >> 2)+1][15:0], memory[pcpi_mem_addr_0 >> 2][31:16]} <= pcpi_mem_wdata_0;
				2'd3: {memory[(pcpi_mem_addr_0 >> 2)+1][23:0], memory[pcpi_mem_addr_0 >> 2][31:24]} <= pcpi_mem_wdata_0;
			endcase
		end 
		
		if ((pcpi_mem_addr_0 >> 2) > `MEM_SIZE) begin
			$display("PCPI OUT-OF-BOUNDS MEMORY ACCESS TO %08x", pcpi_mem_addr_0);
			$display("pcpi_mem_addr_0 = %b", pcpi_mem_addr_0);
			$display("pcpi_mem_wdata_0 = %b", pcpi_mem_wdata_0);
			$finish;
		end
	end
	
	always @(posedge clk) begin
		pcpi_mem_ready_1 <= pcpi_mem_valid_1;
		pcpi_mem_rdata_1 <= 0;
		if (pcpi_mem_valid_1 && !pcpi_mem_write_1 && (pcpi_mem_addr_1 >> 2) < `MEM_SIZE) begin
			case(pcpi_mem_addr_1[1:0])
				2'd0: pcpi_mem_rdata_1 <= memory[pcpi_mem_addr_1 >> 2];
				2'd1: pcpi_mem_rdata_1 <= {memory[(pcpi_mem_addr_1 >> 2)+1][7:0], memory[pcpi_mem_addr_1 >> 2][31:8]};
				2'd2: pcpi_mem_rdata_1 <= {memory[(pcpi_mem_addr_1 >> 2)+1][15:0], memory[pcpi_mem_addr_1 >> 2][31:16]};
				2'd3: pcpi_mem_rdata_1 <= {memory[(pcpi_mem_addr_1 >> 2)+1][23:0], memory[pcpi_mem_addr_1 >> 2][31:24]};
			endcase
		end
		if (pcpi_mem_valid_1 && |pcpi_mem_write_1 && (pcpi_mem_addr_1 >> 2) < `MEM_SIZE) begin
			case(pcpi_mem_addr_1[1:0])
				2'd0: memory[pcpi_mem_addr_1 >> 2] <= pcpi_mem_wdata_0;
				2'd1: {memory[(pcpi_mem_addr_1 >> 2)+1][7:0], memory[pcpi_mem_addr_1 >> 2][31:8]} <= pcpi_mem_wdata_1;
				2'd2: {memory[(pcpi_mem_addr_1 >> 2)+1][15:0], memory[pcpi_mem_addr_1 >> 2][31:16]} <= pcpi_mem_wdata_1;
				2'd3: {memory[(pcpi_mem_addr_1 >> 2)+1][23:0], memory[pcpi_mem_addr_1 >> 2][31:24]} <= pcpi_mem_wdata_1;
			endcase
		end 
		
		if ((pcpi_mem_addr_1 >> 2) > `MEM_SIZE) begin
			$display("PCPI OUT-OF-BOUNDS MEMORY ACCESS TO %08x", pcpi_mem_addr_1);
			$display("pcpi_mem_addr_1 = %b", pcpi_mem_addr_1);
			$display("pcpi_mem_wdata_1 = %b", pcpi_mem_wdata_1);
			$finish;
		end
	end

	always @(posedge clk) begin
		pcpi_mem_ready_2 <= pcpi_mem_valid_2;
		pcpi_mem_rdata_2 <= 0;
		if (pcpi_mem_valid_2 && !pcpi_mem_write_2 && (pcpi_mem_addr_2 >> 2) < `MEM_SIZE) begin
			case(pcpi_mem_addr_2[1:0])
				2'd0: pcpi_mem_rdata_2 <= memory[pcpi_mem_addr_2 >> 2];
				2'd1: pcpi_mem_rdata_2 <= {memory[(pcpi_mem_addr_2 >> 2)+1][7:0], memory[pcpi_mem_addr_2 >> 2][31:8]};
				2'd2: pcpi_mem_rdata_2 <= {memory[(pcpi_mem_addr_2 >> 2)+1][15:0], memory[pcpi_mem_addr_2 >> 2][31:16]};
				2'd3: pcpi_mem_rdata_2 <= {memory[(pcpi_mem_addr_2 >> 2)+1][23:0], memory[pcpi_mem_addr_2 >> 2][31:24]};
			endcase
		end
		if (pcpi_mem_valid_2 && |pcpi_mem_write_2 && (pcpi_mem_addr_2 >> 2) < `MEM_SIZE) begin
			case(pcpi_mem_addr_2[1:0])
				2'd0: memory[pcpi_mem_addr_2 >> 2] <= pcpi_mem_wdata_2;
				2'd1: {memory[(pcpi_mem_addr_2 >> 2)+1][7:0], memory[pcpi_mem_addr_2 >> 2][31:8]} <= pcpi_mem_wdata_2;
				2'd2: {memory[(pcpi_mem_addr_2 >> 2)+1][15:0], memory[pcpi_mem_addr_2 >> 2][31:16]} <= pcpi_mem_wdata_2;
				2'd3: {memory[(pcpi_mem_addr_2 >> 2)+1][23:0], memory[pcpi_mem_addr_2 >> 2][31:24]} <= pcpi_mem_wdata_2;
			endcase
		end 
		
		if ((pcpi_mem_addr_2 >> 2) > `MEM_SIZE) begin
			$display("PCPI OUT-OF-BOUNDS MEMORY ACCESS TO %08x", pcpi_mem_addr_2);
			$display("pcpi_mem_addr_0 = %b", pcpi_mem_addr_2);
			$display("pcpi_mem_wdata_0 = %b", pcpi_mem_wdata_2);
			$finish;
		end
	end

	// Port2: CPU memory access
	generate if (FAST_MEMORY) begin
		always @(posedge clk) begin
			mem_ready <= 1;
			mem_rdata <= memory[memory_addr >> 2];
			if (memory_write && (memory_addr >> 2) < `MEM_SIZE)begin
				if (memory_wstrb[0]) memory[memory_addr >> 2][ 7: 0] <= memory_wdata[ 7: 0];
				if (memory_wstrb[1]) memory[memory_addr >> 2][15: 8] <= memory_wdata[15: 8];
				if (memory_wstrb[2]) memory[memory_addr >> 2][23:16] <= memory_wdata[23:16];
				if (memory_wstrb[3]) memory[memory_addr >> 2][31:24] <= memory_wdata[31:24];
			end
			else if (memory_write && memory_addr == 32'h1000_0000) begin
				$write("%c", memory_wdata[7:0]);
				$fflush();
			end 
			else if (memory_write && memory_addr != 32'h1000_0000) begin
				if (memory_addr == 32'h2000_0000) begin
					if (memory_wdata == 123456789) tests_finshed <= 1;
				end else begin
						$display("OUT-OF-BOUNDS MEMORY WRITE TO %08x", memory_addr);
						$finish;
				end
			end
		end
	end else begin
		always @(posedge clk) begin
			m_read_en <= 0;
			mem_ready <= memory_valid && !mem_ready && m_read_en;

			m_read_data <= memory[memory_addr >> 2];
			mem_rdata <= m_read_data;
			(* parallel_case *)
			case (1)
				memory_valid && !mem_ready && !memory_wstrb && (memory_addr >> 2) < `MEM_SIZE: begin
					m_read_en <= 1;
				end
				memory_valid && !mem_ready && |memory_wstrb && (memory_addr >> 2) < `MEM_SIZE: begin
					if (memory_wstrb[0]) memory[memory_addr >> 2][ 7: 0] <= memory_wdata[ 7: 0];
					if (memory_wstrb[1]) memory[memory_addr >> 2][15: 8] <= memory_wdata[15: 8];
					if (memory_wstrb[2]) memory[memory_addr >> 2][23:16] <= memory_wdata[23:16];
					if (memory_wstrb[3]) memory[memory_addr >> 2][31:24] <= memory_wdata[31:24];
					mem_ready <= 1;
				end
				memory_valid && !mem_ready && |memory_wstrb && memory_addr == 32'h1000_0000: begin
					mem_ready <= 1;
					$write("%c", memory_wdata[7:0]);
					$fflush();
				end
				memory_valid && !mem_ready && |memory_wstrb && memory_addr != 32'h1000_0000: begin
					mem_ready <= 1;
					if (memory_addr == 32'h2000_0000) begin
						if (memory_wdata == 123456789) tests_finshed <= 1;
					end else begin
						$display("OUT-OF-BOUNDS MEMORY WRITE TO %08x", mem_addr);
						$finish;
					end
				end
			endcase
		end
	end endgenerate

	integer cycle_counter;
	
	always @(posedge clk) begin
		cycle_counter <= resetn ? cycle_counter + 1 : 0;
		if (resetn && trap) begin
`ifndef VERILATOR
			repeat (10) @(posedge clk);
`endif
			$display("TRAP after %1d clock cycles", cycle_counter);
			if (tests_finshed) begin
				$display("ALL TESTS HAVE FINISHED.");
				$finish;
			end else begin
				$display("ERROR!");
				if ($test$plusargs("noerror"))
					$finish;
				$stop;
			end
		end
	end
endmodule
