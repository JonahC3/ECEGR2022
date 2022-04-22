.data
Z: .word 2
i: .word 0
.text

main: 
lw tp , Z
lw t0 , i

forloop: 
slti t1, t0, 21 # checks if i <= 20. If it is, then t1 is equal to 1. As long t1 is 1, continues to loop
beq t1, zero, doloop # checks if t1 is 0. If 0, then jump to do loop
addi tp, tp, 1 # increments Z by one
addi t0, t0, 2 #increments i by two
j forloop

doloop:
addi t2, zero, 100 # setting a limmit of 100
addi tp, tp, 1 # increments Z by one on each itteration 
beq tp, t2, whileloop # Breaks out of loop if Z = 100
j doloop

whileloop:
addi tp, tp, -1
addi t0, t0, -1
beq t0, zero, end
j whileloop

end:
sw tp, Z, a4 # stores contents of s5 into the memory address of Z.
