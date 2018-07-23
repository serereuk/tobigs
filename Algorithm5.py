a = [[1,3,5], 8]

def calcul(temp):

    if len(temp[0]) == 1:
        if temp[1] % temp[0][0] == 0:
            return 1
        else:
            return 0
    else:
        i = 0
        s = int(temp[1]/temp[0][0])
        j = 0
        result = []
        while i < s+1:
            s2 = int((temp[1] - temp[0][0]*i)/temp[0][1])
            while j < s2+1:
                if (temp[1] - temp[0][0]*i -temp[0][1]*j) % temp[0][2] ==0:
                    result.append("o")
                    j += 1
                else:
                    j += 1
            i += 1
            j = 0

        return len(result)




calcul(a)
