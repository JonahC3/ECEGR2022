.data
a: .word 0
b: .word 0
c: .word 0
i: .word 5
j: .word 10
.text

main:
lw t0, i 
lw t1, j

addi sp, sp, -8
sw t0, 4(sp)
sw t1 0(sp)

add a0, zero, t0
jal additup
sw t1, a, s0

lw t1, 0(sp)
add a0, zero, t1
jal additup
sw t1, b, s0

addi sp, sp,8

lw t0, a
lw t1, b
add t2, t0, t1
sw t2, c, s0

li a7, 10
ecall

additup:
add t0, zero, zero
add t1, zero, zero

for:
slt t6, t0, a0 
beq t6, zero, exit
addi t2, t0, 1
add t1, t1, t2
addi t0, t0, 1
j for

exit:
ret