.text
.globl _start
_start:
    # Basic immediate loads / ALU
    addi x1, x0, 5          # x1 = 5
    addi x2, x0, 10         # x2 = 10
    add  x3, x1, x2         # x3 = 15   (back-to-back EX/MEM->EX forward on x1,x2? no hazard here)
    add  x4, x3, x3         # x4 = 30   forwarding: x3 produced 1 instr earlier (EX/MEM->EX)
    sub  x5, x4, x1         # x5 = 25   forwarding: x4 produced 1 instr earlier
    addi x6, x5, 100        # x6 = 125  forwarding: x5 produced 1 instr earlier

    # MEM/WB -> EX forwarding (distance 2)
    addi x7, x0, 7          # x7 = 7
    addi x8, x0, 1          # bubble instr
    add  x9, x7, x0         # x9 = 7    forwarding from x7 (distance 2, MEM/WB->EX)

    # store / load-use hazard
    addi x10, x0, 0x100     # x10 = base address 256
    sw   x6, 0(x10)         # mem[256] = 125
    lw   x11, 0(x10)        # x11 = 125
    addi x12, x11, 1        # x12 = 126  (load-use hazard: 1 stall cycle needed)

    # byte/half store-load round trip
    addi x13, x0, -1        # x13 = 0xFFFFFFFF
    sb   x13, 4(x10)        # mem byte at 260 = 0xFF
    lbu  x14, 4(x10)        # x14 = 0x000000FF (zero extended)
    lb   x15, 4(x10)        # x15 = 0xFFFFFFFF (sign extended)

    sh   x13, 8(x10)        # mem halfword at 264 = 0xFFFF
    lhu  x16, 8(x10)        # x16 = 0x0000FFFF
    lh   x17, 8(x10)        # x17 = 0xFFFFFFFF

    # branch not taken then taken
    addi x18, x0, 0
    beq  x1, x2, skip1      # not taken (5 != 10)
    addi x18, x18, 1        # x18 = 1
skip1:
    beq  x1, x1, taken1     # taken
    addi x18, x18, 100      # skipped
taken1:
    addi x18, x18, 10       # x18 = 11

    # loop: sum 1..5 into x20
    addi x19, x0, 5         # counter
    addi x20, x0, 0         # sum
loop:
    add  x20, x20, x19
    addi x19, x19, -1
    bne  x19, x0, loop      # x20 = 5+4+3+2+1 = 15

    # JAL / JALR
    jal  x21, subr          # x21 = return addr, jump to subr
    addi x25, x0, 999       # should NOT execute if jal took effect and subr doesn't return here... actually subr returns here via jalr
    j    finish

subr:
    addi x22, x0, 42        # x22 = 42
    jalr x0, 0(x21)         # return to instruction after jal (the addi x25 line)

finish:
    # LUI / AUIPC
    lui   x23, 0x12345      # x23 = 0x12345000
    auipc x24, 0            # x24 = PC of this instruction

    # signed/unsigned compare
    addi x26, x0, -1
    addi x27, x0, 1
    slt  x28, x26, x27      # x28 = 1 (signed: -1 < 1)
    sltu x29, x26, x27      # x29 = 0 (unsigned: huge < 1 is false)

    # halt: infinite loop so we can stop simulation by cycle count
halt:
    beq  x0, x0, halt
