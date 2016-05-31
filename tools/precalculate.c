/* precalculates specific values */
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <math.h>

#define OUTPUT "gen/precalc.S"

struct precalc {
	char *name;
	uint32_t val;
};

#define PI 3.14159265
#define FOVX 90 * PI / 180
#define FOVY 90 * PI / 180

#define ZFAR  300
#define ZNEAR 10

struct precalc **stuff;

int main(int argc, char *argv[]) {
	int i, fdout;
	int num = 4;

	float fovx_tan = cos(FOVX/2) / sin(FOVX/2);
	float fovy_tan = cos(FOVY/2) / sin(FOVY/2);
	float p33 = -((ZFAR + ZNEAR)/(ZFAR - ZNEAR));
	float p34 = -(2 * (ZFAR * ZNEAR)/(ZFAR - ZNEAR));

	struct precalc s1 = { .name = "fovx_tan",
		.val = *(uint32_t *)&fovx_tan};
	struct precalc s2 = { .name = "fovy_tan",
		.val = *(uint32_t *)&fovy_tan};
	struct precalc s3 = { .name = "pers33",
		.val = *(uint32_t *)&p33};
	struct precalc s4 = { .name = "pers34",
		.val = *(uint32_t *)&p34};

	stuff = malloc(num * sizeof(uintptr_t));
	stuff[0] = &s1;
	stuff[1] = &s2;
	stuff[2] = &s3;
	stuff[3] = &s4;

	fdout = open(OUTPUT, O_RDWR | O_CREAT, 0644);
	ftruncate(fdout, 0);

	dprintf(fdout, ".section \".text\"\n\n");
        for (i = 0; i < num; i ++)
		dprintf(fdout, ".globl %s\n%s: .word 0x%x\n\n",
                          stuff[i]->name, stuff[i]->name, stuff[i]->val);

	return 0;
}
