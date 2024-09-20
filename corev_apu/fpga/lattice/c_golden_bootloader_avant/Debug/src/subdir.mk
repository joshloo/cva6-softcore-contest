################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/crc16.c \
../src/main.c \
../src/utils.c 

OBJS += \
./src/crc16.o \
./src/main.o \
./src/utils.o 

C_DEPS += \
./src/crc16.d \
./src/main.d \
./src/utils.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.c src/subdir.mk
	@echo 'Building file: $<'
	@echo 'Invoking: GNU RISC-V Cross C Compiler'
	riscv-none-embed-gcc -march=rv32imac -mabi=ilp32 -msmall-data-limit=8 -mno-save-restore -O0 -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections  -g3 -DLSCC_STDIO_UART_APB -I"C:\Users\SKothari\Downloads\GSRD2.0_Avant_CPNX_Beta\Final_Beta_Testing\golden_avant\c_golden_bootloader_avant/src" -I"C:\Users\SKothari\Downloads\GSRD2.0_Avant_CPNX_Beta\Final_Beta_Testing\golden_avant\c_golden_bootloader_avant/src/bsp" -I"C:\Users\SKothari\Downloads\GSRD2.0_Avant_CPNX_Beta\Final_Beta_Testing\golden_avant\c_golden_bootloader_avant/src/bsp/driver" -I"C:\Users\SKothari\Downloads\GSRD2.0_Avant_CPNX_Beta\Final_Beta_Testing\golden_avant\c_golden_bootloader_avant/src/bsp/driver/gpio" -I"C:\Users\SKothari\Downloads\GSRD2.0_Avant_CPNX_Beta\Final_Beta_Testing\golden_avant\c_golden_bootloader_avant/src/bsp/driver/mc_avant" -I"C:\Users\SKothari\Downloads\GSRD2.0_Avant_CPNX_Beta\Final_Beta_Testing\golden_avant\c_golden_bootloader_avant/src/bsp/driver/qspi_flash_controller" -I"C:\Users\SKothari\Downloads\GSRD2.0_Avant_CPNX_Beta\Final_Beta_Testing\golden_avant\c_golden_bootloader_avant/src/bsp/driver/riscv_rtos" -I"C:\Users\SKothari\Downloads\GSRD2.0_Avant_CPNX_Beta\Final_Beta_Testing\golden_avant\c_golden_bootloader_avant/src/bsp/driver/sgdma" -I"C:\Users\SKothari\Downloads\GSRD2.0_Avant_CPNX_Beta\Final_Beta_Testing\golden_avant\c_golden_bootloader_avant/src/bsp/driver/tse_mac" -I"C:\Users\SKothari\Downloads\GSRD2.0_Avant_CPNX_Beta\Final_Beta_Testing\golden_avant\c_golden_bootloader_avant/src/bsp/driver/uart" -std=gnu11 --specs=picolibc.specs -DPICOLIBC_INTEGER_PRINTF_SCANF -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


