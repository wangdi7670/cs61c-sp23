addi t0, x0, 3
addi t1, x0, 8

andi s0, t0, 89

ori s1, t0, 2047

slli s1, s1, 30

srai s1, s1, 31

srli s1, s1, 4
xori s1, s1, 0
