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

void PCPI_hard_fc_mmap(int *input_shape, int *weight_shape, int *output_shape, uint8_t *input_offset, uint8_t *weight_offset, uint32_t *output_offset)
{
	hard_dnn_pcpi(0,0);
}

void PCPI_LENET_FC2_HARD(void){

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
	PCPI_hard_fc_mmap(input_shape, weight_shape, output_shape, input_data, weight_data, hard_output_data);
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


void dnn_pcpi(void)
{
	// fc2
	PCPI_LENET_FC2_HARD();
}

