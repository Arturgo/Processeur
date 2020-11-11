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
nbLigne=screen_height//T
nbColonne=screen_width//T

# Move stack pointer
Mov(stack, rsp)

# Init everything in white

Mov(screen, rax)
Add(screen, screen_width * screen_height, rdi)

Erase=Label()
Mov(white, addr(rax))
Add(rax, 1, rax)

Sub(rdi, rax, r8)

Jnz(r8, Erase, rip)


#initialise un serpent de taille 3

debutSerpent=rsp
finSerpent=rax
posSerpentL=rbp
posSerpentC=rdx

Jmp(saut)
dL=Variable(0)
dC=Variable(1)
genAlea=Variable(0)
dernierTemps=Variable(0)
fruitL=Variable(0)
fruitC=Variable(0)
score=Variable(0)
saut=Label()

Mov(0,dL)
Mov(1,dC)
Mov(0,score)

Mov(millisecs, r8)
Mov(r8, genAlea) 
Mov(nbLigne//2,posSerpentL)
Mov(nbColonne//2-1,posSerpentC)
Mov(posSerpentL, addr(debutSerpent))
Sub(debutSerpent, 1, debutSerpent)
Mov(posSerpentC, addr(debutSerpent))
Sub(debutSerpent, 1, debutSerpent)
Mov(debutSerpent, finSerpent)
Mov(rip, rdi)
Jmp(Noir)


Add(posSerpentC, 1, posSerpentC)
Mov(posSerpentL, addr(debutSerpent))
Sub(debutSerpent, 1, debutSerpent)
Mov(posSerpentC, addr(debutSerpent))
Sub(debutSerpent, 1, debutSerpent)
Mov(rip, rdi)
Jmp(Noir)

Add(posSerpentC, 1, posSerpentC)
Mov(posSerpentL, addr(debutSerpent))
Sub(debutSerpent, 1, debutSerpent)
Mov(posSerpentC, addr(debutSerpent))
Sub(debutSerpent, 1, debutSerpent)
Mov(rip, rdi)
Jmp(Noir)

Add(posSerpentC, 1, posSerpentC)
Mov(posSerpentL, addr(debutSerpent))
Sub(debutSerpent, 1, debutSerpent)
Mov(posSerpentC, addr(debutSerpent))
Sub(debutSerpent, 1, debutSerpent)
Mov(rip, rdi)
Jmp(Noir)
Add(posSerpentC, 1, posSerpentC)
Mov(posSerpentL, addr(debutSerpent))
Sub(debutSerpent, 1, debutSerpent)
Mov(posSerpentC, addr(debutSerpent))
Sub(debutSerpent, 1, debutSerpent)
Mov(rip, rdi)
Jmp(Noir)
Add(posSerpentC, 1, posSerpentC)
Mov(posSerpentL, addr(debutSerpent))
Sub(debutSerpent, 1, debutSerpent)
Mov(posSerpentC, addr(debutSerpent))
Sub(debutSerpent, 1, debutSerpent)
Mov(rip, rdi)
Jmp(Noir)
Add(posSerpentC, 1, posSerpentC)
Mov(posSerpentL, addr(debutSerpent))
Sub(debutSerpent, 1, debutSerpent)
Mov(posSerpentC, addr(debutSerpent))
Sub(debutSerpent, 1, debutSerpent)
Mov(rip, rdi)
Jmp(Noir)

Mov(rip, rdi)
Jmp(Noir)

Mov(rip, rdi)
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

Sub(r8, red, r10)
Jiz(r10, nouvfruit, rip)

#supprime la fin
Mov(rip, rdi)
Jmp(SupprimerFin)
Jmp(finFruit)


nouvfruit=Label()

Add(score, 1,score)
Mov(rip, rdi)
Jmp(Fruit)
#Jmp(perdu)

finFruit=Label()

#perdu ?
Mul(posSerpentL, T,r8)
Mul(posSerpentC, T,r9)
Mul(screen_width, r8, r10)
Add(r10, r9, r10)
Add(r10, screen, r10)
Mov(addr(r10), r8)

Sub(r8, black, r9)
Jiz(r9, perdu, rip)

#ajoute une nouvelle case
Mov(posSerpentL, addr(debutSerpent))
Sub(debutSerpent, 1, debutSerpent)
Mov(posSerpentC, addr(debutSerpent))
Sub(debutSerpent, 1, debutSerpent)
Mov(rip, rdi)
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
#Mov(genAlea, r9)
Mov(screen, rax)
Add(screen, screen_width * screen_height, rdi)

EraseP=Label()
Mov(white, addr(rax))
Add(rax, 1, rax)

Sub(rdi, rax, r8)

Jnz(r8, EraseP, rip)

Mod(score, 10, r14)
Sub(score, r14,score)
Div(score, 10, score)
Mov(20,rcx)
Mov(34, rbp)
Mov(rip, rdi)
Jmp(WriteDigit)

Mod(score, 10, r14)
Mov(20,rcx)
Mov(28, rbp)
Mov(rip, rdi)
Jmp(WriteDigit)

Add(addr(screen_update), 1, addr(screen_update))
Mov(0, addr(keyboard))
attente=Label()
Jiz(addr(keyboard), attente, rip)

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
Add(rdi,8,rip)

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
Add(rdi,8,rip)


nbAlea=Label()
Mul(genAlea, 578987987,genAlea)
Add(genAlea, 645321231,genAlea)
Add(rsi,8,rip)


Fruit=Label()

Mod(genAlea, nbLigne, r8)
Mov(r8, fruitL)
Mov(rip, rsi)
Jmp(nbAlea)

Mod(genAlea, nbColonne, r8)
Mov(r8, fruitC)
Mov(rip, rsi)
Jmp(nbAlea)

Mul(fruitL, T,r8)
Mul(fruitC, T,r9)
Add(fruitL, 1,r11)
Mul(r11, T,r11)
Add(fruitC, 1,r12)
Mul(r12, T,r12)
Mul(screen_width, r8, r10)
Add(r10, r9, r10)
Add(r10, screen, r10)
Sub(black, addr(r10), r13)

Jiz(r13, Fruit, rip)
Sub(red, addr(r10), r13)
Jiz(r13, Fruit, rip)


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
Add(rdi,8,rip)



# Write a digit on screen
# Parameters :
# Digit value in r14
# Row in rcx
# Col in rbp
WriteDigit = Label()

# Compute where to stop
Add(rcx, 8, r10)
Add(rbp, 5, r11)
Mov(rbp, r9)

# Compute addr of digit
Mul(r14, digit_size, r14)
Add(Digits, r14, r14)

# Loop to print
Boucle = Label()

# Compute addr to print
Mul(rcx, screen_width, r8)
Add(r8, screen, r8)
Add(r8, r9, r8)

Mov(addr(r14), rdx)
Mov(rdx, addr(r8))

#Inc col
Add(r9, 1, r9)
Add(r14, 1, r14)

#Col comparison
Sub(r9, r11, r13)
Jnz(r13, Normal, rip)
Mov(rbp, r9)
Add(rcx, 1, rcx)
Normal = Label()

#Row comparison
Sub(rcx, r10, r12)
Jnz(r12, Boucle, rip)

#ret
Add(rdi,8,rip)



#Data for digits

Digits = Label()

import Library/chiffre.s
