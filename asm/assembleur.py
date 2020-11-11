import sys

r="from asm import *\n"
sys.argv.append("codes/serpent.s")
with open(sys.argv[1]) as f:
    t=f.read()
t+='\n'

while t.find("import ")!=-1:
    pos=t.find("import ")
    nom=t[pos+len("import "):]
    nom=nom[:nom.find('\n')]
    with open(nom) as f:
        v=f.read()
    t=t.replace("import "+nom, v)

t=list(map(lambda x : x+'\n',t.split('\n')))



for el in t:
    r+="""try:
    None
    {}
except NameError:
    None
""".format(el)
r+="\nInit()\n"
r+=''.join(t)
r+="\nEcrire()\n"
r+=''.join(t)

exec(r)
