import numpy as np

a = np.array([[1,0,1,1,1], [0,0,0,1,1], [0,1,1,1,1], [0,1,1,1,1], [0,1,1,1,1]])
b = np.array([[1,0,1,1,1], [1,1,1,1,1], [0,1,1,1,1], [0,1,1,1,1], [0,1,1,1,1]])

class window():
    def __init__(self, temp):
        self.size = len(np.diag(temp)) - 1

    def check(self,temp):

        def slice(s, d):
            sd = []
            if d == 1:
                for t in s:
                    sd.append(t[:-1])
            else:
                for t in s:
                    sd.append(t[1:])
            return np.array(sd)

        if np.all(np.ones(temp.shape) == temp):
            return np.prod(temp.shape)

        elif temp.shape == (2, 2):
            return np.sum(temp)

        else:
            temp1 = self.check(slice(temp[:-1, ], 1))
            temp2 = self.check(slice(temp[1:, ], 1))
            temp3 = self.check(slice(temp[:-1, ], 0))
            temp4 = self.check(slice(temp[1:, ], 0))

            return [temp1, temp2, temp3, temp4]

    def maxcheck(self, temp):
        a = []
        for j in range(self.size):
            if temp[j] == self.size*self.size:
                return temp[j]

        for i in range(self.size):
            for j in range(self.size):
                a.append(np.max(temp[i][j]))
        return np.max(a)


w1 = window(a)
w2 = window(b)

w1.maxcheck(w1.check(a))
w2.maxcheck(w2.check(b))
