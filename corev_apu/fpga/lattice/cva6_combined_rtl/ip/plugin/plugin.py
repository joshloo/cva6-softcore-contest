import os
import string
import math
def diamond(device):
    if(device == "MachXO3D" or device == "MachXO3L" or device == "MachXO3LF" or device == "MachXO2" or device == "ECP5U" or device == "ECP5UM" or device == "ECP5UM5G"):
        return True
    return False
def cdc_editable(irq_num,comparison):
    ret = 0
    if (irq_num >= comparison):
        return 1
    return ret
def cdc_status_string(CDC_S2,CDC_S3,CDC_S4,CDC_S5,CDC_S6,CDC_S7,CDC_S8,CDC_S9,CDC_S10,CDC_S11,CDC_S12,CDC_S13,CDC_S14,CDC_S15,CDC_S16,CDC_S17,CDC_S18,CDC_S19,CDC_S20,CDC_S21,CDC_S22,CDC_S23,CDC_S24,CDC_S25,CDC_S26,CDC_S27,CDC_S28,
                     CDC_S29,CDC_S30,CDC_S31):
    status_str = '32\'b'+ str(int(CDC_S31 == True)) + str(int(CDC_S30 == True)) + str(int(CDC_S29 == True))+ str(int(CDC_S28 == True))+ str(int(CDC_S27 == True))\
    + str(int(CDC_S26 == True))+ str(int(CDC_S25 == True))+ str(int(CDC_S24 == True))+ str(int(CDC_S23 == True))+ str(int(CDC_S22 == True))+ str(int(CDC_S21 == True))\
    + str(int(CDC_S20 == True))+ str(int(CDC_S19 == True))+ str(int(CDC_S18 == True))+ str(int(CDC_S17 == True))+ str(int(CDC_S16 == True))+ str(int(CDC_S15 == True))\
    + str(int(CDC_S14== True))+ str(int(CDC_S13 == True))+ str(int(CDC_S12 == True))+ str(int(CDC_S11 == True))+ str(int(CDC_S10 == True))+ str(int(CDC_S9 == True))\
    + str(int(CDC_S8 == True))+ str(int(CDC_S7 == True))+ str(int(CDC_S6 == True))+ str(int(CDC_S5 == True))+ str(int(CDC_S4 == True))+ str(int(CDC_S3 == True))\
    + str(int(CDC_S2 == True))
    return status_str

def cfu_port_disable(cfu_en,ports, port_no):
    ret = 0
    if ((not cfu_en) or ports < port_no):
        return 1
    return ret

def not_enable(ports, port_no):
    ret = 0
    if (ports < port_no):
        return 1
    return ret

def get_device_name():
    x = runtime_info.device_info.architecture(1)
    if x in ("LIFCL", "LFD2NX", "LFCPNX","LFMXO5","jd5r00"):
        return "LIFCL"
    elif x in ("LATG1", "LAV-AT"):
        return "LAV-AT"
    elif x in ("ECP5U", "ECP5UM", "ECP5UM5G"):
        return "ECP5U"
    else:
        PluginUtil.post_error("the device is not supported.")
        return x
    
def get_invalid_addr_low(enable):
    ret = "32'h00000000"
    if (not enable):
       ret = "32'h00000000"
    return ret

def get_invalid_addr_high(enable):
    ret = "32'h40000000"
    if (not enable):
       ret = "32'h00000000"
    return ret

def set_env_cache(en):
    if(en):
        os.environ['cpu_cache'] = 'enabled'
    else:
        os.environ['cpu_cache'] = 'disabled'
    return True

def ext_check_instr_port(tcm_enable, instr_port_enable):
    if(tcm_enable == False and instr_port_enable == False):
        PluginUtil.post_error("Either TCM or Instruction Port has to be enabled.")
        return 0
    return 1


def ext_check_baud_rate(sys_clock_freq, desired_baud_rate, baud_rate_type):
    prescaler = (1000000.0 * sys_clock_freq) / desired_baud_rate
    if (prescaler > 65535):
        PluginUtil.post_error("UART %s Baud Rate cannot be achieved with that System Clock Frequency." % baud_rate_type)
        return 0
    elif (prescaler < 16):
        PluginUtil.post_error("UART %s Baud Rate must be at least 1/16th of System Clock Frequency." % baud_rate_type)
        return 0
    else:
        return 1

def check_uart_sim (uart_sim):
	if (uart_sim):
		PluginUtil.post_warning("ERROR -- Enabling UART SIM disables UART for hardware.")
		return 0
	return

def check_hex_format(width,hex_value):
 
   new_hex_value = check_value(hex_value)
 
   if(int_check_hex_val(hex_value)):
     return         PluginUtil.post_error("ERROR  -- Input should be in hexadecimal format!")
   if(math.trunc((width+3)/4) < len(new_hex_value)):
     return         PluginUtil.post_error("ERROR  -- Input has too many hex numbers!")
   if(sample(hex_value) > width):
     return         PluginUtil.post_error("ERROR  -- Out of Range!")
   else:
     return 1
   
def sample(hex_value):
   return (len(bin(int(hex_value,16))[2:]))
   
def check_value(input):
 
  if len(input)>1 and int(input,16)!=0:
    return input.lstrip('0')
  elif len(input)>1 and int(input,16)==0:
    return "0"
  else:
    return input
   
def int_check_hex_val(val):
 
  list = int_str_to_list(val.upper())
  ret  = 0
  for char in list:
    if (char not in ['0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F']):
      ret = 1
      break

def int_str_to_list(val):
 
  list = []
  ret  = 0
 
  for char in val:
    list += char
 
  return list
def check_value(input):

	if len(input)>1 and int(input,16)!=0:
	  return input.lstrip('0')
	elif len(input)>1 and int(input,16)==0:
	  return "0"
	else:
	  return input

def calc_initial_value(width, value):

   new_value = check_value(value)
   return (str(width)+"\'h"+new_value)

def axi_id_range(width):
    range = pow(2,width) -1
    return range