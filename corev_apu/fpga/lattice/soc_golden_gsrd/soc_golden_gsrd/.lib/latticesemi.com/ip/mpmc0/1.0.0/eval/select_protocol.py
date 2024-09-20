import os

# Initialize flag to -1, meaning this is not an Avant device
isAvant = -1

# Parse through dut_params to determine if this is an Avant device
with open('eval/dut_params.v', 'r') as file :
    filedata = file.read()

    # If this is an Avant device, the assignment will 0 or more
    isAvant = filedata.find("LAV_AT")
file.close()

# Check if this is an Avant device
if isAvant==-1:
    # Not an Avant device. Means this is CPNX

    # Write the CPNX version of ldc
    with open('eval/mc_cpnx.ldc', 'r') as src:
        filedata = src.read()
    src.close()
    with open('eval/mc.ldc', 'w') as dst:
        dst.write(filedata)
    src.close()
    dst.close()

    # Write the CPNX version of pdc
    with open('eval/constraint_cpnx.pdc', 'r') as src :
        filedata = src.read()
    with open('eval/constraint.pdc', 'w') as dst:
        dst.write(filedata)
    src.close()
    dst.close()

    # Remove the macro indicating that it is an Avant device from both
    # tb_top and eval_top
    with open('testbench/tb_top.sv', 'r') as file :
        filedata = file.read()
        filedata = filedata.replace('//DEVICE_IS_AVANT', '')
    with open('testbench/tb_top.sv', 'w') as file:
        file.write(filedata)
    file.close()
    with open('eval/eval_top.sv', 'r') as file :
        filedata = file.read()
        filedata = filedata.replace('//DEVICE_IS_AVANT', '')
    with open('eval/eval_top.sv', 'w') as file:
        file.write(filedata)
    file.close()
else:
    # This is an Avant device

    # Write the Avant version of ldc
    with open('eval/mc_lav.ldc', 'r') as src :
        filedata = src.read()
    with open('eval/mc.ldc', 'w') as dst:
        dst.write(filedata)
    src.close()
    dst.close()

    # Write the Avant version of pdc
    with open('eval/constraint_avant.pdc', 'r') as src :
        filedata = src.read()
    with open('eval/constraint.pdc', 'w') as dst:
        dst.write(filedata)
    src.close()
    dst.close()

    # Insert the macro indicating that it is an Avant device to both
    # tb_top and eval_top
    with open('testbench/tb_top.sv', 'r') as file :
        filedata = file.read()
        filedata = filedata.replace('//DEVICE_IS_AVANT', '`define LAV_AT')
    with open('testbench/tb_top.sv', 'w') as file:
        file.write(filedata)
    file.close()
    with open('eval/eval_top.sv', 'r') as file :
        filedata = file.read()
        filedata = filedata.replace('//DEVICE_IS_AVANT', '`define LAV_AT')
    with open('eval/eval_top.sv', 'w') as file:
        file.write(filedata)
    file.close()

# Initialize flag to -1, meaning that the current Radiant version supports MC for Avant
isAvantVersionNotSupported = -1

# Get the filename of the IP RTL. There are only two files in this directory
# ip_name.sv or ip_name_bb.v. I'm going with the first, which is ip_name.sv
rtlpath = os.getcwd() + "/rtl/"
ipfile = os.listdir(rtlpath)[0]
ipfilepath = "rtl/" + ipfile
with open(ipfilepath, 'r') as file :
    filedata = file.read()

    # Search for the version at the top of this file. Radiant 2023.2+ supports MC for Avant
    # MPMC is supported on Radiant 2023.1, so we'll be checking if this is a 2023.1 version.
    # If yes, we want to stop the simulation from running
    isAvantVersionNotSupported = filedata.find("2023.1")
file.close()

# Insert or remove the macro indicating that MC for Avant is supported. Do this for
# both tb_top and eval_top
with open('eval/eval_top.sv', 'r') as file :
    filedata = file.read()
if isAvantVersionNotSupported==-1:
    filedata = filedata.replace('//IS_MC_LAV_SUPPORTED', '`define MC_LAV_SUPPORTED')
else:
    filedata = filedata.replace('//IS_MC_LAV_SUPPORTED', '')
with open('eval/eval_top.sv', 'w') as file:
    file.write(filedata)
file.close()

with open('testbench/tb_top.sv', 'r') as file :
    filedata = file.read()
if isAvantVersionNotSupported==-1:
    filedata = filedata.replace('//IS_MC_LAV_SUPPORTED', '`define MC_LAV_SUPPORTED')
else:
    filedata = filedata.replace('//IS_MC_LAV_SUPPORTED', '')
with open('testbench/tb_top.sv', 'w') as file:
    file.write(filedata)
file.close()

# Selecting the protocol define in the eval_top and tb_top
f_params = open('eval/dut_params.v', 'r')
cdc = -1
while True:
    line = f_params.readline()
    str_spl = line.split(' ')
    val = str_spl[-1]
    param = str_spl[1]
    if param == 'ENABLE_SI_CDC_TOP':
        pos = val.index('}')
        val = val[1:(pos)]
        print(param, ' = ', val)
        cdc = val.find("1'd1")
        break

# Add max delay constraints if applicable, else remove tag
with open('eval/constraint.pdc', 'r') as file :
    filedata = file.read()
if cdc==-1:
    filedata = filedata.replace('#MPMC_HEADER#', '')
    filedata = filedata.replace('#MPMC_MAX_DELAY_AW#', '')
    filedata = filedata.replace('#MPMC_MAX_DELAY_B#', '')
    filedata = filedata.replace('#MPMC_MAX_DELAY_AR#', '')
else:
    filedata = filedata.replace('#MPMC_HEADER#', '# The distributed RAM data output port to FIFO_DC data output register is already guaranteed by design. This constraint is to ensure they are close together')
    if isAvant==-1:
        filedata = filedata.replace('#MPMC_MAX_DELAY_AW#', 'set_max_delay -from [get_pins {*/lscc_mpmc_axi_inst/*u_fifo_intf/*.aw_mpmc_fifo/*async_fifo/u_fifo/u_fifo_dc/mem*.*_inst/WDO*}] -datapath_only 3.5')
        filedata = filedata.replace('#MPMC_MAX_DELAY_B#', 'set_max_delay -from [get_pins {*/lscc_mpmc_axi_inst/*u_fifo_intf/*.b_mpmc_fifo/*async_fifo/u_fifo/u_fifo_dc/mem*.*_inst/WDO*}] -datapath_only 3.5')
        filedata = filedata.replace('#MPMC_MAX_DELAY_AR#', 'set_max_delay -from [get_pins {*/lscc_mpmc_axi_inst/*u_fifo_intf/*.ar_mpmc_fifo/*async_fifo/u_fifo/u_fifo_dc/mem*.*_inst/WDO*}] -datapath_only 3.5')
    else:
        filedata = filedata.replace('#MPMC_MAX_DELAY_AW#', 'set_max_delay -from [get_pins {*/lscc_mpmc_axi_inst/*u_fifo_intf/*.aw_mpmc_fifo/*async_fifo/u_fifo/u_fifo_dc/mem_ram*.dpram_inst/DO*}] -datapath_only 2.5')
        filedata = filedata.replace('#MPMC_MAX_DELAY_B#', 'set_max_delay -from [get_pins {*/lscc_mpmc_axi_inst/*u_fifo_intf/*.b_mpmc_fifo/*async_fifo/u_fifo/u_fifo_dc/mem_ram*.dpram_inst/DO*}] -datapath_only 2.5')
        filedata = filedata.replace('#MPMC_MAX_DELAY_AR#', 'set_max_delay -from [get_pins {*/lscc_mpmc_axi_inst/*u_fifo_intf/*.ar_mpmc_fifo/*async_fifo/u_fifo/u_fifo_dc/mem_ram*.dpram_inst/DO*}] -datapath_only 2.5')

with open('eval/constraint.pdc', 'w') as file:
    file.write(filedata)
file.close()
