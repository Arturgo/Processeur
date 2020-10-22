class registre:
    def __init__(self, n):
        self.n=n
class addr:
    def __init__(self, n):
        self.n=n
for i,el in enumerate(("rip", "rax","rbx","rcx","rdx","rsi","rdi","rbp","rsp","r8","r9","r10","r11","r12","r13","r14")):
    exec(el+"=registre({})".format(i))

def code(op_code,wRam,wReg,a,b,adresse=0,addresseReg=0):
    if isinstance(a,registre):
        aRam=0
        aCst=0
        a=a.n
    else if isinstance(a,addr):
        a=0
        aRam=1
        aCst=0
        adresse=a.n
    else:
        aRam=0
        aCst=1
        
    if isinstance(b,registre):
        bRam=0
        bCst=0
        b=b.n
    else if isinstance(b,addr):
        b=0
        bRam=1
        Cst=0
        adresse=b.n
    else:
        bRam=0
        bCst=1
        
    def Bin(a):
        if a==0:
            return '0'
        return bin(a)[2:]
    op_code=Bin(op_code)
    aRam=Bin(aRam)
    bRam=Bin(bRam)
    wRam=Bin(wRam)
    wReg=Bin(wReg)
    aCst=Bin(aCst)
    bCst=Bin(bCst)
    addrIsReg=Bin(bRam)
    a=Bin(b)
    b=Bin(b)
    addr=Bin(addr)
    addrReg=Bin(addrReg)
    return "{:0>16}{}{}{}{}{}{}{}{:0>11}{:0>32}{:0>32}{:0>24}{:0>4}{:0>4}".format(
        op_code, aRam,bRam,wRam,wReg,aCst,bCst,addrIsReg,0,a,b,addresse,addrReg,0)
