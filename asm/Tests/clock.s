white = (2 ** 32) - 1
black = 0
screen = (2 ** 23)
screen_width = 64
stack = screen - 1

digit_size = 28

# Move stack pointer
Mov(stack, rsp)






# Main loop

Mov(0, rax)
Mov(20, rbx)
Mov(30, rcx)

# Call WriteDigit
Mov(RetAddr0, addr(rsp))
Sub(rsp, 1, rsp)
Jmp(WriteDigit)
RetAddr0 = Label()

Main = Label()
Jmp(Main)






# Write a digit on screen
# Parameters :
# Digit value in rax
# Row in rbx
# Col in rcx
WriteDigit = Label()

# Compute where to stop
Add(rbx, 7, r10)
Add(rcx, 4, r11)
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

# .@@.
# @..@
# @..@
# @..@
# @..@
# @..@
# .@@.

Data(black)
Data(white)
Data(white)
Data(black)

Data(white)
Data(black)
Data(black)
Data(white)

Data(white)
Data(black)
Data(black)
Data(white)

Data(white)
Data(black)
Data(black)
Data(white)

Data(white)
Data(black)
Data(black)
Data(white)

Data(white)
Data(black)
Data(black)
Data(white)

Data(black)
Data(white)
Data(white)
Data(black)
