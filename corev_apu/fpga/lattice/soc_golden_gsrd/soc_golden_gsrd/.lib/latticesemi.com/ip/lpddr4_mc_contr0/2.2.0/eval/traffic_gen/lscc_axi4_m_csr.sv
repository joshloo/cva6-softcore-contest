// =============================================================================
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
// -----------------------------------------------------------------------------
//   Copyright (c) 2022 by Lattice Semiconductor Corporation
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
// File                  : lscc_axi4_m_csr.v
// Title                 :
// Dependencies          : 1.
//                       : 2.
// Description           :
// =============================================================================
//                        REVISION HISTORY
// Version               : 1.0.0
// Author(s)             :
// Mod. Date             :
// Changes Made          : Initial release.
// =============================================================================

module lscc_axi4_m_csr
#(
parameter GEN_IN_WIDTH   = 1,
parameter GEN_OUT_WIDTH  = 4,
parameter APB_ADDR_WIDTH = 1,
parameter APB_DATA_WIDTH = 1,
parameter AXI_LEN_WIDTH  = 0,
parameter AXI_ADDR_WIDTH = 0,
parameter AXI_DATA_WIDTH = 32,
parameter DDR_CMD_FREQ   = 0.0,
parameter AXI_ID_WIDTH   = 1
)
(  

//CLOCKS AND RESETS

input                             pclk_i    ,
input                             preset_n_i,
input                             aclk_i    ,
input                             areset_n_i,
output                            p_rd_error_occur_o,

// General Input
input        [GEN_IN_WIDTH-1:0]   gen_in_i  ,
input        [31:0]               duration_cntr_status_sclk_i,
input        [31:0]               duration_cntr_status_aclk_i,
input        [31:0]               total_num_wr_rd_i , 
input                             wr_timeout_i,
input                             rd_timeout_i,

// General Output - used for showing the test number
output logic [GEN_OUT_WIDTH-1:0]  a_gen_out_o,
output logic [GEN_OUT_WIDTH-1:0]  p_gen_out_o,


//APB INTERFACE SIGNALS
input                             apb_psel,
input                             apb_penable,
input                             apb_pwrite,
input        [APB_ADDR_WIDTH-1:0] apb_paddr,
input        [APB_DATA_WIDTH-1:0] apb_pwdata,

output logic                      apb_pready,
output logic [APB_DATA_WIDTH-1:0] apb_prdata,
output logic                      apb_pslverr,

// OUTPUT SIGNALS TO AXI MASTER
// Added "cfg_" prefix so it is easier to constrain
// Non APB ports are based on aclk_i
 output logic [AXI_LEN_WIDTH-1:0]cfg_awlen           ,             
 output logic [1:0]              cfg_awburst         ,
 output logic [2:0]              cfg_awsize          ,            
 output logic [AXI_ID_WIDTH-1:0] cfg_awid            ,
 output logic [31:0]             cfg_wr_addr_seed    ,
 output logic [31:0]             cfg_wr_data_seed_1  ,    
 output logic [31:0]             cfg_wr_data_seed_2  ,    
 output logic [19:0]             cfg_num_of_wr_trans ,   
 output logic                    cfg_randomize_wraddr, 
 output logic                    cfg_randomize_wrctrl, 
 output logic [5:0]              cfg_wr_txn_delay    ,      
 output logic                    wr_start            ,
          
 output logic [AXI_LEN_WIDTH-1:0]cfg_arlen           ,             
 output logic [1:0]              cfg_arburst         ,           
 output logic [2:0]              cfg_arsize          ,           
 output logic [AXI_ID_WIDTH-1:0] cfg_arid            ,
 output logic                    cfg_fixed_araddr    ,
 output logic [31:0]             cfg_rd_addr_seed    ,      
 output logic [31:0]             cfg_rd_data_seed_1  ,    
 output logic [31:0]             cfg_rd_data_seed_2  ,    
 output logic [19:0]             cfg_num_of_rd_trans ,   
 output logic                    cfg_randomize_rdaddr, 
 output logic                    cfg_randomize_rdctrl, 
 output logic [5:0]              cfg_rd_txn_delay    ,      
 output logic                    rd_start            ,          
// INPUT SIGNALS FROM AXI MASTER
 input                wr_txn_done, //after the num_of_wr_trans is acheived 
 input                rd_txn_done, //after the num_of_rd_trans is acheived
 input                rd_error   , // pulse when read error occur
 input        [19:0]  rd_txn_cnt

);

localparam WR_TXN_CTRL_REG         = 8'h00;
localparam WR_ADDR_SEED_REG        = 8'h04;
localparam WR_DATA_SEED1_REG       = 8'h08;
localparam WR_DATA_SEED2_REG       = 8'h0C;
localparam NUM_WR_TXN_REG          = 8'h10;
localparam WR_CTRL_REG             = 8'h14;
localparam WR_TXN_STAT_REG         = 8'h18;
localparam WR_TXN_DELAY_REG        = 8'h20;
localparam WR_START_REG            = 8'h24;

localparam GEN_IN_REG              = 8'h30;
localparam GEN_OUT_REG             = 8'h34;

localparam RD_TXN_CTRL_REG         = 8'h40;
localparam RD_ADDR_SEED_REG        = 8'h44;
localparam RD_DATA_SEED1_REG       = 8'h48;
localparam RD_DATA_SEED2_REG       = 8'h4C;
localparam NUM_RD_TXN_REG          = 8'h50;
localparam RD_CTRL_REG             = 8'h54;
localparam RD_TXN_STAT_REG         = 8'h58;
localparam RD_ERR_CNT_REG          = 8'h5C;
localparam RD_TXN_DELAY_REG        = 8'h60;
localparam RD_START_REG            = 8'h64;
localparam DURATION_STAT_SCLK_REG  = 8'h68;
localparam DURATION_STAT_ACLK_REG  = 8'h6C;
localparam NUM_WR_RD_STAT_REG      = 8'h70;
localparam SCLK_FREQ_REG           = 8'h74; 
localparam EVAL_SCRATCH_0_REG      = 8'h80;
localparam EVAL_SCRATCH_1_REG      = 8'h84;

localparam SIZE_DEF_VAL            = (AXI_DATA_WIDTH ==  32) ? 3'h2 :
                                     (AXI_DATA_WIDTH ==  64) ? 3'h3 :
									 (AXI_DATA_WIDTH == 128) ? 3'h4 :
									 (AXI_DATA_WIDTH == 256) ? 3'h5 : 3'h6;

localparam SCLK_FREQ          = (DDR_CMD_FREQ / 4);
// Added "csr_" prefix so it is easier to constrain
logic [AXI_LEN_WIDTH-1:0]csr_awlen           ;             
logic [1:0]              csr_awburst         ;
logic [2:0]              csr_awsize          ;
logic [AXI_ID_WIDTH-1:0] csr_awid            ;
logic [6:0]              csr_axi_addr_width  ;
logic [31:0]             csr_wr_addr_seed    ;
logic [31:0]             csr_wr_data_seed_1  ;    
logic [31:0]             csr_wr_data_seed_2  ;    
logic [19:0]             csr_num_of_wr_trans ;   
logic                    csr_randomize_wraddr; 
logic                    csr_randomize_wrctrl; 
logic [5:0]              csr_wr_txn_delay    ;      
//logic                    wr_start            ;
			             
logic [AXI_LEN_WIDTH-1:0]csr_arlen           ;             
logic [1:0]              csr_arburst         ;           
logic [2:0]              csr_arsize          ;           
logic [AXI_ID_WIDTH-1:0] csr_arid            ;
logic                    csr_fixed_araddr    ;
logic [31:0]             csr_rd_addr_seed    ;      
logic [31:0]             csr_rd_data_seed_1  ;    
logic [31:0]             csr_rd_data_seed_2  ;    
logic [19:0]             csr_num_of_rd_trans ;   
logic                    csr_randomize_rdaddr; 
logic                    csr_randomize_rdctrl; 
logic [5:0]              csr_rd_txn_delay    ;      
//logic                    csr_rd_start        ;   
			             
logic                    csr_wr_txn_done;
logic                    csr_rd_txn_done;
logic                    csr_rd_error_occur;
logic [19:0]             csr_rd_error_first;
logic [7:0]              csr_error_cnt;

logic [31:0]               duration_cntr_status_sclk_r;
logic [31:0]               duration_cntr_status_aclk_r;
logic [31:0]               total_num_wr_rd_r;
logic                      csr_rd_txn_done_r;
logic                      csr_rd_txn_done_pulse;
logic                      csr_rd_txn_done_pulse_r;

logic                      p_wr_start_pulse_r;
logic                      p_rd_start_pulse_r;

logic [APB_DATA_WIDTH-1:0] sig_apb_prdata;
logic [APB_ADDR_WIDTH-1:0] apb_paddr_r;
logic                      apb_wr_r;
logic                      apb_rd_r;
logic [APB_DATA_WIDTH-1:0] apb_pwdata_r;

logic [GEN_IN_WIDTH-1:0]   gen_in_r;
logic [GEN_IN_WIDTH-1:0]   rvl_p_gen_in_r;
logic [GEN_OUT_WIDTH-1:0]  gen_out_r;
logic [GEN_OUT_WIDTH-1:0]  gen_out_r2/* synthesis syn_preserve=1 CDC_Register=2 */;

logic [15:0] scratch_1_r;
logic [31:0] scratch_0_r;

logic        a_wr_timeout_r ;
logic        p_wr_timeout_r1/* synthesis syn_preserve=1 CDC_Register=2 */;
logic        p_wr_timeout_r2;
logic        a_rd_timeout_r ;
logic        p_rd_timeout_r1/* synthesis syn_preserve=1 CDC_Register=2 */;
logic        p_rd_timeout_r2;


assign apb_pslverr        = 1'b0;
assign p_rd_error_occur_o = csr_rd_error_occur;
assign csr_axi_addr_width = (AXI_ADDR_WIDTH);
// These registers are static during operation
// FIXME: Explore option to remove this extra register stage
always_ff @(posedge aclk_i or negedge areset_n_i) begin
  if(!areset_n_i) begin
    cfg_awlen            <= 'h0;
    cfg_awburst          <= 'h0;
    cfg_awsize           <= 'h0;
	cfg_awid             <= 'h0;
    cfg_wr_addr_seed     <= 'h0;
    cfg_wr_data_seed_1   <= 'h0;
    cfg_wr_data_seed_2   <= 'h0;
    cfg_num_of_wr_trans  <= 'h0;
    cfg_randomize_wraddr <= 'h0;
    cfg_randomize_wrctrl <= 'h0;
    cfg_wr_txn_delay     <= 'h0;
    cfg_arlen            <= 'h0;
    cfg_arburst          <= 'h0;
    cfg_arsize           <= 'h0;
	cfg_arid             <= 'h0;
    cfg_fixed_araddr     <= 'h0;
    cfg_rd_addr_seed     <= 'h0;
    cfg_rd_data_seed_1   <= 'h0;
    cfg_rd_data_seed_2   <= 'h0;
    cfg_num_of_rd_trans  <= 'h0;
    cfg_randomize_rdaddr <= 'h0;
    cfg_randomize_rdctrl <= 'h0;
    cfg_rd_txn_delay     <= 'h0;
  end
  else begin
    cfg_awlen            <= csr_awlen           ;
    cfg_awburst          <= csr_awburst         ;
    cfg_awsize           <= csr_awsize          ;
	cfg_awid             <= csr_awid            ;
    cfg_wr_addr_seed     <= csr_wr_addr_seed    ;
    cfg_wr_data_seed_1   <= csr_wr_data_seed_1  ;
    cfg_wr_data_seed_2   <= csr_wr_data_seed_2  ;
    cfg_num_of_wr_trans  <= csr_num_of_wr_trans ;
    cfg_randomize_wraddr <= csr_randomize_wraddr;
    cfg_randomize_wrctrl <= csr_randomize_wrctrl;
    cfg_wr_txn_delay     <= csr_wr_txn_delay    ;
    cfg_arlen            <= csr_arlen           ;
    cfg_arburst          <= csr_arburst         ;
    cfg_arsize           <= csr_arsize          ;
	cfg_arid             <= csr_arid            ;
    cfg_fixed_araddr     <= csr_fixed_araddr    ;
    cfg_rd_addr_seed     <= csr_rd_addr_seed    ;
    cfg_rd_data_seed_1   <= csr_rd_data_seed_1  ;
    cfg_rd_data_seed_2   <= csr_rd_data_seed_2  ;
    cfg_num_of_rd_trans  <= csr_num_of_rd_trans ;
    cfg_randomize_rdaddr <= csr_randomize_rdaddr;
    cfg_randomize_rdctrl <= csr_randomize_rdctrl;
    cfg_rd_txn_delay     <= csr_rd_txn_delay    ;
  end
end

// Wite status logic
logic cdc_r1_wr_txn_done/* synthesis syn_preserve=1 CDC_Register=2 */;
logic cdc_r2_wr_txn_done;
//logic cdc_r3_wr_txn_done;

always_ff @(posedge pclk_i or negedge preset_n_i) begin
  if(!preset_n_i) begin
    cdc_r1_wr_txn_done <= 1'b0;
    cdc_r2_wr_txn_done <= 1'b0;
    csr_wr_txn_done    <= 1'b0;
  end
  else begin
    cdc_r1_wr_txn_done <= wr_txn_done;
    cdc_r2_wr_txn_done <= cdc_r1_wr_txn_done;
    if(apb_wr_r & (apb_paddr_r == WR_START_REG) & apb_pwdata_r[0])
	  csr_wr_txn_done  <= 1'b0;
	else 
	  csr_wr_txn_done  <= cdc_r2_wr_txn_done;
  end
end

// Read status logic
logic cdc_r1_rd_txn_done/* synthesis syn_preserve=1 CDC_Register=2 */;
logic cdc_r2_rd_txn_done;
logic cdc_r3_rd_txn_done;

always_ff @(posedge pclk_i or negedge preset_n_i) begin
  if(!preset_n_i) begin
    cdc_r1_rd_txn_done <= 1'b0;
    cdc_r2_rd_txn_done <= 1'b0;
    cdc_r3_rd_txn_done <= 1'b0;
    csr_rd_txn_done    <= 1'b0;
  end
  else begin
    cdc_r1_rd_txn_done <= rd_txn_done;
    cdc_r2_rd_txn_done <= cdc_r1_rd_txn_done;
    cdc_r3_rd_txn_done <= cdc_r2_rd_txn_done;
//	if (cdc_r3_rd_txn_done != cdc_r2_rd_txn_done)
//      csr_rd_txn_done  <= 1'b1;
//	else if(apb_wr_r & (apb_paddr_r == RD_START_REG) & apb_pwdata_r[0])
    if(apb_wr_r & (apb_paddr_r == RD_START_REG) & apb_pwdata_r[0])
	  csr_rd_txn_done  <= 1'b0;
	else 
	  csr_rd_txn_done  <= cdc_r2_rd_txn_done;
  end
end

logic         a2p_tg_rd_error;
logic         a2p_rd_error_occur;
logic [19:0]  a2p_rd_error_first;
logic [7:0]   a2p_error_cnt;
logic [2:0]   err_upd_cnt  ;

always_ff @(posedge aclk_i or negedge areset_n_i) begin
  if(!areset_n_i) begin
    a2p_tg_rd_error        <= 1'b0;
	a2p_rd_error_occur <= 1'b0;
	a2p_rd_error_first <= 20'h00000;
	a2p_error_cnt      <= 8'h00;
	err_upd_cnt        <= 3'h0;
  end
  else begin
    if(rd_start) begin
      a2p_rd_error_occur   <= 1'b0;
    end 
    else if(rd_error) begin
	  err_upd_cnt          <= 3'h0;
	  if (err_upd_cnt == 3'h7) // only transfer information to pclk at min of 8
        a2p_tg_rd_error    <= ~a2p_tg_rd_error;
	  a2p_rd_error_occur   <= 1'b1;
	  if (a2p_rd_error_occur == 0) // save the rd_txn_cnt on 1st error
	    a2p_rd_error_first <= rd_txn_cnt;
	  if (a2p_error_cnt != 8'hFF)
	    a2p_error_cnt      <= a2p_error_cnt + 8'h01;
	end 
	else begin
	  err_upd_cnt <= err_upd_cnt + 3'h1;
	end
  end
end

logic cdc_r1_rd_error/* synthesis syn_preserve=1 CDC_Register=2 */;
logic cdc_r2_rd_error;
logic cdc_r3_rd_error;

always_ff @(posedge pclk_i or negedge preset_n_i) begin
  if(!preset_n_i) begin
    cdc_r1_rd_error    <= 1'b0;
    cdc_r2_rd_error    <= 1'b0; 
    cdc_r3_rd_error    <= 1'b0;
    csr_rd_error_occur <= 1'b0;
    csr_rd_error_first <= 1'b0;
    csr_error_cnt      <= 'h0 ; 
       
  end
  else begin
    cdc_r1_rd_error <= a2p_tg_rd_error;
	cdc_r2_rd_error <= cdc_r1_rd_error;
	cdc_r3_rd_error <= cdc_r2_rd_error;
	if ((cdc_r2_rd_error != cdc_r3_rd_error) || (cdc_r3_rd_txn_done != cdc_r2_rd_txn_done)) begin
	  csr_rd_error_occur <= a2p_rd_error_occur;
	  csr_rd_error_first <= a2p_rd_error_first;
	  csr_error_cnt      <= a2p_error_cnt     ;
	end
  end
end


/////////////////////////////////////////////////////////////
//APB WRITE and READ
/////////////////////////////////////////////////////////////

//assign apb_wr = apb_psel & apb_penable &  apb_pwrite;
//assign apb_rd = apb_psel & apb_penable & !apb_pwrite;
logic  is_setup;
assign is_setup = apb_psel & ~apb_penable;

always_ff @(posedge pclk_i or negedge preset_n_i) begin
  if(!preset_n_i) begin
    apb_pready   <= 0;
    apb_paddr_r  <= {APB_ADDR_WIDTH{1'b0}};
    apb_wr_r     <= 1'b0;
    apb_rd_r     <= 1'b0;
	apb_pwdata_r <= {APB_DATA_WIDTH{1'b0}};
  end
  else begin
    apb_pready   <= (is_setup & apb_pwrite) | apb_rd_r;  // read has +1 cycle latency
    apb_paddr_r  <= apb_paddr;
    apb_wr_r     <= is_setup &  apb_pwrite;
    apb_rd_r     <= is_setup & !apb_pwrite;
	apb_pwdata_r <= apb_pwdata;
  end
end

always_ff @(posedge pclk_i or negedge preset_n_i) begin
  if(!preset_n_i)
    apb_prdata <= 0;
  else if(apb_rd_r)
    apb_prdata <= sig_apb_prdata;
end

always_ff @(posedge pclk_i or negedge preset_n_i) begin
  if(!preset_n_i) begin
    gen_in_r       <= 0;
    rvl_p_gen_in_r <= 0;
  end
  else begin
    gen_in_r       <= gen_in_i;
    rvl_p_gen_in_r <= gen_in_r;
  end
end

assign csr_rd_txn_done_pulse = cdc_r3_rd_txn_done & ~csr_rd_txn_done_r;

always_ff @(posedge pclk_i or negedge preset_n_i) begin
  if(!preset_n_i) begin
    csr_rd_txn_done_r           <= 1'b0;
    csr_rd_txn_done_pulse_r     <= 1'b0;;
    duration_cntr_status_aclk_r <= 32'b0;
    duration_cntr_status_sclk_r <= 32'b0;
    total_num_wr_rd_r           <= 32'b0;
  end 
  else begin
    csr_rd_txn_done_pulse_r  <= csr_rd_txn_done_pulse;
    csr_rd_txn_done_r        <= cdc_r3_rd_txn_done;
    // These signals are pseudo static. 
    if (p_wr_start_pulse_r | p_rd_start_pulse_r) begin
      duration_cntr_status_aclk_r  <= 'h0; 
      duration_cntr_status_sclk_r  <= 'h0;
      total_num_wr_rd_r            <= 'h0;
    end
    else if(csr_rd_txn_done_pulse_r) begin
      duration_cntr_status_aclk_r  <= duration_cntr_status_aclk_i ; //The csr_rd_txn_done_pulse_r is ~4 PCLK delay from the aclk register update 
      duration_cntr_status_sclk_r  <= duration_cntr_status_sclk_i ; //The csr_rd_txn_done_pulse_r is ~2 PCLK from sclk register update.
      total_num_wr_rd_r            <= total_num_wr_rd_i  ;
    end
  end 
end 

///////////////////////////////////////////////////////////////////////////////
/////////////////////////REGISTER READS////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

always_comb
begin
sig_apb_prdata = 0;

case(apb_paddr_r)
WR_TXN_CTRL_REG    : begin 
                       sig_apb_prdata[AXI_LEN_WIDTH-1:0]  = csr_awlen  ; 
					   sig_apb_prdata[9:8]                = csr_awburst;
					   sig_apb_prdata[12:10]              = csr_awsize ;
					   sig_apb_prdata[AXI_ID_WIDTH+12:13] = csr_awid   ;
                                           sig_apb_prdata[26:21]              = csr_axi_addr_width;
					 end
WR_ADDR_SEED_REG   : sig_apb_prdata        = csr_wr_addr_seed  ;
WR_DATA_SEED1_REG  : sig_apb_prdata        = csr_wr_data_seed_1; 
WR_DATA_SEED2_REG  : sig_apb_prdata        = csr_wr_data_seed_2; 
NUM_WR_TXN_REG     : sig_apb_prdata[19:0]  = csr_num_of_wr_trans[19:0]; 
WR_CTRL_REG        : sig_apb_prdata[1:0]   = {csr_randomize_wrctrl, csr_randomize_wraddr}; 
WR_TXN_STAT_REG    : sig_apb_prdata[2:0]   = {p_wr_timeout_r2, 1'b0, csr_wr_txn_done}; 
WR_TXN_DELAY_REG   : sig_apb_prdata[5:0]   = csr_wr_txn_delay  ; 
//WR_START_REG       : sig_apb_prdata =WR_START      ;  // This is WO
GEN_IN_REG         : sig_apb_prdata        = (GEN_IN_WIDTH == 0 ? 32'h0 :{{(32-GEN_IN_WIDTH){1'b0}}, gen_in_r});

RD_TXN_CTRL_REG    : begin 
                       sig_apb_prdata[AXI_LEN_WIDTH-1:0]  = csr_arlen  ; 
					   sig_apb_prdata[9:8]                = csr_arburst;
					   sig_apb_prdata[12:10]              = csr_arsize ;
					   sig_apb_prdata[AXI_ID_WIDTH+12:13] = csr_arid   ;
                       sig_apb_prdata[31]                 = csr_fixed_araddr;
					 end 
RD_ADDR_SEED_REG   : sig_apb_prdata       = csr_rd_addr_seed   ;
RD_DATA_SEED1_REG  : sig_apb_prdata       = csr_rd_data_seed_1 ; 
RD_DATA_SEED2_REG  : sig_apb_prdata       = csr_rd_data_seed_2 ; 
NUM_RD_TXN_REG     : sig_apb_prdata[19:0] = csr_num_of_rd_trans; 
RD_CTRL_REG        : sig_apb_prdata[1:0]  = {csr_randomize_rdctrl, csr_randomize_rdaddr}       ; 
RD_TXN_STAT_REG    : sig_apb_prdata[23:0] = {csr_rd_error_first, 1'b0, p_rd_timeout_r2, csr_rd_error_occur, csr_rd_txn_done}; 
RD_ERR_CNT_REG     : sig_apb_prdata[7:0]  = csr_error_cnt     ; 
RD_TXN_DELAY_REG   : sig_apb_prdata[5:0]  = csr_rd_txn_delay  ; 

DURATION_STAT_ACLK_REG    : sig_apb_prdata       = duration_cntr_status_aclk_r;
DURATION_STAT_SCLK_REG    : sig_apb_prdata       = duration_cntr_status_sclk_r;
NUM_WR_RD_STAT_REG   : sig_apb_prdata       = total_num_wr_rd_r;
SCLK_FREQ_REG        : sig_apb_prdata       = SCLK_FREQ        ;
EVAL_SCRATCH_1_REG   : sig_apb_prdata       = scratch_1_r[15:0]  ;
EVAL_SCRATCH_0_REG   : sig_apb_prdata       = scratch_0_r        ;

// RD_START_REG       : sig_apb_prdata = RD_START      ; // this is WO

endcase
end

///////////////////////////////////////////////////////////////////////////////
/////////////////////////REGISTER WRITES///////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
always_ff @(posedge pclk_i or negedge preset_n_i) begin
  if(!preset_n_i) begin
    scratch_1_r  <= 16'h0;
    scratch_0_r  <= 32'h0; 
  end 
  else if(apb_wr_r & apb_paddr_r == EVAL_SCRATCH_1_REG)  begin
    scratch_1_r <= apb_pwdata_r[15:0]; 
  end 
  else if(apb_wr_r & apb_paddr_r == EVAL_SCRATCH_0_REG)  begin
    scratch_0_r <= apb_pwdata_r; 
  end 
end 

// FIXME: Narrow transfer is not yet supported, full size for now
assign csr_awsize  = SIZE_DEF_VAL[2:0];

//WRITE TRANSACTION CONTROL REGISTER 00
// Use the registered address to cut the propagation delay
always_ff @(posedge pclk_i or negedge preset_n_i) begin
  if(!preset_n_i) begin
    csr_awlen   <= 'h0;
    csr_awburst <= 'h0;
//    csr_awsize  <= SIZE_DEF_VAL[2:0];
	csr_awid    <= 'h0;
  end
  else if(apb_wr_r & apb_paddr_r == WR_TXN_CTRL_REG) begin
    csr_awlen   <= apb_pwdata_r[AXI_LEN_WIDTH-1:0]  ;
    csr_awburst <= apb_pwdata_r[9:8]  ;
//    csr_awsize  <= apb_pwdata_r[12:10]; 
	csr_awid    <= apb_pwdata_r[AXI_ID_WIDTH+12:13]  ;
  end
end

//WRITE ADDR  SEED REGISTER 04
always_ff @(posedge pclk_i or negedge preset_n_i) begin
  if(!preset_n_i)
    csr_wr_addr_seed  <= 32'h0;
  else if(apb_wr_r & apb_paddr_r == WR_ADDR_SEED_REG)
    csr_wr_addr_seed  <= apb_pwdata_r;
end

//WRITE DATA SEED1 REGISTER 08
always_ff @(posedge pclk_i or negedge preset_n_i) begin
  if(!preset_n_i)
    csr_wr_data_seed_1 <= 32'h0;
  else if(apb_wr_r & apb_paddr_r == WR_DATA_SEED1_REG)
    csr_wr_data_seed_1 <= apb_pwdata_r;
end

//WRITE DATA SEED1 REGISTER 0C
always_ff @(posedge pclk_i or negedge preset_n_i) begin
  if(!preset_n_i)
    csr_wr_data_seed_2 <= 32'h0;
  else if(apb_wr_r & apb_paddr_r == WR_DATA_SEED2_REG)
    csr_wr_data_seed_2 <= apb_pwdata_r;
end

//NUMBER OF WRITE TRNASACTIONS REGISTER 10
always_ff @(posedge pclk_i or negedge preset_n_i) begin
  if(!preset_n_i)
    csr_num_of_wr_trans <= 20'h0;
  else if(apb_wr_r & apb_paddr_r == NUM_WR_TXN_REG)
    csr_num_of_wr_trans <= apb_pwdata_r[19:0];
end


always_ff @(posedge pclk_i or negedge preset_n_i) begin
  if(!preset_n_i) begin
    csr_randomize_wraddr <= 1'b0;
    csr_randomize_wrctrl <= 1'b0;
  end
  else if(apb_wr_r & apb_paddr_r == WR_CTRL_REG) begin
	csr_randomize_wraddr <= apb_pwdata_r[0];
	csr_randomize_wrctrl <= apb_pwdata_r[1];
  end
end // always_ff

always_ff @(posedge pclk_i or negedge preset_n_i) begin
  if(!preset_n_i)
    csr_wr_txn_delay <= 6'h00;
  else if(apb_wr_r & apb_paddr_r == WR_TXN_DELAY_REG)
    csr_wr_txn_delay <= apb_pwdata_r[5:0];
end // always_ff

logic p2a_tg_wr_start /* synthesis syn_preserve=1 */;

always_ff @(posedge pclk_i or negedge preset_n_i) begin
  if(!preset_n_i) begin
    p2a_tg_wr_start    <= 1'b0;
    p_wr_start_pulse_r <= 1'b0;
  end
  else begin
    p_wr_start_pulse_r   <= 1'b0;
    if(apb_wr_r & (apb_paddr_r == WR_START_REG) & apb_pwdata_r[0]) begin
      p2a_tg_wr_start    <= ~p2a_tg_wr_start;
      p_wr_start_pulse_r <= 1'b1;
    end
  end
end // always_ff

logic cdc_r1_wr_start /* synthesis syn_preserve=1 CDC_Register=2 */;
logic cdc_r2_wr_start;
logic cdc_r3_wr_start;

always_ff @(posedge aclk_i or negedge areset_n_i) begin
  if(!areset_n_i) begin
    cdc_r1_wr_start <= 1'b0;
	cdc_r2_wr_start <= 1'b0;
	cdc_r3_wr_start <= 1'b0;
	wr_start        <= 1'b0;
  end
  else begin
    cdc_r1_wr_start <= p2a_tg_wr_start;
	cdc_r2_wr_start <= cdc_r1_wr_start;
	cdc_r3_wr_start <= cdc_r2_wr_start;
	wr_start        <= cdc_r2_wr_start != cdc_r3_wr_start;
  end
end // always_ff

// FIXME: need to make this a register
assign csr_arsize  = SIZE_DEF_VAL[2:0];

always_ff @(posedge pclk_i or negedge preset_n_i) begin
  if(!preset_n_i) begin
    csr_arlen        <= 'h0;
	csr_arburst      <= 'h0;
	//csr_arsize       <= 'h0;
	csr_arid         <= 'h0;
    csr_fixed_araddr <= 'h0;
  end
  else if(apb_wr_r & apb_paddr_r == RD_TXN_CTRL_REG) begin
    csr_arlen        <= apb_pwdata_r[AXI_LEN_WIDTH-1:0];
	csr_arburst      <= apb_pwdata_r[9:8];
	//csr_arsize       <= apb_pwdata_r[12:10];
	csr_arid         <= apb_pwdata_r[AXI_ID_WIDTH+12:13];
    csr_fixed_araddr <= apb_pwdata_r[31];
  end
end // always_ff

always_ff @(posedge pclk_i or negedge preset_n_i) begin
  if(!preset_n_i)
    csr_rd_addr_seed  <= 32'h0;
  else if(apb_wr_r & apb_paddr_r == RD_ADDR_SEED_REG)
    csr_rd_addr_seed  <= apb_pwdata_r;
end // always_ff

always_ff @(posedge pclk_i or negedge preset_n_i) begin
  if(!preset_n_i)
    csr_rd_data_seed_1 <= 32'h0;
  else if(apb_wr_r & apb_paddr_r == RD_DATA_SEED1_REG)
    csr_rd_data_seed_1 <= apb_pwdata_r;
end // always_ff

always_ff @(posedge pclk_i or negedge preset_n_i) begin
  if(!preset_n_i)
    csr_rd_data_seed_2 <= 32'h0;
  else if(apb_wr_r & apb_paddr_r == RD_DATA_SEED2_REG)
    csr_rd_data_seed_2 <= apb_pwdata_r;
end // always_ff

always_ff @(posedge pclk_i or negedge preset_n_i) begin
  if(!preset_n_i)
    csr_num_of_rd_trans <= 20'h0;
  else if(apb_wr_r & apb_paddr_r == NUM_RD_TXN_REG)
    csr_num_of_rd_trans <= apb_pwdata_r[19:0];
end // always_ff


always_ff @(posedge pclk_i or negedge preset_n_i) begin
  if(!preset_n_i) begin
    csr_randomize_rdaddr <= 1'b0;
	csr_randomize_rdctrl <= 1'b0;
  end
  else if(apb_wr_r & apb_paddr_r == RD_CTRL_REG) begin
    csr_randomize_rdaddr <= apb_pwdata_r[0];
	csr_randomize_rdctrl <= apb_pwdata_r[1];
  end
end // always_ff

always_ff @(posedge pclk_i or negedge preset_n_i) begin
  if(!preset_n_i)
    csr_rd_txn_delay <= 32'h0;
  else if(apb_wr_r & apb_paddr_r == RD_TXN_DELAY_REG)
    csr_rd_txn_delay <= apb_pwdata_r[5:0];
end // always_ff

logic p2a_tg_rd_start;

always_ff @(posedge pclk_i or negedge preset_n_i) begin
  if(!preset_n_i) begin
    p2a_tg_rd_start    <= 1'b0;
    p_rd_start_pulse_r <= 1'b0;
  end
  else begin
    p_rd_start_pulse_r   <= 1'b0;
    if(apb_wr_r & (apb_paddr_r == RD_START_REG) & apb_pwdata_r[0]) begin
      p2a_tg_rd_start    <= ~p2a_tg_rd_start;
      p_rd_start_pulse_r <= 1'b1;
    end
  end
end // always_ff

logic cdc_r1_rd_start /* synthesis syn_preserve=1 CDC_Register=2 */;
logic cdc_r2_rd_start;
logic cdc_r3_rd_start;

always_ff @(posedge aclk_i or negedge areset_n_i) begin
  if(!areset_n_i) begin
    cdc_r1_rd_start <= 1'b0;
	cdc_r2_rd_start <= 1'b0;
	cdc_r3_rd_start <= 1'b0;
	rd_start        <= 1'b0;
  end
  else begin
    cdc_r1_rd_start <= p2a_tg_rd_start;
	cdc_r2_rd_start <= cdc_r1_rd_start;
	cdc_r3_rd_start <= cdc_r2_rd_start;
	rd_start        <= cdc_r2_rd_start != cdc_r3_rd_start;
  end
end // always_ff

always_ff @(posedge pclk_i or negedge preset_n_i) begin
  if(!preset_n_i)
    gen_out_r    <= {GEN_OUT_WIDTH{1'b0}};
  else if(apb_wr_r & (apb_paddr_r == GEN_OUT_REG))
    gen_out_r    <= apb_pwdata_r[GEN_OUT_WIDTH-1:0];
end // always_ff

assign p_gen_out_o = gen_out_r;
always_ff @(posedge aclk_i or negedge areset_n_i) begin
  if(!areset_n_i) begin
    gen_out_r2   <= {GEN_OUT_WIDTH{1'b0}};
	a_gen_out_o  <= {GEN_OUT_WIDTH{1'b0}};
  end
  else begin
    gen_out_r2   <= gen_out_r ;
	a_gen_out_o  <= gen_out_r2;
  end
end // always_ff

always_ff @(posedge aclk_i or negedge areset_n_i) begin
  if(!areset_n_i) begin
    a_wr_timeout_r  <= 1'b0;
	a_rd_timeout_r  <= 1'b0;
  end
  else begin
    a_wr_timeout_r  <= wr_timeout_i;
	a_rd_timeout_r  <= rd_timeout_i;
  end
end // always_ff

always_ff @(posedge pclk_i or negedge preset_n_i) begin
  if(!preset_n_i) begin
    p_wr_timeout_r1 <= 1'b0;
    p_wr_timeout_r2 <= 1'b0;
    p_rd_timeout_r1 <= 1'b0;
    p_rd_timeout_r2 <= 1'b0;
  end
  else begin
    p_wr_timeout_r1 <= a_wr_timeout_r;
    p_wr_timeout_r2 <= p_wr_timeout_r1;
    p_rd_timeout_r1 <= a_rd_timeout_r;
    p_rd_timeout_r2 <= p_rd_timeout_r1;
  end
end // always_ff

endmodule
