Steps to generate a standalone CVA6 RISCV for Lattice IP integration

1. Navigate to script folder and run "python merge-files.py"
2. Run "python replace-unsigned.py" to workaround Lattice tool constraint of unable to recognize "unsigned'" syntax
3. Run "python replace-error.py" to workaround Lattice tool constraint of unable to recognize multi line $error() syntax

Below are manual processes, lets see how to script these moving forward
4. Look for those `include string and replace those with file content. Or, add include path in Radiant project
5. File module ariane and replace below
module ariane import ariane_pkg::*; import cva6_config_pkg::*; #(
  parameter config_pkg::cva6_cfg_t CVA6Cfg = cva6_config_pkg::cva6_cfg,

6. Find eplace below and replace
  localparam CVA6ConfigAxiAddrWidth = 64;
  localparam CVA6ConfigAxiDataWidth = 64;
to 
  localparam CVA6ConfigAxiAddrWidth = 32;
  localparam CVA6ConfigAxiDataWidth = 32;

From here on, you'd be able to synthesize at least. You may use radiantproject folder's Radiant project as reference.