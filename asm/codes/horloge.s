white = (2 ** 32) - 1
grey = 0b10111111101111111011111111111111
black = 0
screen = (2 ** 23)
screen_width = 64
screen_height = 48
screen_update = screen + screen_width * screen_height
stack = screen - 1
minutes_illegal = screen_update + 2
millisecs_illegal = screen_update + 3
switch = screen_update + 4

minutes = screen - 42
millisecs = screen - 43
fst = screen - 44
lastSwitch = screen - 45

digit_size = 40
letter_size = 36

Mov(1, addr(fst))

Mov(addr(minutes_illegal), rax)
Sub(rax, 1, addr(minutes))

Mov(addr(millisecs_illegal), rax)
Mov(rax, addr(millisecs))

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

Add(addr(millisecs), 1000, rdi)
Mod(rdi, 60000, addr(millisecs))

Div(addr(millisecs), 1000, rdi)

Mod(rdi, 10, rax)
Mov(27, rbx)
Mov(32 + 10 + 7, rcx)

# Call WriteDigit
Mov(RetAddr0, addr(rsp))
Sub(rsp, 1, rsp)
Jmp(WriteDigit)
RetAddr0 = Label()

Mod(rdi, 10, rax)
Jnz(addr(fst), SuiteDiz, rip)
Jnz(rax, CheckMins, rip)
SuiteDiz = Label()

Div(rdi, 10, rax)
Mov(27, rbx)
Mov(32 + 10, rcx)

# Call WriteDigit
Mov(RetAddr1, addr(rsp))
Sub(rsp, 1, rsp)
Jmp(WriteDigit)
RetAddr1 = Label()

CheckMins = Label()

Jnz(addr(fst), SuiteMins, rip)
Jnz(rdi, Update, rip)
SuiteMins = Label()
Mov(0, addr(millisecs))

Add(addr(minutes), 1, rdi)
Mov(rdi, addr(minutes))

Mod(addr(minutes), 60, rdi)

Mod(rdi, 10, rax)
Mov(27, rbx)
Mov(32 + 1, rcx)

# Call WriteDigit
Mov(RetAddr2, addr(rsp))
Sub(rsp, 1, rsp)
Jmp(WriteDigit)
RetAddr2 = Label()

Div(rdi, 10, rax)
Mov(27, rbx)
Mov(32 - 6, rcx)

# Call WriteDigit
Mov(RetAddr3, addr(rsp))
Sub(rsp, 1, rsp)
Jmp(WriteDigit)
RetAddr3 = Label()

Jnz(addr(fst), SuiteFin, rip)
Jnz(rdi, Update, rip)
SuiteFin = Label()

Div(addr(minutes), 60, rdi)
Mod(rdi, 24, rdi)

Mod(rdi, 10, rax)
Mov(27, rbx)
Mov(32 - 15, rcx)

# Call WriteDigit
Mov(RetAddr4, addr(rsp))
Sub(rsp, 1, rsp)
Jmp(WriteDigit)
RetAddr4 = Label()

Div(rdi, 10, rax)
Mov(27, rbx)
Mov(32 - 22, rcx)

# Call WriteDigit
Mov(RetAddr5, addr(rsp))
Sub(rsp, 1, rsp)
Jmp(WriteDigit)
RetAddr5 = Label()


# Calculs des jours
Div(addr(minutes), 1440, rdi)
Add(rdi, 135142, rdi)
Mod(rdi, 146099, rdi)
Mul(rdi, 3, rsi)
Add(Jours, rsi, rsi)


# Affichage de l'année
Div(rdi, 400, rdi)
Mul(rdi, 400, rdi)
Mov(0, rdi)
Add(rsi, 2, rax)
Add(rdi, addr(rax), rdi)

Mod(rdi, 10, rax)
Mov(10, rbx)
Mov(36 + 10 + 7, rcx)

# Call WriteDigit
Mov(RetAddr11, addr(rsp))
Sub(rsp, 1, rsp)
Jmp(WriteDigit)
RetAddr11 = Label()

Mod(rdi, 100, rax)
Div(rax, 10, rax)
Mov(10, rbx)
Mov(36 + 10, rcx)

# Call WriteDigit
Mov(RetAddr12, addr(rsp))
Sub(rsp, 1, rsp)
Jmp(WriteDigit)
RetAddr12 = Label()



# Affichage du mois
Add(rsi, 1, rdi)
Mov(addr(rdi), rdi)
Mul(rdi, 3, rdi)

Add(Mois, rdi, rdi)

Mov(addr(rdi), rax)
Mov(12, rbx)
Mov(22, rcx)

# Call WriteLetter
Mov(RetAddr6, addr(rsp))
Sub(rsp, 1, rsp)
Jmp(WriteLetter)
RetAddr6 = Label()

Add(rdi, 1, rdi)

Mov(addr(rdi), rax)
Mov(12, rbx)
Mov(22 + 7, rcx)

# Call WriteLetter
Mov(RetAddr7, addr(rsp))
Sub(rsp, 1, rsp)
Jmp(WriteLetter)
RetAddr7 = Label()

Add(rdi, 1, rdi)

Mov(addr(rdi), rax)
Mov(12, rbx)
Mov(22 + 14, rcx)

# Call WriteLetter
Mov(RetAddr8, addr(rsp))
Sub(rsp, 1, rsp)
Jmp(WriteLetter)
RetAddr8 = Label()


# Affichage du jour
Mov(addr(rsi), rdi)
Add(rdi, 1, rdi)

Mod(rdi, 10, rax)
Mov(10, rbx)
Mov(13, rcx)

# Call WriteDigit
Mov(RetAddr9, addr(rsp))
Sub(rsp, 1, rsp)
Jmp(WriteDigit)
RetAddr9 = Label()

Div(rdi, 10, rax)
Mov(10, rbx)
Mov(6, rcx)

# Call WriteDigit
Mov(RetAddr10, addr(rsp))
Sub(rsp, 1, rsp)
Jmp(WriteDigit)
RetAddr10 = Label()

Update = Label()

# Update screen
Add(addr(screen_update), 1, addr(screen_update))
Mov(0, addr(fst))

Attente = Label()
Mov(addr(switch), rax)
Sub(rax, addr(lastSwitch), rbx)
Jiz(rbx, Attente, rip)

Mov(rax, addr(lastSwitch))

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
Boucle_digit = Label()

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
Jnz(r13, Normal_digit, rip)
Mov(rcx, r9)
Add(rbx, 1, rbx)
Normal_digit = Label()

#Row comparison
Sub(rbx, r10, r12)
Jnz(r12, Boucle_digit, rip)

#ret
Add(rsp, 1, rsp)
Jmp(addr(rsp))




# Write a letter on screen
# Parameters :
# Digit value in rax
# Row in rbx
# Col in rcx

WriteLetter = Label()

# Compute where to stop
Add(rbx, 6, r10)
Add(rcx, 6, r11)
Mov(rcx, r9)

# Compute addr of digit
Mul(rax, letter_size, rax)
Add(Lettres, rax, rax)

# Loop to print
Boucle_letter = Label()

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
Jnz(r13, Normal_letter, rip)
Mov(rcx, r9)
Add(rbx, 1, rbx)
Normal_letter = Label()

#Row comparison
Sub(rbx, r10, r12)
Jnz(r12, Boucle_letter, rip)

#ret
Add(rsp, 1, rsp)
Jmp(addr(rsp))




#Data for digits

Digits = Label()

import Library/chiffre.s

Lettres = Label()

import Library/lettre.s

Mois = Label()

import Library/mois.s

Jours = Label()

Import("Library/jours.data")
