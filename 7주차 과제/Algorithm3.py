#1.
user = (16, 345, 56, 3457, 236, 354, 75, 634, 2, 23, 6537, 4576, 4, 3)
def Reverse_Order(user):
    return (list(reversed(list(user))))
Reverse_Order(user)

#2.
def Avoiding_Duplicates():
    temp = []
    while True:
        a = input()
        if a == "":
            return list(set(temp))
        else:
            temp.append(a)

#3
def NZP():
    neg = []; zero = []; pos = []
    while True:
        a = input()
        if a == "":
            return print("Negative numbers ", neg,"\n","zeros ",zero,"\n","Positive numbers ",pos)
        elif int(a) > 0:
            pos.append(int(a))
        elif int(a) < 0:
            neg.append(int(a))
        else:
            zero.append(int(a))

#4
def Perfect_Numbers():
    num = int(input()); temp = []
    for i in range(1,num):
        if num % i == 0:
            temp.append(i)
    if sum(temp) == num:
        print("Perfect number")
    else:
        print("Not perfect")

#5
def Format():
    a = input()
    b = a.replace("and", ",").split(",")
    for i in b:
        print("items "+i)
    print("items\n", a)


#6
def Unique_Characters():
    return len(list(set([i for i in input()])))

#7
def Anagrams(a,b):
    if set([i for i in a]) == set([i for i in b]):
        return True
    else:
        return False
