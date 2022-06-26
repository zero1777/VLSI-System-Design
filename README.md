# VLSI-System-Design
NTHU CS. 10920 CS512000 VLSI System Design.

## hw1
- Train a simple CNN with post-training quantization.
- Get familiar with the PyTorch code

## hw2
- Model inference of the CNN pretrained in the hw1.
- Approach A, B: Reduce the bit-width of partial sums without hurting the accuracy.
- Approach C: Reduce the bit-width of partial sums **in each layer** without hurting the accuracy. 

## hw3
- Design a 4x4 systolic array engine of matrix multiplication in Verilog.
- This hardware engine needs to provides two kinds of test patterns for **fully-connected layer** and **convolution layer**, respectively.
  - For the **fully-connected layer**, the engine performs the vector-matrix multiplication, which is a reduction of matrix-matrix multiplication.
  - For the **convolution layer**, we assume that the input data is “unfolded” already. That is, the convolution is transformed to matrix-matrix multiplication.  

## hw4
-  Implement DNN in Verilog and C. Partition the application into hardware and software parts.
-  For the hardware part, wrap your Verilog modules using the **memory-mapped I/O (MMAP)** method. 
-  For the software part, compile your C code with the RISC-V toolchain.

## hw5
- Walk through the APR flow with Cadence Innovus

## Final project 
- Huffman Coding Accelerator in Verilog with PicoRV32 
- Encode
  - Implement a prefix sum array to record each symbol start index in the encoded sequence.
  - The encoder can parallel encode symbol according to the prefix sum array.
- Decode
  - Implement a gap array to record each segment's (8-bit) start index of the first complete encoded subsequence of a symbol.
  - Segments are partitioned from the encoded sequence with 8-bit each.
  - The decoder can parallel decode the encoded sequence according to the gap array. 
- Performance
  - Encode: unfinished
  - Decode: 2~3x speedup (w/ 4 decoder)
