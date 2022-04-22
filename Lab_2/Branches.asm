.data
A: .word 10
B: .word 15
C: .word 6
Z: .word 0
.text

main: 
lw a0, A
lw a1, B
lw a2, C
lw a3, Z

addi tp, zero, 5 # set register = 5. Used to compare 
slt t0 , a0, a1 #if A < B then, t0 = 1. Else t0 = 0
slt t1, tp, a2 #if C < 5 (tp) then , t1 = 1. Else t1 = 0 
and t2, t0, t1

beq t2, zero, elseif #branch or jump to elsif, if t2 = zero. 
addi a3, zero, 1 # set z = 1
j switch

elseif:
slt t3, a1, a0
addi t5, a2, 1 # t5 has the value c+1
addi t5, t5, -7 # t5 has the value c+1-7
beq t5, zero, setto0 # if c + 1 - 7 = 0, set statement as false (0)  
j else

setto0:
slti  t5, t5, 1 # sets c + 1 -7 = to false
or t6, t5, t3
beq t6 , zero, else
addi a3, zero, 2 # set z = 2
j switch

else:
addi a3, zero, 3 # set z = 3

switch:

addi s2, zero, 1 
addi s3, zero, 2
addi s4, zero, 3

beq a3, s2, case1 
beq a3, s3, case2
beq a3, s4 case3

case1:
addi s5, zero, -1
j end
case2:
addi s5, zero, -2
j end
case3:
addi s5, zero, -3

end:
sw s5, Z, a4 # stores cobntetns of s5 into the memory address of Z.

#end of code