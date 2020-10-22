with open("test.in") as f:
    L=list(f.readlines())

ligne=0

for i in range(len(L)):
    command=L[i]
    if command=="\n":
        continue
    ligne+=1
