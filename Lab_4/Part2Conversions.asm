.data
#strings
prompt: .asciz "Please enter a number: "
ansC: .asciz "Number in Celsius is  " 
ansK: .asciz "Number in Kelvin is "
newl: .asciz "\r\n"

#floating point variables
F: .float 0
C: .float 0
K: .float 0

#additional values
addforKelvin: .float 273.15
.text

#-------------------- Main Function----------------------------------------------

main:
# set up floating variables
flw fa0, F, t0
flw fa1, C, t0
flw fa2, K, t0

# set up additional number for Kelvin operation
flw ft3, addforKelvin, t0

li a7, 4  #system call to prompt the user
la a0, prompt
ecall

li a7, 6 # system call for user input
ecall

jal conversionsC
jal ConversionsK

#--------------------Conversion Function--------------------------------------------------------------------------

conversionsC:
#set up additional numbers (Celsius)
li t0, 5
li t1, 9
li t2, 32

#Calculation for Celsius
fcvt.s.w ft0, t0 # has value 5.0
fcvt.s.w ft1, t1 # has value 9.0
fcvt.s.w ft2, t2 # has value 32.0

fsub.s fs2, fa0, ft2 # F - 32.0
fdiv.s fs3, ft0, ft1 # 5.0/9.0
fmul.s fa1, fs2, fs3 # answer in Celsius

#Displaying answer
li a7, 4
la a0, ansC
ecall 

li a7, 2
fmv.s fa0, fa1
ecall
ret

ConversionsK:
# Calculation for Kelvin 
flw ft3, addforKelvin, t0
fadd.s fa0, fa0, ft3

#Displaying answer
li a7, 4
la a0, newl
ecall

li a7, 4
la a0, ansK
ecall

li a7, 2 
ecall































