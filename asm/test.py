from asm import *

mov(15,r8)
inc(r8)
inc(addr(20))
inc(addr(r8))

fichier.close()
