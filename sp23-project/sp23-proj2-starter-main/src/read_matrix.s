.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
#   - If malloc returns an error,
#     this function terminates the program with error code 26
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fread error or eof,
#     this function terminates the program with error code 29
# ==============================================================================


# int *read_matrix(char *file_name, int *row, int *column) {
#     FILE *fp = fopen(file_name, "r");
#     fread(row, sizeof(int), 1, fp);
#     fread(column, sizeof(int), 1, fp);

#     int size = (*row) * (*column);
#     int *arr = malloc(size * sizeof(int));
#     fread(arr, sizeof(int), size, fp);

#     fclose(fp);

#     return arr;
# }


read_matrix:

    # Prologue
    addi sp sp -24
    sw s0 0(sp)
    sw s1 4(sp)
    sw s2 8(sp)
    sw s3 12(sp)
    sw s4 16(sp)
    sw s5 20(sp)

    mv s1 a1  # s1 = row
    mv s2 a2  # s2 = column


    # fopen()
    li a1 0
    li s3 -1
    addi sp sp -4
    sw ra 0(sp)
    jal ra fopen
    lw ra 0(sp)
    addi sp sp 4
    beq a0 s3 fail_open

    mv s0 a0  # s0 = fp

    # fread()
    mv a0 s0
    mv a1 s1
    li a2 4
    mv s3 a2  # s3 = 4
    addi sp sp -4
    sw ra 0(sp)
    jal ra fread
    lw ra 0(sp)
    addi sp sp 4
    bne a0 s3 fail_read


    # fread()
    mv a0 s0
    mv a1 s2
    li a2 4
    addi sp sp -4
    sw ra 0(sp)
    jal ra fread
    lw ra 0(sp)
    addi sp sp 4
    bne a0 s3 fail_read

    lw t0 0(s1)
    lw t1 0(s2)
    mul s5 t0 t1  # s5 = size

    # malloc
    slli a0 s5 2
    addi sp sp -4
    sw ra 0(sp)
    jal ra malloc
    lw ra 0(sp)
    addi sp sp 4

    beq a0 x0 fail_malloc
    mv s4 a0  # s4 = arr

    # fread
    mv a0 s0
    mv a1 s4
    slli a2 s5 2
    addi sp sp -4
    sw ra 0(sp)
    jal ra fread
    lw ra 0(sp)
    addi sp sp 4

    slli t0 s5 2
    bne a0 t0 fail_read

    # fclose()
    mv a0 s0
    addi sp sp -4
    sw ra 0(sp)
    jal ra fclose
    lw ra 0(sp)
    addi sp sp 4

    bne a0 x0 fail_close

    mv a0 s4

    # Epilogue
    lw s0 0(sp)
    lw s1 4(sp)
    lw s2 8(sp)
    lw s3 12(sp)
    lw s4 16(sp)
    lw s5 20(sp)
    addi sp sp 24

    jr ra

fail_malloc:
    li a0 26
    j exit

fail_open:
    li a0 27
    j exit

fail_close:
    li a0 28
    j exit

fail_read:
    li a0 29
    j exit