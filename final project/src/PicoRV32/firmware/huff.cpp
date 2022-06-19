#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <queue>

struct n{
    char letter;
    int freq;
    struct n *next;
    struct n *left;
    struct n *right;
};
typedef struct n node;

struct huff{
    char letter;
    char code[5000];
};
typedef struct huff huffcode;

int count = 0;
huffcode huffmanCode[5000];

void constructTree(node *root, int total) {
    FILE *f2 = fopen("tree.txt", "a+");
    std::queue <node *> qu;
    qu.push(root);

    int cnt = 0;
    while (cnt < total && !qu.empty()) {
        node *n = qu.front();
        qu.pop();

        if (n == NULL) {
            fprintf(f2, "0");
            continue;
        }

        qu.push(n->left);
        qu.push(n->right);
        
        if (!n->left && !n->right) {
            cnt++;
            fprintf(f2, "%c", n->letter);
        } 
        else {
            fprintf(f2, "0");
        }

    }
    fclose(f2);
}

void assignCodes(node *root, char arr[], int index){

    if(root->left){
        arr[index] = '0';
        assignCodes(root->left, arr, index+1);
    }

    if(root->right){
        arr[index] = '1';
        assignCodes(root->right, arr, index+1);
    }

    if(!root->right && !root->left){
        FILE *f = fopen("output.txt", "a+");
        FILE *f1 = fopen("length.txt", "a+");
        
        if (f == NULL || f1 == NULL)
        {
            printf("Error opening file!\n");
            exit(1);
        }
        
        huffmanCode[count].letter = root->letter;
        fprintf(f, "%c: ", root->letter);

        fprintf(f1, "%c: ", root->letter);
        fprintf(f1, "%d ", index);
        // printf(" letter is: %c", huffmanCode[count].letter);

        for (int i = 0; i < index; ++i){
            fprintf(f, "%c", arr[i]);
            huffmanCode[count].code[i] = arr[i];
        }

        int ans = 0;
        int pow = 1;
        for (int i = index-1; i>=0; i--) {
            if (arr[i] == '1') {
                ans += pow;
            }
            pow *= 2;
        }
        fprintf(f, " %d", ans);
        // printf(" code is: %s", huffmanCode[count].code);
        fprintf(f, "\n");
        fprintf(f1, "\n");
        count++;
        fclose(f);
        fclose(f1);
    }
    
}

node *searchList(node *head, char arg){ 	
    node *tmp;
    tmp = head;
    while(tmp!=NULL){
        if(tmp->letter == arg)
            return tmp;
        tmp=tmp->next;
    }
    return NULL;
}

node *createList(char text[]){
    int i, length;
    node *head, *tmp;

    head = (node*)malloc(sizeof(node));
    head->letter = text[0];
    head->freq = 1;
    head->left = NULL;
    head->right = NULL;
    head->next = NULL;
    tmp = head;	
    length = strlen(text);	
    for(i=1; i<length; i++){
        if(searchList(head, text[i]) == NULL){
        tmp->next = (node*)malloc(sizeof(node));
        tmp = tmp->next;
        tmp->left = NULL;
        tmp->right = NULL;
        tmp->next = NULL;
        tmp->freq = 1;
        tmp->letter = text[i];
        
        }
        else{
            searchList(head, text[i])->freq++;
        }
    }
    return head;
}

node *insertFront(node *head, node *element){
    node *tmp;
    tmp = head;
    while(tmp->next != element){
        tmp = tmp->next;
    }
    tmp->next = element->next;
    element->next = head;
    head = element;
    return head;
}

void insertIn(node* head, node *place, node *element){
    node *tmp;
    tmp = head;
    while(tmp->next != element){
        tmp = tmp->next;
    }
    tmp->next = element->next;
    tmp = head;
    while(tmp->next != place){
        tmp = tmp->next;
    }
    tmp->next = element;
    element->next = place;
}

node *sortList(node *head){
    node *tmp, *tmp2;

    tmp = head;
    tmp2 = tmp->next;
    while(tmp2 != NULL){
        //	Finding the place to insert:
        while(tmp->next != tmp2 && tmp->freq <= tmp2->freq){
            tmp = tmp->next;
        }
        if(tmp->freq > tmp2->freq){
            if(tmp == head)
                head = insertFront(head, tmp2);
            else
                insertIn(head, tmp, tmp2);
        }
        tmp = head;
        tmp2 = tmp2->next;
    }
    return head;
}

node *createHuffman(node *head){
    node *tmp, *tmp2, *interval;
    //	Loops until there are 1 or 2 nodes exist in first level.
    while(head->next->next != NULL && head->next != NULL){
        tmp = head;
        tmp2 = head->next;
        head = tmp2->next;
        tmp->next = NULL;
        tmp2->next = NULL;
        interval = (node *)malloc(sizeof(node));
        interval->freq = tmp->freq + tmp2->freq;
        interval->left = tmp;
        interval->right = tmp2;
        // interval->letter = "";
        //	Add to front:
        if(interval->freq <= head->freq){
            interval->next = head;
            head = interval;
        }
        //	Add to tail or middle.
        else{
            node *tmp3 = head;
            //	Finding place to add:
            while(tmp3->next != NULL && tmp3->next->freq < interval->freq){
                tmp3 = tmp3->next;
            }
            interval->next = tmp3->next;
            tmp3->next = interval;
        }
    }
    //	If there are 2 nodes in first level, links them in one parent root.
    if(head->next->next == NULL){
        interval = (node*)malloc(sizeof(node));
        interval->freq = head->freq + head->next->freq;
        interval->next = NULL;
        // interval->letter = "";
        interval->left = head;
        interval->right = head->next;
        return interval;
    }
    else{
        return head;
    }	
}

int main(){
    int i;
    node * head, * root;
    
    
    char text[] = "ABCDEEEEEDDDCCB";
    head = createList(text);
    head = sortList(head);
    root = createHuffman(head);

    char arr[100], index = 0;
    assignCodes(root, arr, index);
    constructTree(root, 5);

    char encodeStr[5000] = "";
    
    for(int i=0; i<strlen(text); i++){
        for(int j=0; j<count; j++){
            // printf("%c: ", temp->letter);
            if(text[i] == huffmanCode[j].letter){
                // printf("text is %c and letter is %c", text[i], huffmanCode[j].letter);
                strcat(encodeStr, huffmanCode[j].code);
                break;
            }
        }
    }
    


    printf("\n\nORIGINAL SEQUENCE: %s\n", text);
    printf("ENCODED SEQUENCE: %s\n", encodeStr);
    
    free(root);

    return 0;
}
