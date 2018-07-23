import numpy as np

a = [7, [3,8], [8,1,0], [2,7,4,4], [4,5,2,6,5]]

def line(a):

    def slice(x, d):
        sd = []
        temp = x[1:]
        if d == 1:
            for t in temp:
                sd.append(t[:-1])
        else:
            for t in temp:
                sd.append(t[1:])
        return sd

    if len(a) == 2:
        return np.max(np.array(a[0]) + np.array(a[1]))

    elif len(a) == 3:
        temp1 = slice(a, 1)
        temp2 = slice(a, 0)
        return a[0] + max([line(temp1), line(temp2)])

    else:
        temp1 = slice(a, 1)
        temp2 = slice(a, 0)
        return a[0]+ max([line(temp1), line(temp2)])

line(a)






