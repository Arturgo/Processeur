white = (2 ** 32) - 1
black = 0
screen = (2 ** 23)
screen_width = 64
stack = screen - 1

digit_size = 25

# Move stack pointer
Mov(stack, rsp)






# Main loop
Main = Label()

# Call WriteDigit
Mov(RetAddr0, addr(rsp))
Sub(rsp, 1, rsp)
Jmp(WriteDigit)
RetAddr0 = Label()

Jmp(Main)






# Write a digit on screen
# Parameters :
# Digit value in rax
# Row in rbx
# Col in rcx
WriteDigit = Label()

# Compute where to stop
Add(rbx, 5, r10)
Add(rcx, 5, r11)

# Compute addr of digit


# Loop to print
Boucle = Label()
Mul(rax, digit_size, rax)
Add(Digits, rax, rax)


#Inc col
Add(r9, 1, r9)
Add(rax, 1, rax)

#Col comparison
Sub(r9, rcx, r13)
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

# .@@@.
# @...@
# @...@
# @...@
# .@@@.

Data(black)
Data(white)
Data(white)
Data(white)
Data(black)

Data(white)
Data(black)
Data(black)
Data(black)
Data(white)

Data(white)
Data(black)
Data(black)
Data(black)
Data(white)

Data(white)
Data(black)
Data(black)
Data(black)
Data(white)

Data(black)
Data(white)
Data(white)
Data(white)
Data(black)