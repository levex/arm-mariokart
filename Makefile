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
SRCS += $(wildcard game/*.S)
OBJS = $(subst tools/lookup_tables.o,, $(SRCS:.S=.o))
OBJS += tools/lookup_tables.o
OBJS += gen/precalc.o

MODELS = $(wildcard models/*.stl)
MODELS_OBJS = $(subst .stl,.pstl,$(MODELS))

SPRITES = $(wildcard sprites/*.bmp)
SPRITES_OBJS = $(subst .bmp,.pbmp,$(SPRITES))

MAPS = $(wildcard maps/*.map)
MAPS_OBJS = $(subst .map,.pstl,$(MAPS))

all: $(RAW)

clena: clean
clean:
	-@rm -f $(OBJS) $(IMAGE) $(SPRITES_OBJS) bmpconv lookup_generator
	-@rm -f precalculate
	-@rm -f gen/*
	-@rm -f obj_converter
	-@rm -f map_loader
	-@rm -f $(MODELS_OBJS)
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

gen/precalc.S: precalculate
	@echo "  PRECALC       $@"
	@./precalculate

precalculate: tools/precalculate.c
	@echo "  HOSTCC        $@"
	@$(HOSTCC) -lm $(HOSTCCFLAGS) tools/precalculate.c -o precalculate 

tools/lookup_tables.S: lookup_generator
	@echo "  GENLKUP       $@"
	@./lookup_generator

%.pbmp: %.bmp bmpconv
	@echo "  BMPCONV       $@"
	@./bmpconv $< $@

obj_converter: tools/obj_converter.c
	@echo "  HOSTCC        $@"
	@$(HOSTCC) $(HOSTCCFLAGS) tools/obj_converter.c -o obj_converter

%.pstl: %.stl obj_converter
	@echo "  PSTLCONV      $@"
	@./obj_converter $< $@

map_loader: tools/map_loader.c
	@echo "  HOSTCC        $@"
	@$(HOSTCC) $(HOSTCCFLAGS) tools/map_loader.c -o map_loader

%.pstl: %.map map_loader
	@echo "  MAPLDR      $@"
	@./map_loader $< $@

$(IMAGE): $(OBJS) $(SPRITES_OBJS) $(MODELS_OBJS)
	@echo "  LD            $@"
	@$(LD) $(OBJS) -o $(IMAGE) -T $(LINKERSCRIPT)

$(RAW): $(IMAGE)
	@echo "  OBJCOPY       $@"
	@$(OBJCOPY) $(IMAGE) -O binary $(RAW)
	@echo ""
	@echo "Sprites compiled in: $(subst sprites/,,$(SPRITES))"
