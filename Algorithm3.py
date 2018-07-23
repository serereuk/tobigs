d = [10, 20, 40, 25, 30, 15, 50]

def increasing(temp, s):
    seed = temp[0]
    if len(s) == 0:
        s = increasing(temp[-2:], [[temp[-1]]])

    def sort(a):
        if sorted(a) == a:
            return a
        else:
            return []

    if len(temp) <= 2:
        if sort(temp) == temp:
            if seed not in s:
                s.append([seed])
            if temp not in s:
                s.append(temp)
            return s
        else:
            return s

    elif len(temp) == 3:
        s.append([seed])
        for i in s:
            if seed < i[0]:
                i.insert(0,seed)
        return s

    else:
        s = increasing(temp[1:], [])
        s.append([seed])
        for i in s:
            if seed < i[0]:
                i.insert(0, seed)
        return s

def checking(temp):
    s = []
    result = increasing(temp, [])
    for i in result:
        s.append(len(i))
    return max(s)

checking(d)