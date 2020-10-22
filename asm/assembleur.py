def code(op_code, aRam,bRam,wRam,wReg,aCst,bCst,addrIsReg,a,b,addr,addrReg):
    return "{:0>16}{}{}{}{}{}{}{}{}{}{}{}{}{}".format(op_code, aRam,bRam,wRam,wReg,aCst,bCst,addrIsReg,a,b,addr,addrReg)
    

with open("test.in") as f:
    L=list(f.readlines())

ligne=0
variable={"rip":0,}

for i in range(len(L)):
    command=L[i]
    if command=="\n":
        continue
    try :
        a=command[:command.find('(')]
        b=command[command.find('(')+1:command.find(',')]
        c=command[command.find(',')+1:command.find(')')]
    except:
        print(command, 'erreur')
    print(a,b,c)
    ligne+=1
