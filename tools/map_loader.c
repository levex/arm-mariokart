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
    EMPTY = 0,

    ROAD_STRAIGHT_1 = 1,
    ROAD_STRAIGHT_2 = 2,
    ROAD_STRAIGHT_3 = 3,
    ROAD_STRAIGHT_4 = 4,

    ROAD_CURVED_901 = 901,
    ROAD_CURVED_902 = 902,
    ROAD_CURVED_903 = 903,
    ROAD_CURVED_904 = 904,
    
    POWERUP = 999,
} component_t;

struct triangle {
  float vertex1[4];
  float vertex2[4];
  float vertex3[4]; 
  uint32_t padding[4];
} __attribute__ ((packed));

typedef struct model {
    uint32_t num_triangles;
    struct triangle **triangles;
} __attribute__ ((packed)) model_t;

model_t *component_data[10];

void print_model(model_t *component_model) {
    for (int i = 0; i < 4; i++) {
        PRINT_FLOAT(component_model->triangles[0]->vertex1[i]);
        PRINT_FLOAT(component_model->triangles[0]->vertex2[i]);
        PRINT_FLOAT(component_model->triangles[0]->vertex3[i]);
        PRINT_INT(component_model->triangles[0]->padding[i]);
    }
}

/* Rotates a model 90 degrees clockwise */
/*model_t *rotate(model_t *model) {
  PRINT_STRING("Old model:");
  model_t *new_model = calloc(1, sizeof(model_t));
  new_model->triangles = calloc(model->num_triangles, sizeof(struct triangle));
  new_model->num_triangles = model->num_triangles;
  memcpy(new_model->triangles, model->triangles, model->num_triangles * sizeof(struct triangle));

  for (int i = 0; i < model->num_triangles; i++) {
    // x' = z
    new_model->triangles[i]->vertex1[0] = model->triangles[i]->vertex1[2];
    new_model->triangles[i]->vertex2[0] = model->triangles[i]->vertex2[2];
    new_model->triangles[i]->vertex3[0] = model->triangles[i]->vertex3[2];

    // z' = -x
    new_model->triangles[i]->vertex1[2] = model->triangles[i]->vertex1[0];
    new_model->triangles[i]->vertex2[2] = model->triangles[i]->vertex2[0];
    new_model->triangles[i]->vertex3[2] = model->triangles[i]->vertex3[0];
  }
  PRINT_STRING("New model:");
  return new_model;
}*/

model_t *load_component_data(char *component) {
  int file;  
  uint32_t *buffer;
  struct stat st;

  /* Open file */
  char *new_component = calloc(7 + strlen(component) + 5 + 1, 1);
  strcat(new_component, "models/");
  strcat(new_component, component);
  strcat(new_component, ".pply");

  //PRINT_STRING(new_component);

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

  /* Round all values */  
  /*for (int i = 0; i < component_model->num_triangles; i++) {
    for (int j = 0; j < 3; j++) {
      component_model->triangles[i]->vertex1[j] = round(component_model->triangles[i]->vertex1[j]);
      component_model->triangles[i]->vertex2[j] = round(component_model->triangles[i]->vertex2[j]);
      component_model->triangles[i]->vertex3[j] = round(component_model->triangles[i]->vertex3[j]);
    }
  }*/

  free(new_component);

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

    case POWERUP:         return component_data[8];
    case EMPTY:           return component_data[9];
  }
}

void load_all_component_data() {
  component_data[0] = load_component_data("road_straight_1");
  component_data[1] = load_component_data("road_straight_1");
  component_data[2] = load_component_data("road_straight_3");
  component_data[3] = load_component_data("road_straight_1");

  component_data[4] = load_component_data("road_curve_901");
  component_data[5] = load_component_data("road_curve_902");
  component_data[6] = load_component_data("road_curve_903");
  component_data[7] = load_component_data("road_curve_904");

  component_data[8] = load_component_data("powerup");
  component_data[9] = load_component_data("empty");
}

model_t *translate_chunk(component_t component, int x, int z) {
  model_t *model = get_component_data(component);
  model_t *new_model = calloc(1, sizeof(model_t));
  new_model->triangles = calloc(model->num_triangles, sizeof(struct triangle));
  new_model->num_triangles = model->num_triangles;
  memcpy(new_model->triangles, model->triangles, model->num_triangles * sizeof(struct triangle));


  for (int i = 0; i < new_model->num_triangles; i++) {
    new_model->triangles[i]->vertex1[0] += x;
    new_model->triangles[i]->vertex1[2] += z;

    new_model->triangles[i]->vertex2[0] += x;
    new_model->triangles[i]->vertex2[2] += z;

    new_model->triangles[i]->vertex3[0] += x;
    new_model->triangles[i]->vertex3[2] += z;
  }

  return new_model;
}

int main (int argc, char *argv[]) {
  int file;
  char *buffer;
  struct stat st;

  /* Open file */

  file = open(argv[1], O_RDONLY);
  fstat(file, &st);
  buffer = calloc(st.st_size + 1, 1);

  if (read(file, buffer, st.st_size) != st.st_size) {
    printf("Error opening map file\n");
    return 1;
  }

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

  model_t *chunks[num_chunks];
  model_t *powerups[num_chunks];

  
  PRINT_INT(map_width);
  PRINT_INT(map_height);
  PRINT_INT(chunk_width);
  PRINT_INT(chunk_height);
  PRINT_INT(chunk_rows);
  PRINT_INT(chunk_columns);
  /* Process road */

  int i = 0;
  for (int y = 0; y < chunk_columns; y++) {
    for (int x = 0; x < chunk_rows; x++) {
      char *component_str;

      /* Skip all whitespace */
      do {
        component_str = strtok(NULL, " \n");
      } while (component_str == NULL);

      /* Position the component by translating it accordingly */
      model_t *translated_chunk = translate_chunk(atoi(component_str), x * chunk_width, y * chunk_height);

      chunks[i] = translated_chunk;
     
      /* Update number of triangles */
      num_total_triangles += translated_chunk->num_triangles;
      i++;
    }
  }

  /* Process powerups */
  int num_powerups = 0;
  for (int y = 0; y < chunk_columns; y++) {
    for (int x = 0; x < chunk_rows; x++) {
      char *component_str = calloc(1, 1);

      /* Skip all whitespace */
      do {
        component_str = strtok(NULL, " \n");
      } while (component_str == NULL);
      
      if (strcmp(component_str, "1") == 0) {
        model_t *translated_chunk = translate_chunk(POWERUP, x * chunk_width, y * chunk_height);
        powerups[num_powerups] = translated_chunk;
        num_powerups++;
        num_total_triangles += translated_chunk->num_triangles;
      }     
    }
  }
  char *num_powerups_str = calloc(10, 1);
  sprintf(num_powerups_str, "%d", num_powerups);

  uint32_t file_size = sizeof(uint32_t) + num_total_triangles * sizeof(struct triangle);
  uint32_t *out = malloc(file_size);
  out[0] = num_total_triangles;

  uint32_t *location = out + 1;
  /* Place the chunks in the output world file */
  for (int i = 0; i < num_chunks; i++) {
    for (int j = 0; j < chunks[i]->num_triangles; j++) {
      memcpy(location,
             chunks[i]->triangles[j],
             sizeof(struct triangle));
      location += sizeof(struct triangle) / 4;
    }
  }

  /* Place the powerups */
  for (int i = 0; i < num_powerups; i++) {
    for (int j = 0; j < powerups[i]->num_triangles; j++) {
      memcpy(location,
             powerups[i]->triangles[j],
             sizeof(struct triangle));
      location += sizeof(struct triangle) / 4;
    }
  }

  int fdout;

  /* Output map file */

  char *map_file = argv[2];

  printf("%s: %d triangles and %d powerups\n", argv[2], num_total_triangles, num_powerups);

  fdout = open(map_file, O_RDWR | O_CREAT, S_IRUSR | S_IRGRP | S_IROTH);
  write(fdout, out, file_size);

  /* Output powerup file */

  map_file[strlen(map_file) - 5] = '\0';
  char *powerup_file = calloc(strlen(argv[2]) + 11 + 1, 1);
  powerup_file = strcat(powerup_file, map_file);
  powerup_file = strcat(powerup_file, "_powerups.S");

  fdout = open(powerup_file, O_RDWR | O_CREAT, S_IRUSR | S_IRGRP | S_IROTH);
  powerup_file[strlen(powerup_file) - 2] = '\0';
  powerup_file += 5;

  char *powerups_header = calloc(10000, 1);
  powerups_header = strcat(powerups_header, ".section \".data\"\n\n");
  powerups_header = strcat(powerups_header, ".globl ");
  powerups_header = strcat(powerups_header, powerup_file);
  powerups_header = strcat(powerups_header, ", ");
  powerups_header = strcat(powerups_header, powerup_file);
  powerups_header = strcat(powerups_header, "_num");
  powerups_header = strcat(powerups_header, "\n");
  powerups_header = strcat(powerups_header, powerup_file);
  powerups_header = strcat(powerups_header, "_num: .word ");
  powerups_header = strcat(powerups_header, num_powerups_str);
  powerups_header = strcat(powerups_header, "\n");
  powerups_header = strcat(powerups_header, powerup_file);
  powerups_header = strcat(powerups_header, ":\n");

  write(fdout, powerups_header, strlen(powerups_header));

  for (int i = 0; i < num_powerups; i++) {
    model_t *powerup = powerups[i];
    dprintf(fdout, ".float %f, %f\n", powerup->triangles[0]->vertex1[0], powerup->triangles[0]->vertex1[2]);
  }

  /* Free */

  free(buffer);
  free(out);

  return 0;
}
