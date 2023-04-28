.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
# Arguments:
#   a0 (int*)  is the pointer to the start of m0
#   a1 (int)   is the # of rows (height) of m0
#   a2 (int)   is the # of columns (width) of m0
#   a3 (int*)  is the pointer to the start of m1
#   a4 (int)   is the # of rows (height) of m1
#   a5 (int)   is the # of columns (width) of m1
#   a6 (int*)  is the pointer to the the start of d
# Returns:
#   None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 38
# =======================================================

# void matmul(int *A, int rowA, int columnA, int *B, int rowB, int columnB, int *C) {
#     for (int i = 0; i < rowA; i++) {
#         for (int j = 0; j < columnB; j++) {
#             C[i * columnB + j] = dots(A + i * columnA, B + j, columnA, 1, columnB);
#         }
#     }
# }

matmul:

    # Error checks
    addi t0 x0 1
    blt a1 t0 over38
    blt a2 t0 over38
    blt a4 t0 over38
    blt a5 t0 over38

    bne a2 a4 over38


    # Prologue
    addi sp sp -28
    sw s0 0(sp)
    sw s1 4(sp)
    sw s2 8(sp)
    sw s3 12(sp)
    sw s4 16(sp)
    sw s5 20(sp)
    sw s6 24(sp)
    
    mv s0 a0  # A
    mv s1 a1  # rowA
    mv s2 a2  # columnA
    mv s3 a3  # B
    mv s4 a4  # rowb
    mv s5 a5  # columnB
    mv s6 a6  # C

    addi t0 x0 0  # t0 = i
outer_loop_start:
    bge t0 s1 outer_loop_end
    addi t1 x0 0  # t1 = j

inner_loop_start:
    bge t1 s5 inner_loop_end

    # a0
    mul a0 t0 s2
    slli a0 a0 2
    add a0 a0 s0

    # a1
    slli a1 t1 2
    add a1 s3 a1

    # a2
    mv a2 s2
    # a3
    li a3 1
    # a4
    mv a4 s5

    # t0 t1
    addi sp sp -8
    sw t0 0(sp)
    sw t1 4(sp)

    # dots()
    addi sp sp -4
    sw ra 0(sp)
    jal ra dot
    lw ra 0(sp)
    addi sp sp 4
    
    # 恢复 t0 t1
    lw t0 0(sp)
    lw t1 4(sp)
    addi sp sp 8

    # 赋值
    mul t2 t0 s5
    add t2 t2 t1
    slli t2 t2 2
    add t2 s6 t2
    sw a0 0(t2)

    addi t1 t1 1
    j inner_loop_start

inner_loop_end:
    addi t0 t0 1
    j outer_loop_start


outer_loop_end:


    # Epilogue
    lw s0 0(sp)
    lw s1 4(sp)
    lw s2 8(sp)
    lw s3 12(sp)
    lw s4 16(sp)
    lw s5 20(sp)
    lw s6 24(sp)

    addi sp sp 28


    jr ra

over38:
    li a0 38
    j exit