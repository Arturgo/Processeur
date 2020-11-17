white = (2 ** 32) - 1
grey = 0b10111111101111111011111111111111
black = 0
screen = (2 ** 23)
screen_width = 64
screen_height = 48
screen_update = screen + screen_width * screen_height
digit_size = 40

Mov(screen, rax)
Add(screen, screen_width * screen_height, rdi)


Erase=Label()
Mov(white, addr(rax))
Add(rax, 1, rax)

Sub(rdi, rax, r8)

Jnz(r8, Erase, rip)
Mov(0,rax)



debut=Label()

Mov(1000, r8)
Attente=Label()
Add(r8,-1,r8)
Sub(r10, 654657,r10)
Sub(r10, 654657,r10)
Sub(r10, 654657,r10)
Sub(r10, 654657,r10)
Sub(r10, 654657,r10)
Sub(r10, 654657,r10)
Sub(r10, 654657,r10)
Sub(r10, 654657,r10)
Sub(r10, 654657,r10)
Sub(r10, 654657,r10)
Jnz(r8, Attente, rip)

Inc(rax)

Mod(rax,10,rax)

Mov(rax,r14)
Mov(10, rcx)
Mov(10, rbp)

Mov(rip,rdi)
Jmp(WriteDigit)
Add(addr(screen_update), 1, addr(screen_update))

Jmp(debut)


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
