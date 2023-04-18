#include "state.h"

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "snake_utils.h"

/* Helper function definitions */
static void set_board_at(game_state_t* state, unsigned int row, unsigned int col, char ch);
static bool is_tail(char c);
static bool is_head(char c);
static bool is_snake(char c);
static char body_to_tail(char c);
static char head_to_body(char c);
static unsigned int get_next_row(unsigned int cur_row, char c);
static unsigned int get_next_col(unsigned int cur_col, char c);
static void find_head(game_state_t* state, unsigned int snum);
static char next_square(game_state_t* state, unsigned int snum);
static void update_tail(game_state_t* state, unsigned int snum);
static void update_head(game_state_t* state, unsigned int snum);

/* Task 1 */
game_state_t* create_default_state() {
  // TODO: Implement this function.
  snake_t *snek = (snake_t *)malloc(sizeof(snake_t));
  snek->live = true;
  snek->head_col = 4;
  snek->head_row = 2;
  snek->tail_col = 2;
  snek->tail_row = 2;

  game_state_t *game = (game_state_t *)malloc(sizeof(game_state_t));
  game->num_rows = 18;
  game->num_snakes = 1;
  game->snakes = snek;
  
  unsigned int rows = 18;
  unsigned int colums = 20;
  char str1[] = "####################";
  char str2[] = "#                  #";

  char **arr = (char **)malloc(rows * sizeof(char *));
  for (int i = 0; i < rows; i++) {
    arr[i] = (char *)malloc((colums+1) * sizeof(char));
    if (i == 0 || i == 17) {
      strcpy(arr[i], str1);
    }else {
      strcpy(arr[i], str2);
    }
  }

  arr[2][2] = 'd';
  arr[2][3] = '>';
  arr[2][4] = 'D';
  arr[2][9] = '*';

  game->board = arr;

  return game;
}

/* Task 2 */
void free_state(game_state_t* state) {
  // TODO: Implement this function.
  free(state->snakes);
  
  for (int i = 0; i < state->num_rows; i++) {
    free(state->board[i]);
  }

  free(state->board);

  free(state);

  return;
}

/* Task 3 */
void print_board(game_state_t* state, FILE* fp) {
  // TODO: Implement this function.
  for (int i = 0; i < state->num_rows; i++) {
    fprintf(fp, "%s\n", state->board[i]);
  }
  return;
}

/*
  Saves the current state into filename. Does not modify the state object.
  (already implemented for you).
*/
void save_board(game_state_t* state, char* filename) {
  FILE* f = fopen(filename, "w");
  print_board(state, f);
  fclose(f);
}

/* Task 4.1 */

/*
  Helper function to get a character from the board
  (already implemented for you).
*/
char get_board_at(game_state_t* state, unsigned int row, unsigned int col) {
  return state->board[row][col];
}

/*
  Helper function to set a character on the board
  (already implemented for you).
*/
static void set_board_at(game_state_t* state, unsigned int row, unsigned int col, char ch) {
  state->board[row][col] = ch;
}

/*
  Returns true if c is part of the snake's tail.
  The snake consists of these characters: "wasd"
  Returns false otherwise.
*/
static bool is_tail(char c) {
  // TODO: Implement this function.
  if (c == 'w' || c == 'a' || c == 's' || c == 'd') {
    return true;
  }
  return false;
}

/*
  Returns true if c is part of the snake's head.
  The snake consists of these characters: "WASDx"
  Returns false otherwise.
*/
static bool is_head(char c) {
  // TODO: Implement this function.
  if (c != 'W' && c != 'A' && c != 'S' && c != 'D' && c != 'x') {
    return false;
  }
  return true;
}

/*
  Returns true if c is part of the snake.
  The snake consists of these characters: "wasd^<v>WASDx"
*/
static bool is_snake(char c) {
  // TODO: Implement this function.
  if (is_tail(c) || is_head(c) || c == '^' || c == '<' || c == 'v' || c == '>') {
    return true;
  }
  return false;
}

/*
  Converts a character in the snake's body ("^<v>")
  to the matching character representing the snake's
  tail ("wasd").
*/
static char body_to_tail(char c) {
  // TODO: Implement this function.
  if (is_snake(c)) {
    switch (c)
    {
    case '^':
      /* code */
      return 'w';
    case '<':
      return 'a';
    case 'v':
      return 's';
    case '>':
      return 'd';
    }
  }
  return '?';
}

/*
  Converts a character in the snake's head ("WASD")
  to the matching character representing the snake's
  body ("^<v>").
*/
static char head_to_body(char c) {
  // TODO: Implement this function.
  if (is_snake(c)) {
    switch (c)
    {
    case 'W':
      /* code */
      return '^';
    case 'A':
      return '<';
    case 'S':
      return 'v';
    case 'D':
      return '>';
    }
  }
  return '?';
}

/*
  Returns cur_row + 1 if c is 'v' or 's' or 'S'.
  Returns cur_row - 1 if c is '^' or 'w' or 'W'.
  Returns cur_row otherwise.
*/
static unsigned int get_next_row(unsigned int cur_row, char c) {
  // TODO: Implement this function.
  if (c == 'v' || c == 's' || c == 'S') {
    return cur_row + 1;
  }
  if (c == '^' || c == 'w' || c == 'W') {
    return cur_row - 1;
  }
  return cur_row;
}

/*
  Returns cur_col + 1 if c is '>' or 'd' or 'D'.
  Returns cur_col - 1 if c is '<' or 'a' or 'A'.
  Returns cur_col otherwise.
*/
static unsigned int get_next_col(unsigned int cur_col, char c) {
  // TODO: Implement this function.
  if (c == '>' || c == 'd' || c == 'D') {
    return cur_col + 1;
  }
  if (c == '<' || c == 'a' || c == 'A') {
    return cur_col - 1;
  }
  return cur_col;
}

/*
  Task 4.2

  Helper function for update_state. Return the character in the cell the snake is moving into.

  This function should not modify anything.
*/
static char next_square(game_state_t* state, unsigned int snum) {
  // TODO: Implement this function.
  snake_t snake = state->snakes[snum];
  char head_char = get_board_at(state, snake.head_row, snake.head_col);
  unsigned int next_col = get_next_col(snake.head_col, head_char);
  unsigned int next_row = get_next_row(snake.head_row, head_char);
  char ans = get_board_at(state, next_row, next_col);
  return ans;
}

/*
  Task 4.3

  Helper function for update_state. Update the head...

  ...on the board: add a character where the snake is moving

  ...in the snake struct: update the row and col of the head

  Note that this function ignores food, walls, and snake bodies when moving the head.
*/
static void update_head(game_state_t* state, unsigned int snum) {
  // TODO: Implement this function.
  snake_t* snake = state->snakes + snum;
  char head_char = get_board_at(state, snake->head_row, snake->head_col);

  unsigned int next_col = get_next_col(snake->head_col, head_char);
  unsigned int next_row = get_next_row(snake->head_row, head_char);

  set_board_at(state, snake->head_row, snake->head_col, head_to_body(head_char));
  set_board_at(state, next_row, next_col, head_char);

  snake->head_col = next_col;
  snake->head_row = next_row;
  return;
}

/*
  Task 4.4

  Helper function for update_state. Update the tail...

  ...on the board: blank out the current tail, and change the new
  tail from a body character (^<v>) into a tail character (wasd)

  ...in the snake struct: update the row and col of the tail
*/
static void update_tail(game_state_t* state, unsigned int snum) {
  // TODO: Implement this function.
  snake_t* snake = state->snakes + snum;
  char tail_char = get_board_at(state, snake->tail_row, snake->tail_col);

  unsigned int next_row = get_next_row(snake->tail_row, tail_char);
  unsigned int next_col = get_next_col(snake->tail_col, tail_char);

  set_board_at(state, snake->tail_row, snake->tail_col, ' ');

  char c = get_board_at(state, next_row, next_col);
  set_board_at(state, next_row, next_col, body_to_tail(c));

  snake->tail_col = next_col;
  snake->tail_row = next_row;

  return;
}

/* Task 4.5 */
void update_state(game_state_t* state, int (*add_food)(game_state_t* state)) {
  // TODO: Implement this function.
  unsigned int nums = state->num_snakes;
  for (unsigned int snum = 0; snum < nums; snum++) {
    char c = next_square(state, snum);
    // 前方啥都没有
    if (c == ' ') {  
      update_head(state, snum);
      update_tail(state, snum);
    } 
    // 吃水果
    else if (c == '*') {
      update_head(state, snum);
      add_food(state);
    } 
    // The head crashes into the body of a snake or a wall
    else if (c == '#' || is_snake(c)) {
      unsigned int row = state->snakes[snum].head_row;
      unsigned int col = state->snakes[snum].head_col;
      set_board_at(state, row, col, 'x');
      state->snakes[snum].live = false;
    }
  }

  return;
}

/* Task 5 */
game_state_t* load_board(char* filename) {
  // TODO: Implement this function.
  FILE *fp = fopen(filename, "r");
  if (fp == NULL) {
    printf("Failed to open file.\n");
    return NULL;
  }

  game_state_t* state = malloc(sizeof(game_state_t));
  state->num_snakes = 0;
  state->snakes = NULL;

  // row 和 col代表 board 中的索引
  unsigned int row = 0;
  unsigned int col = 0;
  // board 中每一行基础长度是5,如果不够再扩容，扩容+5
  unsigned int length = 5;
  state->board = malloc((row+1) * sizeof(char *));
  state->board[0] = calloc(length, sizeof(char));

  char ch;
  while ((ch = (char) fgetc(fp)) != EOF) {
    if (ch != '\n') {
      state->board[row][col] = ch;
      col++;
      if (col == length) {
        length += 5;
        state->board[row] = realloc(state->board[row], length * sizeof(char));
      }
      state->board[row][col] = '\0';
    } else {
      row++;
      state->board = realloc(state->board, (row+1) * sizeof(char*));
      col = 0;
      length = 5;
      state->board[row] = calloc(length, sizeof(char));
    }
  }

  if (col == 0) {
    state->num_rows = row;
  } else {
    state->num_rows = row + 1;
  }

  fclose(fp);

  return state;
}

/*
  Task 6.1

  Helper function for initialize_snakes.
  Given a snake struct with the tail row and col filled in,
  trace through the board to find the head row and col, and
  fill in the head row and col in the struct.
*/
static void find_head(game_state_t* state, unsigned int snum) {
  // TODO: Implement this function.
  snake_t* snake = state->snakes + snum;
  unsigned int row = snake->tail_row;
  unsigned int col = snake->tail_col;
  char ch = get_board_at(state, row, col);

  while (!is_head(ch)) {
    row = get_next_row(row, ch);
    col = get_next_col(col, ch);
    ch = get_board_at(state, row, col);
  }

  snake->head_row = row;
  snake->head_col = col;

  return;
}

/* Task 6.2 */
game_state_t* initialize_snakes(game_state_t* state) {
  // TODO: Implement this function.
  state->snakes = malloc(state->num_snakes * sizeof(snake_t));

  for (unsigned int i = 0; i < state->num_rows; i++) {
    for (unsigned int j = 0; state->board[i][j] != '\0'; j++) {
      if (is_tail(state->board[i][j])) {
        state->num_snakes += 1;
        state->snakes = realloc(state->snakes, state->num_snakes * sizeof(snake_t));
        snake_t* snk = state->snakes + (state->num_snakes - 1);
        snk->live = true;
        snk->tail_row = i;
        snk->tail_col = j;
        find_head(state, state->num_snakes - 1);
      }
    }
  }
  
  return state;
}
