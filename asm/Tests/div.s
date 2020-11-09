white = (2 ** 32) - 1
grey = 0b10111111101111111011111111111111
black = 0
screen = (2 ** 23)
screen_width = 64
screen_height = 48
screen_update = screen + screen_width * screen_height
stack = screen - 1
minutes = screen_update + 2
millisecs = screen_update + 3

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


# Main loop 
Main = Label()



Div(addr(millisecs), 1000, rdi)

Mod(rdi, 10, rax)
Mov(20, rbx)
Mov(32 + 10 + 7, rcx)

# Call WriteDigit
Mov(RetAddr0, addr(rsp))
Sub(rsp, 1, rsp)
Jmp(WriteDigit)
RetAddr0 = Label()

Div(rdi, 10, rax)
Mov(20, rbx)
Mov(32 + 10, rcx)

# Call WriteDigit
Mov(RetAddr1, addr(rsp))
Sub(rsp, 1, rsp)
Jmp(WriteDigit)
RetAddr1 = Label()



Mod(addr(minutes), 60, rdi)

Mod(rdi, 10, rax)
Mov(20, rbx)
Mov(32 + 1, rcx)

# Call WriteDigit
Mov(RetAddr2, addr(rsp))
Sub(rsp, 1, rsp)
Jmp(WriteDigit)
RetAddr2 = Label()

Div(rdi, 10, rax)
Mov(20, rbx)
Mov(32 - 6, rcx)

# Call WriteDigit
Mov(RetAddr3, addr(rsp))
Sub(rsp, 1, rsp)
Jmp(WriteDigit)
RetAddr3 = Label()




Div(addr(minutes), 60, rdi)
Mod(rdi, 24, rdi)

Mod(rdi, 10, rax)
Mov(20, rbx)
Mov(32 - 15, rcx)

# Call WriteDigit
Mov(RetAddr4, addr(rsp))
Sub(rsp, 1, rsp)
Jmp(WriteDigit)
RetAddr4 = Label()

Div(rdi, 10, rax)
Mov(20, rbx)
Mov(32 - 22, rcx)

# Call WriteDigit
Mov(RetAddr5, addr(rsp))
Sub(rsp, 1, rsp)
Jmp(WriteDigit)
RetAddr5 = Label()


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

# 00. 
#0  0.
#0  0.
#0  0.
#0  0.
#0  0.
#.00. 
# ..  

Data(white)
Data(black)
Data(black)
Data(grey)
Data(white)

Data(black)
Data(white)
Data(white)
Data(black)
Data(grey)

Data(black)
Data(white)
Data(white)
Data(black)
Data(grey)

Data(black)
Data(white)
Data(white)
Data(black)
Data(grey)

Data(black)
Data(white)
Data(white)
Data(black)
Data(grey)

Data(black)
Data(white)
Data(white)
Data(black)
Data(grey)

Data(grey)
Data(black)
Data(black)
Data(grey)
Data(white)

Data(white)
Data(grey)
Data(grey)
Data(white)
Data(white)


#  0. 
# 00. 
#0 0. 
#  0. 
#  0. 
#  0. 
# 000.
# ... 

Data(white)
Data(white)
Data(black)
Data(grey)
Data(white)

Data(white)
Data(black)
Data(black)
Data(grey)
Data(white)

Data(black)
Data(white)
Data(black)
Data(grey)
Data(white)

Data(white)
Data(white)
Data(black)
Data(grey)
Data(white)

Data(white)
Data(white)
Data(black)
Data(grey)
Data(white)

Data(white)
Data(white)
Data(black)
Data(grey)
Data(white)

Data(white)
Data(black)
Data(black)
Data(black)
Data(grey)

Data(white)
Data(grey)
Data(grey)
Data(grey)
Data(white)


# 00. 
#0  0.
#   0.
#  0. 
# 0.  
#0.   
#0000.
#.... 

Data(white)
Data(black)
Data(black)
Data(grey)
Data(white)

Data(black)
Data(white)
Data(white)
Data(black)
Data(grey)

Data(white)
Data(white)
Data(white)
Data(black)
Data(grey)

Data(white)
Data(white)
Data(black)
Data(grey)
Data(white)

Data(white)
Data(black)
Data(grey)
Data(white)
Data(white)

Data(black)
Data(grey)
Data(white)
Data(white)
Data(white)

Data(black)
Data(black)
Data(black)
Data(black)
Data(grey)

Data(grey)
Data(grey)
Data(grey)
Data(grey)
Data(white)


# 00. 
#0  0.
#   0.
# 00. 
#   0.
#0  0.
#.00. 
# ..  

Data(white)
Data(black)
Data(black)
Data(grey)
Data(white)

Data(black)
Data(white)
Data(white)
Data(black)
Data(grey)

Data(white)
Data(white)
Data(white)
Data(black)
Data(grey)

Data(white)
Data(black)
Data(black)
Data(grey)
Data(white)

Data(white)
Data(white)
Data(white)
Data(black)
Data(grey)

Data(black)
Data(white)
Data(white)
Data(black)
Data(grey)

Data(grey)
Data(black)
Data(black)
Data(grey)
Data(white)

Data(white)
Data(grey)
Data(grey)
Data(white)
Data(white)


#0  0.
#0  0.
#0  0.
#.000.
# ..0.
#   0.
#   0.
#   . 

Data(black)
Data(white)
Data(white)
Data(black)
Data(grey)

Data(black)
Data(white)
Data(white)
Data(black)
Data(grey)

Data(black)
Data(white)
Data(white)
Data(black)
Data(grey)

Data(grey)
Data(black)
Data(black)
Data(black)
Data(grey)

Data(white)
Data(grey)
Data(grey)
Data(black)
Data(grey)

Data(white)
Data(white)
Data(white)
Data(black)
Data(grey)

Data(white)
Data(white)
Data(white)
Data(black)
Data(grey)

Data(white)
Data(white)
Data(white)
Data(grey)
Data(white)


#0000.
#0... 
#000. 
#   0.
#   0.
#0  0.
#.00. 
# ..  

Data(black)
Data(black)
Data(black)
Data(black)
Data(grey)

Data(black)
Data(grey)
Data(grey)
Data(grey)
Data(white)

Data(black)
Data(black)
Data(black)
Data(grey)
Data(white)

Data(white)
Data(white)
Data(white)
Data(black)
Data(grey)

Data(white)
Data(white)
Data(white)
Data(black)
Data(grey)

Data(black)
Data(white)
Data(white)
Data(black)
Data(grey)

Data(grey)
Data(black)
Data(black)
Data(grey)
Data(white)

Data(white)
Data(grey)
Data(grey)
Data(white)
Data(white)


# 00. 
#0  0.
#0  . 
#000. 
#0  0.
#0  0.
#.00. 
# ..  

Data(white)
Data(black)
Data(black)
Data(grey)
Data(white)

Data(black)
Data(white)
Data(white)
Data(black)
Data(grey)

Data(black)
Data(white)
Data(white)
Data(grey)
Data(white)

Data(black)
Data(black)
Data(black)
Data(grey)
Data(white)

Data(black)
Data(white)
Data(white)
Data(black)
Data(grey)

Data(black)
Data(white)
Data(white)
Data(black)
Data(grey)

Data(grey)
Data(black)
Data(black)
Data(grey)
Data(white)

Data(white)
Data(grey)
Data(grey)
Data(white)
Data(white)


#0000.
#   0.
#   0.
#  0. 
#  0. 
# 0.  
# 0.  
# .   

Data(black)
Data(black)
Data(black)
Data(black)
Data(grey)

Data(white)
Data(white)
Data(white)
Data(black)
Data(grey)

Data(white)
Data(white)
Data(white)
Data(black)
Data(grey)

Data(white)
Data(white)
Data(black)
Data(grey)
Data(white)

Data(white)
Data(white)
Data(black)
Data(grey)
Data(white)

Data(white)
Data(black)
Data(grey)
Data(white)
Data(white)

Data(white)
Data(black)
Data(grey)
Data(white)
Data(white)

Data(white)
Data(grey)
Data(white)
Data(white)
Data(white)


# 00. 
#0  0.
#0  0.
# 00. 
#0  0.
#0  0.
#.00. 
# ..  

Data(white)
Data(black)
Data(black)
Data(grey)
Data(white)

Data(black)
Data(white)
Data(white)
Data(black)
Data(grey)

Data(black)
Data(white)
Data(white)
Data(black)
Data(grey)

Data(white)
Data(black)
Data(black)
Data(grey)
Data(white)

Data(black)
Data(white)
Data(white)
Data(black)
Data(grey)

Data(black)
Data(white)
Data(white)
Data(black)
Data(grey)

Data(grey)
Data(black)
Data(black)
Data(grey)
Data(white)

Data(white)
Data(grey)
Data(grey)
Data(white)
Data(white)


# 00. 
#0  0.
#0  0.
# 000.
#   0.
#0  0.
#.00. 
# ..  

Data(white)
Data(black)
Data(black)
Data(grey)
Data(white)

Data(black)
Data(white)
Data(white)
Data(black)
Data(grey)

Data(black)
Data(white)
Data(white)
Data(black)
Data(grey)

Data(white)
Data(black)
Data(black)
Data(black)
Data(grey)

Data(white)
Data(white)
Data(white)
Data(black)
Data(grey)

Data(black)
Data(white)
Data(white)
Data(black)
Data(grey)

Data(grey)
Data(black)
Data(black)
Data(grey)
Data(white)

Data(white)
Data(grey)
Data(grey)
Data(white)
Data(white)


