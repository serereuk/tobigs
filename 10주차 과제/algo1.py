#1)

def coinmaster(temp):
    return max(temp[temp.index(min(temp)):])-min(temp)
coin = [10300,9600,9800,8200,7800,8300,9500,9800,10200,9500]
coinmaster(coin)


#2)
import numpy as np
from sys import stdin

class baaam():
    def __init__(self):
        self.grid = int(stdin.readline())
        self.ground = np.zeros((self.grid, self.grid))
        self.temp = []; self.grounds = []
        for i in range(self.grid):
            a, b, c = map(int, stdin.readline().rstrip().split(" "))
            self.ground[i] = [a, b, c]
        while True:
            try:
                a, b, c = map(str, stdin.readline().rstrip().split(" "))
                self.temp.append([a, b, c])
            except:
                break
        for i in range(len(self.temp)):
            self.grounds.append(self.ground)

    def pickmepickme(self, temp):
        temp2 = np.copy(temp); length = temp.ndim +1
        temp2[0] = np.cumsum(temp[0])
        temp2[:,0] = np.cumsum(temp[:,0])
        for i in range(1,length):
            for j in range(1,length):
                temp2[i,j] = max(temp2[i,j] + temp2[i-1, j], temp2[i,j] + temp2[i, j-1])
        return np.sum(temp2)

    def main(self):
        if self.temp == []:
            print(self.pickmepickme(self.ground))
        else:
            print(self.pickmepickme(self.ground))
            for i in range(len(self.temp)):
                if self.temp[i][0] == "A":
                    self.grounds[i][int(self.temp[i][1])-1, int(self.temp[i][2])-1] += 1
                else:
                    self.grounds[i][int(self.temp[i][1])-1, int(self.temp[i][2])-1] -= 1
                print(self.pickmepickme(self.grounds[i]))


ex = baaam()
ex.main()








