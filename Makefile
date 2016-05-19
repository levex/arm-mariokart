AS=arm-none-eabi-gcc
CC=arm-none-eabi-gcc
LD=arm-none-eabi-ld

IMAGE=kart.img
LINKERSCRIPT=linker.ld

SRCS = $(wildcard boot/*.S)
SRCS += $(wildcard util/*.S)
SRCS += $(wildcard drivers/*.S)
OBJS = $(SRCS:.S=.o)

all: $(IMAGE)

clean:
	-@rm $(OBJS) $(IMAGE)

%.o: %.S
	@echo "  AS       $@"
	@$(AS) -fPIC -mcpu=arm1176jzf-s -c $< -o $@

$(IMAGE): $(OBJS)
	@echo "  LD       $@"
	@$(LD) $(OBJS) -o $(IMAGE) -T $(LINKERSCRIPT)

