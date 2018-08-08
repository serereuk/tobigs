def repeat(temp):
    if temp[1] != " ":
        return ""
    else:
        result = ""
        num = int(temp[0])
        char = temp[2:]
        for o in char:
            for i in range(num):
                result = result + o

        return result


temp = input("input: ") # 3 ABC 이런식으로 입력 따옴표 없이

repeat(temp)