#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <unistd.h>

struct bm_file_header {
	char bmf_magic[2];
	uint32_t bmf_size;
	uint16_t bmf_res1;
	uint16_t bmf_res2;
	uint32_t bmf_pixdataoff;
} __attribute__((packed));

struct bm_dib_header {
	uint32_t bdh_header_size;
	uint32_t bdh_im_width;
	uint32_t bdh_im_height;
	uint16_t bdh_colorplanes;
	uint16_t bdh_pixsize;
} __attribute__((packed));

int main (int argc, char *argv[]) {
	int fd, fdout, x, y;
	char *buf;
	uint32_t *out;
	struct stat st;
	struct bm_file_header *bmf;
	struct bm_dib_header  *bdh;

	fd = open(argv[1], O_RDONLY);
	fstat(fd, &st);
	buf = malloc(st.st_size);
	if (read(fd, buf, st.st_size) != st.st_size) {
		printf("ouch");
		return 1;
	}

	bmf = (void *) buf;
	bdh = (void *) (buf + sizeof(*bmf));

	out = malloc(8 + bdh->bdh_im_width * bdh->bdh_im_height * 4);

	out[0] = bdh->bdh_im_width;
	out[1] = bdh->bdh_im_height;

	uint32_t *color = (uint32_t *) (buf + sizeof(struct bm_file_header)
		              + bdh->bdh_header_size);
	char *data = buf + bmf->bmf_pixdataoff;
	int w = out[0];
	int h = out[1];

	for (x = 0; x < bdh->bdh_im_width; x ++) {
		for (y = 0; y < bdh->bdh_im_height; y ++) {
			uint8_t d = data[x + y * bdh->bdh_im_width];
			out[2 + x + (h - y) * bdh->bdh_im_width]
				= color[d];
		}
	}

	fdout = open(argv[2], O_RDWR | O_CREAT, S_IRUSR | S_IRGRP | S_IROTH);
	write(fdout, out, 8 + bdh->bdh_im_width * bdh->bdh_im_height * 4);

	return 0;
}
