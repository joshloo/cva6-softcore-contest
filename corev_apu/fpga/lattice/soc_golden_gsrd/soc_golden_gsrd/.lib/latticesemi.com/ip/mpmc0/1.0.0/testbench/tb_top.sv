// =============================================================================
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
// -----------------------------------------------------------------------------
//   Copyright (c) 2019 by Lattice Semiconductor Corporation
//   ALL RIGHTS RESERVED
// -----------------------------------------------------------------------------
//
//   Permission:
//
//      Lattice SG Pte. Ltd. grants permission to use this code
//      pursuant to the terms of the Lattice Reference Design License Agreement.
//
//
//   Disclaimer:
//
//      This VHDL or Verilog source code is intended as a design reference
//      which illustrates how these types of functions can be implemented.
//      It is the user's responsibility to verify their design for
//      consistency and functionality through the use of formal
//      verification methods.  Lattice provides no warranty
//      regarding the use or functionality of this code.
//
// -----------------------------------------------------------------------------
//
//                  Lattice SG Pte. Ltd.
//                  101 Thomson Road, United Square #07-02
//                  Singapore 307591
//
//
//                  TEL: 1-800-Lattice (USA and Canada)
//                       +65-6631-2000 (Singapore)
//                       +1-503-268-8001 (other locations)
//
//                  web: http://www.latticesemi.com/
//                  email: techsupport@latticesemi.com
//
// -----------------------------------------------------------------------------
//
// =============================================================================
//                         FILE DETAILS
// Project               :
// File                  : tb_top.v
// Title                 :
// Dependencies          :
// Description           : Simple test for MC_Avant
// =============================================================================
//                        REVISION HISTORY
// Version               : 1.0.0.
// Author(s)             :
// Mod. Date             : 11.07.2019
// Changes Made          : Initial release.
// =============================================================================
`define LPDDR4
`define LAV_AT

// Uncomment this define to speed-up simulation in RTL (not Post-Synthesis/P&R)
`define RTL_SIM
//`define C_DEBUG_EN

`ifdef LPDDR4
  `include "lpddr4/z19m_2gx16_4266_20210604_ms.svp"
`endif

`timescale 1 ps / 1 ps
`include "debug_c_code.sv"

`ifdef LAV_AT
  module tb_top ();
  `include "dut_params.v"
  `include "avant_mc_params.v"
  `define MC_LAV_SUPPORTED
  
  localparam PLL_REFCLK_PERIOD      = 1000000/REFCLK_FREQ;
  localparam PLL_REFCLK_HALFPERIOD  = PLL_REFCLK_PERIOD/2;
  localparam ACLK_PERIOD            = 1000000/150;
  localparam ACLK_HALFPERIOD        = ACLK_PERIOD/2;
  localparam TB_TIMEOUT             = 30000 * 6;

  logic                  clk_i       ;
  logic                  rstn_i      ;
  logic                  pll_refclk_i;
  logic                  uart_rxd_i  ;
  logic                  uart_txd_o  ;
  wire  [11:0]           LED         ;
  logic                  irq_out     ;
  logic                  sim_o       ;

  // LPDDR4 Interface
  logic [CK_WIDTH-1:0]         ddr_ck_o     ;
  logic [CK_WIDTH-1:0]         ddr_ck_c     ;
  logic [CK_WIDTH-1:0]         ddr_cke_o    ;
  logic [CS_WIDTH-1:0]         ddr_cs_o     ;
  logic [CA_WIDTH-1:0]         ddr_ca_o     ;
  //logic [BA_WIDTH-1:0]         ddr_ba_o     ;
  //logic [BG_WIDTH-1:0]         ddr_bg_o     ;
  logic                        ddr_ras_n_o  ;
  logic                        ddr_cas_n_o  ;
  logic                        ddr_we_n_o   ;
  logic                        ddr_act_n_o  ;
  logic [ODT_WIDTH-1:0]        ddr_odt_o    ;
  logic                        ddr_reset_n_o;
  wire  [BUS_WIDTH-1:0]        ddr_dq_io    ;
  wire  [DQS_WIDTH-1:0]        ddr_dqs_io   ;
  wire  [DQS_WIDTH-1:0]        ddr_dqs_c    ;
  wire  [DQS_WIDTH-1:0]        ddr_dmi_io   ;

  initial begin
      pll_refclk_i   = 1;
      forever pll_refclk_i = #(PLL_REFCLK_HALFPERIOD) ~pll_refclk_i;
  end

  initial begin
      clk_i   = 1;
      forever clk_i = #(ACLK_HALFPERIOD) ~clk_i;
  end


  initial begin
    rstn_i    = 1;
    #(PLL_REFCLK_HALFPERIOD*2);
    rstn_i    = 0;
    #(PLL_REFCLK_HALFPERIOD*40);
    rstn_i     = 1;

    @(posedge u_eval_top.init_done_o);
    $display("INIT_DONE asserted!");
  end

  assign uart_rxd_i = 1'b1;

  assign ddr_dqs_c  = ~ddr_dqs_io;

  reg [100*8-1:0] gpio_msg;
  reg [100 : 0]   gpio_array [1:0];
  int x ;

  initial begin
  //  idx_msg  = 0;
  x = 0;
    gpio_msg = {(100*8){1'b0}};
  end

  always @(LED[8]) begin : print_messages
    #1;  // add some delay before capturing signals
    if (LED[9]) begin // GPIO sends string message
  //    gpio_msg[idx_msg*8+:8] = LED[7:0];
  //    idx_msg = idx_msg + 1;
      gpio_msg = {gpio_msg[99*8-1:0], LED[7:0]};  // Push the message to match the order in C-Code
      if (LED[7:0] == 0) begin                    // NULL character is received
        if (gpio_msg[15:8] != 8'h00)  begin           // gpio_msg has content
          //$display("%0d [TB_TOP]: %0s", $time, gpio_msg);
          gpio_array[x] = gpio_msg;
          if(x == 0)
            $display("%0d [TB_TOP] Bus efficiency : %0s", $time, gpio_array[x]);
          else if(x == 1)
            $display("%0d [TB_TOP] Mbps: %0s", $time, gpio_array[x]);
          x++;
        end

        #1;
  //      idx_msg  = 0;
        gpio_msg = {(100*8){1'b0}};
      end
    end
  end

  `ifdef RTL_SIM
  eval_top #(.SIM(1)) u_eval_top(
  `else
  eval_top u_eval_top(
  `endif
  //  .clk_i         (clk_i        ),
    .rstn_i        (rstn_i       ),
    .pll_refclk_i  (pll_refclk_i ),
    .uart_rxd_i    (uart_rxd_i   ),
    .uart_txd_o    (uart_txd_o   ),
    .LED           (LED          ),
  // .irq_out       (irq_out      ),
    .sim_o         (sim_o        ),
    .ddr_ck_o      (ddr_ck_o     ),
    .ddr_cke_o     (ddr_cke_o    ),
    .ddr_cs_o      (ddr_cs_o     ),
    .ddr_ca_o      (ddr_ca_o     ),
    .ddr_odt_ca_o  (ddr_odt_ca_o ),
    .ddr_reset_n_o (ddr_reset_n_o),
    .ddr_dq_io     (ddr_dq_io    ),
    .ddr_dqs_io    (ddr_dqs_io   ),
    .ddr_dmi_io    (ddr_dmi_io   )
  );
  /////////////////////////////////////////////////////////////////////
  logic done_rd,done_pulse,done_wr,done_wr_pulse;
  logic led_r,led_r1,led_rd,led_rd_1;
  logic flag_test_done,flag_test_done_r;
  logic stream_valid_r, stream_valid_r1,stream_valid_r2;
  int i = 1;
  int xx;
  logic pwr_pulse;
  logic t_done;
  logic t_done_r;
  logic t_done_r1;
  logic done_pulse_r;
  logic [31:0] duration_cnt;
  logic [31:0] num_wr_rd ;
  logic [31:0] led_bytes_concat;
  logic [31:0] num_pass,num_fail;
  int j,wc;
  assign done_wr = LED[3] & LED[2] & !LED[9]; //&& !LED[7];
  assign done_rd = LED[3] & !LED[2] & !LED[9];
  assign flag_test_done = LED[6] && !LED[9]  ;

  always_ff @(posedge pll_refclk_i or negedge rstn_i) begin
    if(!rstn_i) begin
      led_r                 <= 0;
      led_rd                <= 0;
      led_r1                <= 0;
      led_rd_1              <= 0;
      flag_test_done_r      <= 0;
      t_done_r              <= 0;
      t_done_r1             <= 0;
      num_pass              <= 0;
      num_fail              <= 0;

    end
    else begin
      led_r1               <= led_r;
      led_r                <= done_wr;
      led_rd_1             <= led_rd;
      led_rd               <= done_rd;
      flag_test_done_r     <= flag_test_done;
      t_done_r             <= t_done;
      t_done_r1            <= t_done_r;
      if(ddr_reset_n_o) begin
        num_pass             <= (LED[9] == 0 & done_pulse & LED[4] == 0 & LED[2] == 0 & u_eval_top.init_done_o ) ? num_pass + 1 : num_pass ;
        num_fail             <= (LED[9] == 0 & done_pulse & LED[4] == 1 & LED[2] == 0 & u_eval_top.init_done_o ) ? num_fail + 1 : num_fail ;
      end
      else begin
        num_pass              <= 0;
        num_fail              <= 0;
      end
    end
  end

  assign done_pulse = (led_r & ~led_r1 | led_rd & ~led_rd_1) ;
  assign done_wr_pulse = (led_r & ~led_r1);
  assign t_done     = flag_test_done & ~flag_test_done_r;
  initial begin // {
    repeat (500) @(posedge pll_refclk_i);
    `ifdef MC_LAV_SUPPORTED
      `ifdef RTL_SIM
        force `DUT_INST_NAME.lscc_mc_avant_inst.u_ddrphy.i_csr.reset_reg = 1'b1;
        force `DUT_INST_NAME.lscc_mc_avant_inst.u_ddrphy.i_csr.trn_operation_reg = 8'h1E;
      `endif
    `endif
  `ifdef RE_RESET
    for( xx = 0; xx <= 1; xx++) begin
  `endif
    @(posedge pll_refclk_i);
    if (sim_o == 1'b0) begin
      $error("\n\n%0d [TB_TOP] Simulation with eval_top.SIM=0 is not supported due to extremely long simulation time.", $time);
      $display("[TB_TOP] RTL simulation, please uncomment this line in tb_top: `define RTL_SIM");
      $display("[TB_TOP] For post-Synthesis and post-P&R simulations, please set eval_top.SIM=1");
      $display("SIMULATION FAILED");
      $finish;
    end
    
    `ifndef MC_LAV_SUPPORTED
      $error("\n\n%0d [TB_TOP] Simulation with Memory Controller for Avant Devices version 1.3.0.", $time);
      $display("[TB_TOP] Requirement: Radiant 2023.2 and above.");
      $display("SIMULATION Terminated");
      $finish;
    `endif
    
    if(~&ACCESS_MODE_TOP) begin
      $error("\n\n%0d [TB_TOP] Simulation Read & Write access mode. Read Only and Write Only modes are not supported.", $time);
      $display("[TB_TOP] Please change the access mode configuration to Read and Write.");
      $display("SIMULATION FAILED");
      $finish;
    end
    
    @(posedge u_eval_top.init_done_o);
    $display("%0d [TB_TOP] Initialization and Training Done",$time);

    repeat (100) @(posedge pll_refclk_i);
  //  num_pass = 0;
  //  num_fail = 0;
    j = 0;
    wc = 0;
    $display("Waiting for the posedge of the ddr_dqs_t");
    @(posedge ddr_dqs_io[0]);
    $display("Found the dqs toggle");
    while(i > 0) begin  // {
      @(posedge pll_refclk_i);
      if(LED[9] == 0) begin // {
        if(t_done_r1) begin // {
          i = 0;
          $display("END_OF_SIMULATION");
          break;
        end // }
        else begin // {
          if(done_pulse) begin // {
              if((LED[2] == 1) & !LED[9]) begin // {
                $display("%0d [TB_TOP] Run : %0d ",$time,j);
                burst_type(done_wr_pulse,j);
                j = j + 1;
                $display("%0d [TB_TOP] Write Done",$time);
              end // }
              else  begin // {
                if((LED[4] == 0) & !LED[9]) begin  // {
                  $display("%0d [TB_TOP] Read Done : Data Compare Pass",$time);
                  //num_pass = num_pass + 1;
                  continue;
                end // }
                else begin // {
                  $error("%0d [TB_TOP] Read Done : Data Compare Fail", $time);
                  //num_fail = num_fail + 1;
                  $display(" %0d [TB_TOP] Test number :  %0d" , $time,num_fail);
                  continue;
                end  // }
              end // }
          end // }
        end // }
        i = 1;
      end // }
    end  // }
    @(posedge pll_refclk_i);
    @(posedge pll_refclk_i);
    $display("Out side the loop");
    $display("//////////////////////////SUMMARY/////////////////////");
    if(num_fail!=0) begin
      $display("FAILED_RUNS : %d",num_fail);
      $error("SIMULATION FAILED");
    end
    else begin
      $display("PASSED_RUNS : %d",num_pass);
      $display("SIMULATION PASSED");
    end
    $display("//////////////////////////////////////////////////////");
    `ifdef RE_RESET
    @(posedge pll_refclk_i);
        #50;
    if(xx < 1) begin
        #(PLL_REFCLK_HALFPERIOD*2);
        rstn_i     = 0;
      @(posedge pll_refclk_i);
        #(PLL_REFCLK_HALFPERIOD*20);
        #(PLL_REFCLK_HALFPERIOD*40);
        rstn_i     = 1;
        i = 1;
      $display("RE_RESET done here");
    end
    end
    `endif

    $finish;
  end // }

  task burst_type(input int done_wr_pulse, input int wc);
    if(done_wr_pulse) begin
      if(wc == 0)  $display("%0d [TB_TOP] Single INCR2", $time);
      else if(wc == 1)  $display("%0d [TB_TOP] INCR2 " , $time);
      else if(wc == 2)  $display("%0d [TB_TOP] INCR4 " , $time);
      else if(wc == 3)  $display("%0d [TB_TOP] INCR8 " , $time);
      else if(wc == 4)  $display("%0d [TB_TOP] INCR8 with Delay" , $time);
      else if(wc == 5)  $display("%0d [TB_TOP] INCR64",$time);
      else if(wc == 6)  $display("%0d [TB_TOP] PERFORMANCE TEST WITH INCR64",$time);
    end
  endtask

  `ifdef MC_LAV_SUPPORTED
    // This instance is only for single rank
    `ifdef LPDDR4
      `include "lpddr4/lpddr4_memory_instance.vh"
    `endif
  `endif

  ///////////////////// GSR /////////////////////
  reg gsr_clk;
  initial begin
    gsr_clk = 0;
    forever gsr_clk = #2500 ~gsr_clk; // 200MHz
  end

  SGSR GSR_INST (.GSR_N(1'b1), .CLK(gsr_clk));
  ///////////////////// END OF GSR ////////////


  initial begin
    repeat (TB_TIMEOUT) @(posedge pll_refclk_i);
    $display ("============TestBench INFO: SIMULATION TIMEOUT=============");
    $stop;
  end

  // For C-Code debugging
  `ifdef C_DEBUG_EN
  localparam   ASSERT_ADDR = 32'h103F6;
  localparam   GOOD_CODE   = 32'h600DF00D;

  logic [31:0] cpu_ahbl_m1_haddr    ;
  logic [1:0]  cpu_ahbl_m1_htrans   ;
  logic [31:0] cpu_ahbl_m1_hwdata   ;
  logic        cpu_ahbl_m1_hwrite   ;
  logic        cpu_ahbl_m1_hreadyout;
  logic        PCLK_c   ;
  logic        PRESETn_c;

  `ifdef MC_LAV_SUPPORTED
    assign cpu_ahbl_m1_haddr     = `DUT_INST_NAME.lscc_mc_avant_inst.u_ddrphy.i_cpu_grp.i_cpu_AHBL_M1_DATA_interconnect_HADDR_interconnect;
    assign cpu_ahbl_m1_htrans    = `DUT_INST_NAME.lscc_mc_avant_inst.u_ddrphy.i_cpu_grp.i_cpu_AHBL_M1_DATA_interconnect_HTRANS_interconnect;
    assign cpu_ahbl_m1_hwdata    = `DUT_INST_NAME.lscc_mc_avant_inst.u_ddrphy.i_cpu_grp.i_cpu_AHBL_M1_DATA_interconnect_HWDATA_interconnect;
    assign cpu_ahbl_m1_hwrite    = `DUT_INST_NAME.lscc_mc_avant_inst.u_ddrphy.i_cpu_grp.i_cpu_AHBL_M1_DATA_interconnect_HWRITE_interconnect;
    assign cpu_ahbl_m1_hreadyout = `DUT_INST_NAME.lscc_mc_avant_inst.u_ddrphy.i_cpu_grp.i_cpu_AHBL_M1_DATA_interconnect_HREADYOUT_interconnect;
    assign PCLK_c                = `DUT_INST_NAME.lscc_mc_avant_inst.u_ddrphy.i_cpu_grp.clk_i    ;
    assign PRESETn_c             = `DUT_INST_NAME.lscc_mc_avant_inst.u_ddrphy.i_cpu_grp.rst_n_i  ;
  `endif

  debug_c_code #(
    .DDR_TYPE     (1          ), // LPDDR4
    .ASSERT_ADDR  (ASSERT_ADDR),
    .GOOD_CODE    (GOOD_CODE  )
  )
  i_dbg_c(
    .clk_i        (PCLK_c               ),
    .rst_i        (PRESETn_c            ),
    .cpu_addr     (cpu_ahbl_m1_haddr    ),
    .cpu_htrans   (cpu_ahbl_m1_htrans   ),
    .cpu_hwrite   (cpu_ahbl_m1_hwrite   ),
    .training_done(training_done        ),
    .cpu_hwdata   (cpu_ahbl_m1_hwdata   ),
    .cpu_hreadyout(cpu_ahbl_m1_hreadyout)
  );

  //----------------------------------------------------
    // PRINT STATEMENTS FOR THE PHY
    //----------------------------------------------------
    logic axb_ready;
    logic axb_write;
    logic axb_sel  ;
    logic [8:0] axb_addr;
    logic [31:0] axb_rdata;
    logic [31:0] axb_wdata;
    `ifdef MC_LAV_SUPPORTED
      `ifdef LPDDR4
      generate
        if(DDR_WIDTH == 16) begin
          assign axb_sel   = `DUT_INST_NAME.lscc_mc_avant_inst.u_ddrphy.LP4_x16.u_ddrphy.AXB_SEL;
          assign axb_ready = `DUT_INST_NAME.lscc_mc_avant_inst.u_ddrphy.LP4_x16.u_ddrphy.AXB_READY;
          assign axb_write = `DUT_INST_NAME.lscc_mc_avant_inst.u_ddrphy.LP4_x16.u_ddrphy.AXB_WRITE;
          assign axb_addr  = `DUT_INST_NAME.lscc_mc_avant_inst.u_ddrphy.LP4_x16.u_ddrphy.AXB_ADDR ;
          assign axb_wdata = `DUT_INST_NAME.lscc_mc_avant_inst.u_ddrphy.LP4_x16.u_ddrphy.AXB_WDATA;
          assign axb_rdata = `DUT_INST_NAME.lscc_mc_avant_inst.u_ddrphy.LP4_x16.u_ddrphy.AXB_RDATA;
        end
        else if(DDR_WIDTH == 32) begin
          assign axb_sel   = `DUT_INST_NAME.lscc_mc_avant_inst.u_ddrphy.LP4_x32.u_ddrphy.AXB_SEL;
          assign axb_ready = `DUT_INST_NAME.lscc_mc_avant_inst.u_ddrphy.LP4_x32.u_ddrphy.AXB_READY;
          assign axb_write = `DUT_INST_NAME.lscc_mc_avant_inst.u_ddrphy.LP4_x32.u_ddrphy.AXB_WRITE;
          assign axb_addr  = `DUT_INST_NAME.lscc_mc_avant_inst.u_ddrphy.LP4_x32.u_ddrphy.AXB_ADDR ;
          assign axb_wdata = `DUT_INST_NAME.lscc_mc_avant_inst.u_ddrphy.LP4_x32.u_ddrphy.AXB_WDATA;
          assign axb_rdata = `DUT_INST_NAME.lscc_mc_avant_inst.u_ddrphy.LP4_x32.u_ddrphy.AXB_RDATA;
        end
        else begin
          assign axb_sel   = `DUT_INST_NAME.lscc_mc_avant_inst.u_ddrphy.LP4_x64.u_ddrphy.AXB_SEL;
          assign axb_ready = `DUT_INST_NAME.lscc_mc_avant_inst.u_ddrphy.LP4_x64.u_ddrphy.AXB_READY;
          assign axb_write = `DUT_INST_NAME.lscc_mc_avant_inst.u_ddrphy.LP4_x64.u_ddrphy.AXB_WRITE;
          assign axb_addr  = `DUT_INST_NAME.lscc_mc_avant_inst.u_ddrphy.LP4_x64.u_ddrphy.AXB_ADDR ;
          assign axb_wdata = `DUT_INST_NAME.lscc_mc_avant_inst.u_ddrphy.LP4_x64.u_ddrphy.AXB_WDATA;
          assign axb_rdata = `DUT_INST_NAME.lscc_mc_avant_inst.u_ddrphy.LP4_x64.u_ddrphy.AXB_RDATA;

        end
      endgenerate
      `endif
    
      always begin
        @(posedge PCLK_c);
        if(axb_sel & axb_ready) begin
          if(axb_write) begin
            $display("Writing at phy address 0x%02x, value 0x%08x", (axb_addr >> 2), axb_wdata);
          end
          else begin
            $display ("Read from phy address 0x%02x, value 0x%08x", (axb_addr >> 2), axb_rdata);
          end
        end
        else if (`DUT_INST_NAME.init_done_o == 1) begin
          break ;
        end
      end
    `endif
  `endif
  endmodule
`else
  module tb_top ();
  `include "dut_params.v"
  `include "cpnx_mc_params.v"

  localparam PLL_REFCLK_PERIOD      = 1000000/CLKI_FREQ;
  localparam PLL_REFCLK_HALFPERIOD  = PLL_REFCLK_PERIOD/2;
  localparam ACLK_PERIOD            = 1000000/150;
  localparam ACLK_HALFPERIOD        = ACLK_PERIOD/2;
  localparam TB_TIMEOUT             = 30000 * 6;

  //logic                  clk_i       ;
  logic                  rstn_i      ;
  logic                  pll_refclk_i;
  logic                  uart_rxd_i  ;
  logic                  uart_txd_o  ;
  wire  [9:0]            LED         ;
  logic                  irq_out     ;
  logic                  sim_o       ;
  logic                  init_done_o ;
  // LPDDR4 Interface
  //logic [CK_WIDTH-1:0]         ddr_ck_t_o   ;
  //logic [CK_WIDTH-1:0]         ddr_ck_c_o   ;
  logic [CK_WIDTH-1:0]         ddr_ck_o     ;
  logic [CK_WIDTH-1:0]         ddr_cke_o    ;
  logic [CS_WIDTH-1:0]         ddr_cs_o     ;
  logic [CA_WIDTH-1:0]         ddr_ca_o     ;
  //logic [BA_WIDTH-1:0]         ddr_ba_o     ;
  //logic [BG_WIDTH-1:0]         ddr_bg_o     ;
  logic                        ddr_ras_n_o  ;
  logic                        ddr_cas_n_o  ;
  logic                        ddr_we_n_o   ;
  logic                        ddr_act_n_o  ;
  logic [ODT_WIDTH-1:0]        ddr_odt_o    ;
  logic                        ddr_reset_n_o;
  wire  [BUS_WIDTH-1:0]        ddr_dq_io    ;
  wire  [DQS_WIDTH-1:0]        ddr_dqs_io   ;
  wire  [DQS_WIDTH-1:0]        ddr_dqs_c    ;
  wire  [DQS_WIDTH-1:0]        ddr_dmi_io   ;

  initial begin
      pll_refclk_i   = 1;
      forever pll_refclk_i = #(PLL_REFCLK_HALFPERIOD) ~pll_refclk_i;
  end

  //initial begin
  //    clk_i   = 1;
  //    forever clk_i = #(ACLK_HALFPERIOD) ~clk_i;
  //end


  initial begin
    rstn_i    = 1;
    #(PLL_REFCLK_HALFPERIOD*2);
    rstn_i    = 0;
    #(PLL_REFCLK_HALFPERIOD*40);
    rstn_i     = 1;

    @(posedge init_done_o);
    $display("INIT_DONE asserted!");
  end

  assign uart_rxd_i = 1'b1;

  assign ddr_dqs_c  = ~ddr_dqs_io;


  reg [100*8-1:0] gpio_msg;
  reg [100 : 0]   gpio_array [1:0];
  int x ;
  //reg [6:0]       idx_msg;

  initial begin
  //  idx_msg  = 0;
  x = 0;
    gpio_msg = {(100*8){1'b0}};
  end

  always @(LED[8]) begin : print_messages
    #1;  // add some delay before capturing signals
    if (LED[9]) begin // GPIO sends string message
  //    gpio_msg[idx_msg*8+:8] = LED[7:0];
  //    idx_msg = idx_msg + 1;
      gpio_msg = {gpio_msg[99*8-1:0], LED[7:0]};  // Push the message to match the order in C-Code
      if (LED[7:0] == 0) begin                    // NULL character is received
        if (gpio_msg[15:8] != 8'h00)  begin           // gpio_msg has content
          //$display("%0d [TB_TOP]: %0s", $time, gpio_msg);
          gpio_array[x] = gpio_msg;
          if(x == 0)
            $display("%0d [TB_TOP] Bus efficiency : %0s", $time, gpio_array[x]);
          else if(x == 1)
            $display("%0d [TB_TOP] Mbps: %0s", $time, gpio_array[x]);
          x++;
        end

        #1;
  //      idx_msg  = 0;
        gpio_msg = {(100*8){1'b0}};
      end
    end
  end

  `ifdef RTL_SIM
  eval_top #(
    .SIM(1)
  )
  u_eval_top(
  `else
  eval_top u_eval_top(
  `endif
  //  .clk_i         (clk_i        ),
    .rstn_i        (rstn_i       ),
    .pll_refclk_i  (pll_refclk_i ),
    .uart_rxd_i    (uart_rxd_i   ),
    .uart_txd_o    (uart_txd_o   ),
    .LED           (LED          ),
  // .irq_out       (irq_out      ),
    .sim_o         (sim_o        ),
    .init_done_o   (init_done_o  ),
  //  .ddr_ck_t_o    (ddr_ck_t_o   ),
  //  .ddr_ck_c_o    (ddr_ck_c_o   ),
    .ddr_ck_o      (ddr_ck_o     ),
    .ddr_cke_o     (ddr_cke_o    ),
    .ddr_cs_o      (ddr_cs_o     ),
    .ddr_ca_o      (ddr_ca_o     ),
    .ddr_odt_ca_o  (ddr_odt_ca_o ),
    .ddr_reset_n_o (ddr_reset_n_o),
    .ddr_dq_io     (ddr_dq_io    ),
    .ddr_dqs_io    (ddr_dqs_io   ),
    .ddr_dmi_io    (ddr_dmi_io   )
  );
  /////////////////////////////////////////////////////////////////////
  logic done_rd,done_pulse,done_wr,done_wr_pulse;
  logic led_r,led_r1,led_rd,led_rd_1;
  logic flag_test_done,flag_test_done_r;
  logic stream_valid_r, stream_valid_r1,stream_valid_r2;
  int i = 1;
  logic pwr_pulse;
  logic t_done;
  logic t_done_r;
  logic t_done_r1;
  logic done_pulse_r;
  logic [31:0] duration_cnt;
  logic [31:0] num_wr_rd ;
  logic [31:0] led_bytes_concat;
  logic [31:0] num_pass,num_fail;
  int j,wc;
  assign done_wr = LED[3] & LED[2] & !LED[9]; //&& !LED[7];
  assign done_rd = LED[3] & !LED[2] & !LED[9];
  assign flag_test_done = LED[6] && !LED[9]  ;

  always_ff @(posedge pll_refclk_i or negedge rstn_i) begin
    if(!rstn_i) begin
      led_r                 <= 0;
      led_rd                <= 0;
      led_r1                <= 0;
      led_rd_1              <= 0;
      flag_test_done_r      <= 0;
      t_done_r              <= 0;
      t_done_r1             <= 0;
      num_pass              <= 0;
      num_fail              <= 0;

    end
    else begin
      led_r1               <= led_r;
      led_r                <= done_wr;
      led_rd_1             <= led_rd;
      led_rd               <= done_rd;
      flag_test_done_r     <= flag_test_done;
      t_done_r             <= t_done;
      t_done_r1            <= t_done_r;
      num_pass             <= (LED[9] == 0 & done_pulse & LED[4] == 0 & LED[2] == 0 & init_done_o ) ? num_pass + 1 : num_pass ;
      num_fail             <= (LED[9] == 0 & done_pulse & LED[4] == 1 & LED[2] == 0 & init_done_o ) ? num_fail + 1 : num_fail ;
    end
  end

  assign done_pulse = (led_r & ~led_r1 | led_rd & ~led_rd_1) ;
  assign done_wr_pulse = (led_r & ~led_r1);
  assign t_done     = flag_test_done & ~flag_test_done_r;
  initial begin // {
  `ifdef RTL_SIM
    // Uncomment this if you want to test the training in RTL simulation
    //force `DUT_HIER_PATH.lscc_lpddr4_mc_inst.u_controller.u_trn_eng.i_csr.trn_operation_reg = 'h1E;
  `endif
    @(posedge pll_refclk_i);
    if (sim_o == 1'b0) begin
      $error("\n\n%0d [TB_TOP] Simulation with eval_top.SIM=0 is not supported due to extremely long simulation time.", $time);
      $display("[TB_TOP] RTL simulation, please uncomment this line in tb_top: `define RTL_SIM");
      $display("[TB_TOP] For post-Synthesis and post-P&R simulations, please set eval_top.SIM=1");
      $display("SIMULATION FAILED");
      $finish;
    end

    if(~&ACCESS_MODE_TOP) begin
      $error("\n\n%0d [TB_TOP] Simulation Read & Write access mode. Read Only and Write Only modes are not supported.", $time);
      $display("[TB_TOP] Please change the access mode configuration to Read and Write.");
      $display("SIMULATION FAILED");
      $finish;
    end

    @(posedge init_done_o);
    $display("%0d [TB_TOP] Initialization and Training Done",$time);

    repeat (100) @(posedge pll_refclk_i);
  //  num_pass = 0;
  //  num_fail = 0;
    j = 0;
    wc = 0;
    $display("Waiting for the posedge of the ddr_dqs_t");
    @(posedge ddr_dqs_io[0]);
    $display("Found the dqs toggle");
    while(i > 0) begin  // {
      @(posedge pll_refclk_i);
      if(LED[9] == 0) begin // {
        if(t_done_r1) begin // {
          i = 0;
          $display("END_OF_SIMULATION");
          break;
        end // }
        else begin // {
          if(done_pulse) begin // {
              if((LED[2] & !LED[9] ) == 1) begin // {
                $display("%0d [TB_TOP] Run : %0d ",$time,j);
                burst_type(done_wr_pulse,j);
                j = j + 1;
                $display("%0d [TB_TOP] Write Done",$time);
              end // }
              else  begin // {
                if((LED[4] & !LED[9]) == 0) begin  // {
                  $display("%0d [TB_TOP] Read Done : Data Compare Pass",$time);
                  //num_pass = num_pass + 1;
                  continue;
                end // }
                else begin // {
                  $error("%0d [TB_TOP] Read Done : Data Compare Fail", $time);
                  //num_fail = num_fail + 1;
                  $display(" %0d [TB_TOP] Test number :  %0d" , $time,num_fail);
                  continue;
                end  // }
              end // }
          end // }
        end // }
        i = 1;
      end // }
    end  // }
    @(posedge pll_refclk_i);
    @(posedge pll_refclk_i);
    $display("Out side the loop");
    $display("//////////////////////////SUMMARY/////////////////////");
    if(num_fail!=0) begin
      $display("FAILED_RUNS : %d",num_fail);
      $error("SIMULATION FAILED");
    end
    else begin
      $display("PASSED_RUNS : %d",num_pass);
      $display("SIMULATION PASSED");
    end
    $display("//////////////////////////////////////////////////////");
    $finish;
  end // }

  task burst_type(input int done_wr_pulse, input int wc);
    if(done_wr_pulse) begin
      if(wc == 0)  $display("%0d [TB_TOP] Single INCR2", $time);
      else if(wc == 1)  $display("%0d [TB_TOP] INCR2 " , $time);
      else if(wc == 2)  $display("%0d [TB_TOP] INCR4 " , $time);
      else if(wc == 3)  $display("%0d [TB_TOP] INCR8 " , $time);
      else if(wc == 4)  $display("%0d [TB_TOP] INCR8 with Delay" , $time);
      else if(wc == 5)  $display("%0d [TB_TOP] INCR64",$time);
      else if(wc == 6)  $display("%0d [TB_TOP] PERFORMANCE TEST WITH INCR64",$time);
    end
  endtask

  // This instance is only for single rank
  `ifdef LPDDR4
    `include "lpddr4/lpddr4_memory_instance.vh"
  `endif

  ///////////////////// GSR /////////////////////
  reg gsr_clk;
  initial begin
    gsr_clk = 0;
    forever gsr_clk = #2500 ~gsr_clk; // 200MHz
  end

  GSR GSR_INST (.GSR_N(1'b1), .CLK(gsr_clk));
  ///////////////////// END OF GSR ////////////


  initial begin
    repeat (TB_TIMEOUT) @(posedge pll_refclk_i);
    $display ("============TestBench INFO: SIMULATION TIMEOUT=============");
    $stop;
  end
  `ifdef RTL_SIM
    // For C-Code debugging
    `ifdef C_DEBUG_EN
    // FIXME: For C-Code debugging only
    // Will be removed prior to release
    localparam   ASSERT_ADDR = 32'h8800;
    localparam   GOOD_CODE   = 32'h600DF00D;

    logic [31:0] cpu_ahbl_m1_haddr    ;
    logic [1:0]  cpu_ahbl_m1_htrans   ;
    logic [31:0] cpu_ahbl_m1_hwdata   ;
    logic        cpu_ahbl_m1_hreadyout;
    logic        PCLK   ;
    logic        PRESETn;

    generate
      if (CPU_GRP_EN == 1) begin : CPU_EN
        assign cpu_ahbl_m1_haddr     = `DUT_HIER_PATH.lscc_lpddr4_mc_inst.u_controller.u_trn_eng.CPU_EN.i_cpu_grp.i_cpu_AHBL_M1_DATA_interconnect_HADDR_interconnect;
        assign cpu_ahbl_m1_htrans    = `DUT_HIER_PATH.lscc_lpddr4_mc_inst.u_controller.u_trn_eng.CPU_EN.i_cpu_grp.i_cpu_AHBL_M1_DATA_interconnect_HTRANS_interconnect;
        assign cpu_ahbl_m1_hwdata    = `DUT_HIER_PATH.lscc_lpddr4_mc_inst.u_controller.u_trn_eng.CPU_EN.i_cpu_grp.i_cpu_AHBL_M1_DATA_interconnect_HWDATA_interconnect;
        assign cpu_ahbl_m1_hreadyout = `DUT_HIER_PATH.lscc_lpddr4_mc_inst.u_controller.u_trn_eng.CPU_EN.i_cpu_grp.i_cpu_AHBL_M1_DATA_interconnect_HREADYOUT_interconnect;
        assign PCLK                  = u_eval_top.pclk_i;
        assign PRESETn               = u_eval_top.prst_n ;

    debug_c_code #(
      .DDR_TYPE     (DDR_TYPE   ),
      .ASSERT_ADDR  (ASSERT_ADDR),
      .GOOD_CODE    (GOOD_CODE  )
    )
    i_dbg_c(
      .clk_i        (PCLK                 ),
      .reset_n_i    (PRESETn              ),
      .cpu_haddr    (cpu_ahbl_m1_haddr    ),
      .cpu_htrans   (cpu_ahbl_m1_htrans   ),
      .cpu_hwdata   (cpu_ahbl_m1_hwdata   ),
      .cpu_hreadyout(cpu_ahbl_m1_hreadyout)
    );

      end else begin : CPU_DIS
        // Not yet set for this mode
      end

    endgenerate

    `endif
  `endif


  endmodule
`endif





