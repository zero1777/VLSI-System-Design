#include "firmware.h"

#define MAX_INT                 2147483647

#define CONV_INPUT_OFFSET 			0x00010000
#define UNFOLDED_CONV_INPUT_OFFSET 	0x00020000
#define CONV_WEIGHT_OFFSET			0x00030000
#define SOFT_CONV_OUTPUT_OFFSET		0x00040000
#define HARD_CONV_OUTPUT_OFFSET		0x00050000

#define FC_INPUT_OFFSET 			0x00060000
#define FC_WEIGHT_OFFSET			0x00070000
#define SOFT_FC_OUTPUT_OFFSET		0x00080000
#define HARD_FC_OUTPUT_OFFSET		0x00090000

// DNN_MMAP's address mapping
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

void unfold(int *input_shape, int *weight_shape, int *output_shape, volatile int8_t* input_data, volatile int8_t* output_data)
{
	int N = input_shape[0];
	int C = input_shape[1];
	int H = input_shape[2];
	int W = input_shape[3];

	int M = weight_shape[0];
	int R = weight_shape[2];
	int S = weight_shape[3];

	int block_height = H-R+1;
	int block_width = W-S+1;

	int W_S = W - S;
	int _RW_1 = 1 - R*W;
	int S_1 = S-1;
	int RW_W = R*W-W;
	volatile int8_t* input_index = input_data; 
	volatile int8_t* output_index = output_data;
	for(int n=0;n<N; n++){
		for(int c=0; c< C; c++){
			for(int i=0; i< block_height; i++){
				for(int j=0; j< block_width; j++){
					for(int r=0; r<R; r++){
						for(int s=0; s<S; s++){
							*(output_index) = *(input_index);
							input_index++;
							output_index++;
						}
						input_index += W_S;
					}
					input_index += _RW_1;
				}
				input_index += S_1;
			}
			input_index += RW_W;
		}
	}
}

void hard_conv_mmap(int *input_shape, int *weight_shape, int *output_shape, uint8_t *input_offset, uint8_t *weight_offset, uint32_t *output_offset)
{
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_WRITE_CONV) = 1;
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_WRITE_N) = input_shape[0];
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_WRITE_C) = input_shape[1];
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_WRITE_H) = input_shape[2];
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_WRITE_W) = input_shape[3];
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_WRITE_R) = weight_shape[2];
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_WRITE_S) = weight_shape[3];
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_WRITE_M) = weight_shape[0];
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_WRITE_P) = output_shape[2];
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_WRITE_Q) = output_shape[3];
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_INPUT_OFFSET) = input_offset;
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_WEIGHT_OFFSET) = weight_offset;
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_OUTPUT_OFFSET) = output_offset;
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_WRITE_START) = 1;

	// If not using blocking output, SW need to check the status
	// so that HW output is correct, please refer to dnn_mmap.v
	while(*(volatile uint32_t*)(DNN_MMAP_BASE + DNN_MMAP_READ_FINISH) == 0){
	}

	return;
}

void hard_fc_mmap(int *input_shape, int *weight_shape, int *output_shape, uint8_t *input_offset, uint8_t *weight_offset, uint32_t *output_offset)
{
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_WRITE_CONV) = 0;
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_WRITE_N) = input_shape[0];
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_WRITE_C) = input_shape[1];
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_WRITE_H) = input_shape[2];
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_WRITE_W) = input_shape[3];
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_WRITE_R) = weight_shape[2];
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_WRITE_S) = weight_shape[3];
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_WRITE_M) = weight_shape[0];
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_WRITE_P) = output_shape[2];
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_WRITE_Q) = output_shape[3];
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_INPUT_OFFSET) = input_offset;
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_WEIGHT_OFFSET) = weight_offset;
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_OUTPUT_OFFSET) = output_offset;
	*(volatile uint32_t *)(DNN_MMAP_BASE + DNN_MMAP_WRITE_START) = 1;
	// If not using blocking output, SW need to check the status
	// so that HW output is correct, please refer to dnn_mmap.v
	while(*(volatile uint32_t*)(DNN_MMAP_BASE + DNN_MMAP_READ_FINISH) == 0){
	}
	return;
}



void LENET_FC2_HARD(void){

	// timestamp
	int start, stop;

	int input_shape[4] = {1,1,120,1};
	int weight_shape[4] = {1,1,84,120};
	int output_shape[4] = {input_shape[0], weight_shape[0], weight_shape[2], input_shape[3]};

	// your data location
	volatile int8_t* input_data = FC_INPUT_OFFSET;
	volatile int8_t* weight_data = FC_WEIGHT_OFFSET;
	volatile int32_t* hard_output_data = HARD_FC_OUTPUT_OFFSET;

	// the hardware version
	start = tick();
	hard_fc_mmap(input_shape, weight_shape, output_shape, input_data, weight_data, hard_output_data);
	stop = tick();

	print_str("\nThe result of hard_fc is:\n");

	int output_size = output_shape[0] * output_shape[1] * output_shape[2] * output_shape[3];

	// print the hardware result
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

void LENET_CONV2_HARD(void){
	
	// timestamp
	int start, stop;
	
	// conv2 original shape and unfold shape
	int input_shape[4] =  {1,6,14,14};
	int weight_shape[4] = {16,6,5,5};
	int output_shape[4] = {
		input_shape[0], 
		input_shape[1], 
		(input_shape[2]-weight_shape[2]+1)*(input_shape[3]-weight_shape[3]+1), 
		weight_shape[2]*weight_shape[3]
	};

	// your data location
	volatile int8_t* input_data = CONV_INPUT_OFFSET;
	volatile int8_t* output_data = UNFOLDED_CONV_INPUT_OFFSET;

	// softward unfold
	start = tick();
	unfold(input_shape, weight_shape, output_shape, input_data, output_data);
	stop = tick();
	
	// print unfold result
	int output_size = output_shape[0] * output_shape[1] * output_shape[2] * output_shape[3];

	print_str("\nThe time usage: ");
	print_dec(stop - start);
	print_str("\n");
	
	// change the unfold output shape to conv input shape
	for(int i=0; i<4; i++){
		input_shape[i] = output_shape[i];
	}
	
	// change the weight shape because your have flattened the weight 
	weight_shape[2] = 25;
	weight_shape[3] = 1;

	// change the output shape because you use unfold version
	// However your data still put in correct location
	output_shape[1] = weight_shape[0];
	output_shape[2] = input_shape[2];
	output_shape[3] = 1;

	// your data location
	input_data = UNFOLDED_CONV_INPUT_OFFSET;
	volatile int8_t *weight_data = CONV_WEIGHT_OFFSET;
	volatile int32_t* hard_output_data = HARD_CONV_OUTPUT_OFFSET;
	
	start = tick();
	hard_conv_mmap(input_shape, weight_shape, output_shape, input_data, weight_data, hard_output_data);
	stop = tick();

	// print your conv output
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
	//hardware version
	// conv2 
	LENET_CONV2_HARD();

	// fc2
	LENET_FC2_HARD();

}

