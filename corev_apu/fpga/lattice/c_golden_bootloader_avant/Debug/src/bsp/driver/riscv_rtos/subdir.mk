################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/bsp/driver/riscv_rtos/cache.c \
../src/bsp/driver/riscv_rtos/clint.c \
../src/bsp/driver/riscv_rtos/debug.c \
../src/bsp/driver/riscv_rtos/exception.c \
../src/bsp/driver/riscv_rtos/exit.c \
../src/bsp/driver/riscv_rtos/interrupt.c \
../src/bsp/driver/riscv_rtos/iob.c \
../src/bsp/driver/riscv_rtos/led.c \
../src/bsp/driver/riscv_rtos/local_uart.c \
../src/bsp/driver/riscv_rtos/plic.c \
../src/bsp/driver/riscv_rtos/pmp.c \
../src/bsp/driver/riscv_rtos/reg_access.c \
../src/bsp/driver/riscv_rtos/trap.c \
../src/bsp/driver/riscv_rtos/util.c \
../src/bsp/driver/riscv_rtos/watchdog_timer.c 

S_UPPER_SRCS += \
../src/bsp/driver/riscv_rtos/entry.S \
../src/bsp/driver/riscv_rtos/start.S 

OBJS += \
./src/bsp/driver/riscv_rtos/cache.o \
./src/bsp/driver/riscv_rtos/clint.o \
./src/bsp/driver/riscv_rtos/debug.o \
./src/bsp/driver/riscv_rtos/entry.o \
./src/bsp/driver/riscv_rtos/exception.o \
./src/bsp/driver/riscv_rtos/exit.o \
./src/bsp/driver/riscv_rtos/interrupt.o \
./src/bsp/driver/riscv_rtos/iob.o \
./src/bsp/driver/riscv_rtos/led.o \
./src/bsp/driver/riscv_rtos/local_uart.o \
./src/bsp/driver/riscv_rtos/plic.o \
./src/bsp/driver/riscv_rtos/pmp.o \
./src/bsp/driver/riscv_rtos/reg_access.o \
./src/bsp/driver/riscv_rtos/start.o \
./src/bsp/driver/riscv_rtos/trap.o \
./src/bsp/driver/riscv_rtos/util.o \
./src/bsp/driver/riscv_rtos/watchdog_timer.o 

S_UPPER_DEPS += \
./src/bsp/driver/riscv_rtos/entry.d \
./src/bsp/driver/riscv_rtos/start.d 

C_DEPS += \
./src/bsp/driver/riscv_rtos/cache.d \
./src/bsp/driver/riscv_rtos/clint.d \
./src/bsp/driver/riscv_rtos/debug.d \
./src/bsp/driver/riscv_rtos/exception.d \
./src/bsp/driver/riscv_rtos/exit.d \
./src/bsp/driver/riscv_rtos/interrupt.d \
./src/bsp/driver/riscv_rtos/iob.d \
./src/bsp/driver/riscv_rtos/led.d \
./src/bsp/driver/riscv_rtos/local_uart.d \
./src/bsp/driver/riscv_rtos/plic.d \
./src/bsp/driver/riscv_rtos/pmp.d \
./src/bsp/driver/riscv_rtos/reg_access.d \
./src/bsp/driver/riscv_rtos/trap.d \
./src/bsp/driver/riscv_rtos/util.d \
./src/bsp/driver/riscv_rtos/watchdog_timer.d 


# Each subdirectory must supply rules for building sources it contributes
src/bsp/driver/riscv_rtos/%.o: ../src/bsp/driver/riscv_rtos/%.c src/bsp/driver/riscv_rtos/subdir.mk
	@echo 'Building file: $<'
	@echo 'Invoking: GNU RISC-V Cross C Compiler'
	riscv-none-embed-gcc -march=rv32imac -mabi=ilp32 -msmall-data-limit=8 -mno-save-restore -O0 -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections  -g3 -DLSCC_STDIO_UART_APB -I"C:\Users\SKothari\Downloads\GSRD2.0_Avant_CPNX_Beta\Final_Beta_Testing\golden_avant\c_golden_bootloader_avant/src" -I"C:\Users\SKothari\Downloads\GSRD2.0_Avant_CPNX_Beta\Final_Beta_Testing\golden_avant\c_golden_bootloader_avant/src/bsp" -I"C:\Users\SKothari\Downloads\GSRD2.0_Avant_CPNX_Beta\Final_Beta_Testing\golden_avant\c_golden_bootloader_avant/src/bsp/driver" -I"C:\Users\SKothari\Downloads\GSRD2.0_Avant_CPNX_Beta\Final_Beta_Testing\golden_avant\c_golden_bootloader_avant/src/bsp/driver/gpio" -I"C:\Users\SKothari\Downloads\GSRD2.0_Avant_CPNX_Beta\Final_Beta_Testing\golden_avant\c_golden_bootloader_avant/src/bsp/driver/mc_avant" -I"C:\Users\SKothari\Downloads\GSRD2.0_Avant_CPNX_Beta\Final_Beta_Testing\golden_avant\c_golden_bootloader_avant/src/bsp/driver/qspi_flash_controller" -I"C:\Users\SKothari\Downloads\GSRD2.0_Avant_CPNX_Beta\Final_Beta_Testing\golden_avant\c_golden_bootloader_avant/src/bsp/driver/riscv_rtos" -I"C:\Users\SKothari\Downloads\GSRD2.0_Avant_CPNX_Beta\Final_Beta_Testing\golden_avant\c_golden_bootloader_avant/src/bsp/driver/sgdma" -I"C:\Users\SKothari\Downloads\GSRD2.0_Avant_CPNX_Beta\Final_Beta_Testing\golden_avant\c_golden_bootloader_avant/src/bsp/driver/tse_mac" -I"C:\Users\SKothari\Downloads\GSRD2.0_Avant_CPNX_Beta\Final_Beta_Testing\golden_avant\c_golden_bootloader_avant/src/bsp/driver/uart" -std=gnu11 --specs=picolibc.specs -DPICOLIBC_INTEGER_PRINTF_SCANF -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

src/bsp/driver/riscv_rtos/%.o: ../src/bsp/driver/riscv_rtos/%.S src/bsp/driver/riscv_rtos/subdir.mk
	@echo 'Building file: $<'
	@echo 'Invoking: GNU RISC-V Cross Assembler'
	riscv-none-embed-gcc -march=rv32imac -mabi=ilp32 -msmall-data-limit=8 -mno-save-restore -O0 -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections  -g3 -x assembler-with-cpp -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


