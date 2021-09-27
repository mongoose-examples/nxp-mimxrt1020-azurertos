PROG = firmware

PROJECT_ROOT_PATH = $(realpath $(CURDIR)/../..)
DOCKER ?= docker run --rm -v $(PROJECT_ROOT_PATH):$(PROJECT_ROOT_PATH) -w $(CURDIR) mdashnet/armgcc

DIRS = azure-rtos board component device drivers mdio phy ports source startup utilities xip

SOURCES = $(foreach dir, $(DIRS), $(shell find $(dir) -type f -name '*.c'))

S_SOURCES = $(foreach dir, $(DIRS), $(shell find $(dir) -type f -name '*.S'))
S_OBJECTS = $(S_SOURCES:%.S=build/obj_s/%.o)

OBJECTS = $(SOURCES:%.c=build/obj_c/%.o) $(S_OBJECTS)

MONGOOSE_FLAGS = -DMG_ARCH=MG_ARCH_AZURERTOS -DMG_IO_SIZE=128
MCU_DEFINES = -DCPU_MIMXRT1021DAG5A -DSDK_DEBUGCONSOLE=1 -DXIP_EXTERNAL_FLASH=1 -DXIP_BOOT_HEADER_ENABLE=1 -DFSL_FEATURE_PHYKSZ8081_USE_RMII50M_MODE -DSDK_DEBUGCONSOLE_UART -DPRINTF_FLOAT_ENABLE=1 -DSCANF_FLOAT_ENABLE=1 -DPRINTF_ADVANCED_ENABLE=1 -DSCANF_ADVANCED_ENABLE=0 -DSERIAL_PORT_TYPE_UART=1 -DNX_INCLUDE_USER_DEFINE_FILE -DFX_INCLUDE_USER_DEFINE_FILE -DTX_INCLUDE_USER_DEFINE_FILE -DMCUXPRESSO_SDK -DCPU_MIMXRT1021DAG5A_cm7 -D__MCUXPRESSO -D__USE_CMSIS -DDEBUG -D__REDLIB__
MCU_FLAGS = -fno-common -ffunction-sections -fdata-sections -ffreestanding -fno-builtin -fmerge-constants -mcpu=cortex-m7 -mfpu=fpv5-d16 -mfloat-abi=hard -mthumb -fstack-usage

INCLUDES = -I"./board" -I"./source" -I"./mdio" -I"./phy" -I"./drivers" -I"./device" -I"./utilities" -I"./component/uart" -I"./component/serial_manager" -I"./component/lists" -I"./xip" -I"./azure-rtos/netxduo/addons/auto_ip" -I"./azure-rtos/netxduo/addons/cloud" -I"./azure-rtos/netxduo/addons/BSD" \
-I"./azure-rtos/netxduo/addons/dhcp" -I"./azure-rtos/netxduo/addons/dns" -I"./azure-rtos/netxduo/addons/ftp" -I"./azure-rtos/netxduo/addons/http" -I"./azure-rtos/netxduo/addons/mdns" -I"./azure-rtos/netxduo/addons/mqtt" -I"./azure-rtos/netxduo/addons/nat" -I"./azure-rtos/netxduo/addons/pop3" \
-I"./azure-rtos/netxduo/addons/ppp" -I"./azure-rtos/netxduo/addons/pppoe" -I"./azure-rtos/netxduo/addons/smtp" -I"./azure-rtos/netxduo/addons/snmp" -I"./azure-rtos/netxduo/addons/sntp" -I"./azure-rtos/netxduo/addons/telnet" -I"./azure-rtos/netxduo/addons/tftp" -I"./azure-rtos/netxduo/addons/web" \
-I"./azure-rtos/netxduo/common/inc" -I"./azure-rtos/netxduo/crypto_libraries/inc" -I"./azure-rtos/netxduo/nx_secure/inc" -I"./azure-rtos/netxduo/nx_secure/ports" -I"./azure-rtos/netxduo/ports/cortex_m7/gnu/inc" -I"./azure-rtos/filex/common/inc" -I"./azure-rtos/filex/ports/cortex_m7/gnu/inc" \
-I"./azure-rtos/threadx/common/inc" -I"./azure-rtos/threadx/ports/cortex_m7/gnu/inc" -I"./CMSIS" -I"./azure-rtos/config" -I"./sdk/redlib/include"

LIBDIRS = -L"./azure-rtos/binary/netxduo/cortex_m7/mcux" -L"./azure-rtos/binary/filex/cortex_m7/mcux" -L"./azure-rtos/binary/threadx/cortex_m7/mcux" -L"./ld" -L"./sdk/libs"

SPECS = -specs="sdk/redlib.specs"

CFLAGS = -std=gnu99 -O0 -g3 $(MCU_FLAGS) $(MCU_DEFINES) $(MONGOOSE_FLAGS) $(SPECS) $(INCLUDES)
LINKFLAGS = -nostdlib $(LIBDIRS) -Xlinker --gc-sections -Xlinker -print-memory-usage -Xlinker --sort-section=alignment -mcpu=cortex-m7 -mfpu=fpv5-d16 -mfloat-abi=hard -mthumb -T "./ld/MIMXRT1020-azure-simple-http-server_Debug.ld"

build: $(PROG).bin

$(PROG).bin: $(PROG).axf
	$(DOCKER) arm-none-eabi-size $<
	$(DOCKER) arm-none-eabi-objcopy -v -O binary $< $@

$(PROG).axf: $(OBJECTS)
	$(DOCKER) arm-none-eabi-gcc $(LINKFLAGS) $(OBJECTS) -lnetxduo -lfilex -lthreadx -o $@

build/obj_c/%.o: %.c
	@mkdir -p $(dir $@)
	$(DOCKER) arm-none-eabi-gcc $(CFLAGS) -c $< -o $@

build/obj_s/%.o: %.S
	@mkdir -p $(dir $@)
	$(DOCKER) arm-none-eabi-gcc $(CFLAGS) -x assembler-with-cpp -c $< -o $@

clean:
	rm -rf build/ firmware.axf firmware.bin
