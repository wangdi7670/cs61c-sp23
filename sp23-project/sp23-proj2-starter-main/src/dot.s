.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use
#   a3 (int)  is the stride of arr0
#   a4 (int)  is the stride of arr1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
#   - If the stride of either array is less than 1,
#     this function terminates the program with error code 37
# =======================================================

# int dots(int *arr0, int *arr1, int num, int stride0, int stride1) {
#     int sum = 0;
#     for (int i = 0; i < num; i++) {
#         sum += (arr0[i * stride0] * arr1[i * stride1]);
#     }

#     return sum;
# }

dot:
    addi t0 x0 1
    blt a2 t0 over36
    blt a3 t0 over37
    blt a4 t0 over37
    

    # Prologue
    addi sp sp -8
    sw s0 0(sp)
    sw s1 4(sp)

    addi t0 x0 0  # t0 = sum = 0
    addi t1 x0 0  # t1 = i = 0

loop_start:
    bge t1 a2 loop_end
    # s0 = arr0[i * stride0]
    mul s0 t1 a3
    slli s0 s0 2
    add s0 a0 s0
    lw s0 0(s0)

    # s1 = arr1[i * stride1] 
    mul s1 t1 a4
    slli s1 s1 2
    add s1 a1 s1
    lw s1 0(s1)

    # sum += 
    mul t2 s0 s1 
    add t0 t0 t2

    addi t1 t1 1
    j loop_start

loop_end:
    mv a0 t0

    # Epilogue
    lw s0 0(sp)
    lw s1 4(sp)
    addi sp sp 8

    jr ra

over36:
li a0 36 
j exit

over37:
li a0 37
j exit