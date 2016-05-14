AS=arm-none-eabi-as
CC=arm-none-eabi-gcc
LD=arm-none-eabi-ld

IMAGE=kart.img
LINKERSCRIPT=linker.ld

SRCS = $(wildcard boot/*.S)
SRCS += $(wildcard util/*.S)
OBJS = $(SRCS:.S=.o)

all: $(IMAGE)

clean:
	-@rm $(OBJS) $(IMAGE)

%.o: %.S
	@echo "  AS       $@"
	@$(AS) -c $< -o $@

$(IMAGE): $(OBJS)
	@echo "  LD       $@"
	@$(LD) $(OBJS) -o $(IMAGE) -T $(LINKERSCRIPT)

