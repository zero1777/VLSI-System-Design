
RISCV_GNU_TOOLCHAIN_GIT_REVISION = 4e51f26
RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX = /users/course/tools/riscv32

SHELL = bash
TEST_OBJS = $(addsuffix .o,$(basename $(wildcard tests/*.S)))
FIRMWARE_OBJS = firmware/start.o firmware/irq.o firmware/print.o firmware/multest.o firmware/dnn_pcpi.o firmware/dnn_mmap.o firmware/stats.o
DBFILE      = *.fsdb *.vcd *.bak
TMPFILE     = *.log ncverilog.key nWaveLog INCA_libs novas.*
GCC_WARNS  = -Wall -Wextra -Wshadow -Wundef -Wpointer-arith -Wcast-qual -Wcast-align -Wwrite-strings
GCC_WARNS += -Wredundant-decls -Wstrict-prototypes -Wmissing-prototypes -pedantic
TOOLCHAIN_PREFIX = $(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX)i/bin/riscv32-unknown-elf-
COMPRESSED_ISA = C
ID = 0

# Add things like "export http_proxy=... https_proxy=..." here
GIT_ENV = true

pcpi: firmware/firmware.hex
	ncverilog testbench_pcpi.v dnn_pcpi.v picorv32.v +define+COMPRESSED_ISA +access+r

mmap: firmware/firmware.hex
	ncverilog testbench_mmap.v dnn_mmap.v picorv32.v +define+COMPRESSED_ISA +access+r

mmap_syn: firmware/firmware.hex
	ncverilog header.v testbench_mmap.v dnn_syn.v picorv32.v \
	-v /theda21_2/library/GPDK045/cur/gsclib045/verilog/slow_vdd1v2_basicCells.v \
	+define+COMPRESSED_ISA +access+r

pcpi_fsdb: firmware/firmware.hex
	ncverilog testbench_pcpi.v dnn_pcpi.v picorv32.v +define+COMPRESSED_ISA +fsdb +trace +noerror +access+r

mmap_fsdb: firmware/firmware.hex
	ncverilog testbench_mmap.v dnn_mmap.v picorv32.v +define+COMPRESSED_ISA +fsdb +trace +noerror +access+r

mmap_syn_fsdb: firmware/firmware.hex
	ncverilog header.v testbench_mmap.v dnn_syn.v picorv32.v \
	-v /theda21_2/library/GPDK045/cur/gsclib045/verilog/slow_vdd1v2_basicCells.v \
	+define+COMPRESSED_ISA  +fsdb +trace +noerror +access+r

firmware/firmware.hex: firmware/firmware.bin firmware/makehex.py
	python3 firmware/makehex.py $< 16384 > $@

firmware/firmware.bin: firmware/firmware.elf
	$(TOOLCHAIN_PREFIX)objcopy -O binary $< $@
	chmod -x $@

firmware/firmware.elf: $(FIRMWARE_OBJS) $(TEST_OBJS) firmware/sections.lds
	$(TOOLCHAIN_PREFIX)gcc -O0 -ffreestanding -nostdlib -o $@ \
		-Wl,-Bstatic,-T,firmware/sections.lds,-Map,firmware/firmware.map,--strip-debug \
		$(FIRMWARE_OBJS) $(TEST_OBJS) -lgcc
	chmod -x $@

firmware/start.o: firmware/start.S
	$(TOOLCHAIN_PREFIX)gcc -c -march=rv32im$(subst C,c,$(COMPRESSED_ISA)) -o $@ $<

firmware/%.o: firmware/%.c
	$(TOOLCHAIN_PREFIX)gcc -c -march=rv32i$(subst C,c,$(COMPRESSED_ISA)) -O0 --std=c99 $(GCC_WARNS) -ffreestanding -nostdlib -o $@ $<

tests/%.o: tests/%.S tests/riscv_test.h tests/test_macros.h
	$(TOOLCHAIN_PREFIX)gcc -c -march=rv32im -o $@ -DTEST_FUNC_NAME=$(notdir $(basename $<)) \
		-DTEST_FUNC_TXT='"$(notdir $(basename $<))"' -DTEST_FUNC_RET=$(notdir $(basename $<))_ret $<

clean:
	rm -rf riscv-gnu-toolchain-riscv32i riscv-gnu-toolchain-riscv32ic \
		riscv-gnu-toolchain-riscv32im riscv-gnu-toolchain-riscv32imc $(DBFILE) $(TMPFILE)
	rm -vrf $(FIRMWARE_OBJS) $(TEST_OBJS) \
		firmware/firmware.elf firmware/firmware.bin firmware/firmware.hex firmware/firmware.map \
		testbench.fsdb testbench.trace

.PHONY: test test_fsdb clean
