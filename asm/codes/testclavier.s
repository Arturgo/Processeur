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

# Move stack pointer
Mov(stack, rsp)

# Init everything in white

Mov(screen, rax)
Add(screen, screen_width * screen_height, rbx)

Erase = Label()

Mov(white, addr(rax))
Add(rax, 1, rax)

Sub(rbx, rax, r8)

Jnz(r8, Erase, rip)


Mov(0, rsi)
Mov(0, rdi)

# Main loop 
Main = Label()

Mov(addr(keyboard), r8)

Sub(r8, 255, r14)
Jiz(r14, Main, rip)
Mov(255, addr(keyboard))

Mov(rsi, rax)
Mov(20, rbx)
Mov(32, rcx)

# Call WriteDigit
Mov(RetAddr0, addr(rsp))
Sub(rsp, 1, rsp)
Jmp(WriteDigit)
RetAddr0 = Label()

Mov(rdi, rax)
Mov(20, rbx)
Mov(25, rcx)

# Call WriteDigit
Mov(RetAddr1, addr(rsp))
Sub(rsp, 1, rsp)
Jmp(WriteDigit)
RetAddr1 = Label()

Add(1, rsi, rsi)

Sub(rsi, 10, r10)
Jnz(r10, NormalRSI, rip)
Mov(0, rsi)
Add(1, rdi, rdi)
NormalRSI = Label()

Sub(rdi, 10, r10)
Jnz(r10, NormalRDI, rip)
Mov(0, rdi)
NormalRDI = Label()

# Update screen
Add(addr(screen_update), 1, addr(screen_update))

Jmp(Main)




# Write a digit on screen
# Parameters :
# Digit value in rax
# Row in rbx
# Col in rcx
WriteDigit = Label()

# Compute where to stop
Add(rbx, 8, r10)
Add(rcx, 5, r11)
Mov(rcx, r9)

# Compute addr of digit
Mul(rax, digit_size, rax)
Add(Digits, rax, rax)

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






#Data for digits

Digits = Label()

import Library/chiffre.s
