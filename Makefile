AS=arm-none-eabi-gcc
CC=arm-none-eabi-gcc
LD=arm-none-eabi-ld
OBJCOPY=arm-none-eabi-objcopy

ASFLAGS=-fPIC -march=armv6zk -mcpu=arm1176jzf-s -mfpu=vfp -mfloat-abi=hard

HOSTCCFLAGS=
HOSTCC=gcc

IMAGE=kart.img
RAW=kart.bin
LINKERSCRIPT=linker.ld

SRCS = $(wildcard boot/*.S)
SRCS += $(wildcard util/*.S)
SRCS += $(wildcard drivers/*.S)
SRCS += $(wildcard sprites/*.S)
OBJS = $(SRCS:.S=.o)

SPRITES = $(wildcard sprites/*.bmp)
SPRITES_OBJS = $(subst .bmp,.pbmp,$(SPRITES))

all: $(RAW)

clean:
	-@rm -f $(OBJS) $(IMAGE) $(SPRITES_OBJS) bmpconv

sprites/sprites.o: $(SPRITES_OBJS) sprites/sprites.S

%.o: %.S
	@echo "  AS            $@"
	@$(AS) $(ASFLAGS) -c $< -o $@

bmpconv: util/bmp_converter.c
	@echo "  HOSTCC        $@"
	@$(HOSTCC) $(HOSTCCFLAGS) util/bmp_converter.c -o bmpconv

%.pbmp: %.bmp bmpconv
	@echo "  BMPCONV       $@"
	@./bmpconv $< $@

$(IMAGE): $(OBJS) $(SPRITES_OBJS)
	@echo "  LD            $@"
	@$(LD) $(OBJS) -o $(IMAGE) -T $(LINKERSCRIPT)

$(RAW): $(IMAGE)
	@echo "  OBJCOPY       $@"
	@$(OBJCOPY) $(IMAGE) -O binary $(RAW)
	@echo ""
	@echo "Sprites compiled in: $(subst sprites/,,$(SPRITES))"
