# Selecting the protocol define in the eval_top and tb_top
f_params = open('eval/dut_params.v', 'r')
sim_val = 0
intf_type = '`define '
pll_trefclk = 0.0
s_pll_trefclk = ""
while True:
    line = f_params.readline()
    str_spl = line.split(' ')
    val = str_spl[-1]
    param = str_spl[1]
    if param == 'SIM_VAL':
        pos = val.index(';')
        val = val[0:(pos)]
        print(param, ' = ', val)
        sim_val = int(val)
    if param == 'INTERFACE_TYPE':
        pos = val.index(';')
        val = val[1:(pos-1)]
        print(param, ' = ', val)
        intf_type = intf_type + val
    if param == 'REFCLK_FREQ':
        pos = val.index(';')
        val = val[0:(pos-1)]
        print(param, ' = ', val)
        pll_trefclk = 1000.0/float(val)
        s_pll_trefclk = f"{pll_trefclk:.3f}"
    if param == 'DATA_CLK_EN':
        pos = val.index(';')
        val = val[0:(pos)]
        print(param, ' = ', val)
        dataclk_en = int(val)
        break


# Adding the protocol define in the eval_top
with open('eval/eval_top.sv', 'r') as file :
  filedata = file.read()
  filedata = filedata.replace('//SELECT_PROTOCOL', intf_type)
  file.close()

with open('eval/eval_top.sv', 'w') as file:
  file.write(filedata)
  file.close()
  
# Adding the protocol define in the tb_top
with open('testbench/tb_top.sv', 'r') as file :
  filedata = file.read()
  filedata = filedata.replace('//SELECT_PROTOCOL', intf_type)
  file.close()

with open('testbench/tb_top.sv', 'w') as file:
  file.write(filedata)
  file.close()
  
# Setting correct PLL refclk value to clock_constraint.sdc
with open('eval/clock_constraint.sdc', 'r') as file :
  filedata = file.read()
  filedata = filedata.replace('PLL_REFCLK_PERIOD', s_pll_trefclk)
  file.close()

with open('eval/clock_constraint.sdc', 'w') as file:
  file.write(filedata)
  file.close()

# Removing CDC constrains for Bus I/F when DATA_CLK_EN=0
with open('eval/constraint.pdc', 'r') as file :
  filedata = file.read()
  if dataclk_en==1:
    filedata = filedata.replace('#For_AXI4_DATA_CLK_EN#', '')
  else:
    filedata = filedata.replace('#For_AXI4_DATA_CLK_EN#', '#')
  file.close()

with open('eval/constraint.pdc', 'w') as file:
  file.write(filedata)
  file.close()
  
if sim_val!=0:
  with open('eval/eval_top.sv', 'r') as file :
    filedata = file.read()
    filedata = filedata.replace('parameter SIM = 0', 'parameter SIM = 1')
    file.close()
  with open('eval/eval_top.sv', 'w') as file:
    file.write(filedata)  
    file.close()