`ifndef __TESTBENCH__TB_TOP__
`define __TESTBENCH__TB_TOP__
`timescale 1ps/100fs
//==========================================================================
// Module : tb_top
//==========================================================================
module tb_top ();



//--------------------------------------------------------------------------
//--- Local Parameters/Defines ---
//--------------------------------------------------------------------------
`include "dut_params.v"

localparam                    REFCLK_PERIOD = 1000000/REFCLK_FREQ;

localparam                    CLK0_DIV      = (PLL_CLKOD0+1);
localparam                    CLK1_DIV      = (PLL_CLKOD1+1);
localparam                    CLK2_DIV      = (PLL_CLKOD2+1);
localparam                    CLK3_DIV      = (PLL_CLKOD3+1);
localparam                    CLK4_DIV      = (PLL_CLKOD4+1);
localparam                    CLK5_DIV      = (PLL_CLKOD5+1);
localparam                    CLK6_DIV      = (PLL_CLKOD6+1);
localparam                    CLK7_DIV      = (PLL_CLKOD7+1);

localparam                    CLK0_FREQ     = VCO_FREQ/CLK0_DIV;
localparam                    CLK1_FREQ     = VCO_FREQ/CLK1_DIV;
localparam                    CLK2_FREQ     = VCO_FREQ/CLK2_DIV;
localparam                    CLK3_FREQ     = VCO_FREQ/CLK3_DIV;
localparam                    CLK4_FREQ     = VCO_FREQ/CLK4_DIV;
localparam                    CLK5_FREQ     = VCO_FREQ/CLK5_DIV;
localparam                    CLK6_FREQ     = VCO_FREQ/CLK6_DIV;
localparam                    CLK7_FREQ     = VCO_FREQ/CLK7_DIV;

localparam                    CLK0_PHASE    = (EN_EXT_CLKDIV)? ((45*CLK0_PHI/CLK0_DIV) + (360*(CLK0_DEL - CLK0_DIV)/CLK0_DIV)) : 0;
localparam                    CLK1_PHASE    = (EN_EXT_CLKDIV)? ((45*CLK1_PHI/CLK1_DIV) + (360*(CLK1_DEL - CLK1_DIV)/CLK1_DIV)) : 0;
localparam                    CLK2_PHASE    = (EN_EXT_CLKDIV)? ((45*CLK2_PHI/CLK2_DIV) + (360*(CLK2_DEL - CLK2_DIV)/CLK2_DIV)) : 0;
localparam                    CLK3_PHASE    = (EN_EXT_CLKDIV)? ((45*CLK3_PHI/CLK3_DIV) + (360*(CLK3_DEL - CLK3_DIV)/CLK3_DIV)) : 0;
localparam                    CLK4_PHASE    = (EN_EXT_CLKDIV)? ((45*CLK4_PHI/CLK4_DIV) + (360*(CLK4_DEL - CLK4_DIV)/CLK4_DIV)) : 0;
localparam                    CLK5_PHASE    = (EN_EXT_CLKDIV)? ((45*CLK5_PHI/CLK5_DIV) + (360*(CLK5_DEL - CLK5_DIV)/CLK5_DIV)) : 0;
localparam                    CLK6_PHASE    = (EN_EXT_CLKDIV)? ((45*CLK6_PHI/CLK6_DIV) + (360*(CLK6_DEL - CLK6_DIV)/CLK6_DIV)) : 0;
localparam                    CLK7_PHASE    = (EN_EXT_CLKDIV)? ((45*CLK7_PHI/CLK7_DIV) + (360*(CLK7_DEL - CLK7_DIV)/CLK7_DIV)) : 0;

localparam                    EN_PHASE_CHECK_CLK0 = (CLK0_BYP)? 0 :
                                                    (CLK0_FREQ == CLK1_FREQ)? (CLK1_PHASE == 0) :
                                                    (CLK0_FREQ == CLK2_FREQ)? (CLK2_PHASE == 0) :
                                                    (CLK0_FREQ == CLK3_FREQ)? (CLK3_PHASE == 0) :
                                                    (CLK0_FREQ == CLK4_FREQ)? (CLK4_PHASE == 0) :
                                                    (CLK0_FREQ == CLK5_FREQ)? (CLK5_PHASE == 0) :
                                                    (CLK0_FREQ == CLK6_FREQ)? (CLK6_PHASE == 0) :
                                                    (CLK0_FREQ == CLK7_FREQ)? (CLK7_PHASE == 0) : 0;

localparam                    EN_PHASE_CHECK_CLK1 = (CLK1_BYP)? 0 :
                                                    (CLK1_FREQ == CLK2_FREQ)? (CLK2_PHASE == 0) :
                                                    (CLK1_FREQ == CLK3_FREQ)? (CLK3_PHASE == 0) :
                                                    (CLK1_FREQ == CLK4_FREQ)? (CLK4_PHASE == 0) :
                                                    (CLK1_FREQ == CLK5_FREQ)? (CLK5_PHASE == 0) :
                                                    (CLK1_FREQ == CLK6_FREQ)? (CLK6_PHASE == 0) :
                                                    (CLK1_FREQ == CLK7_FREQ)? (CLK7_PHASE == 0) :
                                                    (CLK1_FREQ == CLK0_FREQ)? (CLK0_PHASE == 0) : 0;

localparam                    EN_PHASE_CHECK_CLK2 = (CLK2_BYP)? 0 :
                                                    (CLK2_FREQ == CLK3_FREQ)? (CLK3_PHASE == 0) :
                                                    (CLK2_FREQ == CLK4_FREQ)? (CLK4_PHASE == 0) :
                                                    (CLK2_FREQ == CLK5_FREQ)? (CLK5_PHASE == 0) :
                                                    (CLK2_FREQ == CLK6_FREQ)? (CLK6_PHASE == 0) :
                                                    (CLK2_FREQ == CLK7_FREQ)? (CLK7_PHASE == 0) :
                                                    (CLK2_FREQ == CLK0_FREQ)? (CLK0_PHASE == 0) :
                                                    (CLK2_FREQ == CLK1_FREQ)? (CLK1_PHASE == 0) : 0;

localparam                    EN_PHASE_CHECK_CLK3 = (CLK3_BYP)? 0 :
                                                    (CLK3_FREQ == CLK4_FREQ)? (CLK4_PHASE == 0) :
                                                    (CLK3_FREQ == CLK5_FREQ)? (CLK5_PHASE == 0) :
                                                    (CLK3_FREQ == CLK6_FREQ)? (CLK6_PHASE == 0) :
                                                    (CLK3_FREQ == CLK7_FREQ)? (CLK7_PHASE == 0) :
                                                    (CLK3_FREQ == CLK0_FREQ)? (CLK0_PHASE == 0) :
                                                    (CLK3_FREQ == CLK1_FREQ)? (CLK1_PHASE == 0) :
                                                    (CLK3_FREQ == CLK2_FREQ)? (CLK2_PHASE == 0) : 0;

localparam                    EN_PHASE_CHECK_CLK4 = (CLK4_BYP)? 0 :
                                                    (CLK4_FREQ == CLK5_FREQ)? (CLK5_PHASE == 0) :
                                                    (CLK4_FREQ == CLK6_FREQ)? (CLK6_PHASE == 0) :
                                                    (CLK4_FREQ == CLK7_FREQ)? (CLK7_PHASE == 0) :
                                                    (CLK4_FREQ == CLK0_FREQ)? (CLK0_PHASE == 0) :
                                                    (CLK4_FREQ == CLK1_FREQ)? (CLK1_PHASE == 0) :
                                                    (CLK4_FREQ == CLK2_FREQ)? (CLK2_PHASE == 0) :
                                                    (CLK4_FREQ == CLK3_FREQ)? (CLK3_PHASE == 0) : 0;

localparam                    EN_PHASE_CHECK_CLK5 = (CLK5_BYP)? 0 :
                                                    (CLK5_FREQ == CLK6_FREQ)? (CLK6_PHASE == 0) :
                                                    (CLK5_FREQ == CLK7_FREQ)? (CLK7_PHASE == 0) :
                                                    (CLK5_FREQ == CLK0_FREQ)? (CLK0_PHASE == 0) :
                                                    (CLK5_FREQ == CLK1_FREQ)? (CLK1_PHASE == 0) :
                                                    (CLK5_FREQ == CLK2_FREQ)? (CLK2_PHASE == 0) :
                                                    (CLK5_FREQ == CLK3_FREQ)? (CLK3_PHASE == 0) :
                                                    (CLK5_FREQ == CLK4_FREQ)? (CLK4_PHASE == 0) : 0;

localparam                    EN_PHASE_CHECK_CLK6 = (CLK6_BYP)? 0 :
                                                    (CLK6_FREQ == CLK7_FREQ)? (CLK7_PHASE == 0) :
                                                    (CLK6_FREQ == CLK0_FREQ)? (CLK0_PHASE == 0) :
                                                    (CLK6_FREQ == CLK1_FREQ)? (CLK1_PHASE == 0) :
                                                    (CLK6_FREQ == CLK2_FREQ)? (CLK2_PHASE == 0) :
                                                    (CLK6_FREQ == CLK3_FREQ)? (CLK3_PHASE == 0) :
                                                    (CLK6_FREQ == CLK4_FREQ)? (CLK4_PHASE == 0) :
                                                    (CLK6_FREQ == CLK5_FREQ)? (CLK5_PHASE == 0) : 0;

localparam                    EN_PHASE_CHECK_CLK7 = (CLK7_BYP)? 0 :
                                                    (CLK7_FREQ == CLK0_FREQ)? (CLK0_PHASE == 0) :
                                                    (CLK7_FREQ == CLK1_FREQ)? (CLK1_PHASE == 0) :
                                                    (CLK7_FREQ == CLK2_FREQ)? (CLK2_PHASE == 0) :
                                                    (CLK7_FREQ == CLK3_FREQ)? (CLK3_PHASE == 0) :
                                                    (CLK7_FREQ == CLK4_FREQ)? (CLK4_PHASE == 0) :
                                                    (CLK7_FREQ == CLK5_FREQ)? (CLK5_PHASE == 0) :
                                                    (CLK7_FREQ == CLK6_FREQ)? (CLK6_PHASE == 0) : 0;

localparam                    LOCK_TIMEOUT_CNT    = 100000;

//--------------------------------------------------------------------------
//--- Combinational Wire/Reg ---
//--------------------------------------------------------------------------
reg                           param_mismatch;
reg         [31:0]            lock_timer;
reg                           reset_done;
reg                           exp_lock;

reg                           refclk_in_i;
reg                           rst_n_i;
wire                          usr_fbkclk_i;

reg                           clken_clkop_i;
reg                           clken_clkophy_i;
reg                           clken_clkos2_i;
reg                           clken_clkos3_i;
reg                           clken_clkos4_i;
reg                           clken_clkos5_i;
reg                           clken_clkos_i;
reg                           clken_testclk_i;

reg                           phasedir_i;
reg                           phaseloadreg_i;
reg         [2:0]             phasesel_i;
reg                           phasestep_i;
/*AUTOREGINPUT*/
reg         [6:0]             apb_paddr_i;
reg                           apb_pclk_i;
reg                           apb_penable_i;
reg                           apb_preset_n_i;
reg                           apb_psel_i;
reg         [15:0]            apb_pwdata_i;
reg                           apb_pwrite_i;
reg                           lmmi_clk_i;
reg         [4:0]             lmmi_offset_i;
reg                           lmmi_request_i;
reg                           lmmi_resetn_i;
reg         [15:0]            lmmi_wdata_i;
reg                           lmmi_wr_rdn_i;

wire                          pll_lock_o;
wire                          pll_lock_w;
wire                          refclk_out_o;
wire                          clkout_clkop_o;
wire                          clkout_clkophy_o;
wire                          clkout_clkos2_o;
wire                          clkout_clkos3_o;
wire                          clkout_clkos4_o;
wire                          clkout_clkos5_o;
wire                          clkout_clkos_o;
wire                          clkout_testclk_o;
wire                          div_change_fbkclk_o;
wire                          div_change_refclk_o;
wire                          outresetack_clkop_o;
wire                          outresetack_clkophy_o;
wire                          outresetack_clkos2_o;
wire                          outresetack_clkos3_o;
wire                          outresetack_clkos4_o;
wire                          outresetack_clkos5_o;
wire                          outresetack_clkos_o;
wire                          outresetack_testclk_o;
wire                          slip_fbkclk_o;
wire                          slip_refclk_o;
wire                          stepack_clkop_o;
wire                          stepack_clkophy_o;
wire                          stepack_clkos2_o;
wire                          stepack_clkos3_o;
wire                          stepack_clkos4_o;
wire                          stepack_clkos5_o;
wire                          stepack_clkos_o;
wire                          stepack_testclk_o;
/*AUTOWIRE*/
wire        [15:0]            apb_prdata_o;
wire                          apb_pready_o;
wire                          apb_pslverr_o;
wire        [15:0]            lmmi_rdata_o;
wire                          lmmi_rdata_valid_o;
wire                          lmmi_ready_o;

wire                          test_done;

wire        [7:0]             clk_out;
wire        [7:0]             clk_error_detected;
wire        [7:0]             clk_test_done;
wire        [7:0]             clk_toggle_detected;

real                          clk_phase[7:0];
real                          clk_freq[7:0];


// -----------------------------------------
// port names on generated wrapper
// -----------------------------------------
wire                          clki_i     ;
wire                          rstn_i     ;
wire                          enclkop_i  ;
wire                          enclkos_i  ;
wire                          enclkos2_i ;
wire                          enclkos3_i ;
wire                          enclkos4_i ;
wire                          enclkos5_i ;
wire                          enclkophy_i;
wire                          clkop_o    ;
wire                          clkos_o    ;
wire                          clkos2_o   ;
wire                          clkos3_o   ;
wire                          clkos4_o   ;
wire                          clkos5_o   ;
wire                          clkophy_o  ;
wire                          lock_o     ;

assign clki_i      = refclk_in_i;
assign rstn_i      = rst_n_i;
assign enclkop_i   = clken_clkop_i  ;
assign enclkos_i   = clken_clkos_i  ;
assign enclkos2_i  = clken_clkos2_i ;
assign enclkos3_i  = clken_clkos3_i ;
assign enclkos4_i  = clken_clkos4_i ;
assign enclkos5_i  = clken_clkos5_i ;
assign enclkophy_i = clken_clkophy_i;

assign clkout_clkop_o   = clkop_o   ;
assign clkout_clkos_o   = clkos_o   ;
assign clkout_clkos2_o  = clkos2_o  ;
assign clkout_clkos3_o  = clkos3_o  ;
assign clkout_clkos4_o  = clkos4_o  ;
assign clkout_clkos5_o  = clkos5_o  ;
assign clkout_clkophy_o = clkophy_o ;
assign pll_lock_o       = lock_o    ;
//--------------------------------------------------------------------------
//--- Registers ---
//--------------------------------------------------------------------------

initial begin
`ifdef CADENCE_DUMP
      $timeformat (-15 ,1 , "ps", 15);
      $recordfile("simwave_pll.trn");
  `ifdef TRN_INSTANCE
        $recordvars(`TRN_INSTANCE);
  `else
        $recordvars(tb_top);
  `endif
`endif
end

initial begin
  clken_clkop_i   = 0;
  clken_clkophy_i = 0;
  clken_clkos2_i  = 0;
  clken_clkos3_i  = 0;
  clken_clkos4_i  = 0;
  clken_clkos5_i  = 0;
  clken_clkos_i   = 0;
  clken_testclk_i = 0;

  phasedir_i      = 0;
  phaseloadreg_i  = 0;
  phasesel_i      = 0;
  phasestep_i     = 0;

  apb_paddr_i     = 0;
  apb_pclk_i      = 0;
  apb_penable_i   = 0;
  apb_preset_n_i  = 0;
  apb_psel_i      = 0;
  apb_pwdata_i    = 0;
  apb_pwrite_i    = 0;
  lmmi_clk_i      = 0;
  lmmi_offset_i   = 0;
  lmmi_request_i  = 0;
  lmmi_resetn_i   = 0;
  lmmi_wdata_i    = 0;
  lmmi_wr_rdn_i   = 0;

  lock_timer      = 0;
  exp_lock        = 1'b0;
  #(1000*1000*100);  // delay 100us
  exp_lock        = 1'b1;
end

initial begin
  refclk_in_i = 0;
  forever refclk_in_i = #(REFCLK_PERIOD/2) ~refclk_in_i;
end

reg gsr_clk;
initial begin
  gsr_clk = 0;
  forever gsr_clk = #5000 ~gsr_clk;
end

assign usr_fbkclk_i = (EN_USR_FBKCLK)? clkout_clkop_o : 1'b0;

initial begin
  param_mismatch = 0;
  reset_done = 0;
  rst_n_i    = 0;
  #300000
  $display(" ---------------------------------------------- ");
  $display("\tINFO: RESET DONE: --" );
  $display(" ---------------------------------------------- ");
  reset_done = 1;
  rst_n_i    = 1;
end

always @* begin
  if(rst_n_i) begin
    @(posedge gsr_clk);
    clken_clkop_i   <= 1;
    clken_clkophy_i <= 1;
    clken_clkos2_i  <= 1;
    clken_clkos3_i  <= 1;
    clken_clkos4_i  <= 1;
    clken_clkos5_i  <= 1;
    clken_clkos_i   <= 1;
    clken_testclk_i <= 1;
    apb_preset_n_i  <= 1;
    lmmi_resetn_i   <= 1;
  end
  else begin
    @(posedge gsr_clk);
    clken_clkop_i   <= 0;
    clken_clkophy_i <= 0;
    clken_clkos2_i  <= 0;
    clken_clkos3_i  <= 0;
    clken_clkos4_i  <= 0;
    clken_clkos5_i  <= 0;
    clken_clkos_i   <= 0;
    clken_testclk_i <= 0;
    apb_preset_n_i  <= 0;
    lmmi_resetn_i   <= 0;
  end
end //--always @*--

assign pll_lock_w = (EN_LOCK_DETECT)? pll_lock_o : exp_lock;
always @* begin
  if(rst_n_i) begin
    if(pll_lock_w) begin
      @(posedge gsr_clk);
      lock_timer <= 0;
    end
    else begin
      @(posedge gsr_clk);
      lock_timer <= lock_timer + 1;
    end
  end
  else begin
    @(posedge gsr_clk);
    lock_timer <= 0;
  end
end //--always @*--


function automatic real get_clk_freq;
  input idx;
  real  clk_freq[7:0];
  begin
    clk_freq[0] = CLK0_FREQ;
    clk_freq[1] = CLK1_FREQ;
    clk_freq[2] = CLK2_FREQ;
    clk_freq[3] = CLK3_FREQ;
    clk_freq[4] = CLK4_FREQ;
    clk_freq[5] = CLK5_FREQ;
    clk_freq[6] = CLK6_FREQ;
    clk_freq[7] = CLK7_FREQ;

    get_clk_freq = clk_freq[idx];
  end
endfunction // get_clk_freq

function automatic real get_clk_phase;
  input idx;
  real  clk_phase[7:0];
  begin
    clk_phase[0] = CLK0_PHASE;
    clk_phase[1] = CLK1_PHASE;
    clk_phase[2] = CLK2_PHASE;
    clk_phase[3] = CLK3_PHASE;
    clk_phase[4] = CLK4_PHASE;
    clk_phase[5] = CLK5_PHASE;
    clk_phase[6] = CLK6_PHASE;
    clk_phase[7] = CLK7_PHASE;

    get_clk_phase = clk_phase[idx];
  end
endfunction // get_clk_phase

function automatic reg get_en_clk;
  input idx;
  reg   en_clk[7:0];
  begin
    en_clk[0] = (EN_CLK0_OUT)? 1 : 0;
    en_clk[1] = (EN_CLK1_OUT)? 1 : 0;
    en_clk[2] = (EN_CLK2_OUT)? 1 : 0;
    en_clk[3] = (EN_CLK3_OUT)? 1 : 0;
    en_clk[4] = (EN_CLK4_OUT)? 1 : 0;
    en_clk[5] = (EN_CLK5_OUT)? 1 : 0;
    en_clk[6] = (EN_CLK6_OUT)? 1 : 0;
    en_clk[7] = (EN_CLK7_OUT)? 1 : 0;

    get_en_clk = en_clk[idx];
  end
endfunction // get_en_clk

function automatic [8*7-1:0] get_clk_name;
  input idx;
  reg [8*7-1:0] clk_name[7:0];
  begin
    clk_name[0] = "CLKOP";
    clk_name[1] = "CLKOS";
    clk_name[2] = "CLKOS2";
    clk_name[3] = "CLKOS3";
    clk_name[4] = "CLKOS4";
    clk_name[5] = "CLKOS5";
    clk_name[6] = "CLKOPHY";
    clk_name[7] = "TESTCLK";

    get_clk_name = clk_name[idx];
  end
endfunction // get_clk_name

function automatic reg get_clk_byp;
  input idx;
  reg   clk_byp[7:0];
  begin
    clk_byp[0] = CLK0_BYP;
    clk_byp[1] = CLK1_BYP;
    clk_byp[2] = CLK2_BYP;
    clk_byp[3] = CLK3_BYP;
    clk_byp[4] = CLK4_BYP;
    clk_byp[5] = CLK5_BYP;
    clk_byp[6] = CLK6_BYP;
    clk_byp[7] = CLK7_BYP;

    get_clk_byp = clk_byp[idx];
  end
endfunction // get_clk_byp

function automatic reg get_en_phase_check;
  input idx;
  reg   en_phase_check[7:0];
  begin
    en_phase_check[0] = EN_PHASE_CHECK_CLK0;
    en_phase_check[1] = EN_PHASE_CHECK_CLK1;
    en_phase_check[2] = EN_PHASE_CHECK_CLK2;
    en_phase_check[3] = EN_PHASE_CHECK_CLK3;
    en_phase_check[4] = EN_PHASE_CHECK_CLK4;
    en_phase_check[5] = EN_PHASE_CHECK_CLK5;
    en_phase_check[6] = EN_PHASE_CHECK_CLK6;
    en_phase_check[7] = EN_PHASE_CHECK_CLK7;

    get_en_phase_check = en_phase_check[idx];
  end
endfunction // get_en_phase_check

assign clk_out[0]    = clkout_clkop_o  ;
assign clk_out[1]    = clkout_clkos_o  ;
assign clk_out[2]    = clkout_clkos2_o ;
assign clk_out[3]    = clkout_clkos3_o ;
assign clk_out[4]    = clkout_clkos4_o ;
assign clk_out[5]    = clkout_clkos5_o ;
assign clk_out[6]    = clkout_clkophy_o;
assign clk_out[7]    = clkout_testclk_o;

initial begin
  clk_phase[0]  = CLK0_PHASE;
  clk_phase[1]  = CLK1_PHASE;
  clk_phase[2]  = CLK2_PHASE;
  clk_phase[3]  = CLK3_PHASE;
  clk_phase[4]  = CLK4_PHASE;
  clk_phase[5]  = CLK5_PHASE;
  clk_phase[6]  = CLK6_PHASE;
  clk_phase[7]  = CLK7_PHASE;

  clk_freq[0]   = CLK0_FREQ;
  clk_freq[1]   = CLK1_FREQ;
  clk_freq[2]   = CLK2_FREQ;
  clk_freq[3]   = CLK3_FREQ;
  clk_freq[4]   = CLK4_FREQ;
  clk_freq[5]   = CLK5_FREQ;
  clk_freq[6]   = CLK6_FREQ;
  clk_freq[7]   = CLK7_FREQ;
end

genvar i;
generate
  for(i=0; i<8; i=i+1) begin : gen_clk
    localparam IDX_CK           = i;
    localparam EN_CLK           = (IDX_CK == 7)? EN_CLK7_OUT :
                                  (IDX_CK == 6)? EN_CLK6_OUT :
                                  (IDX_CK == 5)? EN_CLK5_OUT :
                                  (IDX_CK == 4)? EN_CLK4_OUT :
                                  (IDX_CK == 3)? EN_CLK3_OUT :
                                  (IDX_CK == 2)? EN_CLK2_OUT :
                                  (IDX_CK == 1)? EN_CLK1_OUT :
                                                 EN_CLK0_OUT;

    if(EN_CLK) begin : gen_en_clk
      localparam CLK_NAME        = (IDX_CK == 7)? "TESTCLK" :
                                   (IDX_CK == 6)? "CLKOPHY" :
                                   (IDX_CK == 5)? "CLKOS5"  :
                                   (IDX_CK == 4)? "CLKOS4"  :
                                   (IDX_CK == 3)? "CLKOS3"  :
                                   (IDX_CK == 2)? "CLKOS2"  :
                                   (IDX_CK == 1)? "CLKOS"   :
                                                  "CLKOP"   ;

      localparam CLK_BYP         = (IDX_CK == 7)? CLK7_BYP :
                                   (IDX_CK == 6)? CLK6_BYP :
                                   (IDX_CK == 5)? CLK5_BYP :
                                   (IDX_CK == 4)? CLK4_BYP :
                                   (IDX_CK == 3)? CLK3_BYP :
                                   (IDX_CK == 2)? CLK2_BYP :
                                   (IDX_CK == 1)? CLK1_BYP :
                                                  CLK0_BYP ;

      localparam CLK_FREQ        = (IDX_CK == 7)? CLK7_FREQ :
                                   (IDX_CK == 6)? CLK6_FREQ :
                                   (IDX_CK == 5)? CLK5_FREQ :
                                   (IDX_CK == 4)? CLK4_FREQ :
                                   (IDX_CK == 3)? CLK3_FREQ :
                                   (IDX_CK == 2)? CLK2_FREQ :
                                   (IDX_CK == 1)? CLK1_FREQ :
                                                  CLK0_FREQ ;

      localparam EXP_CLK_FREQ    = (CLK_BYP)? REFCLK_FREQ : CLK_FREQ;

      localparam EN_PHASE_CHECK  = (IDX_CK == 7)? EN_PHASE_CHECK_CLK7 :
                                   (IDX_CK == 6)? EN_PHASE_CHECK_CLK6 :
                                   (IDX_CK == 5)? EN_PHASE_CHECK_CLK5 :
                                   (IDX_CK == 4)? EN_PHASE_CHECK_CLK4 :
                                   (IDX_CK == 3)? EN_PHASE_CHECK_CLK3 :
                                   (IDX_CK == 2)? EN_PHASE_CHECK_CLK2 :
                                   (IDX_CK == 1)? EN_PHASE_CHECK_CLK1 :
                                                  EN_PHASE_CHECK_CLK0 ;

      localparam EXP_PHASE_SHIFT = (IDX_CK == 7)? CLK7_PHASE :
                                   (IDX_CK == 6)? CLK6_PHASE :
                                   (IDX_CK == 5)? CLK5_PHASE :
                                   (IDX_CK == 4)? CLK4_PHASE :
                                   (IDX_CK == 3)? CLK3_PHASE :
                                   (IDX_CK == 2)? CLK2_PHASE :
                                   (IDX_CK == 1)? CLK1_PHASE :
                                                  CLK0_PHASE ;

      wire                    phase_0_clk;
      reg   [31:0]            clk_counter;
      wire  [2:0]             phase_0_clk_idx;

      assign phase_0_clk_idx     = ((CLK_FREQ == clk_freq[(i+1)%8]) && (clk_phase[(i+1)%8] == 0))? ((i+1)%8) :
                                   ((CLK_FREQ == clk_freq[(i+2)%8]) && (clk_phase[(i+2)%8] == 0))? ((i+2)%8) :
                                   ((CLK_FREQ == clk_freq[(i+3)%8]) && (clk_phase[(i+3)%8] == 0))? ((i+3)%8) :
                                   ((CLK_FREQ == clk_freq[(i+4)%8]) && (clk_phase[(i+4)%8] == 0))? ((i+4)%8) :
                                   ((CLK_FREQ == clk_freq[(i+5)%8]) && (clk_phase[(i+5)%8] == 0))? ((i+5)%8) :
                                   ((CLK_FREQ == clk_freq[(i+6)%8]) && (clk_phase[(i+6)%8] == 0))? ((i+6)%8) :
                                   ((CLK_FREQ == clk_freq[(i+7)%8]) && (clk_phase[(i+7)%8] == 0))? ((i+7)%8) : i;

      assign phase_0_clk         = (CLK_BYP)? refclk_in_i : clk_out[phase_0_clk_idx];

      initial begin
        clk_counter = 0;
        forever begin
          @(posedge refclk_in_i);
          if(pll_lock_w) begin
            @(posedge clk_out[i]);
            @(negedge clk_out[i]);
            clk_counter = clk_counter + 1;
          end
          else begin
            clk_counter = 0;
          end
        end
      end

      assign clk_toggle_detected[i] = (clk_counter > 16);

      clock_checker #
      (
       .CLK_NAME                              (CLK_NAME),
       .EXP_CLK_FREQ                          (EXP_CLK_FREQ),
       .EXP_PHASE_SHIFT                       (EXP_PHASE_SHIFT),
       .EN_PHASE_CHECK                        (EN_PHASE_CHECK)
      )
      u_clk_freq_checker
      (
       // Inputs
       .rst_n                                 (rst_n_i),
       .pllpd_en_n                            (1'b1),
       .testclk                               (clk_out[i]),
       .phase_0_testclk                       (phase_0_clk),
       .lock                                  (pll_lock_w),
       // Outputs
       .error_detected                        (clk_error_detected[i]),
       .test_done                             (clk_test_done[i]));
    end // gen_en_clk
    else begin : gen_dis_clk
      assign clk_error_detected[i]  = 1'b0;
      assign clk_test_done[i]       = 1'b1;
      assign clk_toggle_detected[i] = 1'b1;
    end // gen_dis_clk
  end // for

endgenerate

assign test_done = &clk_test_done | (lock_timer > LOCK_TIMEOUT_CNT);

initial begin
  wait(test_done);
  repeat (50) @(posedge gsr_clk);

  if(param_mismatch) begin
    $display("\t \t ****** PARAMETER MISMATCH ******\n");
    $display("\t \t ************ TEST CASE FAIL ***********\n");
  end
  else if(~&(clk_test_done & clk_toggle_detected)) begin
    $display("\t \t ****** SOME CLOCK NOT DETECTED (clock detected = %0b) ******\n",clk_toggle_detected);
    $display("\t \t ************ TEST CASE FAIL ***********\n");
  end
  else if(clk_error_detected) begin
    $display("\t \t ****** CLOCK MISMATCH ******\n");
    $display("\t \t ************ TEST CASE FAIL ***********\n");
  end
  else if(lock_timer > LOCK_TIMEOUT_CNT) begin
    $display("\t \t ****** PLL LOCK TIMEOUT ******\n");
    $display("\t \t ************ TEST CASE FAIL ***********\n");
  end
  else begin
    $display("\t \t ********** CLOCK MATCH **********\n");
    $display("\t \t *ALL TESTS PASSED*\n");
    $display("\t \t *SIMULATION PASSED*\n");
  end
  $stop;
end

//--------------------------------------------------------------------------
//--- Module Instantiation ---
//--------------------------------------------------------------------------
GSR GSR_INST (.GSR_N(1'b1), .CLK(gsr_clk));

`ifdef GATE_SIM
localparam GATE_SIM = `GATE_SIM;
generate
if(GATE_SIM != 1) begin : gen_rtl_sim
`ifdef DUT_INST_NAME
  `define DUT_HIER_PATH tb_top.gen_rtl_sim.`DUT_INST_NAME.lscc_pll_inst
`endif
`ifdef DUT_HIER_PATH
  `include "dut_inst.v"
  defparam `DUT_HIER_PATH.SIMULATION = 1;

  initial begin
    $display("----------------------------");
    $display("[DEBUG] Simulation Mode : %0d",`DUT_HIER_PATH.SIMULATION);
    $display("----------------------------");
  end

  `define DUT_HW_TOP  u_pll.PLLC_MODE_inst.PLL_CORE_inst.i_pll_ip_core

  `ifdef DUT_HW_TOP
    `define DUT_HW_PATH   `DUT_HW_TOP.i_pll_ip
    `define DUT_HW_CLKOUT `DUT_HW_TOP.i_pll_output

    `define PLL_HW__CLKR(hw_path) {hw_path.CLKR_5, \
                                   hw_path.CLKR_4, \
                                   hw_path.CLKR_3, \
                                   hw_path.CLKR_2, \
                                   hw_path.CLKR_1, \
                                   hw_path.CLKR_0}

    `define PLL_HW__CLKF(hw_path) {hw_path.CLKF_25, \
                                   hw_path.CLKF_24, \
                                   hw_path.CLKF_23, \
                                   hw_path.CLKF_22, \
                                   hw_path.CLKF_21, \
                                   hw_path.CLKF_20, \
                                   hw_path.CLKF_19, \
                                   hw_path.CLKF_18, \
                                   hw_path.CLKF_17, \
                                   hw_path.CLKF_16, \
                                   hw_path.CLKF_15, \
                                   hw_path.CLKF_14, \
                                   hw_path.CLKF_13, \
                                   hw_path.CLKF_12, \
                                   hw_path.CLKF_11, \
                                   hw_path.CLKF_10, \
                                   hw_path.CLKF_9 , \
                                   hw_path.CLKF_8 , \
                                   hw_path.CLKF_7 , \
                                   hw_path.CLKF_6 , \
                                   hw_path.CLKF_5 , \
                                   hw_path.CLKF_4 , \
                                   hw_path.CLKF_3 , \
                                   hw_path.CLKF_2 , \
                                   hw_path.CLKF_1 , \
                                   hw_path.CLKF_0}

    `define PLL_HW__BWADJ(hw_path) {hw_path.BWADJ_11,  \
                                    hw_path.BWADJ_10,  \
                                    hw_path.BWADJ_9 ,  \
                                    hw_path.BWADJ_8 ,  \
                                    hw_path.BWADJ_7 ,  \
                                    hw_path.BWADJ_6 ,  \
                                    hw_path.BWADJ_5 ,  \
                                    hw_path.BWADJ_4 ,  \
                                    hw_path.BWADJ_3 ,  \
                                    hw_path.BWADJ_2 ,  \
                                    hw_path.BWADJ_1 ,  \
                                    hw_path.BWADJ_0 }

    `define PLL_HW__CLKV(hw_path) {hw_path.CLKV_25, \
                                   hw_path.CLKV_24, \
                                   hw_path.CLKV_23, \
                                   hw_path.CLKV_22, \
                                   hw_path.CLKV_21, \
                                   hw_path.CLKV_20, \
                                   hw_path.CLKV_19, \
                                   hw_path.CLKV_18, \
                                   hw_path.CLKV_17, \
                                   hw_path.CLKV_16, \
                                   hw_path.CLKV_15, \
                                   hw_path.CLKV_14, \
                                   hw_path.CLKV_13, \
                                   hw_path.CLKV_12, \
                                   hw_path.CLKV_11, \
                                   hw_path.CLKV_10, \
                                   hw_path.CLKV_9 , \
                                   hw_path.CLKV_8 , \
                                   hw_path.CLKV_7 , \
                                   hw_path.CLKV_6 , \
                                   hw_path.CLKV_5 , \
                                   hw_path.CLKV_4 , \
                                   hw_path.CLKV_3 , \
                                   hw_path.CLKV_2 , \
                                   hw_path.CLKV_1 , \
                                   hw_path.CLKV_0}

    `define PLL_HW__CLKS(hw_path) {hw_path.CLKS_11,  \
                                   hw_path.CLKS_10,  \
                                   hw_path.CLKS_9 ,  \
                                   hw_path.CLKS_8 ,  \
                                   hw_path.CLKS_7 ,  \
                                   hw_path.CLKS_6 ,  \
                                   hw_path.CLKS_5 ,  \
                                   hw_path.CLKS_4 ,  \
                                   hw_path.CLKS_3 ,  \
                                   hw_path.CLKS_2 ,  \
                                   hw_path.CLKS_1 ,  \
                                   hw_path.CLKS_0 }


    `define PLL_HW__SSEN(hw_path)    hw_path.SSEN
    `define PLL_HW__DITHEN(hw_path)  hw_path.DITHEN
    `define PLL_HW__INTFB(hw_path)   hw_path.INTFB
    `define PLL_HW__FASTEN(hw_path)  hw_path.FASTEN
    `define PLL_HW__ENSAT(hw_path)   hw_path.ENSAT

    `define PLL_HW__BYPASS(hw_path)  {hw_path.BYPASS_7, \
                                      hw_path.BYPASS_6, \
                                      hw_path.BYPASS_5, \
                                      hw_path.BYPASS_4, \
                                      hw_path.BYPASS_3, \
                                      hw_path.BYPASS_2, \
                                      hw_path.BYPASS_1, \
                                      hw_path.BYPASS_0}

    `define PLL_HW__CLKOD_0(hw_path) {hw_path.CLKOD_0_10,  \
                                      hw_path.CLKOD_0_9 ,  \
                                      hw_path.CLKOD_0_8 ,  \
                                      hw_path.CLKOD_0_7 ,  \
                                      hw_path.CLKOD_0_6 ,  \
                                      hw_path.CLKOD_0_5 ,  \
                                      hw_path.CLKOD_0_4 ,  \
                                      hw_path.CLKOD_0_3 ,  \
                                      hw_path.CLKOD_0_2 ,  \
                                      hw_path.CLKOD_0_1 ,  \
                                      hw_path.CLKOD_0_0 }

    `define PLL_HW__CLKOD_1(hw_path) {hw_path.CLKOD_1_10,  \
                                      hw_path.CLKOD_1_9 ,  \
                                      hw_path.CLKOD_1_8 ,  \
                                      hw_path.CLKOD_1_7 ,  \
                                      hw_path.CLKOD_1_6 ,  \
                                      hw_path.CLKOD_1_5 ,  \
                                      hw_path.CLKOD_1_4 ,  \
                                      hw_path.CLKOD_1_3 ,  \
                                      hw_path.CLKOD_1_2 ,  \
                                      hw_path.CLKOD_1_1 ,  \
                                      hw_path.CLKOD_1_0 }

    `define PLL_HW__CLKOD_2(hw_path) {hw_path.CLKOD_2_10,  \
                                      hw_path.CLKOD_2_9 ,  \
                                      hw_path.CLKOD_2_8 ,  \
                                      hw_path.CLKOD_2_7 ,  \
                                      hw_path.CLKOD_2_6 ,  \
                                      hw_path.CLKOD_2_5 ,  \
                                      hw_path.CLKOD_2_4 ,  \
                                      hw_path.CLKOD_2_3 ,  \
                                      hw_path.CLKOD_2_2 ,  \
                                      hw_path.CLKOD_2_1 ,  \
                                      hw_path.CLKOD_2_0 }

    `define PLL_HW__CLKOD_3(hw_path) {hw_path.CLKOD_3_10,  \
                                      hw_path.CLKOD_3_9 ,  \
                                      hw_path.CLKOD_3_8 ,  \
                                      hw_path.CLKOD_3_7 ,  \
                                      hw_path.CLKOD_3_6 ,  \
                                      hw_path.CLKOD_3_5 ,  \
                                      hw_path.CLKOD_3_4 ,  \
                                      hw_path.CLKOD_3_3 ,  \
                                      hw_path.CLKOD_3_2 ,  \
                                      hw_path.CLKOD_3_1 ,  \
                                      hw_path.CLKOD_3_0 }

    `define PLL_HW__CLKOD_4(hw_path) {hw_path.CLKOD_4_10,  \
                                      hw_path.CLKOD_4_9 ,  \
                                      hw_path.CLKOD_4_8 ,  \
                                      hw_path.CLKOD_4_7 ,  \
                                      hw_path.CLKOD_4_6 ,  \
                                      hw_path.CLKOD_4_5 ,  \
                                      hw_path.CLKOD_4_4 ,  \
                                      hw_path.CLKOD_4_3 ,  \
                                      hw_path.CLKOD_4_2 ,  \
                                      hw_path.CLKOD_4_1 ,  \
                                      hw_path.CLKOD_4_0 }

    `define PLL_HW__CLKOD_5(hw_path) {hw_path.CLKOD_5_10,  \
                                      hw_path.CLKOD_5_9 ,  \
                                      hw_path.CLKOD_5_8 ,  \
                                      hw_path.CLKOD_5_7 ,  \
                                      hw_path.CLKOD_5_6 ,  \
                                      hw_path.CLKOD_5_5 ,  \
                                      hw_path.CLKOD_5_4 ,  \
                                      hw_path.CLKOD_5_3 ,  \
                                      hw_path.CLKOD_5_2 ,  \
                                      hw_path.CLKOD_5_1 ,  \
                                      hw_path.CLKOD_5_0 }

    `define PLL_HW__CLKOD_6(hw_path) {hw_path.CLKOD_6_10,  \
                                      hw_path.CLKOD_6_9 ,  \
                                      hw_path.CLKOD_6_8 ,  \
                                      hw_path.CLKOD_6_7 ,  \
                                      hw_path.CLKOD_6_6 ,  \
                                      hw_path.CLKOD_6_5 ,  \
                                      hw_path.CLKOD_6_4 ,  \
                                      hw_path.CLKOD_6_3 ,  \
                                      hw_path.CLKOD_6_2 ,  \
                                      hw_path.CLKOD_6_1 ,  \
                                      hw_path.CLKOD_6_0 }

    `define PLL_HW__CLKOD_7(hw_path) {hw_path.CLKOD_7_10,  \
                                      hw_path.CLKOD_7_9 ,  \
                                      hw_path.CLKOD_7_8 ,  \
                                      hw_path.CLKOD_7_7 ,  \
                                      hw_path.CLKOD_7_6 ,  \
                                      hw_path.CLKOD_7_5 ,  \
                                      hw_path.CLKOD_7_4 ,  \
                                      hw_path.CLKOD_7_3 ,  \
                                      hw_path.CLKOD_7_2 ,  \
                                      hw_path.CLKOD_7_1 ,  \
                                      hw_path.CLKOD_7_0 }

    `define PLL_HW__BYPASS0(hw_path)  hw_path.lmmi_bypassa
    `define PLL_HW__BYPASS1(hw_path)  hw_path.lmmi_bypassb
    `define PLL_HW__BYPASS2(hw_path)  hw_path.lmmi_bypassc
    `define PLL_HW__BYPASS3(hw_path)  hw_path.lmmi_bypassd
    `define PLL_HW__BYPASS4(hw_path)  hw_path.lmmi_bypasse
    `define PLL_HW__BYPASS5(hw_path)  hw_path.lmmi_bypassf
    `define PLL_HW__BYPASS6(hw_path)  hw_path.lmmi_bypassphy
    `define PLL_HW__BYPASS7(hw_path)  hw_path.lmmi_bypassclk7

    `define PLL_HW__DELA(hw_path)    hw_path.lmmi_dela
    `define PLL_HW__DELB(hw_path)    hw_path.lmmi_delb
    `define PLL_HW__DELC(hw_path)    hw_path.lmmi_delc
    `define PLL_HW__DELD(hw_path)    hw_path.lmmi_deld
    `define PLL_HW__DELE(hw_path)    hw_path.lmmi_dele
    `define PLL_HW__DELF(hw_path)    hw_path.lmmi_delf
    `define PLL_HW__DELPHY(hw_path)  hw_path.lmmi_delphy
    `define PLL_HW__DELCLK7(hw_path) hw_path.lmmi_delclk7
    `define PLL_HW__DIVA(hw_path)    hw_path.lmmi_diva
    `define PLL_HW__DIVB(hw_path)    hw_path.lmmi_divb
    `define PLL_HW__DIVC(hw_path)    hw_path.lmmi_divc
    `define PLL_HW__DIVD(hw_path)    hw_path.lmmi_divd
    `define PLL_HW__DIVE(hw_path)    hw_path.lmmi_dive
    `define PLL_HW__DIVF(hw_path)    hw_path.lmmi_divf
    `define PLL_HW__DIVPHY(hw_path)  hw_path.lmmi_divphy
    `define PLL_HW__DIVCLK7(hw_path) hw_path.lmmi_divclk7


    wire [5:0]                  pll_hw_clkr;
    wire [25:0]                 pll_hw_clkf;
    wire [11:0]                 pll_hw_bwadj;
    wire [25:0]                 pll_hw_clkv;
    wire [11:0]                 pll_hw_clks;
    wire                        pll_hw_ssen;
    wire                        pll_hw_dithen;
    wire                        pll_hw_intfb;
    wire                        pll_hw_fasten;
    wire                        pll_hw_ensat;
    wire [7:0]                  pll_hw_bypass;
    wire [10:0]                 pll_hw_clkod_0;
    wire [10:0]                 pll_hw_clkod_1;
    wire [10:0]                 pll_hw_clkod_2;
    wire [10:0]                 pll_hw_clkod_3;
    wire [10:0]                 pll_hw_clkod_4;
    wire [10:0]                 pll_hw_clkod_5;
    wire [10:0]                 pll_hw_clkod_6;
    wire [10:0]                 pll_hw_clkod_7;

    wire [7:0]                  pll_hw_lmmi_dela;
    wire [7:0]                  pll_hw_lmmi_delb;
    wire [7:0]                  pll_hw_lmmi_delc;
    wire [7:0]                  pll_hw_lmmi_deld;
    wire [7:0]                  pll_hw_lmmi_dele;
    wire [7:0]                  pll_hw_lmmi_delf;
    wire [7:0]                  pll_hw_lmmi_delphy;
    wire [7:0]                  pll_hw_lmmi_delclk7;
    wire [7:0]                  pll_hw_lmmi_diva;
    wire [7:0]                  pll_hw_lmmi_divb;
    wire [7:0]                  pll_hw_lmmi_divc;
    wire [7:0]                  pll_hw_lmmi_divd;
    wire [7:0]                  pll_hw_lmmi_dive;
    wire [7:0]                  pll_hw_lmmi_divf;
    wire [7:0]                  pll_hw_lmmi_divphy;
    wire [7:0]                  pll_hw_lmmi_divclk7;

    //generate
      if(!EN_EXT_CLKDIV) begin : gen_int_outclkdiv
        assign pll_hw_clkr    = `PLL_HW__CLKR(`DUT_HIER_PATH.gen_int_outclkdiv.`DUT_HW_PATH);
        assign pll_hw_clkf    = `PLL_HW__CLKF(`DUT_HIER_PATH.gen_int_outclkdiv.`DUT_HW_PATH);
        assign pll_hw_bwadj   = `PLL_HW__BWADJ(`DUT_HIER_PATH.gen_int_outclkdiv.`DUT_HW_PATH);
        assign pll_hw_clkv    = `PLL_HW__CLKV(`DUT_HIER_PATH.gen_int_outclkdiv.`DUT_HW_PATH);
        assign pll_hw_clks    = `PLL_HW__CLKS(`DUT_HIER_PATH.gen_int_outclkdiv.`DUT_HW_PATH);
        assign pll_hw_ssen    = `PLL_HW__SSEN(`DUT_HIER_PATH.gen_int_outclkdiv.`DUT_HW_PATH);
        assign pll_hw_dithen  = `PLL_HW__DITHEN(`DUT_HIER_PATH.gen_int_outclkdiv.`DUT_HW_PATH);
        assign pll_hw_intfb   = `PLL_HW__INTFB(`DUT_HIER_PATH.gen_int_outclkdiv.`DUT_HW_PATH);
        assign pll_hw_fasten  = `PLL_HW__FASTEN(`DUT_HIER_PATH.gen_int_outclkdiv.`DUT_HW_PATH);
        assign pll_hw_ensat   = `PLL_HW__ENSAT(`DUT_HIER_PATH.gen_int_outclkdiv.`DUT_HW_PATH);
        assign pll_hw_clkod_0 = `PLL_HW__CLKOD_0(`DUT_HIER_PATH.gen_int_outclkdiv.`DUT_HW_PATH);
        assign pll_hw_clkod_1 = `PLL_HW__CLKOD_1(`DUT_HIER_PATH.gen_int_outclkdiv.`DUT_HW_PATH);
        assign pll_hw_clkod_2 = `PLL_HW__CLKOD_2(`DUT_HIER_PATH.gen_int_outclkdiv.`DUT_HW_PATH);
        assign pll_hw_clkod_3 = `PLL_HW__CLKOD_3(`DUT_HIER_PATH.gen_int_outclkdiv.`DUT_HW_PATH);
        assign pll_hw_clkod_4 = `PLL_HW__CLKOD_4(`DUT_HIER_PATH.gen_int_outclkdiv.`DUT_HW_PATH);
        assign pll_hw_clkod_5 = `PLL_HW__CLKOD_5(`DUT_HIER_PATH.gen_int_outclkdiv.`DUT_HW_PATH);
        assign pll_hw_clkod_6 = `PLL_HW__CLKOD_6(`DUT_HIER_PATH.gen_int_outclkdiv.`DUT_HW_PATH);
        assign pll_hw_clkod_7 = `PLL_HW__CLKOD_7(`DUT_HIER_PATH.gen_int_outclkdiv.`DUT_HW_PATH);

        assign pll_hw_bypass[0]    = `PLL_HW__BYPASS0(`DUT_HIER_PATH.gen_int_outclkdiv.`DUT_HW_CLKOUT);
        assign pll_hw_bypass[1]    = `PLL_HW__BYPASS1(`DUT_HIER_PATH.gen_int_outclkdiv.`DUT_HW_CLKOUT);
        assign pll_hw_bypass[2]    = `PLL_HW__BYPASS2(`DUT_HIER_PATH.gen_int_outclkdiv.`DUT_HW_CLKOUT);
        assign pll_hw_bypass[3]    = `PLL_HW__BYPASS3(`DUT_HIER_PATH.gen_int_outclkdiv.`DUT_HW_CLKOUT);
        assign pll_hw_bypass[4]    = `PLL_HW__BYPASS4(`DUT_HIER_PATH.gen_int_outclkdiv.`DUT_HW_CLKOUT);
        assign pll_hw_bypass[5]    = `PLL_HW__BYPASS5(`DUT_HIER_PATH.gen_int_outclkdiv.`DUT_HW_CLKOUT);
        assign pll_hw_bypass[6]    = `PLL_HW__BYPASS6(`DUT_HIER_PATH.gen_int_outclkdiv.`DUT_HW_CLKOUT);
        assign pll_hw_bypass[7]    = `PLL_HW__BYPASS7(`DUT_HIER_PATH.gen_int_outclkdiv.`DUT_HW_CLKOUT);

        assign pll_hw_lmmi_dela    = `PLL_HW__DELA(`DUT_HIER_PATH.gen_int_outclkdiv.`DUT_HW_CLKOUT);
        assign pll_hw_lmmi_delb    = `PLL_HW__DELB(`DUT_HIER_PATH.gen_int_outclkdiv.`DUT_HW_CLKOUT);
        assign pll_hw_lmmi_delc    = `PLL_HW__DELC(`DUT_HIER_PATH.gen_int_outclkdiv.`DUT_HW_CLKOUT);
        assign pll_hw_lmmi_deld    = `PLL_HW__DELD(`DUT_HIER_PATH.gen_int_outclkdiv.`DUT_HW_CLKOUT);
        assign pll_hw_lmmi_dele    = `PLL_HW__DELE(`DUT_HIER_PATH.gen_int_outclkdiv.`DUT_HW_CLKOUT);
        assign pll_hw_lmmi_delf    = `PLL_HW__DELF(`DUT_HIER_PATH.gen_int_outclkdiv.`DUT_HW_CLKOUT);
        assign pll_hw_lmmi_delphy  = `PLL_HW__DELPHY(`DUT_HIER_PATH.gen_int_outclkdiv.`DUT_HW_CLKOUT);
        assign pll_hw_lmmi_delclk7 = `PLL_HW__DELCLK7(`DUT_HIER_PATH.gen_int_outclkdiv.`DUT_HW_CLKOUT);
        assign pll_hw_lmmi_diva    = `PLL_HW__DIVA(`DUT_HIER_PATH.gen_int_outclkdiv.`DUT_HW_CLKOUT);
        assign pll_hw_lmmi_divb    = `PLL_HW__DIVB(`DUT_HIER_PATH.gen_int_outclkdiv.`DUT_HW_CLKOUT);
        assign pll_hw_lmmi_divc    = `PLL_HW__DIVC(`DUT_HIER_PATH.gen_int_outclkdiv.`DUT_HW_CLKOUT);
        assign pll_hw_lmmi_divd    = `PLL_HW__DIVD(`DUT_HIER_PATH.gen_int_outclkdiv.`DUT_HW_CLKOUT);
        assign pll_hw_lmmi_dive    = `PLL_HW__DIVE(`DUT_HIER_PATH.gen_int_outclkdiv.`DUT_HW_CLKOUT);
        assign pll_hw_lmmi_divf    = `PLL_HW__DIVF(`DUT_HIER_PATH.gen_int_outclkdiv.`DUT_HW_CLKOUT);
        assign pll_hw_lmmi_divphy  = `PLL_HW__DIVPHY(`DUT_HIER_PATH.gen_int_outclkdiv.`DUT_HW_CLKOUT);
        assign pll_hw_lmmi_divclk7 = `PLL_HW__DIVCLK7(`DUT_HIER_PATH.gen_int_outclkdiv.`DUT_HW_CLKOUT);
      end // gen_int_outclkdiv

      else begin : gen_ext_outclkdiv
        assign pll_hw_clkr    = `PLL_HW__CLKR(`DUT_HIER_PATH.gen_ext_outclkdiv.`DUT_HW_PATH);
        assign pll_hw_clkf    = `PLL_HW__CLKF(`DUT_HIER_PATH.gen_ext_outclkdiv.`DUT_HW_PATH);
        assign pll_hw_bwadj   = `PLL_HW__BWADJ(`DUT_HIER_PATH.gen_ext_outclkdiv.`DUT_HW_PATH);
        assign pll_hw_clkv    = `PLL_HW__CLKV(`DUT_HIER_PATH.gen_ext_outclkdiv.`DUT_HW_PATH);
        assign pll_hw_clks    = `PLL_HW__CLKS(`DUT_HIER_PATH.gen_ext_outclkdiv.`DUT_HW_PATH);
        assign pll_hw_ssen    = `PLL_HW__SSEN(`DUT_HIER_PATH.gen_ext_outclkdiv.`DUT_HW_PATH);
        assign pll_hw_dithen  = `PLL_HW__DITHEN(`DUT_HIER_PATH.gen_ext_outclkdiv.`DUT_HW_PATH);
        assign pll_hw_intfb   = `PLL_HW__INTFB(`DUT_HIER_PATH.gen_ext_outclkdiv.`DUT_HW_PATH);
        assign pll_hw_fasten  = `PLL_HW__FASTEN(`DUT_HIER_PATH.gen_ext_outclkdiv.`DUT_HW_PATH);
        assign pll_hw_ensat   = `PLL_HW__ENSAT(`DUT_HIER_PATH.gen_ext_outclkdiv.`DUT_HW_PATH);
        assign pll_hw_clkod_0 = `PLL_HW__CLKOD_0(`DUT_HIER_PATH.gen_ext_outclkdiv.`DUT_HW_PATH);
        assign pll_hw_clkod_1 = `PLL_HW__CLKOD_1(`DUT_HIER_PATH.gen_ext_outclkdiv.`DUT_HW_PATH);
        assign pll_hw_clkod_2 = `PLL_HW__CLKOD_2(`DUT_HIER_PATH.gen_ext_outclkdiv.`DUT_HW_PATH);
        assign pll_hw_clkod_3 = `PLL_HW__CLKOD_3(`DUT_HIER_PATH.gen_ext_outclkdiv.`DUT_HW_PATH);
        assign pll_hw_clkod_4 = `PLL_HW__CLKOD_4(`DUT_HIER_PATH.gen_ext_outclkdiv.`DUT_HW_PATH);
        assign pll_hw_clkod_5 = `PLL_HW__CLKOD_5(`DUT_HIER_PATH.gen_ext_outclkdiv.`DUT_HW_PATH);
        assign pll_hw_clkod_6 = `PLL_HW__CLKOD_6(`DUT_HIER_PATH.gen_ext_outclkdiv.`DUT_HW_PATH);
        assign pll_hw_clkod_7 = `PLL_HW__CLKOD_7(`DUT_HIER_PATH.gen_ext_outclkdiv.`DUT_HW_PATH);

        assign pll_hw_bypass[0]    = `PLL_HW__BYPASS0(`DUT_HIER_PATH.gen_ext_outclkdiv.`DUT_HW_CLKOUT);
        assign pll_hw_bypass[1]    = `PLL_HW__BYPASS1(`DUT_HIER_PATH.gen_ext_outclkdiv.`DUT_HW_CLKOUT);
        assign pll_hw_bypass[2]    = `PLL_HW__BYPASS2(`DUT_HIER_PATH.gen_ext_outclkdiv.`DUT_HW_CLKOUT);
        assign pll_hw_bypass[3]    = `PLL_HW__BYPASS3(`DUT_HIER_PATH.gen_ext_outclkdiv.`DUT_HW_CLKOUT);
        assign pll_hw_bypass[4]    = `PLL_HW__BYPASS4(`DUT_HIER_PATH.gen_ext_outclkdiv.`DUT_HW_CLKOUT);
        assign pll_hw_bypass[5]    = `PLL_HW__BYPASS5(`DUT_HIER_PATH.gen_ext_outclkdiv.`DUT_HW_CLKOUT);
        assign pll_hw_bypass[6]    = `PLL_HW__BYPASS6(`DUT_HIER_PATH.gen_ext_outclkdiv.`DUT_HW_CLKOUT);
        assign pll_hw_bypass[7]    = `PLL_HW__BYPASS7(`DUT_HIER_PATH.gen_ext_outclkdiv.`DUT_HW_CLKOUT);

        assign pll_hw_lmmi_dela    = `PLL_HW__DELA(`DUT_HIER_PATH.gen_ext_outclkdiv.`DUT_HW_CLKOUT);
        assign pll_hw_lmmi_delb    = `PLL_HW__DELB(`DUT_HIER_PATH.gen_ext_outclkdiv.`DUT_HW_CLKOUT);
        assign pll_hw_lmmi_delc    = `PLL_HW__DELC(`DUT_HIER_PATH.gen_ext_outclkdiv.`DUT_HW_CLKOUT);
        assign pll_hw_lmmi_deld    = `PLL_HW__DELD(`DUT_HIER_PATH.gen_ext_outclkdiv.`DUT_HW_CLKOUT);
        assign pll_hw_lmmi_dele    = `PLL_HW__DELE(`DUT_HIER_PATH.gen_ext_outclkdiv.`DUT_HW_CLKOUT);
        assign pll_hw_lmmi_delf    = `PLL_HW__DELF(`DUT_HIER_PATH.gen_ext_outclkdiv.`DUT_HW_CLKOUT);
        assign pll_hw_lmmi_delphy  = `PLL_HW__DELPHY(`DUT_HIER_PATH.gen_ext_outclkdiv.`DUT_HW_CLKOUT);
        assign pll_hw_lmmi_delclk7 = `PLL_HW__DELCLK7(`DUT_HIER_PATH.gen_ext_outclkdiv.`DUT_HW_CLKOUT);
        assign pll_hw_lmmi_diva    = `PLL_HW__DIVA(`DUT_HIER_PATH.gen_ext_outclkdiv.`DUT_HW_CLKOUT);
        assign pll_hw_lmmi_divb    = `PLL_HW__DIVB(`DUT_HIER_PATH.gen_ext_outclkdiv.`DUT_HW_CLKOUT);
        assign pll_hw_lmmi_divc    = `PLL_HW__DIVC(`DUT_HIER_PATH.gen_ext_outclkdiv.`DUT_HW_CLKOUT);
        assign pll_hw_lmmi_divd    = `PLL_HW__DIVD(`DUT_HIER_PATH.gen_ext_outclkdiv.`DUT_HW_CLKOUT);
        assign pll_hw_lmmi_dive    = `PLL_HW__DIVE(`DUT_HIER_PATH.gen_ext_outclkdiv.`DUT_HW_CLKOUT);
        assign pll_hw_lmmi_divf    = `PLL_HW__DIVF(`DUT_HIER_PATH.gen_ext_outclkdiv.`DUT_HW_CLKOUT);
        assign pll_hw_lmmi_divphy  = `PLL_HW__DIVPHY(`DUT_HIER_PATH.gen_ext_outclkdiv.`DUT_HW_CLKOUT);
        assign pll_hw_lmmi_divclk7 = `PLL_HW__DIVCLK7(`DUT_HIER_PATH.gen_ext_outclkdiv.`DUT_HW_CLKOUT);
      end // gen_ext_outclkdiv
    //endgenerate

    initial begin
      wait(reset_done);
      repeat (5) @(posedge gsr_clk);
      // Check if HW parameters are correctly forwarded
      if(pll_hw_clkr      !== PLL_CLKR    ) begin $display("%t:[ERROR] Parameter mismatch! Expected CLKR     value = %0h : Actual value = %0h",$time, PLL_CLKR,    pll_hw_clkr)      ; param_mismatch = 1; end
      if(pll_hw_clkf      !== PLL_CLKF    ) begin $display("%t:[ERROR] Parameter mismatch! Expected CLKF     value = %0h : Actual value = %0h",$time, PLL_CLKF,    pll_hw_clkf)      ; param_mismatch = 1; end
      if(pll_hw_clkv      !== PLL_CLKV    ) begin $display("%t:[ERROR] Parameter mismatch! Expected CLKV     value = %0h : Actual value = %0h",$time, PLL_CLKV,    pll_hw_clkv)      ; param_mismatch = 1; end
      if(pll_hw_clks      !== PLL_CLKS    ) begin $display("%t:[ERROR] Parameter mismatch! Expected CLKS     value = %0h : Actual value = %0h",$time, PLL_CLKS,    pll_hw_clks)      ; param_mismatch = 1; end
      // no need to check due to dynamic BW initialization
      //if(pll_hw_bwadj     !== PLL_BWADJ   ) begin $display("%t:[ERROR] Parameter mismatch! Expected BWADJ    value = %0h : Actual value = %0h",$time, PLL_BWADJ,   pll_hw_bwadj)     ; param_mismatch = 1; end
      if(pll_hw_ssen      !== PLL_SSEN    ) begin $display("%t:[ERROR] Parameter mismatch! Expected SSEN     value = %0h : Actual value = %0h",$time, PLL_SSEN,    pll_hw_ssen)      ; param_mismatch = 1; end
      if(pll_hw_dithen    !== PLL_DITHEN  ) begin $display("%t:[ERROR] Parameter mismatch! Expected DITHEN   value = %0h : Actual value = %0h",$time, PLL_DITHEN,  pll_hw_dithen)    ; param_mismatch = 1; end
      if(pll_hw_intfb     !== PLL_INTFBK  ) begin $display("%t:[ERROR] Parameter mismatch! Expected INTFB    value = %0h : Actual value = %0h",$time, PLL_INTFBK,  pll_hw_intfb)     ; param_mismatch = 1; end
      if(pll_hw_fasten    !== EN_FAST_LOCK) begin $display("%t:[ERROR] Parameter mismatch! Expected FASTEN   value = %0h : Actual value = %0h",$time, EN_FAST_LOCK,pll_hw_fasten)    ; param_mismatch = 1; end
      if(pll_hw_ensat     !== PLL_ENSAT   ) begin $display("%t:[ERROR] Parameter mismatch! Expected ENSAT    value = %0h : Actual value = %0h",$time, PLL_ENSAT,   pll_hw_ensat)     ; param_mismatch = 1; end
      if(pll_hw_bypass[0] !== CLK0_BYP    ) begin $display("%t:[ERROR] Parameter mismatch! Expected BYPASS_0 value = %0h : Actual value = %0h",$time, CLK0_BYP,    pll_hw_bypass[0]) ; param_mismatch = 1; end
      if(pll_hw_bypass[1] !== CLK1_BYP    ) begin $display("%t:[ERROR] Parameter mismatch! Expected BYPASS_1 value = %0h : Actual value = %0h",$time, CLK1_BYP,    pll_hw_bypass[1]) ; param_mismatch = 1; end
      if(pll_hw_bypass[2] !== CLK2_BYP    ) begin $display("%t:[ERROR] Parameter mismatch! Expected BYPASS_2 value = %0h : Actual value = %0h",$time, CLK2_BYP,    pll_hw_bypass[2]) ; param_mismatch = 1; end
      if(pll_hw_bypass[3] !== CLK3_BYP    ) begin $display("%t:[ERROR] Parameter mismatch! Expected BYPASS_3 value = %0h : Actual value = %0h",$time, CLK3_BYP,    pll_hw_bypass[3]) ; param_mismatch = 1; end
      if(pll_hw_bypass[4] !== CLK4_BYP    ) begin $display("%t:[ERROR] Parameter mismatch! Expected BYPASS_4 value = %0h : Actual value = %0h",$time, CLK4_BYP,    pll_hw_bypass[4]) ; param_mismatch = 1; end
      if(pll_hw_bypass[5] !== CLK5_BYP    ) begin $display("%t:[ERROR] Parameter mismatch! Expected BYPASS_5 value = %0h : Actual value = %0h",$time, CLK5_BYP,    pll_hw_bypass[5]) ; param_mismatch = 1; end
      if(pll_hw_bypass[6] !== CLK6_BYP    ) begin $display("%t:[ERROR] Parameter mismatch! Expected BYPASS_6 value = %0h : Actual value = %0h",$time, CLK6_BYP,    pll_hw_bypass[6]) ; param_mismatch = 1; end
      if(EN_CLK7_OUT) begin
        if(pll_hw_bypass[7] !== CLK7_BYP  ) begin $display("%t:[ERROR] Parameter mismatch! Expected BYPASS_7 value = %0h : Actual value = %0h",$time, CLK7_BYP,    pll_hw_bypass[7]) ; param_mismatch = 1; end
      end
      if(EN_EXT_CLKDIV) begin
        if(pll_hw_lmmi_diva    !== PLL_CLKOD0) begin $display("%t:[ERROR] Parameter mismatch! Expected DIVA      value = %0h : Actual value = %0h",$time, PLL_CLKOD0,  pll_hw_lmmi_diva   )   ; param_mismatch = 1; end
        if(pll_hw_lmmi_divb    !== PLL_CLKOD1) begin $display("%t:[ERROR] Parameter mismatch! Expected DIVB      value = %0h : Actual value = %0h",$time, PLL_CLKOD1,  pll_hw_lmmi_divb   )   ; param_mismatch = 1; end
        if(pll_hw_lmmi_divc    !== PLL_CLKOD2) begin $display("%t:[ERROR] Parameter mismatch! Expected DIVC      value = %0h : Actual value = %0h",$time, PLL_CLKOD2,  pll_hw_lmmi_divc   )   ; param_mismatch = 1; end
        if(pll_hw_lmmi_divd    !== PLL_CLKOD3) begin $display("%t:[ERROR] Parameter mismatch! Expected DIVD      value = %0h : Actual value = %0h",$time, PLL_CLKOD3,  pll_hw_lmmi_divd   )   ; param_mismatch = 1; end
        if(pll_hw_lmmi_dive    !== PLL_CLKOD4) begin $display("%t:[ERROR] Parameter mismatch! Expected DIVE      value = %0h : Actual value = %0h",$time, PLL_CLKOD4,  pll_hw_lmmi_dive   )   ; param_mismatch = 1; end
        if(pll_hw_lmmi_divf    !== PLL_CLKOD5) begin $display("%t:[ERROR] Parameter mismatch! Expected DIVF      value = %0h : Actual value = %0h",$time, PLL_CLKOD5,  pll_hw_lmmi_divf   )   ; param_mismatch = 1; end
        if(pll_hw_lmmi_divphy  !== PLL_CLKOD6) begin $display("%t:[ERROR] Parameter mismatch! Expected DIVPHY    value = %0h : Actual value = %0h",$time, PLL_CLKOD6,  pll_hw_lmmi_divphy )   ; param_mismatch = 1; end
        if(EN_CLK7_OUT) begin
          if(pll_hw_lmmi_divclk7 !== PLL_CLKOD7) begin $display("%t:[ERROR] Parameter mismatch! Expected DIVCLK7   value = %0h : Actual value = %0h",$time, PLL_CLKOD7,  pll_hw_lmmi_divclk7)   ; param_mismatch = 1; end
        end

        if(pll_hw_lmmi_dela    !== (CLK0_DEL-1)) begin $display("%t:[ERROR] Parameter mismatch! Expected DELA      value = %0h : Actual value = %0h",$time, (CLK0_DEL-1),  pll_hw_lmmi_dela   )   ; param_mismatch = 1; end
        if(pll_hw_lmmi_delb    !== (CLK1_DEL-1)) begin $display("%t:[ERROR] Parameter mismatch! Expected DELB      value = %0h : Actual value = %0h",$time, (CLK1_DEL-1),  pll_hw_lmmi_delb   )   ; param_mismatch = 1; end
        if(pll_hw_lmmi_delc    !== (CLK2_DEL-1)) begin $display("%t:[ERROR] Parameter mismatch! Expected DELC      value = %0h : Actual value = %0h",$time, (CLK2_DEL-1),  pll_hw_lmmi_delc   )   ; param_mismatch = 1; end
        if(pll_hw_lmmi_deld    !== (CLK3_DEL-1)) begin $display("%t:[ERROR] Parameter mismatch! Expected DELD      value = %0h : Actual value = %0h",$time, (CLK3_DEL-1),  pll_hw_lmmi_deld   )   ; param_mismatch = 1; end
        if(pll_hw_lmmi_dele    !== (CLK4_DEL-1)) begin $display("%t:[ERROR] Parameter mismatch! Expected DELE      value = %0h : Actual value = %0h",$time, (CLK4_DEL-1),  pll_hw_lmmi_dele   )   ; param_mismatch = 1; end
        if(pll_hw_lmmi_delf    !== (CLK5_DEL-1)) begin $display("%t:[ERROR] Parameter mismatch! Expected DELF      value = %0h : Actual value = %0h",$time, (CLK5_DEL-1),  pll_hw_lmmi_delf   )   ; param_mismatch = 1; end
        if(pll_hw_lmmi_delphy  !== (CLK6_DEL-1)) begin $display("%t:[ERROR] Parameter mismatch! Expected DELPHY    value = %0h : Actual value = %0h",$time, (CLK6_DEL-1),  pll_hw_lmmi_delphy )   ; param_mismatch = 1; end
        if(EN_CLK7_OUT) begin
          if(pll_hw_lmmi_delclk7 !== (CLK7_DEL-1)) begin $display("%t:[ERROR] Parameter mismatch! Expected DELCLK7   value = %0h : Actual value = %0h",$time, (CLK7_DEL-1),  pll_hw_lmmi_delclk7)   ; param_mismatch = 1; end
        end
      end
      else begin
        if(pll_hw_clkod_0 !== PLL_CLKOD0  ) begin $display("%t:[ERROR] Parameter mismatch! Expected CLKOD0   value = %0h : Actual value = %0h",$time, PLL_CLKOD0,  pll_hw_clkod_0)   ; param_mismatch = 1; end
        if(pll_hw_clkod_1 !== PLL_CLKOD1  ) begin $display("%t:[ERROR] Parameter mismatch! Expected CLKOD1   value = %0h : Actual value = %0h",$time, PLL_CLKOD1,  pll_hw_clkod_1)   ; param_mismatch = 1; end
        if(pll_hw_clkod_2 !== PLL_CLKOD2  ) begin $display("%t:[ERROR] Parameter mismatch! Expected CLKOD2   value = %0h : Actual value = %0h",$time, PLL_CLKOD2,  pll_hw_clkod_2)   ; param_mismatch = 1; end
        if(pll_hw_clkod_3 !== PLL_CLKOD3  ) begin $display("%t:[ERROR] Parameter mismatch! Expected CLKOD3   value = %0h : Actual value = %0h",$time, PLL_CLKOD3,  pll_hw_clkod_3)   ; param_mismatch = 1; end
        if(pll_hw_clkod_4 !== PLL_CLKOD4  ) begin $display("%t:[ERROR] Parameter mismatch! Expected CLKOD4   value = %0h : Actual value = %0h",$time, PLL_CLKOD4,  pll_hw_clkod_4)   ; param_mismatch = 1; end
        if(pll_hw_clkod_5 !== PLL_CLKOD5  ) begin $display("%t:[ERROR] Parameter mismatch! Expected CLKOD5   value = %0h : Actual value = %0h",$time, PLL_CLKOD5,  pll_hw_clkod_5)   ; param_mismatch = 1; end
        if(pll_hw_clkod_6 !== PLL_CLKOD6  ) begin $display("%t:[ERROR] Parameter mismatch! Expected CLKOD6   value = %0h : Actual value = %0h",$time, PLL_CLKOD6,  pll_hw_clkod_6)   ; param_mismatch = 1; end
        if(EN_CLK7_OUT) begin
          if(pll_hw_clkod_7 !== PLL_CLKOD7) begin $display("%t:[ERROR] Parameter mismatch! Expected CLKOD7   value = %0h : Actual value = %0h",$time, PLL_CLKOD7,  pll_hw_clkod_7)   ; param_mismatch = 1; end
        end
      end
    end
  `endif
`endif
end // gen_rtl_sim
else begin : gen_gate_sim
  `include "dut_inst.v"
end // gen_gate_sim
endgenerate
`endif



endmodule //--tb_top--
`endif // __TESTBENCH__TB_TOP__

`ifndef __RTL_MODULE__CLOCK_CHECKER__
`define __RTL_MODULE__CLOCK_CHECKER__
`timescale 1ps / 1fs
//==========================================================================
// Module : clock_checker
//==========================================================================
module clock_checker #

( //--begin_param--
//----------------------------
// Parameters
//----------------------------
parameter                     CLK_NAME = "CLK",
parameter                     EXP_CLK_FREQ = 100.0,
parameter                     EXP_PHASE_SHIFT = 0.0,
parameter                     EN_PHASE_CHECK = 0,
parameter                     MAX_SAMPLE_CNT = 255

) //--end_param--

( //--begin_ports--
//----------------------------
// Inputs
//----------------------------

input                         rst_n,
input                         pllpd_en_n,   // power down active low
input                         testclk,
input                         phase_0_testclk,
input                         lock,

//----------------------------
// Outputs
//----------------------------
output wire                   error_detected,
output reg                    test_done

); //--end_ports--


function [31:0] clog2 ;
    input [31:0] value ;
    reg [31:0] num ;
    begin
        num = (value - 1) ;
        for (clog2 = 0 ; (num > 0) ; clog2 = (clog2 + 1))
            num = (num >> 1) ;
    end
endfunction

//--------------------------------------------------------------------------
//--- Local Parameters/Defines ---
//--------------------------------------------------------------------------
localparam                    CNTWID = clog2(MAX_SAMPLE_CNT+1);

//--------------------------------------------------------------------------
//--- Combinational Wire/Reg ---
//--------------------------------------------------------------------------

//--------------------------------------------------------------------------
//--- Registers ---
//--------------------------------------------------------------------------

reg                           lock_testclk;
reg                           testclk_div2_pos;
reg                           testclk_div2_neg;
reg                           testclk_div4_pos;
reg         [CNTWID-1:0]      testclk_sample_cntr;
reg                           freq_error;
reg                           phase_error;

realtime                      pos_time_testclk;
realtime                      neg_time_testclk;
realtime                      phase_0_time;
realtime                      phase_testclk_time;

real                          obs_testclk_timediff;
real                          obs_testclk_freq;
real                          obs_phase_shift;
real                          obs_phase_timediff;

assign                        error_detected = freq_error | phase_error;

initial begin
  lock_testclk = 1'd0;
  testclk_div2_pos = 1'b0;
  testclk_div2_neg = 1'b0;
  testclk_div4_pos = 1'b0;
  testclk_sample_cntr = {CNTWID{1'b0}};
  test_done = 0;
  pos_time_testclk = 0;
  neg_time_testclk = 0;
  phase_0_time = 0;
  phase_testclk_time = 0;
  freq_error = 1'd0;
  phase_error = 1'd0;
  obs_phase_shift = 0;
  obs_phase_timediff = 0;
end

//    +----+    +----+    +----+    +----+    +----+    +----+    +----+    +----+    +--
//    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |  phase 0 clock
//----+    +----+    +----+    +----+    +----+    +----+    +----+    +----+    +----+
//
//              |                   |                   |                   |
//              |                   |                   |                   |
//              V                   V                   V                   V
//      phase time1               time1               time1               time1
//
//       +----+    +----+    +----+    +----+    +----+    +----+    +----+    +----+
//       |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    testclk
//   ----+    +----+    +----+    +----+    +----+    +----+    +----+    +----+    +----
//
//                 |                   |                   |                   |
//                 |                   |                   |                   |
//                 V                   V                   V                   V
//         phase time2               time2               time2               time2
//
//    phase shift = 360*EXP_CLK_FREQ*(time2-time1)*(1e-6)
//
//       +---------+         +---------+         +---------+         +---------+
//       |         |         |         |         |         |         |         |         divide by 2 clock
//   ----+         +---------+         +---------+         +---------+         +---------
//
//
//       +-------------------+                   +-------------------+                   divide by 4 clock will serve as
//       |                   |                   |                   |                   enable for checking
//   ----+                   +-------------------+                   +-------------------
//
//
//            +---------+         +---------+         +---------+         +---------+    divide by 2 clock
//            |         |         |         |         |         |         |         |    shifted by 90
//   ---------+         +---------+         +---------+         +---------+         +----
//
//            |         |         |         |         |         |         |         |
//            |         |         |         |         |         |         |         |
//            |         V         |         V         |         V         |         V
//            |       time2       |       time2       |       time2       |       time2
//            V                   V                   V                   V
//          time1               time1               time1               time1
//
//    clock frequency = (1e6 MHz) / abs(time2-time1)

always @(posedge phase_0_testclk or negedge rst_n) begin
  if(~rst_n) begin
    phase_0_time <= 0;
  end
  else begin
    if(lock_testclk & pllpd_en_n) begin
      if(testclk_div2_pos & testclk_div4_pos)
        phase_0_time <= $time;
    end
  end
end

always @(posedge testclk or negedge rst_n) begin
  if(~rst_n) begin
    lock_testclk <= 1'd0;
  end
  else begin
    lock_testclk <= lock;
  end
end

// Generate a divide by 2 version of the clock
always @(posedge testclk or negedge rst_n) begin
  if(~rst_n) begin
    testclk_div2_pos <= 1'd0;
    phase_testclk_time <= 0;
  end
  else begin
    if(lock_testclk & pllpd_en_n) begin
      testclk_div2_pos <= ~testclk_div2_pos;
      if(testclk_div2_neg & testclk_div4_pos)
        phase_testclk_time <= $time;
    end
  end
end

// Generate a divide by 4 version of the clock
// This will be used as enable signal for checking the timestamp
always @(posedge testclk_div2_pos or negedge rst_n) begin
  if(~rst_n) begin
    testclk_div4_pos <= 1'd0;
  end
  else begin
    if(lock_testclk & pllpd_en_n & ~test_done) begin
      testclk_div4_pos <= ~testclk_div4_pos;
    end
  end
end

// counter for ending simulation
always @(posedge testclk_div4_pos or negedge rst_n) begin
  if(~rst_n) begin
    testclk_sample_cntr <= {CNTWID{1'b0}};
    test_done <= 1'd0;
  end
  else begin
    if(lock_testclk & pllpd_en_n) begin
      testclk_sample_cntr <= (testclk_sample_cntr==MAX_SAMPLE_CNT)? testclk_sample_cntr : testclk_sample_cntr + 1;
      test_done <= (testclk_sample_cntr==MAX_SAMPLE_CNT);
    end
  end
end

// Generate a divide by 2 version of the clock with 90 degress shift
// The timestamp will be sampled at posedge and negedge of this div2 clock
always @(negedge testclk or negedge rst_n) begin
  if(~rst_n) begin
    testclk_div2_neg <= 1'd0;
  end
  else begin
    if(lock_testclk & pllpd_en_n) begin
      testclk_div2_neg <= ~testclk_div2_neg & testclk_div2_pos;
    end
  end
end

// Sample time at posedge and negedge of divide by 2 clock
always @(posedge testclk_div2_neg or negedge rst_n) begin
  if(~rst_n) begin
    pos_time_testclk <= 0;
  end
  else begin
    if(testclk_div4_pos)
      pos_time_testclk <= $time;
  end
end

always @(negedge testclk_div2_neg or negedge rst_n) begin
  if(~rst_n) begin
    neg_time_testclk <= 0;
  end
  else begin
    if(testclk_div4_pos)
      neg_time_testclk <= $time;
  end
end

// Check timestamp difference
always @(negedge testclk_div4_pos or negedge rst_n) begin
  if(rst_n & lock_testclk & pllpd_en_n) begin
    obs_testclk_timediff = (neg_time_testclk > pos_time_testclk)? (neg_time_testclk - pos_time_testclk) :
                                                                  (pos_time_testclk - neg_time_testclk);
    obs_testclk_freq     = 1000000.0/obs_testclk_timediff;
    `ifdef PLL_DEBUG
      $display("%t:[DEBUG] %s observed period : %f ps (Freq: %f MHz)  (POS1:%t, POS2:%t) ",
               $time,CLK_NAME,obs_testclk_timediff,obs_testclk_freq,neg_time_testclk,pos_time_testclk);
    `endif
    if(( ((EXP_CLK_FREQ > obs_testclk_freq) && ((EXP_CLK_FREQ - obs_testclk_freq)/EXP_CLK_FREQ) > 0.1) ||
         ((EXP_CLK_FREQ < obs_testclk_freq) && ((obs_testclk_freq - EXP_CLK_FREQ)/EXP_CLK_FREQ) > 0.1)
       ) && lock_testclk == 1 && test_done == 0) begin
      freq_error = 1'b1;
      $display("%t:[ERROR] Frequency Mismatch. %s observed period : %f ps (Freq: %f MHz)  (POS1:%t, POS2:%t) : Expected Frequency = %f ",
               $time,CLK_NAME,obs_testclk_timediff,obs_testclk_freq,neg_time_testclk,pos_time_testclk,EXP_CLK_FREQ);
    end

    if(EN_PHASE_CHECK & EXP_PHASE_SHIFT > 0) begin
      obs_phase_timediff = phase_testclk_time-phase_0_time;
      obs_phase_shift    = (360*EXP_CLK_FREQ*obs_phase_timediff)/1000000.0;
      `ifdef PLL_DEBUG
        $display("%t:[DEBUG] %s observed phase shift : %f degrees (TimeDiff: %f ps)  (POS1:%t, POS2:%t) ",
                 $time,CLK_NAME,obs_phase_shift,obs_phase_timediff,phase_0_time,phase_testclk_time);
      `endif
      if(( ((EXP_PHASE_SHIFT > obs_phase_shift) && ((EXP_PHASE_SHIFT-obs_phase_shift)/EXP_PHASE_SHIFT) > 0.1) ||
           ((EXP_PHASE_SHIFT < obs_phase_shift) && ((obs_phase_shift-EXP_PHASE_SHIFT)/EXP_PHASE_SHIFT) > 0.1)
         ) && lock_testclk == 1 && test_done == 0) begin
        phase_error = 1'b1;
        $display("%t:[ERROR] Phase Mismatch. %s observed phase shift : %f degrees (TimeDiff: %f ps)  (POS1:%t, POS2:%t) : Expected Phase Shift = %f ",
                 $time,CLK_NAME,obs_phase_shift,obs_phase_timediff,phase_0_time,phase_testclk_time,EXP_PHASE_SHIFT);
      end
    end
  end
end

// End of clock test
always @* begin
  if(test_done) begin
    $display("%t:[INFO] Maximum sampling count reached (%d).Done test for clock %s.",$time,testclk_sample_cntr,CLK_NAME);
  end
end

//--------------------------------------------------------------------------
//--- Module Instantiation ---
//--------------------------------------------------------------------------


endmodule //--clock_checker--
`endif // __RTL_MODULE__CLOCK_CHECKER__
