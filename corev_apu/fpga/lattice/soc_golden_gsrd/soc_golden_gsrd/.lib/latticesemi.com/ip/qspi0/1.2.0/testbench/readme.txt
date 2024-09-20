No flash simulation model is included on this IP package release. 

See below for the steps to simulate the QSPI Flash Controller IP with a Flash simulation model:
	
1. Check the flash model instantiation starting from tb_top.v line 357. Update this section as necessary. 
   Make sure that the ss_n_o signal is connected to the flash model being used.

2. Manually add the flash simulation model on the testbench folder.

3. For Winbond flash, .TXT files are needed on the simulation folder to enable simulation.

4. When running simulation through Radiant Simulation Wizard, edit the generated .mdo or .f file.
   On the vsim command, append +target_flash=target_flash_value.
   The current customer testbench supports Macronix and Winbond flash simulation.
   Set target_flash_value to 0 for Macronix and 1 for Winbond.
   
5. Re-run the simulation using the updated .mdo or .f file.
  