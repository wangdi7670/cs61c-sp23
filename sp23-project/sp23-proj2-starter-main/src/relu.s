.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
#   a0 (int*) is the pointer to the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   None
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# ==============================================================================

# void relu(int *arr, int length) {
#     for (int i = 0; i < length; i++) {
            ## if (arr[i] < 0) {
            #     arr[i] = 0
            # }
#     }
# }

relu:
    li t0 1
    blt a1 t0 over

    # Prologue
    addi sp sp -12
    sw s0 0(sp)
    sw s1 4(sp)
    sw s2 8(sp)

loop_start:
    addi s0 x0 0  # s0 = i
    mv s1 a1  # s1 = length
    mv s2 a0  # s2 = arr



loop_continue:
    beq s1 s0 loop_end
    slli t0 s0 2  # t0 = i * 4
    add t1 s2 t0  # t1 = arr + 4*i

    lw t2 0(t1)  # t2 = arr[i]
    blt t2 x0 if_label
    j end_if  # jump to end_if
    
if_label:
    sw x0 0(t1)
end_if:
    addi s0 s0 1  # i++
    jal x0 loop_continue

loop_end:


    # Epilogue
    lw s0 0(sp)
    lw s1 4(sp)
    lw s2 8(sp)
    addi sp sp 12

    jr ra
over:
    li a0 36
    j exit