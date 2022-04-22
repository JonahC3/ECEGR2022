.data
A: .word 0,0,0,0,0
B: .word 1,2,4,8,16
i: .word 0
.text

main:
la t0, A
la t1, B
lw a1, i
addi ra, zero 4 # ra holds the value 4. ra is created since each integer in the array takes up 4 bytes of memeory

for: 
slti a0, a1, 5
beq a0, zero, subone
mul s0, a1, ra # Trying to get address of A[i]
mul s1, a1, ra # Trying to get addtress of B[i]
add s0, t0 , s0 # Generalized address of A[i] for each itteration 
add s1, t1 , s1 # Generalized address of B[i] for each itteration
lw t3, 0(s1)
addi t3, t3, -1
sw t3, 0(s0)
addi a1, a1, 1
j for

subone:
addi a1, a1, -1

while:
blt a1, zero, end
mul s0, a1, ra # Trying to get address of A[i]
mul s1, a1, ra # Trying to get addtress of B[i]
add s0, t0 , s0 # Generalized address of A[i] for each itteration 
add s1, t1 , s1 # Generalized address of B[i] for each 
lw t4, 0(s1) 
lw t5, 0(s0)
add t6, t4, t5
addi s11, zero, 2
mul t6, t6, s11
sw t6, 0(s0)
addi a1, a1, -1
j while

end:





