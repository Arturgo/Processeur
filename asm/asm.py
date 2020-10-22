class registre:
    def __init__(self, n):
        self.n=n
class addr:
    def __init__(self, n):
        self.n=n
for i,el in enumerate(("rip", "rax","rbx","rcx","rdx","rsi","rdi","rbp","rsp","r8","r9","r10","r11","r12","r13","r14")):
    exec(el+"=registre({})".format(i))
fichier=open('../OurJazz/Tests/gen.data','w')

def code(op_code,a,b,c):
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
  
    def Bin(a):
        if a==0:
            return '0'
        return (bin(a)[2:])[::-1]
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
    print( "{:0<16}{}{}{}{}{}{}{}{:0<9}{:0<32}{:0<32}{:0<24}{:0<4}{:0<4}".format(
        op_code, aRam,bRam,wRam,wReg,aCst,bCst,addrIsReg,0,a,b,adresse,addrReg,0),file=fichier)
    print(aRam)
def mov(a,b):
    code(0,a,0,b)
def inc(a):
    code(1,a,0,a)
