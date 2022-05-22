.data

.text

#---------NON-IMMEDIATES----------

# INPUT VALUES
li t0, 0x01234567
li t1, 0x11223344

# ADD
add a0, t0, t1

# SUB
sub a1, t0, t1

# AND
and a2, t0, t1

# OR
or a3, t0, t1

# SRL by one
li t1, 1
srl a4, t0, t1

# SRL by two
li t1, 2
srl a5, t0, t1

# SRL by three
li t1, 3
srl a6, t0, t1

# SLL by one
li t1, 1
sll a7, t0, t1

# SLL by two
li t1, 2
sll s2, t0, t1

# SLL by three
li t1, 3
sll s3, t0, t1
#----------IMMEDIATES--------------

# ADDI
addi s4, t0, 0x00000123

# ANDI
andi s5, t0, 0x00000123

# ORI
ori  s6, t0, 0x00000123

# SRLI
srli s7, t0, 3

# SLLI
slli s8, t0, 3

#---------NEW INPUT VALUES--------- (testing zero outputs)
li t0, 0x44332211
li t1, 0x44332211
sub s9, t0, t1



  
