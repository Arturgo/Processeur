white = (2 ** 32) - 1
grey = 0b10111111101111111011111111111111
black = 0
screen = (2 ** 23)
screen_width = 64
screen_height = 48
screen_update = screen + screen_width * screen_height
keyboard = screen_update + 1
stack = screen - 1

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
genAlea=Variable(57)
saut=Label()

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
Mov(0,dL)
Mov(-1,dC)
Jmp(Fin)
Droite=Label()
Mov(0,dL)
Mov(1,dC)
Jmp(Fin)
Haut=Label()
Mov(-1,dL)
Mov(0,dC)
Jmp(Fin)
Bas=Label()
Mov(1,dL)
Mov(0,dC)
Jmp(Fin)

Fin=Label()
Mov(255, addr(keyboard))

#supprime la fin
Mov(rip, rbx)
Jmp(SupprimerFin)

#déplace la tete
Add(posSerpentL, dL,posSerpentL)
Add(posSerpentC, dC,posSerpentC)

Mod(posSerpentC, nbColonne, posSerpentC)
Mod(posSerpentL, nbLigne, posSerpentL)


#ajoute une nouvelle case
Mov(posSerpentL, addr(debutSerpent))
Sub(debutSerpent, 1, debutSerpent)
Mov(posSerpentC, addr(debutSerpent))
Sub(debutSerpent, 1, debutSerpent)
Mov(rip, rbx)
Jmp(Noir)


Add(addr(screen_update), 1, addr(screen_update))
Jmp(Main)



# Write a digit on screen
# Parameters :
# Digit value in rax
# Row in rbx
# Col in rcx
Write = Label()

# Compute where to stop
Add(rbx, 8, r10)
Add(rcx, 5, r11)
Mov(rcx, r9)

# Compute addr of digit
Mul(rax, digit_size, rax)

# Loop to print
Boucle = Label()

# Compute addr to print
Mul(rbx, 64, r8)
Add(r8, screen, r8)
Add(r8, r9, r8)

Mov(addr(rax), rdx)
Mov(rdx, addr(r8))

#Inc col
Add(r9, 1, r9)
Add(rax, 1, rax)

#Col comparison
Sub(r9, r11, r13)
Jnz(r13, Normal, rip)
Mov(rcx, r9)
Add(rbx, 1, rbx)
Normal = Label()

#Row comparison
Sub(rbx, r10, r12)
Jnz(r12, Boucle, rip)

#ret
Add(rsp, 1, rsp)
Jmp(addr(rsp))



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
