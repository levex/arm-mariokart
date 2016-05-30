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
SRCS += $(subst util/macros.S,, $(wildcard util/*.S))
SRCS += $(wildcard drivers/*.S)
SRCS += $(wildcard graphics/*.S)
SRCS += $(wildcard sprites/*.S)
OBJS = $(subst tools/lookup_tables.o,, $(SRCS:.S=.o))
OBJS += tools/lookup_tables.o

SPRITES = $(wildcard sprites/*.bmp)
SPRITES_OBJS = $(subst .bmp,.pbmp,$(SPRITES))

all: $(RAW)

clean:
	-@rm -f $(OBJS) $(IMAGE) $(SPRITES_OBJS) bmpconv lookup_generator
	-@rm -f tools/lookup_tables.S
	-@rm -f $(RAW)

sprites/sprites.o: $(SPRITES_OBJS) sprites/sprites.S

%.o: %.S
	@echo "  AS            $@"
	@$(AS) $(ASFLAGS) -c $< -o $@

bmpconv: tools/bmp_converter.c
	@echo "  HOSTCC        $@"
	@$(HOSTCC) $(HOSTCCFLAGS) tools/bmp_converter.c -o bmpconv

lookup_generator: tools/generate_lookup.c
	@echo "  HOSTCC        $@"
	@$(HOSTCC) -lm $(HOSTCCFLAGS) tools/generate_lookup.c -o lookup_generator

tools/lookup_tables.S: lookup_generator
	@echo "  GENLKUP       $@"
	@./lookup_generator

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
