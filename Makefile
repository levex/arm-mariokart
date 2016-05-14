AS=arm-none-eabi-as
CC=arm-none-eabi-gcc
LD=arm-none-eabi-ld

IMAGE=kart.img
LINKERSCRIPT=linker.ld

SRCS = $(wildcard boot/*.S)
SRCS += $(wildcard util/*.S)
OBJS = $(SRCS:.S=.o)
OBJS += led.o

all: $(IMAGE)

clean:
	-@rm $(OBJS) $(IMAGE)

%.o: %.c
	@echo "  CC       $@"
	@$(CC) -c $< -o $@

%.o: %.S
	@echo "  AS       $@"
	@$(AS) -c $< -o $@

$(IMAGE): $(OBJS)
	@echo "  LD       $@"
	@$(LD) $(OBJS) -o $(IMAGE) -T $(LINKERSCRIPT)

