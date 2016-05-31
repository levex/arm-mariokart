#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <unistd.h>
#include <string.h>

struct header {
  uint8_t header[80];
  uint32_t num_triangles;
} __attribute__ ((packed));

struct triangle {
  float normal[3];
  float vertex1[3];
  float vertex2[3];
  float vertex3[3];
  uint16_t atrribute_byte_count;
} __attribute__ ((packed));

struct triangle_min {
  float vertex1[4];
  float vertex2[4];
  float vertex3[4]; 
  float padding[4];
} __attribute__ ((packed));

int main (int argc, char *argv[]) {
  int file;
  uint8_t *buffer;
  struct stat st;

  /* Open file */

  file = open(argv[1], O_RDONLY);
  fstat(file, &st);
  buffer = malloc(st.st_size);

  if (read(file, buffer, st.st_size) != st.st_size) {
    printf("Error opening file");
    return 1;
  }

  /* Process file */

  struct header *head = (void *) buffer;
  buffer += sizeof(struct header);

  uint32_t file_size = sizeof(uint32_t) +
                       head->num_triangles * sizeof(struct triangle_min);
  uint32_t *out = malloc(file_size);

  out[0] = head->num_triangles;
  printf("  Number of triangles in %s: %d\n", argv[1], head->num_triangles);

  for (int i = 0; i < head->num_triangles; i++) {
    struct triangle *tri = (void *) (buffer + i * sizeof(struct triangle));
    struct triangle_min *min = malloc(sizeof(struct triangle_min));

    memcpy(&min->vertex1, &tri->vertex1, sizeof(float) * 3);
    memcpy(&min->vertex2, &tri->vertex2, sizeof(float) * 3);
    memcpy(&min->vertex3, &tri->vertex3, sizeof(float) * 3);

    //Add w value
    min->vertex1[3] = 1;
    min->vertex2[3] = 1;
    min->vertex3[3] = 1;

    //Add padding
    memset(min->padding, 0, sizeof(float) * 4);

    memcpy((uint8_t *) out + sizeof(uint32_t) + i * sizeof(struct triangle_min), min, sizeof(struct triangle_min));
  }

  /* Output file */
  int fdout;

  fdout = open(argv[2], O_RDWR | O_CREAT, S_IRUSR | S_IRGRP | S_IROTH);
  write(fdout, out, file_size);

  return 0;
}
