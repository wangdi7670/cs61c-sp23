.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================

# int argmax(int *arr, int length) {
#     int max = arr[0];
#     int arg = 0;
#     for (int i = 1; i < length; i++) {
##         if (arr[i] > max) {
#             max = arr[i];
#             arg = i;
#         }
#     }

#     return arg;
# }

argmax:
    li t0 1
    blt a1 t0 over
    # Prologue
    addi sp sp -12
    sw s0 0(sp)
    sw s1 4(sp)
    sw s2 8(sp)


loop_start:
    lw s0 0(a0)  # s0 = max = arr[0]
    addi t0 x0 0  # t0 = arg = 0
    addi t1 x0 1  # t1 = i = 1
    mv s1 a0  # s1 = arr
    mv s2 a1  # s2 = length

loop_continue:
    bge t1 s2 loop_end
    slli t2 t1 2  # i * 4
    add t2 s0 t2
    lw t2 0(t2)  # t2 = arr[i]
    bge s0 t2 if_end
if_label:
    mv s0 t2
    mv t0 t1
if_end:
    addi t1 t1 1
    j loop_continue

loop_end:
    # Epilogue
    lw s0 0(sp)
    lw s1 4(sp)
    lw s2 8(sp)
    addi sp sp 12

    mv a0 t0

    jr ra

over:
    li a0 36
    j exit