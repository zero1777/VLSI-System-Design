#include "firmware.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_INT                 2147483647

// Here is the data offset
// We place DNN data in these addresses
#define INPUT_OFFSET 			    0x00010000
#define LENGTH_OFFSET			 	0x00020000
#define SYMBOL_OFFSET				0x00030000
#define ENCODE_OFFSET				0x00040000
#define HARD_CONV_OUTPUT_OFFSET		0x00050000

#define FC_INPUT_OFFSET 			0x00060000
#define FC_WEIGHT_OFFSET			0x00070000
#define SOFT_FC_OUTPUT_OFFSET		0x00080000
#define HARD_FC_OUTPUT_OFFSET		0x00090000
#define CONV_INPUT_OFFSET           0x00010000
#define UNFOLDED_CONV_INPUT_OFFSET	0x00020000
#define CONV_WEIGHT_OFFSET			0x00030000
#define SOFT_CONV_OUTPUT_OFFSET		0x00040000

// DNN_MMAP's address mapping
// Your addresses need to be maintained in both here and dnn_mmap.v
#define DNN_MMAP_BASE 			0x40000000
#define DNN_MMAP_RANG 			0x0000ffff
#define DNN_MMAP_READ_FINISH	0x0
#define DNN_MMAP_WRITE_CONV		0x4
#define DNN_MMAP_WRITE_N		0x8
#define DNN_MMAP_WRITE_C		0xc
#define DNN_MMAP_WRITE_H		0x10
#define DNN_MMAP_WRITE_W		0x14
#define DNN_MMAP_WRITE_R		0x18
#define DNN_MMAP_WRITE_S		0x1c
#define DNN_MMAP_WRITE_M		0x20
#define DNN_MMAP_WRITE_P		0x24
#define DNN_MMAP_WRITE_Q		0x28
#define DNN_MMAP_INPUT_OFFSET	0x2c
#define DNN_MMAP_WEIGHT_OFFSET	0x30
#define DNN_MMAP_OUTPUT_OFFSET	0x34
#define DNN_MMAP_WRITE_START	0x38

void SOFT()
{
	print_str("helllllo   ");
	// Your data location
	volatile signed char * input_data = INPUT_OFFSET;
	volatile signed char * symbol_data = SYMBOL_OFFSET;
	volatile int8_t* length_data = LENGTH_OFFSET;
	volatile int8_t* encode_data = ENCODE_OFFSET;

	int binarynum[32];
	int code_seq[100];
	int index = 7;

	// print input data 
	for(int i=0; i<15; i++){
		int j;
		// print_dec(*(input_data+i));
		print_str("\n");
		print_chr(*(input_data + i));
		for(j=0; j<5; j++){
			if(*(input_data + i) == *(symbol_data + j)){
				print_str(" find corresponding symbol in symbol.txt: ");
				print_dec(j);
				print_str("\n");
				break;
			}
		}
		int k = 0; // counter for binary array
		int n = *(encode_data + j);
		int bit_len = *(length_data + j);
		if(n == 0){
			binarynum[0] = 0;
			k++;
		}
		else{
			while(n > 0){
				binarynum[k] = n % 2;
				n /= 2;
				k++;
			}
		}
		if(k < bit_len){
			for(int i=k; i<bit_len; i++){
				binarynum[i] = 0;
			}
		}
		// print_dec(k);
		for(int i=bit_len-1; i>=0; i--){
			print_dec(binarynum[i]);
			int temp = index;
			code_seq[temp] = binarynum[i];
			if((temp+8) % 8 == 0){
				index += 15;
			}
			else{
				index -= 1;
			}
		}

		// print_dec(*(length_data + j));
		print_str("\n");
		// print_str("encode data is: ");
		// print_dec(*(encode_data + j));
		// print_str("\n");
		print_str("----------------------");
	}
	print_str("'\n");
	for(int i=0; i<40; i++){
		if(i != 0 && i % 8 == 0){
			print_str(" ");
		}
		print_dec(code_seq[i]);
	}

	// print length data
	// for(int i=0; i<5; i++){
	// 	print_dec(*(length_data+i));
	// 	print_str("\n");
	// }

	// print symbol data 
	// for(int i=0; i<10; i++){
	// 	// print_dec(*(symbol_data+i));
	// 	print_str("\n");
	// 	print_chr(*(symbol_data + i));
	// }

	// print encode data 
	// for(int i=0; i<5; i++){
	// 	print_dec(*(encode_data+i));
	// 	print_str("\n");
	// 	// print_chr(*(symbol_data + i));
	// }


}

// TODO 1
// This part will do convolution layer in software.
// The shapes and data locations are already given.
// All the output values are fixed to -1 as for a demonstration.
// You have to complete the for-loop to compute the convolution layer.
// (You don't need to unfold the data as in HW #3).
// You can refer to the convolution layer in your HW #2.
// Note: The simulation of this part will take at least 10 mins.
void soft_conv(int *input_shape, int *weight_shape, int *output_shape, volatile int8_t* input_data, volatile int8_t* weight_data, volatile int32_t* output_data)
{
	int N = input_shape[0];
	int C = input_shape[1];
	int H = input_shape[2];
	int W = input_shape[3];

	int M = weight_shape[0];
	int R = weight_shape[2];
	int S = weight_shape[3];

	int P = output_shape[2];
	int Q = output_shape[3];

	int h, w;
	volatile int8_t* temp_data = output_data;
	
	for(int i=0; i< output_shape[0]*output_shape[1]*output_shape[2]*output_shape[3]; i++){
		*(output_data + i) = 0;
	}
	
	for(int m=0; m<M; m++){
		for(int p=0; p<P; p++){
			for(int q=0; q<Q; q++){
				for(int c=0; c<C; c++){
					for(int r=0; r<R; r++){
						for(int s=0; s<S; s++){
							*(output_data + (m*P*Q) + (p*Q) + q) += *(input_data + (c*H*W) + ((p+r)*W) + (q+s)) * *(weight_data + (m*C*R*S) + (c*R*S) + (r*S) + s);
						}
					}
				}
			}
		}
	}
	


}

// TODO 2
// This part will do fully connected layer in software.
// The shapes and data locations are already given.
// All the output values are fixed to -1 as for a demonstration.
// You have to complete the for-loop to compute the fully connected layer.
// You can refer to the fully connected layer in your HW #2.
void soft_fc(int *input_shape, int *weight_shape, int *output_shape, volatile int8_t* input_data, volatile int8_t* weight_data, volatile int32_t* output_data)
{
	int N = input_shape[0];
	int C = input_shape[1];
	int H = input_shape[2];
	int W = input_shape[3];

	int M = weight_shape[0];
	int R = weight_shape[2];
	int S = weight_shape[3];

	/*
	for(int i=0; i< output_shape[0]*output_shape[1]*output_shape[2]*output_shape[3]; i++){
		*(output_data + i) = -1;
	}
	*/
	for(int w=0; w<R; w++){
		for(int h=0; h<H; h++){
			*(output_data + w) += *(input_data + h) * *(weight_data + w*H + h);
		}
	}
	

}

// TODO 3
// All the output values are fixed to -1 as for a demonstration.
// You have to complete the for-loop to perform the convolution unfolding.
// You can refer to the unfold.py in your HW #3.
void unfold(int *input_shape, int *weight_shape, int *output_shape, volatile int8_t* input_data, volatile int8_t* output_data)
{
	int N = input_shape[0];
	int C = input_shape[1];
	int H = input_shape[2];
	int W = input_shape[3];

	int M = weight_shape[0];
	int R = weight_shape[2];
	int S = weight_shape[3]; //k

	/*
	for(int i=0; i< output_shape[0]*output_shape[1]*output_shape[2]*output_shape[3]; i++){
		*(output_data + i) = -1;
	}
	*/

	for(int b=0; b<N; b++){
		for(int c=0; c<C; c++){
			int row_num = 0;
			for(int i=0; i<(H-S+1); i++){
				for(int j=0; j<(W-S+1); j++){
					for(int k=0; k<S; k++){
						for(int p=0; p<S; p++){
							*(output_data + (b*C*H*W) + (c*(H-S+1)*(W-S+1)*S*S) + (row_num*S*S) + (p+k*S)) = *(input_data + (b*C*H*W) + (c*H*W) + ((i+k)*H) + (j+p));
						}
					}
					row_num += 1;
				}
			}
		}
	}


}

// Here is how your code connects to your accelerator.
void hard_conv_mmap(int *input_shape, int *weight_shape, int *output_shape, uint8_t *input_offset, uint8_t *weight_offset, uint32_t *output_offset)
{
	// TODO 4
	// You have to write the correct data into DNN_MMAP's addresses.
	// We just write all zeros for a demonstration.
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_WRITE_CONV) = 1;
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_WRITE_N) = input_shape[0];
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_WRITE_C) = input_shape[1];
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_WRITE_H) = input_shape[2];
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_WRITE_W) = input_shape[3];
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_WRITE_R) = weight_shape[2];
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_WRITE_S) = weight_shape[3];
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_WRITE_M) = output_shape[1];
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_WRITE_P) = output_shape[2];
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_WRITE_Q) = output_shape[3];
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_INPUT_OFFSET) = input_offset;
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_WEIGHT_OFFSET) = weight_offset;
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_OUTPUT_OFFSET) = output_offset;

	// Start the convolution layer
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_WRITE_START) = 1;

	// If not using blocking output, SW needs to check the status
	// to make sure that HW output is ready.  Please refer to dnn_mmap.v
	while(*(volatile uint32_t*)(DNN_MMAP_BASE + DNN_MMAP_READ_FINISH) == 0){
	}

	return;
}

void mmap_hard_fc_mmap(int *input_shape, int *weight_shape, int *output_shape, uint8_t *input_offset, uint8_t *weight_offset, uint32_t *output_offset)
{
	// TODO 6
	// You have to write the correct data into DNN_MMAP's addresses.
	// We just write all zeros for a demonstration.
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_WRITE_CONV) = 0;
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_WRITE_N) = input_shape[0];
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_WRITE_C) = input_shape[1];
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_WRITE_H) = input_shape[2];
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_WRITE_W) = input_shape[3];
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_WRITE_R) = weight_shape[2];
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_WRITE_S) = weight_shape[3];
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_WRITE_M) = output_shape[1];
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_WRITE_P) = output_shape[2];
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_WRITE_Q) = output_shape[3];
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_INPUT_OFFSET) = input_offset;
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_WEIGHT_OFFSET) = weight_offset;
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_OUTPUT_OFFSET) = output_offset;

	// Start the fully connected layer
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_WRITE_START) = 1;

	// If not using blocking output, SW needs to check the status
	// to make sure that HW output is ready.  Please refer to dnn_mmap.v
	while(*(volatile uint32_t*)(DNN_MMAP_BASE + DNN_MMAP_READ_FINISH) == 0){
	}

	return;
}

void LENET_FC2_SOFT(void){

	// Timestamp
	int start, stop;

	int input_shape[4] = {1,1,120,1};
	int weight_shape[4] = {1,1,84,120};
	int output_shape[4] = {input_shape[0], weight_shape[0], weight_shape[2], input_shape[3]};

	// Your data location
	volatile int8_t* input_data = FC_INPUT_OFFSET;
	volatile int8_t* weight_data = FC_WEIGHT_OFFSET;
	volatile int32_t* soft_output_data = SOFT_FC_OUTPUT_OFFSET;


	// Software version
	start = tick();
	soft_fc(input_shape, weight_shape, output_shape, input_data, weight_data, soft_output_data);
	stop = tick();

	print_str("\nThe result of soft_fc is:\n");

	int output_size = output_shape[0] * output_shape[1] * output_shape[2] * output_shape[3];
	
	// Print the software results
	for(int i=0; i< output_size; i++){
		print_dec(i);
		print_str(": ");
		print_sign(*(soft_output_data + i));
		print_str("\n");
	}
	print_str("\nThe software time usage: ");
	print_dec(stop - start);
	print_str("\n");

}

void LENET_FC2_HARD(void){

	// Timestamp
	int start, stop;

	int input_shape[4] = {1,1,120,1};
	int weight_shape[4] = {1,1,84,120};
	int output_shape[4] = {input_shape[0], weight_shape[0], weight_shape[2], input_shape[3]};

	// Your data location
	volatile int8_t* input_data = FC_INPUT_OFFSET;
	volatile int8_t* weight_data = FC_WEIGHT_OFFSET;
	volatile int32_t* hard_output_data = HARD_FC_OUTPUT_OFFSET;

	// Hardware version
	start = tick();
	mmap_hard_fc_mmap(input_shape, weight_shape, output_shape, input_data, weight_data, hard_output_data);
	stop = tick();

	print_str("\nThe result of hard_fc is:\n");

	int output_size = output_shape[0] * output_shape[1] * output_shape[2] * output_shape[3];

	// Print the hardware results
	for(int i=0; i< output_size; i++){
		print_dec(i);
		print_str(": ");
		print_sign(*(hard_output_data + i));
		print_str("\n");
	}

	print_str("\nThe hardware time usage: ");
	print_dec(stop - start);
	print_str("\n");
}	

void LENET_CONV2_SOFT(void){
	
	// Timestamp
	int start, stop;

	int input_shape[4] =  {1,6,14,14};
	int weight_shape[4] = {16,6,5,5};
	int output_shape[4] = {input_shape[0], weight_shape[0], (input_shape[2]-weight_shape[2]+1), (input_shape[3]-weight_shape[3]+1)};

	volatile int8_t* input_data = CONV_INPUT_OFFSET;
	volatile int8_t* weight_data = CONV_WEIGHT_OFFSET;
	volatile int32_t* output_data = SOFT_CONV_OUTPUT_OFFSET;

	start = tick();
	soft_conv(input_shape, weight_shape, output_shape, input_data, weight_data, output_data);
	stop = tick();

	print_str("\nThe result of soft_conv is:\n");
	int output_size = output_shape[0] * output_shape[1] * output_shape[2] * output_shape[3];
	for(int i=0; i< output_size; i++){
		print_dec(i);
		print_str(": ");
		print_sign(*(output_data + i));
		print_str("\n");
	}
	print_str("\nThe time usage: ");
	print_dec(stop - start);
	print_str("\n");
	
}

// Here we will unfold the input conv data,
// then we use the unfolded data as our accelerator's conv inputs.
// You can comment out the hard_conv_mmap part if you just want to
// verify the unfold function.
void LENET_CONV2_HARD(void){
	
	// Timestamp
	int start, stop;
	
	// Conv2 original shape and unfold shape
	int input_shape[4] =  {1,6,14,14};
	int weight_shape[4] = {16,6,5,5};
	int output_shape[4] = {
		input_shape[0], 
		input_shape[1], 
		(input_shape[2]-weight_shape[2]+1)*(input_shape[3]-weight_shape[3]+1), 
		weight_shape[2]*weight_shape[3]
	};

	// Your data location
	volatile int8_t* input_data = CONV_INPUT_OFFSET;
	volatile int8_t* output_data = UNFOLDED_CONV_INPUT_OFFSET;

	// Software unfold
	start = tick();
	unfold(input_shape, weight_shape, output_shape, input_data, output_data);
	stop = tick();
	
	// Print the unfold results
	int output_size = output_shape[0] * output_shape[1] * output_shape[2] * output_shape[3];

	/*
	print_str("\nThe result of unfold is:\n");
	for(int i=0; i< output_size; i++){
		print_dec(i);
		print_str(": ");
		print_sign(*(output_data + i));
		print_str("\n");
	}
	*/

	print_str("\nThe time usage: ");
	print_dec(stop - start);
	print_str("\n");
	
	// Change the unfold output shape to conv input shape
	for(int i=0; i<4; i++){
		input_shape[i] = output_shape[i];
	}
	
	// Change the weight shape because you have flattened the weights
	weight_shape[2] = 25;
	weight_shape[3] = 1;

	// Change the output shape because you use unfold version
	output_shape[1] = weight_shape[0];
	output_shape[2] = input_shape[2];
	output_shape[3] = 1;

	// Your data location
	input_data = UNFOLDED_CONV_INPUT_OFFSET;
	volatile int8_t *weight_data = CONV_WEIGHT_OFFSET;
	volatile int32_t* hard_output_data = HARD_CONV_OUTPUT_OFFSET;
	
	start = tick();
	hard_conv_mmap(input_shape, weight_shape, output_shape, input_data, weight_data, hard_output_data);
	stop = tick();

	// Print your conv output
	output_size = output_shape[0] * output_shape[1] * output_shape[2] * output_shape[3];

	print_str("\nThe result of hard_conv is:\n");
	for(int i=0; i< output_size; i++){
		print_dec(i);
		print_str(": ");
		print_sign(*(hard_output_data + i));
		print_str("\n");
	}
	print_str("\nThe time usage: ");
	print_dec(stop - start);
	print_str("\n");
}



void dnn_mmap(void)
{
	//--------- software version ---------

	// conv2 
	// LENET_CONV2_SOFT();

	// fc2
	// LENET_FC2_SOFT();

	//--------- hardware version ---------

	// conv2 
	// TODO 5
	// Uncomment "LENET_CONV2_HARD();" after you finish unfold and hard_conv_mmap
	// LENET_CONV2_HARD();

	// fc2
	// TODO 7
	// Uncomment "LENET_FC2_HARD();" after you finish hard_fc_mmap
	// LENET_FC2_HARD();

	//-------------------------------------------------------------
	SOFT();

}

