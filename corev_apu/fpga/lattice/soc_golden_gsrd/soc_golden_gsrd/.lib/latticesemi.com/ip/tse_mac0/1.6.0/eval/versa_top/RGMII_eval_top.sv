module top(
	input			rgmii_rxc_0, //ch0
	input			rgmii_rxctl_0,
	input [3:0] 	rgmii_rxd_0,
	output			rgmii_txc_0,
	output			rgmii_txctl_0,
	output [3:0] 	rgmii_txd_0,
	output			rgmii_mdc_0,
	inout			rgmii_mdio_0,
	input			rgmii_rxc_1, //ch1
	input			rgmii_rxctl_1,
	input [3:0] 	rgmii_rxd_1,
	output			rgmii_txc_1,
	output			rgmii_txctl_1,
	output [3:0] 	rgmii_txd_1,
	output			rgmii_mdc_1,
	inout			rgmii_mdio_1,

	input  [1:0]	i_phy_resetn, // PHY reset 
	output [1:0]	o_phy_resetn, // PHY reset 

	output [7:0]	LED_RED,
	input			patgen_start,
	input			clk_125_i,
	output			clk_125_en_o,
	input			resetn_i 
	);

	localparam SPEED_MODE = "1G"; //RGMII speed mode: "10M"; "100M"; "1G"
	localparam CLK_ALGN = "1"; 
	//clock alignment for data sampling
	//"0"= MAC/FPGA TX & RX delay
	//"1"= [recommended] Centered align PHY (by adding 1.9ns to PHYs TX and RX)
	//"2"= MAC/FPGA TX & PHY RX delay
	//"3"= PHY TX & MAC/FPGA RX delay
	//"4"= Edge align, no delay

	localparam RGMII_CHANNEL = 2; //Numbers of channel used
	localparam DATA_FINE_DELAY_VALUE = "0";
	localparam DEL_MODE = "SCLK_CENTERED";  //data delay mode: "SCLK_CENTERED"; "USER_DEFINED"
	//Fine Delay Value for User-defined
	//Default data path fine delay setting. Only valid when Data Path Delay is Static User-defined or Dynamic User-defined.
	//Ideally, a 9-bit binary string, 12.5 ps per step  
	//max_fine_delay = 511 × 12.5 ps = 6387.5ps
	//Note: The silicon is designed to have 12.5ps delay per step but on simulation, only 10ps can be observed.

	wire [1:0] speed_sel; //10:1G  01:100M  00:10M
	assign speed_sel[1] = (SPEED_MODE == "1G")? 1'b1 : 1'b0;
	assign speed_sel[0] = (SPEED_MODE == "100M")? 1'b1 : 1'b0;
	wire [2:0] linkup;

	//DDR
	wire [9:0] rx_ddr_out_0;
	wire [9:0] rx_ddr_out_1;
	wire [9:0] tx_ddr_in_0;
	wire [5:0] tx_ddr_out_0;
	wire [9:0] tx_ddr_in_1;
	wire [5:0] tx_ddr_out_1;
	
	//DELAY, for DDR and SDR
	wire [5:0] rx_in_0;
	wire [5:0] rx_in_1;
	wire [5:0] rx_dly_0;
	wire [5:0] rx_dly_1;

	//CLK - TX
	wire pllclk_125;
	wire pllclk_125_90deg;
	wire pllclk_25;
	wire pllclk_25_90deg;
	wire pllclk_20;
	wire pllclk_20_90deg;
	wire pllclk_5;
	wire pllclk_2p5;
	wire plllock_o;

	//CLK - MAC
	wire rxmac_clk_i [RGMII_CHANNEL-1:0];
	wire txmac_clk_i;
	wire rxmac_clk_i_div2 [RGMII_CHANNEL-1:0];
	wire txmac_clk_i_div2;
	wire txmii_clk_i;
	//MDIO
	wire tse_mdc;
	wire tse_mdi_i [RGMII_CHANNEL-1:0];
	wire tse_mdo_o [RGMII_CHANNEL-1:0];
	wire tse_mdio_en_o [RGMII_CHANNEL-1:0];

	//AXI-Stream
	wire [7:0] axis_rx_tdata_o [RGMII_CHANNEL-1:0];
	wire axis_rx_tvalid_o [RGMII_CHANNEL-1:0];
	wire axis_rx_tready_i [RGMII_CHANNEL-1:0];
	wire axis_rx_tlast_o [RGMII_CHANNEL-1:0];
	wire axis_rx_tkeep_o [RGMII_CHANNEL-1:0];
	wire [7:0] axis_tx_tdata_i [RGMII_CHANNEL-1:0];
	wire axis_tx_tready_o [RGMII_CHANNEL-1:0];
	wire axis_tx_tvalid_i [RGMII_CHANNEL-1:0];
	wire axis_tx_tlast_i [RGMII_CHANNEL-1:0];

	//wire patgen_start;
	wire [RGMII_CHANNEL-1:0] patgen_done ;
	wire [RGMII_CHANNEL-1:0] compareFail ;

	//APB Host Interface
	wire apb_pready_o [RGMII_CHANNEL-1:0];
	wire [31:0] apb_prdata_o [RGMII_CHANNEL-1:0];
	wire apb_request_o [RGMII_CHANNEL-1:0];
	wire apb_pwrite_i [RGMII_CHANNEL-1:0];
	wire [15:0] apb_paddr_i [RGMII_CHANNEL-1:0]; 
	wire [31:0] apb_pwdata_i [RGMII_CHANNEL-1:0];
	wire apb_done [RGMII_CHANNEL-1:0] ;
	
	//MII/GMII wire
	wire [7:0] tse_rxd_i [RGMII_CHANNEL-1:0];
	wire tse_rx_dv_i [RGMII_CHANNEL-1:0];
	wire tse_rx_er_i [RGMII_CHANNEL-1:0];
	wire [7:0] tse_txd_o [RGMII_CHANNEL-1:0];
	wire tse_tx_en_o [RGMII_CHANNEL-1:0];
	wire tse_tx_er_o [RGMII_CHANNEL-1:0];
	wire [7:0] rxd_i_0;
	wire rx_dv_i_0;
	wire rx_er_i_0;
	wire [7:0] txd_o_0;
	wire tx_en_o_0;
	wire tx_er_o_0;
	wire rxctl_1_0;
	wire [7:0] rxd_i_1;
	wire rx_dv_i_1;
	wire rx_er_i_1;
	wire [7:0] txd_o_1;
	wire tx_en_o_1;
	wire tx_er_o_1;
	wire rxctl_1_1;
		
	// PHY reset
	assign o_phy_resetn = i_phy_resetn;
	assign clk_125_en_o = 1'b1;

	// LED
	assign LED_RED[0] = plllock_o;
	assign LED_RED[1] = apb_done[0] & apb_done[1];
	assign LED_RED[2] = &patgen_done;
	assign LED_RED[3] = |compareFail;
	assign LED_RED[4] = 1'b0;
	assign LED_RED[5] = linkup[2]; //10M
	assign LED_RED[6] = linkup[1]; //100M
	assign LED_RED[7] = linkup[0]; //1G

	assign linkup[0] = ((~rx_dv_i_0&rxd_i_0[3]&rxd_i_0[2]&~rxd_i_0[1]&rxd_i_0[0]));//1G
	assign linkup[1] = ((~rx_dv_i_0&rxd_i_0[3]&~rxd_i_0[2]&rxd_i_0[1]&rxd_i_0[0]));//100M
	assign linkup[2] = ((~rx_dv_i_0&rxd_i_0[3]&~rxd_i_0[2]&~rxd_i_0[1]&rxd_i_0[0]));//10M
	
	assign tse_rxd_i[0] = rxd_i_0;
	assign tse_rx_dv_i[0] = rx_dv_i_0;
	assign tse_rx_er_i[0] = rx_er_i_0;
	assign tse_rxd_i[1] = rxd_i_1;
	assign tse_rx_dv_i[1] = rx_dv_i_1;
	assign tse_rx_er_i[1] = rx_er_i_1;
	assign txd_o_0 = tse_txd_o[0];
	assign tx_en_o_0 = tse_tx_en_o[0];
	assign tx_er_o_0 = tse_tx_er_o[0];
	assign txd_o_1 = tse_txd_o[1];
	assign tx_en_o_1 = tse_tx_en_o[1];
	assign tx_er_o_1 = tse_tx_er_o[1];
	
	GSRA GSR_INST (.GSR_N(resetn_i)); //Avant GSR
	OSCE #(.CLK_DIV("128")) u_OSC (//Inputs    //"40"  "64"     //160             5M = 320M/64
		.EN(1'b1), 
		.SEL400_N(1'b1),  //1'b0 - 400MHz; 1'b1 - 320MHz              
		.CLKOUT(tse_mdc) );   // 8MHz = 320MHz/40 
	tx_pll u_tx_pll(.rstn_i(resetn_i), //.rstn_i(1'b1),
		.clki_i(clk_125_i), //clk_125_i  rgmii_rxc_0
		.lock_o(plllock_o),
		.clkop_o(pllclk_125), 		//125Mhz
		.clkos_o(pllclk_125_90deg),	//125Mhz+90degree
		.clkos2_o(pllclk_25),		//25Mhz
		.clkos3_o(pllclk_25_90deg),	//25Mhz+90degree
		.clkos4_o(pllclk_20),		//20Mhz
		.clkos5_o(pllclk_20_90deg)	//20Mhz+90degree
	);

	//10M speed only - TX 2.5Mhz clock
	if (SPEED_MODE == "10M" ) begin
		//primitive IP, to divide incoming clock to specific frequency 
		ECLKDIVA#(
		  .ALIGN      ("DISABLED"),
		  .CLK_DIV    ("4"), //divider value
		  .GSR        ("DISABLED"),
		  .PHYBY4_SEL ("DISABLED"),
		  .RATE       ("HALF")
		) u1_ECLKDIV (
		  .ECLKIN     (pllclk_20), //input clk 20Mhz
		  .ALIGNWD    (0),
		  .RST        (~resetn_i),
		  .ECLKDIVOUT (pllclk_5) //output clk 5Mhz
		);
		ECLKDIVA#(
		  .ALIGN      ("DISABLED"),
		  .CLK_DIV    ("2"), //divider value
		  .GSR        ("DISABLED"),
		  .PHYBY4_SEL ("DISABLED"),
		  .RATE       ("HALF")
		) u2_ECLKDIV (
		  .ECLKIN     (pllclk_5), //input clk 5Mhz
		  .ALIGNWD    (0),
		  .RST        (~resetn_i),
		  .ECLKDIVOUT (pllclk_2p5) //output clk 2.5Mhz
		);
	end
	
	//10M/100M speed only - RX 2.5Mhz clock and 1.25Mhz clock
	if ((SPEED_MODE == "10M" ) || (SPEED_MODE == "100M")) begin
		ECLKDIVA#(
		  .ALIGN      ("DISABLED"),
		  .CLK_DIV    ("2"),
		  .GSR        ("DISABLED"),
		  .PHYBY4_SEL ("DISABLED"),
		  .RATE       ("HALF")
		) u3_ECLKDIV (
		  .ECLKIN     (rxmac_clk_i[0]), 
		  .ALIGNWD    (0), 
		  .RST        (~resetn_i),  
		  .ECLKDIVOUT (rxmac_clk_i_div2[0])  
		);
		ECLKDIVA#(
		  .ALIGN      ("DISABLED"),
		  .CLK_DIV    ("2"),
		  .GSR        ("DISABLED"),
		  .PHYBY4_SEL ("DISABLED"),
		  .RATE       ("HALF")
		) u4_ECLKDIV (
		  .ECLKIN     (rxmac_clk_i[1]),  
		  .ALIGNWD    (0),  
		  .RST        (~resetn_i),  
		  .ECLKDIVOUT (rxmac_clk_i_div2[1])   
		);
	end

	if ((SPEED_MODE == "10M") || (SPEED_MODE == "100M")) begin
		ECLKDIVA#(
		  .ALIGN      ("DISABLED"),
		  .CLK_DIV    ("2"), 
		  .GSR        ("DISABLED"),
		  .PHYBY4_SEL ("DISABLED"),
		  .RATE       ("HALF")
		) u5_ECLKDIV (
		  .ECLKIN     (txmac_clk_i), 
		  .ALIGNWD    (0),
		  .RST        (~resetn_i),
		  .ECLKDIVOUT (txmac_clk_i_div2)
		);
	end
	 
	//TX and RX clock definition
	assign txmac_clk_i = (SPEED_MODE == "1G") ? pllclk_125 : ((SPEED_MODE == "100M") ? pllclk_25 : pllclk_2p5); 
	if (CLK_ALGN == "0" || CLK_ALGN == "2") begin
		assign txmii_clk_i = (SPEED_MODE == "1G") ? pllclk_125_90deg : ((SPEED_MODE == "100M") ? pllclk_25_90deg : pllclk_2p5); 
	end else begin
		assign txmii_clk_i = txmac_clk_i; 
	end
	
	assign rgmii_txc_0 = txmac_clk_i; 
	assign rgmii_txc_1 = txmac_clk_i; 
	assign rxmac_clk_i[0] = rgmii_rxc_0; 
	assign rxmac_clk_i[1] = rgmii_rxc_1; 

	assign rgmii_mdc_0 = tse_mdc;
	assign rgmii_mdio_0 = tse_mdio_en_o[0] ? tse_mdo_o[0] : 1'bz; 
	assign tse_mdi_i[0] = rgmii_mdio_0; 
	assign rgmii_mdc_1 = tse_mdc;
	assign rgmii_mdio_1 = tse_mdio_en_o[1] ? tse_mdo_o[1] : 1'bz; 
	assign tse_mdi_i[1] = rgmii_mdio_1; 

	if (SPEED_MODE == "1G") begin
		//DDR 
		assign tx_ddr_in_0 = {(tx_en_o_0^tx_er_o_0), tx_en_o_0, txd_o_0[7], txd_o_0[3], txd_o_0[6], txd_o_0[2], txd_o_0[5], txd_o_0[1], txd_o_0[4], txd_o_0[0]};
		assign tx_ddr_in_1 = {(tx_en_o_1^tx_er_o_1), tx_en_o_1, txd_o_1[7], txd_o_1[3], txd_o_1[6], txd_o_1[2], txd_o_1[5], txd_o_1[1], txd_o_1[4], txd_o_1[0]};
	end else begin
		//SDR
		assign tx_ddr_in_0 = {(tx_en_o_0^tx_er_o_0), tx_en_o_0, txd_o_0[3], txd_o_0[3], txd_o_0[2], txd_o_0[2], txd_o_0[1], txd_o_0[1], txd_o_0[0], txd_o_0[0]};
		assign tx_ddr_in_1 = {(tx_en_o_1^tx_er_o_1), tx_en_o_1, txd_o_1[3], txd_o_1[3], txd_o_1[2], txd_o_1[2], txd_o_1[1], txd_o_1[1], txd_o_1[0], txd_o_1[0]};
	end
	assign {rgmii_txctl_0, rgmii_txd_0} = tx_ddr_out_0;
	assign {rgmii_txctl_1, rgmii_txd_1} = tx_ddr_out_1;		
	assign rx_in_0  = {rgmii_rxctl_0, rgmii_rxd_0};
	assign rx_in_1  = {rgmii_rxctl_1, rgmii_rxd_1};
	assign {rxctl_1_0, rx_dv_i_0, rxd_i_0[7], rxd_i_0[3], rxd_i_0[6], rxd_i_0[2], rxd_i_0[5], rxd_i_0[1], rxd_i_0[4], rxd_i_0[0]} = rx_ddr_out_0;
	assign {rxctl_1_1, rx_dv_i_1, rxd_i_1[7], rxd_i_1[3], rxd_i_1[6], rxd_i_1[2], rxd_i_1[5], rxd_i_1[1], rxd_i_1[4], rxd_i_1[0]} = rx_ddr_out_1;
	
	genvar i; 
	generate 
		//DDR - for 1G speed only && 100M/10M without DDR functionality
		for (i = 0;(i < 5);i = (i + 1)) 
			begin : Data
			//DDR - transmitter
			ODDRX1A u_ODDRX1A_0 (
				.D1(tx_ddr_in_0[((i*2)+1)]), 
				.D0(tx_ddr_in_0[((i*2)+0)]), 
				.SCLK(rgmii_txc_0), 
				.RST(~resetn_i | ~plllock_o), 
				.Q(tx_ddr_out_0[i])
			);
			ODDRX1A u_ODDRX1A_1 (
				.D1(tx_ddr_in_1[((i*2)+1)]), 
				.D0(tx_ddr_in_1[((i*2)+0)]), 
				.SCLK(rgmii_txc_1), 
				.RST(~resetn_i | ~plllock_o), 
				.Q(tx_ddr_out_1[i])
			);
			
			//data delay module, and receiver 
			if(CLK_ALGN == "0" || CLK_ALGN == "3") begin
				DELAYE #(
					.DEL_VALUE(DATA_FINE_DELAY_VALUE),
					.DEL_MODE(DEL_MODE)) 
				u_DELAYE_2 (
					.A(rx_in_0[i]), 
					.Z(rx_dly_0[i])
				); 
			end 
			IDDRX1A #(.GSR("ENABLED")) u_IDDRX1A_0 (.D(((CLK_ALGN == "0" || CLK_ALGN == "3")? rx_dly_0[i] : rx_in_0[i])),  
				.SCLK(~rgmii_rxc_0),		
				.RST(~resetn_i),			
				.Q1(rx_ddr_out_0[((i*2)+1)]), 
				.Q0(rx_ddr_out_0[((i*2)+0)])
			) ; 
			if(CLK_ALGN == "0" || CLK_ALGN == "3") begin
				DELAYE #(
					.DEL_VALUE(DATA_FINE_DELAY_VALUE),
					.DEL_MODE(DEL_MODE)
				) u_DELAYE_3 (
					.A(rx_in_1[i]), 
					.Z(rx_dly_1[i])
				); 
			end
			IDDRX1A #(.GSR("ENABLED")) u_IDDRX1A_1 (.D(((CLK_ALGN == "0" || CLK_ALGN == "3") ? rx_dly_1[i] : rx_in_1[i])), 
				.SCLK(~rgmii_rxc_1),		
				.RST(~resetn_i),			
				.Q1(rx_ddr_out_1[((i*2)+1)]), 
				.Q0(rx_ddr_out_1[((i*2)+0)])
			) ;
		end
	endgenerate

	generate for (i = 0 ; i < RGMII_CHANNEL ; i = i+1 ) 
		begin : inst
		apb_module #(.SPEED_MODE(SPEED_MODE),.EXTERNAL_PHY_DELAY(CLK_ALGN)) u_apb_init (
			  .apb_clk_i            (pllclk_125) 
			 ,.apb_reset_i          (resetn_i & plllock_o) 
			 ,.apb_ready_i          (apb_pready_o[i]) //apb_pready_i
			 ,.apb_request_o        (apb_request_o[i])
			 ,.apb_prdata_i         (apb_prdata_o[i])
			 ,.apb_wr_rdn_o         (apb_pwrite_i[i]) //apb_wr_rdn_o
			 ,.apb_offset_o         (apb_paddr_i[i]) //apb_offset_o
			 ,.apb_wdata_o          (apb_pwdata_i[i]) //apb_wdata_o
			 ,.done                 (apb_done[i]) //apb_done 
		 ); 
		 
		dut_inst_wrap u_tsemac (
			//Clock and Reset
			.clk_i (pllclk_125) 
			,.reset_n_i(resetn_i & plllock_o)
			,.int_o()
			,.col_i(1'b0)
			,.crs_i(1'b0)
			//RGMII clk
			,.rxmac_clk_i((SPEED_MODE == "1G") ? rxmac_clk_i[i] : rxmac_clk_i_div2[i]) 
			,.txmac_clk_i((SPEED_MODE == "1G") ? txmac_clk_i : txmac_clk_i_div2)
			,.rx_mii_clk_i(rxmac_clk_i[i])
			,.tx_mii_clk_i(txmii_clk_i)
			
			//MII/GMII datapath
			,.mii_gmii_rxd_i(tse_rxd_i[i]) 
			,.mii_gmii_rx_dv_i(tse_rx_dv_i[i])
			,.mii_gmii_rx_er_i(tse_rx_er_i[i])
			,.mii_gmii_txd_o(tse_txd_o[i])
			,.mii_gmii_tx_en_o(tse_tx_en_o[i])
			,.mii_gmii_tx_er_o(tse_tx_er_o[i])
			//Management Interface (Available in MAC Only Option and When MIIM is Selected)
			,.mdc_i                  (tse_mdc         )
			,.mdi_i                  (tse_mdi_i[i]    )
			,.mdo_o                  (tse_mdo_o[i]    )
			,.mdio_en_o              (tse_mdio_en_o[i])
			//AXI4 Stream Receive Interface
			,.axis_rx_tready_i       (1'b1)
			,.axis_rx_tvalid_o       (axis_rx_tvalid_o[i])
			,.axis_rx_tdata_o        (axis_rx_tdata_o[i] )
			,.axis_rx_tlast_o        (axis_rx_tlast_o[i] )
			//AXI4 Stream Transmit Interface
			,.axis_tx_tready_o       (axis_tx_tready_o[i])
			,.axis_tx_tvalid_i       (axis_tx_tvalid_i[i])
			,.axis_tx_tdata_i        (axis_tx_tdata_i[i] )
			,.axis_tx_tlast_i        (axis_tx_tlast_i[i] )
			//Transmit MAC Control and Status Signal
			,.tx_sndpaustim_i        (16'h0000)
			,.tx_sndpausreq_i        (1'b0)
			,.tx_fifoctrl_i          (1'b0)
			,.tx_staten_o            ()
			,.tx_macread_o           ()
			,.tx_statvec_o           ()
			,.tx_done_o              ()
			,.tx_discfrm_o           ()
			//Receive MAC Control and Status Signals
			,.rx_stat_vector_o       ()
			,.rx_staten_o            ()
			,.ignore_pkt_i           (1'b0)
			,.rx_error_o             ()
			,.rx_eof_o               ()
			,.rx_fifo_error_o        ()
			//APB Host Interface
			,.apb_paddr_i            (apb_paddr_i[i]  )
			,.apb_psel_i             (apb_request_o[i])
			,.apb_penable_i          (apb_request_o[i])
			,.apb_pwrite_i           (apb_pwrite_i[i] )
			,.apb_pwdata_i           (apb_pwdata_i[i] )
			,.apb_pready_o           (apb_pready_o[i] )
			,.apb_prdata_o           (apb_prdata_o[i] )
			,.apb_pslverr_o          ()
			//Miscellaneous
			,.cpu_if_gbit_en_o       () 
		);

		traffic_genchk #(
			.MAX_DATA_WIDTH(8),
			.FRAME_LEN_INIT(16'd66),
			.FRAME_LEN_MAX(16'd70),
			.CONTINUOUS_TRAFFIC (0),
			.NUM_PKT(12)
		) u_traffic_genchk (
			.txclk((SPEED_MODE == "1G") ? txmac_clk_i : txmac_clk_i_div2),
			.rxclk((SPEED_MODE == "1G") ? rxmac_clk_i[i] : rxmac_clk_i_div2[i]), 
			.rstn(resetn_i & plllock_o & (apb_done[0] & apb_done[1])), 
			.inReady(axis_tx_tready_o[i]),
			.outData(axis_tx_tdata_i[i]),
			.outKeep(),
			.outValid(axis_tx_tvalid_i[i]),
			.outUser(),
			.outLast(axis_tx_tlast_i[i]),
			.outReady(),
			.inData(axis_rx_tdata_o[i]),
			.inKeep(1'b1),
			.inValid(axis_rx_tvalid_o[i]),
			.inUser(1'b0),
			.inLast(axis_rx_tlast_o[i]),
			.compareFail(compareFail[i]),
			.done(patgen_done[i]),
			.inStart_patgen(patgen_start) 
		);
		end 
	endgenerate
endmodule

module dut_inst_wrap(
		int_o, 
        ignore_pkt_i, 
        reset_n_i, 
        mdo_o, 
        rx_error_o, 
        apb_pready_o, 
        axis_rx_tvalid_o, 
        rx_fifo_error_o, 
        axis_rx_tready_i, 
        tx_discfrm_o, 
        tx_sndpausreq_i, 
        rx_stat_vector_o, 
        apb_pslverr_o, 
        clk_i, 
        rxmac_clk_i, 
        txmac_clk_i, 
        tx_mii_clk_i, 
        rx_mii_clk_i, 
        apb_paddr_i, 
        apb_prdata_o, 
        rx_eof_o, 
        tx_sndpaustim_i, 
        tx_staten_o, 
        rx_staten_o, 
        cpu_if_gbit_en_o, 
        tx_macread_o, 
        mdc_i, 
        mdi_i, 
        crs_i, 
        axis_rx_tdata_o, 
        tx_fifoctrl_i, 
        axis_rx_tlast_o, 
        axis_rx_tkeep_o, 
        apb_pwdata_i, 
        axis_tx_tdata_i, 
        axis_tx_tready_o, 
        apb_pwrite_i, 
        apb_psel_i, 
        apb_penable_i, 
        col_i, 
        tx_statvec_o, 
        mdio_en_o, 
        axis_tx_tvalid_i, 
        axis_tx_tlast_i, 
        axis_tx_tkeep_i, 
        tx_done_o, 
		mii_gmii_rxd_i, 
        mii_gmii_rx_dv_i, 
        mii_gmii_rx_er_i, 
        mii_gmii_txd_o, 
        mii_gmii_tx_en_o, 
        mii_gmii_tx_er_o) ;
    output int_o ; 
    input ignore_pkt_i ; 
    input reset_n_i ; 
    output mdo_o ; 
    output rx_error_o ; 
    output apb_pready_o ; 
    output axis_rx_tvalid_o ; 
    output rx_fifo_error_o ; 
    input axis_rx_tready_i ; 
    output tx_discfrm_o ; 
    input tx_sndpausreq_i ; 
    output [31:0] rx_stat_vector_o ; 
    output apb_pslverr_o ; 
    input clk_i ; 
    input rxmac_clk_i ; 
    input txmac_clk_i ; 
    input tx_mii_clk_i ; 
    input rx_mii_clk_i ; 
    input [10:0] apb_paddr_i ; 
    output [31:0] apb_prdata_o ; 
    output rx_eof_o ; 
    input [15:0] tx_sndpaustim_i ; 
    output tx_staten_o ; 
    output rx_staten_o ; 
    output cpu_if_gbit_en_o ; 
    output tx_macread_o ; 
    input mdc_i ; 
    input mdi_i ; 
    input crs_i ; 
    output [7:0] axis_rx_tdata_o ; 
    input tx_fifoctrl_i ; 
    output axis_rx_tlast_o ; 
    output axis_rx_tkeep_o ; 
    input [31:0] apb_pwdata_i ; 
    input [7:0] axis_tx_tdata_i ; 
    output axis_tx_tready_o ; 
    input apb_pwrite_i ; 
    input apb_psel_i ; 
    input apb_penable_i ; 
    input col_i ; 
    output [31:0] tx_statvec_o ; 
    output mdio_en_o ; 
    input axis_tx_tvalid_i ; 
    input axis_tx_tlast_i ; 
    input axis_tx_tkeep_i ; 
    output tx_done_o ; 
    input [7:0] mii_gmii_rxd_i ; 
    input mii_gmii_rx_dv_i ; 
    input mii_gmii_rx_er_i ; 
    output [7:0] mii_gmii_txd_o ; 
    output mii_gmii_tx_en_o ; 
    output mii_gmii_tx_er_o ; 
	
	tsemac u_tsemac(.int_o(int_o),
		.ignore_pkt_i(ignore_pkt_i),
		.reset_n_i(reset_n_i),
		.mdo_o(mdo_o),
		.rx_error_o(rx_error_o),
		.apb_pready_o(apb_pready_o),
		.axis_rx_tvalid_o(axis_rx_tvalid_o),
		.rx_fifo_error_o(rx_fifo_error_o),
		.axis_rx_tready_i(axis_rx_tready_i),
		.tx_discfrm_o(tx_discfrm_o),
		.tx_sndpausreq_i(tx_sndpausreq_i),
		.rx_stat_vector_o(rx_stat_vector_o),
		.apb_pslverr_o(apb_pslverr_o),
		.clk_i(clk_i),
		.rxmac_clk_i(rxmac_clk_i),
		.txmac_clk_i(txmac_clk_i),
		.tx_mii_clk_i(tx_mii_clk_i),
		.rx_mii_clk_i(rx_mii_clk_i),
		.apb_paddr_i(apb_paddr_i),
		.apb_prdata_o(apb_prdata_o),
		.rx_eof_o(rx_eof_o),
		.tx_sndpaustim_i(tx_sndpaustim_i),
		.tx_staten_o(tx_staten_o),
		.rx_staten_o(rx_staten_o),
		.cpu_if_gbit_en_o(cpu_if_gbit_en_o),
		.tx_macread_o(tx_macread_o),
		.mdc_i(mdc_i),
		.mdi_i(mdi_i),
		.crs_i(crs_i),
		.axis_rx_tdata_o(axis_rx_tdata_o),
		.tx_fifoctrl_i(tx_fifoctrl_i),
		.axis_rx_tlast_o(axis_rx_tlast_o),
		.axis_rx_tkeep_o(axis_rx_tkeep_o),
		.apb_pwdata_i(apb_pwdata_i),
		.axis_tx_tdata_i(axis_tx_tdata_i),
		.axis_tx_tready_o(axis_tx_tready_o),
		.apb_pwrite_i(apb_pwrite_i),
		.apb_psel_i(apb_psel_i),
		.apb_penable_i(apb_penable_i),
		.col_i(col_i),
		.tx_statvec_o(tx_statvec_o),
		.mdio_en_o(mdio_en_o),
		.axis_tx_tvalid_i(axis_tx_tvalid_i),
		.axis_tx_tlast_i(axis_tx_tlast_i),
		.axis_tx_tkeep_i(axis_tx_tkeep_i),
		.tx_done_o(tx_done_o),
		.mii_gmii_rxd_i(mii_gmii_rxd_i),
        .mii_gmii_rx_dv_i(mii_gmii_rx_dv_i),
        .mii_gmii_rx_er_i(mii_gmii_rx_er_i),
        .mii_gmii_txd_o(mii_gmii_txd_o),
        .mii_gmii_tx_en_o(mii_gmii_tx_en_o),
        .mii_gmii_tx_er_o(mii_gmii_tx_er_o)
	);
endmodule


//------------------------------------------------------------------------------------------------------------
// Title       : apb_module.v
// Project     : Example TSEMAC+RGMII
//------------------------------------------------------------------------------------------------------------
// Description : Register configuration of TSEMAC using APB interface.
//------------------------------------------------------------------------------------------------------------

module apb_module
#(
parameter					   SPEED_MODE = "1G",
parameter					   EXTERNAL_PHY_DELAY = "1", //PHY delay is enabled by default 
parameter                      NUM_REGS = (SPEED_MODE == "1G") ? 10 : 16 , //2
parameter                      APB_ADDR_W = 11  
)
(
input                         apb_clk_i,         //125Mhz clock
input                         apb_reset_i,       //system reset
input                         apb_ready_i,       //apb ready signal from TSEMAC
input       [31:0]            apb_prdata_i,       //apb read data
output reg                    apb_request_o,     //apb request
output reg                    apb_wr_rdn_o,      //apb read/write command
output reg  [APB_ADDR_W-1:0]  apb_offset_o,      //apb offset
output reg  [31:0]            apb_wdata_o,       //apb write data
output reg                    done               //apb configuration done   
);

//--------------------------------------------------------------------------
//--- Local Parameters/Defines ---
//--------------------------------------------------------------------------
localparam                    ST_INIT_IDLE  = 3'd0,
                              ST_INIT_START = 3'd1,
                              ST_INIT_WRITE = 3'd3,
                              ST_INIT_WAIT  = 3'd2,
                              ST_INIT_READ  = 3'd4;
localparam                    PTRWID        = clog2(NUM_REGS+1);

//--------------------------------------------------------------------------
//--- Combinational Wire/Reg ---
//--------------------------------------------------------------------------
wire        [APB_ADDR_W-1:0]  reg_addr[NUM_REGS-1:0];
wire        [31:0]            reg_wdat[NUM_REGS-1:0];
wire                          mdio_read_w [NUM_REGS-1:0];
reg                           mdio_read;


//Ethernet MAC Register settings
//FMC MDIO 1G setting
if (SPEED_MODE == "1G") begin
	assign reg_addr[0] = 11'h24; //configure page to 2
	assign reg_wdat[0] = 32'h00000002; 
	assign mdio_read_w[0] = 1'b0; 
	assign reg_addr[1] = 11'h20; //configure page to 2
	assign reg_wdat[1] = 32'h00002016; // register 22
	assign mdio_read_w[1] = 1'b0; 
	
	assign reg_addr[2] = 11'h24; //write page 2, register 21
	if (EXTERNAL_PHY_DELAY == "0" || EXTERNAL_PHY_DELAY == "4") begin
		assign reg_wdat[2] = 32'h00000846; // configure 1G; with no delay
	end else if (EXTERNAL_PHY_DELAY == "1") begin
		assign reg_wdat[2] = 32'h00000876; // configure 1G; with TX & RX delay
	end else if (EXTERNAL_PHY_DELAY == "2") begin
		assign reg_wdat[2] = 32'h00000866; // configure 1G; with RX delay
	end else begin
		assign reg_wdat[2] = 32'h00000856; // configure 1G; with TX  delay
	end
	assign mdio_read_w[2] = 1'b0; 
	assign reg_addr[3] = 11'h20; //write page 2, register 21
	assign reg_wdat[3] = 32'h00002015; // register 21
	assign mdio_read_w[3] = 1'b0; 
	
	assign reg_addr[4] = 11'h24; //configure page to 0
	assign reg_wdat[4] = 32'h00000000; 
	assign mdio_read_w[4] = 1'b0; 
	assign reg_addr[5] = 11'h20; //configure page to 0
	assign reg_wdat[5] = 32'h00002016; // register 22
	assign mdio_read_w[5] = 1'b0; 
	
	//reset to start 1G AN
	assign reg_addr[6] = 11'h24; //configure page to 0
	assign reg_wdat[6] = 32'h00009140; 
	assign mdio_read_w[6] = 1'b0; 
	assign reg_addr[7] = 11'h20; //configure page to 0
	assign reg_wdat[7] = 32'h00002000; // register 0 - reset phy (software reset)
	assign mdio_read_w[7] = 1'b0; 
	
	assign reg_addr[8] = 11'h004; //Transmit and Receive Control Register
	assign reg_wdat[8] = 32'h00000003; //RX CTRL - Enable prms , discard FCS
	assign mdio_read_w[8] = 1'b0; 
	assign reg_addr[9] = 11'h000; //Set to enable Tx & Rx
	assign reg_wdat[9] = 32'h0000000D; //TX_en , RX_en , Gb_en
	assign mdio_read_w[9] = 1'b0; 
end 

//FMC MDIO 100M and 10M setting
else begin
	assign reg_addr[0] = 11'h24; //configure page to 2
	assign reg_wdat[0] = 32'h00000002; 
	assign mdio_read_w[0] = 1'b0; 

	assign reg_addr[1] = 11'h20; //configure page to 2
	assign reg_wdat[1] = 32'h00002016; // register 22
	assign mdio_read_w[1] = 1'b0; 

	assign reg_addr[2] = 11'h24; //write page 2, register 21	
	if (SPEED_MODE == "100M") begin
		if (EXTERNAL_PHY_DELAY == "0" || EXTERNAL_PHY_DELAY == "4") begin
			assign reg_wdat[2] = 32'h00002806; //configure 100M; no delay
		end else if (EXTERNAL_PHY_DELAY == "1") begin
			assign reg_wdat[2] = 32'h00002836; //configure 100M; with TX & RX delay
		end else if (EXTERNAL_PHY_DELAY == "2") begin
			assign reg_wdat[2] = 32'h00002826; //configure 100M; with RX delay
		end else begin
			assign reg_wdat[2] = 32'h00002816; //configure 100M; with TX delay
		end
	end else begin
		if (EXTERNAL_PHY_DELAY == "0" || EXTERNAL_PHY_DELAY == "4") begin
			assign reg_wdat[2] = 32'h00000806; //configure 10M; no delay
		end else if (EXTERNAL_PHY_DELAY == "1") begin
			assign reg_wdat[2] = 32'h00000836; //configure 10M; with TX & RX delay
		end else if (EXTERNAL_PHY_DELAY == "2") begin
			assign reg_wdat[2] = 32'h00000826; //configure 10M; with RX delay
		end else begin
			assign reg_wdat[2] = 32'h00000816; //configure 10M; with TX delay
		end
	end	
	assign mdio_read_w[2] = 1'b0; 
	assign reg_addr[3] = 11'h20; //write page 2, register 21
	assign reg_wdat[3] = 32'h00002015; // register 21
	assign mdio_read_w[3] = 1'b0; 

	assign reg_addr[4] = 11'h24; //read page 2, register 21 z9999
	assign reg_wdat[4] = 32'h00000015; 
	assign mdio_read_w[4] = 1'b0; 
	assign reg_addr[5] = 11'h20; //read page 2, register 21  z9999
	assign reg_wdat[5] = 32'h00000A00;
	assign mdio_read_w[5] = 1'b1;

	assign reg_addr[6] = 11'h24; //configure page to 0
	assign reg_wdat[6] = 32'h00000000; 
	assign mdio_read_w[6] = 1'b0; 
	assign reg_addr[7] = 11'h20; //configure page to 0
	assign reg_wdat[7] = 32'h00002016; // register 22
	assign mdio_read_w[7] = 1'b0; 

	//disable 1000BaseT so that AN for only 100BaseT
	assign reg_addr[8] = 11'h24; //configure page to 0
	assign reg_wdat[8] = 32'h00000000;  //P0R9 data to all 0's
	assign mdio_read_w[8] = 1'b0; 
	assign reg_addr[9] = 11'h20; //configure page to 0
	assign reg_wdat[9] = 32'h00002009; // register 9
	assign mdio_read_w[9] = 1'b0; 
	//can read the status back for before and after

	//disable 1000BaseT and 100BaseT AN Advertisement
	assign reg_addr[10] = 11'h24; 
	assign reg_wdat[10] = (SPEED_MODE == "100M") ? 32'h00000101: 32'h00000041;  
	assign mdio_read_w[10] = 1'b0; 
	assign reg_addr[11] = 11'h20; //configure page to 0
	assign reg_wdat[11] = 32'h00002004; // register 4
	assign mdio_read_w[11] = 1'b0; 

	//reset to start 100M/10M AN
	assign reg_addr[12] = 11'h24; //configure page to 0
	assign reg_wdat[12] = (SPEED_MODE == "100M") ? 32'h0000B100 : 32'h00009100; 
	assign mdio_read_w[12] = 1'b0; 
	assign reg_addr[13] = 11'h20; //configure page to 0
	assign reg_wdat[13] = 32'h00002000; // register 0 - reset phy (software reset)
	assign mdio_read_w[13] = 1'b0; 

	// 10M_100M 
	assign reg_addr[14] = 11'h004; //Transmit and Receive Control Register
	assign reg_wdat[14] = 32'h00000003; //RX CTRL - Enable prms , discard FCS
	assign mdio_read_w[14] = 1'b0; 
	assign reg_addr[15] = 11'h000; //Set to enable Tx & Rx
	assign reg_wdat[15] = 32'h0000000C; //TX_en , RX_en
	assign mdio_read_w[15] = 1'b0; 
end


//--------------------------------------------------------------------------
//--- Registers ---
//--------------------------------------------------------------------------
reg         [2:0]             init_sm_cs;
reg         [PTRWID-1:0]      init_ptr;
reg                           init_last;
reg                           apb_busy;
reg         [6:0]             count;
reg                           cmd_fin_reg ;
//--------------------------------------------
//-- Sequential block --
//--------------------------------------------
always @(posedge apb_clk_i or negedge apb_reset_i) begin
  if(~apb_reset_i) begin
    init_sm_cs <= ST_INIT_IDLE;
    /*AUTORESET*/
    // Beginning of autoreset for uninitialized flops
    done           <= 1'h0;
    init_last      <= 1'h0;
    init_ptr       <= {PTRWID{1'b0}};
    apb_offset_o   <= {APB_ADDR_W{1'b0}};
    apb_request_o  <= 1'h0;
    apb_wdata_o    <= 32'h00000000;
    apb_wr_rdn_o   <= 1'h0;
    apb_busy       <= 1'b1;
    count          <= 'd0;
    cmd_fin_reg    <= 'd0;
    mdio_read      <= 'd0;
    // End of automatics
  end
  else begin
    count <= count + 1'b1;
    if (count >= 80) begin
      count <= count;
    end
    case(init_sm_cs)
    //Initial state
      ST_INIT_START : begin

        if (apb_busy) begin
          if (mdio_read) begin
            apb_offset_o    <= 11'h24;
          end else begin
            apb_offset_o    <= 11'h20;
          end 
          apb_wr_rdn_o    <= 1'b0;
            apb_request_o <= 1'b1;

          if(apb_ready_i && count >= 80) begin
              cmd_fin_reg <= apb_prdata_i[14];
              apb_busy <= ~ apb_prdata_i[14] ;
              count <= 'd0;
              mdio_read <= 'd0;
          end
        end else begin
          if ( mdio_read_w[init_ptr] ) begin
              init_sm_cs    <= ST_INIT_READ;
          end else begin
              init_sm_cs    <= ST_INIT_WRITE;
          end 
          apb_request_o <= 1'b1;
          apb_wr_rdn_o  <= ~mdio_read_w[init_ptr];
          mdio_read     <= mdio_read_w[init_ptr];
          apb_offset_o  <= reg_addr[init_ptr];
          apb_wdata_o   <= reg_wdat[init_ptr];
          init_ptr      <= init_ptr + 1'b1;
          init_last     <= (init_ptr == NUM_REGS-1);
          apb_busy      <= 1'b1;
        end
      end

     //Read state
      ST_INIT_READ : begin

          apb_wr_rdn_o    <= 1'b0;
          if(apb_ready_i) begin
            apb_request_o <= 1'b1;
            apb_wr_rdn_o  <= 1'b0;
            if(init_last) begin
              init_sm_cs  <= ST_INIT_WAIT;
            end
            else begin
              init_sm_cs  <= ST_INIT_START;
            end
          end
          else begin
              init_sm_cs  <= ST_INIT_READ;
          end

      end

     //Writing state
      ST_INIT_WRITE : begin

          apb_wr_rdn_o    <= 1'b1;
          if(apb_ready_i) begin
            apb_request_o <= 1'b1;
            apb_wr_rdn_o  <= 1'b1;
            if(init_last) begin
              init_sm_cs  <= ST_INIT_WAIT;
            end
            else begin
              init_sm_cs  <= ST_INIT_START;
            end
          end
          else begin
              init_sm_cs  <= ST_INIT_WRITE;
          end

      end
      //Wait till last register configuration
      ST_INIT_WAIT : begin
         init_sm_cs    <= ST_INIT_IDLE;
         done          <= init_last;
      end
      default : begin
        apb_request_o  <= 1'b0;
        apb_wr_rdn_o   <= 1'b0;
        init_ptr       <= 'h0;
        init_last      <= 1'b0;
        if(done)
          init_sm_cs   <= ST_INIT_IDLE;
        else begin
          init_sm_cs   <= ST_INIT_START;
        end
      end
    endcase
  end
end

function [31:0] clog2;
  input [31:0] value;
  reg   [31:0] num;
begin
  num = value - 1;
  for (clog2=0; num>0; clog2=clog2+1) num = num>>1;
end
endfunction

endmodule


/*******************************************************************************
    Verilog netlist generated by IPGEN Lattice Radiant Software (64-bit)
    2024.1.0.33.0
    Soft IP Version: 2.5.0
    2024 06 21 14:29:15
*******************************************************************************/
/*******************************************************************************
    Wrapper Module generated per user settings.
*******************************************************************************/
(* ORIG_MODULE_NAME="tx_pll", LATTICE_IP_GENERATED="1" *) module tx_pll (rstn_i, 
        clki_i, 
        lock_o, 
        clkop_o, 
        clkos_o, 
        clkos2_o, 
        clkos3_o, 
        clkos4_o, 
        clkos5_o) ;
    input rstn_i ; 
    input clki_i ; 
    output lock_o ; 
    output clkop_o ; 
    output clkos_o ; 
    output clkos2_o ; 
    output clkos3_o ; 
    output clkos4_o ; 
    output clkos5_o ; 
    tx_pll_ipgen_lscc_pll #(.DEVICE_NAME("LAV-AT-E70ES1"),
            .VCO_FREQ(4000.0),
            .REFCLK_FREQ(125.0),
            .REFCLK_SEL(0),
            .FBKSEL_CLKOUT(0),
            .EXT_FBK_DELAY(3),
            .EN_USR_FBKCLK(0),
            .EN_EXT_CLKDIV(1),
            .EN_SYNC_CLK0(0),
            .WAIT_FOR_LOCK(0),
            .EN_FAST_LOCK(0),
            .EN_LOCK_DETECT(1),
            .EN_PLL_RST(1),
            .EN_CLK0_OUT(1),
            .EN_CLK1_OUT(1),
            .EN_CLK2_OUT(1),
            .EN_CLK3_OUT(1),
            .EN_CLK4_OUT(1),
            .EN_CLK5_OUT(1),
            .EN_CLK6_OUT(0),
            .EN_CLK7_OUT(0),
            .EN_CLK0_CLKEN(0),
            .EN_CLK1_CLKEN(0),
            .EN_CLK2_CLKEN(0),
            .EN_CLK3_CLKEN(0),
            .EN_CLK4_CLKEN(0),
            .EN_CLK5_CLKEN(0),
            .EN_CLK6_CLKEN(0),
            .EN_CLK7_CLKEN(0),
            .CLK0_BYP(0),
            .CLK1_BYP(0),
            .CLK2_BYP(0),
            .CLK3_BYP(0),
            .CLK4_BYP(0),
            .CLK5_BYP(0),
            .CLK6_BYP(0),
            .CLK7_BYP(0),
            .PHASE_SHIFT_TYPE(0),
            .CLK0_PHI(1),
            .CLK1_PHI(1),
            .CLK2_PHI(1),
            .CLK3_PHI(1),
            .CLK4_PHI(1),
            .CLK5_PHI(1),
            .CLK6_PHI(1),
            .CLK7_PHI(1),
            .CLK0_DEL(32),
            .CLK1_DEL(40),
            .CLK2_DEL(160),
            .CLK3_DEL(200),
            .CLK4_DEL(200),
            .CLK5_DEL(250),
            .CLK6_DEL(1),
            .CLK7_DEL(1),
            .PLL_SSEN(0),
            .PLL_DITHEN(1),
            .PLL_ENSAT(1),
            .PLL_INTFBK(1),
            .PLL_CLKR(6'h00),
            .PLL_CLKF(26'h0080000),
            .PLL_CLKV(26'h0000000),
            .PLL_CLKS(12'h000),
            .PLL_BWADJ(12'h007),
            .PLL_CLKOD0(11'h01F),
            .PLL_CLKOD1(11'h01F),
            .PLL_CLKOD2(11'h09F),
            .PLL_CLKOD3(11'h09F),
            .PLL_CLKOD4(11'h0C7),
            .PLL_CLKOD5(11'h0C7),
            .PLL_CLKOD6(11'h000),
            .PLL_CLKOD7(11'h013),
            .REG_INTERFACE("None"),
            .REG_MAPPING(0)) lscc_pll_inst (.rst_n_i(rstn_i), 
                .refclk_in_i(clki_i), 
                .usr_fbkclk_i(1'b0), 
                .phasedir_i(1'b0), 
                .phasestep_i(1'b0), 
                .phaseloadreg_i(1'b0), 
                .phasesel_i(3'b000), 
                .clken_clkop_i(1'b1), 
                .clken_clkos_i(1'b1), 
                .clken_clkos2_i(1'b1), 
                .clken_clkos3_i(1'b1), 
                .clken_clkos4_i(1'b1), 
                .clken_clkos5_i(1'b1), 
                .clken_clkophy_i(1'b1), 
                .clken_testclk_i(1'b1), 
                .refclk_out_o(), 
                .div_change_refclk_o(), 
                .div_change_fbkclk_o(), 
                .slip_refclk_o(), 
                .slip_fbkclk_o(), 
                .pll_lock_o(lock_o), 
                .clkout_clkop_o(clkop_o), 
                .clkout_clkos_o(clkos_o), 
                .clkout_clkos2_o(clkos2_o), 
                .clkout_clkos3_o(clkos3_o), 
                .clkout_clkos4_o(clkos4_o), 
                .clkout_clkos5_o(clkos5_o), 
                .clkout_clkophy_o(), 
                .clkout_testclk_o(), 
                .outresetack_clkop_o(), 
                .outresetack_clkos_o(), 
                .outresetack_clkos2_o(), 
                .outresetack_clkos3_o(), 
                .outresetack_clkos4_o(), 
                .outresetack_clkos5_o(), 
                .outresetack_clkophy_o(), 
                .outresetack_testclk_o(), 
                .stepack_clkop_o(), 
                .stepack_clkos_o(), 
                .stepack_clkos2_o(), 
                .stepack_clkos3_o(), 
                .stepack_clkos4_o(), 
                .stepack_clkos5_o(), 
                .stepack_clkophy_o(), 
                .stepack_testclk_o(), 
                .lmmi_clk_i(1'b0), 
                .lmmi_resetn_i(1'b1), 
                .lmmi_request_i(1'b0), 
                .lmmi_wr_rdn_i(1'b0), 
                .lmmi_offset_i(5'b00000), 
                .lmmi_wdata_i(16'b0000000000000000), 
                .lmmi_rdata_o(), 
                .lmmi_rdata_valid_o(), 
                .lmmi_ready_o(), 
                .apb_pclk_i(1'b0), 
                .apb_preset_n_i(1'b1), 
                .apb_penable_i(1'b0), 
                .apb_psel_i(1'b0), 
                .apb_pwrite_i(1'b0), 
                .apb_paddr_i(7'b0000000), 
                .apb_pwdata_i(16'b0000000000000000), 
                .apb_pready_o(), 
                .apb_pslverr_o(), 
                .apb_prdata_o()) ; 
endmodule



// =============================================================================
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
// -----------------------------------------------------------------------------
//   Copyright (c) 2024 by Lattice Semiconductor Corporation
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
//==========================================================================
// Module : lscc_pll
//==========================================================================
(* LATTICE_IP_MODULE=1 *) module tx_pll_ipgen_lscc_pll #(parameter VCO_FREQ = 2500.0, 
        parameter REFCLK_FREQ = 100.0, 
        parameter REFCLK_SEL = 0, 
        parameter FBKSEL_CLKOUT = 0, 
        parameter EXT_FBK_DELAY = 3, 
        parameter USE_ECLK_FBPATH = 0, 
        parameter EN_USR_FBKCLK = 0, 
        parameter EN_EXT_CLKDIV = 1, 
        parameter EN_SYNC_CLK0 = 0, 
        parameter EN_FAST_LOCK = 0, 
        parameter EN_LOCK_DETECT = 1, 
        parameter EN_PLL_RST = 1, 
        parameter EN_STARTUP_BW = 1, 
        parameter EN_CLK0_OUT = 1, 
        parameter EN_CLK1_OUT = 0, 
        parameter EN_CLK2_OUT = 0, 
        parameter EN_CLK3_OUT = 0, 
        parameter EN_CLK4_OUT = 0, 
        parameter EN_CLK5_OUT = 0, 
        parameter EN_CLK6_OUT = 0, 
        parameter EN_CLK7_OUT = 0, 
        parameter EN_CLK0_CLKEN = 0, 
        parameter EN_CLK1_CLKEN = 0, 
        parameter EN_CLK2_CLKEN = 0, 
        parameter EN_CLK3_CLKEN = 0, 
        parameter EN_CLK4_CLKEN = 0, 
        parameter EN_CLK5_CLKEN = 0, 
        parameter EN_CLK6_CLKEN = 0, 
        parameter EN_CLK7_CLKEN = 0, 
        parameter CLK0_BYP = 0, 
        parameter CLK1_BYP = 0, 
        parameter CLK2_BYP = 0, 
        parameter CLK3_BYP = 0, 
        parameter CLK4_BYP = 0, 
        parameter CLK5_BYP = 0, 
        parameter CLK6_BYP = 0, 
        parameter CLK7_BYP = 0, 
        parameter PHASE_SHIFT_TYPE = 0, 
        parameter CLK0_PHI = 1, 
        parameter CLK1_PHI = 1, 
        parameter CLK2_PHI = 1, 
        parameter CLK3_PHI = 1, 
        parameter CLK4_PHI = 1, 
        parameter CLK5_PHI = 1, 
        parameter CLK6_PHI = 1, 
        parameter CLK7_PHI = 1, 
        parameter CLK0_DEL = 1, 
        parameter CLK1_DEL = 1, 
        parameter CLK2_DEL = 1, 
        parameter CLK3_DEL = 1, 
        parameter CLK4_DEL = 1, 
        parameter CLK5_DEL = 1, 
        parameter CLK6_DEL = 1, 
        parameter CLK7_DEL = 1, 
        parameter PLL_SSEN = 0, 
        parameter PLL_DITHEN = 1, 
        parameter PLL_ENSAT = 1, 
        parameter PLL_INTFBK = 1, 
        parameter [5:0] PLL_CLKR = 6'd0, 
        parameter [25:0] PLL_CLKF = 26'h8C00, 
        parameter [25:0] PLL_CLKV = 26'd0, 
        parameter [11:0] PLL_CLKS = 12'd0, 
        parameter [11:0] PLL_BWADJ = 12'd17, 
        parameter [10:0] PLL_CLKOD0 = 11'd34, 
        parameter [10:0] PLL_CLKOD1 = 11'd34, 
        parameter [10:0] PLL_CLKOD2 = 11'd34, 
        parameter [10:0] PLL_CLKOD3 = 11'd34, 
        parameter [10:0] PLL_CLKOD4 = 11'd34, 
        parameter [10:0] PLL_CLKOD5 = 11'd34, 
        parameter [10:0] PLL_CLKOD6 = 11'd34, 
        parameter [10:0] PLL_CLKOD7 = 11'd19, 
        parameter REG_INTERFACE = "None", 
        parameter REG_MAPPING = ((REG_INTERFACE == "APB") ? 1 : 0), 
        parameter WAIT_FOR_LOCK = 1, 
        parameter DEVICE_NAME = "LAV-AT-E70", 
        parameter SIMULATION = 0) (
    //--begin_param--
    //----------------------------
    // Parameters
    // User Must Configure the IP Using
    // Radiant IP Generation Wizard
    //----------------------------
    // Enable Clock Output port
    // Use Clock Output Enable port
    // Clock Output Bypass
    // Static VCO Phase shift : 1-8
    // Static Divider Phase shift : 1-256
    // Enable Spread Spectrum
    // Enable Fractional accumulation (Dithering)
    // Enable Saturation behavior
    // Internal feedback select
    // Reference clock divider
    // Feedback divider
    // Spreading slope control
    // Spreading rate divider
    // Bandwidth adjustment divider
    // Output Dividers
    // ['None', 'APB', 'LMMI']
    // 0 - default addressing, 1 - dword addressing
    //--end_param--
    //--begin_ports--
    input rst_n_i, 
    input refclk_in_i, 
    input usr_fbkclk_i, 
    input clken_clkop_i, 
    input clken_clkos_i, 
    input clken_clkos2_i, 
    input clken_clkos3_i, 
    input clken_clkos4_i, 
    input clken_clkos5_i, 
    input clken_clkophy_i, 
    input clken_testclk_i, 
    output wire clkout_clkop_o, 
    output wire clkout_clkos_o, 
    output wire clkout_clkos2_o, 
    output wire clkout_clkos3_o, 
    output wire clkout_clkos4_o, 
    output wire clkout_clkos5_o, 
    output wire clkout_clkophy_o, 
    output wire clkout_testclk_o, 
    output wire outresetack_clkop_o, 
    output wire outresetack_clkos_o, 
    output wire outresetack_clkos2_o, 
    output wire outresetack_clkos3_o, 
    output wire outresetack_clkos4_o, 
    output wire outresetack_clkos5_o, 
    output wire outresetack_clkophy_o, 
    output wire outresetack_testclk_o, 
    input phasedir_i, 
    input phaseloadreg_i, 
    input [2:0] phasesel_i, 
    input phasestep_i, 
    output wire stepack_clkop_o, 
    output wire stepack_clkos_o, 
    output wire stepack_clkos2_o, 
    output wire stepack_clkos3_o, 
    output wire stepack_clkos4_o, 
    output wire stepack_clkos5_o, 
    output wire stepack_clkophy_o, 
    output wire stepack_testclk_o, 
    output wire pll_lock_o, 
    output wire refclk_out_o, 
    output wire div_change_fbkclk_o, 
    output wire div_change_refclk_o, 
    output wire slip_fbkclk_o, 
    output wire slip_refclk_o /*AUTOINPUT*//*AUTOOUTPUT*/, 
    input lmmi_clk_i, 
    input [4:0] lmmi_offset_i, 
    input lmmi_request_i, 
    input lmmi_resetn_i, 
    input [15:0] lmmi_wdata_i, 
    input lmmi_wr_rdn_i, 
    output wire [15:0] lmmi_rdata_o, 
    output wire lmmi_rdata_valid_o, 
    output wire lmmi_ready_o, 
    input apb_pclk_i, 
    input apb_preset_n_i, 
    input apb_psel_i, 
    input apb_penable_i, 
    input apb_pwrite_i, 
    input [6:0] apb_paddr_i, 
    input [15:0] apb_pwdata_i, 
    output wire apb_pready_o, 
    output wire apb_pslverr_o, 
    output wire [15:0] apb_prdata_o) ;
    //--end_ports--
    function [((8 * 10) - 1):0] int_to_str ; 
        input [31:0] int_num ; 
        integer num, 
            i ; 
        reg [((8 * 16) - 1):0] str_num ; 
        reg [3:0] digit ; 
        reg [8:0] str_digit ; 
        begin
            num = int_num ;
            digit = 0 ;
            i = 0 ;
            str_num = "0" ;
            for (num = int_num ; (num > 0) ; num = ((num - digit) / 10))
                begin
                    digit = (num % 10) ;
                    case (digit)
                    0 : 
                        str_digit = "0" ;
                    1 : 
                        str_digit = "1" ;
                    2 : 
                        str_digit = "2" ;
                    3 : 
                        str_digit = "3" ;
                    4 : 
                        str_digit = "4" ;
                    5 : 
                        str_digit = "5" ;
                    6 : 
                        str_digit = "6" ;
                    7 : 
                        str_digit = "7" ;
                    8 : 
                        str_digit = "8" ;
                    9 : 
                        str_digit = "9" ;
                    default : 
                        str_digit = "%" ;
                    endcase 
                    str_num[(i * 8) +: 8] = str_digit ;
                    i = (i + 1) ;
                end
            int_to_str = {"",
                    str_num} ;
        end
    endfunction
    function [(((2 + 2) * 8) - 1):0] int_to_2b_str ; 
    // int_to_2b_str
        input [1:0] value ; 
        reg [((8 * 2) - 1):0] binstr ; 
        integer idx ; 
        begin
            for (idx = 0 ; (idx < 2) ; idx = (idx + 1))
                begin
                    binstr[(idx * 8) +: 8] = (value[idx] ? "1" : "0") ;
                end
            int_to_2b_str = {"0b",
                    binstr} ;
        end
    endfunction
    function [(((2 + 12) * 8) - 1):0] int_to_12b_str ; 
    // int_to_12b_str
        input [11:0] value ; 
        reg [((8 * 12) - 1):0] binstr ; 
        integer idx ; 
        begin
            for (idx = 0 ; (idx < 12) ; idx = (idx + 1))
                begin
                    binstr[(idx * 8) +: 8] = (value[idx] ? "1" : "0") ;
                end
            int_to_12b_str = {"0b",
                    binstr} ;
        end
    endfunction
    function [(((2 + 14) * 8) - 1):0] int_to_14b_str ; 
    // int_to_14b_str
        input [13:0] value ; 
        reg [((8 * 14) - 1):0] binstr ; 
        integer idx ; 
        begin
            for (idx = 0 ; (idx < 14) ; idx = (idx + 1))
                begin
                    binstr[(idx * 8) +: 8] = (value[idx] ? "1" : "0") ;
                end
            int_to_14b_str = {"0b",
                    binstr} ;
        end
    endfunction
    function [(((2 + 26) * 8) - 1):0] int_to_26b_str ; 
    // int_to_26b_str
        input [25:0] value ; 
        reg [((8 * 26) - 1):0] binstr ; 
        integer idx ; 
        begin
            for (idx = 0 ; (idx < 26) ; idx = (idx + 1))
                begin
                    binstr[(idx * 8) +: 8] = (value[idx] ? "1" : "0") ;
                end
            int_to_26b_str = {"0b",
                    binstr} ;
        end
    endfunction
    //--------------------------------------------------------------------------
    //--- Local Parameters/Defines ---
    //--------------------------------------------------------------------------
    // ------------------------------------
    // intermediate values - for debugging
    // ------------------------------------
    localparam REFCLK_DIV = (PLL_CLKR + 1) ; 
    localparam FBK_INTG_DIV = PLL_CLKF[25:14] ; 
    localparam FBK_FRAC_DIV = PLL_CLKF[13:6] ; 
    localparam FBK_FRAC_SSC = PLL_CLKF[5:0] ; 
    localparam FBK_FRAC_14B = PLL_CLKF[13:0] ; 
    localparam BWADJ_DIV = (PLL_BWADJ + 1) ; 
    localparam CLK0_DIV = (PLL_CLKOD0 + 1) ; 
    localparam CLK1_DIV = (PLL_CLKOD1 + 1) ; 
    localparam CLK2_DIV = (PLL_CLKOD2 + 1) ; 
    localparam CLK3_DIV = (PLL_CLKOD3 + 1) ; 
    localparam CLK4_DIV = (PLL_CLKOD4 + 1) ; 
    localparam CLK5_DIV = (PLL_CLKOD5 + 1) ; 
    localparam CLK6_DIV = (PLL_CLKOD6 + 1) ; 
    localparam CLK7_DIV = (PLL_CLKOD7 + 1) ; 
    // VCO Frequency
    localparam FVCO = int_to_str(VCO_FREQ) ; 
    // Reference Clock Frequency
    localparam FCLKI = int_to_str(REFCLK_FREQ) ; 
    // Reference Clock Divider
    localparam CLKI_DIV = int_to_str(REFCLK_DIV) ; 
    // Reference Clock Mux Select
    localparam CLKI_SEL = (REFCLK_SEL ? "REFMUX1" : "REFMUX0") ; 
    // Feedback Divider - CLKF[25:0]: [25:14] - int, [13:6] - fracN, [5:0] - ssc
    localparam CLKFB_DIV = int_to_str(FBK_INTG_DIV) ; 
    localparam CLKFB_PATH = (PLL_INTFBK ? "INTERNAL" : (USE_ECLK_FBPATH ? "EXTERNAL_ECLK" : "EXTERNAL")) ; 
    localparam FRACTIONAL_FBK = int_to_14b_str(FBK_FRAC_14B) ; 
    localparam EXT_FB_DELAY = int_to_2b_str(EXT_FBK_DELAY) ; 
    // Bandwidth Adjustment divider - BWADJ[11:0]
    //localparam                    LOOP_BW                 = `STR_PARAM_TYPE(int_to_12b_str(PLL_BWADJ));
    // initial BW ratio should be 1.0 (i.e. NB = effective feedback divider)
    // for internal feedback NB=NF, for external feedback NB=NF*OD
    localparam EFF_FBK_DIV = (PLL_INTFBK ? FBK_INTG_DIV : ((FBKSEL_CLKOUT == 6) ? (FBK_INTG_DIV * CLK6_DIV) : ((FBKSEL_CLKOUT == 5) ? (FBK_INTG_DIV * CLK5_DIV) : ((FBKSEL_CLKOUT == 4) ? (FBK_INTG_DIV * CLK4_DIV) : ((FBKSEL_CLKOUT == 3) ? (FBK_INTG_DIV * CLK3_DIV) : ((FBKSEL_CLKOUT == 2) ? (FBK_INTG_DIV * CLK2_DIV) : ((FBKSEL_CLKOUT == 1) ? (FBK_INTG_DIV * CLK1_DIV) : (FBK_INTG_DIV * CLK0_DIV)))))))) ; 
    localparam NB_INIT = (EFF_FBK_DIV - 1) ; 
    localparam LOOP_BW = int_to_12b_str(NB_INIT) ; 
    // SSC spreading Slope control - CLKV[25:0]
    localparam CLKV_SSC_SLOPE = int_to_26b_str(PLL_CLKV) ; 
    // SSC spreading rate divider - CLKS[11:0]
    localparam CLKS_SSC_RATE = int_to_12b_str(PLL_CLKS) ; 
    // External Output Dividers
    localparam CLKOP_DIV = (EN_EXT_CLKDIV ? int_to_str(CLK0_DIV) : "1") ; 
    localparam CLKOS_DIV = (EN_EXT_CLKDIV ? int_to_str(CLK1_DIV) : "1") ; 
    localparam CLKOS2_DIV = (EN_EXT_CLKDIV ? int_to_str(CLK2_DIV) : "1") ; 
    localparam CLKOS3_DIV = (EN_EXT_CLKDIV ? int_to_str(CLK3_DIV) : "1") ; 
    localparam CLKOS4_DIV = (EN_EXT_CLKDIV ? int_to_str(CLK4_DIV) : "1") ; 
    localparam CLKOS5_DIV = (EN_EXT_CLKDIV ? int_to_str(CLK5_DIV) : "1") ; 
    localparam CLKPHY_DIV = (EN_EXT_CLKDIV ? int_to_str(CLK6_DIV) : "1") ; 
    // set external output divider to 2, then combined with internal output divider (20) - a total of 40
    // CLK7 would have a range of 40 MHz to 100 MHz (150 MHz worst case)
    localparam INT_CLK7_DIV = (EN_EXT_CLKDIV ? int_to_str(2) : "1") ; 
    // Internal Output Dividers
    localparam INT_CLKOD0_DIV = (EN_EXT_CLKDIV ? "1" : int_to_str(CLK0_DIV)) ; 
    localparam INT_CLKOD1_DIV = (EN_EXT_CLKDIV ? "1" : int_to_str(CLK1_DIV)) ; 
    localparam INT_CLKOD2_DIV = (EN_EXT_CLKDIV ? "1" : int_to_str(CLK2_DIV)) ; 
    localparam INT_CLKOD3_DIV = (EN_EXT_CLKDIV ? "1" : int_to_str(CLK3_DIV)) ; 
    localparam INT_CLKOD4_DIV = (EN_EXT_CLKDIV ? "1" : int_to_str(CLK4_DIV)) ; 
    localparam INT_CLKOD5_DIV = (EN_EXT_CLKDIV ? "1" : int_to_str(CLK5_DIV)) ; 
    localparam INT_CLKOD6_DIV = (EN_EXT_CLKDIV ? "1" : int_to_str(CLK6_DIV)) ; 
    //localparam                    INT_CLKOD7_DIV          = (EN_EXT_CLKDIV)? "1" : `STR_PARAM_TYPE(int_to_str(25));
    localparam INT_CLKOD7_DIV = int_to_str(20) ; // this should be a fix value in PLL primitive
    // Clock Output Bypass (external)
    localparam CLKOP_OUT_SEL = (CLK0_BYP ? "CLKI" : "DIVA") ; 
    localparam CLKOS_OUT_SEL = (CLK1_BYP ? "CLKI" : "DIVB") ; 
    localparam CLKOS2_OUT_SEL = (CLK2_BYP ? "CLKI" : "DIVC") ; 
    localparam CLKOS3_OUT_SEL = (CLK3_BYP ? "CLKI" : "DIVD") ; 
    localparam CLKOS4_OUT_SEL = (CLK4_BYP ? "CLKI" : "DIVE") ; 
    localparam CLKOS5_OUT_SEL = (CLK5_BYP ? "CLKI" : "DIVF") ; 
    localparam CLKPHY_OUT_SEL = (CLK6_BYP ? "CLKI" : "DIVPHY") ; 
    localparam TEST_CLK7_OUT_SEL = (CLK7_BYP ? "CLKI" : "DIVRES") ; 
    // Enable output(s) sync with CLKOP
    localparam SYNC_CLKOP = (EN_SYNC_CLK0 ? "ENABLED" : "DISABLED") ; 
    // Enable fast lock
    localparam FAST_LOCK = (EN_FAST_LOCK ? "ENABLED" : "DISABLED") ; 
    // Reset PLL when loss of lock is detected
    localparam LOSS_LOCK_DETECTION = "DISABLED" ; // recommended by PE
    // Enable Spread Spectrum clock
    localparam SCC_SS = (PLL_SSEN ? "ENABLED" : "DISABLED") ; 
    // Enable Fractional accumulation - Dithering
    localparam SCC_FRACTIONAL = (PLL_DITHEN ? "ENABLED" : "DISABLED") ; 
    // Enable saturation
    localparam SATURATION = (PLL_ENSAT ? "ENABLED" : "DISABLED") ; 
    // Enable PLL reset port
    localparam EN_PLLRESET = (EN_PLL_RST ? "ENABLED" : "DISABLED") ; 
    // Enable Clock Output port
    localparam EN_CLKOP_OUT = (EN_CLK0_OUT ? "ON" : "OFF") ; 
    localparam EN_CLKOS_OUT = (EN_CLK1_OUT ? "ON" : "OFF") ; 
    localparam EN_CLKOS2_OUT = (EN_CLK2_OUT ? "ON" : "OFF") ; 
    localparam EN_CLKOS3_OUT = (EN_CLK3_OUT ? "ON" : "OFF") ; 
    localparam EN_CLKOS4_OUT = (EN_CLK4_OUT ? "ON" : "OFF") ; 
    localparam EN_CLKOS5_OUT = (EN_CLK5_OUT ? "ON" : "OFF") ; 
    localparam EN_CLKPHY_OUT = (EN_CLK6_OUT ? "ON" : "OFF") ; 
    localparam TEST_EN_CLK7_OUT = (EN_STARTUP_BW ? "ON" : "OFF") ; 
    // Use Clock Output Enable port
    localparam EN_CLKOP = ((EN_CLK0_OUT && (!EN_CLK0_CLKEN)) ? "YES" : "NO") ; 
    localparam EN_CLKOS = ((EN_CLK1_OUT && (!EN_CLK1_CLKEN)) ? "YES" : "NO") ; 
    localparam EN_CLKOS2 = ((EN_CLK2_OUT && (!EN_CLK2_CLKEN)) ? "YES" : "NO") ; 
    localparam EN_CLKOS3 = ((EN_CLK3_OUT && (!EN_CLK3_CLKEN)) ? "YES" : "NO") ; 
    localparam EN_CLKOS4 = ((EN_CLK4_OUT && (!EN_CLK4_CLKEN)) ? "YES" : "NO") ; 
    localparam EN_CLKOS5 = ((EN_CLK5_OUT && (!EN_CLK5_CLKEN)) ? "YES" : "NO") ; 
    localparam EN_CLKPHY = ((EN_CLK6_OUT && (!EN_CLK6_CLKEN)) ? "YES" : "NO") ; 
    localparam TEST_EN_CLK7 = ((EN_STARTUP_BW && (!EN_CLK7_CLKEN)) ? "YES" : "NO") ; 
    // Phase shift source - static or dynamic
    localparam PHASE_SOURCE = (PHASE_SHIFT_TYPE ? "DYN" : "STATIC") ; 
    // Static VCO Phase shift
    localparam CLKOP_FPHASE = int_to_str(CLK0_PHI) ; 
    localparam CLKOS_FPHASE = int_to_str(CLK1_PHI) ; 
    localparam CLKOS2_FPHASE = int_to_str(CLK2_PHI) ; 
    localparam CLKOS3_FPHASE = int_to_str(CLK3_PHI) ; 
    localparam CLKOS4_FPHASE = int_to_str(CLK4_PHI) ; 
    localparam CLKOS5_FPHASE = int_to_str(CLK5_PHI) ; 
    localparam CLKPHY_FPHASE = int_to_str(CLK6_PHI) ; 
    localparam TEST_CLK7_FPHASE = int_to_str(CLK7_PHI) ; 
    // Static Divider Phase shift
    localparam CLKOP_CPHASE = int_to_str(CLK0_DEL) ; 
    localparam CLKOS_CPHASE = int_to_str(CLK1_DEL) ; 
    localparam CLKOS2_CPHASE = int_to_str(CLK2_DEL) ; 
    localparam CLKOS3_CPHASE = int_to_str(CLK3_DEL) ; 
    localparam CLKOS4_CPHASE = int_to_str(CLK4_DEL) ; 
    localparam CLKOS5_CPHASE = int_to_str(CLK5_DEL) ; 
    localparam CLKOPHY_CPHASE = int_to_str(CLK6_DEL) ; 
    localparam TEST_CLK7_CPHASE = int_to_str(CLK7_DEL) ; 
    localparam EN_PLL = "ENABLED" ; 
    localparam CONFIG_WAIT_FOR_LOCK = (WAIT_FOR_LOCK ? "ENABLED" : "DISABLED") ; 
    // programmable phase control -- need not be set
    localparam STATIC_PHASE_SEL = "CLKOP" ; // dyn_sel
    localparam STATIC_PHASE_LOADREG = "NO" ; // load_reg
    localparam STATIC_VCO_PHASE_STEP = "NO" ; // rotate
    localparam STATIC_VCO_PHASE_DIR = "DELAYED" ; // direction
    //--------------------------------------------------------------------------
    //--- Combinational Wire/Reg ---
    //--------------------------------------------------------------------------
    /*AUTOREGINPUT*/
    /*AUTOWIRE*/
    wire rst_i ; 
    wire fbkclk_i ; 
    // hard IP wires
    wire init_clk_i ; 
    wire pll_lock ; 
    wire lmmi_clk_w ; 
    wire lmmi_resetn_w ; 
    wire lmmi_request_w ; 
    wire lmmi_wr_rdn_w ; 
    wire [4:0] lmmi_offset_w ; 
    wire [15:0] lmmi_wdata_w ; 
    wire lmmi_ready_w ; 
    wire lmmi_rdata_valid_w ; 
    wire [15:0] lmmi_rdata_w ; 
    // user interface wires
    wire usr_lmmi_clk_i ; 
    wire usr_lmmi_resetn_i ; 
    wire usr_lmmi_request_i ; 
    wire usr_lmmi_wr_rdn_i ; 
    wire [4:0] usr_lmmi_offset_i ; 
    wire [15:0] usr_lmmi_wdata_i ; 
    wire usr_lmmi_ready_o ; 
    wire usr_lmmi_rdata_valid_o ; 
    wire [15:0] usr_lmmi_rdata_o ; 
    //--------------------------------------------------------------------------
    //--- Registers ---
    //--------------------------------------------------------------------------
    assign rst_i = (~rst_n_i) ; 
    // if PLL_INTFBK == 1, fbclk_i doesn't matter
    assign fbkclk_i = (PLL_INTFBK ? 1'b0 : (EN_USR_FBKCLK ? usr_fbkclk_i : ((FBKSEL_CLKOUT == 7) ? clkout_testclk_o : ((FBKSEL_CLKOUT == 6) ? clkout_clkophy_o : ((FBKSEL_CLKOUT == 5) ? clkout_clkos5_o : ((FBKSEL_CLKOUT == 4) ? clkout_clkos4_o : ((FBKSEL_CLKOUT == 3) ? clkout_clkos3_o : ((FBKSEL_CLKOUT == 2) ? clkout_clkos2_o : ((FBKSEL_CLKOUT == 1) ? clkout_clkos_o : clkout_clkop_o))))))))) ; 
    assign init_clk_i = clkout_testclk_o ; 
    //--------------------------------------------------------------------------
    //--- Module Instantiation ---
    //--------------------------------------------------------------------------
    generate
        if ((REG_INTERFACE == "APB")) 
            begin : gen_apb
                wire [4:0] apb_paddr_w ; 
                assign apb_paddr_w = (REG_MAPPING ? apb_paddr_i[6:2] : apb_paddr_i[4:0]) ; 
                tx_pll_ipgen_apb2lmmi #(.DATA_WIDTH(16),
                        .ADDR_WIDTH(5),
                        .REG_OUTPUT(1)) u_apb (// Parameters
                        // Inputs
                        .clk_i(apb_pclk_i), 
                            .rst_n_i(apb_preset_n_i), 
                            .apb_penable_i(apb_penable_i), 
                            .apb_psel_i(apb_psel_i), 
                            .apb_pwrite_i(apb_pwrite_i), 
                            .apb_paddr_i(apb_paddr_w[4:0]), 
                            .apb_pwdata_i(apb_pwdata_i[15:0]), 
                            .lmmi_ready_i(usr_lmmi_ready_o), 
                            .lmmi_rdata_valid_i(usr_lmmi_rdata_valid_o), 
                            .lmmi_error_i(1'b0), 
                            .lmmi_rdata_i(usr_lmmi_rdata_o[15:0]), 
                            // Outputs
                        .apb_pready_o(apb_pready_o), 
                            .apb_pslverr_o(apb_pslverr_o), 
                            .apb_prdata_o(apb_prdata_o[15:0]), 
                            .lmmi_request_o(usr_lmmi_request_i), 
                            .lmmi_wr_rdn_o(usr_lmmi_wr_rdn_i), 
                            .lmmi_offset_o(usr_lmmi_offset_i[4:0]), 
                            .lmmi_wdata_o(usr_lmmi_wdata_i[15:0]), 
                            .lmmi_resetn_o() /*AUTOINST*/) ; 
                assign usr_lmmi_clk_i = apb_pclk_i ; 
                assign usr_lmmi_resetn_i = apb_preset_n_i ; 
                assign lmmi_ready_o = 1'b0 ; 
                assign lmmi_rdata_valid_o = 1'b0 ; 
                assign lmmi_rdata_o = usr_lmmi_rdata_o ; 
            end
        else
            begin : gen_lmmi
                assign usr_lmmi_clk_i = lmmi_clk_i ; 
                assign usr_lmmi_resetn_i = lmmi_resetn_i ; 
                assign usr_lmmi_wdata_i = lmmi_wdata_i ; 
                assign usr_lmmi_wr_rdn_i = lmmi_wr_rdn_i ; 
                assign usr_lmmi_offset_i = lmmi_offset_i ; 
                assign usr_lmmi_request_i = lmmi_request_i ; 
                assign lmmi_ready_o = usr_lmmi_ready_o ; 
                assign lmmi_rdata_valid_o = usr_lmmi_rdata_valid_o ; 
                assign lmmi_rdata_o = usr_lmmi_rdata_o ; 
                assign apb_pready_o = 1'b0 ; 
                assign apb_pslverr_o = 1'b0 ; 
                assign apb_prdata_o = 16'd0 ; 
            end
        if (SIMULATION) 
            begin : gen_sim_disp
                initial
                    begin
                        $display ("----------------------------------------------------------------------") ;
                        $display ("----------------------- PLL Wrapper Parameters -----------------------") ;
                        $display ("----------------------------------------------------------------------") ;
                        $display ("[DEBUG] PLL wrapper parameter : VCO_FREQ         = %0f",
                                VCO_FREQ) ;
                        $display ("[DEBUG] PLL wrapper parameter : REFCLK_FREQ      = %0f",
                                REFCLK_FREQ) ;
                        $display ("[DEBUG] PLL wrapper parameter : REFCLK_SEL       = %0d",
                                REFCLK_SEL) ;
                        $display ("[DEBUG] PLL wrapper parameter : FBKSEL_CLKOUT    = %0d",
                                FBKSEL_CLKOUT) ;
                        $display ("[DEBUG] PLL wrapper parameter : EXT_FBK_DELAY    = %0d",
                                EXT_FBK_DELAY) ;
                        $display ("[DEBUG] PLL wrapper parameter : EN_USR_FBKCLK    = %0d",
                                EN_USR_FBKCLK) ;
                        $display ("[DEBUG] PLL wrapper parameter : EN_EXT_CLKDIV    = %0d",
                                EN_EXT_CLKDIV) ;
                        $display ("[DEBUG] PLL wrapper parameter : EN_SYNC_CLK0     = %0d",
                                EN_SYNC_CLK0) ;
                        $display ("[DEBUG] PLL wrapper parameter : EN_FAST_LOCK     = %0d",
                                EN_FAST_LOCK) ;
                        $display ("[DEBUG] PLL wrapper parameter : EN_LOCK_DETECT   = %0d",
                                EN_LOCK_DETECT) ;
                        $display ("[DEBUG] PLL wrapper parameter : EN_PLL_RST       = %0d",
                                EN_PLL_RST) ;
                        $display ("[DEBUG] PLL wrapper parameter : EN_CLK0_OUT      = %0d",
                                EN_CLK0_OUT) ;
                        $display ("[DEBUG] PLL wrapper parameter : EN_CLK1_OUT      = %0d",
                                EN_CLK1_OUT) ;
                        $display ("[DEBUG] PLL wrapper parameter : EN_CLK2_OUT      = %0d",
                                EN_CLK2_OUT) ;
                        $display ("[DEBUG] PLL wrapper parameter : EN_CLK3_OUT      = %0d",
                                EN_CLK3_OUT) ;
                        $display ("[DEBUG] PLL wrapper parameter : EN_CLK4_OUT      = %0d",
                                EN_CLK4_OUT) ;
                        $display ("[DEBUG] PLL wrapper parameter : EN_CLK5_OUT      = %0d",
                                EN_CLK5_OUT) ;
                        $display ("[DEBUG] PLL wrapper parameter : EN_CLK6_OUT      = %0d",
                                EN_CLK6_OUT) ;
                        $display ("[DEBUG] PLL wrapper parameter : EN_CLK7_OUT      = %0d",
                                EN_CLK7_OUT) ;
                        $display ("[DEBUG] PLL wrapper parameter : EN_CLK0_CLKEN    = %0d",
                                EN_CLK0_CLKEN) ;
                        $display ("[DEBUG] PLL wrapper parameter : EN_CLK1_CLKEN    = %0d",
                                EN_CLK1_CLKEN) ;
                        $display ("[DEBUG] PLL wrapper parameter : EN_CLK2_CLKEN    = %0d",
                                EN_CLK2_CLKEN) ;
                        $display ("[DEBUG] PLL wrapper parameter : EN_CLK3_CLKEN    = %0d",
                                EN_CLK3_CLKEN) ;
                        $display ("[DEBUG] PLL wrapper parameter : EN_CLK4_CLKEN    = %0d",
                                EN_CLK4_CLKEN) ;
                        $display ("[DEBUG] PLL wrapper parameter : EN_CLK5_CLKEN    = %0d",
                                EN_CLK5_CLKEN) ;
                        $display ("[DEBUG] PLL wrapper parameter : EN_CLK6_CLKEN    = %0d",
                                EN_CLK6_CLKEN) ;
                        $display ("[DEBUG] PLL wrapper parameter : EN_CLK7_CLKEN    = %0d",
                                EN_CLK7_CLKEN) ;
                        $display ("[DEBUG] PLL wrapper parameter : CLK0_BYP         = %0d",
                                CLK0_BYP) ;
                        $display ("[DEBUG] PLL wrapper parameter : CLK1_BYP         = %0d",
                                CLK1_BYP) ;
                        $display ("[DEBUG] PLL wrapper parameter : CLK2_BYP         = %0d",
                                CLK2_BYP) ;
                        $display ("[DEBUG] PLL wrapper parameter : CLK3_BYP         = %0d",
                                CLK3_BYP) ;
                        $display ("[DEBUG] PLL wrapper parameter : CLK4_BYP         = %0d",
                                CLK4_BYP) ;
                        $display ("[DEBUG] PLL wrapper parameter : CLK5_BYP         = %0d",
                                CLK5_BYP) ;
                        $display ("[DEBUG] PLL wrapper parameter : CLK6_BYP         = %0d",
                                CLK6_BYP) ;
                        $display ("[DEBUG] PLL wrapper parameter : CLK7_BYP         = %0d",
                                CLK7_BYP) ;
                        $display ("[DEBUG] PLL wrapper parameter : PHASE_SHIFT_TYPE = %0d",
                                PHASE_SHIFT_TYPE) ;
                        $display ("[DEBUG] PLL wrapper parameter : CLK0_PHI         = %0d",
                                CLK0_PHI) ;
                        $display ("[DEBUG] PLL wrapper parameter : CLK1_PHI         = %0d",
                                CLK1_PHI) ;
                        $display ("[DEBUG] PLL wrapper parameter : CLK2_PHI         = %0d",
                                CLK2_PHI) ;
                        $display ("[DEBUG] PLL wrapper parameter : CLK3_PHI         = %0d",
                                CLK3_PHI) ;
                        $display ("[DEBUG] PLL wrapper parameter : CLK4_PHI         = %0d",
                                CLK4_PHI) ;
                        $display ("[DEBUG] PLL wrapper parameter : CLK5_PHI         = %0d",
                                CLK5_PHI) ;
                        $display ("[DEBUG] PLL wrapper parameter : CLK6_PHI         = %0d",
                                CLK6_PHI) ;
                        $display ("[DEBUG] PLL wrapper parameter : CLK7_PHI         = %0d",
                                CLK7_PHI) ;
                        $display ("[DEBUG] PLL wrapper parameter : CLK0_DEL         = %0d",
                                CLK0_DEL) ;
                        $display ("[DEBUG] PLL wrapper parameter : CLK1_DEL         = %0d",
                                CLK1_DEL) ;
                        $display ("[DEBUG] PLL wrapper parameter : CLK2_DEL         = %0d",
                                CLK2_DEL) ;
                        $display ("[DEBUG] PLL wrapper parameter : CLK3_DEL         = %0d",
                                CLK3_DEL) ;
                        $display ("[DEBUG] PLL wrapper parameter : CLK4_DEL         = %0d",
                                CLK4_DEL) ;
                        $display ("[DEBUG] PLL wrapper parameter : CLK5_DEL         = %0d",
                                CLK5_DEL) ;
                        $display ("[DEBUG] PLL wrapper parameter : CLK6_DEL         = %0d",
                                CLK6_DEL) ;
                        $display ("[DEBUG] PLL wrapper parameter : CLK7_DEL         = %0d",
                                CLK7_DEL) ;
                        $display ("[DEBUG] PLL wrapper parameter : PLL_SSEN         = %0d",
                                PLL_SSEN) ;
                        $display ("[DEBUG] PLL wrapper parameter : PLL_DITHEN       = %0d",
                                PLL_DITHEN) ;
                        $display ("[DEBUG] PLL wrapper parameter : PLL_ENSAT        = %0d",
                                PLL_ENSAT) ;
                        $display ("[DEBUG] PLL wrapper parameter : PLL_INTFBK       = %0d",
                                PLL_INTFBK) ;
                        $display ("[DEBUG] PLL wrapper parameter : PLL_CLKR         = %0d",
                                PLL_CLKR) ;
                        $display ("[DEBUG] PLL wrapper parameter : PLL_CLKF         = %0d",
                                PLL_CLKF) ;
                        $display ("[DEBUG] PLL wrapper parameter : PLL_CLKV         = %0d",
                                PLL_CLKV) ;
                        $display ("[DEBUG] PLL wrapper parameter : PLL_CLKS         = %0d",
                                PLL_CLKS) ;
                        $display ("[DEBUG] PLL wrapper parameter : PLL_BWADJ        = %0d",
                                PLL_BWADJ) ;
                        $display ("[DEBUG] PLL wrapper parameter : PLL_CLKOD0       = %0d",
                                PLL_CLKOD0) ;
                        $display ("[DEBUG] PLL wrapper parameter : PLL_CLKOD1       = %0d",
                                PLL_CLKOD1) ;
                        $display ("[DEBUG] PLL wrapper parameter : PLL_CLKOD2       = %0d",
                                PLL_CLKOD2) ;
                        $display ("[DEBUG] PLL wrapper parameter : PLL_CLKOD3       = %0d",
                                PLL_CLKOD3) ;
                        $display ("[DEBUG] PLL wrapper parameter : PLL_CLKOD4       = %0d",
                                PLL_CLKOD4) ;
                        $display ("[DEBUG] PLL wrapper parameter : PLL_CLKOD5       = %0d",
                                PLL_CLKOD5) ;
                        $display ("[DEBUG] PLL wrapper parameter : PLL_CLKOD6       = %0d",
                                PLL_CLKOD6) ;
                        $display ("[DEBUG] PLL wrapper parameter : PLL_CLKOD7       = %0d",
                                PLL_CLKOD7) ;
                        $display ("[DEBUG] PLL wrapper parameter : REG_INTERFACE    = %0s",
                                REG_INTERFACE) ;
                        $display ("[DEBUG] PLL wrapper parameter : SIMULATION       = %0d",
                                SIMULATION) ;
                        $display ("----------------------------------------------------------------------") ;
                        $display ("---------------------- PLL Primitive Parameters ----------------------") ;
                        $display ("----------------------------------------------------------------------") ;
                        $display ("[DEBUG] PLL Primitive parameter : FCLKI                 = %0s",
                                FCLKI) ;
                        $display ("[DEBUG] PLL Primitive parameter : FVCO                  = %0s",
                                FVCO) ;
                        $display ("[DEBUG] PLL Primitive parameter : EN_PLL                = %0s",
                                EN_PLL) ;
                        $display ("[DEBUG] PLL Primitive parameter : EN_PLLRESET           = %0s",
                                EN_PLLRESET) ;
                        $display ("[DEBUG] PLL Primitive parameter : SATURATION            = %0s",
                                SATURATION) ;
                        $display ("[DEBUG] PLL Primitive parameter : SCC_SS                = %0s",
                                SCC_SS) ;
                        $display ("[DEBUG] PLL Primitive parameter : SCC_FRACTIONAL        = %0s",
                                SCC_FRACTIONAL) ;
                        $display ("[DEBUG] PLL Primitive parameter : EN_CLKOP              = %0s",
                                EN_CLKOP) ;
                        $display ("[DEBUG] PLL Primitive parameter : EN_CLKOS              = %0s",
                                EN_CLKOS) ;
                        $display ("[DEBUG] PLL Primitive parameter : EN_CLKOS2             = %0s",
                                EN_CLKOS2) ;
                        $display ("[DEBUG] PLL Primitive parameter : EN_CLKOS3             = %0s",
                                EN_CLKOS3) ;
                        $display ("[DEBUG] PLL Primitive parameter : EN_CLKOS4             = %0s",
                                EN_CLKOS4) ;
                        $display ("[DEBUG] PLL Primitive parameter : EN_CLKOS5             = %0s",
                                EN_CLKOS5) ;
                        $display ("[DEBUG] PLL Primitive parameter : EN_CLKPHY             = %0s",
                                EN_CLKPHY) ;
                        $display ("[DEBUG] PLL Primitive parameter : EN_CLKRES             = %0s",
                                TEST_EN_CLK7) ;
                        $display ("[DEBUG] PLL Primitive parameter : EN_CLKOP_OUT          = %0s",
                                EN_CLKOP_OUT) ;
                        $display ("[DEBUG] PLL Primitive parameter : EN_CLKOS_OUT          = %0s",
                                EN_CLKOS_OUT) ;
                        $display ("[DEBUG] PLL Primitive parameter : EN_CLKOS2_OUT         = %0s",
                                EN_CLKOS2_OUT) ;
                        $display ("[DEBUG] PLL Primitive parameter : EN_CLKOS3_OUT         = %0s",
                                EN_CLKOS3_OUT) ;
                        $display ("[DEBUG] PLL Primitive parameter : EN_CLKOS4_OUT         = %0s",
                                EN_CLKOS4_OUT) ;
                        $display ("[DEBUG] PLL Primitive parameter : EN_CLKOS5_OUT         = %0s",
                                EN_CLKOS5_OUT) ;
                        $display ("[DEBUG] PLL Primitive parameter : EN_CLKPHY_OUT         = %0s",
                                EN_CLKPHY_OUT) ;
                        $display ("[DEBUG] PLL Primitive parameter : EN_CLKRES_OUT         = %0s",
                                TEST_EN_CLK7_OUT) ;
                        $display ("[DEBUG] PLL Primitive parameter : CLKOP_OUT_SEL         = %0s",
                                CLKOP_OUT_SEL) ;
                        $display ("[DEBUG] PLL Primitive parameter : CLKOS_OUT_SEL         = %0s",
                                CLKOS_OUT_SEL) ;
                        $display ("[DEBUG] PLL Primitive parameter : CLKOS2_OUT_SEL        = %0s",
                                CLKOS2_OUT_SEL) ;
                        $display ("[DEBUG] PLL Primitive parameter : CLKOS3_OUT_SEL        = %0s",
                                CLKOS3_OUT_SEL) ;
                        $display ("[DEBUG] PLL Primitive parameter : CLKOS4_OUT_SEL        = %0s",
                                CLKOS4_OUT_SEL) ;
                        $display ("[DEBUG] PLL Primitive parameter : CLKOS5_OUT_SEL        = %0s",
                                CLKOS5_OUT_SEL) ;
                        $display ("[DEBUG] PLL Primitive parameter : CLKPHY_OUT_SEL        = %0s",
                                CLKPHY_OUT_SEL) ;
                        $display ("[DEBUG] PLL Primitive parameter : CLKRES_OUT_SEL        = %0s",
                                TEST_CLK7_OUT_SEL) ;
                        $display ("[DEBUG] PLL Primitive parameter : CLKI_SEL              = %0s",
                                CLKI_SEL) ;
                        $display ("[DEBUG] PLL Primitive parameter : CLKFB_PATH            = %0s",
                                CLKFB_PATH) ;
                        $display ("[DEBUG] PLL Primitive parameter : CLKI_DIV              = %0s",
                                CLKI_DIV) ;
                        $display ("[DEBUG] PLL Primitive parameter : CLKFB_DIV             = %0s",
                                CLKFB_DIV) ;
                        $display ("[DEBUG] PLL Primitive parameter : FRACTIONAL_FBK        = %0s",
                                FRACTIONAL_FBK) ;
                        $display ("[DEBUG] PLL Primitive parameter : LOOP_BW               = %0s",
                                LOOP_BW) ;
                        $display ("[DEBUG] PLL Primitive parameter : CLKV_SSC_SLOPE        = %0s",
                                CLKV_SSC_SLOPE) ;
                        $display ("[DEBUG] PLL Primitive parameter : CLKS_SSC_RATE         = %0s",
                                CLKS_SSC_RATE) ;
                        $display ("[DEBUG] PLL Primitive parameter : EXT_FB_DELAY          = %0s",
                                EXT_FB_DELAY) ;
                        $display ("[DEBUG] PLL Primitive parameter : CLKOP_DIV             = %0s",
                                CLKOP_DIV) ;
                        $display ("[DEBUG] PLL Primitive parameter : CLKOS_DIV             = %0s",
                                CLKOS_DIV) ;
                        $display ("[DEBUG] PLL Primitive parameter : CLKOS2_DIV            = %0s",
                                CLKOS2_DIV) ;
                        $display ("[DEBUG] PLL Primitive parameter : CLKOS3_DIV            = %0s",
                                CLKOS3_DIV) ;
                        $display ("[DEBUG] PLL Primitive parameter : CLKOS4_DIV            = %0s",
                                CLKOS4_DIV) ;
                        $display ("[DEBUG] PLL Primitive parameter : CLKOS5_DIV            = %0s",
                                CLKOS5_DIV) ;
                        $display ("[DEBUG] PLL Primitive parameter : CLKPHY_DIV            = %0s",
                                CLKPHY_DIV) ;
                        $display ("[DEBUG] PLL Primitive parameter : CLKRES_DIV            = %0s",
                                INT_CLK7_DIV) ;
                        $display ("[DEBUG] PLL Primitive parameter : INT_CLKOD0_DIV        = %0s",
                                INT_CLKOD0_DIV) ;
                        $display ("[DEBUG] PLL Primitive parameter : INT_CLKOD1_DIV        = %0s",
                                INT_CLKOD1_DIV) ;
                        $display ("[DEBUG] PLL Primitive parameter : INT_CLKOD2_DIV        = %0s",
                                INT_CLKOD2_DIV) ;
                        $display ("[DEBUG] PLL Primitive parameter : INT_CLKOD3_DIV        = %0s",
                                INT_CLKOD3_DIV) ;
                        $display ("[DEBUG] PLL Primitive parameter : INT_CLKOD4_DIV        = %0s",
                                INT_CLKOD4_DIV) ;
                        $display ("[DEBUG] PLL Primitive parameter : INT_CLKOD5_DIV        = %0s",
                                INT_CLKOD5_DIV) ;
                        $display ("[DEBUG] PLL Primitive parameter : INT_CLKOD6_DIV        = %0s",
                                INT_CLKOD6_DIV) ;
                        $display ("[DEBUG] PLL Primitive parameter : INT_CLKOD7_DIV        = %0s",
                                INT_CLKOD7_DIV) ;
                        $display ("[DEBUG] PLL Primitive parameter : SYNC_CLKOP            = %0s",
                                SYNC_CLKOP) ;
                        $display ("[DEBUG] PLL Primitive parameter : PHASE_SOURCE          = %0s",
                                PHASE_SOURCE) ;
                        $display ("[DEBUG] PLL Primitive parameter : CLKOP_FPHASE          = %0s",
                                CLKOP_FPHASE) ;
                        $display ("[DEBUG] PLL Primitive parameter : CLKOS_FPHASE          = %0s",
                                CLKOS_FPHASE) ;
                        $display ("[DEBUG] PLL Primitive parameter : CLKOS2_FPHASE         = %0s",
                                CLKOS2_FPHASE) ;
                        $display ("[DEBUG] PLL Primitive parameter : CLKOS3_FPHASE         = %0s",
                                CLKOS3_FPHASE) ;
                        $display ("[DEBUG] PLL Primitive parameter : CLKOS4_FPHASE         = %0s",
                                CLKOS4_FPHASE) ;
                        $display ("[DEBUG] PLL Primitive parameter : CLKOS5_FPHASE         = %0s",
                                CLKOS5_FPHASE) ;
                        $display ("[DEBUG] PLL Primitive parameter : CLKPHY_FPHASE         = %0s",
                                CLKPHY_FPHASE) ;
                        $display ("[DEBUG] PLL Primitive parameter : CLKRES_FPHASE         = %0s",
                                TEST_CLK7_FPHASE) ;
                        $display ("[DEBUG] PLL Primitive parameter : CLKOP_CPHASE          = %0s",
                                CLKOP_CPHASE) ;
                        $display ("[DEBUG] PLL Primitive parameter : CLKOS_CPHASE          = %0s",
                                CLKOS_CPHASE) ;
                        $display ("[DEBUG] PLL Primitive parameter : CLKOS2_CPHASE         = %0s",
                                CLKOS2_CPHASE) ;
                        $display ("[DEBUG] PLL Primitive parameter : CLKOS3_CPHASE         = %0s",
                                CLKOS3_CPHASE) ;
                        $display ("[DEBUG] PLL Primitive parameter : CLKOS4_CPHASE         = %0s",
                                CLKOS4_CPHASE) ;
                        $display ("[DEBUG] PLL Primitive parameter : CLKOS5_CPHASE         = %0s",
                                CLKOS5_CPHASE) ;
                        $display ("[DEBUG] PLL Primitive parameter : CLKOPHY_CPHASE        = %0s",
                                CLKOPHY_CPHASE) ;
                        $display ("[DEBUG] PLL Primitive parameter : CLKRES_CPHASE         = %0s",
                                TEST_CLK7_CPHASE) ;
                        $display ("[DEBUG] PLL Primitive parameter : STATIC_PHASE_SEL      = %0s",
                                STATIC_PHASE_SEL) ;
                        $display ("[DEBUG] PLL Primitive parameter : STATIC_PHASE_LOADREG  = %0s",
                                STATIC_PHASE_LOADREG) ;
                        $display ("[DEBUG] PLL Primitive parameter : STATIC_VCO_PHASE_STEP = %0s",
                                STATIC_VCO_PHASE_STEP) ;
                        $display ("[DEBUG] PLL Primitive parameter : STATIC_VCO_PHASE_DIR  = %0s",
                                STATIC_VCO_PHASE_DIR) ;
                        $display ("[DEBUG] PLL Primitive parameter : FAST_LOCK             = %0s",
                                FAST_LOCK) ;
                        $display ("[DEBUG] PLL Primitive parameter : LOSS_LOCK_DETECTION   = %0s",
                                LOSS_LOCK_DETECTION) ;
                    end
            end
    endgenerate
    tx_pll_ipgen_pll_init_bw #(.SIMULATION(SIMULATION),
            .REG_INTERFACE(REG_INTERFACE),
            .EN_STARTUP_BW(EN_STARTUP_BW),
            .PLL_CLKF(PLL_CLKF[25:0]),
            .PLL_CLKV(PLL_CLKV[25:0]),
            .PLL_BWADJ(PLL_BWADJ[11:0]),
            .PLL_INTFBK(PLL_INTFBK)) u_pll_init_bw (/*AUTOINSTPARAM*/ // Parameters
            // Inputs
            .init_clk_i(init_clk_i), 
                .init_rst_n_i(rst_n_i), 
                .lmmi_ready_o(lmmi_ready_w), 
                .lmmi_rdata_o(lmmi_rdata_w[15:0]), 
                .lmmi_rdata_valid_o(lmmi_rdata_valid_w), 
                .pll_lock(pll_lock), 
                .usr_lmmi_clk_i(usr_lmmi_clk_i), 
                .usr_lmmi_resetn_i(usr_lmmi_resetn_i), 
                .usr_lmmi_offset_i(usr_lmmi_offset_i[4:0]), 
                .usr_lmmi_request_i(usr_lmmi_request_i), 
                .usr_lmmi_wdata_i(usr_lmmi_wdata_i[15:0]), 
                .usr_lmmi_wr_rdn_i(usr_lmmi_wr_rdn_i), 
                // Outputs
            .lmmi_clk_i(lmmi_clk_w), 
                .lmmi_resetn_i(lmmi_resetn_w), 
                .lmmi_offset_i(lmmi_offset_w[4:0]), 
                .lmmi_request_i(lmmi_request_w), 
                .lmmi_wdata_i(lmmi_wdata_w[15:0]), 
                .lmmi_wr_rdn_i(lmmi_wr_rdn_w), 
                .usr_lmmi_ready_o(usr_lmmi_ready_o), 
                .usr_lmmi_rdata_o(usr_lmmi_rdata_o[15:0]), 
                .usr_lmmi_rdata_valid_o(usr_lmmi_rdata_valid_o), 
                .usr_pll_lock(pll_lock_o) /*AUTOINST*/) ; 
    /*PLLC AUTO_TEMPLATE
(
 // Parameters
 .FCLKI                                 (FCLKI),
 .FVCO                                  (FVCO),
 .CLKOP_OUT_SEL                         (CLKOP_OUT_SEL),
 .CLKOS_OUT_SEL                         (CLKOS_OUT_SEL),
 .CLKOS2_OUT_SEL                        (CLKOS2_OUT_SEL),
 .CLKOS3_OUT_SEL                        (CLKOS3_OUT_SEL),
 .CLKOS4_OUT_SEL                        (CLKOS4_OUT_SEL),
 .CLKOS5_OUT_SEL                        (CLKOS5_OUT_SEL),
 .CLKPHY_OUT_SEL                        (CLKPHY_OUT_SEL),
 .SYNC_CLKOP                            (SYNC_CLKOP),
 .PHASE_SOURCE                          (PHASE_SOURCE),
 .STATIC_PHASE_SEL                      (STATIC_PHASE_SEL),
 .STATIC_PHASE_LOADREG                  (STATIC_PHASE_LOADREG),
 .STATIC_VCO_PHASE_STEP                 (STATIC_VCO_PHASE_STEP),
 .STATIC_VCO_PHASE_DIR                  (STATIC_VCO_PHASE_DIR),
 .CLKOP_FPHASE                          (CLKOP_FPHASE),
 .CLKOS_FPHASE                          (CLKOS_FPHASE),
 .CLKOS2_FPHASE                         (CLKOS2_FPHASE),
 .CLKOS3_FPHASE                         (CLKOS3_FPHASE),
 .CLKOS4_FPHASE                         (CLKOS4_FPHASE),
 .CLKOS5_FPHASE                         (CLKOS5_FPHASE),
 .CLKPHY_FPHASE                         (CLKPHY_FPHASE),
 .CLKOP_CPHASE                          (CLKOP_CPHASE),
 .CLKOS_CPHASE                          (CLKOS_CPHASE),
 .CLKOS2_CPHASE                         (CLKOS2_CPHASE),
 .CLKOS3_CPHASE                         (CLKOS3_CPHASE),
 .CLKOS4_CPHASE                         (CLKOS4_CPHASE),
 .CLKOS5_CPHASE                         (CLKOS5_CPHASE),
 .CLKOPHY_CPHASE                        (CLKOPHY_CPHASE),
 .FAST_LOCK                             (FAST_LOCK),
 .LOSS_LOCK_DETECTION                   (LOSS_LOCK_DETECTION),
 .CLKI_DIV                              (CLKI_DIV),
 .CLKI_SEL                              (CLKI_SEL),
 .CLKFB_DIV                             (CLKFB_DIV),
 .FRACTIONAL_FBK                        (FRACTIONAL_FBK),
 .CLKFB_PATH                            (CLKFB_PATH),
 .EXT_FB_DELAY                          (EXT_FB_DELAY),
 .LOOP_BW                               (LOOP_BW),
 .CLKV_SSC_SLOPE                        (CLKV_SSC_SLOPE),
 .CLKS_SSC_RATE                         (CLKS_SSC_RATE),
 .SCC_SS                                (SCC_SS),
 .SCC_FRACTIONAL                        (SCC_FRACTIONAL),
 .CLKOP_DIV                             (CLKOP_DIV),
 .CLKOS_DIV                             (CLKOS_DIV),
 .CLKOS2_DIV                            (CLKOS2_DIV),
 .CLKOS3_DIV                            (CLKOS3_DIV),
 .CLKOS4_DIV                            (CLKOS4_DIV),
 .CLKOS5_DIV                            (CLKOS5_DIV),
 .CLKPHY_DIV                            (CLKPHY_DIV),
 .SATURATION                            (SATURATION),
 .EN_PLL                                (EN_PLL),
 .CONFIG_WAIT_FOR_LOCK                  (CONFIG_WAIT_FOR_LOCK),
 .EN_PLLRESET                           (EN_PLLRESET),
 .EN_CLKOP                              (EN_CLKOP),
 .EN_CLKOS                              (EN_CLKOS),
 .EN_CLKOS2                             (EN_CLKOS2),
 .EN_CLKOS3                             (EN_CLKOS3),
 .EN_CLKOS4                             (EN_CLKOS4),
 .EN_CLKOS5                             (EN_CLKOS5),
 .EN_CLKPHY                             (EN_CLKPHY),
 .EN_CLKOP_OUT                          (EN_CLKOP_OUT),
 .EN_CLKOS_OUT                          (EN_CLKOS_OUT),
 .EN_CLKOS2_OUT                         (EN_CLKOS2_OUT),
 .EN_CLKOS3_OUT                         (EN_CLKOS3_OUT),
 .EN_CLKOS4_OUT                         (EN_CLKOS4_OUT),
 .EN_CLKOS5_OUT                         (EN_CLKOS5_OUT),
 .EN_CLKPHY_OUT                         (EN_CLKPHY_OUT),
 .CLKRES_OUT_SEL                        (TEST_CLK7_OUT_SEL),
 .CLKRES_FPHASE                         (TEST_CLK7_FPHASE),
 .CLKRES_CPHASE                         (TEST_CLK7_CPHASE),
 .CLKRES_DIV                            (INT_CLK7_DIV),
 .EN_CLKRES                             (TEST_EN_CLK7),
 .EN_CLKRES_OUT                         (TEST_EN_CLK7_OUT),
 // Inputs
 .CLKI                                  (refclk_in_i),
 .CLKFB                                 (fbkclk_i),
 .RESET                                 (rst_i),
 .ENCLKPHY                              (clken_clkophy_i),
 .ENCLKOP                               (clken_clkop_i),
 .ENCLKOS                               (clken_clkos_i),
 .ENCLKOS2                              (clken_clkos2_i),
 .ENCLKOS3                              (clken_clkos3_i),
 .ENCLKOS4                              (clken_clkos4_i),
 .ENCLKOS5                              (clken_clkos5_i),
 .ENCLKRES                              (clken_testclk_i),
 .PHASELOADREG                          (phaseloadreg_i),
 .PHASESEL                              (phasesel_i[2:0]),
 .PHASESTEP                             (phasestep_i),
 .PHASEDIR                              (phasedir_i),
 .LMMICLK                               (lmmi_clk_w),
 .LMMIRESET_N                           (lmmi_resetn_w),
 .LMMIREQUEST                           (lmmi_request_w),
 .LMMIWRRDN                             (lmmi_wr_rdn_w),
 .LMMIWDATA                             (lmmi_wdata_w[15:0]),
 .LMMIOFFSET                            (lmmi_offset_w[4:0]),
 // Outputs
 .CLKOPHY                               (clkout_clkophy_o),
 .CLKOP                                 (clkout_clkop_o),
 .CLKOS                                 (clkout_clkos_o),
 .CLKOS2                                (clkout_clkos2_o),
 .CLKOS3                                (clkout_clkos3_o),
 .CLKOS4                                (clkout_clkos4_o),
 .CLKOS5                                (clkout_clkos5_o),
 .CLKRES                                (clkout_testclk_o),
 .CLKOREF                               (refclk_out_o),
 .LOCK                                  (pll_lock),
 .CLKOP_STEPACK                         (stepack_clkop_o),
 .CLKOS_STEPACK                         (stepack_clkos_o),
 .CLKOS2_STEPACK                        (stepack_clkos2_o),
 .CLKOS3_STEPACK                        (stepack_clkos3_o),
 .CLKOS4_STEPACK                        (stepack_clkos4_o),
 .CLKOS5_STEPACK                        (stepack_clkos5_o),
 .CLKPHY_STEPACK                        (stepack_clkophy_o),
 .CLKRES_STEPACK                        (stepack_testclk_o),
 .CLKOP_OUTRESETACK                     (outresetack_clkop_o),
 .CLKOS_OUTRESETACK                     (outresetack_clkos_o),
 .CLKOS2_OUTRESETACK                    (outresetack_clkos2_o),
 .CLKOS3_OUTRESETACK                    (outresetack_clkos3_o),
 .CLKOS4_OUTRESETACK                    (outresetack_clkos4_o),
 .CLKOS5_OUTRESETACK                    (outresetack_clkos5_o),
 .CLKPHY_OUTRESETACK                    (outresetack_clkophy_o),
 .CLKRES_OUTRESETACK                    (outresetack_testclk_o),
 .CLKISLIP                              (slip_refclk_o),
 .CLKFBSLIP                             (slip_fbkclk_o),
 .CLKIDIVCHANGE                         (div_change_refclk_o),
 .CLKFBDIVCHANGE                        (div_change_fbkclk_o),
 .LMMIRDATA                             (lmmi_rdata_w[15:0]),
 .LMMIRDATAVALID                        (lmmi_rdata_valid_w),
 .LMMIREADY                             (lmmi_ready_w),
 );*/
    generate
        if ((!EN_EXT_CLKDIV)) 
            begin : gen_int_outclkdiv
                PLLC #(.FCLKI(FCLKI),
                        .FVCO(FVCO),
                        .CLKOP_OUT_SEL(CLKOP_OUT_SEL),
                        .CLKOS_OUT_SEL(CLKOS_OUT_SEL),
                        .CLKOS2_OUT_SEL(CLKOS2_OUT_SEL),
                        .CLKOS3_OUT_SEL(CLKOS3_OUT_SEL),
                        .CLKOS4_OUT_SEL(CLKOS4_OUT_SEL),
                        .CLKOS5_OUT_SEL(CLKOS5_OUT_SEL),
                        .CLKPHY_OUT_SEL(CLKPHY_OUT_SEL),
                        .SYNC_CLKOP(SYNC_CLKOP),
                        .PHASE_SOURCE(PHASE_SOURCE),
                        .STATIC_PHASE_SEL(STATIC_PHASE_SEL),
                        .STATIC_PHASE_LOADREG(STATIC_PHASE_LOADREG),
                        .STATIC_VCO_PHASE_STEP(STATIC_VCO_PHASE_STEP),
                        .STATIC_VCO_PHASE_DIR(STATIC_VCO_PHASE_DIR),
                        .CLKOP_FPHASE(CLKOP_FPHASE),
                        .CLKOS_FPHASE(CLKOS_FPHASE),
                        .CLKOS2_FPHASE(CLKOS2_FPHASE),
                        .CLKOS3_FPHASE(CLKOS3_FPHASE),
                        .CLKOS4_FPHASE(CLKOS4_FPHASE),
                        .CLKOS5_FPHASE(CLKOS5_FPHASE),
                        .CLKPHY_FPHASE(CLKPHY_FPHASE),
                        .CLKOP_CPHASE(CLKOP_CPHASE),
                        .CLKOS_CPHASE(CLKOS_CPHASE),
                        .CLKOS2_CPHASE(CLKOS2_CPHASE),
                        .CLKOS3_CPHASE(CLKOS3_CPHASE),
                        .CLKOS4_CPHASE(CLKOS4_CPHASE),
                        .CLKOS5_CPHASE(CLKOS5_CPHASE),
                        .CLKOPHY_CPHASE(CLKOPHY_CPHASE),
                        .FAST_LOCK(FAST_LOCK),
                        .LOSS_LOCK_DETECTION(LOSS_LOCK_DETECTION),
                        .CLKI_DIV(CLKI_DIV),
                        .CLKI_SEL(CLKI_SEL),
                        .CLKFB_DIV(CLKFB_DIV),
                        .FRACTIONAL_FBK(FRACTIONAL_FBK),
                        .CLKFB_PATH(CLKFB_PATH),
                        .EXT_FB_DELAY(EXT_FB_DELAY),
                        .LOOP_BW(LOOP_BW),
                        .CLKV_SSC_SLOPE(CLKV_SSC_SLOPE),
                        .CLKS_SSC_RATE(CLKS_SSC_RATE),
                        .SCC_SS(SCC_SS),
                        .SCC_FRACTIONAL(SCC_FRACTIONAL),
                        .CLKOP_DIV(CLKOP_DIV),
                        .CLKOS_DIV(CLKOS_DIV),
                        .CLKOS2_DIV(CLKOS2_DIV),
                        .CLKOS3_DIV(CLKOS3_DIV),
                        .CLKOS4_DIV(CLKOS4_DIV),
                        .CLKOS5_DIV(CLKOS5_DIV),
                        .CLKPHY_DIV(CLKPHY_DIV),
                        .SATURATION(SATURATION),
                        .EN_PLL(EN_PLL),
                        .CONFIG_WAIT_FOR_LOCK(CONFIG_WAIT_FOR_LOCK),
                        .EN_PLLRESET(EN_PLLRESET),
                        .EN_CLKOP(EN_CLKOP),
                        .EN_CLKOS(EN_CLKOS),
                        .EN_CLKOS2(EN_CLKOS2),
                        .EN_CLKOS3(EN_CLKOS3),
                        .EN_CLKOS4(EN_CLKOS4),
                        .EN_CLKOS5(EN_CLKOS5),
                        .EN_CLKPHY(EN_CLKPHY),
                        .EN_CLKOP_OUT(EN_CLKOP_OUT),
                        .EN_CLKOS_OUT(EN_CLKOS_OUT),
                        .EN_CLKOS2_OUT(EN_CLKOS2_OUT),
                        .EN_CLKOS3_OUT(EN_CLKOS3_OUT),
                        .EN_CLKOS4_OUT(EN_CLKOS4_OUT),
                        .EN_CLKOS5_OUT(EN_CLKOS5_OUT),
                        .EN_CLKPHY_OUT(EN_CLKPHY_OUT),
                        .CLKRES_OUT_SEL(TEST_CLK7_OUT_SEL),
                        .CLKRES_FPHASE(TEST_CLK7_FPHASE),
                        .CLKRES_CPHASE(TEST_CLK7_CPHASE),
                        .CLKRES_DIV(INT_CLK7_DIV),
                        .EN_CLKRES(TEST_EN_CLK7),
                        .EN_CLKRES_OUT(TEST_EN_CLK7_OUT)) u_pll (.CLKI(refclk_in_i),  /*AUTOINSTPARAM*//*AUTOINST*/
                            .CLKFB(fbkclk_i), 
                            .RESET(rst_i), 
                            .ENCLKPHY(clken_clkophy_i), 
                            .ENCLKOP(clken_clkop_i), 
                            .ENCLKOS(clken_clkos_i), 
                            .ENCLKOS2(clken_clkos2_i), 
                            .ENCLKOS3(clken_clkos3_i), 
                            .ENCLKOS4(clken_clkos4_i), 
                            .ENCLKOS5(clken_clkos5_i), 
                            .PHASELOADREG(phaseloadreg_i), 
                            .PHASESEL(phasesel_i[2:0]), 
                            .PHASESTEP(phasestep_i), 
                            .PHASEDIR(phasedir_i), 
                            .LMMICLK(lmmi_clk_w), 
                            .LMMIRESET_N(lmmi_resetn_w), 
                            .LMMIREQUEST(lmmi_request_w), 
                            .LMMIWRRDN(lmmi_wr_rdn_w), 
                            .LMMIWDATA(lmmi_wdata_w[15:0]), 
                            .LMMIOFFSET(lmmi_offset_w[4:0]), 
                            .ENCLKRES(clken_testclk_i), 
                            .CLKOPHY(clkout_clkophy_o), 
                            .CLKOP(clkout_clkop_o), 
                            .CLKOS(clkout_clkos_o), 
                            .CLKOS2(clkout_clkos2_o), 
                            .CLKOS3(clkout_clkos3_o), 
                            .CLKOS4(clkout_clkos4_o), 
                            .CLKOS5(clkout_clkos5_o), 
                            .CLKOREF(refclk_out_o), 
                            .LOCK(pll_lock), 
                            .CLKOP_STEPACK(stepack_clkop_o), 
                            .CLKOS_STEPACK(stepack_clkos_o), 
                            .CLKOS2_STEPACK(stepack_clkos2_o), 
                            .CLKOS3_STEPACK(stepack_clkos3_o), 
                            .CLKOS4_STEPACK(stepack_clkos4_o), 
                            .CLKOS5_STEPACK(stepack_clkos5_o), 
                            .CLKPHY_STEPACK(stepack_clkophy_o), 
                            .CLKOP_OUTRESETACK(outresetack_clkop_o), 
                            .CLKOS_OUTRESETACK(outresetack_clkos_o), 
                            .CLKOS2_OUTRESETACK(outresetack_clkos2_o), 
                            .CLKOS3_OUTRESETACK(outresetack_clkos3_o), 
                            .CLKOS4_OUTRESETACK(outresetack_clkos4_o), 
                            .CLKOS5_OUTRESETACK(outresetack_clkos5_o), 
                            .CLKPHY_OUTRESETACK(outresetack_clkophy_o), 
                            .CLKISLIP(slip_refclk_o), 
                            .CLKFBSLIP(slip_fbkclk_o), 
                            .CLKIDIVCHANGE(div_change_refclk_o), 
                            .CLKFBDIVCHANGE(div_change_fbkclk_o), 
                            .LMMIRDATA(lmmi_rdata_w[15:0]), 
                            .LMMIRDATAVALID(lmmi_rdata_valid_w), 
                            .LMMIREADY(lmmi_ready_w), 
                            .CLKRES(clkout_testclk_o), 
                            .CLKRES_STEPACK(stepack_testclk_o), 
                            .CLKRES_OUTRESETACK(outresetack_testclk_o)) ; 
                defparam u_pll.PLLC_MODE_inst.PLL_CORE_inst.INT_CLKOD0_DIV = INT_CLKOD0_DIV ; 
                defparam u_pll.PLLC_MODE_inst.PLL_CORE_inst.INT_CLKOD1_DIV = INT_CLKOD1_DIV ; 
                defparam u_pll.PLLC_MODE_inst.PLL_CORE_inst.INT_CLKOD2_DIV = INT_CLKOD2_DIV ; 
                defparam u_pll.PLLC_MODE_inst.PLL_CORE_inst.INT_CLKOD3_DIV = INT_CLKOD3_DIV ; 
                defparam u_pll.PLLC_MODE_inst.PLL_CORE_inst.INT_CLKOD4_DIV = INT_CLKOD4_DIV ; 
                defparam u_pll.PLLC_MODE_inst.PLL_CORE_inst.INT_CLKOD5_DIV = INT_CLKOD5_DIV ; 
                defparam u_pll.PLLC_MODE_inst.PLL_CORE_inst.INT_CLKOD6_DIV = INT_CLKOD6_DIV ; 
                defparam u_pll.PLLC_MODE_inst.PLL_CORE_inst.INT_CLKOD7_DIV = INT_CLKOD7_DIV ; 
            end
        else
            begin : gen_ext_outclkdiv
                PLLC #(.FCLKI(FCLKI),
                        .FVCO(FVCO),
                        .CLKOP_OUT_SEL(CLKOP_OUT_SEL),
                        .CLKOS_OUT_SEL(CLKOS_OUT_SEL),
                        .CLKOS2_OUT_SEL(CLKOS2_OUT_SEL),
                        .CLKOS3_OUT_SEL(CLKOS3_OUT_SEL),
                        .CLKOS4_OUT_SEL(CLKOS4_OUT_SEL),
                        .CLKOS5_OUT_SEL(CLKOS5_OUT_SEL),
                        .CLKPHY_OUT_SEL(CLKPHY_OUT_SEL),
                        .SYNC_CLKOP(SYNC_CLKOP),
                        .PHASE_SOURCE(PHASE_SOURCE),
                        .STATIC_PHASE_SEL(STATIC_PHASE_SEL),
                        .STATIC_PHASE_LOADREG(STATIC_PHASE_LOADREG),
                        .STATIC_VCO_PHASE_STEP(STATIC_VCO_PHASE_STEP),
                        .STATIC_VCO_PHASE_DIR(STATIC_VCO_PHASE_DIR),
                        .CLKOP_FPHASE(CLKOP_FPHASE),
                        .CLKOS_FPHASE(CLKOS_FPHASE),
                        .CLKOS2_FPHASE(CLKOS2_FPHASE),
                        .CLKOS3_FPHASE(CLKOS3_FPHASE),
                        .CLKOS4_FPHASE(CLKOS4_FPHASE),
                        .CLKOS5_FPHASE(CLKOS5_FPHASE),
                        .CLKPHY_FPHASE(CLKPHY_FPHASE),
                        .CLKOP_CPHASE(CLKOP_CPHASE),
                        .CLKOS_CPHASE(CLKOS_CPHASE),
                        .CLKOS2_CPHASE(CLKOS2_CPHASE),
                        .CLKOS3_CPHASE(CLKOS3_CPHASE),
                        .CLKOS4_CPHASE(CLKOS4_CPHASE),
                        .CLKOS5_CPHASE(CLKOS5_CPHASE),
                        .CLKOPHY_CPHASE(CLKOPHY_CPHASE),
                        .FAST_LOCK(FAST_LOCK),
                        .LOSS_LOCK_DETECTION(LOSS_LOCK_DETECTION),
                        .CLKI_DIV(CLKI_DIV),
                        .CLKI_SEL(CLKI_SEL),
                        .CLKFB_DIV(CLKFB_DIV),
                        .FRACTIONAL_FBK(FRACTIONAL_FBK),
                        .CLKFB_PATH(CLKFB_PATH),
                        .EXT_FB_DELAY(EXT_FB_DELAY),
                        .LOOP_BW(LOOP_BW),
                        .CLKV_SSC_SLOPE(CLKV_SSC_SLOPE),
                        .CLKS_SSC_RATE(CLKS_SSC_RATE),
                        .SCC_SS(SCC_SS),
                        .SCC_FRACTIONAL(SCC_FRACTIONAL),
                        .CLKOP_DIV(CLKOP_DIV),
                        .CLKOS_DIV(CLKOS_DIV),
                        .CLKOS2_DIV(CLKOS2_DIV),
                        .CLKOS3_DIV(CLKOS3_DIV),
                        .CLKOS4_DIV(CLKOS4_DIV),
                        .CLKOS5_DIV(CLKOS5_DIV),
                        .CLKPHY_DIV(CLKPHY_DIV),
                        .SATURATION(SATURATION),
                        .EN_PLL(EN_PLL),
                        .CONFIG_WAIT_FOR_LOCK(CONFIG_WAIT_FOR_LOCK),
                        .EN_PLLRESET(EN_PLLRESET),
                        .EN_CLKOP(EN_CLKOP),
                        .EN_CLKOS(EN_CLKOS),
                        .EN_CLKOS2(EN_CLKOS2),
                        .EN_CLKOS3(EN_CLKOS3),
                        .EN_CLKOS4(EN_CLKOS4),
                        .EN_CLKOS5(EN_CLKOS5),
                        .EN_CLKPHY(EN_CLKPHY),
                        .EN_CLKOP_OUT(EN_CLKOP_OUT),
                        .EN_CLKOS_OUT(EN_CLKOS_OUT),
                        .EN_CLKOS2_OUT(EN_CLKOS2_OUT),
                        .EN_CLKOS3_OUT(EN_CLKOS3_OUT),
                        .EN_CLKOS4_OUT(EN_CLKOS4_OUT),
                        .EN_CLKOS5_OUT(EN_CLKOS5_OUT),
                        .EN_CLKPHY_OUT(EN_CLKPHY_OUT),
                        .CLKRES_OUT_SEL(TEST_CLK7_OUT_SEL),
                        .CLKRES_FPHASE(TEST_CLK7_FPHASE),
                        .CLKRES_CPHASE(TEST_CLK7_CPHASE),
                        .CLKRES_DIV(INT_CLK7_DIV),
                        .EN_CLKRES(TEST_EN_CLK7),
                        .EN_CLKRES_OUT(TEST_EN_CLK7_OUT)) u_pll (.CLKI(refclk_in_i),  /*AUTOINSTPARAM*//*AUTOINST*/
                            .CLKFB(fbkclk_i), 
                            .RESET(rst_i), 
                            .ENCLKPHY(clken_clkophy_i), 
                            .ENCLKOP(clken_clkop_i), 
                            .ENCLKOS(clken_clkos_i), 
                            .ENCLKOS2(clken_clkos2_i), 
                            .ENCLKOS3(clken_clkos3_i), 
                            .ENCLKOS4(clken_clkos4_i), 
                            .ENCLKOS5(clken_clkos5_i), 
                            .PHASELOADREG(phaseloadreg_i), 
                            .PHASESEL(phasesel_i[2:0]), 
                            .PHASESTEP(phasestep_i), 
                            .PHASEDIR(phasedir_i), 
                            .LMMICLK(lmmi_clk_w), 
                            .LMMIRESET_N(lmmi_resetn_w), 
                            .LMMIREQUEST(lmmi_request_w), 
                            .LMMIWRRDN(lmmi_wr_rdn_w), 
                            .LMMIWDATA(lmmi_wdata_w[15:0]), 
                            .LMMIOFFSET(lmmi_offset_w[4:0]), 
                            .ENCLKRES(clken_testclk_i), 
                            .CLKOPHY(clkout_clkophy_o), 
                            .CLKOP(clkout_clkop_o), 
                            .CLKOS(clkout_clkos_o), 
                            .CLKOS2(clkout_clkos2_o), 
                            .CLKOS3(clkout_clkos3_o), 
                            .CLKOS4(clkout_clkos4_o), 
                            .CLKOS5(clkout_clkos5_o), 
                            .CLKOREF(refclk_out_o), 
                            .LOCK(pll_lock), 
                            .CLKOP_STEPACK(stepack_clkop_o), 
                            .CLKOS_STEPACK(stepack_clkos_o), 
                            .CLKOS2_STEPACK(stepack_clkos2_o), 
                            .CLKOS3_STEPACK(stepack_clkos3_o), 
                            .CLKOS4_STEPACK(stepack_clkos4_o), 
                            .CLKOS5_STEPACK(stepack_clkos5_o), 
                            .CLKPHY_STEPACK(stepack_clkophy_o), 
                            .CLKOP_OUTRESETACK(outresetack_clkop_o), 
                            .CLKOS_OUTRESETACK(outresetack_clkos_o), 
                            .CLKOS2_OUTRESETACK(outresetack_clkos2_o), 
                            .CLKOS3_OUTRESETACK(outresetack_clkos3_o), 
                            .CLKOS4_OUTRESETACK(outresetack_clkos4_o), 
                            .CLKOS5_OUTRESETACK(outresetack_clkos5_o), 
                            .CLKPHY_OUTRESETACK(outresetack_clkophy_o), 
                            .CLKISLIP(slip_refclk_o), 
                            .CLKFBSLIP(slip_fbkclk_o), 
                            .CLKIDIVCHANGE(div_change_refclk_o), 
                            .CLKFBDIVCHANGE(div_change_fbkclk_o), 
                            .LMMIRDATA(lmmi_rdata_w[15:0]), 
                            .LMMIRDATAVALID(lmmi_rdata_valid_w), 
                            .LMMIREADY(lmmi_ready_w), 
                            .CLKRES(clkout_testclk_o), 
                            .CLKRES_STEPACK(stepack_testclk_o), 
                            .CLKRES_OUTRESETACK(outresetack_testclk_o)) ; 
            end
    endgenerate

//--lscc_pll--
endmodule



// __RTL_MODULE__LSCC_PLL__
//==========================================================================
// Module : apb2lmmi
//==========================================================================
(* LATTICE_IP_MODULE=1 *) module tx_pll_ipgen_apb2lmmi #(parameter DATA_WIDTH = 32, 
        parameter ADDR_WIDTH = 16, 
        parameter REG_OUTPUT = 1) (
    //--begin_param--
    //----------------------------
    // Parameters
    //----------------------------
    // Data width
    // Address width
    // enable registered output
    //--end_param--
    //--begin_ports--
    //----------------------------
    // Global Signals (Clock and Reset)
    //----------------------------
    input clk_i,  // apb clock
    input rst_n_i,  // active low reset
    //----------------------------
    // APB Interface
    //----------------------------
    input apb_penable_i,  // apb enable
    input apb_psel_i,  // apb slave select
    input apb_pwrite_i,  // apb write 1, read 0
    input [(ADDR_WIDTH - 1):0] apb_paddr_i,  // apb address
    input [(DATA_WIDTH - 1):0] apb_pwdata_i,  // apb write data
    output reg apb_pready_o,  // apb ready
    output reg apb_pslverr_o,  // apb slave error
    output reg [(DATA_WIDTH - 1):0] apb_prdata_o,  // apb read data
    //----------------------------
    // LMMI-Extended Interface
    //----------------------------
    input lmmi_ready_i,  // slave is ready to start new transaction
    input lmmi_rdata_valid_i,  // read transaction is complete
    input lmmi_error_i,  // error indicator
    input [(DATA_WIDTH - 1):0] lmmi_rdata_i,  // read data
    output reg lmmi_request_o,  // start transaction
    output reg lmmi_wr_rdn_o,  // write 1, read 0
    output reg [(ADDR_WIDTH - 1):0] lmmi_offset_o,  // address/offset
    output reg [(DATA_WIDTH - 1):0] lmmi_wdata_o,  // write data
    output wire lmmi_resetn_o // reset to LMMI inteface
        ) ;
    //--end_ports--
    //--------------------------------------------------------------------------
    //--- Local Parameters/Defines ---
    //--------------------------------------------------------------------------
    localparam ST_BUS_IDLE = 2'd0 ; 
    localparam ST_BUS_REQ = 2'd1 ; 
    localparam ST_BUS_DAT = 2'd2 ; 
    localparam ST_BUS_WAIT = 2'd3 ; 
    //--------------------------------------------------------------------------
    //--- Combinational Wire/Reg ---
    //--------------------------------------------------------------------------
    reg timeout_flag_nxt ; 
    reg [7:0] req_timer_nxt ; 
    //--------------------------------------------------------------------------
    //--- Registers ---
    //--------------------------------------------------------------------------
    reg timeout_flag ; 
    reg [7:0] req_timer ; 
    assign lmmi_resetn_o = rst_n_i ; 
    generate
        if (REG_OUTPUT) 
            begin : genblk1
                reg [1:0] bus_sm_ns ; 
                reg [1:0] bus_sm_cs ; 
                reg lmmi_request_nxt ; 
                reg lmmi_wr_rdn_nxt ; 
                reg [(ADDR_WIDTH - 1):0] lmmi_offset_nxt ; 
                reg [(DATA_WIDTH - 1):0] lmmi_wdata_nxt ; 
                reg apb_pready_nxt ; 
                reg apb_pslverr_nxt ; 
                reg [(DATA_WIDTH - 1):0] apb_prdata_nxt ; 
                //--------------------------------------------
                //-- Bus Statemachine --
                //--------------------------------------------
                always
                    @(*)
                    begin
                        bus_sm_ns = bus_sm_cs ;
                        case (bus_sm_cs)
                        ST_BUS_REQ : 
                            begin
                                if (lmmi_ready_i) 
                                    begin
                                        if (lmmi_wr_rdn_o) 
                                            begin
                                                bus_sm_ns = ST_BUS_WAIT ;
                                            end
                                        else
                                            begin
                                                if (lmmi_rdata_valid_i) 
                                                    bus_sm_ns = ST_BUS_WAIT ;
                                                else
                                                    bus_sm_ns = ST_BUS_DAT ;
                                            end
                                    end
                                else
                                    begin
                                        if (timeout_flag) 
                                            begin
                                                bus_sm_ns = ST_BUS_WAIT ;
                                            end
                                        else
                                            begin
                                                bus_sm_ns = ST_BUS_REQ ;
                                            end
                                    end
                            end
                        ST_BUS_DAT : 
                            begin
                                if (lmmi_rdata_valid_i) 
                                    bus_sm_ns = ST_BUS_WAIT ;
                                else
                                    begin
                                        if (timeout_flag) 
                                            bus_sm_ns = ST_BUS_WAIT ;
                                        else
                                            bus_sm_ns = ST_BUS_DAT ;
                                    end
                            end
                        ST_BUS_WAIT : 
                            begin
                                bus_sm_ns = ST_BUS_IDLE ;
                            end
                        default : 
                            begin
                                if (apb_psel_i) 
                                    bus_sm_ns = ST_BUS_REQ ;
                                else
                                    bus_sm_ns = ST_BUS_IDLE ;
                            end
                        endcase 
                    end//--always @*--
                //--------------------------------------------
                //-- APB to LMMI conversion --
                //--------------------------------------------
                always
                    @(*)
                    begin
                        lmmi_request_nxt = lmmi_request_o ;
                        lmmi_wr_rdn_nxt = lmmi_wr_rdn_o ;
                        lmmi_offset_nxt = lmmi_offset_o ;
                        lmmi_wdata_nxt = lmmi_wdata_o ;
                        apb_pready_nxt = apb_pready_o ;
                        apb_pslverr_nxt = 1'b0 ;
                        apb_prdata_nxt = apb_prdata_o ;
                        req_timer_nxt = (req_timer + {7'd0,
                                (~timeout_flag)}) ;
                        timeout_flag_nxt = (&req_timer[7:1]) ;
                        case (bus_sm_cs)
                        ST_BUS_REQ : 
                            begin
                                if (lmmi_ready_i) 
                                    begin
                                        lmmi_request_nxt = 1'b0 ;
                                        lmmi_wr_rdn_nxt = 1'b0 ;
                                        if (lmmi_wr_rdn_o) 
                                            begin
                                                apb_pready_nxt = 1'b1 ;
                                            end
                                        else
                                            begin
                                                if (lmmi_rdata_valid_i) 
                                                    begin
                                                        apb_pready_nxt = 1'b1 ;
                                                        apb_prdata_nxt = lmmi_rdata_i ;
                                                        apb_pslverr_nxt = lmmi_error_i ;
                                                    end
                                            end
                                    end// lmmi_ready_i
                                else
                                    if (timeout_flag) 
                                        begin
                                            lmmi_request_nxt = 1'b0 ;
                                            lmmi_wr_rdn_nxt = 1'b0 ;
                                            if (lmmi_wr_rdn_o) 
                                                begin
                                                    apb_pready_nxt = 1'b1 ;
                                                end
                                            else
                                                begin
                                                    apb_pready_nxt = 1'b1 ;
                                                    apb_prdata_nxt = 32'd0 ;
                                                    apb_pslverr_nxt = 1'b1 ;
                                                end
                                        end// timeout_flag
                            end// ST_BUS_REQ
                        ST_BUS_DAT : 
                            begin
                                if (lmmi_rdata_valid_i) 
                                    begin
                                        apb_pready_nxt = 1'b1 ;
                                        apb_prdata_nxt = lmmi_rdata_i ;
                                        apb_pslverr_nxt = lmmi_error_i ;
                                    end// lmmi_rdata_valid_i
                                else
                                    if (timeout_flag) 
                                        begin
                                            apb_pready_nxt = 1'b1 ;
                                            apb_prdata_nxt = 32'd0 ;
                                            apb_pslverr_nxt = 1'b1 ;
                                        end// timeout_flag
                            end// ST_BUS_DAT
                        ST_BUS_WAIT : 
                            begin
                                apb_pready_nxt = 1'b0 ;
                                req_timer_nxt = 8'd0 ;
                                timeout_flag_nxt = 1'b0 ;
                            end// ST_BUS_WAIT
                        default : 
                            begin
                                apb_pready_nxt = 1'b0 ;
                                req_timer_nxt = 8'd0 ;
                                timeout_flag_nxt = 1'b0 ;
                                if (apb_psel_i) 
                                    begin
                                        lmmi_request_nxt = 1'b1 ;
                                        lmmi_wr_rdn_nxt = apb_pwrite_i ;
                                        lmmi_offset_nxt = apb_paddr_i ;
                                        lmmi_wdata_nxt = apb_pwdata_i ;
                                    end
                                else
                                    begin
                                        lmmi_request_nxt = 1'b0 ;
                                        lmmi_wr_rdn_nxt = 1'b0 ;
                                    end
                            end// ST_BUS_IDLE
                        endcase 
                    end//--always @*--
                //--------------------------------------------
                //-- Sequential block --
                //--------------------------------------------
                always
                    @(posedge clk_i or 
                        negedge rst_n_i)
                    begin
                        if ((~rst_n_i)) 
                            begin
                                bus_sm_cs <=  ST_BUS_IDLE ;
                                /*AUTORESET*/
                                // Beginning of autoreset for uninitialized flops
                                apb_prdata_o <=  {DATA_WIDTH{1'b0}} ;
                                apb_pready_o <=  1'h0 ;
                                apb_pslverr_o <=  1'h0 ;
                                lmmi_offset_o <=  {ADDR_WIDTH{1'b0}} ;
                                lmmi_request_o <=  1'h0 ;
                                lmmi_wdata_o <=  {DATA_WIDTH{1'b0}} ;
                                lmmi_wr_rdn_o <=  1'h0 ;
                                // End of automatics
                            end
                        else
                            begin
                                bus_sm_cs <=  bus_sm_ns ;
                                lmmi_request_o <=  lmmi_request_nxt ;
                                lmmi_wr_rdn_o <=  lmmi_wr_rdn_nxt ;
                                lmmi_offset_o <=  lmmi_offset_nxt ;
                                lmmi_wdata_o <=  lmmi_wdata_nxt ;
                                apb_pready_o <=  apb_pready_nxt ;
                                apb_pslverr_o <=  apb_pslverr_nxt ;
                                apb_prdata_o <=  apb_prdata_nxt ;
                            end
                    end//--always @(posedge clk_i or negedge rst_n_i)--
            end
        else
            begin : genblk1
                // REG_OUTPUT == 0
                reg lmmi_busy_nxt ; 
                reg lmmi_busy ; 
                reg prev_req_granted ; 
                reg [(DATA_WIDTH - 1):0] reg_apb_prdata ; 
                reg reg_lmmi_request ; 
                reg reg_lmmi_wr_rdn ; 
                reg [(ADDR_WIDTH - 1):0] reg_lmmi_offset ; 
                reg [(DATA_WIDTH - 1):0] reg_lmmi_wdata ; 
                //--------------------------------------------
                //-- LMMI request --
                //--------------------------------------------
                always
                    @(*)
                    begin
                        if (lmmi_busy) 
                            begin
                                lmmi_request_o = reg_lmmi_request ;
                                lmmi_wr_rdn_o = reg_lmmi_wr_rdn ;
                                lmmi_offset_o = reg_lmmi_offset ;
                                lmmi_wdata_o = reg_lmmi_wdata ;
                            end
                        else
                            begin
                                lmmi_request_o = apb_psel_i ;
                                lmmi_wr_rdn_o = apb_pwrite_i ;
                                lmmi_offset_o = apb_paddr_i ;
                                lmmi_wdata_o = apb_pwdata_i ;
                            end
                    end//--always @*--
                //--------------------------------------------
                //-- APB outputs --
                //--------------------------------------------
                always
                    @(*)
                    begin
                        if (lmmi_busy) 
                            begin
                                apb_pready_o = (((prev_req_granted | (lmmi_ready_i & lmmi_wr_rdn_o)) | (lmmi_rdata_valid_i & (~lmmi_wr_rdn_o))) | timeout_flag) ;
                                apb_prdata_o = (lmmi_rdata_valid_i ? lmmi_rdata_i : reg_apb_prdata) ;
                                apb_pslverr_o = (lmmi_rdata_valid_i ? lmmi_error_i : timeout_flag) ;
                            end
                        else
                            begin
                                apb_pready_o = 1'b0 ;
                                apb_prdata_o = reg_apb_prdata ;
                                apb_pslverr_o = 1'b0 ;
                            end
                    end//--always @*--
                //--------------------------------------------
                //-- LMMI busy --
                //--------------------------------------------
                always
                    @(*)
                    begin
                        lmmi_busy_nxt = ((lmmi_busy & (~(apb_penable_i & apb_pready_o))) | ((~lmmi_busy) & apb_psel_i)) ;
                    end//--always @*--
                //--------------------------------------------
                //-- Request timer --
                //--------------------------------------------
                always
                    @(*)
                    begin
                        if (lmmi_busy) 
                            begin
                                req_timer_nxt = (req_timer + {7'd0,
                                        (~timeout_flag)}) ;
                                timeout_flag_nxt = (&req_timer[7:1]) ;
                            end
                        else
                            begin
                                req_timer_nxt = 8'd0 ;
                                timeout_flag_nxt = 1'b0 ;
                            end
                    end//--always @*--
                //--------------------------------------------
                //-- Sequential block --
                //--------------------------------------------
                always
                    @(posedge clk_i or 
                        negedge rst_n_i)
                    begin
                        if ((~rst_n_i)) 
                            begin
                                /*AUTORESET*/
                                // Beginning of autoreset for uninitialized flops
                                lmmi_busy <=  1'h0 ;
                                prev_req_granted <=  1'h0 ;
                                reg_apb_prdata <=  {DATA_WIDTH{1'b0}} ;
                                reg_lmmi_offset = {ADDR_WIDTH{1'b0}} ;
                                reg_lmmi_request = 1'h0 ;
                                reg_lmmi_wdata = {DATA_WIDTH{1'b0}} ;
                                reg_lmmi_wr_rdn = 1'h0 ;
                                // End of automatics
                            end
                        else
                            begin
                                prev_req_granted <=  (lmmi_request_o & lmmi_ready_i) ;
                                reg_apb_prdata <=  apb_prdata_o ;
                                lmmi_busy <=  lmmi_busy_nxt ;
                                reg_lmmi_request = (lmmi_request_o & (~lmmi_ready_i)) ;
                                reg_lmmi_wr_rdn = ((lmmi_wr_rdn_o & lmmi_request_o) & (~lmmi_ready_i)) ;
                                reg_lmmi_offset = lmmi_offset_o ;
                                reg_lmmi_wdata = lmmi_wdata_o ;
                            end
                    end//--always @(posedge clk_i or negedge rst_n_i)--
            end
    endgenerate
    //--------------------------------------------
    //-- Sequential block --
    //--------------------------------------------
    always
        @(posedge clk_i or 
            negedge rst_n_i)
        begin
            if ((~rst_n_i)) 
                begin
                    /*AUTORESET*/
                    // Beginning of autoreset for uninitialized flops
                    req_timer <=  8'h0 ;
                    timeout_flag <=  1'h0 ;
                    // End of automatics
                end
            else
                begin
                    req_timer <=  req_timer_nxt ;
                    timeout_flag <=  timeout_flag_nxt ;
                end
        end//--always @(posedge clk_i or negedge rst_n_i)--

//--------------------------------------------------------------------------
//--- Module Instantiation ---
//--------------------------------------------------------------------------
//--apb2lmmi--
endmodule



//==========================================================================
// Module : pll_init_bw
//==========================================================================
(* LATTICE_IP_MODULE=1 *) module tx_pll_ipgen_pll_init_bw #(parameter SIMULATION = 0, 
        parameter EN_STARTUP_BW = 1, 
        parameter [25:0] PLL_CLKF = 26'h8C00, 
        parameter [25:0] PLL_CLKV = 26'd0, 
        parameter [11:0] PLL_BWADJ = 12'd17, 
        parameter PLL_INTFBK = 1, 
        parameter REG_INTERFACE = "None") (
    //--begin_param--
    //----------------------------
    // Parameters
    //----------------------------
    // ['None', 'APB', 'LMMI']
    //--end_param--
    //--begin_ports--
    input init_clk_i, 
    input init_rst_n_i // PLL primitive
        , 
    output wire lmmi_clk_i, 
    output wire lmmi_resetn_i, 
    output wire [4:0] lmmi_offset_i, 
    output wire lmmi_request_i, 
    output wire [15:0] lmmi_wdata_i, 
    output wire lmmi_wr_rdn_i, 
    input lmmi_ready_o, 
    input [15:0] lmmi_rdata_o, 
    input lmmi_rdata_valid_o, 
    input pll_lock // user interface
        , 
    input usr_lmmi_clk_i, 
    input usr_lmmi_resetn_i, 
    input [4:0] usr_lmmi_offset_i, 
    input usr_lmmi_request_i, 
    input [15:0] usr_lmmi_wdata_i, 
    input usr_lmmi_wr_rdn_i, 
    output wire usr_lmmi_ready_o, 
    output wire [15:0] usr_lmmi_rdata_o, 
    output wire usr_lmmi_rdata_valid_o, 
    output wire usr_pll_lock) ;
    //--end_ports--
    //--------------------------------------------------------------------------
    //--- Local Parameters/Defines ---
    //--------------------------------------------------------------------------
    //--------------------------------------------------------------------------
    //--- Combinational Wire/Reg ---
    //--------------------------------------------------------------------------
    //--------------------------------------------------------------------------
    //--- Registers ---
    //--------------------------------------------------------------------------
    generate
        if (EN_STARTUP_BW) 
            begin : gen_bw_init
                localparam [4:0] NF_REG_ADDR = 5'd3 ; 
                localparam [4:0] BW_REG_ADDR = 5'd4 ; 
                localparam [15:0] NF_REG_ACTUAL = PLL_CLKF[25:10] ; 
                localparam [15:0] BW_REG_ACTUAL = {PLL_CLKV[3:0],
                            PLL_BWADJ[11:0]} ; 
                localparam // auto enum state_1
                    ST_RESET = 3'd0, 
                    ST_BW_INIT = 3'd1, 
                    ST_WAIT_LOCK = 3'd2, 
                    ST_BW_ACTUAL = 3'd3, 
                    ST_NORMAL_OP = 3'd4 ; 
                wire clk ; 
                wire rst_n ; 
                wire [4:0] init_offset ; 
                wire init_wr_rdn ; 
                wire [15:0] init_wdata ; 
                wire [15:0] bw_add1 ; 
                wire [11:0] bw_init_value ; 
                wire reg_rst_n ; 
                reg [2:0] // auto enum state_1
                    bw_init_cs ; 
                reg [1:0] dly_wait_cntr ; 
                reg en_usr_lmmi ; 
                reg [15:0] nf_usr_regval ; 
                reg [15:0] bw_usr_regval ; 
                reg init_request ; 
                reg [1:0] rst_n_sync ; 
                reg [1:0] pll_lock_reg ; 
                reg [11:0] wdata ; 
                assign usr_lmmi_ready_o = (en_usr_lmmi & lmmi_ready_o) ; 
                assign usr_lmmi_rdata_valid_o = (en_usr_lmmi & lmmi_rdata_valid_o) ; 
                assign usr_lmmi_rdata_o = lmmi_rdata_o ; 
                assign usr_pll_lock = ((bw_init_cs == ST_NORMAL_OP) ? pll_lock : 1'b0) ; 
                assign clk = init_clk_i ; 
                assign rst_n = rst_n_sync[1] ; 
                // Note: relax timing from bw_usr_regval/nf_usr_regval, this is multicycle path
                assign bw_add1 = ({4'd0,
                            bw_usr_regval} + 16'd1) ; // add 1 for actual numerical value
                // initial BW ratio=1, i.e. NB=NF, need to subtract 1 since BWADJ is 0 base
                // for external feedback, it is possible that NB>NF after multiplying x4 due to rounding up of actual NB value
                assign bw_init_value = (PLL_INTFBK ? (nf_usr_regval[15:4] - 12'd1) : ({bw_add1[13:0],
                            2'd0} - 16'd1)) ; // multiply by 4, subtract 1 from final numerical value
                assign init_offset = BW_REG_ADDR ; 
                assign init_wr_rdn = init_request ; 
                assign init_wdata = {bw_usr_regval[15:12],
                            wdata} ; 
                //--------------------------------------------
                //-- Reset synchronizer --
                //--------------------------------------------
                always
                    @(posedge init_clk_i or 
                        negedge init_rst_n_i)
                    begin
                        if ((~init_rst_n_i)) 
                            begin
                                /*AUTORESET*/
                                // Beginning of autoreset for uninitialized flops
                                rst_n_sync <=  2'h0 ;
                                // End of automatics
                            end
                        else
                            begin
                                rst_n_sync <=  {rst_n_sync[0],
                                        1'b1} ;
                            end
                    end//--always @(posedge init_clk_i or negedge init_rst_n_i)--
                assign reg_rst_n = (((REG_INTERFACE == "APB") || (REG_INTERFACE == "LMMI")) ? usr_lmmi_resetn_i : rst_n) ; 
                //----------------------------------------------
                //-- Capture user write to BW and NF register --
                // if User resets the LMMI interface and the BW, NF parameters have changed before that
                // then User needs to reprogram these values.
                // Otherwise the default parameter values (BW_REG_ACTUAL, NF_REG_ACTUAL) will be taken
                // which may cause the PLL to not work correctly
                //----------------------------------------------
                always
                    @(posedge usr_lmmi_clk_i or 
                        negedge reg_rst_n)
                    begin
                        if ((~reg_rst_n)) 
                            begin
                                bw_usr_regval <=  BW_REG_ACTUAL ;
                                nf_usr_regval <=  NF_REG_ACTUAL ;
                                /*AUTORESET*/
                            end
                        else
                            begin
                                if (((usr_lmmi_request_i & usr_lmmi_ready_o) & usr_lmmi_wr_rdn_i)) 
                                    begin
                                        if ((usr_lmmi_offset_i == BW_REG_ADDR)) 
                                            begin
                                                bw_usr_regval <=  usr_lmmi_wdata_i ;
                                            end
                                        // If using internal feedback, we can directly take NF value as the max NB value
                                        if (((PLL_INTFBK == 1) && (usr_lmmi_offset_i == NF_REG_ADDR))) 
                                            begin
                                                nf_usr_regval <=  usr_lmmi_wdata_i ;
                                            end
                                    end
                            end
                    end//--always @(posedge usr_lmmi_clk_i or negedge reg_rst_n)--
                //--------------------------------------------
                //-- BW StartUp SM --
                //--------------------------------------------
                always
                    @(posedge clk or 
                        negedge rst_n)
                    begin
                        if ((~rst_n)) 
                            begin
                                bw_init_cs <=  ST_RESET ;
                                en_usr_lmmi <=  1'b1 ;
                                dly_wait_cntr <=  2'd0 ;
                                /*AUTORESET*/
                                // Beginning of autoreset for uninitialized flops
                                init_request <=  1'h0 ;
                                pll_lock_reg <=  2'h0 ;
                                wdata <=  12'h0 ;
                                // End of automatics
                            end
                        else
                            begin
                                pll_lock_reg <=  {pll_lock_reg[0],
                                        pll_lock} ;
                                wdata <=  (pll_lock_reg[0] ? bw_usr_regval[11:0] : bw_init_value[11:0]) ;
                                case (bw_init_cs)
                                ST_BW_INIT : 
                                    begin
                                        bw_init_cs <=  ST_BW_INIT ;
                                        dly_wait_cntr <=  (dly_wait_cntr + {1'b0,
                                                (init_request & lmmi_ready_o)}) ;
                                        init_request <=  1'b1 ;
                                        if ((dly_wait_cntr == {2{1'b1}})) 
                                            begin
                                                bw_init_cs <=  ST_WAIT_LOCK ;
                                                init_request <=  1'b0 ;
                                            end
                                    end// ST_BW_INIT
                                ST_WAIT_LOCK : 
                                    begin
                                        bw_init_cs <=  ST_WAIT_LOCK ;
                                        dly_wait_cntr <=  2'd0 ;
                                        if (pll_lock_reg[1]) 
                                            begin
                                                bw_init_cs <=  ST_BW_ACTUAL ;
                                            end
                                    end// ST_WAIT_LOCK
                                ST_BW_ACTUAL : 
                                    begin
                                        bw_init_cs <=  ST_BW_ACTUAL ;
                                        dly_wait_cntr <=  (dly_wait_cntr + {1'b0,
                                                (init_request & lmmi_ready_o)}) ;
                                        init_request <=  1'b1 ;
                                        if ((dly_wait_cntr == {2{1'b1}})) 
                                            begin
                                                bw_init_cs <=  ST_NORMAL_OP ;
                                                init_request <=  1'b0 ;
                                            end
                                    end// ST_BW_ACTUAL
                                ST_NORMAL_OP : 
                                    begin
                                        bw_init_cs <=  ST_NORMAL_OP ;
                                        en_usr_lmmi <=  1'b1 ;
                                    end// ST_NORMAL_OP
                                default : 
                                    begin
                                        // ST_RESET
                                        bw_init_cs <=  ST_RESET ;
                                        en_usr_lmmi <=  1'b0 ;
                                        dly_wait_cntr <=  2'd0 ;
                                        if ((~en_usr_lmmi)) 
                                            begin
                                                bw_init_cs <=  ST_BW_INIT ;
                                            end
                                    end// ST_RESET
                                endcase 
                            end
                    end//--always @(posedge clk or negedge rst_n)--
                tx_pll_ipgen_pll_sip_lmmi_mux u_pll_lmmi_mux (// Inputs
                        .LMMI_SELECT(en_usr_lmmi), 
                            .LMMI_0_CLK(init_clk_i), 
                            .LMMI_0_RESETN(1'b1), 
                            .LMMI_0_OFFSET(init_offset[4:0]), 
                            .LMMI_0_REQUEST(init_request), 
                            .LMMI_0_WDATA(init_wdata[15:0]), 
                            .LMMI_0_WR_RDN(init_wr_rdn), 
                            .LMMI_1_CLK(usr_lmmi_clk_i), 
                            .LMMI_1_RESETN(usr_lmmi_resetn_i), 
                            .LMMI_1_OFFSET(usr_lmmi_offset_i[4:0]), 
                            .LMMI_1_REQUEST(usr_lmmi_request_i), 
                            .LMMI_1_WDATA(usr_lmmi_wdata_i[15:0]), 
                            .LMMI_1_WR_RDN(usr_lmmi_wr_rdn_i), 
                            .LMMI_READY(lmmi_ready_o), 
                            .LMMI_RVALID(lmmi_rdata_valid_o), 
                            .LMMI_RDATA(lmmi_rdata_o[15:0]), 
                            // Outputs
                        .LMMI_CLK(lmmi_clk_i), 
                            .LMMI_RESETN(lmmi_resetn_i), 
                            .LMMI_OFFSET(lmmi_offset_i[4:0]), 
                            .LMMI_REQUEST(lmmi_request_i), 
                            .LMMI_WDATA(lmmi_wdata_i[15:0]), 
                            .LMMI_WR_RDN(lmmi_wr_rdn_i) /*AUTOINST*/) ; 
                if (SIMULATION) 
                    begin : gen_sim
                        initial
                            begin
                                rst_n_sync = 2'd0 ;
                                bw_usr_regval = BW_REG_ACTUAL ;
                                nf_usr_regval = NF_REG_ACTUAL ;
                            end
                        // -----------------------------------
                        // For Simulation use only
                        // State in ASCII for readability
                        // -----------------------------------
                        /*AUTOASCIIENUM("bw_init_cs", "_bw_init_cs_", "ST_")*/
                        // Beginning of automatic ASCII enum decoding
                        reg [71:0] _bw_init_cs_ ; // Decode of bw_init_cs
                        always
                            @(bw_init_cs)
                            begin
                                case ({bw_init_cs})
                                ST_RESET : 
                                    _bw_init_cs_ = "reset    " ;
                                ST_BW_INIT : 
                                    _bw_init_cs_ = "bw_init  " ;
                                ST_WAIT_LOCK : 
                                    _bw_init_cs_ = "wait_lock" ;
                                ST_BW_ACTUAL : 
                                    _bw_init_cs_ = "bw_actual" ;
                                ST_NORMAL_OP : 
                                    _bw_init_cs_ = "normal_op" ;
                                default : 
                                    _bw_init_cs_ = "%Error   " ;
                                endcase 
                            end
                    end
            end
        else
            begin : gen_no_bw_init
                assign lmmi_clk_i = usr_lmmi_clk_i ; 
                assign lmmi_resetn_i = usr_lmmi_resetn_i ; 
                assign lmmi_offset_i = usr_lmmi_offset_i ; 
                assign lmmi_request_i = usr_lmmi_request_i ; 
                assign lmmi_wdata_i = usr_lmmi_wdata_i ; 
                assign lmmi_wr_rdn_i = usr_lmmi_wr_rdn_i ; 
                assign usr_lmmi_ready_o = lmmi_ready_o ; 
                assign usr_lmmi_rdata_valid_o = lmmi_rdata_valid_o ; 
                assign usr_lmmi_rdata_o = lmmi_rdata_o ; 
                assign usr_pll_lock = pll_lock ; 
            end
    endgenerate

//--------------------------------------------------------------------------
//--- Module Instantiation ---
//--------------------------------------------------------------------------
//--pll_init_bw--
endmodule



// __RTL_MODULE__PLL_INIT_BW__
//==========================================================================
// Module : pll_sip_lmmi_mux
//==========================================================================
(* LATTICE_IP_MODULE=1 *) module tx_pll_ipgen_pll_sip_lmmi_mux (
    //--begin_ports--
    input LMMI_SELECT, 
    input LMMI_0_CLK, 
    input LMMI_0_RESETN, 
    input [4:0] LMMI_0_OFFSET, 
    input LMMI_0_REQUEST, 
    input [15:0] LMMI_0_WDATA, 
    input LMMI_0_WR_RDN, 
    input LMMI_1_CLK, 
    input LMMI_1_RESETN, 
    input [4:0] LMMI_1_OFFSET, 
    input LMMI_1_REQUEST, 
    input [15:0] LMMI_1_WDATA, 
    input LMMI_1_WR_RDN, 
    output wire LMMI_CLK, 
    output wire LMMI_RESETN, 
    output wire [4:0] LMMI_OFFSET, 
    output wire LMMI_REQUEST, 
    output wire [15:0] LMMI_WDATA, 
    output wire LMMI_WR_RDN, 
    input LMMI_READY, 
    input LMMI_RVALID, 
    input [15:0] LMMI_RDATA) ;
    //--end_ports--
    wire fip_select ; 
    assign fip_select = (~LMMI_SELECT) ; 
    PLL_LMMI_MUX u_sw_lmmi_mux (// Inputs
            .FIP_SELECT(fip_select), 
                .LMMICLK_FIP(LMMI_0_CLK),  // soft ip
            .LMMIRESET_FIP_N(LMMI_0_RESETN),  // soft ip
            .LMMIREQUEST_FIP(LMMI_0_REQUEST),  // soft ip
            .LMMIWRRDN_FIP(LMMI_0_WR_RDN),  // soft ip
            .LMMIWDATA_FIP(LMMI_0_WDATA[15:0]),  // soft ip
            .LMMIOFFSET_FIP(LMMI_0_OFFSET[4:0]),  // soft ip
            .LMMICLK(LMMI_1_CLK),  // reveal
            .LMMIRESET_N(LMMI_1_RESETN),  // reveal
            .LMMIREQUEST(LMMI_1_REQUEST),  // reveal
            .LMMIWRRDN(LMMI_1_WR_RDN),  // reveal
            .LMMIWDATA(LMMI_1_WDATA[15:0]),  // reveal
            .LMMIOFFSET(LMMI_1_OFFSET[4:0]),  // reveal
            .LMMIREADY_IN(LMMI_READY),  // PLL primitive
            .LMMIRDATAVALID_IN(LMMI_RVALID),  // PLL primitive
            .LMMIRDATA_IN(LMMI_RDATA[15:0]),  // PLL primitive
            // Outputs
            .LMMICLK_OUT(LMMI_CLK),  // PLL primitive
            .LMMIRESET_OUT_N(LMMI_RESETN),  // PLL primitive
            .LMMIREQUEST_OUT(LMMI_REQUEST),  // PLL primitive
            .LMMIWRRDN_OUT(LMMI_WR_RDN),  // PLL primitive
            .LMMIWDATA_OUT(LMMI_WDATA[15:0]),  // PLL primitive
            .LMMIOFFSET_OUT(LMMI_OFFSET[4:0]),  // PLL primitive
            .LMMIREADY(),  // reveal
            .LMMIRDATAVALID(),  // reveal
            .LMMIRDATA() // reveal
            ) ; 

//--pll_sip_lmmi_mux--
endmodule


//   ===============================================================================================
//   >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
// -------------------------------------------------------------------------------------------------
//   Copyright (c) 2021 by Lattice Semiconductor Corporation
// -------------------------------------------------------------------------------------------------
//
// Permission:
//
//   Lattice Semiconductor grants permission to use this code for use in synthesis for any Lattice 
//   programmable logic product.  Other use of this code, including the selling or duplication of 
//   any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL or Verilog source code is intended as a design reference which illustrates how these
//   types of functions can be implemented.  It is the user's responsibility to verify their design
//   for consistency and functionality through the use of formal verification methods.  Lattice 
//   Semiconductor provides no warranty regarding the use or functionality of this code.
//
// -------------------------------------------------------------------------------------------------
//
//                               Lattice Semiconductor Corporation
//                               5555 NE Moore Court
//                               Hillsboro, OR 97214
//                               U.S.A
//                            
//                               TEL: 1-800-Lattice (USA and Canada)
//                                    408-826-6000 (other locations)
//                            
//                               web: http://www.latticesemi.com/
//                               email: techsupport@latticesemi.com
//
// -------------------------------------------------------------------------------------------------
//==========================================================================
// Module : packet_gen_check
//
//	Ethernet simple packet generator + checker
//
//==========================================================================
//
// File            : packet_gen_check.v
// Date            : 02/22/2022
// Version         : 1.0
// Abstract        : Lattice simple ethernet packet generator/checker
//					 Note: compareFail will fail if packet length < 64, due to miscompare on padded bytes
//					  	
//
// Modification History:
// Date          By       Version    Change Description
//
// ===========================================================
// 02/22/2022    ctc      1.0        Original
// 
// ===========================================================
module traffic_genchk (
	txclk, rxclk, rstn, 
	inReady, outData, outValid, outKeep, outUser, outLast,
	outReady, inData, inValid, inKeep, inUser, inLast,
	done, compareFail, inStart_patgen
	);

	parameter CONTINUOUS_TRAFFIC	= 0;				// From top level: Generate packets continously
	parameter NUM_PKT 				= 10_000; 			// From top level: Number of packets to generate when CONTINUOUS_TRAFFIC = 0
	parameter MAX_DATA_WIDTH 		= 8;				//z9

	parameter RANDOMIZE	 			= 1; 				// 1 - Generate some junk data for user data bytes. 0 - user data bytes counting up
	//parameter USR_DATA_BYTE 		= 16'h055C;		// Number of user data bytes //z9 working:h009C 02BC=700=28*21*32 055C=1372=28+42*32//z9 default:055C        !!!! h001C is too short
	
	parameter SRC_MAC_ADDR 			= 48'hFACE_FACE_FACE;
	parameter DEST_MAC_ADDR 		= 48'hDEAD_DEAD_DEAD;
	parameter MASK_DATA				= 128'hEF55_3A4C_5ECA_31A5_7B29_C6A2_E512_9966; //z9 64'hEF45_4255_3A4C_5ECA
	
	parameter FRAME_LEN_MAX			= 16'd1455; //z9
	//parameter FRAME_LEN_MAX			= 16'd1259; //z9
	//parameter FRAME_LEN_INIT		= 16'd0; //z9 start from 3 since both B0,B1 in payload are used for pkt cnt
	parameter FRAME_LEN_INIT		= 16'd1255;
	
	input 			txclk;
	input 			rxclk;
	input 			rstn;
	input 			inReady;
	output  [MAX_DATA_WIDTH-1:0] 		outData; //z9
	output								outKeep; //z9
	output 	reg		outValid;
	output 			outUser;
	output 			outLast;
	
	output 			outReady;
	input 	[MAX_DATA_WIDTH-1:0] 		inData; //z9
	input								inKeep; //z9
	input			inValid;
	input			inUser;
	input			inLast;
	
	output reg		compareFail;
	output reg		done;

	input			inStart_patgen;
	
	reg				sim_active;
	reg		[7:0]	sim_count;
	reg		[15:0]	pkt_cnt;
	reg		[15:0]	quad_octets_cnt;
	reg 	[128-1:0] 	genData; //z9
	reg		[15:0]	frame_byte_length;
	reg             init;
	reg             shift;
	reg				last_bit;
	reg				outLast_reg;
	
	reg 	[MAX_DATA_WIDTH-1:0] 	Data;
    
	reg [15:0] rcvd_octet_cnt;
	reg [128-1:0] rcvd_data_field;
	reg        comparePass;
	reg        rcvd_shift;
	reg        rcvd_last_bit;
	reg [15:0] rcvd_pkt_cnt;
	reg        inValid_reg; 
    reg [15:0] FRAME_LEN_cnt;
    reg [15:0] rcvd_FRAME_LEN_cnt;
	reg 	   sim_count_rst;
	reg			outLast_off;
	
	always @ (posedge txclk or negedge rstn) begin
		if (~rstn) begin
	        sim_count <= 1'b0;
		end else if (sim_count_rst) begin
			sim_count <= 1'b0;
		//end else begin //causing hi-z
		end else if (inStart_patgen) begin
	        sim_count <= sim_count + 1'b1;
		end
	end

	always @ (posedge txclk or negedge rstn) begin
        if (~rstn) begin
	        sim_active <= 1'b0;
			done <= 1'b0;
		end
		else if (rcvd_pkt_cnt == 16'h0 && CONTINUOUS_TRAFFIC==0) begin //z9
			done <= 1'b1; //z9
		end
		else if (pkt_cnt == 16'h0 && CONTINUOUS_TRAFFIC==0) begin //z9
	        sim_active <= 1'b0; //z9
			//sim_count <= 0; //z9
		end
		else if(sim_count_rst) begin
			sim_active <= 1'b0;
		end
		else if (sim_count >= 8'd5 & inStart_patgen & ~done) begin		// delay start of generator //z9 default:8'd20
	        sim_active <= 1'b1;
		end

	end
	
	// --------------- pattern generator ---------------
	
	always @ (posedge txclk or negedge rstn) begin
		if (~rstn) begin
			quad_octets_cnt <= 16'h0;
			init <= 1'b0;
			outValid   <= 1'b0;
			outLast_reg   <= 1'b0;
			pkt_cnt <= NUM_PKT ;
			FRAME_LEN_cnt <= FRAME_LEN_INIT; //z9 14=8+8+2
			frame_byte_length <= FRAME_LEN_INIT+14;  //z9 default:4
			//frame_byte_length <= FRAME_LEN-8;  //z9 default:4
			sim_count_rst <= 0;
			outLast_off <= 0;
		end
		else if (outLast_off) begin
			outLast_off <=0;
		end
		else if (outLast & FRAME_LEN_cnt <= 2) begin //!!!!!!!!!!!!!!!!!!!!!!!!!!
			outValid   <= 1'b0;
			outLast_reg   <= 1'b0;
			FRAME_LEN_cnt		<= FRAME_LEN_cnt + 1;
			//if(FRAME_LEN_cnt == 2)begin
			//frame_byte_length <= FRAME_LEN_cnt+14;
			//end else begin
			frame_byte_length <= FRAME_LEN_cnt+15;
			//end
			sim_count_rst		<= 1; //z9 cooldown //using:1
			init				<= 1'b0;
			outLast_off <= 1;
		end
		else if (sim_active & inReady & init ) begin
			quad_octets_cnt <= 16'h0;
			frame_byte_length <= FRAME_LEN_cnt+14; //z9 6+6+2 ? default:4
			//frame_byte_length <= FRAME_LEN_cnt -8; //z9 default:4
			outValid   <= 1'b0;
			outLast_reg    <= 1'b0;
			init 	   <= 1'b0;
			pkt_cnt <= pkt_cnt - 1'b1;
		end
		else if (sim_active & inReady & frame_byte_length <= 2 ) begin //z9 default:16
			quad_octets_cnt <= quad_octets_cnt + 1'b1;
			outValid   <= 1'b1;
			outLast_reg    <= 1'b1;
				//FRAME_LEN_cnt <= FRAME_LEN_cnt + 1;
				if(FRAME_LEN_cnt == FRAME_LEN_MAX) begin
				FRAME_LEN_cnt <= FRAME_LEN_INIT;
				end else begin
				FRAME_LEN_cnt <= FRAME_LEN_cnt + 1;
				end
			frame_byte_length <= frame_byte_length - 16'd1; //z9 default:16'd8
			init 	   <= 1'b1;
		end
		else if (sim_active & inReady & outValid) begin
			quad_octets_cnt <= quad_octets_cnt + 1'b1;
			outValid   <= 1'b1;
			outLast_reg    <= 1'b0;
			frame_byte_length <= frame_byte_length - 16'd1; //z9 default:16'd8
		end
		else if (sim_active) begin
			if(pkt_cnt == 16'h0) begin //z9
				outValid   <= 1'b0;  //z9
			end else begin  //z9
				outValid   <= 1'b1;  //z9
			end
		end
		else begin
			outValid   <= 1'b0;
			sim_count_rst <= 0;
		end
	end
	
	always @ (posedge txclk or negedge rstn) begin
        if (~rstn) begin
			genData <= 128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF; //z9
			shift <= 1'b0;
			last_bit <= 1'b0;
		end 
		else if (RANDOMIZE & inReady & outValid & shift) begin
			last_bit <= genData[MAX_DATA_WIDTH-1];  //z9
			genData <= genData << 1;
			genData[0] <= last_bit;
			shift <= 0;
        end
		else if (RANDOMIZE & inReady & outValid ) begin
			genData <= genData ^ MASK_DATA;
			shift <= 1;
        end
		else if ( inReady & outValid) begin
			genData <= genData + 1'b1;
		end
		else begin
			genData <= genData;
		end
	end

	always @ (*) begin
	  case ( quad_octets_cnt )
		16'h0000: Data = DEST_MAC_ADDR[47:40]; //z9
		16'h0001: Data = DEST_MAC_ADDR[39:32]; //z9
		16'h0002: Data = DEST_MAC_ADDR[31:24]; //z9
		16'h0003: Data = DEST_MAC_ADDR[23:16]; //z9
		16'h0004: Data = DEST_MAC_ADDR[15:8]; //z9
		16'h0005: Data = DEST_MAC_ADDR[7:0]; //z9
	    
	    16'h0006: Data = SRC_MAC_ADDR[47:40]; //z9
		16'h0007: Data = SRC_MAC_ADDR[39:32]; //z9
		16'h0008: Data = SRC_MAC_ADDR[31:24]; //z9
		16'h0009: Data = SRC_MAC_ADDR[23:16]; //z9
		16'h000a: Data = SRC_MAC_ADDR[15:8]; //z9
		16'h000b: Data = SRC_MAC_ADDR[7:0]; //z9

	    16'h000c: Data = FRAME_LEN_cnt[15:8]; //z9
	    16'h000d: Data = FRAME_LEN_cnt[7:0]; //z9
		default : Data = (genData[7:0]^genData[15:8]^genData[23:16]^genData[31:24]^genData[39:32]^genData[47:40]^genData[55:48]^genData[63:56]^genData[71:64]^genData[79:72]^genData[87:80]^genData[95:88]^genData[103:96]^genData[111:104]^genData[119:112]^genData[127:120]);
      endcase		
	end
	
	assign outData = Data;
	assign outLast = (outLast_reg | FRAME_LEN_cnt <= 2) & (inReady) & (~outLast_off); //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	assign outKeep = outValid; //1'b1
	assign outUser = 1'b0;
	assign outReady = 1'b1;

	// --------------- pattern checker ---------------
	
	always @(posedge rxclk or negedge rstn) begin
		if (~rstn) begin
			rcvd_octet_cnt  <= 16'd0;
			compareFail     <= 1'b0;
			rcvd_pkt_cnt    <= NUM_PKT;
			inValid_reg     <= 1'b0;
			rcvd_FRAME_LEN_cnt <= FRAME_LEN_INIT;
		end
		else begin
			rcvd_octet_cnt  <= (inLast)? 16'd0 : (inValid)? rcvd_octet_cnt + 1'b1 : rcvd_octet_cnt;
			compareFail     <= (compareFail)? 1'b1 : (~inValid_reg)? 1'b0 : ~comparePass; //z9999 checking
			rcvd_pkt_cnt    <= (inLast&inValid)? rcvd_pkt_cnt - 1'b1 : rcvd_pkt_cnt;
			inValid_reg     <= inValid;
			//z9 rcvd_FRAME_LEN_cnt <= inLast? rcvd_FRAME_LEN_cnt + 1'b1 : rcvd_FRAME_LEN_cnt;
			rcvd_FRAME_LEN_cnt <= (inLast&inValid)? ((rcvd_FRAME_LEN_cnt==FRAME_LEN_MAX)? FRAME_LEN_INIT:(rcvd_FRAME_LEN_cnt + 1'b1)) : rcvd_FRAME_LEN_cnt;
		end
	end

	
	always @ (posedge rxclk or negedge rstn) begin
        if (~rstn) begin
			rcvd_data_field <= 128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF; //z9
			rcvd_shift <= 1'b0;
			rcvd_last_bit <= 1'b0;
		end 
		else if (RANDOMIZE & inValid & rcvd_shift) begin
			rcvd_last_bit <= rcvd_data_field[MAX_DATA_WIDTH-1];
			rcvd_data_field <= rcvd_data_field << 1;
			rcvd_data_field[0] <= rcvd_last_bit;
			rcvd_shift <= 0;
        end
		else if (RANDOMIZE & inValid ) begin
			rcvd_data_field <= rcvd_data_field ^ MASK_DATA;
			rcvd_shift <= 1;
        end
		else if ( inValid ) begin
			rcvd_data_field <= rcvd_data_field + 1'b1;
		end
		else begin
			rcvd_data_field <= rcvd_data_field;
		end
	end

	always @ (posedge rxclk or negedge rstn) begin
        if (~rstn) begin
			comparePass <= 1'b1;
		end
		else begin
			case (rcvd_octet_cnt) //z9
				16'h0000: comparePass <= ~|((inData) ^ (DEST_MAC_ADDR[47:40]));
				16'h0001: comparePass <= ~|((inData) ^ (DEST_MAC_ADDR[39:32]));
				16'h0002: comparePass <= ~|((inData) ^ (DEST_MAC_ADDR[31:24]));
				16'h0003: comparePass <= ~|((inData) ^ (DEST_MAC_ADDR[23:16]));
				16'h0004: comparePass <= ~|((inData) ^ (DEST_MAC_ADDR[15:8]));
				16'h0005: comparePass <= ~|((inData) ^ (DEST_MAC_ADDR[7:0]));

				16'h0006: comparePass <= ~|((inData) ^ (SRC_MAC_ADDR[47:40]));
				16'h0007: comparePass <= ~|((inData) ^ (SRC_MAC_ADDR[39:32]));
				16'h0008: comparePass <= ~|((inData) ^ (SRC_MAC_ADDR[31:24]));
				16'h0009: comparePass <= ~|((inData) ^ (SRC_MAC_ADDR[23:16]));
				16'h000a: comparePass <= ~|((inData) ^ (SRC_MAC_ADDR[15:8]));
				16'h000b: comparePass <= ~|((inData) ^ (SRC_MAC_ADDR[7:0]));
				
				16'h000c: comparePass <= ~|((inData) ^ (rcvd_FRAME_LEN_cnt[15:8]));
				16'h000d: comparePass <= ~|((inData) ^ (rcvd_FRAME_LEN_cnt[7:0]));
				
				//16'h0001: comparePass <= ~|((inData) ^ (rcvd_data_field[7:0], rcvd_FRAME_LEN_cnt[7:0], rcvd_FRAME_LEN_cnt[15:8], SRC_MAC_ADDR, DEST_MAC_ADDR} & expanded_inKeep));//z9
		
				default: begin
					comparePass <= ~|((inData) ^ (rcvd_data_field[7:0]^rcvd_data_field[15:8]^rcvd_data_field[23:16]^rcvd_data_field[31:24]^rcvd_data_field[39:32]^rcvd_data_field[47:40]^rcvd_data_field[55:48]^rcvd_data_field[63:56]^rcvd_data_field[71:64]^rcvd_data_field[79:72]^rcvd_data_field[87:80]^rcvd_data_field[95:88]^rcvd_data_field[103:96]^rcvd_data_field[111:104]^rcvd_data_field[119:112]^rcvd_data_field[127:120])); //z9 default:~|(inData ^ rcvd_data_field)
				end
			endcase //z9
		end
	end
endmodule
	
