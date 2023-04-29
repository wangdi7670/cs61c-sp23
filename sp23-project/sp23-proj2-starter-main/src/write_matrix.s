.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fwrite error or eof,
#     this function terminates the program with error code 30
# ==============================================================================


# void write_matrix(char *name, int *arr, int row, int column) {
#     FILE *fp = fopen(name, "w");
#     fwrite(&row, sizeof(int), 1, fp);
#     fwrite(&column, sizeof(int), 1, fp);
#     fwrite(arr, sizeof(int), row * column, fp);

#     fclose(fp);
# }


write_matrix:

    # Prologue

    addi sp sp -24
    sw a2 0(sp)  # 0(sp) is row
    sw a3 4(sp)  # 4(sp) is column
    sw s0 8(sp)
    sw s1 12(sp)
    sw s2 16(sp)
    sw s3 20(sp)

    mv s1 a1  # s1 = arr
    mv s2 a2  # s2 = row
    mv s3 a3  # s3 = column


    # fopen
    li a1 1

    addi sp sp -4
    sw ra 0(sp)
    jal ra fopen
    lw ra 0(sp)
    addi sp sp 4

    li t0 -1
    beq a0 t0 fail_open
    mv s0 a0  # s0 = fp

    # fwrite
    addi a1 sp 0
    li a2 1
    li a3 4
    addi sp sp -4
    sw ra 0(sp)
    jal ra fwrite
    lw ra 0(sp)
    addi sp sp 4

    li t0 1
    bne a0 t0 fail_write

    # fwrite
    mv a0 s0
    addi a1 sp 4
    li a2 1
    li a3 4
    addi sp sp -4
    sw ra 0(sp)
    jal ra fwrite
    lw ra 0(sp)
    addi sp sp 4

    li t0 1
    bne a0 t0 fail_write

    # fwrite
    mv a0 s0
    mv a1 s1
    mul a2 s2 s3
    li a3 4
    addi sp sp -4
    sw ra 0(sp)
    jal ra fwrite
    lw ra 0(sp)
    addi sp sp 4

    mul t0 s2 s3
    bne a0 t0 fail_write

    # fclose
    mv a0 s0
    addi sp sp -4
    sw ra 0(sp)
    jal ra fclose
    lw ra 0(sp)
    addi sp sp 4

    li t0 0
    bne a0 t0 fail_close

    # Epilogue

    lw s0 8(sp)
    lw s1 12(sp)
    lw s2 16(sp)
    lw s3 20(sp)
    addi sp sp 24


    jr ra

fail_open:
    li a0 27
    j exit

fail_write:
    li a0 30
    j exit

fail_close:
    li a0 28
    j exit
