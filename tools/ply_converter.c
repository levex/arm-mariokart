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

struct triangle_min {
  float vertex1[4];
  float vertex2[4];
  float vertex3[4]; 
  uint32_t padding[4];
} __attribute__ ((packed));

uint32_t get_hex_color(uint8_t color[3]) {
  uint32_t hex_color = 0x00000000;

  hex_color = color[0] << 4 * 4;
  hex_color = hex_color | (color[1] << 2 * 4);
  hex_color = hex_color | color[2];

  return hex_color;
}

int main (int argc, char *argv[]) {
  int file;
  char *buffer;
  struct stat st;

  uint8_t color[3] = {255, 255, 255};
  get_hex_color(color);

  /* Open file */

  file = open(argv[1], O_RDONLY);
  fstat(file, &st);
  buffer = malloc(st.st_size);

  if (read(file, buffer, st.st_size) != st.st_size) {
    printf("Error opening file");
    return 1;
  }

  /* Parse header */

  buffer = strstr(buffer, "element vertex ");
  buffer += strlen("element vertex ");
  char *num_vertices_str = strtok(buffer, "\n");
  int num_vertices = atoi(num_vertices_str);

  buffer += strlen(num_vertices_str) + 1;

  buffer = strstr(buffer, "element face ");
  buffer += strlen("element face ");
  char *num_faces_str = strtok(buffer, "\n");
  int num_faces = atoi(num_faces_str);

  buffer += strlen(num_faces_str) + 1;

  char *data_str = strstr(buffer, "end_header\n");
  data_str += strlen("end_header\n");

  float vertices[num_vertices][4];
  uint8_t colors[num_vertices][3];

  /* Parse vertices and colors */

  char *a;
  char *b;

  for (int i = 0; i < num_vertices; i++) {
    char *line = strtok_r(i == 0 ? data_str : NULL, "\n", &a);
    int line_length = strlen(line);

    //PRINT_STRING(line);
  
    for (int coord = 0; coord < 3; coord++) {
      char *token = strtok_r(coord == 0 ? line : NULL, " ", &b);
      vertices[i][coord] = atof(token);
      //PRINT_FLOAT(atof(token));
    }

    for (int rgb = 0; rgb < 3; rgb++) {
      char *token = strtok_r(NULL, " ", &b);
      colors[i][rgb] = atoi(token);
      //PRINT_INT(atoi(token));
    }

    vertices[i][3] = 1;

    data_str += line_length + 1;
  }

  /* Parse faces and create triangle structs */

  struct triangle_min triangles[num_faces];
  char *c;

  for (int i = 0; i < num_faces; i++) {
    char *line = strtok_r(i == 0 ? data_str : NULL, "\n", &a);
    int line_length = strlen(line);

    struct triangle_min triangle;

    for (int i = 0; i < 4; i++) {
      char *token;

      if (i == 0) {
        token = strtok_r(line, " ", &c);
      } else {
        token = strtok_r(NULL, " ", &c);
        int vertex = atoi(token);  

        switch (i) {
          case 1:
            memcpy(&triangle.vertex1[0], &vertices[vertex][0], sizeof(4 * sizeof(float)));
            memcpy(&triangle.vertex1[1], &vertices[vertex][1], sizeof(4 * sizeof(float)));
            memcpy(&triangle.vertex1[2], &vertices[vertex][2], sizeof(4 * sizeof(float)));
            triangle.vertex1[3] = 1;
            break;
          case 2:
            memcpy(&triangle.vertex2[0], &vertices[vertex][0], sizeof(4 * sizeof(float)));
            memcpy(&triangle.vertex2[1], &vertices[vertex][1], sizeof(4 * sizeof(float)));
            memcpy(&triangle.vertex2[2], &vertices[vertex][2], sizeof(4 * sizeof(float)));     
            triangle.vertex1[3] = 1;       
            break;
          case 3:
            memcpy(&triangle.vertex3[0], &vertices[vertex][0], sizeof(4 * sizeof(float)));
            memcpy(&triangle.vertex3[1], &vertices[vertex][1], sizeof(4 * sizeof(float)));
            memcpy(&triangle.vertex3[2], &vertices[vertex][2], sizeof(4 * sizeof(float)));      
            triangle.vertex1[3] = 1;      
            break;  
        }
        triangle.padding[0] = get_hex_color(colors[vertex]);
      }
    }

    triangle.padding[1] = 0;
    triangle.padding[2] = 0;
    triangle.padding[3] = 0;

    triangles[i] = triangle;

    //PRINT_FLOAT(triangle.vertex1[0]);
    //printf("%x\n", triangle.padding[0]);

    data_str += line_length + 1;
  }

  uint32_t file_size = sizeof(uint32_t) +
                       num_faces * sizeof(struct triangle_min);
  uint32_t *out = malloc(file_size);

  //PRINT_INT(file_size);
  printf("%s: %d triangles and %d vertices\n", argv[1], num_faces, num_vertices);

  out[0] = num_faces;
  for (int i = 0; i < num_faces; i++) {
    memcpy((uint8_t *) out + sizeof(uint32_t) + i * sizeof(struct triangle_min), &triangles[i], sizeof(struct triangle_min));
  }

  /* Output file */
  int fdout;

  fdout = open(argv[2], O_RDWR | O_CREAT, S_IRUSR | S_IRGRP | S_IROTH);
  write(fdout, out, file_size);

  return 0;
}
