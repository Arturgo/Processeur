import sys
class registre:
    def __init__(self, n):
        self.n=n
class addr:
    def __init__(self, n):
        self.n=n
for i,el in enumerate(("rip", "rax","rbx","rcx","rdx","rsi","rdi","rbp","rsp","r8","r9","r10","r11","r12","r13","r14")):
    exec(el+"=registre({})".format(i))

pr=print
def print(*arg):
    if not premierPasse:
        pr(*arg)

ligne=0
premierPasse=True
def Bin(a):
        if a==0:
            return '0'
        if a<0:
            return Bin(2**32-1)
        return (bin(a)[2:])[::-1]

    
def code(op_code,a,b,c):
    L=[x.n for x in (a,b,c) if isinstance(x, addr)]
    assert len(L)==0 or max(L)==min(L)
    global ligne
    while ligne%4:
        ligne+=1
        print("0"*32)
    ligne+=4
    adresse=0
    if isinstance(a,registre):
        aRam=0
        aCst=0
        a=a.n
    elif isinstance(a,addr):
        aRam=1
        aCst=0
        adresse=a.n
        a=0
    else:
        aRam=0
        aCst=1
        
    if isinstance(b,registre):
        bRam=0
        bCst=0
        b=b.n
    elif isinstance(b,addr):
        bRam=1
        bCst=0
        adresse=b.n
        b=0      
    else:
        bRam=0
        bCst=1

    if isinstance(c,registre):
        wReg=1
        wRam=0
        addrReg=c.n
    elif isinstance(c,addr):
        wRam=1
        wReg=0
        adresse=c.n
        addrReg=0
    else:
        raise "pb type de c"

    if isinstance(adresse, registre):
        adresse=adresse.n
        addrIsReg=1
    else:
        addrIsReg=0
  
    op_code=Bin(op_code)
    aRam=Bin(aRam)
    bRam=Bin(bRam)
    wRam=Bin(wRam)
    wReg=Bin(wReg)
    aCst=Bin(aCst)
    bCst=Bin(bCst)
    addrIsReg=Bin(addrIsReg)
    a=Bin(a)
    b=Bin(b)
    adresse=Bin(adresse)
    addrReg=Bin(addrReg)
    #print(op_code, aRam,bRam,wRam,wReg,aCst,bCst,addrIsReg,0,a,b,adresse,addrReg)
    print("{:0<16}{}{}{}{}{}{}{}{:0<9}{:0<32}{:0<32}{:0<24}{:0<4}{:0<4}".format(
        op_code, aRam,bRam,wRam,wReg,aCst,bCst,addrIsReg,0,a,b,adresse,addrReg,0))
    #print(aRam)

for i,(el,nb) in enumerate((["Mov", 2],["Inc",1],["Add", 3],
                           ["Not",2],["Neg", 2],["Sub", 3],
                           ["Xor",3],["Or", 3],["And",3],
                           ["Mul",3],["Jiz",3],["Jnz",3],["Jl",3],
                           ["Jle",3],["Jg",3],["Jge",3],["Div", 3],["Mod", 3])):
    if nb==1:
        exec("""
def {}(a):
    code({},a,0,a)""".format(el,i))
    if nb==2:
        exec("""
def {}(a,b):
    code({},a,0,b)""".format(el,i))
    if nb==3:
        exec("""
def {}(a,b,c):
    code({},a,b,c)""".format(el,i))
def Jmp(nb):
    #print(nb)
    code(0,nb,0,rip)
def Data(donnee):
    global ligne
    ligne+=1
    if isinstance(donnee, str):
        donnee=ord(donnee)
    print("{:0<32}".format(Bin(donnee)))
def Variable(donnee):
    Data(donnee)
    return addr(ligne-1)
def Label():
    return ligne
def Init():
    global ligne
    ligne=0
def Ecrire():
    global premierPasse
    premierPasse=False
    Init()
def Import(fichier):
    global ligne
    with open(fichier) as f:
        t=f.read()
        print(t)
        ligne+=(t.count('0')+t.count('1'))//32
