#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <unistd.h>
#include <string.h>

#define PRINT_STRING(var) printf("%s = %s\n", #var, var)
#define PRINT_INT(var) printf("%s = %d\n", #var, var)
#define PRINT_FLOAT(var) printf("%s = %f\n", #var, var)

typedef enum component {
  ROAD_STRAIGHT_1 = 1,
  ROAD_STRAIGHT_2 = 2,
  ROAD_STRAIGHT_3 = 3,
  ROAD_STRAIGHT_4 = 4,

  ROAD_CURVED_901 = 901,
  ROAD_CURVED_902 = 902,
  ROAD_CURVED_903 = 903,
  ROAD_CURVED_904 = 904,
  ROAD_CURVED_9992 = 9992,
} component_t;

struct triangle {
  float vertex1[4];
  float vertex2[4];
  float vertex3[4]; 
  float padding[4];
} __attribute__ ((packed));

typedef struct model {
  uint32_t num_triangles;
  struct triangle **triangles;
} __attribute__ ((packed)) model_t;

model_t **component_data;

void print_model(model_t *component_model) {
  for (int i = 0; i < 4; i++) {
    PRINT_FLOAT(component_model->triangles[0]->vertex1[i]);
    PRINT_FLOAT(component_model->triangles[0]->vertex2[i]);
    PRINT_FLOAT(component_model->triangles[0]->vertex3[i]);
    PRINT_FLOAT(component_model->triangles[0]->padding[i]);
  }
}

/* Rotates a model 90 degrees clockwise */
model_t *rotate(model_t *model) {
  model_t *new_model = malloc(sizeof(model_t));
  memcpy(new_model, model, sizeof(model_t));

  for (int i = 0; i < model->num_triangles; i++) {
    // x' = z
    new_model->triangles[i]->vertex1[0] = model->triangles[i]->vertex1[2];

    // z' = -x
    new_model->triangles[i]->vertex1[2] = model->triangles[i]->vertex1[0];
  }

  return new_model;
}

model_t *load_component_data(char *component) {
  int file;  
  uint32_t *buffer;
  struct stat st;

  /* Open file */
  char *new_component = calloc(7 + strlen(component) + 5 + 1, 1);
  strcat(new_component, "models/");
  strcat(new_component, component);
  strcat(new_component, ".pstl");

  file = open(new_component, O_RDONLY);
  fstat(file, &st);
  buffer = malloc(st.st_size);

  if (read(file, buffer, st.st_size) != st.st_size) {
    printf("Error opening component file");
    return NULL;
  }

  /* Return as a structure */

  model_t *component_model = malloc(sizeof(model_t));
  component_model->num_triangles = buffer[0];
  component_model->triangles = calloc(component_model->num_triangles, sizeof(struct triangle));

  for (int i = 0; i < component_model->num_triangles; i++) {
    component_model->triangles[i] = (void *) (buffer + 1 + i * (sizeof(struct triangle) / 4));
  }

  /*printf("Loaded model %s: \n", new_component);
  print_model(component_model);*/

  return component_model;
}

model_t *get_component_data(component_t component) {
  switch (component) {
    case ROAD_STRAIGHT_1: return component_data[0];
    case ROAD_STRAIGHT_2: return component_data[1];
    case ROAD_STRAIGHT_3: return component_data[2];
    case ROAD_STRAIGHT_4: return component_data[3];

    case ROAD_CURVED_901: return component_data[4];
    case ROAD_CURVED_902: return component_data[5];
    case ROAD_CURVED_903: return component_data[6];
    case ROAD_CURVED_904: return component_data[7];

    case ROAD_CURVED_9992: return component_data[7];
  }
}

void load_all_component_data() {
  component_data = calloc(8, sizeof(model_t));

  component_data[0] = load_component_data("road_straight_1");
  component_data[1] = rotate(component_data[0]);
  component_data[2] = rotate(component_data[1]);
  component_data[3] = rotate(component_data[2]);

  component_data[4] = load_component_data("road_curve_901");
  component_data[5] = rotate(component_data[4]);
  component_data[6] = rotate(component_data[5]);
  component_data[7] = rotate(component_data[6]);

}

model_t *translate_chunk(component_t component, int x, int z) {
  model_t *component_model = get_component_data(component);

  //printf("Translating model %d: \n", component);

  for (int i = 0; i < component_model->num_triangles; i++) {
    component_model->triangles[i]->vertex1[0] += x;
    component_model->triangles[i]->vertex1[2] += z;

    component_model->triangles[i]->vertex2[0] += x;
    component_model->triangles[i]->vertex2[2] += z;

    component_model->triangles[i]->vertex3[0] += x;
    component_model->triangles[i]->vertex3[2] += z;
  }

  return component_model;
}

int main (int argc, char *argv[]) {
  int file;
  char *buffer;
  struct stat st;

  /* Open file */

  file = open(argv[1], O_RDONLY);
  fstat(file, &st);
  buffer = malloc(st.st_size);

  if (read(file, buffer, st.st_size) != st.st_size) {
    printf("Error opening map file");
    return 1;
  }

  /* Load components */

  load_all_component_data();

  /* Process file */

  int map_width = atoi(strtok(buffer, "\n"));  
  int map_height = atoi(strtok(NULL, "\n"));
  int chunk_width = atoi(strtok(NULL, "\n"));
  int chunk_height = atoi(strtok(NULL, "\n"));
  int chunk_rows = map_width / chunk_width;
  int chunk_columns = map_height / chunk_height;
  int num_chunks = chunk_rows * chunk_columns;

  int num_total_triangles = 0;

  uint32_t file_size = num_chunks * sizeof(model_t) * 100;
  uint32_t *out = malloc(file_size);


  for (int y = 0; y < chunk_columns; y++) {
    for (int x = 0; x < chunk_rows; x++) {
      char *component_str;

      /* Skip all whitespace */
      do {
        component_str = strtok(NULL, " \n");
      } while (component_str == NULL);
      //PRINT_INT(x);
      //PRINT_INT(y);

      /* Get the chunk represented by the current number */
      component_t component = atoi(component_str);

      /* Position the component by translating it accordingly */
      model_t *translated_chunk = translate_chunk(component, x * chunk_width, y * chunk_height);

      //print_model(translated_chunk);

      /* Place the chunk in the output world file */
      for (int i = 0; i < translated_chunk->num_triangles; i++) {
         memcpy(out + 1 + (num_total_triangles + i) * (sizeof(struct triangle) / 4),
             translated_chunk->triangles[i], translated_chunk->num_triangles * sizeof(struct triangle));
      }
     
      /* Update number of triangles */
      num_total_triangles += translated_chunk->num_triangles;
    }
  }
  out[0] = num_total_triangles;

  file_size = 4 + num_total_triangles * sizeof(struct triangle);

  /* Output file */
  int fdout;

  fdout = open(argv[2], O_RDWR | O_CREAT, S_IRUSR | S_IRGRP | S_IROTH);
  write(fdout, out, file_size);

  return 0;
}
