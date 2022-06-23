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
