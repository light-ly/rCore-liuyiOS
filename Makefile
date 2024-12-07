TARGET := riscv64gc-unknown-none-elf
MODE := release
KERNEL_ELF := target/$(TARGET)/$(MODE)/os
KERNEL_BIN := $(KERNEL_ELF).bin

# Binutils
OBJDUMP := rust-objdump --arch-name=riscv64
OBJCOPY := rust-objcopy --binary-architecture=riscv64

# Board Info
KERNEL_ENTRY_PA := 0x80200000
BOARD                ?= qemu
SBI                  ?= rustsbi
BOOTLOADER   := ../bootloader/$(SBI)-$(BOARD).bin

QEMU_ARGS += -machine virt -nographic
QEMU_ARGS += -bios $(BOOTLOADER) -device loader,file=$(KERNEL_BIN),addr=$(KERNEL_ENTRY_PA)

ifeq ($(GDB), 1)
QEMU_ARGS += -s -S
endif

kernel:
	@cargo build --$(MODE)

$(KERNEL_BIN): kernel
	@$(OBJCOPY) $(KERNEL_ELF) --strip-all -O binary $@

build: $(KERNEL_BIN)

clean:
	@cargo clean

run: run-inner

run-inner: build
ifeq ($(BOARD), qemu)
	@qemu-system-riscv64 $(QEMU_ARGS)
else ifeq ($(BOARD), k210)
	@cp $(BOOTLOADER) $(BOOTLOADER).copy
	@dd if=$(KERNEL_BIN) of=$(BOOTLOADER).copy bs=128K seek=1
	@mv $(BOOTLOADER).copy $(KERNEL_BIN)
	@sudo chmod 777 $(K210-SERIALPORT)
	python3 $(K210-BURNER) -p $(K210-SERIALPORT) -b 1500000 $(KERNEL_BIN)
	miniterm --eol LF --dtr 0 --rts 0 --filter direct $(K210-SERIALPORT) 115200
else
	@echo "Unsupport Board '$(BOARD)'! Nothing to do ..."
endif

gdb-client:
	riscv64-unknown-elf-gdb \
       -ex 'file target/riscv64gc-unknown-none-elf/release/os' \
       -ex 'set arch riscv:rv64' \
       -ex 'target remote localhost:1234'

.PHONY: kernel build run run-inner clean