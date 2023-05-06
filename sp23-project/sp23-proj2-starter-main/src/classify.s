.globl classify

.text
# =====================================
# COMMAND LINE ARGUMENTS
# =====================================
# Args:
#   a0 (int)        argc
#   a1 (char**)     argv
#   a1[1] (char*)   pointer to the filepath string of m0
#   a1[2] (char*)   pointer to the filepath string of m1
#   a1[3] (char*)   pointer to the filepath string of input matrix
#   a1[4] (char*)   pointer to the filepath string of output file
#   a2 (int)        silent mode, if this is 1, you should not print
#                   anything. Otherwise, you should print the
#                   classification and a newline.
# Returns:
#   a0 (int)        Classification
# Exceptions:
#   - If there are an incorrect number of command line args,
#     this function terminates the program with exit code 31
#   - If malloc fails, this function terminates the program with exit code 26
#
# Usage:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
classify:
    addi t0 x0 5
    bne t0 a0 fail_num
    
    # PROLOGUE
    addi sp sp -48
    sw s0 0(sp)
    sw s1 4(sp)
    sw s2 8(sp)
    sw s3 12(sp)
    sw s4 16(sp)
    sw s5 20(sp)
    sw s6 24(sp)
    sw s7 28(sp)
    sw s8 32(sp)
    sw s9 36(sp)
    sw s10 40(sp)
    sw s11 44(sp)

    mv s1 a1  # s1 = argv
    mv s2 a2  # s2 = silent mode 


    # Read pretrained m0
    li a0 4
    addi sp sp -4
    sw ra 0(sp)
    jal ra malloc
    lw ra 0(sp)
    addi sp sp 4
    beq a0 x0 fail_malloc
    mv s0 a0  # s0 = m0_row

    li a0 4
    addi sp sp -4
    sw ra 0(sp)
    jal ra malloc
    lw ra 0(sp)
    addi sp sp 4
    beq a0 x0 fail_malloc
    mv s3 a0  # s3 = m0_column

    li a0 1
    slli a0 a0 2
    add a0 s1 a0
    lw a0 0(a0)
    mv a1 s0
    mv a2 s3
    addi sp sp -4
    sw ra 0(sp)
    jal ra read_matrix
    lw ra 0(sp)
    addi sp sp 4
    mv s4 a0  # s4 = m0


    # Read pretrained m1
    li a0 4
    addi sp sp -4
    sw ra 0(sp)
    jal ra malloc
    lw ra 0(sp)
    addi sp sp 4
    beq a0 x0 fail_malloc
    mv s5 a0  # s5 = m1_row

    li a0 4
    addi sp sp -4
    sw ra 0(sp)
    jal ra malloc
    lw ra 0(sp)
    addi sp sp 4
    beq a0 x0 fail_malloc
    mv s6 a0  # s6 = m1_column

    li a0 2
    slli a0 a0 2
    add a0 s1 a0
    lw a0 0(a0)
    mv a1 s5
    mv a2 s6
    addi sp sp -4
    sw ra 0(sp)
    jal ra read_matrix
    lw ra 0(sp)
    addi sp sp 4
    mv s7 a0  # s7 = m1


    # Read input matrix
    li a0 4
    addi sp sp -4
    sw ra 0(sp)
    jal ra malloc
    lw ra 0(sp)
    addi sp sp 4
    beq a0 x0 fail_malloc
    mv s8 a0  # s8 = input_row

    li a0 4
    addi sp sp -4
    sw ra 0(sp)
    jal ra malloc
    lw ra 0(sp)
    addi sp sp 4
    beq a0 x0 fail_malloc
    mv s9 a0  # s9 = input_column

    li a0 3
    slli a0 a0 2
    add a0 s1 a0
    lw a0 0(a0)
    mv a1 s8
    mv a2 s9
    addi sp sp -4
    sw ra 0(sp)
    jal ra read_matrix
    lw ra 0(sp)
    addi sp sp 4
    mv s10 a0  # s10 = input


    # Compute h = matmul(m0, input)
    lw t0 0(s0)
    lw t1 0(s9)
    mul a0 t0 t1
    slli a0 a0 2
    addi sp sp -4
    sw ra 0(sp)
    jal ra malloc
    lw ra 0(sp)
    addi sp sp 4
    beq a0 x0 fail_malloc
    mv s11 a0  # s11 = h

    mv a0 s4
    lw a1 0(s0)
    lw a2 0(s3)
    mv a3 s10
    lw a4 0(s8)
    lw a5 0(s9)
    mv a6 s11
    addi sp sp -4
    sw ra 0(sp)
    jal ra matmul
    lw ra 0(sp)
    addi sp sp 4


    # Compute h = relu(h)
    mv a0 s11
    lw t0 0(s0)
    lw t1 0(s9)
    mul a1 t0 t1
    addi sp sp -4
    sw ra 0(sp)
    jal ra relu
    lw ra 0(sp)
    addi sp sp 4


    # Compute o = matmul(m1, h)
    lw t0 0(s5)
    lw t1 0(s9)
    mul a0 t0 t1
    slli a0 a0 2
    addi sp sp -4
    sw ra 0(sp)
    jal ra malloc
    lw ra 0(sp)
    addi sp sp 4
    beq a0 x0 fail_malloc
    mv t2 a0  # t2 = o

    mv a0 s7
    lw a1 0(s5)
    lw a2 0(s6)
    mv a3 s11
    lw a4 0(s0)
    lw a5 0(s9)
    mv a6 t2
    addi sp sp -8
    sw ra 0(sp)
    sw t2 4(sp)
    jal ra matmul
    lw ra 0(sp)
    lw t2 4(sp)
    addi sp sp 8


    # Write output matrix o
    li a0 4
    slli a0 a0 2
    add a0 s1 a0
    lw a0 0(a0)
    mv a1 t2
    lw a2 0(s5)
    lw a3 0(s9)
    addi sp sp -8
    sw ra 0(sp)
    sw t2 4(sp)
    jal ra write_matrix
    lw ra 0(sp)
    lw t2 4(sp)
    addi sp sp 8


    # Compute and return argmax(o)
    mv a0 t2
    lw t0 0(s5)
    lw t1 0(s9)
    mul a1 t0 t1
    addi sp sp -8
    sw ra 0(sp)
    sw t2 4(sp)
    jal ra argmax
    lw ra 0(sp)
    lw t2 4(sp)
    addi sp sp 8

    mv t3 a0  # t3 = arg


    # If enabled, print argmax(o) and newline
    bne s2 x0 label1

    mv a0 t3
    addi sp sp -12
    sw ra 0(sp)
    sw t2 4(sp)
    sw t3 8(sp)
    jal ra print_int
    lw ra 0(sp)
    lw t2 4(sp)
    lw t3 8(sp)
    addi sp sp 12

    li a0 '\n'
    addi sp sp -12
    sw ra 0(sp)
    sw t2 4(sp)
    sw t3 8(sp)
    jal ra print_char
    lw ra 0(sp)
    lw t2 4(sp)
    lw t3 8(sp)
    addi sp sp 12

label1:
    # free heap memory
    mv a0 s0 
    addi sp sp -12
    sw ra 0(sp)
    sw t2 4(sp)
    sw t3 8(sp)
    jal ra free
    lw ra 0(sp)
    lw t2 4(sp)
    lw t3 8(sp)
    addi sp sp 12

    mv a0 s3    
    addi sp sp -12
    sw ra 0(sp)
    sw t2 4(sp)
    sw t3 8(sp)
    jal ra free
    lw ra 0(sp)
    lw t2 4(sp)
    lw t3 8(sp)
    addi sp sp 12

    mv a0 s4 
    addi sp sp -12
    sw ra 0(sp)
    sw t2 4(sp)
    sw t3 8(sp)
    jal ra free
    lw ra 0(sp)
    lw t2 4(sp)
    lw t3 8(sp)
    addi sp sp 12

    mv a0 s5
    addi sp sp -12
    sw ra 0(sp)
    sw t2 4(sp)
    sw t3 8(sp)
    jal ra free
    lw ra 0(sp)
    lw t2 4(sp)
    lw t3 8(sp)
    addi sp sp 12

    mv a0 s6 
    addi sp sp -12
    sw ra 0(sp)
    sw t2 4(sp)
    sw t3 8(sp)
    jal ra free
    lw ra 0(sp)
    lw t2 4(sp)
    lw t3 8(sp)
    addi sp sp 12


    mv a0 s7
    addi sp sp -12
    sw ra 0(sp)
    sw t2 4(sp)
    sw t3 8(sp)
    jal ra free
    lw ra 0(sp)
    lw t2 4(sp)
    lw t3 8(sp)
    addi sp sp 12

    mv a0 s8
    addi sp sp -12
    sw ra 0(sp)
    sw t2 4(sp)
    sw t3 8(sp)
    jal ra free
    lw ra 0(sp)
    lw t2 4(sp)
    lw t3 8(sp)
    addi sp sp 12

    mv a0 s9
    addi sp sp -12
    sw ra 0(sp)
    sw t2 4(sp)
    sw t3 8(sp)
    jal ra free
    lw ra 0(sp)
    lw t2 4(sp)
    lw t3 8(sp)
    addi sp sp 12

    mv a0 s10
    addi sp sp -12
    sw ra 0(sp)
    sw t2 4(sp)
    sw t3 8(sp)
    jal ra free
    lw ra 0(sp)
    lw t2 4(sp)
    lw t3 8(sp)
    addi sp sp 12

    mv a0 s11
    addi sp sp -12
    sw ra 0(sp)
    sw t2 4(sp)
    sw t3 8(sp)
    jal ra free
    lw ra 0(sp)
    lw t2 4(sp)
    lw t3 8(sp)
    addi sp sp 12

    mv a0 t2
    addi sp sp -12
    sw ra 0(sp)
    sw t2 4(sp)
    sw t3 8(sp)
    jal ra free
    lw ra 0(sp)
    lw t2 4(sp)
    lw t3 8(sp)
    addi sp sp 12

    mv a0 t3

    # Epilogue
    lw s0 0(sp)
    lw s1 4(sp)
    lw s2 8(sp)
    lw s3 12(sp)
    lw s4 16(sp)
    lw s5 20(sp)
    lw s6 24(sp)
    lw s7 28(sp)
    lw s8 32(sp)
    lw s9 36(sp)
    lw s10 40(sp)
    lw s11 44(sp)
    addi sp sp 48

    jr ra

fail_malloc:
    li a0 26
    j exit

fail_num:
    li a0 31
    j exit