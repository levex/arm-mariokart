AS=arm-none-eabi-gcc
CC=arm-none-eabi-gcc
LD=arm-none-eabi-ld
OBJCOPY=arm-none-eabi-objcopy

ASFLAGS=-fPIC -mcpu=arm1176jzf-s

IMAGE=kart.img
RAW=kart.bin
LINKERSCRIPT=linker.ld

SRCS = $(wildcard boot/*.S)
SRCS += $(wildcard util/*.S)
SRCS += $(wildcard drivers/*.S)
SRCS += $(wildcard sprites/*.S)
OBJS = $(SRCS:.S=.o)

SPRITES = $(wildcard sprites/*.bmp)

all: $(RAW)

clean:
	-@rm $(OBJS) $(IMAGE)

%.o: %.S
	@echo "  AS            $@"
	@$(AS) $(ASFLAGS) -c $< -o $@

$(IMAGE): $(OBJS) $(SPRITES)
	@echo "  LD            $@"
	@$(LD) $(OBJS) -o $(IMAGE) -T $(LINKERSCRIPT)

$(RAW): $(IMAGE)
	@echo "  OBJCOPY       $@"
	@$(OBJCOPY) $(IMAGE) -O binary $(RAW)
	@echo ""
	@echo "Sprites compiled in: $(SPRITES)"
