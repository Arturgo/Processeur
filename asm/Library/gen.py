if True: #alphabet
    nb=26
    nbL=6
    nbC=6
else: #chiffres
    nb=10
    nbL=8
    nbC=5
    
for i in range(nb):
    L=[list(input()) for i in range(nbL)]
    for el in L:
        print("#"+''.join(el))
    print()
    for el in L:
        assert(len(el)==nbC)
        for i in el:
            if i==' ':
                print("Data(white)")
            elif i=='.':
                print("Data(grey)")
            else:
                print("Data(black)")
        print()
    el=input()
    assert(el=="")
    print()
