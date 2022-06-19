#include "firmware.h"
#define K						5
#define MAX_INT                 2147483647
#define DATA_LENGTH             3073
#define NUM_CLASS				10
#define NUM_TEST_IMAGE			50
#define NUM_TRAIN_IMAGE			950
#define IMAGE_OFFSET 			0x00010000

#define TEST_INDEX 0

void knn_pcpi(void)
{
	int i, j;
	/*int distances[NUM_TRAIN_IMAGE];
	int start = tick();
	//just an example of single test image!
    for(i = 0; i < NUM_TRAIN_IMAGE; i++){
		//TODO: implement hardware & software versions of pairwise distance computation
		//distances[i] = hard_knn_pcpi(TEST_INDEX, i + NUM_TEST_IMAGE);
		int diff, sum = 0;
		int test_value, train_value;
		for(j = 1; j < DATA_LENGTH; j++){
			test_value = *(int*)(IMAGE_OFFSET + TEST_INDEX * DATA_LENGTH*4 + 4*j);
			train_value = *(int*)(IMAGE_OFFSET + (i + NUM_TEST_IMAGE) * DATA_LENGTH*4 + 4*j);
			diff = test_value - train_value;
			sum += diff * diff;
		}
		distances[i] = sum;
		
	}
	
	//TODO: implement hardware version of label voting
	//you can use the algorithm we provided below, or any better algorithm you can think of
	int top_images[K][2];
	for(i = 0; i < K; i++){
		top_images[i][0] = MAX_INT; //distances of top-K closest images
		top_images[i][1] = 0;		//labels of top-K closest images
	}
		
	//iterate through all images, only keep the top-K closest images
	for(i = 0; i < NUM_TRAIN_IMAGE; i++){
        int insert_idx = -1;
		//get the index to insert, so that distances after this index are all larger
		for(j = 0; j < K; j++){
			if(distances[i] < top_images[j][0]){
				insert_idx = j;
				break;
			}
		}
		if(insert_idx >= 0){
			//insert new data, shift the rest
			for(j = K - 1; j > insert_idx; j--){
				top_images[j][0] = top_images[j-1][0];
				top_images[j][1] = top_images[j-1][1];
			}
			top_images[insert_idx][0] = distances[i];
			top_images[insert_idx][1] = i;
		}
	}

	int max_count = 0;
	int max_label = 0;
	int num_labels[NUM_CLASS] = {0};

	//count the votes for each labels
	for(i = 0; i < K; i++){
		int label = *(volatile uint32_t*)(IMAGE_OFFSET + (top_images[i][1] + NUM_TEST_IMAGE) * DATA_LENGTH * 4);
		num_labels[label]++;
	}
	
	//find the label with the most votes
	for(i = 0; i < NUM_CLASS; i++){
		if(num_labels[i] > max_count){
			max_count = num_labels[i];
			max_label = i;
		}
	}

	int stop = tick();

	print_str("\nThe result of soft_knn is:");
	print_dec(max_label);
	print_str("\nElapsed: ");
	print_dec(stop - start);
	print_str("\n");*/
	
	int hard_start = tick();
	int hard_ans = hard_knn_pcpi(TEST_INDEX, 0 + NUM_TEST_IMAGE);
	int hard_num_labels[NUM_CLASS] = {0};
	int hard_max_count, hard_max_label;

	for(i = 0; i < K; i++){
		int hard_label = hard_ans % 10;
		hard_ans /= 10;
		hard_num_labels[hard_label]++;
	}

	for(i = 0; i < NUM_CLASS; i++){
		if(hard_num_labels[i] > hard_max_count){
			hard_max_count = hard_num_labels[i];
			hard_max_label = i;
		}
	}
	int hard_stop = tick();
	
	print_str("\nThe result of hard_knn is:");
	print_dec(hard_max_label);
	print_str("\nElapsed: ");
	print_dec(hard_stop - hard_start);
	print_str("\n");
	
}
