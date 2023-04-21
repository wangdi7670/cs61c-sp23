.globl f # this allows other files to find the function f

# f takes in two arguments:
# a0 is the value we want to evaluate f at
# a1 is the address of the "output" array (defined above).
# The return value should be stored in a0
f:
    # Your code here
    # a0 是索引， a1 是数组(指向首个元素的指针)
    addi t0 a0 3
    addi t1 x0 4
    mul t0 t0 t1
    add t2 a1 t0
    lw a0 0(t2)
    # This is how you return from a function. You'll learn more about this later.
    # This should be the last line in your program.
    jr ra
