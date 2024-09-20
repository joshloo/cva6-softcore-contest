// This instance is only for single rank
// DDR4 Memory Instances
// Common settings:
//     CONFIGURED_DQ_BITS=8:   The x4 is not supported and the x16 training is same as the x8.
//     CONFIGURED_DENSITY=2:   Only using the 2G density to save memory allocation for simulation.
//     CONFIGURED_RANKS=1:     Only 1 rank will be supported for the first release.
localparam int RANK1_SKEW     = (SIM_VAL[1] == 1'b0) ? 0 : (CLK_FREQ==1200) ? 25 : ((CLK_FREQ>=1066) ? 27 : ((CLK_FREQ>=933) ? 30 : ((CLK_FREQ>=800) ? 35 : ((CLK_FREQ>=666) ? 45 : ((CLK_FREQ>=533) ? 60 : 75)))));
localparam int CA_SKEW        = (SIM_VAL[1] == 1'b0) ? 0 : (CLK_FREQ==1200) ? 30 : ((CLK_FREQ>=1066) ? 34 : ((CLK_FREQ>=933) ? 40 : ((CLK_FREQ>=800) ? 55 : ((CLK_FREQ>=666) ? 75 : ((CLK_FREQ>=533) ? 90 : 110)))));
localparam int RANK0_DLY      = (SIM_VAL[1] == 1'b0) ? 0 : 600; //ck,cke and odt
localparam int RANK0_CS_DLY   = (SIM_VAL[1] == 1'b0) ? 0 : RANK0_DLY - CA_SKEW;
localparam int RANK0_CA_DLY   = (SIM_VAL[1] == 1'b0) ? 0 : RANK0_DLY + CA_SKEW;
localparam int RANK0_DQS_DLY  = (SIM_VAL[1] == 1'b0) ? 0 : 300; 
localparam int RANK0_DQ_OFST  = (SIM_VAL[1] == 1'b0) ? 0 : (CLK_FREQ==1200) ? 24 : ((CLK_FREQ>=1066) ? 27 : ((CLK_FREQ>=933) ? 30 : ((CLK_FREQ>=800) ? 45 : ((CLK_FREQ>=666) ? 60 : ((CLK_FREQ>=533) ? 90 : 120)))));
localparam int RANK0_DQS_SKEW = (SIM_VAL[1] == 1'b0) ? 0 : (CLK_FREQ==1200) ? 24 : ((CLK_FREQ>=1066) ? 27 : ((CLK_FREQ>=933) ? 30 : ((CLK_FREQ>=800) ? 45 : ((CLK_FREQ>=666) ? 60 : ((CLK_FREQ>=533) ? 90 : 120)))));
localparam int RANK1_DLY      = (SIM_VAL[1] == 1'b0) ? 0 : RANK0_DLY - RANK1_SKEW;
localparam int RANK1_CS_DLY   = (SIM_VAL[1] == 1'b0) ? 0 : RANK0_CS_DLY - RANK1_SKEW;
localparam int RANK1_CA_DLY   = (SIM_VAL[1] == 1'b0) ? 0 : RANK0_CA_DLY - RANK1_SKEW;
localparam int RANK1_DQS_DLY  = (SIM_VAL[1] == 1'b0) ? 0 : RANK0_DQS_DLY - RANK1_SKEW;
localparam int RANK1_DQ_OFST  = (SIM_VAL[1] == 1'b0) ? 0 : RANK0_DQ_OFST;
localparam int RANK1_DQS_SKEW = (SIM_VAL[1] == 1'b0) ? 0 : RANK0_DQS_SKEW;


/*localparam int RANK0_DLY     = 350; //ck,cke and odt
localparam int RANK0_CS_DLY  = 400; //cs
localparam int RANK0_CA_DLY  = 250; // rest of command address
localparam int RANK0_DQS_DLY = 300; 
localparam int RANK0_DQ_OFST = 0  ;
localparam int RANK0_DQS_SKEW= 50 ;
localparam int RANK1_DLY     = 300;  // 150ps
localparam int RANK1_CS_DLY  = 350;
localparam int RANK1_CA_DLY  = 200;
localparam int RANK1_DQS_DLY = 250;
localparam int RANK1_DQ_OFST = 0  ;
localparam int RANK1_DQS_SKEW= 40 ;*/


/*localparam int RANK0_DLY     = 0; //ck,cke and odt
localparam int RANK0_CS_DLY  = 0; //cs
localparam int RANK0_CA_DLY  = 0; // rest of command address
localparam int RANK0_DQS_DLY = 0; 
localparam int RANK0_DQ_OFST = 0;
localparam int RANK0_DQS_SKEW= 0;
localparam int RANK1_DLY     = 0;  // 150ps
localparam int RANK1_CS_DLY  = 0;
localparam int RANK1_CA_DLY  = 0;
localparam int RANK1_DQS_DLY = 0;
localparam int RANK1_DQ_OFST = 0;
localparam int RANK1_DQS_SKEW= 0;*/


/*localparam int DQS_DELAY[2]  = {RANK1_DQS_DLY, RANK0_DQS_DLY};
localparam int DQ_OFFSET[2]  = {(RANK1_DQ_OFST/2), (RANK0_DQ_OFST/2)};
localparam int DQS_SKEW[2]   = {RANK1_DQS_SKEW, RANK0_DQS_SKEW};*/

localparam int DQS_DELAY[2]  = {RANK0_DQS_DLY, RANK1_DQS_DLY};
localparam int DQ_OFFSET[2]  = {(RANK0_DQ_OFST/2), (RANK1_DQ_OFST/2)};
localparam int DQS_SKEW[2]   = {RANK0_DQS_SKEW, RANK1_DQS_SKEW};


logic                 ddr4_pwr    ;
logic                 ddr4_vref_ca;
logic                 ddr4_vref_dq;
/*logic [DQS_WIDTH-1:0] dqs_out_enb ;
logic [DQS_WIDTH-1:0] dqs_out_enb1;
logic [BUS_WIDTH-1:0] dq_out_enb  ; // mem is driving
logic [BUS_WIDTH-1:0] dq_out_enb1 ; 
logic [DQS_WIDTH-1:0] dm_out_enb  ;
logic [DQS_WIDTH-1:0] dm_out_enb1 ;*/

logic [1:0] dly_CK_t; // CK[0]==CK_c CK[1]==CK_t
logic [1:0] dly_CK_c; // CK[0]==CK_c CK[1]==CK_t
logic [1:0] dly_CS_n;
logic [1:0] dly_CKE;
logic [1:0] dly_ODT;
logic [1:0] dly_ACT_n;
logic [1:0] dly_RAS_n_A16;
logic [1:0] dly_CAS_n_A15;
logic [1:0] dly_WE_n_A14;
logic [1:0][BG_WIDTH-1:0] dly_BG;
logic [1:0][BANK_WIDTH-1:0] dly_BA;
logic [1:0][CA_WIDTH-1:0] dly_ADDR;
/*wire  [1:0][DQS_WIDTH-1:0] dly_DQS_t;
wire  [1:0][DQS_WIDTH-1:0] dly_DQS_c ;
wire  [1:0][BUS_WIDTH-1:0] dly_DQ ;
wire  [1:0][DQS_WIDTH-1:0] dly_DMI;*/


//CK, CS, CKE, ODT, RASn, CASn, WEn, BA, BG, CA

genvar dqs_i     ;
genvar cs_i     ;
generate   
  if (INTERFACE_TYPE == "DDR4") begin : D4MEM
	
	delay_1dir #(.DELAY_VAL(RANK0_DLY),   .BIT_WIDTH(1)) d_ckt0 (.ddr_i(ddr_ck_o[0]), .ddr_o(dly_CK_t[0]));
    delay_1dir #(.DELAY_VAL(RANK0_DLY),   .BIT_WIDTH(1)) d_ckc0 (.ddr_i(ddr_ck_c[0]), .ddr_o(dly_CK_c[0]));
	delay_1dir #(.DELAY_VAL(RANK0_CS_DLY),.BIT_WIDTH(1)) d_cs0  (.ddr_i(ddr_cs_o[0]), .ddr_o(dly_CS_n[0]));
	delay_1dir #(.DELAY_VAL(RANK0_DLY),   .BIT_WIDTH(1)) d_cke0 (.ddr_i(ddr_cke_o[0]), .ddr_o(dly_CKE[0]));
	delay_1dir #(.DELAY_VAL(RANK0_DLY),   .BIT_WIDTH(1)) d_odt0 (.ddr_i(ddr_odt_o[0]), .ddr_o(dly_ODT[0]));
	delay_1dir #(.DELAY_VAL(RANK0_CA_DLY),.BIT_WIDTH(1)) d_ack0 (.ddr_i(ddr_act_n_o), .ddr_o(dly_ACT_n[0]));
    delay_1dir #(.DELAY_VAL(RANK0_CA_DLY),.BIT_WIDTH(1)) d_ras0 (.ddr_i(ddr_ras_n_o), .ddr_o(dly_RAS_n_A16[0]));
	delay_1dir #(.DELAY_VAL(RANK0_CA_DLY),.BIT_WIDTH(1)) d_cas0 (.ddr_i(ddr_cas_n_o), .ddr_o(dly_CAS_n_A15[0]));
	delay_1dir #(.DELAY_VAL(RANK0_CA_DLY),.BIT_WIDTH(1)) d_we0 (.ddr_i(ddr_we_n_o), .ddr_o(dly_WE_n_A14[0]));
	delay_1dir #(.DELAY_VAL(RANK0_CA_DLY),.BIT_WIDTH(2)) d_bg0 (.ddr_i(ddr_bg_o), .ddr_o(dly_BG[0]));
    delay_1dir #(.DELAY_VAL(RANK0_CA_DLY),.BIT_WIDTH(2)) d_ca0 (.ddr_i(ddr_ba_o), .ddr_o(dly_BA[0]));
	delay_1dir #(.DELAY_VAL(RANK0_CA_DLY),.BIT_WIDTH(14)) d_addr0 (.ddr_i(ddr_ca_o), .ddr_o(dly_ADDR[0]));
	
	if (CK_WIDTH == 1) begin : CK1
      delay_1dir #(.DELAY_VAL(RANK1_DLY), .BIT_WIDTH(1)) d_ckt1 (.ddr_i(ddr_ck_o[0]), .ddr_o(dly_CK_t[1]));
      delay_1dir #(.DELAY_VAL(RANK1_DLY), .BIT_WIDTH(1)) d_ckc1 (.ddr_i(ddr_ck_c[0]), .ddr_o(dly_CK_c[1]));
    end
    else begin : CK2
      delay_1dir #(.DELAY_VAL(RANK1_DLY), .BIT_WIDTH(1)) d_ckt1 (.ddr_i(ddr_ck_o[1]), .ddr_o(dly_CK_t[1]));
      delay_1dir #(.DELAY_VAL(RANK1_DLY), .BIT_WIDTH(1)) d_ckc1 (.ddr_i(ddr_ck_c[1]), .ddr_o(dly_CK_c[1]));
    end
	
	if(CS_WIDTH==2) begin
	  delay_1dir #(.DELAY_VAL(RANK1_CS_DLY),.BIT_WIDTH(1)) d_cs1 (.ddr_i(ddr_cs_o[1]), .ddr_o(dly_CS_n[1]));
	  delay_1dir #(.DELAY_VAL(RANK1_DLY),   .BIT_WIDTH(1)) d_cke1 (.ddr_i(ddr_cke_o[1]), .ddr_o(dly_CKE[1]));
	  delay_1dir #(.DELAY_VAL(RANK1_DLY),   .BIT_WIDTH(1)) d_odt1 (.ddr_i(ddr_odt_o[1]), .ddr_o(dly_ODT[1]));
	  delay_1dir #(.DELAY_VAL(RANK1_CA_DLY),.BIT_WIDTH(1)) d_ack1 (.ddr_i(ddr_act_n_o), .ddr_o(dly_ACT_n[1]));
      delay_1dir #(.DELAY_VAL(RANK1_CA_DLY),.BIT_WIDTH(1)) d_ras1 (.ddr_i(ddr_ras_n_o), .ddr_o(dly_RAS_n_A16[1]));
	  delay_1dir #(.DELAY_VAL(RANK1_CA_DLY),.BIT_WIDTH(1)) d_cas1 (.ddr_i(ddr_cas_n_o), .ddr_o(dly_CAS_n_A15[1]));
	  delay_1dir #(.DELAY_VAL(RANK1_CA_DLY),.BIT_WIDTH(1)) d_we1 (.ddr_i(ddr_we_n_o), .ddr_o(dly_WE_n_A14[1]));
	  delay_1dir #(.DELAY_VAL(RANK1_CA_DLY),.BIT_WIDTH(2)) d_bg1 (.ddr_i(ddr_bg_o), .ddr_o(dly_BG[1]));
      delay_1dir #(.DELAY_VAL(RANK1_CA_DLY),.BIT_WIDTH(2)) d_ca1 (.ddr_i(ddr_ba_o), .ddr_o(dly_BA[1]));
	  delay_1dir #(.DELAY_VAL(RANK1_CA_DLY),.BIT_WIDTH(14)) d_addr1 (.ddr_i(ddr_ca_o), .ddr_o(dly_ADDR[1]));
	end
	  
    for(cs_i=0; cs_i<CS_WIDTH; cs_i++) begin : RANK
      for(dqs_i=0; dqs_i<DQS_WIDTH; dqs_i++) begin : DQSGRP
          DDR4_if #(.CONFIGURED_DQ_BITS(8)) iDDR4();
		  
		  assign iDDR4.CK[0]     = dly_CK_c[cs_i];
          assign iDDR4.CK[1]     = dly_CK_t[cs_i];
		  assign iDDR4.CS_n      = dly_CS_n[cs_i];
          assign iDDR4.CKE       = dly_CKE[cs_i];
		  assign iDDR4.ACT_n     = dly_ACT_n[cs_i];
          assign iDDR4.RAS_n_A16 = dly_RAS_n_A16[cs_i];
		  assign iDDR4.CAS_n_A15 = dly_CAS_n_A15[cs_i];
          assign iDDR4.WE_n_A14  = dly_WE_n_A14[cs_i];
          assign iDDR4.ODT       = dly_ODT[cs_i];
          //assign iDDR4.C         = ;    // unused
          assign iDDR4.BG        = dly_BG[cs_i];
          assign iDDR4.BA        = dly_BA[cs_i];
          assign iDDR4.ADDR      = dly_ADDR[cs_i];
          initial iDDR4.ALERT_n  = 1'b1;
          assign iDDR4.PARITY    = 1'b0;  // unused
          assign iDDR4.RESET_n   = ddr_reset_n_o;
          assign iDDR4.TEN       = 1'b0;  // unused
          assign iDDR4.ADDR_17   = 1'b0;  // Max density is not yet supported
          assign iDDR4.ZQ        = 1'b0;
          assign iDDR4.PWR       = ddr4_pwr    ;
          assign iDDR4.VREF_CA   = ddr4_vref_ca;
          assign iDDR4.VREF_DQ   = ddr4_vref_dq;
      
        ddr4_model #(.CONFIGURED_DQ_BITS(8), .CONFIGURED_DENSITY(2), .CONFIGURED_RANKS(1))
                     mem_x8_00(.model_enable(model_enable), .iDDR4(iDDR4));
					 
		//assign dqs_out_enb = mem_x8_00.dqs_out_enb;
        //assign dq_out_enb  = mem_x8_00.dq_out_enb;
        //assign dm_out_enb  = mem_x8_00.dm_out_enb;
		
					 
		dqs_grp_delay #(
			.DQS_DEL_VALUE    (DQS_DELAY[cs_i]	  ), // in between DQ_DMI_DEL_MIN and DQ_DMI_DEL_MAX
			.DQ_DMI_OFFSET_MAX(DQ_OFFSET[cs_i]    ),
			.RAND_OFFSET      (dqs_i+cs_i*dqs_i   )
		  ) 
		   d_dqs_grp (
			.mc_dqs_enb (~mem_x8_00.dqs_out_enb	  ),
			.mc_dqs_t   (ddr_dqs_io[dqs_i]        ),
			.mc_dqs_c   (ddr_dqs_c[dqs_i]         ),
			.mc_dq_enb  (~mem_x8_00.dq_out_enb    ), // controls both DQ and DMI
			.mc_dq      (ddr_dq_io[dqs_i*8+:8]    ),
			.mc_dmi_enb (~mem_x8_00.dm_out_enb	  ),
			.mc_dmi     (ddr_dmi_io[dqs_i]        ),
			.mem_dqs_enb(mem_x8_00.dqs_out_enb	  ),
			.mem_dqs_t  (iDDR4.DQS_t              ),
			.mem_dqs_c  (iDDR4.DQS_c              ),
			.mem_dq_enb (mem_x8_00.dq_out_enb     ), // controls both DQ and DMI
			.mem_dq     (iDDR4.DQ     			  ),
			.mem_dmi_enb(mem_x8_00.dm_out_enb	  ),
			.mem_dmi    (iDDR4.DM_n   			  )
		   );
          			 
      
        // MICRON suggested approach for connection
        /*if (cs_i == 0) begin : R0_DQSG
		
		  assign dqs_out_enb[dqs_i]      = mem_x8_00.dqs_out_enb;
          assign dq_out_enb[dqs_i*8+:8]  = mem_x8_00.dq_out_enb;
          assign dm_out_enb[dqs_i]       = mem_x8_00.dm_out_enb;
          
          assign iDDR4.DM_n              = !dm_out_enb ? ddr_dmi_io[dqs_i]:'hz;
          assign ddr_dmi_io[dqs_i]       = dm_out_enb ? iDDR4.DM_n:'hz;
        
          assign iDDR4.DQ                = !dq_out_enb ? ddr_dq_io[dqs_i*8+:8] :'hzz;
          assign ddr_dq_io[dqs_i*8+:8]   = dq_out_enb ? iDDR4.DQ : 'hzz;
        
          assign iDDR4.DQS_t             = !dqs_out_enb ? ddr_dqs_io[dqs_i] : 'hz;
          assign ddr_dqs_io[dqs_i]       = dqs_out_enb ? iDDR4.DQS_t : 'hz;
        
          assign iDDR4.DQS_c             = ddr_dqs_c[dqs_i];
        end
        else begin : R1_DQSG
          assign dqs_out_enb1[dqs_i]     = mem_x8_00.dqs_out_enb;
          assign dq_out_enb1[dqs_i*8+:8] = mem_x8_00.dq_out_enb;
          assign dm_out_enb1[dqs_i]      = mem_x8_00.dm_out_enb;
          
          assign iDDR4.DM_n              = !dm_out_enb1 ? ddr_dmi_io[dqs_i]:'hz;
          assign ddr_dmi_io[dqs_i]       = dm_out_enb1  ? iDDR4.DM_n:'hz;
          // FIXME: Either do the assignment per bit or make ddr_dq_io per DQSGRP 
          assign iDDR4.DQ                = !dq_out_enb1 ? ddr_dq_io[dqs_i*8+:8] :'hzz;
          assign ddr_dq_io[dqs_i*8+:8]   = dq_out_enb1  ? iDDR4.DQ : 'hzz;
        
          assign iDDR4.DQS_t             = !dqs_out_enb1 ? ddr_dqs_io[dqs_i] : 'hz;
          assign ddr_dqs_io[dqs_i]       = dqs_out_enb1  ? iDDR4.DQS_t : 'hz;
        
          assign iDDR4.DQS_c             = ddr_dqs_c[dqs_i];
        end */
      
      end
    end // for RANK
  end // D4MEM
endgenerate
 


initial begin
    ddr4_pwr     <= 0;
    ddr4_vref_ca <= 0;
    ddr4_vref_dq <= 0;
    repeat (100) @(posedge pll_refclk_i);
    ddr4_pwr     <= 1;
    ddr4_vref_ca <= 1;
    ddr4_vref_dq <= 1;
end



