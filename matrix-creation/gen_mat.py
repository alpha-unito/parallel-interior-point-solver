import sys
import numpy as np

diagSize = int(sys.argv[1])
cut = int(sys.argv[2])
outFilenameA = sys.argv[3]
outFilenameC = sys.argv[4]

# generate matrix
matrix = np.random.rand(diagSize, diagSize)
matrixT = matrix.transpose()
result = (np.matmul(matrix, matrixT))[0:cut, 0:diagSize]
np.savetxt(outFilenameA, result, delimiter=' ', fmt='%6.10f')

# generate vector
np.savetxt(outFilenameC, np.random.rand(diagSize, 1), delimiter=' ', fmt='%6.10f')
