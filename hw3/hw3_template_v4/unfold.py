import numpy as np
from numpy import zeros
import sys

# print the full array content without truncation
#np.set_printoptions(threshold=sys.maxsize)

# feature map unfold
def unfold_matrix(X, k):
    N, C, H, W = X.shape
    xx = zeros((N, C, (H - k + 1) * (W - k + 1), k**2))
    
    def make_row(x):
        return x.flatten()

    for b in range(N):
        for c in range(C):
            row_num = 0
            for i in range(H- k+ 1):
                for j in range(W - k + 1):

                    #collect block of k*k elements and convert to row
                    xx[b,c,row_num,:] = make_row(X[b, c, i:i+k, j:j+k])
                    row_num = row_num + 1
    return xx

# your image shape
shape = (1,6,14,14)
weight_shape = (16,6,5,5)

path = './conv2_input.csv'
x = np.genfromtxt(fname = path, dtype = float).reshape(shape).astype(int)

print('x = ',x, end='\n')

k = weight_shape[3]
x_unfolded = unfold_matrix(x, k)

print('x_unfold = ', x_unfolded, end='\n')
print('shape of x unfold:', x_unfolded.shape, end='\n')

np.savetxt('./input_conv.csv', x_unfolded.reshape(-1),fmt='%d', delimiter=',')