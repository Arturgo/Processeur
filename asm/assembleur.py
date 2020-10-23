with open("test.py") as f:
    t=f.read()

exec("from asm import *\n"+t+"\nfichier.close()")
