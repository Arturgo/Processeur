import sys

r="from asm import *\n"
with open(sys.argv[1]) as f:
    t=list(f.readlines())
for el in t:
    r+="""try:
    {}
except NameError:
    None
""".format(el)
r+="\nInit()\n"
r+=''.join(t)
r+="\nEcrire()\n"
r+=''.join(t)
exec(r)
