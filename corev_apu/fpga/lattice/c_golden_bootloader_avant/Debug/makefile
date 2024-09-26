################################################################################
# Automatically-generated file. Do not edit!
################################################################################

-include ../makefile.init

RM := rm -rf

# All of the sources participating in the build are defined here
-include sources.mk
-include src/bsp/driver/uart/subdir.mk
-include src/bsp/driver/tse_mac/subdir.mk
-include src/bsp/driver/sgdma/subdir.mk
-include src/bsp/driver/riscv_rtos/subdir.mk
-include src/bsp/driver/qspi_flash_controller/subdir.mk
-include src/bsp/driver/mc_avant/subdir.mk
-include src/bsp/driver/gpio/subdir.mk
-include src/subdir.mk
-include subdir.mk
-include objects.mk

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(ASM_DEPS)),)
-include $(ASM_DEPS)
endif
ifneq ($(strip $(S_UPPER_DEPS)),)
-include $(S_UPPER_DEPS)
endif
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
endif

-include ../makefile.defs

OPTIONAL_TOOL_DEPS := \
$(wildcard ../makefile.defs) \
$(wildcard ../makefile.init) \
$(wildcard ../makefile.targets) \


BUILD_ARTIFACT_NAME := c_golden_bootloader_avant
BUILD_ARTIFACT_EXTENSION := elf
BUILD_ARTIFACT_PREFIX :=
BUILD_ARTIFACT := $(BUILD_ARTIFACT_PREFIX)$(BUILD_ARTIFACT_NAME)$(if $(BUILD_ARTIFACT_EXTENSION),.$(BUILD_ARTIFACT_EXTENSION),)

# Add inputs and outputs from these tool invocations to the build variables 
SECONDARY_LIST += \
c_golden_bootloader_avant.lst \

SECONDARY_SIZE += \
c_golden_bootloader_avant.siz \

SECONDARY_MEMORY += \
c_golden_bootloader_avant.mem \


# All Target
all: main-build

# Main-build Target
main-build: c_golden_bootloader_avant.elf secondary-outputs

# Tool invocations
c_golden_bootloader_avant.elf: $(OBJS) $(USER_OBJS) makefile objects.mk $(OPTIONAL_TOOL_DEPS)
	@echo 'Building target: $@'
	@echo 'Invoking: GNU RISC-V Cross C Linker'
	riscv-none-embed-gcc -march=rv32imac -mabi=ilp32 -msmall-data-limit=8 -mno-save-restore -O0 -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections  -g3 -T "C:/Users/SKothari/Downloads/GSRD2.0_Avant_CPNX_Beta/Final_Beta_Testing/golden_avant/c_golden_bootloader_avant/src/linker.ld" -nostartfiles -Xlinker --gc-sections -Wl,-Map,"c_golden_bootloader_avant.map" --specs=picolibc.specs -DPICOLIBC_INTEGER_PRINTF_SCANF -o "c_golden_bootloader_avant.elf" $(OBJS) $(USER_OBJS) $(LIBS)
	@echo 'Finished building target: $@'
	@echo ' '

c_golden_bootloader_avant.lst: c_golden_bootloader_avant.elf makefile objects.mk $(OPTIONAL_TOOL_DEPS)
	@echo 'Invoking: GNU RISC-V Cross Create Listing'
	riscv-none-embed-objdump --source --all-headers --demangle --line-numbers --wide "c_golden_bootloader_avant.elf" > "c_golden_bootloader_avant.lst"
	@echo 'Finished building: $@'
	@echo ' '

c_golden_bootloader_avant.siz: c_golden_bootloader_avant.elf makefile objects.mk $(OPTIONAL_TOOL_DEPS)
	@echo 'Invoking: GNU RISC-V Cross Print Size'
	riscv-none-embed-size --format=berkeley "c_golden_bootloader_avant.elf"
	@echo 'Finished building: $@'
	@echo ' '

c_golden_bootloader_avant.mem: c_golden_bootloader_avant.elf makefile objects.mk $(OPTIONAL_TOOL_DEPS)
	@echo 'Invoking: Lattice Create Memory Deployment'
	riscv-none-embed-objcopy -O binary --gap-fill 0 "c_golden_bootloader_avant.elf" "c_golden_bootloader_avant.bin"; srec_cat "c_golden_bootloader_avant.bin" -Binary -byte-swap 4 -DISable Header -Output "c_golden_bootloader_avant.mem" -MEM 32
	@echo 'Finished building: $@'
	@echo ' '

# Other Targets
clean:
	-$(RM) $(SECONDARY_MEMORY)$(OBJS)$(SECONDARY_LIST)$(SECONDARY_SIZE)$(ASM_DEPS)$(S_UPPER_DEPS)$(C_DEPS) c_golden_bootloader_avant.elf
	-@echo ' '

secondary-outputs: $(SECONDARY_LIST) $(SECONDARY_SIZE) $(SECONDARY_MEMORY)

.PHONY: all clean dependents main-build

-include ../makefile.targets
