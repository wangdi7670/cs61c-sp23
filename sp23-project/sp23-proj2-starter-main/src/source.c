#include <string.h>
#include <stdio.h>
#include <stdlib.h>

void relu(int *arr, int length) {
    for (int i = 0; i < length; i++) {
        if (arr[i] < 0) {
            arr[i] = 0;
        }
    }
}


int argmax(int *arr, int length) {
    int max = arr[0];
    int arg = 0;
    for (int i = 1; i < length; i++) {
        if (arr[i] > max) {
            max = arr[i];
            arg = i;
        }
    }

    return arg;
}



int dots(int *arr0, int *arr1, int num, int stride0, int stride1) {
    int sum = 0;
    for (int i = 0; i < num; i++) {
        sum += (arr0[i * stride0] * arr1[i * stride1]);
    }

    return sum;
}


void matmul(int *A, int rowA, int columnA, int *B, int rowB, int columnB, int *C) {
    for (int i = 0; i < rowA; i++) {
        for (int j = 0; j < columnB; j++) {
            C[i * columnB + j] = dots(A + i * columnA, B + j, columnA, 1, columnB);
        }
    }
}


void printMatrix(int *arr, int size) {
    for (int i = 0; i < size; i++) {
        printf("%d, ", arr[i]);
    }
}

int *read_matrix(char *file_name, int *row, int *column) {
    FILE *fp = fopen(file_name, "r");
    fread(row, sizeof(int), 1, fp);
    fread(column, sizeof(int), 1, fp);

    int size = (*row) * (*column);
    int *arr = malloc(size * sizeof(int));
    fread(arr, sizeof(int), size, fp);

    fclose(fp);

    return arr;
}


void write_matrix(char *name, int *arr, int row, int column) {
    FILE *fp = fopen(name, "w");
    fwrite(&row, sizeof(int), 1, fp);
    fwrite(&column, sizeof(int), 1, fp);
    fwrite(arr, sizeof(int), row * column, fp);

    fclose(fp);
}

int classify(int argc, char **argv, int isPrint) {
    // 1
    int *m0_row = malloc(sizeof(int));
    int *m0_column = malloc(sizeof(int));
    int *m0 = read_matrix(argv[1], m0_row, m0_column);

    int *m1_row = malloc(sizeof(int));
    int *m1_column = malloc(sizeof(int));
    int *m1 = read_matrix(argv[2], m1_row, m1_column);

    int *input_row = malloc(sizeof(int));
    int *input_column = malloc(sizeof(int));
    int *input = read_matrix(argv[3], input_row, input_column);

    // 2
    int h_row = *(m0_row);
    int h_column = *(input_column);
    int *h = malloc(h_row * h_column * sizeof(int));
    matmul(m0, *m0_row, *m0_column, input, *input_row, *input_column, h);

    // 3
    relu(h, h_row * h_column);

    // 4
    int o_row = *(m1_row);
    int o_column = h_column;
    int *o = malloc(o_row * o_column * sizeof(int));
    matmul(m1, *m1_row, *m1_column, h, h_row, h_column, o);
    write_matrix(argv[4], o, o_row, o_column);

    // 5
    int arg = argmax(o, o_row * o_column);
    if (isPrint == 0) {
        printf("%d\n", arg);
    }

    // 6
    free(m0_row);
    free(m0_column);
    free(m0);
    free(m1_row);
    free(m1_column);
    free(m1);
    free(input_row);
    free(input_column);
    free(input);
    free(h);
    free(o);

    // 7
    return arg;
}