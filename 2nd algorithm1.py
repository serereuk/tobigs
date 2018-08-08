def mostfind(temp):
    diction = {}
    temp = temp.upper()
    unique_temp = list(set(temp))
    for alphabet in unique_temp:
        diction[alphabet] = temp.count(alphabet)
    max_count = max(diction.values())
    if list(diction.values()).count(max_count) != 1:
        return "??"
    else:
        a = list(diction.values()).index(max_count)
        return list(diction.keys())[a]

temp = input("input: ") # 단어만 입력 ex) Mississipi 따옴표 없이

mostfind(temp)