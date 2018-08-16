def repeat(temp):
    if len(temp) == 1:
        return
    else:
        result = ""
        char = temp[2:]
        for o in char:
            result = result + o * int(temp[0])
        return result

temp = input("input: ") # 3 ABC 이런식으로 입력 따옴표 없이

repeat(temp)

def Main(temp):
    result = ""
    R = int(temp[0])
    S = temp[2:]
    for o in S:
        result += o * R
    return result
nsim = input()
for _ in range(int(nsim)):
    temp = input()
    print(Main(temp))

# 아래꺼는 백준 통과용