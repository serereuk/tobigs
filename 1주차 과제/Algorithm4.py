a = [10, 20, 5, 30, 15]
d = [30, 35, 15, 5, 10, 20, 25]
c = [10,20,5,30]

def chopchop(temp):
    a = [[temp[i], temp[i+1]] for i in range(len(temp)-1)]
    if len(temp) ==2:
        return [0, temp]

    def cal(a, b):
        return a[0] * b[0] * b[1]

    def res(a, b):
        return [a[0], b[1]]

    def back(a):
        s = []
        for i in a:
            s.extend(i)
        d = [s[1:len(s)-1][2*i] for i in range(int((len(s)-2)/2))]
        d.insert(0, a[0][0])
        d.append(a[-1][1])
        return d

    if len(a) == 2:
        c = cal(a[0], a[1])
        return [c, res(a[0], a[1])]

    elif len(a) == 3:
        sd = a[:-1]
        temp0 = cal(sd[0], sd[1]) + cal(res(sd[0], sd[1]), a[-1])
        sd = a[1:]
        temp1 = cal(sd[0], sd[1]) + cal(a[0], res(sd[0], sd[1]))
        return [min([temp0, temp1]), res(a[0], a[2])]

    else:
        mem = []
        result = []
        final = []
        for i in range(len(a)-1):
            t = back(a[:i+1])
            f = back(a[i+1:])
            mem.extend([t,f])
        for i in mem:
            result.append(chopchop(i))

        for i in range(int(len(result)/2)):
            final.append([result[2*i][0] + result[2*i + 1][0] + cal(result[2*i][1], result[2*i + 1][1]),
                          res(result[2*i][1], result[2*i + 1][1])])

        return min(final)



chopchop(a)
chopchop(d)
chopchop(c)