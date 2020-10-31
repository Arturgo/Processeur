white = (2 ** 32) - 1
black = 0
screen = (2 ** 23)

#LIG = rax
#COL = rbx

Mov(white, addr(screen + 2 * 64 + 1))

Mov(3, rax)
LoopLig = Label()

Mov(1, rbx)
LoopCol = Label()

Mul(rax, 64, rdx)
Add(rbx, rdx, rdx)
Add(screen, rdx, rdx)

Sub(rdx, 64, r10)
Sub(rdx, 65, r11)

Mov(addr(r10), r8)
Mov(addr(r11), r9)

Xor(r8, r9, addr(rdx))

Inc(rbx)
Sub(rbx, rax, rcx)
Jnz(rcx, LoopCol, rip)

Inc(rax)
Jmp(LoopLig)
