.data 

A: .word 15
B: .word 10
C: .word 5
D: .word 2
E: .word 18
F: .word -3
Z: .word 0

.text

main:

lw a0, A
lw a1, B
lw a2, C
lw a3, D
lw a4, E
lw a5, F
lw a6, Z

sub t3, a0, a1
mul t4, a2, a3
sub t5, a4, a5
div t6, a0, a2 

add t1, t3, t4
sub t2, t5, t6
add a6, t1, t2 

sw a6, Z, t0

li a7,10
ecall