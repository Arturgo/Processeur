nouvJeu=Label()
white = (2 ** 32) - 1
grey = 0b10111111101111111011111111111111
red=   0b11111111000000000000000011111111
black = 0
screen = (2 ** 23)
screen_width = 64
screen_height = 48
screen_update = screen + screen_width * screen_height
keyboard = screen_update + 1
stack = screen - 1
minutes = addr(screen_update + 2)
millisecs = addr(screen_update + 3)
ecart=100

digit_size = 40

T=4
nbLigne=12
nbColonne=16

# Move stack pointer
Mov(stack, rsp)

# Init everything in white

Mov(screen, rax)
Add(screen, screen_width * screen_height, rbx)

Erase=Label()
Mov(white, addr(rax))
Add(rax, 1, rax)

Sub(rbx, rax, r8)

Jnz(r8, Erase, rip)


#initialise un serpent de taille 3

debutSerpent=rsp
finSerpent=rax
posSerpentL=rcx
posSerpentC=rdx

Jmp(saut)
dL=Variable(0)
dC=Variable(1)
genAlea=Variable(0)
dernierTemps=Variable(0)
fruitL=Variable(0)
fruitC=Variable(0)
saut=Label()

Mov(millisecs, r8)
Mov(r8, genAlea) 
Mov(nbLigne//2,posSerpentL)
Mov(nbColonne//2-1,posSerpentC)
Mov(posSerpentL, addr(debutSerpent))
Sub(debutSerpent, 1, debutSerpent)
Mov(posSerpentC, addr(debutSerpent))
Sub(debutSerpent, 1, debutSerpent)
Mov(debutSerpent, finSerpent)
Mov(rip, rbx)
Jmp(Noir)


Add(posSerpentC, 1, posSerpentC)
Mov(posSerpentL, addr(debutSerpent))
Sub(debutSerpent, 1, debutSerpent)
Mov(posSerpentC, addr(debutSerpent))
Sub(debutSerpent, 1, debutSerpent)
Mov(rip, rbx)
Jmp(Noir)

Add(posSerpentC, 1, posSerpentC)
Mov(posSerpentL, addr(debutSerpent))
Sub(debutSerpent, 1, debutSerpent)
Mov(posSerpentC, addr(debutSerpent))
Sub(debutSerpent, 1, debutSerpent)
Mov(rip, rbx)
Jmp(Noir)

Add(posSerpentC, 1, posSerpentC)
Mov(posSerpentL, addr(debutSerpent))
Sub(debutSerpent, 1, debutSerpent)
Mov(posSerpentC, addr(debutSerpent))
Sub(debutSerpent, 1, debutSerpent)
Mov(rip, rbx)
Jmp(Noir)
Add(posSerpentC, 1, posSerpentC)
Mov(posSerpentL, addr(debutSerpent))
Sub(debutSerpent, 1, debutSerpent)
Mov(posSerpentC, addr(debutSerpent))
Sub(debutSerpent, 1, debutSerpent)
Mov(rip, rbx)
Jmp(Noir)
Add(posSerpentC, 1, posSerpentC)
Mov(posSerpentL, addr(debutSerpent))
Sub(debutSerpent, 1, debutSerpent)
Mov(posSerpentC, addr(debutSerpent))
Sub(debutSerpent, 1, debutSerpent)
Mov(rip, rbx)
Jmp(Noir)
Add(posSerpentC, 1, posSerpentC)
Mov(posSerpentL, addr(debutSerpent))
Sub(debutSerpent, 1, debutSerpent)
Mov(posSerpentC, addr(debutSerpent))
Sub(debutSerpent, 1, debutSerpent)
Mov(rip, rbx)
Jmp(Noir)

Mov(rip, rbx)
Jmp(Noir)

Mod(genAlea, nbLigne, r8)
Mov(r8, fruitL)
Mov(rip, rbx)
Jmp(nbAlea)

Mod(genAlea, nbColonne, r8)
Mov(r8, fruitC)
Mov(rip, rbx)
Jmp(nbAlea)

Mov(rip, rbx)
Jmp(Fruit)


Add(addr(screen_update), 1, addr(screen_update))

# Main loop 
Main = Label()

#regarde le clavier
Sub(addr(keyboard), 71, r8)
Jiz(r8, Gauche, rip)
Sub(addr(keyboard), 72, r8)
Jiz(r8, Droite, rip)
Sub(addr(keyboard), 73, r8)
Jiz(r8, Haut, rip)
Sub(addr(keyboard), 74, r8)
Jiz(r8, Bas, rip)
Jmp(Fin)

Gauche=Label()
Jg(dC, Fin, rip)
Mov(0,dL)
Mov(-1,dC)
Jmp(Fin)
Droite=Label()
Jl(dC, Fin, rip)
Mov(0,dL)
Mov(1,dC)
Jmp(Fin)
Haut=Label()
Jg(dL, Fin, rip)
Mov(-1,dL)
Mov(0,dC)
Jmp(Fin)
Bas=Label()
Jl(dL, Fin, rip)
Mov(1,dL)
Mov(0,dC)
Jmp(Fin)


Fin=Label()
Mov(255, addr(keyboard))


#déplace la tete
Add(posSerpentL, dL,posSerpentL)
Add(posSerpentC, dC,posSerpentC)

Add(posSerpentL, nbLigne,posSerpentL)
Add(posSerpentC, nbColonne,posSerpentC)
Mod(posSerpentC, nbColonne, posSerpentC)
Mod(posSerpentL, nbLigne, posSerpentL)

#detecte ce qu'il y a sur la tête
Mul(posSerpentL, T,r8)
Mul(posSerpentC, T,r9)
Mul(screen_width, r8, r10)
Add(r10, r9, r10)
Add(r10, screen, r10)
Mov(addr(r10), r8)

Sub(r8, black, r9)
Sub(r8, red, r10)
Jiz(r9, perdu, rip)
Jiz(r10, nouvfruit, rip)

#supprime la fin
Mov(rip, rbx)
Jmp(SupprimerFin)
Jmp(finFruit)


nouvfruit=Label()

Mod(genAlea, nbLigne, r8)
Mov(r8, fruitL)
Mov(rip, rbx)
Jmp(nbAlea)

Mod(genAlea, nbColonne, r8)
Mov(r8, fruitC)
Mov(rip, rbx)
Jmp(nbAlea)

Mov(rip, rbx)
Jmp(Fruit)
#Jmp(perdu)

finFruit=Label()

#ajoute une nouvelle case
Mov(posSerpentL, addr(debutSerpent))
Sub(debutSerpent, 1, debutSerpent)
Mov(posSerpentC, addr(debutSerpent))
Sub(debutSerpent, 1, debutSerpent)
Mov(rip, rbx)
Jmp(Noir)

#gere le temps de rafrachissement
sleep=Label()
Add(millisecs,1000,r8)
Sub(r8, dernierTemps,r8)
Mod(r8, 1000, r8)
Sub(r8,ecart,r8)
Jl(r8,sleep,rip)

Mov(millisecs, r8)
Mov(r8, dernierTemps)
#Add(dernierTemps, ecart, dernierTemps)
#Mod(dernierTemps, 1000, dernierTemps)

Add(addr(screen_update), 1, addr(screen_update))
Jmp(Main)

#
perdu=Label()
Mov(genAlea, r9)
Mov(screen, rax)
Add(screen, screen_width * screen_height, rbx)

EraseP=Label()
Mov(r9, addr(rax))
Add(rax, 1, rax)

Sub(rbx, rax, r8)

Jnz(r8, EraseP, rip)
Add(addr(screen_update), 1, addr(screen_update))
Mov(rip, rbx)
Jmp(nbAlea)
Jmp(nouvJeu)


#Noir écrit la case posSerpentL,posSerpentC en noir

Noir=Label()
Mul(posSerpentL, T,r8)
Mul(posSerpentC, T,r9)
Add(posSerpentL, 1,r11)
Mul(r11, T,r11)
Add(posSerpentC, 1,r12)
Mul(r12, T,r12)

boucleNoir=Label()
Mul(screen_width, r8, r10)
Add(r10, r9, r10)
Add(r10, screen, r10)
Mov(black, addr(r10))

Add(r8,1,r8)
Sub(r8,r11,r10)
Jnz(r10, boucleNoir, rip)
Add(r9, 1,r9)
Mul(posSerpentL, T,r8)
Sub(r9,r12,r10)
Jnz(r10, boucleNoir, rip)
Add(rbx,8,rip)

SupprimerFin=Label()
posSerpentL=r13
posSerpentC=r14
Add(finSerpent, 2, finSerpent)
Mov(addr(finSerpent), posSerpentL)
Sub(finSerpent, 1, finSerpent)
Mov(addr(finSerpent), posSerpentC)
Sub(finSerpent, 3,finSerpent)

Mul(posSerpentL, T,r8)
Mul(posSerpentC, T,r9)
Add(posSerpentL, 1,r11)
Mul(r11, T,r11)
Add(posSerpentC, 1,r12)
Mul(r12, T,r12)

boucleSupr=Label()
Mul(screen_width, r8, r10)
Add(r10, r9, r10)
Add(r10, screen, r10)
Mov(white, addr(r10))

Add(r8,1,r8)
Sub(r8,r11,r10)
Jnz(r10, boucleSupr, rip)
Add(r9, 1,r9)
Mul(posSerpentL, T,r8)
Sub(r9,r12,r10)
Jnz(r10, boucleSupr, rip)
Add(rbx,8,rip)


nbAlea=Label()
Mul(genAlea, 578987987,genAlea)
Add(genAlea, 645321231,genAlea)
Add(rbx,8,rip)


Fruit=Label()

Mul(fruitL, T,r8)
Mul(fruitC, T,r9)
Add(fruitL, 1,r11)
Mul(r11, T,r11)
Add(fruitC, 1,r12)
Mul(r12, T,r12)

boucleFruit=Label()
Mul(screen_width, r8, r10)
Add(r10, r9, r10)
Add(r10, screen, r10)
Mov(red, addr(r10))

Add(r8,1,r8)
Sub(r8,r11,r10)
Jnz(r10, boucleFruit, rip)
Add(r9, 1,r9)
Mul(fruitL, T,r8)
Sub(r9,r12,r10)
Jnz(r10, boucleFruit, rip)
Add(rbx,8,rip)

