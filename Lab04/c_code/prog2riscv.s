lui t0, 0x10010
addi t0, t0, 0
lw t1, 0(t0)
andi t2, t1, 1
bne t2, zero, skip0
slli t1, t1, 1
sw t1, 0(t0)
skip0:
lw t1, 4(t0)
andi t2, t1, 1
bne t2, zero, skip1
slli t1, t1, 1
sw t1, 4(t0)
skip1:
lw t1, 8(t0)
andi t2, t1, 1
bne t2, zero, skip2
slli t1, t1, 1
sw t1, 8(t0)
skip2:
lw t1, 12(t0)
andi t2, t1, 1
bne t2, zero, skip3
slli t1, t1, 1
sw t1, 12(t0)
skip3:
lw t1, 16(t0)
andi t2, t1, 1
bne t2, zero, skip4
slli t1, t1, 1
sw t1, 16(t0)
skip4:
lw t1, 20(t0)
andi t2, t1, 1
bne t2, zero, skip5
slli t1, t1, 1
sw t1, 20(t0)
skip5:
lw t1, 24(t0)
andi t2, t1, 1
bne t2, zero, skip6
slli t1, t1, 1
sw t1, 24(t0)
skip6:
lw t1, 28(t0)
andi t2, t1, 1
bne t2, zero, skip7
slli t1, t1, 1
sw t1, 28(t0)
skip7:
lw t1, 32(t0)
andi t2, t1, 1
bne t2, zero, skip8
slli t1, t1, 1
sw t1, 32(t0)
skip8:
lw t1, 36(t0)
andi t2, t1, 1
bne t2, zero, skip9
slli t1, t1, 1
sw t1, 36(t0)
skip9:
