CC := clang
LD := ld.lld

CFLAGS := -ffreestanding -MMD -mno-red-zone -std=c11 \
	-target x86_64-unknown-windows
LDFLAGS := -flavor link -subsystem:efi_application -entry:efi_main

SRCS := $(wildcard *.c)
OBJS := $(SRCS:c=o)

.PHONY: all clean install

all: pkernel

$(OBJS): %.o : %.c
	$(CC) $(CFLAGS) -c $<

kernel.bin: kernel.s
	fasm kernel.s kernel.bin

ps2_keyboard.o: ./drivers/ps2_keyboard.c
	$(CC)	$(CFLAGS) -c ./drivers/ps2_keyboard.c

fasm.elf: fasmelf.s
	fasm fasmelf.s fasm.elf

pkernel: $(OBJS) kernel.bin fasm.elf ps2_keyboard.o
	$(LD) $(LDFLAGS) ${OBJS} ps2_keyboard.o -out:/root/virtual_machine/disk/pkernel #-verbose 

#-include $(SRCS:.c=.d)

release:
	cp /root/virtual_machine/disk/pkernel /boot/pkernel

install:
	cp kernel.bin /root/virtual_machine/disk/kernel.bin
	cp fasm.elf /root/virtual_machine/disk/fasm.elf

clean:
	rm -f *.o
	rm -f *.d
	rm -f *.bin
	rm -f *.elf

