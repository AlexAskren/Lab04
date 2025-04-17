li t1, 0
lui t0, 0x10010
addi t0, t0, 0
loop:
li t2, 10
bge t1, t2, end
slli t3, t1, 2
add t4, t0, t3
lw t5, 0(t4)
slli t5, t5, 1
sw t5, 0(t4)
addi t1, t1, 1
jal zero, loop
end:
li a0, 0
ret

