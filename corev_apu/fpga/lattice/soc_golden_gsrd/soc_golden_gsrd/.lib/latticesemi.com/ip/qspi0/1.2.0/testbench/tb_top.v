//`timescale 1ns/1ns
`timescale 1ns / 100ps
module tb_top();
    `include "dut_params.v"
	//`include "MX25L51245G.v"
	//`include "W25Q512JVxIQ.v"

    localparam AXI_DATA_WIDTH                    = 32;
    localparam AXI_ADDRESS_WIDTH                 = 32;
	
    //Configuration Registers
    localparam RESERVED                          = 32'h0000000;       // Reserved address for configuration register
    localparam QSPI_CONFIG_REG_0_REG_ADDR        = 32'h0000004;       // Offset for config 0 register
    localparam QSPI_CONFIG_REG_1_REG_ADDR        = 32'h0000008;       // Offset for config 1 register
    localparam FLASH_COMMAND_CODE_0_REG_ADDR     = 32'h000000C;       // Offset for flash command code 0 register
    localparam FLASH_COMMAND_CODE_1_REG_ADDR     = 32'h0000010;       // Offset for flash command code 1 register
    localparam FLASH_COMMAND_CODE_2_REG_ADDR     = 32'h0000014;       // offset for flash command code 2 register
    localparam FLASH_COMMAND_CODE_3_REG_ADDR     = 32'h0000018;       // offset for flash command code 3 register
    localparam FLASH_COMMAND_CODE_4_REG_ADDR     = 32'h000001C;       // offset for flash command code 4 register
    localparam FLASH_COMMAND_CODE_5_REG_ADDR     = 32'h0000020;       // offset for flash command code 5 register
    localparam FLASH_COMMAND_CODE_6_REG_ADDR     = 32'h0000024;       // offset for flash command code 6 register
    localparam FLASH_COMMAND_CODE_7_REG_ADDR     = 32'h0000028;       // offset for flash command code 7 register
    localparam MIN_FLASH_ADDRESS_ALIGN_REG_ADDR  = 32'h000002C;       // offset for minimum flash address alignment register
    localparam STARTING_FLASH_ADDRESS_REG_ADDR   = 32'h0000030;       // offset for starting flash address register
    localparam FLASH_MEMORY_MAP_SIZE_REG_ADDR    = 32'h0000034;       // offset for flash memory map size register
    localparam AXI_ADDRESS_MAP_REG_ADDR          = 32'h0000038;       // offset for AXI address map register
    
    //Status and Interrupt Registers
    localparam TRANSACTION_STATUS_REG_ADDR       = 32'h0000100;     // offset for transaction status register
    localparam INTERRUPT_STATUS_REG_ADDR         = 32'h0000104;     // offset for interrupt status register
    localparam INTERRUPT_ENABLE_REG_ADDR         = 32'h0000108;     // offset for interrupt enable register
    localparam INTERRUPT_SET_REG_ADDR            = 32'h000010C;     // offset for interrupt set register
    localparam SUPPORTED_PKT_HDR_DATA_TRANS_STAT_REG_ADDR = 32'h0000110; // Mapped to Generic SPI Controller
    localparam GENERIC_PKT_HDR_DATA_TRANS_STAT_REG_ADDR   = 32'h0000114; // Mapped to Generic SPI Controller
    
    //Control Registers
    localparam TX_FIFO_MAPPING_REG_ADDR           = 32'h0000200;    // offset for TX FIFO mapping register
    localparam RX_FIFO_MAPPING_REG_ADDR           = 32'h0000204;    // offset for RX FIFO mapping register
    localparam PACKET_HEADER_0_REG_ADDR           = 32'h0000208;    // offset for packet header 0 register
    localparam PACKET_HEADER_1_REG_ADDR           = 32'h000020C;    // offset for packet header 1 register
    localparam PACKET_HEADER_2_REG_ADDR           = 32'h0000210;    // offset for packet header 2 register
    localparam PACKET_HEADER_3_REG_ADDR           = 32'h0000214;    // offset for packet header 3 register
    localparam PACKET_DATA_0_REG_ADDR             = 32'h0000218;    // offset for packet data 0 register
    localparam PACKET_DATA_1_REG_ADDR             = 32'h000021C;    // offset for packet data 1 register
    localparam START_TRANSACTION_REG_ADDR         = 32'h0000220;    // offset for start transaction register
    localparam ENABLE_LOOPBACK_TESTING_REG_ADDR   = 32'h0000224;    // offset for enable loopback register
	
	//Flash Command Opcodes for Unsupported Commands
	localparam WRITE_ENABLE_CMD_OPCODE            = 8'h06;
	localparam BLK_ERASE_CMD_OPCODE               = 8'h20;
	localparam READ_STAT_REG_CMD_OPCODE           = 8'h05;
	localparam PAGE_PROGRAM_CMD_OPCODE            = 8'h02;
	localparam READ_DATA_CMD_OPCODE               = 8'h03;
	localparam FAST_READ_DATA_CMD_OPCODE          = 8'h0B;
	localparam EN4B_ADDR_CMD_OPCODE               = 8'hB7;
	localparam EX4B_ADDR_CMD_OPCODE               = 8'hE9;
	localparam EN_QUAD_IO_CMD_OPCODE              = 8'h35;
	localparam EX_QUAD_IO_CMD_OPCODE              = 8'hF5;
	
	//Input Clock Frequency
    //localparam integer  CLK_PERIOD         = (1000*1000 / (SYSTEM_CLOCK_FREQUENCY));
    localparam real CLK_PERIOD         = (1000.0 / (SYSTEM_CLOCK_FREQUENCY));

    reg a_clk_i;
    reg a_reset_n_i;

    // AXI write address channel
    reg      [ AXI_ID_WIDTH-1: 0]       axi_awid_i     ;  // AXI write address ID
    reg      [ AXI_ADDRESS_WIDTH-1: 0]  axi_awaddr_i   ;  // AXI write address
    reg      [      8-1: 0]             axi_awlen_i    ;  // AXI write burst length
    reg      [      3-1: 0]             axi_awsize_i   ;  // AXI write burst size
    reg      [      2-1: 0]             axi_awburst_i  ;  // AXI write burst type
    reg      [      1-1: 0]             axi_awlock_i   ;  // AXI write lock type
    reg      [      4-1: 0]             axi_awcache_i  ;  // AXI write cache type
    reg      [      3-1: 0]             axi_awprot_i   ;  // AXI write protection type
    reg                                 axi_awvalid_i  ;  // AXI write address valid
    wire                                axi_awready_o  ;  // AXI write ready

    // AXI write data channel
    reg      [ AXI_DATA_WIDTH-1: 0]     axi_wdata_i    ;  // AXI write data
    reg      [ (AXI_DATA_WIDTH/8)-1: 0] axi_wstrb_i    ;  // AXI write strobes
    reg                                 axi_wlast_i    ;  // AXI write last
    reg                                 axi_wvalid_i   ;  // AXI write valid
    wire                                axi_wready_o   ;  // AXI write ready

    // AXI write response channel
    wire     [ AXI_ID_WIDTH-1: 0]       axi_bid_o      ;  // AXI write response ID
    wire     [      2-1: 0]             axi_bresp_o    ;  // AXI write response
    wire                                axi_bvalid_o   ;  // AXI write response valid
    reg                                 axi_bready_i   ;  // AXI write response ready

    // AXI read address channel
    reg      [ AXI_ID_WIDTH-1: 0]       axi_arid_i     ;  // AXI read address ID
    reg      [ AXI_ADDRESS_WIDTH-1: 0]  axi_araddr_i   ;  // AXI read address
    reg      [      8-1: 0]             axi_arlen_i    ;  // AXI read burst length
    reg      [      3-1: 0]             axi_arsize_i   ;  // AXI read burst size
    reg      [      2-1: 0]             axi_arburst_i  ;  // AXI read burst type
    reg      [      1-1: 0]             axi_arlock_i   ;  // AXI read lock type
    reg      [      4-1: 0]             axi_arcache_i  ;  // AXI read cache type
    reg      [      3-1: 0]             axi_arprot_i   ;  // AXI read protection type
    reg                                 axi_arvalid_i  ;  // AXI read address valid
    wire                                axi_arready_o  ;  // AXI read address ready
    
    // axi read data channel
    wire     [ AXI_ID_WIDTH-1: 0]       axi_rid_o      ;  // AXI read response ID
    wire     [ AXI_DATA_WIDTH-1: 0]     axi_rdata_o    ;  // AXI read data
    wire     [      2-1: 0]             axi_rresp_o    ;  // AXI read response
    wire                                axi_rlast_o    ;  // AXI read last
    wire                                axi_rvalid_o   ;  // AXI read response valid
    reg                                 axi_rready_i   ;  // AXI read response ready
    //////////////////////////////////////////////////////////////////////
    //////////////////AXI4-LITE Interface ///////////////////////////////
    reg [31:0]     axil_awaddr_i;
    reg [2:0]      axil_awprot_i;
    reg            axil_awvalid_i;
    wire           axil_awready_o;
    reg [31:0]     axil_wdata_i;
    reg [3:0]      axil_wstrb_i;
    reg            axil_wvalid_i;
    wire           axil_wready_o;
    wire [1:0]     axil_bresp_o;
    wire           axil_bvalid_o;
    reg            axil_bready_i;
    reg [31:0]     axil_araddr_i;
    reg [2:0]      axil_arprot_i;
    reg            axil_arvalid_i;
    wire           axil_arready_o;
    wire [31:0]    axil_rdata_o;
    wire [1:0]     axil_rresp_o;
    wire           axil_rvalid_o;
    reg            axil_rready_i;
    //////////////////////////////////////////////////////////////////////
    ////////////////AHBL Interface ///////////////////////////////////////
    reg [31:0]     ahbl_haddr_i;
    reg [31:0]     ahbl_hwdata_i;
    reg [2:0]      ahbl_hsize_i;
    reg            ahbl_hwrite_i;
    reg            ahbl_hsel_i;
    reg [2:0]      ahbl_hburst_i;
    reg [1:0]      ahbl_htrans_i;
    reg            ahbl_hmastlock_i;
    reg [3:0]      ahbl_hprot_i;
    reg            ahbl_hready_i;
    wire [31:0]    ahbl_hrdata_o;
    wire  [1:0]    ahbl_hresp_o;
    wire           ahbl_hready_o;
    reg            flash_decode_rd_en_i = 0;
    reg            data_valid_rx_i = 0;
    reg [31:0]     data_rx_i;
    reg            pkt_ready_i = 0;
    reg            flash_rd = 0;
	reg [2:0]      size_3b;
	reg [31:0]     aadr_32b;
    
    reg [31:0] irq_status_32b = 0;
    reg [31:0] irq_status_32b_1 = 0;
    reg [31:0] irq_status_32b_2 = 0;
    reg [31:0] irq_status_32b_3 = 0;
    reg [31:0] irq_status_32b_4 = 0;
    reg [31:0] irq_status_32b_5 = 0;
    reg [31:0] irq_status_32b_6 = 0;
    reg [31:0] irq_loopback_read_0 = 0;
    reg [31:0] irq_loopback_read_1 = 0;
    reg [31:0] irq_loopback_read_2 = 0;
    reg [31:0] irq_loopback_read_3 = 0;
    reg [31:0] trans_stat_32b = 0;
    reg [31:0] write_data_cnt = 0;
    reg [31:0] loopback_read_0 = 0;
    reg [31:0] loopback_read_1 = 0;
    reg [31:0] loopback_read_2 = 0;
    reg [31:0] loopback_read_3 = 0;
    reg [31:0] page_program_transaction_status_32b = 0;
    reg [31:0] sector_erase_transaction_status_32b = 0;
    reg [31:0] sector_erase_transaction_status_32b_1 = 0;
    reg [31:0] read_transaction_status_32b = 0;
    reg [31:0] read_transaction_status_32b_1 = 0;
    reg [31:0] read_transaction_status_32b_2 = 0;
    reg [31:0] read_transaction_status_32b_3 = 0;
    reg [31:0] rd_data_1;
    reg [31:0] rd_data_2;
    reg [31:0] rd_data_3;
	
    wire       qspi_io0;
    wire       qspi_io1;
    wire       qspi_io2;
    wire       qspi_io3;
    wire       read_io_o;
    wire       io0_i;
    wire       io0_oe_o;
    wire       io0_o;
    wire       io1_i;
    wire       io1_oe_o;
    wire       io1_o;
    wire       io2_o;
    wire       io2_oe_o;
    wire       io3_o;
    wire       io3_oe_o;
    wire       sclk_o;
    wire [NUMBER_OF_SLAVE_SELECT_LINES-1:0] ss_n_o;
	
	wire       si;
	wire       so;
	wire       sio2;
	wire       sio3;
	//inout       sio0;
	//inout       sio1;
	//inout       sio2;
	//inout       sio3;
	
    reg [31:0] memory_map_reg = 0;
	
    integer                        errs_i;            // Total number of errors detected
    reg                            finish_on_error_b; // Terminate on error message
	reg                            overwrite_gui_settings;
	reg                            disp_sim_log;
    reg                            run_full_regr;
	reg                            standard_spi_fast_read_en;
	reg  [1:0]                     flash_device;              
	
    `include "dut_inst.v"
	// Supported Flash Commands flash_command_code and default opcodes
	// flash_command_code          || Opcode  || Flash Command
	// flash_command_code == 5'h00 ||  8'h05  || Read Status Register-1
	// flash_command_code == 5'h01 ||  8'h35  || Read Status Register-2
	// flash_command_code == 5'h02 ||  8'h15  || Read Status Register-3
	// flash_command_code == 5'h03 ||  8'hB5  || Read Configuration Register
	// flash_command_code == 5'h04 ||  8'h9F  || Read ID
	// flash_command_code == 5'h05 ||  8'hAB  || Read Electronic ID
	// flash_command_code == 5'h06 ||  8'hAF  || Multiple I/O Read ID
	// flash_command_code == 5'h07 ||  8'h90  || Read Manufacturer and Device ID
	// flash_command_code == 5'h08 ||  8'h92  || Read Manufacturer and Device ID Dual I/O
	// flash_command_code == 5'h09 ||  8'h94  || Read Manufacturer and Device ID Quad I/O
	// flash_command_code == 5'h0A ||  8'h03  || Read Data
	// flash_command_code == 5'h0B ||  8'h0B  || Fast Read
	// flash_command_code == 5'h0C ||  8'h3B  || Dual Output Fast Read
	// flash_command_code == 5'h0D ||  8'hBB  || Dual Input/Output Fast Read
	// flash_command_code == 5'h0E ||  8'h6B  || Quad Output Fast Read
	// flash_command_code == 5'h0F ||  8'hEB  || Quad Input/Output Fast Read
	// flash_command_code == 5'h10 ||  8'h20  || Block Erase Type 1
	// flash_command_code == 5'h11 ||  8'h52  || Block Erase Type 2
	// flash_command_code == 5'h12 ||  8'hD8  || Block Erase Type 3
	// flash_command_code == 5'h13 ||  8'h60  || Chip Erase
	// flash_command_code == 5'h14 ||  8'h06  || Write Enable
	// flash_command_code == 5'h15 ||  8'h04  || Write Disable
	// flash_command_code == 5'h16 ||  8'h01  || Write Status/Configuration Register 
	// flash_command_code == 5'h17 ||  8'h02  || Page Program
	// flash_command_code == 5'h18 ||  8'hA2  || Dual Input Fast Program
	// flash_command_code == 5'h19 ||  8'hD2  || Extended Dual Input Fast Program
	// flash_command_code == 5'h1A ||  8'h32  || Quad Input Fast Program
	// flash_command_code == 5'h1B ||  8'h38  || Extended Quad Input Fast Program
	// flash_command_code == 5'h1C ||  8'hB7  || Enter 4-Byte Address Mode
	// flash_command_code == 5'h1D ||  8'hE9  || Exit 4-Byte Address Mode
	// flash_command_code == 5'h1E ||  8'h35  || Enter Quad Input/Output Mode
	// flash_command_code == 5'h1F ||  8'hF5  || Reset Quad Input/Output Mode
	
	
	// Supported Flash Commands on Winbond (W25Q512JVxIQ) Flash flash_command_code and equivalent opcode
	// For Write and Read Commands, all opcodes used are on 3-byte address mode
	// flash_command_code          || Opcode  || Flash Command
	// flash_command_code == 5'h00 ||  8'h05  || Read Status Register-1
	// flash_command_code == 5'h01 ||  8'h35  || Read Status Register-2
	// flash_command_code == 5'h02 ||  8'h15  || Read Status Register-3
	// flash_command_code == 5'h03 ||  8'hB5  || Read Configuration Register --> Not existing
	// flash_command_code == 5'h04 ||  8'h9F  || JEDEC ID 
	// flash_command_code == 5'h05 ||  8'hAB  || Read Electronic ID
	// flash_command_code == 5'h06 ||  8'hAF  || Multiple I/O Read ID --> Not existing
	// flash_command_code == 5'h07 ||  8'h90  || Read Manufacturer and Device ID
	// flash_command_code == 5'h08 ||  8'h92  || Read Manufacturer and Device ID Dual I/O
	// flash_command_code == 5'h09 ||  8'h94  || Read Manufacturer and Device ID Quad I/O
	// flash_command_code == 5'h0A ||  8'h03  || Read Data
	// flash_command_code == 5'h0B ||  8'h0B  || Fast Read
	// flash_command_code == 5'h0C ||  8'h3B  || Dual Output Fast Read 1-1-2
	// flash_command_code == 5'h0D ||  8'hBB  || Dual Input/Output Fast Read 1-2-2
	// flash_command_code == 5'h0E ||  8'h6B  || Quad Output Fast Read 1-1-4
	// flash_command_code == 5'h0F ||  8'hEB  || Quad Input/Output Fast Read 1-4-4
	// flash_command_code == 5'h10 ||  8'h20  || Block Erase Type 1
	// flash_command_code == 5'h11 ||  8'h52  || Block Erase Type 2
	// flash_command_code == 5'h12 ||  8'hD8  || Block Erase Type 3
	// flash_command_code == 5'h13 ||  8'h60  || Chip Erase
	// flash_command_code == 5'h14 ||  8'h06  || Write Enable
	// flash_command_code == 5'h15 ||  8'h04  || Write Disable
	// flash_command_code == 5'h16 ||  8'h01  || Write Status/Configuration Register 01h, 31h, 11h
	// flash_command_code == 5'h17 ||  8'h02  || Page Program
	// flash_command_code == 5'h18 ||  8'hA2  || Dual Input Fast Program --> Not existing 
	// flash_command_code == 5'h19 ||  8'hD2  || Extended Dual Input Fast Program --> Not existing
	// flash_command_code == 5'h1A ||  8'h32  || Quad Input Fast Program 1-1-4
	// flash_command_code == 5'h1B ||  8'h38  || Extended Quad Input Fast Program  --> Not existing
	// flash_command_code == 5'h1C ||  8'hB7  || Enter 4-Byte Address Mode
	// flash_command_code == 5'h1D ||  8'hE9  || Exit 4-Byte Address Mode
	// flash_command_code == 5'h1E ||  8'h35  || Enter Quad Input/Output Mode  --> Not existing, since no command is fully quad
	// flash_command_code == 5'h1F ||  8'hF5  || Reset Quad Input/Output Mode  --> Not existing, since no command is fully quad
	

    initial begin
       a_clk_i = 0;   
       forever #(CLK_PERIOD/2.0) a_clk_i =  ~a_clk_i;
    end
    
    initial begin
        a_reset_n_i  = 1'b0;
        #12000;
        a_reset_n_i = 1'b1;
	    if(INTERFACE==0) begin
		    ahbl_haddr_i     = 32'h0;
		    ahbl_hwdata_i    = 32'h0;
		    ahbl_hsize_i     = 3'h0;
		    ahbl_hwrite_i    = 1'h0;
		    ahbl_hsel_i      = 1'h0;
		    ahbl_hburst_i    = 3'h0;
		    ahbl_htrans_i    = 2'h0;
		    ahbl_hmastlock_i = 1'h0;
		    ahbl_hprot_i     = 1'h0;
		    ahbl_hready_i    = 1'h0;
	    end
    end
	
	initial begin
       errs_i = 0;
	   test_runner();
	   post_process();
	   $finish(1);
	end
            
    GSR GSR_INST ( .GSR_N(a_reset_n_i), .CLK(a_clk_i));
    
	generate 
        if(ENABLE_IO_PRIMITIVE == 1) begin
            if(SUPPORTED_PROTOCOL == 0 || SUPPORTED_PROTOCOL == 1) begin // standard/dual mode
			    assign si        = qspi_io0;
				assign qspi_io1  = so;
            end
            //else if (SUPPORTED_PROTOCOL == 2) begin // quad mode
			//    //assign si  =  qspi_io0;
			//	//assign so  =  qspi_io1;
			//	//assign sio2=  qspi_io2;
			//	//assign sio3=  qspi_io3;
			//    assign qspi_io0 = si  ;
			//	assign qspi_io1 = so  ;
			//	assign qspi_io2 = sio2;
			//	assign qspi_io3 = sio3;
            //end
		end
        else begin
            if(SUPPORTED_PROTOCOL == 0 || SUPPORTED_PROTOCOL == 1) begin // standard/dual mode
			    assign si      = io0_o;
				assign io1_i   = so;
            end
            else if (SUPPORTED_PROTOCOL == 2) begin // quad mode
			    assign si    = io0_o;
				assign io1_i = so;
				assign sio2  = io2_o;
				assign sio3  = io3_o;
            end
        end
    endgenerate
		
	if(SUPPORTED_PROTOCOL == 0) begin
	    MX25L51245G MX25L51245G_inst  (.SCLK (sclk_o),
	                                    .CS   (ss_n_o[0]),
	    							    .SI   (si),
	    							    .SO   (so),
	    							    .WP   (),
	    							    .SIO3 (),
                                        .RESET()); 
										
        W25Q512JVxIQ W25Q512JVxIQ_inst(
	        .CSn     (ss_n_o[1]), 
	        .CLK     (sclk_o), 
	    	.DIO     (si), 
	    	.DO      (so), 
	    	.WPn     (), 
	    	.HOLDn   ());
	end	
	else if(SUPPORTED_PROTOCOL == 1) begin // Dual SPI Mode
	    MX25L51245G MX25L51245G_inst  (.SCLK (sclk_o),
	                                    .CS   (ss_n_o[0]),
	    							    .SI   (qspi_io0),
	    							    .SO   (qspi_io1),
	    							    .WP   (),
	    							    .SIO3 (),
                                        .RESET()); 
										
        W25Q512JVxIQ W25Q512JVxIQ_inst(
	        .CSn     (ss_n_o[1]), 
	        .CLK     (sclk_o), 
	    	.DIO     (qspi_io0), 
	    	.DO      (qspi_io1), 
	    	.WPn     (), 
	    	.HOLDn   ());
	end
	else begin // Quad SPI Mode
	    MX25L51245G MX25L51245G_inst  (.SCLK (sclk_o),
	                                    .CS   (ss_n_o[0]),
	    							    .SI   (qspi_io0),
	    							    .SO   (qspi_io1),
	    							    .WP   (qspi_io2),
	    							    .SIO3 (qspi_io3),
                                        .RESET());
										
        W25Q512JVxIQ W25Q512JVxIQ_inst(
	        .CSn     (ss_n_o[1]), 
	        .CLK     (sclk_o), 
	    	.DIO     (qspi_io0), 
	    	.DO      (qspi_io1), 
	    	.WPn     (qspi_io2), 
	    	.HOLDn   (qspi_io3));
	end
	
    //Tasks AXI4-LITE Write
    task axilite_write;  
    input [31:0]      addr;
    input [31:0]     wr_data;
    begin
       repeat (1) @(posedge a_clk_i) ;
       axil_bready_i    <= 1'b1;
       axil_awvalid_i   <=  1'b1;
       wait (axil_awready_o);
       axil_awaddr_i       <=  addr; 
       repeat (1) @(posedge a_clk_i) ;
       axil_awvalid_i   <=  1'b0;
       axil_wvalid_i    <=  1'b1; 
       wait (axil_wready_o);
       axil_wstrb_i     <=  4'b1111;
       axil_wdata_i       <=  wr_data;
       if (disp_sim_log == 1) $display("---INFO : AXI Write to Addr:%h, Data:%h at %0t", addr, wr_data, $time ) ;
       repeat (1) @(posedge a_clk_i) ;
       axil_wvalid_i    <=  1'b0;
       wait (axil_bvalid_o); 
       repeat (1) @(posedge a_clk_i) ;
         axil_bready_i  <= 1'b0;
    	  axil_wstrb_i   <= 4'b0000;
       repeat (1) @(posedge a_clk_i) ;
    end
    endtask
    
    //Tasks AXI4-LITE Read
    task axilite_read;  
    input [31:0]      addr;
    output [31:0]    rd_data;
    begin
       repeat (1) @(posedge a_clk_i) ;
       axil_arvalid_i   <=  1'b1;
       wait (axil_arready_o);
       axil_araddr_i  <=  addr;
       axil_rready_i   <=  1'b1;
       repeat (1) @(posedge a_clk_i) ;
       axil_arvalid_i <=  1'b0;
       wait (axil_rvalid_o);
       rd_data  <=  axil_rdata_o[31:0];
       if (disp_sim_log == 1) $display("---INFO : AXI4L Read to Addr:%h, Data:%h at %0t", addr, axil_rdata_o, $time ) ;
       repeat (1) @(posedge  a_clk_i) ;
          axil_rready_i    <=  1'b0; 
       repeat (1) @(posedge  a_clk_i) ;
       
    end
    endtask
    
    //Task AHBL Write
    task ahbl_write;
    input [31:0]     addr;
    input [31:0]     wr_data;
    begin // Modified ahbl_write
       repeat (1) @(posedge  a_clk_i) ;
           ahbl_hsize_i     <= 3'b010; // added JAMR
    	   ahbl_hprot_i     <= 1'h0;   // added JAMR
    	   ahbl_hmastlock_i <= 1'h0;   // added JAMR
           ahbl_hburst_i    <= 3'h0;   // added JAMR
       wait (ahbl_hready_o);
       ahbl_haddr_i   <= addr ; 
       ahbl_hwrite_i  <=  1'b1;
       ahbl_hready_i  <=  1'b1;
       ahbl_hsel_i    <=  1'b1;
       ahbl_htrans_i  <=  2'b10;
       ahbl_hwdata_i  <= wr_data;
       //#10;
       @ (posedge a_clk_i);
       if (disp_sim_log == 1) $display("---INFO : AHBL Write to Addr:%h, Data:%h at %0t", addr, wr_data, $time ) ;
       ahbl_haddr_i <= 0 ;
       ahbl_hsel_i    <=  1'b0;
       ahbl_hwrite_i  <=  1'b0;
       ahbl_hready_i  <=  1'b0;
       ahbl_htrans_i  <=  2'b00;
       repeat (1) @(posedge  a_clk_i) ;
    end
    endtask
    
    //Task AHBL Read
    task ahbl_read;
    input [31:0]      addr;
    output [31:0]    rd_data;
    begin // Modified ahbl_read
       @(posedge  a_clk_i) ;
       ahbl_hsize_i     <= 3'b010; // added JAMR
       ahbl_hprot_i     <= 1'h0;   // added JAMR
       ahbl_hmastlock_i <= 1'h0;   // added JAMR
       ahbl_hburst_i    <= 3'h0;   // added JAMR
       ahbl_hburst_i    <= 0;
       ahbl_haddr_i     <= addr ; 
       ahbl_hsel_i      <= 1'b1;
       ahbl_hwrite_i    <= 1'b0;
       ahbl_hready_i    <= 1'b1;
       ahbl_htrans_i    <= 2'b10;
       @(posedge a_clk_i);
       ahbl_haddr_i     <= 32'h0 ; 
       ahbl_hsel_i      <= 1'b0;
       ahbl_htrans_i    <= 2'b00;
       @(posedge a_clk_i);
       while (ahbl_hready_o == 1'b0) begin
           @(posedge a_clk_i);
       end
       rd_data   <=  ahbl_hrdata_o;
       if (disp_sim_log == 1) $display("---INFO : AHBL Read to Addr:%h, Data:%h at %0t", addr, ahbl_hrdata_o, $time ) ;
       //ahbl_haddr_i <= 0 ;
       //ahbl_hsel_i   <= 1'b0 ; 
       //ahbl_hwrite_i <= 1'b0;
       //ahbl_hready_i <= 1'b0;
          
       repeat (1) @(posedge  a_clk_i) ;
    end
    endtask

    //Task AHBL Write
    /*task ahbl_write;
    input [31:0]      addr;
    input [31:0]      wr_data;
    begin
        repeat (1) @(posedge  a_clk_i) ;
        wait (ahbl_hready_o);
        $display("---INFO : AHBL write to Addr:%h, Data:%h at %0t", addr, wr_data, $time ) ;
        ahbl_haddr_i                    <= addr; 
        ahbl_htrans_i                   <= 2;
        ahbl_hsel_i                     <= 1;
        ahbl_hwrite_i                   <= 1;
        ahbl_hburst_i                   <= 0;
        ahbl_hsize_i                    <= 3'b010;
        @ (posedge a_clk_i);
        ahbl_haddr_i                    <= 0;
        ahbl_hwrite_i                   <= 0;
        ahbl_htrans_i                   <= 0;
        ahbl_hwdata_i                   <= wr_data;
	    
        //if( S_AHB_DAT_WIDTH == 32 && p_size_3b == 0) begin
        //  if( S_AHB_DAT_ENDIANESS == "little-endian")
        //    case (p_addr_32b[1:0])
        //      2'b00 : ahbl_hwdata     <= {24'd0, p_data_32b[7:0]};
        //      2'b01 : ahbl_hwdata     <= {16'd0, p_data_32b[7:0],  8'd0};
        //      2'b10 : ahbl_hwdata     <= { 8'd0, p_data_32b[7:0], 16'd0};
        //      2'b11 : ahbl_hwdata     <= {       p_data_32b[7:0], 24'd0};
        //    endcase
        //  else // !if( S_AHB_DAT_ENDIANESS == "little-endian")
        //    case (p_addr_32b[1:0])
        //      2'b00 : ahbl_hwdata     <= {       p_data_32b[7:0], 24'd0};
        //      2'b01 : ahbl_hwdata     <= { 8'd0, p_data_32b[7:0], 16'd0};
        //      2'b10 : ahbl_hwdata     <= {16'd0, p_data_32b[7:0],  8'd0};
        //      2'b11 : ahbl_hwdata     <= {24'd0, p_data_32b[7:0]};
        //    endcase
        //end
        //else
        //  ahbl_hwdata                 <= p_data_32b;
	    
        @ (posedge a_clk_i);
        //3---------------------------------------------------------------------------------------------
        // Transfer is completed 
        //3---------------------------------------------------------------------------------------------
        while (ahbl_hready_o == 0) begin
          @ (posedge a_clk_i);
        end
        ahbl_htrans_i                   <= 0;
        ahbl_hwrite_i                   <= 0;
        ahbl_hburst_i                   <= 0;
        ahbl_hsize_i                    <= 0;
        ahbl_hsel_i                     <= 0;
    end
    endtask*/
    
    //Task AHBL Read
    /*task ahbl_read;
    input [31:0]     addr;
    output [31:0]    rd_data;
    begin
       repeat (1) @(posedge  a_clk_i) ;
	   ahbl_hwdata_i    <= 32'h0;
	   ahbl_hprot_i     <= 1'h0;
	   ahbl_hmastlock_i <= 1'h0;
       ahbl_hburst_i    <=  3'h0;
       ahbl_haddr_i     <=  addr ; 
       ahbl_hsel_i      <=  1'b1;
       ahbl_hwrite_i    <=  1'b0;
       ahbl_hready_i    <=  1'b1;
       ahbl_htrans_i    <=  2'b10;
	   ahbl_hsize_i     <=  3'b010;
       #20;
       wait(ahbl_hready_o);
       rd_data   <=  ahbl_hrdata_o;
       $display("---INFO : AHBL Read to Addr:%h, Data:%h at %0t", addr, ahbl_hrdata_o, $time ) ;
       #20;
       ahbl_haddr_i  <= 32'h0 ;
       ahbl_hsel_i   <= 1'b0 ; 
       ahbl_hwrite_i <= 1'b0;
       ahbl_hready_i <= 1'b0;
          
       repeat (1) @(posedge  a_clk_i) ;
    end
    endtask*/
    
	reg   [31:0]      burst_prg_data_2d_32b [1023:0]  ;  
	//Task AHBL Burst Write
    task burst_write_ahb;
      input    [31:0]      p_addr_32b                      ;
      input    [31:0]      p_data_32b                      ;
      input    [2:0]       p_size_3b                       ;
      input    [31:0]      p_burst_32b                     ; 
	  
      integer              m_i_i;
      reg      [31:0]      addr_32b                       ;
      begin
        @ (posedge a_clk_i);
        $write("# ---INFO : @%0dns :: AHB Burst Write address 0x%x\n",$time,p_addr_32b);
        ahbl_haddr_i                    <= p_addr_32b; 
        ahbl_htrans_i                   <= 2;
        ahbl_hsel_i                     <= 1;
        ahbl_hwrite_i                   <= 1;
        ahbl_hburst_i                   <= 1;
        ahbl_hready_i                   <= 1;
        ahbl_hsize_i                    <= p_size_3b;
        size_3b                         <= p_size_3b;
        addr_32b                        <= p_addr_32b;
        @ (posedge a_clk_i);
        
        //No wait states are expected
        for (m_i_i = 0; m_i_i < p_burst_32b; m_i_i = m_i_i + 1) begin
            ahbl_hwdata_i               <= $random;
            addr_32b                    <= addr_32b + 4;
			burst_prg_data_2d_32b[m_i_i][31:0] <= ahbl_hwdata_i;     
            
          if(m_i_i == (p_burst_32b-1)) begin
            ahbl_haddr_i                <= 0;
            ahbl_htrans_i               <= 0;
            ahbl_hsel_i                 <= 0;
            ahbl_hwrite_i               <= 0;
            ahbl_hburst_i               <= 0;
            ahbl_hsize_i                <= 0;
          end
          else
            ahbl_htrans_i               <= 3;
          
          @ (posedge a_clk_i);
           while (ahbl_hready_o == 0) begin
              @ (posedge a_clk_i);
           end
		   //hready <= 1;
        end
    
        //3---------------------------------------------------------------------------------------------
        // Transfer is completed 
        //3---------------------------------------------------------------------------------------------
        ahbl_hsel_i                 <= 0;
      end
    endtask

	reg   [31:0]      burst_rd_data_2d_32b [1023:0];
	//Task AHBL Burst Read
    task burst_read_ahb;
       input    [31:0]      p_addr_32b                     ;
       input    [2:0]       p_size_3b                      ;
       input    [31:0]      p_burst_32b                    ;
	   //output reg  [31:0]      burst_rd_data_2d_32b [1023:0]  ;
       integer              m_i_i;
       reg      [31:0]      addr_32b                       ;
	   reg      [31:0]      rd_data                        ;
       begin
         @ (posedge a_clk_i);
         $write("# ---INFO : @%0dns :: AHB Burst Read address 0x%x\n",$time,p_addr_32b);
         ahbl_haddr_i                <= p_addr_32b; 
         ahbl_htrans_i               <= 2;
         ahbl_hsel_i                 <= 1;
         ahbl_hwrite_i               <= 0;
         ahbl_hburst_i               <= 1;
         ahbl_hready_i               <= 1;
         ahbl_hsize_i                <= p_size_3b;
         size_3b                     <= p_size_3b;
         addr_32b                    <= p_addr_32b;
               
         @ (posedge a_clk_i);
    
         //No wait states are expected
         for (m_i_i = 0; m_i_i < p_burst_32b; m_i_i = m_i_i + 1) begin        
           if(m_i_i == (p_burst_32b-1)) begin
             ahbl_haddr_i            <= 0;
             ahbl_htrans_i           <= 0;
             ahbl_hsel_i             <= 0;
             ahbl_hwrite_i           <= 0;
             ahbl_hburst_i           <= 0;
             ahbl_hsize_i            <= 0;
           end
           else
             ahbl_htrans_i           <= 3;
           
           @ (negedge a_clk_i);
           
           while (ahbl_hready_o == 0) begin
             @ (negedge a_clk_i);
           end
           rd_data   <=  ahbl_hrdata_o;
		   burst_rd_data_2d_32b[m_i_i][31:0] <= rd_data;
           
           @ (posedge a_clk_i);
		   if (ahbl_hready_o == 1) begin
		   end
         end
           while (ahbl_hready_o == 0) begin
             @ (negedge a_clk_i);
           end
         
         //3---------------------------------------------------------------------------------------------
         // Transfer is completed 
         //3---------------------------------------------------------------------------------------------
         ahbl_hsel_i             <= 0;
       end
    endtask

	
	task axi_write_bulk_page_prog;  
    input [31:0]      axi_addr;
    input [7:0]       axi_awlen;
    input [2:0]       axi_awsize;
    input [1:0]       axi_awburst;
    begin
       axi_awvalid_i   <=  1'b0;
       repeat (1) @(posedge a_clk_i) ;
       axi_awid_i      <= 4'b0101;        
       axi_awlen_i     <= axi_awlen;
       axi_awsize_i    <= axi_awsize;
       axi_awburst_i   <= axi_awburst;
       axi_awlock_i    <= 0;
       axi_awcache_i   <= 0;
       axi_awprot_i    <= 0;
       axi_awvalid_i   <=  1'b1;
       axi_wvalid_i    <= 0;
       
       axi_wlast_i     <= 0;
       axi_awaddr_i       <=  axi_addr; 
       repeat (1) @(posedge a_clk_i) ;
       axi_wvalid_i    <=  1'b1;  
       axi_wstrb_i     <=  4'b1111;
       axi_wdata_i       <=  32'h0010005F; // configuration register 0
       
       wait (axi_wready_o);
       axi_awvalid_i   <=  1'b0; 
       if (disp_sim_log == 1) $display("---INFO : AXI Write to axi_addr:%h, Data:%h at %0t", axi_addr, axi_wdata_i, $time ) ;
       repeat (1) @(posedge a_clk_i) ;
       axi_wstrb_i     <=  4'b1111;
       axi_wdata_i       <=  32'h00004000; // configuration register 1
       wait (axi_wready_o);
       if (disp_sim_log == 1) $display("---INFO : AXI Write to axi_addr:%h, Data:%h at %0t", axi_addr, axi_wdata_i, $time ) ;
       repeat (1) @(posedge a_clk_i) ;
       axi_wstrb_i     <=  4'b1111;
       axi_wdata_i       <=  32'h00040508; // address
       wait (axi_wready_o);
       if (disp_sim_log == 1) $display("---INFO : AXI Write to axi_addr:%h, Data:%h at %0t", axi_addr, axi_wdata_i, $time ) ;
       repeat (1) @(posedge a_clk_i) ;
       axi_wstrb_i     <=  4'b1111;
       axi_wdata_i       <=  32'h04024446; // data0
       wait (axi_wready_o);
       if (disp_sim_log == 1) $display("---INFO : AXI Write to axi_addr:%h, Data:%h at %0t", axi_addr, axi_wdata_i, $time ) ;
       repeat (1) @(posedge a_clk_i) ;
       axi_wstrb_i     <=  4'b1111;
       axi_wdata_i       <=  32'h06024446;
       wait (axi_wready_o);
       if (disp_sim_log == 1) $display("---INFO : AXI Write to axi_addr:%h, Data:%h at %0t", axi_addr, axi_wdata_i, $time ) ;
       repeat (1) @(posedge a_clk_i) ;
       axi_wstrb_i     <=  4'b1111;
       axi_wdata_i       <=  32'h08024446;
       wait (axi_wready_o);
       if (disp_sim_log == 1) $display("---INFO : AXI Write to axi_addr:%h, Data:%h at %0t", axi_addr, axi_wdata_i, $time ) ;
       repeat (1) @(posedge a_clk_i) ;
       axi_wstrb_i     <=  4'b1111;
       axi_wdata_i       <=  32'h0A024446;
       wait (axi_wready_o);
       axi_wlast_i     <= 1;
       if (disp_sim_log == 1) $display("---INFO : AXI Write to axi_addr:%h, Data:%h at %0t", axi_addr, axi_wdata_i, $time ) ;
       repeat (1) @(posedge a_clk_i) ;
       axi_wvalid_i    <=  1'b0;
       axi_wlast_i     <= 1'b0;
       axi_wstrb_i     <=  4'b0000;
       axi_wdata_i       <=  32'h00000000;
       axi_bready_i <= 1;
       wait (axi_bvalid_o);
       repeat (1) @(posedge a_clk_i) ;
       axi_bready_i <= 0; 
    end
    endtask
    
    task axi_write_bulk_page_prog_unsupported;  
    input [31:0]      axi_addr;
    input [7:0]       axi_awlen;
    input [2:0]       axi_awsize;
    input [1:0]       axi_awburst;
    begin
       axi_awvalid_i   <=  1'b0;
       repeat (1) @(posedge a_clk_i) ;
       axi_awid_i      <= 4'b0101;        
       axi_awlen_i     <= axi_awlen;
       axi_awsize_i    <= axi_awsize;
       axi_awburst_i   <= axi_awburst;
       axi_awlock_i    <= 0;
       axi_awcache_i   <= 0;
       axi_awprot_i    <= 0;
       axi_awvalid_i   <=  1'b1;
       axi_wvalid_i    <= 0;
       
       axi_wlast_i     <= 0;
       axi_awaddr_i       <=  axi_addr; 
       repeat (1) @(posedge a_clk_i) ;
       axi_wvalid_i    <=  1'b1;  
       axi_wstrb_i     <=  4'b1111;
       axi_wdata_i       <=  32'h00140032; // configuration register 0
       
       wait (axi_wready_o);
       axi_awvalid_i   <=  1'b0; 
       if (disp_sim_log == 1) $display("---INFO : AXI Write to axi_addr:%h, Data:%h at %0t", axi_addr, axi_wdata_i, $time ) ;
       repeat (1) @(posedge a_clk_i) ;
       axi_wstrb_i     <=  4'b1111;
       if(DATA_ENDIANNESS == 1) begin
          axi_wdata_i       <=  32'h02080405; // data
       end
       else begin
          axi_wdata_i       <=  32'h05040802; // data
       end
       wait (axi_wready_o);
       if (disp_sim_log == 1) $display("---INFO : AXI Write to axi_addr:%h, Data:%h at %0t", axi_addr, axi_wdata_i, $time ) ;
       repeat (1) @(posedge a_clk_i) ;
       axi_wstrb_i     <=  4'b1111;
       axi_wdata_i       <=  32'h04024446;
       wait (axi_wready_o);
       if (disp_sim_log == 1) $display("---INFO : AXI Write to axi_addr:%h, Data:%h at %0t", axi_addr, axi_wdata_i, $time ) ;
       repeat (1) @(posedge a_clk_i) ;
       axi_wstrb_i     <=  4'b1111;
       axi_wdata_i       <=  32'h06024446;
       wait (axi_wready_o);
       if (disp_sim_log == 1) $display("---INFO : AXI Write to axi_addr:%h, Data:%h at %0t", axi_addr, axi_wdata_i, $time ) ;
       repeat (1) @(posedge a_clk_i) ;
       axi_wstrb_i     <=  4'b1111;
       axi_wdata_i       <=  32'h08024446;
       wait (axi_wready_o);
       if (disp_sim_log == 1) $display("---INFO : AXI Write to axi_addr:%h, Data:%h at %0t", axi_addr, axi_wdata_i, $time ) ;
       repeat (1) @(posedge a_clk_i) ;
       axi_wstrb_i     <=  4'b1111;
       axi_wdata_i       <=  32'h0A024446;
       wait (axi_wready_o);
       axi_wlast_i     <= 1;
       if (disp_sim_log == 1) $display("---INFO : AXI Write to axi_addr:%h, Data:%h at %0t", axi_addr, axi_wdata_i, $time ) ;
       repeat (1) @(posedge a_clk_i) ;
       axi_wvalid_i    <=  1'b0;
       axi_wlast_i     <= 1'b0;
       axi_wstrb_i     <=  4'b0000;
       axi_wdata_i       <=  32'h00000000;
       axi_bready_i <= 1;
       wait (axi_bvalid_o);
       repeat (1) @(posedge a_clk_i) ;
       axi_bready_i <= 0; 
    end
    endtask
    
    task axi_write_bulk_block_erase_unsupported;  
    input [31:0]      axi_addr;
    input [7:0]       axi_awlen;
    input [2:0]       axi_awsize;
    input [1:0]       axi_awburst;
    begin
       axi_awvalid_i   <=  1'b0;
       repeat (1) @(posedge a_clk_i) ;
       axi_awid_i      <= 4'b0101;        
       axi_awlen_i     <= axi_awlen;
       axi_awsize_i    <= axi_awsize;
       axi_awburst_i   <= axi_awburst;
       axi_awlock_i    <= 0;
       axi_awcache_i   <= 0;
       axi_awprot_i    <= 0;
       axi_awvalid_i   <=  1'b1;
       axi_wvalid_i    <= 0;
       
       axi_wlast_i     <= 0;
       axi_awaddr_i       <=  axi_addr; 
       repeat (1) @(posedge a_clk_i) ;
       axi_wvalid_i    <=  1'b1;  
       axi_wstrb_i     <=  4'b1111;
       axi_wdata_i       <=  32'h00040032; // configuration register 0
       
       wait (axi_wready_o);
       axi_awvalid_i   <=  1'b0; 
       if (disp_sim_log == 1) $display("---INFO : AXI Write to axi_addr:%h, Data:%h at %0t", axi_addr, axi_wdata_i, $time ) ;
       repeat (1) @(posedge a_clk_i) ;
       axi_wstrb_i     <=  4'b1111;
       if(DATA_ENDIANNESS == 1) begin
          axi_wdata_i       <=  32'h20080405; // configuration register 1
       end
       else begin
          axi_wdata_i       <=  32'h05040820; // configuration register 1
       end
       wait (axi_wready_o);
       axi_wlast_i     <= 1;
       if (disp_sim_log == 1) $display("---INFO : AXI Write to axi_addr:%h, Data:%h at %0t", axi_addr, axi_wdata_i, $time ) ;
       repeat (1) @(posedge a_clk_i) ;
       axi_wvalid_i    <=  1'b0;
       axi_wlast_i     <= 1'b0;
       axi_wstrb_i     <=  4'b0000;
       axi_wdata_i       <=  32'h00000000;
       axi_bready_i <= 1;
       wait (axi_bvalid_o);
       repeat (1) @(posedge a_clk_i) ;
       axi_bready_i <= 0; 
    end
    endtask
    
    task axi_write_bulk_block_erase;  
    input [31:0]      axi_addr;
    input [7:0]       axi_awlen;
    input [2:0]       axi_awsize;
    input [1:0]       axi_awburst;
    begin
       axi_awvalid_i   <=  1'b0;
       repeat (1) @(posedge a_clk_i) ;
       axi_awid_i      <= 4'b0101;        
       axi_awlen_i     <= axi_awlen;
       axi_awsize_i    <= axi_awsize;
       axi_awburst_i   <= axi_awburst;
       axi_awlock_i    <= 0;
       axi_awcache_i   <= 0;
       axi_awprot_i    <= 0;
       axi_awvalid_i   <=  1'b1;
       axi_wvalid_i    <= 0;
       
       axi_wlast_i     <= 0;
       axi_awaddr_i       <=  axi_addr; 
       repeat (1) @(posedge a_clk_i) ;
       axi_wvalid_i    <=  1'b1;  
       axi_wstrb_i     <=  4'b1111;
       axi_wdata_i       <=  32'h00000041; // configuration register 0
       
       wait (axi_wready_o);
       axi_awvalid_i   <=  1'b0; 
       if (disp_sim_log == 1) $display("---INFO : AXI Write to axi_addr:%h, Data:%h at %0t", axi_addr, axi_wdata_i, $time ) ;
       repeat (1) @(posedge a_clk_i) ;
       axi_wstrb_i     <=  4'b1111;
       axi_wdata_i       <=  32'h00004000; // configuration register 1
       wait (axi_wready_o);
       if (disp_sim_log == 1) $display("---INFO : AXI Write to axi_addr:%h, Data:%h at %0t", axi_addr, axi_wdata_i, $time ) ;
       repeat (1) @(posedge a_clk_i) ;
       axi_wstrb_i     <=  4'b1111;
       axi_wdata_i       <=  32'h00040508;
       wait (axi_wready_o);
       axi_wlast_i     <= 1;
       if (disp_sim_log == 1) $display("---INFO : AXI Write to axi_addr:%h, Data:%h at %0t", axi_addr, axi_wdata_i, $time ) ;
       repeat (1) @(posedge a_clk_i) ;
       axi_wvalid_i    <=  1'b0;
       axi_wlast_i     <= 1'b0;
       axi_wstrb_i     <=  4'b0000;
       axi_wdata_i       <=  32'h00000000;
       axi_bready_i <= 1;
       wait (axi_bvalid_o);
       repeat (1) @(posedge a_clk_i) ;
       axi_bready_i <= 0; 
    end
    endtask
    
    task axi_write_bulk_read_cmd;  
    input [31:0]      axi_addr;
    input [7:0]       axi_awlen;
    input [2:0]       axi_awsize;
    input [1:0]       axi_awburst;
    begin
       axi_awvalid_i   <=  1'b0;
       repeat (1) @(posedge a_clk_i) ;
       axi_awid_i      <= 4'b0101;        
       axi_awlen_i     <= axi_awlen;
       axi_awsize_i    <= axi_awsize;
       axi_awburst_i   <= axi_awburst;
       axi_awlock_i    <= 0;
       axi_awcache_i   <= 0;
       axi_awprot_i    <= 0;
       axi_awvalid_i   <=  1'b1;
       axi_wvalid_i    <= 0;
       
       axi_wlast_i     <= 0;
       axi_awaddr_i       <=  axi_addr; 
       repeat (1) @(posedge a_clk_i) ;
       axi_wvalid_i    <=  1'b1;  
       axi_wstrb_i     <=  4'b1111;
       axi_wdata_i       <=  32'h00000029; // configuration register 0
       
       wait (axi_wready_o);
       axi_awvalid_i   <=  1'b0; 
       if (disp_sim_log == 1) $display("---INFO : AXI Write to axi_addr:%h, Data:%h at %0t", axi_addr, axi_wdata_i, $time ) ;
       repeat (1) @(posedge a_clk_i) ;
       axi_wstrb_i     <=  4'b1111;
       axi_wdata_i       <=  32'h00004000; // configuration register 1
       wait (axi_wready_o);
       if (disp_sim_log == 1) $display("---INFO : AXI Write to axi_addr:%h, Data:%h at %0t", axi_addr, axi_wdata_i, $time ) ;
       repeat (1) @(posedge a_clk_i) ;
       axi_wstrb_i     <=  4'b1111;
       axi_wdata_i       <=  32'h00040508;
       wait (axi_wready_o);
       axi_wlast_i     <= 1;
       if (disp_sim_log == 1) $display("---INFO : AXI Write to axi_addr:%h, Data:%h at %0t", axi_addr, axi_wdata_i, $time ) ;
       repeat (1) @(posedge a_clk_i) ;
       axi_wvalid_i    <=  1'b0;
       axi_wlast_i     <= 1'b0;
       axi_wstrb_i     <=  4'b0000;
       axi_wdata_i       <=  32'h00000000;
       axi_bready_i <= 1;
       wait (axi_bvalid_o);
       repeat (1) @(posedge a_clk_i) ;
       axi_bready_i <= 0; 
    end
    endtask
    
    
    /*task axi_write_bulk2;  
    input [31:0]      axi_addr;
    input [7:0]       axi_awlen;
    input [2:0]       axi_awsize;
    input [1:0]       axi_awburst;
    begin
       axi_awvalid_i   <=  1'b0;
       repeat (1) @(posedge a_clk_i) ;
       axi_awid_i      <= 4'b0101;        
       axi_awlen_i     <= axi_awlen;
       axi_awsize_i    <= axi_awsize;
       axi_awburst_i   <= axi_awburst;
       axi_awlock_i    <= 0;
       axi_awcache_i   <= 0;
       axi_awprot_i    <= 0;
       axi_awvalid_i   <=  1'b1;
       axi_wvalid_i    <= 0;
       
       axi_wlast_i     <= 0;
       axi_awaddr_i       <=  axi_addr; 
       repeat (1) @(posedge a_clk_i) ;
       axi_wvalid_i    <=  1'b1;  
       axi_wstrb_i     <=  4'b1111;
       axi_wdata_i       <=  32'h00002029; // configuration register 0
       
       wait (axi_wready_o);
       axi_awvalid_i   <=  1'b0; 
       $display("---INFO : AXI Write to axi_addr:%h, Data:%h at %0t", axi_addr, axi_wdata_i, $time ) ;
       repeat (1) @(posedge a_clk_i) ;
       axi_wstrb_i     <=  4'b1111;
       axi_wdata_i       <=  32'h00000000; // configuration register 1
       wait (axi_wready_o);
       $display("---INFO : AXI Write to axi_addr:%h, Data:%h at %0t", axi_addr, axi_wdata_i, $time ) ;
       repeat (1) @(posedge a_clk_i) ;
       axi_wstrb_i     <=  4'b1111;
       axi_wdata_i       <=  32'h00000001;
       wait (axi_wready_o);
       axi_wlast_i     <= 1;
       $display("---INFO : AXI Write to axi_addr:%h, Data:%h at %0t", axi_addr, axi_wdata_i, $time ) ;
       repeat (1) @(posedge a_clk_i) ;
       axi_wvalid_i    <=  1'b0;
       axi_wlast_i     <= 1'b0;
       axi_wstrb_i     <=  4'b0000;
       axi_wdata_i       <=  32'h00000000;
       axi_bready_i <= 1;
       wait (axi_bvalid_o);
       repeat (1) @(posedge a_clk_i) ;
       axi_bready_i <= 0; 
    end
    endtask*/
    
    task axi_write_single;  
    input [31:0]      axi_addr;
    input [31:0]      axi_data;
    input [7:0]       axi_awlen;
    input [2:0]       axi_awsize;
    input [1:0]       axi_awburst;
    begin
       wait (a_reset_n_i);
       axi_awvalid_i   <=  1'b0;
       repeat (1) @(posedge a_clk_i) ;
       axi_awid_i      <= 4'b0101;        
       axi_awlen_i     <= axi_awlen;
       axi_awsize_i    <= axi_awsize;
       axi_awburst_i   <= axi_awburst;
       axi_awlock_i    <= 0;
       axi_awcache_i   <= 0;
       axi_awprot_i    <= 0;
       axi_awvalid_i   <=  1'b1;
       axi_wvalid_i    <= 0;
       
       axi_wlast_i     <= 0;
       axi_awaddr_i       <=  axi_addr; 
       repeat (1) @(posedge a_clk_i) ;
       axi_wvalid_i    <=  1'b1;  
       axi_wstrb_i     <=  4'b1111;
       axi_wdata_i       <= axi_data; // configuration register 0
       
       wait (axi_wready_o);
       axi_awvalid_i   <=  1'b0;
       axi_wlast_i     <= 1;
       if (disp_sim_log == 1) $display("---INFO : AXI Write to axi_addr:%h, Data:%h at %0t", axi_addr, axi_wdata_i, $time ) ;
       repeat (1) @(posedge a_clk_i) ;
       axi_wvalid_i    <=  1'b0;
       axi_wlast_i     <= 1'b0;
       axi_wstrb_i     <=  4'b0000;
       axi_wdata_i       <=  32'h00000000;
       axi_bready_i <= 1;
       wait (axi_bvalid_o);
       repeat (1) @(posedge a_clk_i) ;
       axi_bready_i <= 0;
    end
    endtask
    
    task axi_read_single;  
    input [31:0]      axi_addr;
    output [31:0]     axi_data;
    input [7:0]       axi_arlen;
    input [2:0]       axi_arsize;
    input [1:0]       axi_arburst;
    begin
       wait (a_reset_n_i);
       repeat (1) @(posedge a_clk_i) ;
       axi_arid_i      <= 4'b0101;        
       axi_arlen_i     <= axi_arlen;
       axi_arsize_i    <= axi_arsize;
       axi_arburst_i   <= axi_arburst;
       axi_arlock_i    <= 0;
       axi_arcache_i   <= 0;
       axi_arprot_i    <= 0;
       axi_arvalid_i   <=  1'b1;
       
       axi_araddr_i       <=  axi_addr;
       axi_rready_i   <=  1'b1;   
       repeat (2) @(posedge a_clk_i) ;
       axi_arvalid_i   <=  1'b0;
       wait (axi_arready_o);
       if (disp_sim_log == 1) $display("---INFO : AXI Read to axi_addr:%h at %0t", axi_addr, $time ) ;
       repeat (2) @(posedge a_clk_i) ;
       axi_arvalid_i   <=  1'b0;
       repeat (1) @(posedge a_clk_i) ;
       wait (axi_rvalid_o);
       axi_data           <= axi_rdata_o; 
       repeat (1) @(posedge a_clk_i) ;
       
    end
    endtask
    
    
    task axi_write_bulk;  
    input [31:0]      axi_addr;
    input [7:0]       axi_awlen;
    input [2:0]       axi_awsize;
    input [1:0]       axi_awburst;
    begin
       axi_awvalid_i   <=  1'b0;
       repeat (1) @(posedge a_clk_i) ;
       axi_awid_i      <= 4'b0101;        
       axi_awlen_i     <= axi_awlen;
       axi_awsize_i    <= axi_awsize;
       axi_awburst_i   <= axi_awburst;
       axi_awlock_i    <= 0;
       axi_awcache_i   <= 0;
       axi_awprot_i    <= 0;
       axi_awvalid_i   <= 1'b1;
       axi_wvalid_i    <= 0;
       
       axi_wlast_i     <= 0;
       axi_awaddr_i       <=  axi_addr; 
       repeat (1) @(posedge a_clk_i) ;
       axi_wvalid_i    <=  1'b1;  
       axi_wstrb_i     <=  4'b1111;
       axi_wdata_i       <=  32'h00000100; // configuration register 0
       
       wait (axi_wready_o);
       axi_awvalid_i   <=  1'b0; 
       if (disp_sim_log == 1) $display("---INFO : AXI Write to axi_addr:%h, Data:%h at %0t", axi_addr, axi_wdata_i, $time ) ;
       repeat (1) @(posedge a_clk_i) ;
       axi_wstrb_i     <=  4'b1111;
       axi_wdata_i       <=  32'h00000020; // configuration register 1
       wait (axi_wready_o);
       if (disp_sim_log == 1) $display("---INFO : AXI Write to axi_addr:%h, Data:%h at %0t", axi_addr, axi_wdata_i, $time ) ;
       repeat (1) @(posedge a_clk_i) ;
       axi_wstrb_i     <=  4'b1111;
       axi_wdata_i       <=  32'habcde000;
       wait (axi_wready_o);
       if (disp_sim_log == 1) $display("---INFO : AXI Write to axi_addr:%h, Data:%h at %0t", axi_addr, axi_wdata_i, $time ) ;
       repeat (1) @(posedge a_clk_i) ;
       axi_wstrb_i     <=  4'b1111;
       axi_wdata_i       <=  32'habcde001;
       wait (axi_wready_o);
       if (disp_sim_log == 1) $display("---INFO : AXI Write to axi_addr:%h, Data:%h at %0t", axi_addr, axi_wdata_i, $time ) ;
       repeat (1) @(posedge a_clk_i) ;
       axi_wstrb_i     <=  4'b1111;
       axi_wdata_i       <=  32'habcde002;
       wait (axi_wready_o);
       if (disp_sim_log == 1) $display("---INFO : AXI Write to axi_addr:%h, Data:%h at %0t", axi_addr, axi_wdata_i, $time ) ;
       repeat (1) @(posedge a_clk_i) ;
       axi_wstrb_i     <=  4'b1111;
       axi_wdata_i       <=  32'habcde003;
       wait (axi_wready_o);
       if (disp_sim_log == 1) $display("---INFO : AXI Write to axi_addr:%h, Data:%h at %0t", axi_addr, axi_wdata_i, $time ) ;
       repeat (1) @(posedge a_clk_i) ;
       axi_wstrb_i     <=  4'b1111;
       axi_wdata_i       <=  32'habcde004;
       wait (axi_wready_o);
       if (disp_sim_log == 1) $display("---INFO : AXI Write to axi_addr:%h, Data:%h at %0t", axi_addr, axi_wdata_i, $time ) ;
       repeat (1) @(posedge a_clk_i) ;
       axi_wstrb_i     <=  4'b1111;
       axi_wdata_i       <=  32'habcde005;
       wait (axi_wready_o);
       if (disp_sim_log == 1) $display("---INFO : AXI Write to axi_addr:%h, Data:%h at %0t", axi_addr, axi_wdata_i, $time ) ;
       repeat (1) @(posedge a_clk_i) ;
       axi_wstrb_i     <=  4'b1111;
       axi_wdata_i       <=  32'habcde006;
       wait (axi_wready_o);
       if (disp_sim_log == 1) $display("---INFO : AXI Write to axi_addr:%h, Data:%h at %0t", axi_addr, axi_wdata_i, $time ) ;
       repeat (1) @(posedge a_clk_i) ;
       axi_wstrb_i     <=  4'b1111;
       axi_wdata_i       <=  32'habcde007;
       wait (axi_wready_o);
       if (disp_sim_log == 1) $display("---INFO : AXI Write to axi_addr:%h, Data:%h at %0t", axi_addr, axi_wdata_i, $time ) ;
       repeat (1) @(posedge a_clk_i) ;
       axi_wstrb_i     <=  4'b1111;
       axi_wdata_i       <=  32'h00000001;
       wait (axi_wready_o);
       if (disp_sim_log == 1) $display("---INFO : AXI Write to axi_addr:%h, Data:%h at %0t", axi_addr, axi_wdata_i, $time ) ;
       repeat (1) @(posedge a_clk_i) ;
       axi_wstrb_i     <=  4'b1111;
       axi_wdata_i       <=  32'h00000400;
       wait (axi_wready_o);
       if (disp_sim_log == 1) $display("---INFO : AXI Write to axi_addr:%h, Data:%h at %0t", axi_addr, axi_wdata_i, $time ) ;
       repeat (1) @(posedge a_clk_i) ;
       axi_wstrb_i     <=  4'b1111;
       axi_wdata_i       <=  32'h00000004;
       wait (axi_wready_o);
       if (disp_sim_log == 1) $display("---INFO : AXI Write to axi_addr:%h, Data:%h at %0t", axi_addr, axi_wdata_i, $time ) ;
       repeat (1) @(posedge a_clk_i) ;
       axi_wstrb_i     <=  4'b1111;
       axi_wdata_i       <=  32'h00000800;   
       wait (axi_wready_o);
       axi_wlast_i     <= 1;
       if (disp_sim_log == 1) $display("---INFO : AXI Write to axi_addr:%h, Data:%h at %0t", axi_addr, axi_wdata_i, $time ) ;
       repeat (1) @(posedge a_clk_i) ;
       axi_wvalid_i    <=  1'b0;
       axi_wlast_i     <= 1'b0;
       axi_wstrb_i     <=  4'b0000;
       axi_wdata_i       <=  32'h00000000;
       axi_bready_i <= 1;
       wait (axi_bvalid_o);
       repeat (1) @(posedge a_clk_i) ;
       axi_bready_i <= 0; 
    end
    endtask
    
    task axi_read_bulk;  
    input [31:0]      axi_addr;
    input [7:0]       axi_arlen;
    input [2:0]       axi_arsize;
    input [1:0]       axi_arburst;
    begin
       repeat (1) @(posedge a_clk_i) ;
       axi_arid_i      <= 4'b0100;        
       axi_arlen_i     <= axi_arlen;
       axi_arsize_i    <= axi_arsize;
       axi_arburst_i   <= axi_arburst;
       axi_arlock_i    <= 0;
       axi_arcache_i   <= 0;
       axi_arprot_i    <= 0;
       axi_arvalid_i   <= 1'b1;
       
       axi_araddr_i       <=  axi_addr;
       axi_rready_i   <=  1'b1;   
       repeat (2) @(posedge a_clk_i) ;
       axi_arvalid_i   <=  1'b0;
       wait (axi_arready_o);
       if (disp_sim_log == 1) $display("---INFO : AXI Write to axi_addr:%h, Data:%h at %0t", axi_addr, axi_wdata_i, $time ) ;
       repeat (2) @(posedge a_clk_i) ;
       axi_arvalid_i   <=  1'b0;
    end
    endtask
    
    task write_to_intf; 
    input [31:0]      addr_32b;
    input [31:0]      wr_data_32b;	
	    begin
	    	if(ENABLE_OPTION_AXI4L_FOR_REGISTER_ACCESS == 1) begin
	    	    axilite_write(addr_32b, wr_data_32b);
	    	end
	    	else begin
	    	    if(INTERFACE==0) begin
	    	        ahbl_write(addr_32b, wr_data_32b);
	    		end
	    		else begin
	    		    axi_write_single(addr_32b, wr_data_32b, 8'h00, 3'b010, 2'b00);
	    		end
	    	end
	    end
	endtask
	
	task direct_write_to_intf; 
    input [31:0]      addr_32b;
    input [31:0]      wr_data_32b;	
	    begin
	    	if(INTERFACE==0) begin
	    	    ahbl_write(addr_32b, wr_data_32b);
	    	end
	    	else begin
	    	    axi_write_single(addr_32b, wr_data_32b, 8'h00, 3'b010, 2'b00);
	    	end
	    end
	endtask
	
    task read_from_intf; 
    input [31:0]      addr_32b;
    output [31:0]     rd_data_32b;	
	    begin
	    	if(ENABLE_OPTION_AXI4L_FOR_REGISTER_ACCESS == 1) begin
	    	    axilite_read(addr_32b, rd_data_32b);
	    	end
	    	else begin
	    	    if(INTERFACE==0) begin
	    	        ahbl_read(addr_32b, rd_data_32b);
	    		end
	    		else begin
	    		    axi_read_single(addr_32b, rd_data_32b, 8'h00, 3'b010, 2'b00);
	    		end
	    	end
	    end
	endtask
	
    task direct_read_from_intf; 
    input [31:0]      addr_32b;
    output [31:0]     rd_data_32b;	
	    begin
	    	if(INTERFACE==0) begin
	    	    ahbl_read(addr_32b, rd_data_32b);
	    	end
	    	else begin
	    	    axi_read_single(addr_32b, rd_data_32b, 8'h00, 3'b010, 2'b00);
	    	end
	    end
	endtask
	
	task do_data_compare;
        input [31:0]                   p_exe_data_32b                   ; // Expected data 
        input [31:0]                   p_got_data_32b                   ; // Got data 
    
        //Compare Address
        if (p_exe_data_32b === p_got_data_32b) begin
		  $write("# ---INFO : @%0dns :: Data expected 0x%x, Got 0x%x\n", $time, p_exe_data_32b,p_got_data_32b);
        end else begin
          process_err();
		  $write("# ---ERROR : @%0dns :: Data expected 0x%x, Got 0x%x\n", $time, p_exe_data_32b,p_got_data_32b);
        end
    
    endtask
	
	
    task process_err;
      begin
        errs_i                         = errs_i + 1;
        //3---------------------------------------------------------------------------------------------
        // Check if finish was passed 
        //3---------------------------------------------------------------------------------------------
        if (finish_on_error_b == 1) begin
          $finish(1);
        end
      end
    endtask
	
	
    task post_process;
      begin
        $write("# ---INFO : @%0dns :: #####################################################################\n",
          $time);
        $write("# ---INFO : @%0dns ::               Errors   detected in CHECKER %4d\n",$time,errs_i);
        //$write("# ---MSG : @%0dns %m() ::               Number of Transactions       %4d\n",$time,trans_i);
        $write("# ---INFO : @%0dns :: #####################################################################\n",
          $time);
        //3---------------------------------------------------------------------------------------------
        // Declare pass of fail based on sim status 
        //3---------------------------------------------------------------------------------------------
        //if (errs_i == 0 && trans_i != 0) begin
        if (errs_i == 0) begin
          $write("# ---INFO : @%0dns ::                       SIMULATION PASSED\n",$time);
        //3---------------------------------------------------------------------------------------------
        // If sim error is set, then there was simulation error 
        //3---------------------------------------------------------------------------------------------
        end else begin
          $write("# ---INFO : @%0dns ::                       SIMULATION FAILED\n",$time);
        end
        $write("# ---INFO : @%0dns :: #####################################################################\n",
          $time);
      end
    endtask

	// Test Sequence Starts Here
	
	// Read Default Register Test
	task read_default_register_test;
        reg [31:0] rd_data_32b;
        reg [31:0] rd_data_2d_32b      [1023:0];
        reg [31:0] def_rd_data_2d_32b  [1023:0];
        integer m_i_i;
		begin
            $display("\n---INFO : Read Default Register Test at %0t", $time ) ;
	        // For Default Read Value for Each register
	        def_rd_data_2d_32b[32'h00000000] = {32'h00000000};
			if (ENABLE_FLASH_ADDRESS_MAPPING == 0) begin 
	            def_rd_data_2d_32b[32'h00000004] = {16'h0,
													2'b0,DATA_ENDIANNESS[0],SPI_CLOCK_FREQUENCY_DIVIDER[4:0] >> 1,5'h0,
													SPI_CLOCK_PHASE[0],SPI_CLOCK_POLARITY[0],FIRST_TRANSMITTED_BIT[0]};
			end
			else begin
			    def_rd_data_2d_32b[32'h00000004] = {DATA_LANE_WIDTH[1:0],ADDRESS_LANE_WIDTH[1:0],COMMAND_LANE_WIDTH[1:0],
				                                    FLASH_ADDRESS_WIDTH[0],DUMMY_CLOCK_CYCLES[2:0],READ_ACCESS[2:0],WRITE_ACCESS[2:0],
													2'b0,DATA_ENDIANNESS[0],SPI_CLOCK_FREQUENCY_DIVIDER[4:0] >> 1,5'h0,
													SPI_CLOCK_PHASE[0],SPI_CLOCK_POLARITY[0],FIRST_TRANSMITTED_BIT[0]};
			end
	        def_rd_data_2d_32b[32'h00000008] = {32'h00000000};
	        def_rd_data_2d_32b[32'h0000000C] = {READ_STATUS_REGISTER_1,READ_STATUS_REGISTER_2,
			                                    READ_STATUS_REGISTER_3,READ_CONFIGURATION_REGISTER};
	        def_rd_data_2d_32b[32'h00000010] = {READ_ID,READ_ELECTRONIC_ID,
			                                    MULTIPLE_IO_READ_ID,READ_MANUFACTURER_AND_DEVICE_ID};
	        def_rd_data_2d_32b[32'h00000014] = {READ_MANUFACTURER_AND_DEVICE_ID_DUAL_IO,READ_MANUFACTURER_AND_DEVICE_ID_QUAD_IO,
			                                    READ_DATA,FAST_READ};
	        def_rd_data_2d_32b[32'h00000018] = {DUAL_OUTPUT_FAST_READ,DUAL_INPUT_OUTPUT_FAST_READ,
			                                    QUAD_OUTPUT_FAST_READ,QUAD_INPUT_OUTPUT_FAST_READ};
	        def_rd_data_2d_32b[32'h0000001C] = {BLOCK_ERASE_TYPE1,BLOCK_ERASE_TYPE2, BLOCK_ERASE_TYPE3,CHIP_ERASE};
	        def_rd_data_2d_32b[32'h00000020] = {WRITE_ENABLE,WRITE_DISABLE,WRITE_STATUS_CONFIGURATION_REGISTER,PAGE_PROGRAM};
	        def_rd_data_2d_32b[32'h00000024] = {DUAL_INPUT_FAST_PROGRAM,EXTENDED_DUAL_INPUT_FAST_PROGRAM,
			                                    QUAD_INPUT_FAST_PROGRAM,EXTENDED_QUAD_INPUT_FAST_PROGRAM};
	        def_rd_data_2d_32b[32'h00000028] = {ENTER_4_BYTE_ADDRESS_MODE,EXIT_4_BYTE_ADDRESS_MODE,
			                                    ENTER_QUAD_INPUT_OUTPUT_MODE,RESET_QUAD_INPUT_OUTPUT_MODE};
		    if (ENABLE_FLASH_ADDRESS_MAPPING == 0) begin
	            def_rd_data_2d_32b[32'h0000002C] = {32'h00000000};
	            def_rd_data_2d_32b[32'h00000030] = {32'h00000000};
	            def_rd_data_2d_32b[32'h00000034] = {32'h00000000};
	            def_rd_data_2d_32b[32'h00000038] = {32'h00000000};
		    end
		    else begin // different default value when flash addressing mapping is enabled
	            def_rd_data_2d_32b[32'h0000002C] = MINIMUM_FLASH_ADDRESS_ALIGNMENT;
	            def_rd_data_2d_32b[32'h00000030] = STARTING_OFFSET_ADDRESS;
	            def_rd_data_2d_32b[32'h00000034] = FLASH_MEMORY_MAP_SIZE;
	            def_rd_data_2d_32b[32'h00000038] = AXI_ADDRESS_MAP;
		    end
			
		    for (m_i_i = 32'h00000003C; m_i_i < 32'h00000100; m_i_i = m_i_i + 32'h00000004) begin
	            def_rd_data_2d_32b[m_i_i] = 32'h0;
			end
			
	        def_rd_data_2d_32b[32'h00000100] = {32'h00000000};
		    
		    // different default value when FIFO is enabled or disabled
		    if (ENABLE_TRANSMIT_FIFO == 0 & ENABLE_RECEIVE_FIFO == 0) begin
	            def_rd_data_2d_32b[32'h00000104] = {32'h00000003};    
		    end
		    else if  (ENABLE_TRANSMIT_FIFO == 1 & ENABLE_RECEIVE_FIFO == 0) begin
	            def_rd_data_2d_32b[32'h00000104] = {32'h00000001};    
		    end
		    else if  (ENABLE_TRANSMIT_FIFO == 0 & ENABLE_RECEIVE_FIFO == 1) begin
	            def_rd_data_2d_32b[32'h00000104] = {32'h00000013};    
		    end
		    else begin // Both Transmit and Receive FIFO are enabled
	            def_rd_data_2d_32b[32'h00000104] = {32'h00000011};  
		    end
		    
	        def_rd_data_2d_32b[32'h00000108] = {32'h00000000};     
	        def_rd_data_2d_32b[32'h0000010C] = {32'h00000000}; 
	        def_rd_data_2d_32b[32'h00000110] = {32'h00000000};
	        def_rd_data_2d_32b[32'h00000114] = {32'h00000000};
			
		    for (m_i_i = 32'h000000108; m_i_i < 32'h00000200; m_i_i = m_i_i + 32'h00000004) begin
	            def_rd_data_2d_32b[m_i_i] = 32'h0;
			end
		    
	        def_rd_data_2d_32b[32'h00000200] = {32'h00000000};
	        def_rd_data_2d_32b[32'h00000204] = {32'h00000000};
	        def_rd_data_2d_32b[32'h00000208] = {32'h00000000};
	        def_rd_data_2d_32b[32'h0000020C] = {32'h00000000};
	        def_rd_data_2d_32b[32'h00000210] = {32'h00000000};
	        def_rd_data_2d_32b[32'h00000214] = {32'h00000000};
	        def_rd_data_2d_32b[32'h00000218] = {32'h00000000};
	        def_rd_data_2d_32b[32'h0000021C] = {32'h00000000};
	        def_rd_data_2d_32b[32'h00000220] = {32'h00000000};
	        def_rd_data_2d_32b[32'h00000224] = {32'h00000000};
			
		    for (m_i_i = 32'h000000228; m_i_i < 32'h00000304; m_i_i = m_i_i + 32'h00000004) begin
	            def_rd_data_2d_32b[m_i_i] = 32'h0;
			end
	        
            #12000; // wait for a_reset_n_i assertion
			#1000;
			// Reading Default Values of Configuration Registers
		    for (m_i_i = 32'h00000000; m_i_i < 32'h00000304; m_i_i = m_i_i + 32'h00000004) begin
                read_from_intf(m_i_i, rd_data_32b);
		    	rd_data_2d_32b[m_i_i] = rd_data_32b;
                $display("---INFO : Read default register value of address 0x%x at %0t", m_i_i, $time );
		    	do_data_compare(def_rd_data_2d_32b[m_i_i], rd_data_2d_32b[m_i_i]);
		    end
			
			
			/*
			// Reading Default Values of Configuration Registers
		    //for (m_i_i = 32'h00000000; m_i_i < 32'h0000003C; m_i_i = m_i_i + 32'h00000004) begin
		    for (m_i_i = 32'h00000001; m_i_i < 32'h0000003C; m_i_i = m_i_i + 32'h00000004) begin
                read_from_intf(m_i_i, rd_data_32b);
		    	rd_data_2d_32b[m_i_i] = rd_data_32b;
		    	do_data_compare(def_rd_data_2d_32b[m_i_i], rd_data_2d_32b[m_i_i]);
				//#100;
		    end
		    //Reading Default Values of Status and Interrupt Registers
		    for (m_i_i = 32'h00000100; m_i_i < 32'h00000118; m_i_i = m_i_i + 32'h00000004) begin
                read_from_intf(m_i_i, rd_data_32b);
		    	rd_data_2d_32b[m_i_i] = rd_data_32b;
		    	do_data_compare(def_rd_data_2d_32b[m_i_i], rd_data_2d_32b[m_i_i]);
				//#100;
		    end
			*/
			/*
		    // Reading Default Values of Control Registers
		    //for (m_i_i = 32'h00000200; m_i_i < 32'h00000228; m_i_i = m_i_i + 32'h00000004) begin
			if (ENABLE_OPTION_AXI4L_FOR_REGISTER_ACCESS == 0) begin
                read_from_intf(32'h00000200, rd_data_32b);
		    	rd_data_2d_32b[32'h00000200] = rd_data_32b;
		    	do_data_compare(def_rd_data_2d_32b[32'h00000200], rd_data_2d_32b[m_i_i]);
			end
			else begin
			   if (INTERFACE == 0) begin
                    ahbl_read(32'h00000200, rd_data_32b);
		    	    rd_data_2d_32b[32'h00000200] = rd_data_32b;
		    	    do_data_compare(def_rd_data_2d_32b[32'h00000200], rd_data_2d_32b[m_i_i]);
			   end
			   else begin
                    axi_read_single(32'h00000200, rd_data_32b, 8'h00, 3'b10, 2'b00);
		    	    rd_data_2d_32b[32'h00000200] = rd_data_32b;
		    	    do_data_compare(def_rd_data_2d_32b[32'h00000200], rd_data_2d_32b[m_i_i]);
			   end
			end
			
		    for (m_i_i = 32'h00000204; m_i_i < 32'h00000228; m_i_i = m_i_i + 32'h00000004) begin
                read_from_intf(m_i_i, rd_data_32b);
		    	rd_data_2d_32b[m_i_i] = rd_data_32b;
		    	do_data_compare(def_rd_data_2d_32b[m_i_i], rd_data_2d_32b[m_i_i]);
				//#100;
		    end*/
		end
	endtask
	
	// Write-Read Register Test
	task write_read_register_test;
        reg [31:0] rd_data_32b;
        reg [31:0] wr_data_32b;
        reg [31:0] rd_data_2d_32b      [1023:0];
        reg [31:0] mask_data_2d_32b    [1023:0];
        integer m_i_i;
		begin
            $display("\n---INFO : Write then Read  Register Test at %0t ", $time ) ;
	        // For Default Read Value for Each register
	        mask_data_2d_32b[32'h00000000] = {32'h00000000};
		    if (ENABLE_FLASH_ADDRESS_MAPPING == 0) begin
	            mask_data_2d_32b[32'h00000004] = {16'h0, 16'hBF07};
			end
			else begin
	            mask_data_2d_32b[32'h00000004] = {16'hFFFF, 16'hBF07};
			end
	        mask_data_2d_32b[32'h00000008] = {32'hFFFFFFFF};
	        mask_data_2d_32b[32'h0000000C] = {32'hFFFFFFFF};
	        mask_data_2d_32b[32'h00000010] = {32'hFFFFFFFF};
	        mask_data_2d_32b[32'h00000014] = {32'hFFFFFFFF};
	        mask_data_2d_32b[32'h00000018] = {32'hFFFFFFFF};
	        mask_data_2d_32b[32'h0000001C] = {32'hFFFFFFFF};
	        mask_data_2d_32b[32'h00000020] = {32'hFFFFFFFF};
	        mask_data_2d_32b[32'h00000024] = {32'hFFFFFFFF};
	        mask_data_2d_32b[32'h00000028] = {32'hFFFFFFFF};
		    if (ENABLE_FLASH_ADDRESS_MAPPING == 0) begin
	            mask_data_2d_32b[32'h0000002C] = {32'h00000000};
	            mask_data_2d_32b[32'h00000030] = {32'h00000000};
	            mask_data_2d_32b[32'h00000034] = {32'h00000000};
	            mask_data_2d_32b[32'h00000038] = {32'h00000000};
		    end
		    else begin // different default value when flash addressing mapping is enabled
	            mask_data_2d_32b[32'h0000002C] = {32'hFFFFFFFF};
	            mask_data_2d_32b[32'h00000030] = {32'hFFFFFFFF};
	            mask_data_2d_32b[32'h00000034] = {32'hFFFFFFFF};
	            mask_data_2d_32b[32'h00000038] = {32'hFFFFFFFF};
		    end
			
		    for (m_i_i = 32'h00000003C; m_i_i < 32'h00000100; m_i_i = m_i_i + 32'h00000004) begin
	            mask_data_2d_32b[m_i_i] = 32'h0;
			end
			
	        mask_data_2d_32b[32'h00000100] = {32'h00000000};
		    
		    // different default value when FIFO is enabled or disabled
		    if (ENABLE_TRANSMIT_FIFO == 0 & ENABLE_RECEIVE_FIFO == 0) begin
	            //mask_data_2d_32b[32'h00000104] = {32'h00000333};   
	            mask_data_2d_32b[32'h00000104] = {32'h00000000};   
	            mask_data_2d_32b[32'h00000108] = {32'h00000333}; 
	            mask_data_2d_32b[32'h0000010C] = {32'h00000333}; 
		    end
		    else if  (ENABLE_TRANSMIT_FIFO == 1 & ENABLE_RECEIVE_FIFO == 0) begin
	            //mask_data_2d_32b[32'h00000104] = {32'h0000033F}; 
	            mask_data_2d_32b[32'h00000104] = {32'h00000000};   
	            mask_data_2d_32b[32'h00000108] = {32'h0000033F}; 
	            mask_data_2d_32b[32'h0000010C] = {32'h0000033F}; 
		    end
		    else if  (ENABLE_TRANSMIT_FIFO == 0 & ENABLE_RECEIVE_FIFO == 1) begin
	            //mask_data_2d_32b[32'h00000104] = {32'h000003F3};  
	            mask_data_2d_32b[32'h00000104] = {32'h00000000};   
	            mask_data_2d_32b[32'h00000108] = {32'h000003F3}; 
	            mask_data_2d_32b[32'h0000010C] = {32'h000003F3}; 
		    end
		    else begin // Both Transmit and Receive FIFO are enabled
	            //mask_data_2d_32b[32'h00000104] = {32'h000003FF}; 
	            mask_data_2d_32b[32'h00000104] = {32'h00000000};    
	            mask_data_2d_32b[32'h00000108] = {32'h000003FF}; 
	            mask_data_2d_32b[32'h0000010C] = {32'h000003FF}; 
		    end
		        
	        mask_data_2d_32b[32'h00000110] = {32'h00000000};
	        mask_data_2d_32b[32'h00000114] = {32'h00000000};
			
		    for (m_i_i = 32'h000000118; m_i_i < 32'h00000200; m_i_i = m_i_i + 32'h00000004) begin
	            mask_data_2d_32b[m_i_i] = 32'h0;
			end
		    
	        mask_data_2d_32b[32'h00000200] = {32'h00000000};
	        mask_data_2d_32b[32'h00000204] = {32'h00000000};
	        mask_data_2d_32b[32'h00000208] = {32'hFFFFFFFF};
	        mask_data_2d_32b[32'h0000020C] = {32'h0000FF3F};
	        mask_data_2d_32b[32'h00000210] = {32'hFFFFFFFF};
	        mask_data_2d_32b[32'h00000214] = {32'hFFFFFFFF};
	        mask_data_2d_32b[32'h00000218] = {32'h00000000};
	        mask_data_2d_32b[32'h0000021C] = {32'h00000000};
	        mask_data_2d_32b[32'h00000220] = {32'h00000003};
	        mask_data_2d_32b[32'h00000224] = {32'h00000001};
			
		    for (m_i_i = 32'h000000228; m_i_i < 32'h00000304; m_i_i = m_i_i + 32'h00000004) begin
	            mask_data_2d_32b[m_i_i] = 32'h0;
			end
			
            #12000; // wait for a_reset_n_i assertion
			#1000;
		    // Writing then Reading Values of Configuration Registers
		    for (m_i_i = 32'h00000000; m_i_i < 32'h00000304; m_i_i = m_i_i + 32'h00000004) begin
			    write_to_intf(m_i_i, 32'hFFFFFFFF);
				//#100;
                read_from_intf(m_i_i, rd_data_32b);
				//#100;
		    	rd_data_2d_32b[m_i_i] = rd_data_32b;
                $display("---INFO : Read register value of address 0x%x at %0t", m_i_i, $time );
		    	do_data_compare((32'hFFFFFFFF & mask_data_2d_32b[m_i_i][31:0]), rd_data_2d_32b[m_i_i]);
		    end
			
			/*
		    for (m_i_i = 32'h00000000; m_i_i < 32'h0000003C; m_i_i = m_i_i + 32'h00000004) begin
                //read_from_intf(m_i_i, rd_data_32b);
			    write_to_intf(m_i_i, 32'hFFFFFFFF);
				#100;
                read_from_intf(m_i_i, rd_data_32b);
				#100;
		    	rd_data_2d_32b[m_i_i] = rd_data_32b;
		    	do_data_compare((32'hFFFFFFFF & mask_data_2d_32b[m_i_i][31:0]), rd_data_2d_32b[m_i_i]);
		    end
		    /// Writing then Reading Values of of Status and Interrupt Registers
		    for (m_i_i = 32'h00000100; m_i_i < 32'h00000118; m_i_i = m_i_i + 32'h00000004) begin
                //read_from_intf(m_i_i, rd_data_32b);
			    write_to_intf(m_i_i, 32'hFFFFFFFF);
				#100;
                read_from_intf(m_i_i, rd_data_32b);
				#100;
		    	rd_data_2d_32b[m_i_i] = rd_data_32b;
		    	do_data_compare((32'hFFFFFFFF & mask_data_2d_32b[m_i_i][31:0]), rd_data_2d_32b[m_i_i]);
		    end
		    // Writing then Reading Values of Control Registers
		    for (m_i_i = 32'h00000200; m_i_i < 32'h00000228; m_i_i = m_i_i + 32'h00000004) begin
                //read_from_intf(m_i_i, rd_data_32b);
				if (m_i_i == 32'h00000220) begin
			        write_to_intf(m_i_i, 32'hFFFFFFFE);
				    #100;
                    read_from_intf(m_i_i, rd_data_32b);
				    #100;
				end
				else begin
			        write_to_intf(m_i_i, 32'hFFFFFFFF);
				    #100;
                    read_from_intf(m_i_i, rd_data_32b);
				    #100;
		    	    rd_data_2d_32b[m_i_i] = rd_data_32b;
		    	    do_data_compare((32'hFFFFFFFF & mask_data_2d_32b[m_i_i][31:0]), rd_data_2d_32b[m_i_i]);
				end
		    end*/
		end
	endtask
	
	// Sclk Rate Register Test
	task supported_commands_test_send_command_sclk_rate_test;
        reg [31:0] addr_32b;
        reg [31:0] wr_data_32b;
		reg [31:0] rd_data_32b;
		integer m_i_i;
		
		//QSPI_CONFIG_REG_0_REG_ADDR
		reg [31:0] qspi_config_0_wr_data;
		reg en_frame_end_done_cntr;
        reg en_flash_address_space_map;
        reg data_endianness;                        
        reg [4:0] sck_rate;
		reg chip_select_behaviour;                  
        reg [2:0] min_idle_time;  
        reg en_back_to_back_trans;		
        reg cpha;                                   
        reg cpol;                                   
        reg first_bit_transfer;
		
		//PACKET_HEADER_0
		reg [31:0] packet_header_0_wr_data;
		reg [15:0] xfer_len_bytes; 
		reg [7:0] num_wait_state;  
		reg multiple_flash_target; 
		reg [4:0] flash_cmd_code;  
		reg with_payload;          
		reg sup_flash_cmd;  

		//PACKET_HEADER_1
		reg [31:0] packet_header_1_wr_data;
        reg [2:0] flash_addr_width;
        reg [4:0] tgt_cs;          
        reg [1:0] data_lane_width; 
        reg [1:0] addr_lane_width; 
        reg [1:0] cmd_lane_width;  		
		
	    begin
		// Write Only
		// Send write commands without payload, then read back the command sent
		    // flash_command_code == 5'h14 // Write Enable
		    // flash_command_code == 5'h15 // Write Disable
		    // flash_command_code == 5'h1E // Enter Quad Input/Output Mode
		    // flash_command_code == 5'h1F // Reset Quad Input/Output Mode
		    // flash_command_code == 5'h1C // Enter 4-Byte Address Mode
		    // flash_command_code == 5'h1D // Exit 4-Byte Address Mode
            #12000;
			#1000;
		    for (m_i_i = 32'h00000000; m_i_i < 32'h00000020; m_i_i = m_i_i + 32'h00000001) begin	
		        // Write to config0 - Configuration Register
		        en_frame_end_done_cntr     = 1'h0;
                en_flash_address_space_map = 1'h0;
                data_endianness            = 1'h0;                        
                sck_rate                   = m_i_i[4:0];
		        chip_select_behaviour      = 1'h0;                  
                min_idle_time              = 3'h0;  
                en_back_to_back_trans      = 1'h0;		
                cpha                       = 1'h1;                                   
                cpol                       = 1'h1;                                   
                first_bit_transfer         = 1'h0;
				addr_32b = QSPI_CONFIG_REG_0_REG_ADDR;
				qspi_config_0_wr_data = {16'b0, en_frame_end_done_cntr, en_flash_address_space_map, 
				                         data_endianness, sck_rate, chip_select_behaviour, min_idle_time, 
										 en_back_to_back_trans, cpha, cpol, first_bit_transfer};
				wr_data_32b = qspi_config_0_wr_data;
				#100;
		    	write_to_intf(addr_32b, wr_data_32b);
		        #30;
				read_from_intf(QSPI_CONFIG_REG_0_REG_ADDR, rd_data_32b);
		        // Write to pkt_header_0 - supported flash command
		        xfer_len_bytes        = 16'h0;
		        num_wait_state        = 8'h0;
		        multiple_flash_target = 1'h0;
		        flash_cmd_code        = 5'h14;
		        with_payload          = 1'h0; 
		        sup_flash_cmd         = 1'h1; 
		        addr_32b = PACKET_HEADER_0_REG_ADDR;
		        packet_header_0_wr_data = {xfer_len_bytes, num_wait_state, multiple_flash_target, flash_cmd_code, with_payload, sup_flash_cmd};
		        wr_data_32b = packet_header_0_wr_data;
		        #100;
		    	write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_1
		        //flash_addr_width      = 3'b010; // 24-bit address
		        flash_addr_width      = 3'b000; // 24-bit address
		        //tgt_cs                = 5'h1;          
		        tgt_cs                = 5'h0;          
		        data_lane_width       = 2'b00;  // Standard SPI
		        addr_lane_width       = 2'b00;  // Standard SPI
		        cmd_lane_width        = 2'b00;  // Standard SPI 
		        packet_header_1_wr_data = {16'h0, flash_addr_width, tgt_cs, 2'h0, data_lane_width, addr_lane_width, cmd_lane_width};
		        addr_32b    = PACKET_HEADER_1_REG_ADDR;
		        wr_data_32b = packet_header_1_wr_data;
		        #100;
		        write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_2 and pkt_header_3
		        addr_32b    = PACKET_HEADER_2_REG_ADDR;
		        wr_data_32b = 32'h0;
		        #100;
		        write_to_intf(addr_32b, wr_data_32b);
		        addr_32b    = PACKET_HEADER_3_REG_ADDR;
		        wr_data_32b = 32'h0;
		        #100;
		        write_to_intf(addr_32b, wr_data_32b);
		        // Start transaction
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000001;
		        #100;
		        write_to_intf(addr_32b, wr_data_32b);
		        // Read TRANSACTION_STATUS
		        #100;
		        read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
		        //while (rd_data_32b[0] == 1) begin
		        //    read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
		        //    #100;
		        //end
		        // Start transaction
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000000;
		        #100;
		        write_to_intf(addr_32b, wr_data_32b);
		        #((1000*sck_rate)+2000);
		    end
	    end
	endtask
	
	// Clock Register Test
	task supported_commands_test_send_command_clk_mode_test;
        reg [31:0] addr_32b;
        reg [31:0] wr_data_32b;
		reg [31:0] rd_data_32b;
		integer m_i_i;
		
		//QSPI_CONFIG_REG_0_REG_ADDR
		reg [31:0] qspi_config_0_wr_data;
		reg en_frame_end_done_cntr;
        reg en_flash_address_space_map;
        reg data_endianness;                        
        reg [4:0] sck_rate;
		reg chip_select_behaviour;                  
        reg [2:0] min_idle_time;  
        reg en_back_to_back_trans;		
        reg cpha;                                   
        reg cpol;                                   
        reg first_bit_transfer;
		
		//PACKET_HEADER_0
		reg [31:0] packet_header_0_wr_data;
		reg [15:0] xfer_len_bytes; 
		reg [7:0] num_wait_state;  
		reg multiple_flash_target; 
		reg [4:0] flash_cmd_code;  
		reg with_payload;          
		reg sup_flash_cmd;  

		//PACKET_HEADER_1
		reg [31:0] packet_header_1_wr_data;
        reg [2:0] flash_addr_width;
        reg [4:0] tgt_cs;          
        reg [1:0] data_lane_width; 
        reg [1:0] addr_lane_width; 
        reg [1:0] cmd_lane_width;  		
		
	    begin
		// Write Only
		// Send write commands without payload, then read back the command sent
		    // flash_command_code == 5'h14 // Write Enable
		    // flash_command_code == 5'h15 // Write Disable
		    // flash_command_code == 5'h1E // Enter Quad Input/Output Mode
		    // flash_command_code == 5'h1F // Reset Quad Input/Output Mode
		    // flash_command_code == 5'h1C // Enter 4-Byte Address Mode
		    // flash_command_code == 5'h1D // Exit 4-Byte Address Mode
		    //for (m_i_i = 32'h00000000; m_i_i < 32'h00000002; m_i_i = m_i_i + 32'h00000001) begin	
		        // Write to config0 - Configuration Register - Clock Mode 3
		        en_frame_end_done_cntr     = 1'h0;
                en_flash_address_space_map = 1'h0;
                data_endianness            = 1'h0;                        
                sck_rate                   = 5'h02;
		        chip_select_behaviour      = 1'h0;                  
                min_idle_time              = 3'h0;  
                en_back_to_back_trans      = 1'h0;		
                cpha                       = 1'h1;                                   
                cpol                       = 1'h1;                                   
                first_bit_transfer         = 1'h0;
				addr_32b = QSPI_CONFIG_REG_0_REG_ADDR;
				qspi_config_0_wr_data = {16'b0, en_frame_end_done_cntr, en_flash_address_space_map, 
				                         data_endianness, sck_rate, chip_select_behaviour, min_idle_time, 
										 en_back_to_back_trans, cpha, cpol, first_bit_transfer};
				wr_data_32b = qspi_config_0_wr_data;
				#100;
		    	write_to_intf(addr_32b, wr_data_32b);
				#1000;
		    	write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_0 - supported flash command
		        xfer_len_bytes        = 16'h0;
		        num_wait_state        = 8'h0;
		        multiple_flash_target = 1'h0;
		        flash_cmd_code        = 5'h14;
		        with_payload          = 1'h0; 
		        sup_flash_cmd         = 1'h1; 
		        addr_32b = PACKET_HEADER_0_REG_ADDR;
		        packet_header_0_wr_data = {xfer_len_bytes, num_wait_state, multiple_flash_target, flash_cmd_code, with_payload, sup_flash_cmd};
		        wr_data_32b = packet_header_0_wr_data;
		        #100;
		    	write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_1
		        //flash_addr_width      = 3'b010; // 24-bit address
		        flash_addr_width      = 3'b000; // 24-bit address
		        //tgt_cs                = 5'h1;          
		        tgt_cs                = 5'h0;          
		        data_lane_width       = 2'b00;  // Standard SPI
		        addr_lane_width       = 2'b00;  // Standard SPI
		        cmd_lane_width        = 2'b00;  // Standard SPI 
		        packet_header_1_wr_data = {16'h0, flash_addr_width, tgt_cs, 2'h0, data_lane_width, addr_lane_width, cmd_lane_width};
		        addr_32b    = PACKET_HEADER_1_REG_ADDR;
		        wr_data_32b = packet_header_1_wr_data;
		        #100;
		        write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_2 and pkt_header_3
		        addr_32b    = PACKET_HEADER_2_REG_ADDR;
		        wr_data_32b = 32'h0;
		        #100;
		        write_to_intf(addr_32b, wr_data_32b);
		        addr_32b    = PACKET_HEADER_3_REG_ADDR;
		        wr_data_32b = 32'h0;
		        #100;
		        write_to_intf(addr_32b, wr_data_32b);
		        // Start transaction
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000001;
		        #100;
		        write_to_intf(addr_32b, wr_data_32b);
		        // Read TRANSACTION_STATUS
		        #100;
		        read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
		        //while (rd_data_32b[0] == 1) begin
		        //    read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
		        //    #100;
		        //end
		        // Start transaction
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000000;
		        #100;
		        write_to_intf(addr_32b, wr_data_32b);
		        #1000;
		        // Write to config0 - Configuration Register - Clock Mode 0
		        en_frame_end_done_cntr     = 1'h0;
                en_flash_address_space_map = 1'h0;
                data_endianness            = 1'h0;                        
                sck_rate                   = 5'h02;
		        chip_select_behaviour      = 1'h0;                  
                min_idle_time              = 3'h0;  
                en_back_to_back_trans      = 1'h0;		
                cpha                       = 1'h0;                                   
                cpol                       = 1'h0;                                   
                first_bit_transfer         = 1'h0;
				addr_32b = QSPI_CONFIG_REG_0_REG_ADDR;
				qspi_config_0_wr_data = {16'b0, en_frame_end_done_cntr, en_flash_address_space_map, 
				                         data_endianness, sck_rate, chip_select_behaviour, min_idle_time, 
										 en_back_to_back_trans, cpha, cpol, first_bit_transfer};
				wr_data_32b = qspi_config_0_wr_data;
				#100;
		    	write_to_intf(addr_32b, wr_data_32b);
				#1000;
		    	write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_0 - supported flash command
		        xfer_len_bytes        = 16'h0;
		        num_wait_state        = 8'h0;
		        multiple_flash_target = 1'h0;
		        flash_cmd_code        = 5'h14;
		        with_payload          = 1'h0; 
		        sup_flash_cmd         = 1'h1; 
		        addr_32b = PACKET_HEADER_0_REG_ADDR;
		        packet_header_0_wr_data = {xfer_len_bytes, num_wait_state, multiple_flash_target, flash_cmd_code, with_payload, sup_flash_cmd};
		        wr_data_32b = packet_header_0_wr_data;
		        #100;
		    	write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_1
		        //flash_addr_width      = 3'b010; // 24-bit address
		        flash_addr_width      = 3'b000; // 24-bit address
		        //tgt_cs                = 5'h1;          
		        tgt_cs                = 5'h0;          
		        data_lane_width       = 2'b00;  // Standard SPI
		        addr_lane_width       = 2'b00;  // Standard SPI
		        cmd_lane_width        = 2'b00;  // Standard SPI 
		        packet_header_1_wr_data = {16'h0, flash_addr_width, tgt_cs, 2'h0, data_lane_width, addr_lane_width, cmd_lane_width};
		        addr_32b    = PACKET_HEADER_1_REG_ADDR;
		        wr_data_32b = packet_header_1_wr_data;
		        #100;
		        write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_2 and pkt_header_3
		        addr_32b    = PACKET_HEADER_2_REG_ADDR;
		        wr_data_32b = 32'h0;
		        #100;
		        write_to_intf(addr_32b, wr_data_32b);
		        addr_32b    = PACKET_HEADER_3_REG_ADDR;
		        wr_data_32b = 32'h0;
		        #100;
		        write_to_intf(addr_32b, wr_data_32b);
		        // Start transaction
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000001;
		        #100;
		        write_to_intf(addr_32b, wr_data_32b);
		        // Read TRANSACTION_STATUS
		        #100;
		        read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
		        //while (rd_data_32b[0] == 1) begin
		        //    read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
		        //    #100;
		        //end
		        // Start transaction
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000000;
		        #100;
		        write_to_intf(addr_32b, wr_data_32b);
		        #1000;
		        // Write to config0 - Configuration Register - Clock Mode 1
		        en_frame_end_done_cntr     = 1'h0;
                en_flash_address_space_map = 1'h0;
                data_endianness            = 1'h0;                        
                sck_rate                   = 5'h02;
		        chip_select_behaviour      = 1'h0;                  
                min_idle_time              = 3'h0;  
                en_back_to_back_trans      = 1'h0;		
                cpha                       = 1'h1;                                   
                cpol                       = 1'h0;                                   
                first_bit_transfer         = 1'h0;
				addr_32b = QSPI_CONFIG_REG_0_REG_ADDR;
				qspi_config_0_wr_data = {16'b0, en_frame_end_done_cntr, en_flash_address_space_map, 
				                         data_endianness, sck_rate, chip_select_behaviour, min_idle_time, 
										 en_back_to_back_trans, cpha, cpol, first_bit_transfer};
				wr_data_32b = qspi_config_0_wr_data;
				#100;
		    	write_to_intf(addr_32b, wr_data_32b);
				#1000;
		    	write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_0 - supported flash command
		        xfer_len_bytes        = 16'h0;
		        num_wait_state        = 8'h0;
		        multiple_flash_target = 1'h0;
		        flash_cmd_code        = 5'h14;
		        with_payload          = 1'h0; 
		        sup_flash_cmd         = 1'h1; 
		        addr_32b = PACKET_HEADER_0_REG_ADDR;
		        packet_header_0_wr_data = {xfer_len_bytes, num_wait_state, multiple_flash_target, flash_cmd_code, with_payload, sup_flash_cmd};
		        wr_data_32b = packet_header_0_wr_data;
		        #100;
		    	write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_1
		        //flash_addr_width      = 3'b010; // 24-bit address
		        flash_addr_width      = 3'b000; // 24-bit address
		        //tgt_cs                = 5'h1;          
		        tgt_cs                = 5'h0;          
		        data_lane_width       = 2'b00;  // Standard SPI
		        addr_lane_width       = 2'b00;  // Standard SPI
		        cmd_lane_width        = 2'b00;  // Standard SPI 
		        packet_header_1_wr_data = {16'h0, flash_addr_width, tgt_cs, 2'h0, data_lane_width, addr_lane_width, cmd_lane_width};
		        addr_32b    = PACKET_HEADER_1_REG_ADDR;
		        wr_data_32b = packet_header_1_wr_data;
		        #100;
		        write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_2 and pkt_header_3
		        addr_32b    = PACKET_HEADER_2_REG_ADDR;
		        wr_data_32b = 32'h0;
		        #100;
		        write_to_intf(addr_32b, wr_data_32b);
		        addr_32b    = PACKET_HEADER_3_REG_ADDR;
		        wr_data_32b = 32'h0;
		        #100;
		        write_to_intf(addr_32b, wr_data_32b);
		        // Start transaction
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000001;
		        #100;
		        write_to_intf(addr_32b, wr_data_32b);
		        // Read TRANSACTION_STATUS
		        #100;
		        read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
		        //while (rd_data_32b[0] == 1) begin
		        //    read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
		        //    #100;
		        //end
		        // Start transaction
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000000;
		        #100;
		        write_to_intf(addr_32b, wr_data_32b);
		        #1000;
		        // Write to config0 - Configuration Register - Clock Mode 2
		        en_frame_end_done_cntr     = 1'h0;
                en_flash_address_space_map = 1'h0;
                data_endianness            = 1'h0;                        
                sck_rate                   = 5'h02;
		        chip_select_behaviour      = 1'h0;                  
                min_idle_time              = 3'h0;  
                en_back_to_back_trans      = 1'h0;		
                cpha                       = 1'h0;                                   
                cpol                       = 1'h1;                                   
                first_bit_transfer         = 1'h0;
				addr_32b = QSPI_CONFIG_REG_0_REG_ADDR;
				qspi_config_0_wr_data = {16'b0, en_frame_end_done_cntr, en_flash_address_space_map, 
				                         data_endianness, sck_rate, chip_select_behaviour, min_idle_time, 
										 en_back_to_back_trans, cpha, cpol, first_bit_transfer};
				wr_data_32b = qspi_config_0_wr_data;
				#100;
		    	write_to_intf(addr_32b, wr_data_32b);
				#1000;
		    	write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_0 - supported flash command
		        xfer_len_bytes        = 16'h0;
		        num_wait_state        = 8'h0;
		        multiple_flash_target = 1'h0;
		        flash_cmd_code        = 5'h14;
		        with_payload          = 1'h0; 
		        sup_flash_cmd         = 1'h1; 
		        addr_32b = PACKET_HEADER_0_REG_ADDR;
		        packet_header_0_wr_data = {xfer_len_bytes, num_wait_state, multiple_flash_target, flash_cmd_code, with_payload, sup_flash_cmd};
		        wr_data_32b = packet_header_0_wr_data;
		        #100;
		    	write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_1
		        //flash_addr_width      = 3'b010; // 24-bit address
		        flash_addr_width      = 3'b000; // 24-bit address
		        //tgt_cs                = 5'h1;          
		        tgt_cs                = 5'h0;          
		        data_lane_width       = 2'b00;  // Standard SPI
		        addr_lane_width       = 2'b00;  // Standard SPI
		        cmd_lane_width        = 2'b00;  // Standard SPI 
		        packet_header_1_wr_data = {16'h0, flash_addr_width, tgt_cs, 2'h0, data_lane_width, addr_lane_width, cmd_lane_width};
		        addr_32b    = PACKET_HEADER_1_REG_ADDR;
		        wr_data_32b = packet_header_1_wr_data;
		        #100;
		        write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_2 and pkt_header_3
		        addr_32b    = PACKET_HEADER_2_REG_ADDR;
		        wr_data_32b = 32'h0;
		        #100;
		        write_to_intf(addr_32b, wr_data_32b);
		        addr_32b    = PACKET_HEADER_3_REG_ADDR;
		        wr_data_32b = 32'h0;
		        #100;
		        write_to_intf(addr_32b, wr_data_32b);
		        // Start transaction
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000001;
		        #100;
		        write_to_intf(addr_32b, wr_data_32b);
		        // Read TRANSACTION_STATUS
		        #100;
		        read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
		        //while (rd_data_32b[0] == 1) begin
		        //    read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
		        //    #100;
		        //end
		        // Start transaction
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000000;
		        #100;
		        write_to_intf(addr_32b, wr_data_32b);
		        #1000;
		    //end
	    end
	endtask
	
	// Execute/Test Supported Commands : Send Command
	// GUI Setting : 
	//              AHB-L, AXI4 or AXI4L Interfaces, 
	//              Little or Big Endianness 
	//              Enabled or Disabled IO Buffer
	//              Any Clock Modes
	//              Only : 
    //                    Standard SPI Protocol 
	//                    MSB First Transmitted Bit (Commd Opcode should be changed for LSB mode)
	//                    Disabled Back to Back Transfer
	//                    Receive and Transmit FIFOs Disabled
	//                    Disabled Flash Address Mapping 
	//                    All command opcodes are on default
	task supported_commands_test_send_command;
        reg [31:0] addr_32b;
        reg [31:0] wr_data_32b;
		reg [31:0] rd_data_32b;
        reg [4:0] flash_command_code_reg [5:0];
		integer m_i_i;
		integer m_j_i;
		integer m_k_i;
		reg [31:0] max_loop;
		
		//QSPI_CONFIG_REG_0_REG_ADDR
		reg [31:0] qspi_config_0_wr_data;
		reg en_frame_end_done_cntr;
        reg en_flash_address_space_map;
        reg data_endianness;                        
        reg [4:0] sck_rate;
		reg chip_select_behaviour;                  
        reg [2:0] min_idle_time;  
        reg en_back_to_back_trans;		
        reg cpha;                                   
        reg cpol;                                   
        reg first_bit_transfer;
		
		//PACKET_HEADER_0
		reg [31:0] packet_header_0_wr_data;
		reg [15:0] xfer_len_bytes; 
		reg [7:0] num_wait_state;  
		reg multiple_flash_target; 
		reg [4:0] flash_cmd_code;  
		reg with_payload;          
		reg sup_flash_cmd;  

		//PACKET_HEADER_1
		reg [31:0] packet_header_1_wr_data;
        reg [2:0] flash_addr_width;
        reg [4:0] tgt_cs;          
        reg [1:0] data_lane_width; 
        reg [1:0] addr_lane_width; 
        reg [1:0] cmd_lane_width;  		
		
	    begin
		// Write Only
		// Send write commands without payload, then read back the command sent
		    // flash_command_code == 5'h14 // Write Enable                 06h
		    // flash_command_code == 5'h15 // Write Disable                04h
		    // flash_command_code == 5'h1C // Enter 4-Byte Address Mode    B7h
		    // flash_command_code == 5'h1D // Exit 4-Byte Address Mode     E9h
		    // flash_command_code == 5'h1E // Enter Quad Input/Output Mode 35h
		    // flash_command_code == 5'h1F // Reset Quad Input/Output Mode F5h
			flash_command_code_reg[0] = 5'h14;
			flash_command_code_reg[1] = 5'h15;
			flash_command_code_reg[2] = 5'h1C;
			flash_command_code_reg[3] = 5'h1D;
			flash_command_code_reg[4] = 5'h1E;
			flash_command_code_reg[5] = 5'h1F;
            #12000; // wait for a_reset_n_i assertion
			#1000;
			max_loop = (SUPPORTED_PROTOCOL == 2) ? 32'h00000006 : 32'h00000004;
			$display("# ---INFO : @%0dns :: Test Name : supported_commands_test_send_command", $time);
		    //for (m_j_i = 32'h0000000; m_j_i < 32'h00000002; m_j_i = m_j_i + 32'h00000001) begin	
		        //for (m_k_i = 32'h0000001; m_k_i < 32'h00000020; m_k_i = m_k_i + 32'h00000001) begin	
		            //for (m_i_i = 32'h0000000; m_i_i < 32'h00000006; m_i_i = m_i_i + 32'h00000001) begin	 // Run this on Quad Protocol only
		            for (m_i_i = 32'h0000000; m_i_i < max_loop; m_i_i = m_i_i + 32'h00000001) begin	
				        // Write to config0 - Configuration Register
		                //en_frame_end_done_cntr     = 1'h0;
                        //en_flash_address_space_map = 1'h0;
                        //data_endianness            = 1'h0;                        
                        //sck_rate                   = m_k_i[4:0];
		                //chip_select_behaviour      = 1'h0;                  
                        //min_idle_time              = 3'h0;  
                        //en_back_to_back_trans      = 1'h0;		
                        ////cpha                       = 1'h1;                                   
                        ////cpol                       = 1'h1;  		
                        //cpha                       = m_j_i[0];                                   
                        //cpol                       = m_j_i[0];                                 
                        //first_bit_transfer         = 1'h0;
			        	//addr_32b = QSPI_CONFIG_REG_0_REG_ADDR;
			        	//qspi_config_0_wr_data = {16'b0, en_frame_end_done_cntr, en_flash_address_space_map, 
			        	//                         data_endianness, sck_rate, chip_select_behaviour, min_idle_time, 
			        	//						 en_back_to_back_trans, cpha, cpol, first_bit_transfer};
			        	//wr_data_32b = qspi_config_0_wr_data;
			            //if (overwrite_gui_settings == 1) begin
			            //    #100; write_to_intf(addr_32b, wr_data_32b);
			            //end
		                // Write 0 to Start transaction Register
		                addr_32b    = START_TRANSACTION_REG_ADDR;
		                wr_data_32b = 32'h00000000;
		                #100; write_to_intf(addr_32b, wr_data_32b);
		                // Write to pkt_header_0 - supported flash command
		                xfer_len_bytes        = 16'h0;
		                num_wait_state        = 8'h0;
		                multiple_flash_target = 1'h0;
		                flash_cmd_code        = flash_command_code_reg[m_i_i];
		                with_payload          = 1'h0; 
		                sup_flash_cmd         = 1'h1; 
		                addr_32b              = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_0_REG_ADDR;
		                packet_header_0_wr_data = {xfer_len_bytes, num_wait_state, multiple_flash_target, flash_cmd_code, with_payload, sup_flash_cmd};
		                wr_data_32b = packet_header_0_wr_data;
		                #100;
		            	write_to_intf(addr_32b, wr_data_32b);
		                // Write to pkt_header_1
		                flash_addr_width      = 3'b000; // 24-bit address
		                //tgt_cs                = 5'h1;          
		                tgt_cs                = 5'h0;   
                        if (m_i_i == 32'h5) begin
		                    data_lane_width       = 2'b10;  // Quad SPI
		                    addr_lane_width       = 2'b10;  // Quad SPI
		                    cmd_lane_width        = 2'b10;  // Quad SPI 
                        end		
                        else begin					
		                    data_lane_width       = 2'b00;  // Standard SPI
		                    addr_lane_width       = 2'b00;  // Standard SPI
		                    cmd_lane_width        = 2'b00;  // Standard SPI 
				    	end
		                packet_header_1_wr_data = {16'h0, flash_addr_width, tgt_cs, 2'h0, data_lane_width, addr_lane_width, cmd_lane_width};
		                addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_1_REG_ADDR;
		                wr_data_32b = packet_header_1_wr_data;
		                #100;
		                write_to_intf(addr_32b, wr_data_32b);
		                //// Write to pkt_header_2 and pkt_header_3
		                //addr_32b    = PACKET_HEADER_2_REG_ADDR;
		                //wr_data_32b = 32'h0;
		                //#100;
		                //write_to_intf(addr_32b, wr_data_32b);
		                //addr_32b    = PACKET_HEADER_3_REG_ADDR;
		                //wr_data_32b = 32'h0;
		                //#100;
		                //write_to_intf(addr_32b, wr_data_32b);
		                // Start transaction
		                addr_32b    = START_TRANSACTION_REG_ADDR;
		                wr_data_32b = 32'h00000001;
		                #100;
		                write_to_intf(addr_32b, wr_data_32b);
		                #100;
		                read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
		                while (rd_data_32b[0] == 1) begin
		                    read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
		                    #100;
		                end
		                // Start transaction
		                addr_32b    = START_TRANSACTION_REG_ADDR;
		                wr_data_32b = 32'h00000000; // without this only 1 transaction will be started by the controller
		                #100;
		                write_to_intf(addr_32b, wr_data_32b);
		                #100;
		                read_from_intf(addr_32b, wr_data_32b);
		            end
				//end
			//end
			$display("# ---INFO : @%0dns :: Done supported_commands_test_send_command testing", $time);
					
	    end
	endtask
	
	// Execute/Test Supported Commands : Send Command + Address
	task supported_commands_test_send_command_and_address;
        reg [31:0] addr_32b;
        reg [31:0] wr_data_32b;
		reg [31:0] rd_data_32b;
        reg [4:0] flash_command_code_reg [4:0];
        reg [31:0] pkt_hdr_addr_32b;
		
		//QSPI_CONFIG_REG_0_REG_ADDR
		reg [31:0] qspi_config_0_wr_data;
		reg en_frame_end_done_cntr;
        reg en_flash_address_space_map;
        reg data_endianness;                        
        reg [4:0] sck_rate;
		reg chip_select_behaviour;                  
        reg [2:0] min_idle_time;  
        reg en_back_to_back_trans;		
        reg cpha;                                   
        reg cpol;                                   
        reg first_bit_transfer;
		
		//QSPI_CONFIG_REG_1_REG_ADDR
		reg [31:0] qspi_config_1_wr_data;
		reg [15:0] trgt_rd_trans_cnt;
		reg [15:0] trgt_wr_trans_cnt;
		integer m_j_i;
		integer m_i_i;
		
		//PACKET_HEADER_0
		reg [31:0] packet_header_0_wr_data;
		reg [15:0] xfer_len_bytes; 
		reg [7:0] num_wait_state;  
		reg multiple_flash_target; 
		reg [4:0] flash_cmd_code;  
		reg with_payload;          
		reg sup_flash_cmd;  

		//PACKET_HEADER_1
		reg [31:0] packet_header_1_wr_data;
        reg [2:0] flash_addr_width;
        reg [4:0] tgt_cs;          
        reg [1:0] data_lane_width; 
        reg [1:0] addr_lane_width; 
        reg [1:0] cmd_lane_width;  
		
	    begin		
            #12000; // wait for a_reset_n_i assertion
			#1000;
		// Write Command with Address - Erase Operations
		    flash_command_code_reg[0] = 5'h10;
			flash_command_code_reg[1] = 5'h11;
			flash_command_code_reg[2] = 5'h12;
			flash_command_code_reg[3] = 5'h13;
			flash_command_code_reg[4] = 5'h13;
			
			if (DATA_ENDIANNESS == 1 ) begin //Big Endian
			    pkt_hdr_addr_32b    = 32'h01000000; // 24-bit address is 24'h010000
			end
			else begin // Little Endian
			    pkt_hdr_addr_32b    = 32'h00000001; // 24-bit address is 24'h010000
			end
			
			$display("# ---INFO : @%0dns :: Test Name : supported_commands_test_send_command_and_address", $time);
			    
			//for (m_i_i = 32'h00000000; m_i_i < 32'h00000004; m_i_i = m_i_i + 32'h00000001) begin  // up to chip erase
			for (m_i_i = 32'h00000000; m_i_i < 32'h00000003; m_i_i = m_i_i + 32'h00000001) begin 
			//for (m_i_i = 32'h00000002; m_i_i < 32'h00000005; m_i_i = m_i_i + 32'h00000001) begin 
			//for (m_i_i = 32'h00000000; m_i_i < 32'h00000005; m_i_i = m_i_i + 32'h00000001) begin 
			    if (m_i_i == 32'h00000004) begin
			        $display("# ---INFO : @%0dns :: Change flash erase command opcodes.", $time);
			        set_flash_command_code(32'h0000001C, {8'h21, 8'h52, 8'hDC, 8'hC7});
				end
				// Write to config0 - Configuration Register 0, this setting will be used for Erase, Write and Read Operation
		        en_frame_end_done_cntr     = 1'h0;
                en_flash_address_space_map = 1'h0;
                data_endianness            = 1'h0;                        
                sck_rate                   = 5'h02;
		        chip_select_behaviour      = 1'h0;                  
                min_idle_time              = 3'h0;  
                en_back_to_back_trans      = 1'h0;		
                cpha                       = 1'h0;                                    
                cpol                       = 1'h0;                                    
                first_bit_transfer         = 1'h0;
			    addr_32b                   = QSPI_CONFIG_REG_0_REG_ADDR;
			    qspi_config_0_wr_data      = {16'b0, en_frame_end_done_cntr, en_flash_address_space_map, 
			                                  data_endianness, sck_rate, chip_select_behaviour, min_idle_time, 
			    						      en_back_to_back_trans, cpha, cpol, first_bit_transfer};
			    wr_data_32b = qspi_config_0_wr_data;
			    if (overwrite_gui_settings == 1) begin
			        #100; write_to_intf(addr_32b, wr_data_32b);
			    end
			    // Write to config1 - Configuration Register 1, this setting will be used for Write and Read Operation
		        trgt_rd_trans_cnt     = 16'h100;
			    trgt_wr_trans_cnt     = 16'h100;
			    addr_32b              = QSPI_CONFIG_REG_1_REG_ADDR;
			    qspi_config_1_wr_data = {trgt_rd_trans_cnt, trgt_wr_trans_cnt};
			    wr_data_32b           = qspi_config_1_wr_data;
			    #100; write_to_intf(addr_32b, wr_data_32b);
				
			    $display("# ---INFO : @%0dns :: Setting registers to execute erase operation.", $time);
		        // Write to pkt_header_0 - supported flash command
		        xfer_len_bytes        = 16'h0;
		        num_wait_state        = 8'h0;
		        multiple_flash_target = 1'h0;
		        flash_cmd_code        = flash_command_code_reg[m_i_i]; // Erase Command
		        with_payload          = 1'h0; 
		        sup_flash_cmd         = 1'h1; 
		        addr_32b              = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_0_REG_ADDR;
		        packet_header_0_wr_data = {xfer_len_bytes, num_wait_state, multiple_flash_target, flash_cmd_code, with_payload, sup_flash_cmd};
		        wr_data_32b             = packet_header_0_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_1
		        flash_addr_width      = 3'b010; // 24-bit address
		        tgt_cs                = 5'h1;          
		        data_lane_width       = 2'b00;  // Standard SPI
		        addr_lane_width       = 2'b00;  // Standard SPI
		        cmd_lane_width        = 2'b00;  // Standard SPI 
		        packet_header_1_wr_data = {16'h0, flash_addr_width, tgt_cs, 2'h0, data_lane_width, addr_lane_width, cmd_lane_width};
		        addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_1_REG_ADDR;
		        wr_data_32b = packet_header_1_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
				if (m_i_i < 32'h00000003) begin
		           // Write to pkt_header_2 and pkt_header_3
		           addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_2_REG_ADDR;
		           wr_data_32b = pkt_hdr_addr_32b;
		           #100; write_to_intf(addr_32b, wr_data_32b);
				end
				if (ENABLE_TRANSMIT_FIFO == 0) begin
		           addr_32b    = PACKET_HEADER_3_REG_ADDR;
		           wr_data_32b = 32'h0;
		           #100; write_to_intf(addr_32b, wr_data_32b);
				end
		        // Start transaction
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000001;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Read TRANSACTION_STATUS
		        #100; read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
				$display("# ---INFO : @%0dns :: Polling transaction status register.", $time);
				if (rd_data_32b[0] == 1) begin
				    if (m_i_i == 32'h00000000) begin
				        $display("# ---INFO : @%0dns :: Block Erase Type 1 started.", $time);
			        end
				    else if (m_i_i == 32'h00000001) begin
				        $display("# ---INFO : @%0dns :: Block Erase Type 2 started.", $time);
			        end
				    else if (m_i_i == 32'h00000002) begin
				        $display("# ---INFO : @%0dns :: Block Erase Type 3 started.", $time);
			        end
				    else begin
				        $display("# ---INFO : @%0dns :: Chip Erase started.", $time);
				    end
				end
				else begin
				    $display("# ---INFO : @%0dns :: Erase operation not yet started.", $time);
				end
		        while (rd_data_32b[0] == 1) begin
		            read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
		            #100;
		        end
				$display("# ---INFO : @%0dns :: Erase operation done.", $time);
		        // Write 0 to Start Transaction Register
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000000;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		    end
		end
    endtask	
	
	// Execute/Test Supported Commands : Send Command + Write Data
	// GUI Setting : 
	//              AHB-L, AXI4 or AXI4L Interfaces, 
	//              Little or Big Endianness 
	//              Enabled or Disabled IO Buffer
	//              Any Clock Modes
	//              Only : 
    //                    Standard SPI Protocol 
	//                    MSB First Transmitted Bit (Commd Opcode should be changed for LSB mode)
	//                    Disabled Back to Back Transfer
	//                    Receive and Transmit FIFOs Disabled
	//                    Disabled Flash Address Mapping 
	//                    All command opcodes are on default
	// This task is for Write Configuration/Status Register only.
	// This is the only supported command with write data and without address.
	task supported_commands_test_send_command_and_write_data;
	    input [31:0] stat_reg_wr_data;
	    input [4:0] rdsr_flash_cmd_code;
		input [0:0] multiple_flash_target_input;
		input [4:0] tgt_cs_input;
        reg [31:0] addr_32b;
        reg [31:0] flash_addr_32b;
        reg [31:0] flash_wr_data_32b [255:0];
        reg [31:0] flash_rd_data_32b [255:0];
        reg [31:0] pkt_hdr_addr_32b;
        reg [31:0] wr_data_32b;
		reg [31:0] rd_data_32b;
		reg [31:0] num_of_bytes;
		reg [31:0] limit_num_of_bytes;
		integer m_i_i;
		integer m_j_i;
		
		//PACKET_HEADER_0
		reg [31:0] packet_header_0_wr_data;
		reg [15:0] xfer_len_bytes; 
		reg [7:0] num_wait_state;  
		reg multiple_flash_target; 
		reg [4:0] flash_cmd_code;  
		reg with_payload;          
		reg sup_flash_cmd;  

		//PACKET_HEADER_1
		reg [31:0] packet_header_1_wr_data;
        reg [2:0] flash_addr_width;
        reg [4:0] tgt_cs;          
        reg [1:0] data_lane_width; 
        reg [1:0] addr_lane_width; 
        reg [1:0] cmd_lane_width;  
		
		reg wb_stat_reg_2_data;
		
	    begin		
            #12000; // wait for a_reset_n_i assertion
			#1000;
		// Write Command with data
		    // flash_command_code == 5'h16 // Write Status/Configuration Register
			$display("# ---INFO : @%0dns :: Test Name : supported_commands_test_send_command_and_write_data", $time);
			
		    // Write 0 to Start Transaction Register
		    addr_32b    = START_TRANSACTION_REG_ADDR;
		    wr_data_32b = 32'h00000000;
		    #100; write_to_intf(addr_32b, wr_data_32b);
			
			$display("# ---INFO : @%0dns :: Setting registers to Write Status Register.", $time);
		    // Write to pkt_header_0 - supported flash command
		    xfer_len_bytes        = 16'h1;
		    num_wait_state        = 8'h0;
		    multiple_flash_target = multiple_flash_target_input;
		    flash_cmd_code        = 5'h16; // Write Status/Configuration Register
		    with_payload          = 1'h1; 
		    sup_flash_cmd         = 1'h1;  
		    addr_32b              = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_0_REG_ADDR;
		    packet_header_0_wr_data = {xfer_len_bytes, num_wait_state, multiple_flash_target, flash_cmd_code, with_payload, sup_flash_cmd};
		    wr_data_32b = packet_header_0_wr_data;
		    #100; write_to_intf(addr_32b, wr_data_32b);
		    // Write to pkt_header_1
		    flash_addr_width      = 3'b000; // no address on sequence
		    tgt_cs                = tgt_cs_input;          
		    data_lane_width       = 2'b00;  // Standard SPI
		    addr_lane_width       = 2'b00;  // Standard SPI
		    cmd_lane_width        = 2'b00;  // Standard SPI 
		    packet_header_1_wr_data = {16'h0, flash_addr_width, tgt_cs, 2'h0, data_lane_width, addr_lane_width, cmd_lane_width};
		    addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_1_REG_ADDR;
		    wr_data_32b = packet_header_1_wr_data;
		    #100; write_to_intf(addr_32b, wr_data_32b);
		    //// Write to pkt_header_2 and pkt_header_3
		    //addr_32b    = PACKET_HEADER_2_REG_ADDR;
		    //wr_data_32b = 32'h0;
		    //#100;
		    //write_to_intf(addr_32b, wr_data_32b);
		    //addr_32b    = PACKET_HEADER_3_REG_ADDR;
		    //wr_data_32b = 32'h0;
		    //#100;
		    //write_to_intf(addr_32b, wr_data_32b);
		    // Write to pkt_data_0
		    addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_DATA_0_REG_ADDR;
			wr_data_32b = stat_reg_wr_data;
		    #100; write_to_intf(addr_32b, wr_data_32b);
			//if (flash_device == 2'b01) begin
			//    if (DATA_ENDIANNESS == 1) begin // Big Endian 
			//	    wb_stat_reg_2_data = 32'h02000000;
			//	end
			//	else begin // Little Endian 
			//	    wb_stat_reg_2_data = 32'h00000002;
			//	end
			//end
			//flash_wr_data_32b[0][31:0] = (flash_device == 2'b01) ? wb_stat_reg_2_data : wr_data_32b;
			flash_wr_data_32b[0][31:0] = wr_data_32b;
		    // Start transaction
		    addr_32b    = START_TRANSACTION_REG_ADDR;
		    wr_data_32b = 32'h00000001;
		    #100;
		    write_to_intf(addr_32b, wr_data_32b);
		    // Read TRANSACTION_STATUS
		    #100; read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
			$display("# ---INFO : @%0dns :: Polling transaction status register.", $time);
			if (rd_data_32b[0] == 1) begin
			    $display("# ---INFO : @%0dns :: Write to Status/Configuration Register operation started.", $time);
			end
			else begin
			    $display("# ---INFO : @%0dns :: Write to Status/Configuration Register operation not yet started.", $time);
			end
		    while (rd_data_32b[0] == 1) begin
		        read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b); #100;
		    end
			$display("# ---INFO : @%0dns :: Write to Status/Configuration Register operation done.", $time);
			
			// Below Sequence is to perform Read Status Register Command to check if Write Status Register is successful
			// flash_command_code == 5'h00 // Read Status Register-1      8’h05
		    // Write 0 to Start transaction Register
		    addr_32b    = START_TRANSACTION_REG_ADDR;
		    wr_data_32b = 32'h00000000;
		    #100; write_to_intf(addr_32b, wr_data_32b);
			
			$display("# ---INFO : @%0dns :: Setting registers to execute Read Status Register operation.", $time);
		    xfer_len_bytes        = 16'h0001; // 1-byte status register
		    multiple_flash_target = multiple_flash_target_input;
		    flash_cmd_code        = rdsr_flash_cmd_code; // Read Status Register-1      8’h05  
		    num_wait_state        = 8'h00;
		    with_payload          = 1'h0; 
		    sup_flash_cmd         = 1'h1; 
		    addr_32b = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_0_REG_ADDR;
		    packet_header_0_wr_data = {xfer_len_bytes, num_wait_state, multiple_flash_target, flash_cmd_code, with_payload, sup_flash_cmd};
		    wr_data_32b = packet_header_0_wr_data;
		    #100; write_to_intf(addr_32b, wr_data_32b);
		    // Write to pkt_header_1
		    flash_addr_width      = 3'b000; // 0-bit address
		    tgt_cs                = tgt_cs_input; 
		    data_lane_width       = 2'b00;  // Standard SPI
		    addr_lane_width       = 2'b00;  // Standard SPI
		    cmd_lane_width        = 2'b00;  // Standard SPI 
		    packet_header_1_wr_data = {16'h0, flash_addr_width, tgt_cs, 2'h0, data_lane_width, addr_lane_width, cmd_lane_width};
		    addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_1_REG_ADDR;
			wr_data_32b = packet_header_1_wr_data;
		    #100; write_to_intf(addr_32b, wr_data_32b);
			// Write to Interrupt Status Register
		    addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		    wr_data_32b = 32'hFFFFFFFF;
		    #100; write_to_intf(addr_32b, wr_data_32b);
			// Enable Interrupt Status Register
		    addr_32b    = INTERRUPT_ENABLE_REG_ADDR;
		    wr_data_32b = 32'h00000030;
		    #100; write_to_intf(addr_32b, wr_data_32b);
		    // Start transaction
		    addr_32b    = START_TRANSACTION_REG_ADDR;
		    wr_data_32b = 32'h00000001;
		    #100; write_to_intf(addr_32b, wr_data_32b);
		    // Read TRANSACTION_STATUS
		    #100; read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
			$display("# ---INFO : @%0dns :: Polling transaction status register.", $time);
			if (rd_data_32b[0] == 1) begin
			    $display("# ---INFO : @%0dns :: Read Status Register started.", $time);
			end
			else begin
			    $display("# ---INFO : @%0dns :: Read Status Register not yet started.", $time);
			end	
		    while (rd_data_32b[0] == 1) begin
		        read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b); #100;
		    end
			$display("# ---INFO : @%0dns :: Read Status Register done.", $time);
		    //Read from pkt_data_0
			addr_32b = ENABLE_RECEIVE_FIFO ? RX_FIFO_MAPPING_REG_ADDR : PACKET_DATA_0_REG_ADDR;
			read_from_intf(addr_32b, rd_data_32b);
			flash_rd_data_32b[0][31:0] = rd_data_32b;
			// Comment below lines for now
		    /*if (flash_device == 0) begin
                do_data_compare(flash_wr_data_32b[0],flash_rd_data_32b[0]);
			end
			else begin
			    $display("# ---INFO : @%0dns :: Read Status Register read data is 0x%x.", $time, rd_data_32b);
			end
			*/
			/*
			read_from_intf(INTERRUPT_STATUS_REG_ADDR, rd_data_32b);
			while (rd_data_32b[4] != 1) begin
			    read_from_intf(INTERRUPT_STATUS_REG_ADDR, rd_data_32b);
			end
			if (rd_data_32b[4] == 1) begin
			    // Write to Interrupt Status Register
		        addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		        wr_data_32b = 32'h00000010;
		        write_to_intf(addr_32b, wr_data_32b);
		        // Read from pkt_data_0
			    addr_32b = ENABLE_RECEIVE_FIFO ? RX_FIFO_MAPPING_REG_ADDR : PACKET_DATA_0_REG_ADDR;
			    read_from_intf(addr_32b, rd_data_32b);
			    flash_rd_data_32b[0][31:0] = rd_data_32b;
				if (flash_device == 0) begin
                    do_data_compare(flash_wr_data_32b[0],flash_rd_data_32b[0]);
				end
				else begin
			        $display("# ---INFO : @%0dns :: Read Status Register read data is 0x%x.", $time, rd_data_32b);
				end
			end*/
		    //Write 0 to Start transaction Register
		    addr_32b    = START_TRANSACTION_REG_ADDR;
		    wr_data_32b = 32'h00000000;
		    #100; write_to_intf(addr_32b, wr_data_32b);
		end
    endtask	
	
	// Execute/Test Supported Commands : Send Command + Read Data
	// GUI Setting : 
	//              AHB-L, AXI4 or AXI4L Interfaces, 
	//              Little or Big Endianness 
	//              Enabled or Disabled IO Buffer
	//              Any Clock Modes
	//              Only : 
    //                    Standard/Dual/Quad SPI Protocol 
	//                    MSB First Transmitted Bit (Commd Opcode should be changed for LSB mode)
	//                    Disabled Back to Back Transfer
	//                    Receive and Transmit FIFOs Disabled
	//                    Disabled Flash Address Mapping 
	//                    All command opcodes are on default
	task supported_commands_test_send_command_and_read_data;
	    input [15:0] xfer_len_bytes_input;
		input        multiple_flash_target_input;
		input  [4:0] flash_cmd_code_input;
		input  [7:0] num_wait_state_input;
		input  [2:0] flash_addr_width_input;
		input  [4:0] tgt_cs_input;
		input  [1:0] data_lane_width_input;
		input  [1:0] addr_lane_width_input;
		input  [1:0] cmd_lane_width_input;
		input [31:0] flash_addr_input; 
	
        reg [31:0] addr_32b;
        reg [31:0] flash_addr_32b;
        reg [31:0] flash_wr_data_32b [255:0];
        reg [31:0] flash_rd_data_32b [255:0];
        reg [31:0] pkt_hdr_addr_32b;
        reg [31:0] wr_data_32b;
		reg [31:0] rd_data_32b;
		reg [31:0] num_of_bytes;
		reg [31:0] limit_num_of_bytes;
		integer m_i_i;
		integer m_j_i;
		
		//QSPI_CONFIG_REG_0_REG_ADDR
		reg [31:0] qspi_config_0_wr_data;
		reg en_frame_end_done_cntr;
        reg en_flash_address_space_map;
        reg data_endianness;                        
        reg [4:0] sck_rate;
		reg chip_select_behaviour;                  
        reg [2:0] min_idle_time;  
        reg en_back_to_back_trans;		
        reg cpha;                                   
        reg cpol;                                   
        reg first_bit_transfer;
		
		//QSPI_CONFIG_REG_1_REG_ADDR
		reg [31:0] qspi_config_1_wr_data;
		reg [15:0] trgt_rd_trans_cnt;
		reg [15:0] trgt_wr_trans_cnt;
		
		//PACKET_HEADER_0
		reg [31:0] packet_header_0_wr_data;
		reg [15:0] xfer_len_bytes; 
		reg [7:0] num_wait_state;  
		reg multiple_flash_target; 
		reg [4:0] flash_cmd_code;  
		reg with_payload;          
		reg sup_flash_cmd;  

		//PACKET_HEADER_1
		reg [31:0] packet_header_1_wr_data;
        reg [2:0] flash_addr_width;
        reg [4:0] tgt_cs;          
        reg [1:0] data_lane_width; 
        reg [1:0] addr_lane_width; 
        reg [1:0] cmd_lane_width;  		
		
		begin
            #12000; // wait for a_reset_n_i assertion
			#1000;
		// Commands for ID Read                                                              Flash Model   Protocol       Return Data   
		    // flash_command_code == 5'h04 // 8'h9F Read ID                                  MX25L51245G   Standard       3 bytes
		    // flash_command_code == 5'h05 // 8’hAB Read Electronic ID                       MX25L51245G   Standard/Quad  1 byte
		    // flash_command_code == 5'h06 // 8’hAF Multiple I/O Read ID                     MX25L51245G   Quad           1 byte  
		    // flash_command_code == 5'h07 // 8’h90 Read Manufacturer and Device ID          MX25L51245G   Standard       1 byte
		    // flash_command_code == 5'h08 // 8’h92 Read Manufacturer and Device ID Dual I/O W25Q512JV     Dual           2 bytes              
		    // flash_command_code == 5'h09 // 8’h94 Read Manufacturer and Device ID Quad I/O W25Q512JV     Quad           2 bytes
			
			// *8’h92 Read Manufacturer and Device ID Dual I/O
			//  X1 command, X2 3/4-byte address last byte is 00h, X2 M7-0 Fxh, X2 Data
			
			// *8’h94 Read Manufacturer and Device ID Quad I/O 
			//  X1 command, X4 3/4-byte address last byte is 00h, X4 M7-0 Fxh, X4 8bits dummy, X4 Data
			
		// Read Only                                                                        Flash Model   Protocol       Return Data                               
		    // flash_command_code == 5'h00 // Read Status Register-1      8’h05
		    // flash_command_code == 5'h01 // Read Status Register-2      8’h35 
		    // flash_command_code == 5'h02 // Read Status Register-3      8’h15
		    // flash_command_code == 5'h03 // Read Configuration Register 8’hB5
			
			
		    // W25Q512JV uses all, MX25L51245G use only  Read Status Register-1, all has 1 byte return data
			
			// For Macronix Quad Read ID commands
		    if (flash_device == 2'b00) begin
			    if (cmd_lane_width_input == 2'b00 & data_lane_width_input == 2'b10 & addr_lane_width_input == 2'b10 ) begin // Address and Data to be sent on 4 IO lanes	
                    // For Quad Enable Bit setting on Configuration Register
			        if (DATA_ENDIANNESS == 1) begin // Big Endian
			            supported_commands_test_send_command_and_write_data({8'h40, 24'h000000}, 5'h00, 1'h0, 5'h0);
			    	end
			    	else begin
			            supported_commands_test_send_command_and_write_data({24'h000000, 8'h40}, 5'h00, 1'h0, 5'h0);
			    	end   
				end
				else if (cmd_lane_width_input == 2'b10 & data_lane_width_input == 2'b10 & addr_lane_width_input == 2'b10 ) begin // Address and Data to be sent on 4 IO lanes	
                    // Enter Quad I/O
					supported_flash_command_opcode_only(1'h0, 5'h1E, 5'h0);     
				end
			end
		
		
        // Below Sequence is to perform Read ID Command on MX25L51245G flash device
			$display("# ---INFO : @%0dns :: Test Name : supported_commands_test_send_command_and_read_data", $time);
		    // Write 0 to Start transaction Register
		    addr_32b    = START_TRANSACTION_REG_ADDR;
		    wr_data_32b = 32'h00000000;
		    #100; write_to_intf(addr_32b, wr_data_32b);
			
			$display("# ---INFO : @%0dns :: Setting registers to execute Read ID operation.", $time);
		    xfer_len_bytes        = xfer_len_bytes_input;
		    multiple_flash_target = multiple_flash_target_input;
		    flash_cmd_code        = flash_cmd_code_input;
		    num_wait_state        = num_wait_state_input;
		    with_payload          = 1'h0; 
		    sup_flash_cmd         = 1'h1; 
		    addr_32b = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_0_REG_ADDR;
		    packet_header_0_wr_data = {xfer_len_bytes, num_wait_state, multiple_flash_target, flash_cmd_code, with_payload, sup_flash_cmd};
		    wr_data_32b = packet_header_0_wr_data;
		    #100; write_to_intf(addr_32b, wr_data_32b);
		    // Write to pkt_header_1
		    flash_addr_width      = flash_addr_width_input;
		    tgt_cs                = tgt_cs_input; 
		    data_lane_width       = data_lane_width_input; 
		    addr_lane_width       = addr_lane_width_input;  
		    cmd_lane_width        = cmd_lane_width_input;   
		    packet_header_1_wr_data = {16'h0, flash_addr_width, tgt_cs, 2'h0, data_lane_width, addr_lane_width, cmd_lane_width};
		    addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_1_REG_ADDR;
			wr_data_32b = packet_header_1_wr_data;
		    #100; write_to_intf(addr_32b, wr_data_32b);
		    // Write to pkt_header_2 and pkt_header_3
			if(flash_addr_width != 3'h0) begin
		        addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_2_REG_ADDR;
		        wr_data_32b = flash_addr_input;
		        #100; write_to_intf(addr_32b, wr_data_32b);
			end
			//if (ENABLE_TRANSMIT_FIFO == 0) begin
		    //   addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_3_REG_ADDR;
		    //   wr_data_32b = 32'h0;
		    //   #100; write_to_intf(addr_32b, wr_data_32b);
			//end
			// Write to Interrupt Status Register
		    addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		    wr_data_32b = 32'hFFFFFFFF;
		    #100; write_to_intf(addr_32b, wr_data_32b);
			// Enable Interrupt Status Register
		    addr_32b    = INTERRUPT_ENABLE_REG_ADDR;
		    wr_data_32b = 32'h00000030;
		    #100; write_to_intf(addr_32b, wr_data_32b);
		    // Start transaction
		    addr_32b    = START_TRANSACTION_REG_ADDR;
		    wr_data_32b = 32'h00000001;
		    #100; write_to_intf(addr_32b, wr_data_32b);
		    // Read TRANSACTION_STATUS
		    #100; read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
			$display("# ---INFO : @%0dns :: Polling transaction status register.", $time);
			if (rd_data_32b[0] == 1) begin
			    $display("# ---INFO : @%0dns :: Read Device ID started.", $time);
			end
			else begin
			    $display("# ---INFO : @%0dns :: Read Device ID not yet started.", $time);
			end	
			num_of_bytes = 0;
			if (DATA_ENDIANNESS == 0) begin // Little Endian
			    if (flash_device == 2'b00) begin
					if (flash_cmd_code_input == 5'h04) flash_wr_data_32b[0][31:0] = 32'h001A20C2;// Macronix RDID [Manufacturer ID, Memory Type, memory Density]
					if (flash_cmd_code_input == 5'h05) flash_wr_data_32b[0][31:0] = 32'h00000019;// Macronix Electronic ID
					if (flash_cmd_code_input == 5'h06) flash_wr_data_32b[0][31:0] = 32'h001A20C2;// Macronix QPID [Manufacturer ID, Memory Type, memory Density] 
					if (flash_cmd_code_input == 5'h07) flash_wr_data_32b[0][31:0] = 32'h000019C2;// Macronix REMS [Manufacturer ID, Device ID]
				
			    end
				else if (flash_device == 2'b01) begin
				    if (flash_cmd_code_input == 5'h04) flash_wr_data_32b[0][31:0] = 32'h002040EF;// Winbond Read Jedec ID 9Fh
				    if (flash_cmd_code_input == 5'h05) flash_wr_data_32b[0][31:0] = 32'h00000019;// Winbond Read Electronic ID ABh
				    if (flash_cmd_code_input == 5'h06) flash_wr_data_32b[0][31:0] = 32'h00000000;// Winbond Multiple I/O Read ID AFh not available 
				    if (flash_cmd_code_input == 5'h07) flash_wr_data_32b[0][31:0] = 32'h000019EF;// Winbond Read Manufacturer and Device ID 90h
				    if (flash_cmd_code_input == 5'h08) flash_wr_data_32b[0][31:0] = 32'h000019EF;// Winbond Read Manufacturer and Device ID Dual I/O 92h 
				    if (flash_cmd_code_input == 5'h09) flash_wr_data_32b[0][31:0] = 32'h000019EF;// Winbond Read Manufacturer and Device ID Quad I/O 94h
			    end
			end
			else begin // Big Endian
			    if (flash_device == 2'b00) begin
					if (flash_cmd_code_input == 5'h04) flash_wr_data_32b[0][31:0] = 32'hC2201A00;// Macronix RDID [Manufacturer ID, Memory Type, memory Density]
					if (flash_cmd_code_input == 5'h05) flash_wr_data_32b[0][31:0] = 32'h19000000;// Macronix Electronic ID
					if (flash_cmd_code_input == 5'h06) flash_wr_data_32b[0][31:0] = 32'hC2201A00;// Macronix QPID [Manufacturer ID, Memory Type, memory Density] 
					if (flash_cmd_code_input == 5'h07) flash_wr_data_32b[0][31:0] = 32'hC2190000;// Macronix REMS [Manufacturer ID, Device ID]
				end 
				else if (flash_device == 2'b01) begin
				    if (flash_cmd_code_input == 5'h04) flash_wr_data_32b[0][31:0] = 32'hEF402000;// Winbond Read Jedec ID 9Fh
				    if (flash_cmd_code_input == 5'h05) flash_wr_data_32b[0][31:0] = 32'h19000000;// Winbond Read Electronic ID ABh
				    if (flash_cmd_code_input == 5'h06) flash_wr_data_32b[0][31:0] = 32'h00000000;// Winbond Multiple I/O Read ID AFh not available 
				    if (flash_cmd_code_input == 5'h07) flash_wr_data_32b[0][31:0] = 32'hEF190000;// Winbond Read Manufacturer and Device ID 90h
				    if (flash_cmd_code_input == 5'h08) flash_wr_data_32b[0][31:0] = 32'hEF190000;// Winbond Read Manufacturer and Device ID Dual I/O 92h 
				    if (flash_cmd_code_input == 5'h09) flash_wr_data_32b[0][31:0] = 32'hEF190000;// Winbond Read Manufacturer and Device ID Quad I/O 94h
			    end
			end
			if (ENABLE_RECEIVE_FIFO == 0) begin
			    read_from_intf(INTERRUPT_STATUS_REG_ADDR, rd_data_32b);
			    while (rd_data_32b[4] != 1) begin
			        read_from_intf(INTERRUPT_STATUS_REG_ADDR, rd_data_32b);
			    end
				if (rd_data_32b[4] == 1) begin
		            //Read from pkt_data_0
					addr_32b = ENABLE_RECEIVE_FIFO ? RX_FIFO_MAPPING_REG_ADDR : PACKET_DATA_0_REG_ADDR;
			        read_from_intf(addr_32b, rd_data_32b);
			        flash_rd_data_32b[(num_of_bytes>>2)][31:0] = rd_data_32b;
                    do_data_compare(flash_wr_data_32b[(num_of_bytes>>2)],flash_rd_data_32b[(num_of_bytes>>2)]);
		            #100;
			        // Write to Interrupt Status Register
		            addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		            wr_data_32b = 32'h00000010;
		            #100; write_to_intf(addr_32b, wr_data_32b);
			        read_from_intf(INTERRUPT_STATUS_REG_ADDR, rd_data_32b);
					//num_of_bytes = num_of_bytes + 4;
				end
				else begin
		            #100;
				end
		        read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);	
			    $display("# ---INFO : @%0dns :: Polling transaction status register.", $time);	
			    if (rd_data_32b[0] == 1) begin
			        $display("# ---INFO : @%0dns :: Read Device ID still on-going.", $time);
			    end
			    else begin
			        $display("# ---INFO : @%0dns :: Read Device ID done.", $time);
			    end	
			end
			else begin
		        read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
			    while (rd_data_32b[0] != 0) begin
			        read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
			    end
			    $display("# ---INFO : @%0dns :: Read Device ID done.", $time);
				addr_32b = ENABLE_RECEIVE_FIFO ? RX_FIFO_MAPPING_REG_ADDR : PACKET_DATA_0_REG_ADDR;
			    read_from_intf(addr_32b, rd_data_32b);
			    flash_rd_data_32b[(num_of_bytes>>2)][31:0] = rd_data_32b;
                do_data_compare(flash_wr_data_32b[(num_of_bytes>>2)],flash_rd_data_32b[(num_of_bytes>>2)]);
		        #100;
			end
		    // Write 0 to Start transaction Register
		    addr_32b    = START_TRANSACTION_REG_ADDR;
		    wr_data_32b = 32'h00000000;
		    #100; write_to_intf(addr_32b, wr_data_32b);
			
			// For Macronix Quad Read ID commands
		    if (flash_device == 2'b00) begin
			    if (cmd_lane_width_input == 2'b00 & data_lane_width_input == 2'b10 & addr_lane_width_input == 2'b10 ) begin // Address and Data to be sent on 4 IO lanes	
                    supported_commands_test_send_command_and_write_data(32'h0, 5'h00, 1'h0, 5'h0);  
				end
				else if (cmd_lane_width_input == 2'b10 & data_lane_width_input == 2'b10 & addr_lane_width_input == 2'b10 ) begin // Address and Data to be sent on 4 IO lanes	
                    // Exit Quad I/O
					supported_flash_command_opcode_only(1'h0, 5'h1F, 5'h0);     
				end
			end
		end
    endtask	
	
	// Applicable for Macronix flash when doing operations on full Quad Mode (4-4-4)
	task enable_quad_io;
        reg [31:0] addr_32b;
        reg [31:0] flash_addr_32b;
        reg [31:0] flash_wr_data_32b [255:0];
        reg [31:0] flash_rd_data_32b [255:0];
        reg [31:0] pkt_hdr_addr_32b;
        reg [31:0] wr_data_32b;
		reg [31:0] rd_data_32b;
		reg [31:0] num_of_bytes;
		reg [31:0] limit_num_of_bytes;
		integer m_i_i;
		integer m_j_i;
		
		//QSPI_CONFIG_REG_0_REG_ADDR
		reg [31:0] qspi_config_0_wr_data;
		reg en_frame_end_done_cntr;
        reg en_flash_address_space_map;
        reg data_endianness;                        
        reg [4:0] sck_rate;
		reg chip_select_behaviour;                  
        reg [2:0] min_idle_time;  
        reg en_back_to_back_trans;		
        reg cpha;                                   
        reg cpol;                                   
        reg first_bit_transfer;
		
		//QSPI_CONFIG_REG_1_REG_ADDR
		reg [31:0] qspi_config_1_wr_data;
		reg [15:0] trgt_rd_trans_cnt;
		reg [15:0] trgt_wr_trans_cnt;
		
		//PACKET_HEADER_0
		reg [31:0] packet_header_0_wr_data;
		reg [15:0] xfer_len_bytes; 
		reg [7:0] num_wait_state;  
		reg multiple_flash_target; 
		reg [4:0] flash_cmd_code;  
		reg with_payload;          
		reg sup_flash_cmd;  

		//PACKET_HEADER_1
		reg [31:0] packet_header_1_wr_data;
        reg [2:0] flash_addr_width;
        reg [4:0] tgt_cs;          
        reg [1:0] data_lane_width; 
        reg [1:0] addr_lane_width; 
        reg [1:0] cmd_lane_width;  		
		
	    begin
			// Enter 4-byte Address Mode - Supported Command
			    // flash_command_code == 5'h1C // Enter 4-byte Address Mode		
							
		        // Write 0 to Start transaction Register
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000000;
		        #100; write_to_intf(addr_32b, wr_data_32b);	
				
			    $display("# ---INFO : @%0dns :: Setting registers to execute Enter 4-byte address mode command.", $time);
		        // Write to pkt_header_0 - supported flash command
		        xfer_len_bytes          = 16'h0;
		        num_wait_state          = 8'h0;
		        multiple_flash_target   = 1'h0;
		        flash_cmd_code          = 5'h1C; // Enter 4-byte Address Mode	
		        with_payload            = 1'h0; 
		        sup_flash_cmd           = 1'h1;
			    addr_32b                = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_0_REG_ADDR;
		        packet_header_0_wr_data = {xfer_len_bytes, num_wait_state, multiple_flash_target, flash_cmd_code, with_payload, sup_flash_cmd};
		        wr_data_32b             = packet_header_0_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_1
		        flash_addr_width        = 3'b000;
		        tgt_cs                  = 5'h0; 
		        data_lane_width         = 2'b00;  // Standard SPI
		        addr_lane_width         = 2'b00;  // Standard SPI
		        cmd_lane_width          = 2'b00;  // Standard SPI 
		        packet_header_1_wr_data = {16'h0, flash_addr_width, tgt_cs, 2'h0, data_lane_width, addr_lane_width, cmd_lane_width};
                addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_1_REG_ADDR;
		        wr_data_32b = packet_header_1_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Start transaction
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000001;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Read TRANSACTION_STATUS
		        #100; read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
				$display("# ---INFO : @%0dns :: Polling transaction status register.", $time);
				if (rd_data_32b[0] == 1) begin
				    $display("# ---INFO : @%0dns :: Flash operation started.", $time);
				end
				else begin
				    $display("# ---INFO : @%0dns :: Flash operation not yet started.", $time);
				end
		        while (rd_data_32b[0] == 1) begin
		            read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b); #100;
		        end
				$display("# ---INFO : @%0dns :: Flash operation done.", $time);	
			
			// Exit 4-byte Address Mode
			    // flash_command_code == 5'h1D // Exit 4-byte Address Mode		
							
		        // Write 0 to Start transaction Register
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000000;
		        #100; write_to_intf(addr_32b, wr_data_32b);	
				
			    $display("# ---INFO : @%0dns :: Setting registers to execute Exit 4-byte address mode command.", $time);
		        // Write to pkt_header_0 - supported flash command
		        xfer_len_bytes          = 16'h0;
		        num_wait_state          = 8'h0;
		        multiple_flash_target   = 1'h0;
		        flash_cmd_code          = 5'h1D; // Exit 4-byte Address Mode	
		        with_payload            = 1'h0; 
		        sup_flash_cmd           = 1'h1;
			    addr_32b                = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_0_REG_ADDR;
		        packet_header_0_wr_data = {xfer_len_bytes, num_wait_state, multiple_flash_target, flash_cmd_code, with_payload, sup_flash_cmd};
		        wr_data_32b             = packet_header_0_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_1
		        flash_addr_width        = 3'b000;
		        tgt_cs                  = 5'h0; 
		        data_lane_width         = 2'b00;  // Standard SPI
		        addr_lane_width         = 2'b00;  // Standard SPI
		        cmd_lane_width          = 2'b00;  // Standard SPI 
		        packet_header_1_wr_data = {16'h0, flash_addr_width, tgt_cs, 2'h0, data_lane_width, addr_lane_width, cmd_lane_width};
                addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_1_REG_ADDR;
		        wr_data_32b = packet_header_1_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Start transaction
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000001;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Read TRANSACTION_STATUS
		        #100; read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
				$display("# ---INFO : @%0dns :: Polling transaction status register.", $time);
				if (rd_data_32b[0] == 1) begin
				    $display("# ---INFO : @%0dns :: Flash operation started.", $time);
				end
				else begin
				    $display("# ---INFO : @%0dns :: Flash operation not yet started.", $time);
				end
		        while (rd_data_32b[0] == 1) begin
		            read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b); #100;
		        end
				$display("# ---INFO : @%0dns :: Flash operation done.", $time);
				
			// Enter Quad Mode - Supported Command	
			    // flash_command_code == 5'h1E // Enter Quad I/O Mode		
							
		        // Write 0 to Start transaction Register
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000000;
		        #100; write_to_intf(addr_32b, wr_data_32b);	
				
			    $display("# ---INFO : @%0dns :: Setting registers to execute Enter Quad I/O mode command.", $time);
		        // Write to pkt_header_0 - supported flash command
		        xfer_len_bytes          = 16'h0;
		        num_wait_state          = 8'h0;
		        multiple_flash_target   = 1'h0;
		        flash_cmd_code          = 5'h1E; // Enter Quad I/O Mode	
		        with_payload            = 1'h0; 
		        sup_flash_cmd           = 1'h1;
			    addr_32b                = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_0_REG_ADDR;
		        packet_header_0_wr_data = {xfer_len_bytes, num_wait_state, multiple_flash_target, flash_cmd_code, with_payload, sup_flash_cmd};
		        wr_data_32b             = packet_header_0_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_1
		        flash_addr_width        = 3'b000;
		        tgt_cs                  = 5'h0; 
		        data_lane_width         = 2'b00;  // Standard SPI
		        addr_lane_width         = 2'b00;  // Standard SPI
		        cmd_lane_width          = 2'b00;  // Standard SPI 
		        packet_header_1_wr_data = {16'h0, flash_addr_width, tgt_cs, 2'h0, data_lane_width, addr_lane_width, cmd_lane_width};
                addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_1_REG_ADDR;
		        wr_data_32b = packet_header_1_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Start transaction
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000001;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Read TRANSACTION_STATUS
		        #100; read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
				$display("# ---INFO : @%0dns :: Polling transaction status register.", $time);
				if (rd_data_32b[0] == 1) begin
				    $display("# ---INFO : @%0dns :: Flash operation started.", $time);
				end
				else begin
				    $display("# ---INFO : @%0dns :: Flash operation not yet started.", $time);
				end
		        while (rd_data_32b[0] == 1) begin
		            read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b); #100;
		        end
				$display("# ---INFO : @%0dns :: Flash operation done.", $time);
		end
	endtask
	
	// Applicable for Macronix flash after doing operations on full Quad Mode (4-4-4)
	task disable_quad_io;
        reg [31:0] addr_32b;
        reg [31:0] flash_addr_32b;
        reg [31:0] flash_wr_data_32b [255:0];
        reg [31:0] flash_rd_data_32b [255:0];
        reg [31:0] pkt_hdr_addr_32b;
        reg [31:0] wr_data_32b;
		reg [31:0] rd_data_32b;
		reg [31:0] num_of_bytes;
		reg [31:0] limit_num_of_bytes;
		integer m_i_i;
		integer m_j_i;
		
		//QSPI_CONFIG_REG_0_REG_ADDR
		reg [31:0] qspi_config_0_wr_data;
		reg en_frame_end_done_cntr;
        reg en_flash_address_space_map;
        reg data_endianness;                        
        reg [4:0] sck_rate;
		reg chip_select_behaviour;                  
        reg [2:0] min_idle_time;  
        reg en_back_to_back_trans;		
        reg cpha;                                   
        reg cpol;                                   
        reg first_bit_transfer;
		
		//QSPI_CONFIG_REG_1_REG_ADDR
		reg [31:0] qspi_config_1_wr_data;
		reg [15:0] trgt_rd_trans_cnt;
		reg [15:0] trgt_wr_trans_cnt;
		
		//PACKET_HEADER_0
		reg [31:0] packet_header_0_wr_data;
		reg [15:0] xfer_len_bytes; 
		reg [7:0] num_wait_state;  
		reg multiple_flash_target; 
		reg [4:0] flash_cmd_code;  
		reg with_payload;          
		reg sup_flash_cmd;  

		//PACKET_HEADER_1
		reg [31:0] packet_header_1_wr_data;
        reg [2:0] flash_addr_width;
        reg [4:0] tgt_cs;          
        reg [1:0] data_lane_width; 
        reg [1:0] addr_lane_width; 
        reg [1:0] cmd_lane_width;  		
		
	    begin
		    // Exit Quad Mode	
		        // flash_command_code == 5'h1F // Exit Quad I/O Mode		
		    				
		        // Write 0 to Start transaction Register
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000000;
		        #100; write_to_intf(addr_32b, wr_data_32b);	
		    	
		        $display("# ---INFO : @%0dns :: Setting registers to execute Exit Quad I/O mode command.", $time);
		        // Write to pkt_header_0 - supported flash command
		        xfer_len_bytes          = 16'h0;
		        num_wait_state          = 8'h0;
		        multiple_flash_target   = 1'h0;
		        flash_cmd_code          = 5'h1F; // Exit Quad I/O Mode	
		        with_payload            = 1'h0; 
		        sup_flash_cmd           = 1'h1;
		        addr_32b                = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_0_REG_ADDR;
		        packet_header_0_wr_data = {xfer_len_bytes, num_wait_state, multiple_flash_target, flash_cmd_code, with_payload, sup_flash_cmd};
		        wr_data_32b             = packet_header_0_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_1
		        flash_addr_width        = 3'b000;
		        tgt_cs                  = 5'h0; 
		        data_lane_width         = 2'b10;  // Quad SPI
		        addr_lane_width         = 2'b10;  // Quad SPI
		        cmd_lane_width          = 2'b10;  // Quad SPI 
		        packet_header_1_wr_data = {16'h0, flash_addr_width, tgt_cs, 2'h0, data_lane_width, addr_lane_width, cmd_lane_width};
                addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_1_REG_ADDR;
		        wr_data_32b = packet_header_1_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Start transaction
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000001;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Read TRANSACTION_STATUS
		        #100; read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
		    	$display("# ---INFO : @%0dns :: Polling transaction status register.", $time);
		    	if (rd_data_32b[0] == 1) begin
		    	    $display("# ---INFO : @%0dns :: Flash operation started.", $time);
		    	end
		    	else begin
		    	    $display("# ---INFO : @%0dns :: Flash operation not yet started.", $time);
		    	end
		        while (rd_data_32b[0] == 1) begin
		            read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b); #100;
		        end
		    	$display("# ---INFO : @%0dns :: Flash operation done.", $time);	
		end
	endtask	
				
	// Erase-Write-Read Sequence using Supported Commands
	// For Write and Read Sequence, either with FIFO enabled or disabled, writing/reading to registers and TX/RX FIFO are the same.
	// Write : Checks the interrupt status accordingly, when the register or FIFO is empty, new data will be written.
    // Read  : Checks the interrupt status accordingly, when the register or FIFO is not empty, packet data will be read.	
	task erase_write_read_using_supported_commands;
	    input [31:0] flash_addr;
		input [1:0] supported_protocol;
        reg [31:0] addr_32b;
        reg [31:0] flash_addr_32b;
        reg [31:0] flash_wr_data_32b [255:0];
        reg [31:0] flash_rd_data_32b [255:0];
        reg [31:0] pkt_hdr_addr_32b;
        reg [31:0] wr_data_32b;
		reg [31:0] rd_data_32b;
		reg [31:0] num_of_bytes;
		reg [31:0] limit_num_of_bytes;
		integer m_i_i;
		integer m_j_i;
		
		//QSPI_CONFIG_REG_0_REG_ADDR
		reg [31:0] qspi_config_0_wr_data;
		reg en_frame_end_done_cntr;
        reg en_flash_address_space_map;
        reg data_endianness;                        
        reg [4:0] sck_rate;
		reg chip_select_behaviour;                  
        reg [2:0] min_idle_time;  
        reg en_back_to_back_trans;		
        reg cpha;                                   
        reg cpol;                                   
        reg first_bit_transfer;
		
		//QSPI_CONFIG_REG_1_REG_ADDR
		reg [31:0] qspi_config_1_wr_data;
		reg [15:0] trgt_rd_trans_cnt;
		reg [15:0] trgt_wr_trans_cnt;
		
		//PACKET_HEADER_0
		reg [31:0] packet_header_0_wr_data;
		reg [15:0] xfer_len_bytes; 
		reg [7:0] num_wait_state;  
		reg multiple_flash_target; 
		reg [4:0] flash_cmd_code;  
		reg with_payload;          
		reg sup_flash_cmd;  

		//PACKET_HEADER_1
		reg [31:0] packet_header_1_wr_data;
        reg [2:0] flash_addr_width;
        reg [4:0] tgt_cs;          
        reg [1:0] data_lane_width; 
        reg [1:0] addr_lane_width; 
        reg [1:0] cmd_lane_width;  		
		
	    begin
                #12000; // wait for a_reset_n_i assertion
			    #1000;
				if (supported_protocol == 2'b00) begin
			        $display("# ---INFO : @%0dns :: Test Name : erase_write_read_using_supported_commands_standard_spi", $time);
			    end
				else if (supported_protocol == 2'b10) begin
			        $display("# ---INFO : @%0dns :: Test Name : erase_write_read_using_supported_commands_quad_spi", $time);
			    end
				//Generate Address to be used on Erase, Write, Read
                flash_addr_32b[31:12] = 20'h00000;
                flash_addr_32b[11:2]  = $random;
                flash_addr_32b[1:0]   = 2'h0;
			    //pkt_hdr_addr_32b      = 32'h01F00000; // 24-bit address is 24'h01F000
			    pkt_hdr_addr_32b      = flash_addr; // 24-bit address is 24'h01F000
			    
		        // Write to config0 - Configuration Register 0, this setting will be used for Erase, Write and Read Operation
		        en_frame_end_done_cntr     = 1'h0;
                en_flash_address_space_map = 1'h0;
                data_endianness            = 1'h0;                        
                sck_rate                   = 5'h02;
                //sck_rate                   = 5'h001;
		        chip_select_behaviour      = 1'h0;                  
                min_idle_time              = 3'h0;  
                en_back_to_back_trans      = 1'h0;		
                cpha                       = 1'h1;                                    
                cpol                       = 1'h1; 		
                //cpha                       = m_i_i[0];                                    
                //cpol                       = m_i_i[0];                                   
                first_bit_transfer         = 1'h0;
			    addr_32b                   = QSPI_CONFIG_REG_0_REG_ADDR;
			    qspi_config_0_wr_data      = {16'b0, en_frame_end_done_cntr, en_flash_address_space_map, 
			                                  data_endianness, sck_rate, chip_select_behaviour, min_idle_time, 
			    						      en_back_to_back_trans, cpha, cpol, first_bit_transfer};
			    wr_data_32b = qspi_config_0_wr_data;
			    if (overwrite_gui_settings == 1) begin
			        #100; write_to_intf(addr_32b, wr_data_32b);
			    end
			    // Write to config1 - Configuration Register 1, this setting will be used for Write and Read Operation
		        trgt_rd_trans_cnt     = 16'h100;
			    trgt_wr_trans_cnt     = 16'h100;
			    addr_32b              = QSPI_CONFIG_REG_1_REG_ADDR;
			    qspi_config_1_wr_data = {trgt_rd_trans_cnt, trgt_wr_trans_cnt};
			    wr_data_32b           = qspi_config_1_wr_data;
			    #100; write_to_intf(addr_32b, wr_data_32b);
				
				if(supported_protocol == 2'b10) begin
				    enable_quad_io();
				end
				
		    // Erase - For MX25L51245G can work on Standard SPI and Quad SPI
		        // flash_command_code == 5'h10 // Block Erase Type 1
		        // flash_command_code == 5'h11 // Block Erase Type 2
		        // flash_command_code == 5'h12 // Block Erase Type 3
		        // flash_command_code == 5'h13 // Chip Erase
				
		        // Write 0 to Start transaction Register
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000000;
		        #100; write_to_intf(addr_32b, wr_data_32b);	
				
			    $display("# ---INFO : @%0dns :: Setting registers to execute erase operation.", $time);
		        // Write to pkt_header_0 - supported flash command
		        xfer_len_bytes          = 16'h0;
		        num_wait_state          = 8'h0;
		        multiple_flash_target   = 1'h0;
		        flash_cmd_code          = 5'h10; // Block Erase Type 1 
		        with_payload            = 1'h0; 
		        sup_flash_cmd           = 1'h1;
			    addr_32b                = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_0_REG_ADDR;
		        packet_header_0_wr_data = {xfer_len_bytes, num_wait_state, multiple_flash_target, flash_cmd_code, with_payload, sup_flash_cmd};
		        wr_data_32b             = packet_header_0_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_1
		        flash_addr_width        = 3'b010; // 24-bit address, need to add EN4B when 32-bit address
		        tgt_cs                  = 5'h0;
		        data_lane_width         = supported_protocol;  // Standard/Quad SPI
		        addr_lane_width         = supported_protocol;  // Standard/Quad SPI
		        cmd_lane_width          = supported_protocol;  // Standard/Quad SPI
		        packet_header_1_wr_data = {16'h0, flash_addr_width, tgt_cs, 2'h0, data_lane_width, addr_lane_width, cmd_lane_width};
                addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_1_REG_ADDR;
		        wr_data_32b = packet_header_1_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_2 and pkt_header_3
                addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_2_REG_ADDR;
		        wr_data_32b = pkt_hdr_addr_32b;
		        #100; write_to_intf(addr_32b, wr_data_32b);
				if (ENABLE_TRANSMIT_FIFO == 0) begin
                    addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_3_REG_ADDR;
		            wr_data_32b = 32'h0;
		            #100; write_to_intf(addr_32b, wr_data_32b);
				end
		        // Start transaction
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000001;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Read TRANSACTION_STATUS
		        #100; read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
				$display("# ---INFO : @%0dns :: Polling transaction status register.", $time);
				if (rd_data_32b[0] == 1) begin
				    $display("# ---INFO : @%0dns :: Erase operation started.", $time);
				end
				else begin
				    $display("# ---INFO : @%0dns :: Erase operation not yet started.", $time);
				end
		        while (rd_data_32b[0] == 1) begin
		            read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b); #100;
		        end
				$display("# ---INFO : @%0dns :: Erase operation done.", $time);
			
		    // Page Program	
		        // Standard SPI Write 
		            // flash_command_code == 5'h17 // Page Program
		        // Dual SPI Write 
		            // flash_command_code == 5'h18 // Dual Input Fast Program
		            // flash_command_code == 5'h19 // Extended Dual Input Fast Program
		        // Quad SPI Write 
		            // flash_command_code == 5'h1A // Quad Input Fast Program
		            // flash_command_code == 5'h1B // Extended Quad Input Fast Program
			    
		        // Write 0 to Start transaction Register
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000000;
		        #100; write_to_intf(addr_32b, wr_data_32b);	
				
			    $display("# ---INFO : @%0dns :: Setting registers to execute page program operation.", $time);
		        // Write to pkt_header_0 - supported flash command
		        xfer_len_bytes          = 16'h100; // 256 bytes
		        num_wait_state          = 8'h0;  
		        multiple_flash_target   = 1'h0;
		        flash_cmd_code          = 5'h17; // Page Program 
		        with_payload            = 1'h1; 
		        sup_flash_cmd           = 1'h1; 
                addr_32b                = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_0_REG_ADDR;
		        packet_header_0_wr_data = {xfer_len_bytes, num_wait_state, multiple_flash_target, flash_cmd_code, with_payload, sup_flash_cmd};
		        wr_data_32b             = packet_header_0_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_1
		        flash_addr_width        = 3'b010; // 24-bit address, need to add EN4B when 32-bit address
		        tgt_cs                  = 5'h0; 
		        data_lane_width         = supported_protocol;  // Standard/Quad SPI
		        addr_lane_width         = supported_protocol;  // Standard/Quad SPI
		        cmd_lane_width          = supported_protocol;  // Standard/Quad SPI
		        packet_header_1_wr_data = {16'h0, flash_addr_width, tgt_cs, 2'h0, data_lane_width, addr_lane_width, cmd_lane_width};
		        addr_32b                = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_1_REG_ADDR;
			    wr_data_32b             = packet_header_1_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_2 and pkt_header_3
			    addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_2_REG_ADDR;
		        wr_data_32b = pkt_hdr_addr_32b;
		        #100; write_to_intf(addr_32b, wr_data_32b);
				if (ENABLE_TRANSMIT_FIFO == 0) begin
			        addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_3_REG_ADDR;
		            wr_data_32b = 32'h0;
		            #100; write_to_intf(addr_32b, wr_data_32b);
				end
			    // Write to Interrupt Status Register
		        addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		        wr_data_32b = 32'hFFFFFFFF;
		        #100; write_to_intf(addr_32b, wr_data_32b);
			    // Enable Interrupt Status Register
		        addr_32b    = INTERRUPT_ENABLE_REG_ADDR;
		        wr_data_32b = 32'h00000003;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_data_0
		        addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_DATA_0_REG_ADDR;
		        wr_data_32b = $random;
			    flash_wr_data_32b[0][31:0] = wr_data_32b;
		        #100; write_to_intf(addr_32b, wr_data_32b);
				$display("---INFO : @%0dns :: Write Data 0x%x", $time, wr_data_32b);
                // Write to pkt_data_1
		        addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_DATA_1_REG_ADDR;
		        wr_data_32b = $random;
			    flash_wr_data_32b[1][31:0] = wr_data_32b;
		        #100; write_to_intf(addr_32b, wr_data_32b);
				$display("---INFO : @%0dns :: Write Data 0x%x", $time, wr_data_32b);
			    // Start transaction
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000001;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Read TRANSACTION_STATUS
		        #100; read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
				$display("# ---INFO : @%0dns :: Polling transaction status register.", $time);
				if (rd_data_32b[0] == 1) begin
				    $display("# ---INFO : @%0dns :: Page program started.", $time);
				end
				else begin
				    $display("# ---INFO : @%0dns :: Page program not yet started.", $time);
				end
			    num_of_bytes = 8;
				limit_num_of_bytes = ENABLE_TRANSMIT_FIFO ? (xfer_len_bytes-8) : (xfer_len_bytes-1);
				while (num_of_bytes < limit_num_of_bytes) begin // write remaining 254 bytes of data
				    read_from_intf(INTERRUPT_STATUS_REG_ADDR, rd_data_32b);
			        if (ENABLE_TRANSMIT_FIFO == 0) begin
			    	    if (rd_data_32b[0] == 1) begin
			                // Write to Interrupt Status Register
		                    addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		                    wr_data_32b = 32'h00000001;
		                    #100; write_to_intf(addr_32b, wr_data_32b);
		                    // Write to pkt_data_0
		                    addr_32b    = PACKET_DATA_0_REG_ADDR;
		                    wr_data_32b = $random;
			                flash_wr_data_32b[(num_of_bytes>>2)][31:0] = wr_data_32b;
		                    #100; write_to_intf(addr_32b, wr_data_32b);
				            $display("---INFO : @%0dns :: Write Data 0x%x", $time, wr_data_32b);
			    	    	num_of_bytes = num_of_bytes + 4;
			    	    end
			    	    else begin
		                    #50;
			    	    end
			            read_from_intf(INTERRUPT_STATUS_REG_ADDR, rd_data_32b);
			    	    if (rd_data_32b[1] == 1) begin
			                // Write to Interrupt Status Register
		                    addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		                    wr_data_32b = 32'h00000002;
		                    #100; write_to_intf(addr_32b, wr_data_32b);
		                    // Write to pkt_data_0
		                    addr_32b    = PACKET_DATA_1_REG_ADDR;
		                    wr_data_32b = $random;
			                flash_wr_data_32b[(num_of_bytes>>2)][31:0] = wr_data_32b;
		                    #100; write_to_intf(addr_32b, wr_data_32b);
				            $display("---INFO : @%0dns :: Write Data 0x%x", $time, wr_data_32b);
			    	    	num_of_bytes = num_of_bytes + 4;
			    	    end
			    	    else begin
		                    #50;
			    	    end
			    	end
			    	else begin// ENABLE_TRANSMIT_FIFO == 1 
			    	    if (rd_data_32b[0] == 1) begin
			                // Write to Interrupt Status Register
		                    addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		                    wr_data_32b = 32'h00000001;
		                    #100; write_to_intf(addr_32b, wr_data_32b);
		                    // Write to pkt_data_0
		                    addr_32b    = TX_FIFO_MAPPING_REG_ADDR;
		                    wr_data_32b = $random;
			                flash_wr_data_32b[(num_of_bytes>>2)][31:0] = wr_data_32b;
		                    #100; write_to_intf(addr_32b, wr_data_32b);
				            $display("---INFO : @%0dns :: Write Data 0x%x", $time, wr_data_32b);
			    	    	num_of_bytes = num_of_bytes + 4;
			    	    end
			    	    else begin
		                    #50;
			    	    end
			    	end
				end
				read_from_intf(INTERRUPT_STATUS_REG_ADDR, rd_data_32b);
				while (rd_data_32b[1:0] != 2'b11) begin
		            read_from_intf(INTERRUPT_STATUS_REG_ADDR, rd_data_32b);
		            #100;
		        end
			    // Write to Interrupt Status Register
		        addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		        wr_data_32b = 32'hFFFFFFFF;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
				$display("# ---INFO : @%0dns :: Polling transaction status register.", $time);	
                if (rd_data_32b[0] == 1) $display("# ---INFO : @%0dns :: Page program is still on-going.", $time);				
		        while (rd_data_32b[0] == 1) begin
		            read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
		            #100;
		        end
				$display("# ---INFO : @%0dns :: Page program done.", $time);
			    
		    // Standard SPI Read 	
		        // flash_command_code == 5'h0A // Read Data
		        // flash_command_code == 5'h0B // Fast Read
		    // Dual SPI Read
		        // flash_command_code == 5'h0C // Dual Output Fast Read
		        // flash_command_code == 5'h0D // Dual Input/Output Fast Read
		    // Quad SPI Read
		        // flash_command_code == 5'h0E // Quad Output Fast Read
		        // flash_command_code == 5'h0F // Quad Input/Output Fast Read
			    
		        // Write 0 to Start transaction Register
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000000;
		        #100; write_to_intf(addr_32b, wr_data_32b);
				
			    $display("# ---INFO : @%0dns :: Setting registers to execute page read operation.", $time);
		        xfer_len_bytes        = 16'h100;
		        multiple_flash_target = 1'h0;
				if (supported_protocol == 2'b00) begin // Standard Mode
			        if (standard_spi_fast_read_en == 0) begin
		                flash_cmd_code        = 5'h0A; // Read Data 
		                num_wait_state        = 8'h0;
			        end
			        else begin
		                flash_cmd_code        = 5'h0B; // Fast Read  
		                num_wait_state        = 8'h08;
			        end
				end
				else if (supported_protocol == 2'b10) begin // Quad Mode
		            flash_cmd_code        = 5'h0F; // Read Data 
		            num_wait_state        = 8'h6;
				end
		        with_payload          = 1'h0; 
		        sup_flash_cmd         = 1'h1; 
		        addr_32b = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_0_REG_ADDR;
		        packet_header_0_wr_data = {xfer_len_bytes, num_wait_state, multiple_flash_target, flash_cmd_code, with_payload, sup_flash_cmd};
		        wr_data_32b = packet_header_0_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_1
		        flash_addr_width      = 3'b010; // 24-bit address, need to add EN4B when 32-bit address
		        tgt_cs                = 5'h0; 
		        data_lane_width       = supported_protocol;  // Standard/Quad SPI
		        addr_lane_width       = supported_protocol;  // Standard/Quad SPI
		        cmd_lane_width        = supported_protocol;  // Standard/Quad SPI
		        packet_header_1_wr_data = {16'h0, flash_addr_width, tgt_cs, 2'h0, data_lane_width, addr_lane_width, cmd_lane_width};
		        addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_1_REG_ADDR;
			    wr_data_32b = packet_header_1_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_2 and pkt_header_3
		        addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_2_REG_ADDR;
		        wr_data_32b = pkt_hdr_addr_32b;
		        #100; write_to_intf(addr_32b, wr_data_32b);
				if (ENABLE_TRANSMIT_FIFO == 0) begin
		           addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_3_REG_ADDR;
		           wr_data_32b = 32'h0;
		           #100; write_to_intf(addr_32b, wr_data_32b);
				end
			    // Write to Interrupt Status Register
		        addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		        wr_data_32b = 32'hFFFFFFFF;
		        #100; write_to_intf(addr_32b, wr_data_32b);
			    // Enable Interrupt Status Register
		        addr_32b    = INTERRUPT_ENABLE_REG_ADDR;
		        wr_data_32b = 32'h00000030;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Start transaction
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000001;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Read TRANSACTION_STATUS
		        #100; read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
				$display("# ---INFO : @%0dns :: Polling transaction status register.", $time);
				if (rd_data_32b[0] == 1) begin
				    $display("# ---INFO : @%0dns :: Page read started.", $time);
				end
				else begin
				    $display("# ---INFO : @%0dns :: Page read not yet started.", $time);
				end	
			    num_of_bytes = 0;
				//limit_num_of_bytes = ENABLE_RECEIVE_FIFO ? (xfer_len_bytes+1) : (xfer_len_bytes-3);
				while (num_of_bytes < xfer_len_bytes-1) begin
			        read_from_intf(INTERRUPT_STATUS_REG_ADDR, rd_data_32b);
			    	if (rd_data_32b[4] == 1) begin
		                //Read from pkt_data_0
						addr_32b = ENABLE_RECEIVE_FIFO ? RX_FIFO_MAPPING_REG_ADDR : PACKET_DATA_0_REG_ADDR;
			            read_from_intf(addr_32b, rd_data_32b);
			            flash_rd_data_32b[(num_of_bytes>>2)][31:0] = rd_data_32b;
                        do_data_compare(flash_wr_data_32b[(num_of_bytes>>2)],flash_rd_data_32b[(num_of_bytes>>2)]);
		                //#100;
			            // Write to Interrupt Status Register
		                addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		                wr_data_32b = 32'h00000010;
		                //#100; 
						write_to_intf(addr_32b, wr_data_32b);
			            read_from_intf(INTERRUPT_STATUS_REG_ADDR, rd_data_32b);
			    		num_of_bytes = num_of_bytes + 4;
			    	end
			    	else begin
		                #100;
			    	end
				end
		        read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);	
				$display("# ---INFO : @%0dns :: Polling transaction status register.", $time);		
		        while (rd_data_32b[0] == 1) begin
		            read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
		            #100;
				    if (rd_data_32b[0] == 1) begin
				        $display("# ---INFO : @%0dns :: Page read still on-going.", $time);
				    end
				    else begin
				        $display("# ---INFO : @%0dns :: Page read done.", $time);
				    end	
		        end
				
			    // Exit Quad Mode of the flash
			    if (supported_protocol == 2'b10) begin
				    disable_quad_io();
			    end
		end
	endtask
	
    // Erase-Write-Read Sequence using Supported Commands
	// For Write and Read Sequence, either with FIFO enabled or disabled, writing/reading to registers and TX/RX FIFO are the same.
	// Write : Checks the interrupt status accordingly, when the register or FIFO is empty, new data will be written.
    // Read  : Checks the interrupt status accordingly, when the register or FIFO is not empty, packet data will be read.	
	task erase_multiple_write_single_read_using_supported_commands;
	    input [1:0] erase_test;
		input [1:0] supported_protocol;
        reg [31:0] addr_32b;
        reg [31:0] flash_addr_32b;
        reg [31:0] flash_wr_data_32b [262143:0];
        reg [31:0] flash_rd_data_32b [262143:0];
        reg [31:0] pkt_hdr_addr_32b;
        reg [31:0] pkt_hdr_addr_32b_val;
        reg [31:0] wr_data_32b;
		reg [31:0] rd_data_32b;
		reg [31:0] num_of_bytes;
		reg [31:0] limit_num_of_bytes;
		integer m_i_i;
		integer m_j_i;
		integer m_k_i;
		reg [31:0] max_loop;
		reg [15:0] xfer_len_bytes_val; 
		reg [31:0] addr_inc_val;
		reg [31:0] addr_inc_val_shift;
		
		//QSPI_CONFIG_REG_0_REG_ADDR
		reg [31:0] qspi_config_0_wr_data;
		reg en_frame_end_done_cntr;
        reg en_flash_address_space_map;
        reg data_endianness;                        
        reg [4:0] sck_rate;
		reg chip_select_behaviour;                  
        reg [2:0] min_idle_time;  
        reg en_back_to_back_trans;		
        reg cpha;                                   
        reg cpol;                                   
        reg first_bit_transfer;
		
		//QSPI_CONFIG_REG_1_REG_ADDR
		reg [31:0] qspi_config_1_wr_data;
		reg [15:0] trgt_rd_trans_cnt;
		reg [15:0] trgt_wr_trans_cnt;
		
		//PACKET_HEADER_0
		reg [31:0] packet_header_0_wr_data;
		reg [15:0] xfer_len_bytes; 
		reg [7:0] num_wait_state;  
		reg multiple_flash_target; 
		reg [4:0] flash_cmd_code;  
		reg with_payload;          
		reg sup_flash_cmd;  

		//PACKET_HEADER_1
		reg [31:0] packet_header_1_wr_data;
        reg [2:0] flash_addr_width;
        reg [4:0] tgt_cs;          
        reg [1:0] data_lane_width; 
        reg [1:0] addr_lane_width; 
        reg [1:0] cmd_lane_width;  		
		
	    begin
                #12000; // wait for a_reset_n_i assertion
			    #1000;
				if (supported_protocol == 2'b00) begin
			        $display("# ---INFO : @%0dns :: Test Name : erase_multiple_write_single_read_using_supported_commands_standard_spi", $time);
			    end
				else if (supported_protocol == 2'b10) begin 
			        $display("# ---INFO : @%0dns :: Test Name : erase_multiple_write_single_read_using_supported_commands_quad_spi", $time);
			    end
				//Generate Address to be used on Erase, Write, Read
                flash_addr_32b[31:12] = 20'h00000;
                flash_addr_32b[11:2]  = $random;
                flash_addr_32b[1:0]   = 2'h0;
			    if (DATA_ENDIANNESS == 1 ) begin //Big Endian
			        pkt_hdr_addr_32b    = 32'h01000000; // 24-bit address is 24'h010000
			    end
			    else begin // Little Endian
			        pkt_hdr_addr_32b    = 32'h00000001; // 24-bit address is 24'h010000
			    end
			    
		        // Write to config0 - Configuration Register 0, this setting will be used for Erase, Write and Read Operation
		        en_frame_end_done_cntr     = 1'h0;
                en_flash_address_space_map = 1'h0;
                data_endianness            = 1'h0;                        
                sck_rate                   = 5'h02;
                //sck_rate                   = 5'h001;
		        chip_select_behaviour      = 1'h0;                  
                min_idle_time              = 3'h0;  
                en_back_to_back_trans      = 1'h0;		
                cpha                       = 1'h1;                                    
                cpol                       = 1'h1; 		
                //cpha                       = m_i_i[0];                                    
                //cpol                       = m_i_i[0];                                   
                first_bit_transfer         = 1'h0;
			    addr_32b                   = QSPI_CONFIG_REG_0_REG_ADDR;
			    qspi_config_0_wr_data      = {16'b0, en_frame_end_done_cntr, en_flash_address_space_map, 
			                                  data_endianness, sck_rate, chip_select_behaviour, min_idle_time, 
			    						      en_back_to_back_trans, cpha, cpol, first_bit_transfer};
			    wr_data_32b = qspi_config_0_wr_data;
			    if (overwrite_gui_settings == 1) begin
			        #100; write_to_intf(addr_32b, wr_data_32b);
			    end
			    // Write to config1 - Configuration Register 1, this setting will be used for Write and Read Operation
		        trgt_rd_trans_cnt     = 16'h100;
			    trgt_wr_trans_cnt     = 16'h100;
			    addr_32b              = QSPI_CONFIG_REG_1_REG_ADDR;
			    qspi_config_1_wr_data = {trgt_rd_trans_cnt, trgt_wr_trans_cnt};
			    wr_data_32b           = qspi_config_1_wr_data;
			    #100; write_to_intf(addr_32b, wr_data_32b);
			/*	
			// Enter 4-byte Address Mode - Supported Command
			    // flash_command_code == 5'h1C // Enter 4-byte Address Mode		
							
		        // Write 0 to Start transaction Register
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000000;
		        #100; write_to_intf(addr_32b, wr_data_32b);	
				
			    $display("# ---INFO : @%0dns :: Setting registers to execute Enter 4-byte address mode command.", $time);
		        // Write to pkt_header_0 - supported flash command
		        xfer_len_bytes          = 16'h0;
		        num_wait_state          = 8'h0;
		        multiple_flash_target   = 1'h0;
		        flash_cmd_code          = 5'h1C; // Enter 4-byte Address Mode	
		        with_payload            = 1'h0; 
		        sup_flash_cmd           = 1'h1;
			    addr_32b                = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_0_REG_ADDR;
		        packet_header_0_wr_data = {xfer_len_bytes, num_wait_state, multiple_flash_target, flash_cmd_code, with_payload, sup_flash_cmd};
		        wr_data_32b             = packet_header_0_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_1
		        flash_addr_width        = 3'b000;
		        tgt_cs                  = 5'h0; 
		        data_lane_width         = 2'b00;  // Standard SPI
		        addr_lane_width         = 2'b00;  // Standard SPI
		        cmd_lane_width          = 2'b00;  // Standard SPI 
		        packet_header_1_wr_data = {16'h0, flash_addr_width, tgt_cs, 2'h0, data_lane_width, addr_lane_width, cmd_lane_width};
                addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_1_REG_ADDR;
		        wr_data_32b = packet_header_1_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Start transaction
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000001;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Read TRANSACTION_STATUS
		        #100; read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
				$display("# ---INFO : @%0dns :: Polling transaction status register.", $time);
				if (rd_data_32b[0] == 1) begin
				    $display("# ---INFO : @%0dns :: Flash operation started.", $time);
				end
				else begin
				    $display("# ---INFO : @%0dns :: Flash operation not yet started.", $time);
				end
		        while (rd_data_32b[0] == 1) begin
		            read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b); #100;
		        end
				$display("# ---INFO : @%0dns :: Flash operation done.", $time);	
   		    */
				if(supported_protocol == 2'b10) begin
				    enable_quad_io();
				end
		    // Erase - For MX25L51245G can work on Standard SPI and Quad SPI
		        // flash_command_code == 5'h10 // Block Erase Type 1
		        // flash_command_code == 5'h11 // Block Erase Type 2
		        // flash_command_code == 5'h12 // Block Erase Type 3
		        // flash_command_code == 5'h13 // Chip Erase
				
		        // Write 0 to Start transaction Register
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000000;
		        #100; write_to_intf(addr_32b, wr_data_32b);	
				
			    $display("# ---INFO : @%0dns :: Setting registers to execute erase operation.", $time);
		        // Write to pkt_header_0 - supported flash command
		        xfer_len_bytes          = 16'h0;
		        num_wait_state          = 8'h0;
		        multiple_flash_target   = 1'h0;
				if (erase_test == 3'b000) begin
		            flash_cmd_code          = 5'h10; // Block Erase Type 1 
				end
				else if (erase_test == 3'b001) begin
		            flash_cmd_code          = 5'h11; // Block Erase Type 2
				end
				else if (erase_test == 3'b010) begin
		            flash_cmd_code          = 5'h12; // Block Erase Type 3 
				end
				else begin
		            flash_cmd_code          = 5'h10; // Block Erase Type 1 
				end
		        with_payload            = 1'h0; 
		        sup_flash_cmd           = 1'h1;
			    addr_32b                = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_0_REG_ADDR;
		        packet_header_0_wr_data = {xfer_len_bytes, num_wait_state, multiple_flash_target, flash_cmd_code, with_payload, sup_flash_cmd};
		        wr_data_32b             = packet_header_0_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_1
		        flash_addr_width        = 3'b010; // 24-bit address, need to add EN4B when 32-bit address
		        //flash_addr_width      = 3'b011; // 32-bit address, need to add EN4B when 32-bit address
		        tgt_cs                  = 5'h0; 
		        data_lane_width         = supported_protocol;  // Standard/Quad SPI
		        addr_lane_width         = supported_protocol;  // Standard/Quad SPI
		        cmd_lane_width          = supported_protocol;  // Standard/Quad SPI
		        packet_header_1_wr_data = {16'h0, flash_addr_width, tgt_cs, 2'h0, data_lane_width, addr_lane_width, cmd_lane_width};
                addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_1_REG_ADDR;
		        wr_data_32b = packet_header_1_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_2 and pkt_header_3
                addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_2_REG_ADDR;
		        wr_data_32b = pkt_hdr_addr_32b;
		        #100; write_to_intf(addr_32b, wr_data_32b);
				if (ENABLE_TRANSMIT_FIFO == 0) begin
                    addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_3_REG_ADDR;
		            wr_data_32b = 32'h0;
		            #100; write_to_intf(addr_32b, wr_data_32b);
				end
		        // Start transaction
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000001;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Read TRANSACTION_STATUS
		        #100; read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
				$display("# ---INFO : @%0dns :: Polling transaction status register.", $time);
				if (rd_data_32b[0] == 1) begin
				    $display("# ---INFO : @%0dns :: Erase operation started.", $time);
				end
				else begin
				    $display("# ---INFO : @%0dns :: Erase operation not yet started.", $time);
				end
		        while (rd_data_32b[0] == 1) begin
		            read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b); #100;
		        end
				$display("# ---INFO : @%0dns :: Erase operation done.", $time);
				
		        //max_loop = 32'h09;
				if (erase_test == 3'b000) begin
		            max_loop = 32'h10; // 1 PP = 256 bytes : 4KB = 4096 bytes : 4096/256 = 16
				end
				else if (erase_test == 3'b001) begin
		            max_loop = 32'h80; // 1 PP = 256 bytes : 32KB = 32768 bytes : 32768/256 = 128 
				end
				else if (erase_test == 3'b010) begin
		            max_loop = 32'h100; // 1 PP = 256 bytes : 64KB = 65536 bytes : 65536/256 = 256 
				end
				else begin
		            max_loop = 32'h10; // 1 PP = 256 bytes : 4KB = 4096 bytes : 4096/256 = 16
				end
				for (m_i_i = 32'h0000000; m_i_i < max_loop; m_i_i = m_i_i + 32'h00000001) begin
		        // Page Program	
		            // Standard SPI Write 
		                // flash_command_code == 5'h17 // Page Program
		            // Dual SPI Write 
		                // flash_command_code == 5'h18 // Dual Input Fast Program
		                // flash_command_code == 5'h19 // Extended Dual Input Fast Program
		            // Quad SPI Write 
		                // flash_command_code == 5'h1A // Quad Input Fast Program
		                // flash_command_code == 5'h1B // Extended Quad Input Fast Program
			        
		            // Write 0 to Start transaction Register
		            addr_32b    = START_TRANSACTION_REG_ADDR;
		            wr_data_32b = 32'h00000000;
		            #100; write_to_intf(addr_32b, wr_data_32b);	
			    	
			        $display("# ---INFO : @%0dns :: Setting registers to execute page program operation.", $time);
		            // Write to pkt_header_0 - supported flash command
		            xfer_len_bytes          = 16'h100; // 256 bytes
		            num_wait_state          = 8'h0;  
		            multiple_flash_target   = 1'h0;
		            flash_cmd_code          = 5'h17; // Page Program 
		            with_payload            = 1'h1; 
		            sup_flash_cmd           = 1'h1; 
                    addr_32b                = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_0_REG_ADDR;
		            packet_header_0_wr_data = {xfer_len_bytes, num_wait_state, multiple_flash_target, flash_cmd_code, with_payload, sup_flash_cmd};
		            wr_data_32b             = packet_header_0_wr_data;
		            #100; write_to_intf(addr_32b, wr_data_32b);
		            // Write to pkt_header_1
		            flash_addr_width        = 3'b010; // 24-bit address, need to add EN4B when 32-bit address
		            //flash_addr_width        = 3'b011; // 32-bit address, need to add EN4B when 32-bit address
		            tgt_cs                  = 5'h0; 
		            data_lane_width         = supported_protocol;  // Standard/Quad SPI
		            addr_lane_width         = supported_protocol;  // Standard/Quad SPI
		            cmd_lane_width          = supported_protocol;  // Standard/Quad SPI
		            packet_header_1_wr_data = {16'h0, flash_addr_width, tgt_cs, 2'h0, data_lane_width, addr_lane_width, cmd_lane_width};
		            addr_32b                = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_1_REG_ADDR;
			        wr_data_32b             = packet_header_1_wr_data;
		            #100; write_to_intf(addr_32b, wr_data_32b);
		            // Write to pkt_header_2 and pkt_header_3
			        addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_2_REG_ADDR;
		            if (m_i_i==0) begin
					   wr_data_32b = pkt_hdr_addr_32b;
					end
					else begin
			            if (DATA_ENDIANNESS == 1 ) begin //Big Endian
					        wr_data_32b        = pkt_hdr_addr_32b + ((256*(m_i_i)<<8));
			            end
			            else begin // Little Endian
						    addr_inc_val       = (256*(m_i_i));
							//addr_inc_val_shift = addr_inc_val[31:24]>>16 + addr_inc_val[23:16]>>8 + addr_inc_val[15:8]<<8;
							addr_inc_val_shift = {addr_inc_val[7:0], addr_inc_val[15:8], addr_inc_val[23:16],  addr_inc_val[31:24]}>>8;
					        wr_data_32b        = pkt_hdr_addr_32b + addr_inc_val_shift;
			            end
					end
		            #100; write_to_intf(addr_32b, wr_data_32b);
			    	if (ENABLE_TRANSMIT_FIFO == 0) begin
			            addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_3_REG_ADDR;
		                wr_data_32b = 32'h0;
		                #100; write_to_intf(addr_32b, wr_data_32b);
			    	end
			        // Write to Interrupt Status Register
		            addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		            wr_data_32b = 32'hFFFFFFFF;
		            #100; write_to_intf(addr_32b, wr_data_32b);
			        // Enable Interrupt Status Register
		            addr_32b    = INTERRUPT_ENABLE_REG_ADDR;
		            wr_data_32b = 32'h00000003;
		            #100; write_to_intf(addr_32b, wr_data_32b);
		            // Write to pkt_data_0
		            addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_DATA_0_REG_ADDR;
		            wr_data_32b = $random;
			        flash_wr_data_32b[(m_i_i*64)+0][31:0] = wr_data_32b;
		            #100; write_to_intf(addr_32b, wr_data_32b);
			    	$display("---INFO : @%0dns :: Write Data 0x%x", $time, wr_data_32b);
                    // Write to pkt_data_1
		            addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_DATA_1_REG_ADDR;
		            wr_data_32b = $random;
			        flash_wr_data_32b[(m_i_i*64)+1][31:0] = wr_data_32b;
		            #100; write_to_intf(addr_32b, wr_data_32b);
			    	$display("---INFO : @%0dns :: Write Data 0x%x", $time, wr_data_32b);
			        // Start transaction
		            addr_32b    = START_TRANSACTION_REG_ADDR;
		            wr_data_32b = 32'h00000001;
		            #100; write_to_intf(addr_32b, wr_data_32b);
		            // Read TRANSACTION_STATUS
		            #100; read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
			    	$display("# ---INFO : @%0dns :: Polling transaction status register.", $time);
			    	if (rd_data_32b[0] == 1) begin
			    	    $display("# ---INFO : @%0dns :: Page program started.", $time);
			    	end
			    	else begin
			    	    $display("# ---INFO : @%0dns :: Page program not yet started.", $time);
			    	end
			        num_of_bytes = 8;
			    	limit_num_of_bytes = ENABLE_TRANSMIT_FIFO ? (xfer_len_bytes-8) : (xfer_len_bytes-1);
			    	while (num_of_bytes < limit_num_of_bytes) begin // write remaining 254 bytes of data
			    	    read_from_intf(INTERRUPT_STATUS_REG_ADDR, rd_data_32b);
			            if (ENABLE_TRANSMIT_FIFO == 0) begin
			        	    if (rd_data_32b[0] == 1) begin
			                    // Write to Interrupt Status Register
		                        addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		                        wr_data_32b = 32'h00000001;
		                        #100; write_to_intf(addr_32b, wr_data_32b);
		                        // Write to pkt_data_0
		                        addr_32b    = PACKET_DATA_0_REG_ADDR;
		                        wr_data_32b = $random;
			                    flash_wr_data_32b[(m_i_i*64)+(num_of_bytes>>2)][31:0] = wr_data_32b;
		                        #100; write_to_intf(addr_32b, wr_data_32b);
			    	            $display("---INFO : @%0dns :: Write Data 0x%x", $time, wr_data_32b);
			        	    	num_of_bytes = num_of_bytes + 4;
			        	    end
			        	    else begin
		                        #50;
			        	    end
			                read_from_intf(INTERRUPT_STATUS_REG_ADDR, rd_data_32b);
			        	    if (rd_data_32b[1] == 1) begin
			                    // Write to Interrupt Status Register
		                        addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		                        wr_data_32b = 32'h00000002;
		                        #100; write_to_intf(addr_32b, wr_data_32b);
		                        // Write to pkt_data_0
		                        addr_32b    = PACKET_DATA_1_REG_ADDR;
		                        wr_data_32b = $random;
			                    flash_wr_data_32b[(m_i_i*64)+(num_of_bytes>>2)][31:0] = wr_data_32b;
		                        #100; write_to_intf(addr_32b, wr_data_32b);
			    	            $display("---INFO : @%0dns :: Write Data 0x%x", $time, wr_data_32b);
			        	    	num_of_bytes = num_of_bytes + 4;
			        	    end
			        	    else begin
		                        #50;
			        	    end
			        	end
			        	else begin// ENABLE_TRANSMIT_FIFO == 1 
			        	    if (rd_data_32b[0] == 1) begin
			                    // Write to Interrupt Status Register
		                        addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		                        wr_data_32b = 32'h00000001;
		                        #100; write_to_intf(addr_32b, wr_data_32b);
		                        // Write to pkt_data_0
		                        addr_32b    = TX_FIFO_MAPPING_REG_ADDR;
		                        wr_data_32b = $random;
			                    flash_wr_data_32b[(m_i_i*64)+(num_of_bytes>>2)][31:0] = wr_data_32b;
			    	            
		                        #100; write_to_intf(addr_32b, wr_data_32b);
			    	            $display("---INFO : @%0dns :: Write Data 0x%x", $time, wr_data_32b);
			        	    	num_of_bytes = num_of_bytes + 4;
			        	    end
			        	    else begin
		                        #50;
			        	    end
			        	end
			    	end
				    read_from_intf(INTERRUPT_STATUS_REG_ADDR, rd_data_32b);
				    while (rd_data_32b[1:0] != 2'b11) begin
		                read_from_intf(INTERRUPT_STATUS_REG_ADDR, rd_data_32b);
		                #100;
		            end
			        // Write to Interrupt Status Register
		            addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		            wr_data_32b = 32'hFFFFFFFF;
		            #100; write_to_intf(addr_32b, wr_data_32b);
		            read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
			    	$display("# ---INFO : @%0dns :: Polling transaction status register.", $time);	
                    if (rd_data_32b[0] == 1) $display("# ---INFO : @%0dns :: Page program is still on-going.", $time);				
		            while (rd_data_32b[0] == 1) begin
		                read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
		                #100;
		            end
			    	$display("# ---INFO : @%0dns :: Page program done.", $time);
				end
			    
		    // Standard SPI Read 	
		        // flash_command_code == 5'h0A // Read Data
		        // flash_command_code == 5'h0B // Fast Read
		    // Dual SPI Read
		        // flash_command_code == 5'h0C // Dual Output Fast Read
		        // flash_command_code == 5'h0D // Dual Input/Output Fast Read
		    // Quad SPI Read
		        // flash_command_code == 5'h0E // Quad Output Fast Read
		        // flash_command_code == 5'h0F // Quad Input/Output Fast Read
				
				// Calculate value for nuumber of bytes to be continuously read
				// Loop will be used if multiple 32KB read will be done for 64KB read
		        if (erase_test == 3'b000) begin
				    xfer_len_bytes_val        = 16'h1000; // 4KB = 4096 bytes
					max_loop                  = 32'h1;
				end
				else if (erase_test == 3'b001) begin
				    xfer_len_bytes_val        = 16'h8000; // 32KB = 32768 bytes
					max_loop                  = 32'h1;
				end
				else if (erase_test == 3'b010) begin
				    //xfer_len_bytes_val        = 16'hFFFF; // 64KB = 65536 bytes (-1)
					//max_loop                  = 32'h1;
					// 2 32KB read
				    xfer_len_bytes_val        = 16'h8000; // 32KB = 32768 bytes
					max_loop                  = 32'h2;
				end
				else begin
				    xfer_len_bytes_val        = 16'h1000; // 4KB = 4096 bytes
					max_loop                  = 32'h1;
				end
			    for (m_i_i = 32'h00000000; m_i_i < max_loop; m_i_i = m_i_i + 32'h00000001) begin
		            // Write 0 to Start transaction Register
		            addr_32b    = START_TRANSACTION_REG_ADDR;
		            wr_data_32b = 32'h00000000;
		            #100; write_to_intf(addr_32b, wr_data_32b);
				    
			        $display("# ---INFO : @%0dns :: Setting registers to execute page read operation.", $time);
		            xfer_len_bytes = xfer_len_bytes_val;
					multiple_flash_target = 1'h0;
					if (supported_protocol == 2'b00) begin // Standard Mode
			            if (standard_spi_fast_read_en == 0) begin
		                    flash_cmd_code        = 5'h0A; // Read Data 
		                    num_wait_state        = 8'h0;
			            end
			            else begin
		                    flash_cmd_code        = 5'h0B; // Fast Read  
		                    num_wait_state        = 8'h08;
			            end
					end
					else if (supported_protocol == 2'b10) begin // Quad Mode
		                flash_cmd_code        = 5'h0F; // Read Data 
		                num_wait_state        = 8'h6;
					end
		            with_payload          = 1'h0; 
		            sup_flash_cmd         = 1'h1; 
		            addr_32b = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_0_REG_ADDR;
		            packet_header_0_wr_data = {xfer_len_bytes, num_wait_state, multiple_flash_target, flash_cmd_code, with_payload, sup_flash_cmd};
		            wr_data_32b = packet_header_0_wr_data;
		            #100; write_to_intf(addr_32b, wr_data_32b);
		            // Write to pkt_header_1
		            flash_addr_width        = 3'b010; // 24-bit address, need to add EN4B when 32-bit address
		            //flash_addr_width      = 3'b011; // 32-bit address, need to add EN4B when 32-bit address
		            tgt_cs                  = 5'h0; 
		            data_lane_width         = supported_protocol;  // Standard/Quad SPI
		            addr_lane_width         = supported_protocol;  // Standard/Quad SPI
		            cmd_lane_width          = supported_protocol;  // Standard/Quad SPI
		            packet_header_1_wr_data = {16'h0, flash_addr_width, tgt_cs, 2'h0, data_lane_width, addr_lane_width, cmd_lane_width};
		            addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_1_REG_ADDR;
			        wr_data_32b = packet_header_1_wr_data;
		            #100; write_to_intf(addr_32b, wr_data_32b);
		            // Write to pkt_header_2 and pkt_header_3
		            addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_2_REG_ADDR;
		            if (DATA_ENDIANNESS == 1 ) begin //Big Endian begin
		                wr_data_32b = pkt_hdr_addr_32b+((m_i_i*32768)<<8);
					end
					else begin // Little Endian
						addr_inc_val       = (32768*(m_i_i));
						//addr_inc_val_shift = addr_inc_val[31:24]>>16 + addr_inc_val[23:16]>>8 + addr_inc_val[15:8]<<8;
						addr_inc_val_shift = {addr_inc_val[7:0], addr_inc_val[15:8], addr_inc_val[23:16],  addr_inc_val[31:24]}>>8;
					    wr_data_32b        = pkt_hdr_addr_32b + addr_inc_val_shift;
					end
		            #100; write_to_intf(addr_32b, wr_data_32b);
				    if (ENABLE_TRANSMIT_FIFO == 0) begin
		               addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_3_REG_ADDR;
		               wr_data_32b = 32'h0;
		               #100; write_to_intf(addr_32b, wr_data_32b);
				    end
			        // Write to Interrupt Status Register
		            addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		            wr_data_32b = 32'hFFFFFFFF;
		            #100; write_to_intf(addr_32b, wr_data_32b);
			        // Enable Interrupt Status Register
		            addr_32b    = INTERRUPT_ENABLE_REG_ADDR;
		            wr_data_32b = 32'h00000030;
		            #100; write_to_intf(addr_32b, wr_data_32b);
		            // Start transaction
		            addr_32b    = START_TRANSACTION_REG_ADDR;
		            wr_data_32b = 32'h00000001;
		            #100; write_to_intf(addr_32b, wr_data_32b);
		            // Read TRANSACTION_STATUS
		            #100; read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
				    $display("# ---INFO : @%0dns :: Polling transaction status register.", $time);
				    if (rd_data_32b[0] == 1) begin
				        $display("# ---INFO : @%0dns :: Page read started.", $time);
				    end
				    else begin
				        $display("# ---INFO : @%0dns :: Page read not yet started.", $time);
				    end	
			        num_of_bytes = 0;
				    //limit_num_of_bytes = ENABLE_RECEIVE_FIFO ? (xfer_len_bytes+1) : (xfer_len_bytes-3);
				    while (num_of_bytes < xfer_len_bytes-1) begin
			            read_from_intf(INTERRUPT_STATUS_REG_ADDR, rd_data_32b);
			        	if (rd_data_32b[4] == 1) begin
		                    //Read from pkt_data_0
				    		addr_32b = ENABLE_RECEIVE_FIFO ? RX_FIFO_MAPPING_REG_ADDR : PACKET_DATA_0_REG_ADDR;
			                read_from_intf(addr_32b, rd_data_32b);
			                flash_rd_data_32b[(((m_i_i*32768)+num_of_bytes)>>2)][31:0] = rd_data_32b;
                            do_data_compare(flash_wr_data_32b[(((m_i_i*32768)+num_of_bytes)>>2)],flash_rd_data_32b[(((m_i_i*32768)+num_of_bytes)>>2)]);
		                    //#100;
			                // Write to Interrupt Status Register
		                    addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		                    wr_data_32b = 32'h00000010;
		                    //#100; 
							write_to_intf(addr_32b, wr_data_32b);
			                read_from_intf(INTERRUPT_STATUS_REG_ADDR, rd_data_32b);
			        		num_of_bytes = num_of_bytes + 4;
			        	end
			        	else begin
		                    #100;
			        	end
				    end
		            read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);	
				    $display("# ---INFO : @%0dns :: Polling transaction status register.", $time);		
		            while (rd_data_32b[0] == 1) begin
		                read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
		                #100;
				        if (rd_data_32b[0] == 1) begin
				            $display("# ---INFO : @%0dns :: Page read still on-going.", $time);
				        end
				        else begin
				            $display("# ---INFO : @%0dns :: Page read done.", $time);
				        end	
		            end
				end
				
			   // Exit Quad Mode of the flash
			   if (supported_protocol == 2'b10) begin
			   	disable_quad_io();
			   end
		end
	endtask
	
	// Erase-Write-Read Sequence using Supported Commands
	// For Write and Read Sequence, either with FIFO enabled or disabled, writing/reading to registers and TX/RX FIFO are the same.
	// Write : Checks the interrupt status accordingly, when the register or FIFO is empty, new data will be written.
    // Read  : Checks the interrupt status accordingly, when the register or FIFO is not empty, packet data will be read.	
	task erase_multiple_write_and_read_using_supported_commands;
	    input [1:0] erase_test;
		input [1:0] supported_protocol;
        reg [31:0] addr_32b;
        reg [31:0] flash_addr_32b;
        reg [31:0] flash_wr_data_32b [255:0];
        reg [31:0] flash_rd_data_32b [255:0];
        reg [31:0] pkt_hdr_addr_32b;
        reg [31:0] wr_data_32b;
		reg [31:0] rd_data_32b;
		reg [31:0] num_of_bytes;
		reg [31:0] limit_num_of_bytes;
		integer m_i_i;
		integer m_j_i;
		integer m_k_i;
		reg [31:0] max_loop;
		reg [31:0] addr_inc_val;
		reg [31:0] addr_inc_val_shift;
		
		//QSPI_CONFIG_REG_0_REG_ADDR
		reg [31:0] qspi_config_0_wr_data;
		reg en_frame_end_done_cntr;
        reg en_flash_address_space_map;
        reg data_endianness;                        
        reg [4:0] sck_rate;
		reg chip_select_behaviour;                  
        reg [2:0] min_idle_time;  
        reg en_back_to_back_trans;		
        reg cpha;                                   
        reg cpol;                                   
        reg first_bit_transfer;
		
		//QSPI_CONFIG_REG_1_REG_ADDR
		reg [31:0] qspi_config_1_wr_data;
		reg [15:0] trgt_rd_trans_cnt;
		reg [15:0] trgt_wr_trans_cnt;
		
		//PACKET_HEADER_0
		reg [31:0] packet_header_0_wr_data;
		reg [15:0] xfer_len_bytes; 
		reg [7:0] num_wait_state;  
		reg multiple_flash_target; 
		reg [4:0] flash_cmd_code;  
		reg with_payload;          
		reg sup_flash_cmd;  

		//PACKET_HEADER_1
		reg [31:0] packet_header_1_wr_data;
        reg [2:0] flash_addr_width;
        reg [4:0] tgt_cs;          
        reg [1:0] data_lane_width; 
        reg [1:0] addr_lane_width; 
        reg [1:0] cmd_lane_width;  		
		
	    begin
                #12000; // wait for a_reset_n_i assertion
			    #1000;
				if (supported_protocol == 2'b00) begin
			        $display("# ---INFO : @%0dns :: Test Name : erase_multiple_write_and_read_using_supported_commands_standard_spi", $time);
			    end
				else if (supported_protocol == 2'b10) begin
			        $display("# ---INFO : @%0dns :: Test Name : erase_multiple_write_and_read_using_supported_commands_quad_spi", $time);
			    end
				//Generate Address to be used on Erase, Write, Read
                flash_addr_32b[31:12] = 20'h00000;
                flash_addr_32b[11:2]  = $random;
                flash_addr_32b[1:0]   = 2'h0;
			    if (DATA_ENDIANNESS == 1 ) begin //Big Endian
			        pkt_hdr_addr_32b    = 32'h01000000; // 24-bit address is 24'h010000
			    end
			    else begin // Little Endian
			        pkt_hdr_addr_32b    = 32'h00000001; // 24-bit address is 24'h010000
			    end
			    
		        // Write to config0 - Configuration Register 0, this setting will be used for Erase, Write and Read Operation
		        en_frame_end_done_cntr     = 1'h0;
                en_flash_address_space_map = 1'h0;
                data_endianness            = 1'h0;                        
                sck_rate                   = 5'h02;
                //sck_rate                   = 5'h001;
		        chip_select_behaviour      = 1'h0;                  
                min_idle_time              = 3'h0;  
                en_back_to_back_trans      = 1'h0;		
                cpha                       = 1'h1;                                    
                cpol                       = 1'h1; 		
                //cpha                       = m_i_i[0];                                    
                //cpol                       = m_i_i[0];                                   
                first_bit_transfer         = 1'h0;
			    addr_32b                   = QSPI_CONFIG_REG_0_REG_ADDR;
			    qspi_config_0_wr_data      = {16'b0, en_frame_end_done_cntr, en_flash_address_space_map, 
			                                  data_endianness, sck_rate, chip_select_behaviour, min_idle_time, 
			    						      en_back_to_back_trans, cpha, cpol, first_bit_transfer};
			    wr_data_32b = qspi_config_0_wr_data;
			    if (overwrite_gui_settings == 1) begin
			        #100; write_to_intf(addr_32b, wr_data_32b);
			    end
			    // Write to config1 - Configuration Register 1, this setting will be used for Write and Read Operation
		        trgt_rd_trans_cnt     = 16'h100;
			    trgt_wr_trans_cnt     = 16'h100;
			    addr_32b              = QSPI_CONFIG_REG_1_REG_ADDR;
			    qspi_config_1_wr_data = {trgt_rd_trans_cnt, trgt_wr_trans_cnt};
			    wr_data_32b           = qspi_config_1_wr_data;
			    #100; write_to_intf(addr_32b, wr_data_32b);
				
				if(supported_protocol == 2'b10) begin
				    enable_quad_io();
				end
		    // Erase - For MX25L51245G can work on Standard SPI and Quad SPI
		        // flash_command_code == 5'h10 // Block Erase Type 1
		        // flash_command_code == 5'h11 // Block Erase Type 2
		        // flash_command_code == 5'h12 // Block Erase Type 3
		        // flash_command_code == 5'h13 // Chip Erase
				
		        // Write 0 to Start transaction Register
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000000;
		        #100; write_to_intf(addr_32b, wr_data_32b);	
				
			    $display("# ---INFO : @%0dns :: Setting registers to execute erase operation.", $time);
		        // Write to pkt_header_0 - supported flash command
		        xfer_len_bytes          = 16'h0;
		        num_wait_state          = 8'h0;
		        multiple_flash_target   = 1'h0;
				if (erase_test == 3'b000) begin
		            flash_cmd_code          = 5'h10; // Block Erase Type 1 
				end
				else if (erase_test == 3'b001) begin
		            flash_cmd_code          = 5'h11; // Block Erase Type 2
				end
				else if (erase_test == 3'b010) begin
		            flash_cmd_code          = 5'h12; // Block Erase Type 3 
				end
				else begin
		            flash_cmd_code          = 5'h10; // Block Erase Type 1 
				end
		        with_payload            = 1'h0; 
		        sup_flash_cmd           = 1'h1;
			    addr_32b                = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_0_REG_ADDR;
		        packet_header_0_wr_data = {xfer_len_bytes, num_wait_state, multiple_flash_target, flash_cmd_code, with_payload, sup_flash_cmd};
		        wr_data_32b             = packet_header_0_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_1
		        flash_addr_width        = 3'b010; // 24-bit address, need to add EN4B when 32-bit address
		        tgt_cs                  = 5'h0; 
		        data_lane_width         = supported_protocol;  // Standard/Quad SPI
		        addr_lane_width         = supported_protocol;  // Standard/Quad SPI
		        cmd_lane_width          = supported_protocol;  // Standard/Quad SPI
		        packet_header_1_wr_data = {16'h0, flash_addr_width, tgt_cs, 2'h0, data_lane_width, addr_lane_width, cmd_lane_width};
                addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_1_REG_ADDR;
		        wr_data_32b = packet_header_1_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_2 and pkt_header_3
                addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_2_REG_ADDR;
		        wr_data_32b = pkt_hdr_addr_32b;
		        #100; write_to_intf(addr_32b, wr_data_32b);
				if (ENABLE_TRANSMIT_FIFO == 0) begin
                    addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_3_REG_ADDR;
		            wr_data_32b = 32'h0;
		            #100; write_to_intf(addr_32b, wr_data_32b);
				end
		        // Start transaction
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000001;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Read TRANSACTION_STATUS
		        #100; read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
				$display("# ---INFO : @%0dns :: Polling transaction status register.", $time);
				if (rd_data_32b[0] == 1) begin
				    $display("# ---INFO : @%0dns :: Erase operation started.", $time);
				end
				else begin
				    $display("# ---INFO : @%0dns :: Erase operation not yet started.", $time);
				end
		        while (rd_data_32b[0] == 1) begin
		            read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b); #100;
		        end
				$display("# ---INFO : @%0dns :: Erase operation done.", $time);
				
				if (erase_test == 3'b000) begin
		            max_loop = 32'h10; // 1 PP = 256 bytes : 4KB = 4096 bytes : 4096/256 = 16
		            //max_loop = 32'h3; // 1 PP = 256 bytes : 4KB = 4096 bytes : 4096/256 = 16
				end
				else if (erase_test == 3'b001) begin
		            max_loop = 32'h80; // 1 PP = 256 bytes : 32KB = 32768 bytes : 32768/256 = 128 
				end
				else if (erase_test == 3'b010) begin
		            max_loop = 32'h100; // 1 PP = 256 bytes : 64KB = 65536 bytes : 65536/256 = 256 
				end
				else begin
		            max_loop = 32'h10; // 1 PP = 256 bytes : 4KB = 4096 bytes : 4096/256 = 16
				end
				for (m_i_i = 32'h0000000; m_i_i < max_loop; m_i_i = m_i_i + 32'h00000001) begin
		        // Page Program	
		            // Standard SPI Write 
		                // flash_command_code == 5'h17 // Page Program
		            // Dual SPI Write 
		                // flash_command_code == 5'h18 // Dual Input Fast Program
		                // flash_command_code == 5'h19 // Extended Dual Input Fast Program
		            // Quad SPI Write 
		                // flash_command_code == 5'h1A // Quad Input Fast Program
		                // flash_command_code == 5'h1B // Extended Quad Input Fast Program
			        
		            // Write 0 to Start transaction Register
		            addr_32b    = START_TRANSACTION_REG_ADDR;
		            wr_data_32b = 32'h00000000;
		            #100; write_to_intf(addr_32b, wr_data_32b);	
			    	
			        $display("# ---INFO : @%0dns :: Setting registers to execute page program operation.", $time);
		            // Write to pkt_header_0 - supported flash command
		            xfer_len_bytes          = 16'h100; // 256 bytes
		            num_wait_state          = 8'h0;  
		            multiple_flash_target   = 1'h0;
		            flash_cmd_code          = 5'h17; // Page Program 
		            with_payload            = 1'h1; 
		            sup_flash_cmd           = 1'h1; 
                    addr_32b                = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_0_REG_ADDR;
		            packet_header_0_wr_data = {xfer_len_bytes, num_wait_state, multiple_flash_target, flash_cmd_code, with_payload, sup_flash_cmd};
		            wr_data_32b             = packet_header_0_wr_data;
		            #100; write_to_intf(addr_32b, wr_data_32b);
		            // Write to pkt_header_1
		            flash_addr_width        = 3'b010; // 24-bit address, need to add EN4B when 32-bit address
		            tgt_cs                  = 5'h0; 
		            data_lane_width         = supported_protocol;  // Standard/Quad SPI
		            addr_lane_width         = supported_protocol;  // Standard/Quad SPI
		            cmd_lane_width          = supported_protocol;  // Standard/Quad SPI
		            packet_header_1_wr_data = {16'h0, flash_addr_width, tgt_cs, 2'h0, data_lane_width, addr_lane_width, cmd_lane_width};
		            addr_32b                = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_1_REG_ADDR;
			        wr_data_32b             = packet_header_1_wr_data;
		            #100; write_to_intf(addr_32b, wr_data_32b);
		            // Write to pkt_header_2 and pkt_header_3
			        addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_2_REG_ADDR;
		            if (m_i_i==0) begin
					   wr_data_32b = pkt_hdr_addr_32b;
					end
					else begin
			            if (DATA_ENDIANNESS == 1 ) begin //Big Endian
					        wr_data_32b        = pkt_hdr_addr_32b + ((256*(m_i_i)<<8));
			            end
			            else begin // Little Endian
						    addr_inc_val       = (256*(m_i_i));
							//addr_inc_val_shift = addr_inc_val[31:24]>>16 + addr_inc_val[23:16]>>8 + addr_inc_val[15:8]<<8;
							addr_inc_val_shift = {addr_inc_val[7:0], addr_inc_val[15:8], addr_inc_val[23:16],  addr_inc_val[31:24]}>>8;
					        wr_data_32b        = pkt_hdr_addr_32b + addr_inc_val_shift;
			            end
					end
		            #100; write_to_intf(addr_32b, wr_data_32b);
			    	if (ENABLE_TRANSMIT_FIFO == 0) begin
			            addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_3_REG_ADDR;
		                wr_data_32b = 32'h0;
		                #100; write_to_intf(addr_32b, wr_data_32b);
			    	end
			        // Write to Interrupt Status Register
		            addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		            wr_data_32b = 32'hFFFFFFFF;
		            #100; write_to_intf(addr_32b, wr_data_32b);
			        // Enable Interrupt Status Register
		            addr_32b    = INTERRUPT_ENABLE_REG_ADDR;
		            wr_data_32b = 32'h00000003;
		            #100; write_to_intf(addr_32b, wr_data_32b);
		            // Write to pkt_data_0
		            addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_DATA_0_REG_ADDR;
		            wr_data_32b = $random;
			        flash_wr_data_32b[0][31:0] = wr_data_32b;
		            #100; write_to_intf(addr_32b, wr_data_32b);
			    	$display("---INFO : @%0dns :: Write Data 0x%x", $time, wr_data_32b);
                    // Write to pkt_data_1
		            addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_DATA_1_REG_ADDR;
		            wr_data_32b = $random;
			        flash_wr_data_32b[1][31:0] = wr_data_32b;
		            #100; write_to_intf(addr_32b, wr_data_32b);
			    	$display("---INFO : @%0dns :: Write Data 0x%x", $time, wr_data_32b);
			        // Start transaction
		            addr_32b    = START_TRANSACTION_REG_ADDR;
		            wr_data_32b = 32'h00000001;
		            #100; write_to_intf(addr_32b, wr_data_32b);
		            // Read TRANSACTION_STATUS
		            #100; read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
			    	$display("# ---INFO : @%0dns :: Polling transaction status register.", $time);
			    	if (rd_data_32b[0] == 1) begin
			    	    $display("# ---INFO : @%0dns :: Page program started.", $time);
			    	end
			    	else begin
			    	    $display("# ---INFO : @%0dns :: Page program not yet started.", $time);
			    	end
			        num_of_bytes = 8;
			    	limit_num_of_bytes = ENABLE_TRANSMIT_FIFO ? (xfer_len_bytes-8) : (xfer_len_bytes-1);
			    	while (num_of_bytes < limit_num_of_bytes) begin // write remaining 254 bytes of data
			    	    read_from_intf(INTERRUPT_STATUS_REG_ADDR, rd_data_32b);
			            if (ENABLE_TRANSMIT_FIFO == 0) begin
			        	    if (rd_data_32b[0] == 1) begin
			                    // Write to Interrupt Status Register
		                        addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		                        wr_data_32b = 32'h00000001;
		                        #100; write_to_intf(addr_32b, wr_data_32b);
		                        // Write to pkt_data_0
		                        addr_32b    = PACKET_DATA_0_REG_ADDR;
		                        wr_data_32b = $random;
			                    flash_wr_data_32b[(num_of_bytes>>2)][31:0] = wr_data_32b;
		                        #100; write_to_intf(addr_32b, wr_data_32b);
			    	            $display("---INFO : @%0dns :: Write Data 0x%x", $time, wr_data_32b);
			        	    	num_of_bytes = num_of_bytes + 4;
			        	    end
			        	    else begin
		                        #50;
			        	    end
			                read_from_intf(INTERRUPT_STATUS_REG_ADDR, rd_data_32b);
			        	    if (rd_data_32b[1] == 1) begin
			                    // Write to Interrupt Status Register
		                        addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		                        wr_data_32b = 32'h00000002;
		                        #100; write_to_intf(addr_32b, wr_data_32b);
		                        // Write to pkt_data_0
		                        addr_32b    = PACKET_DATA_1_REG_ADDR;
		                        wr_data_32b = $random;
			    	            //if (DATA_ENDIANNESS == 1 ) begin // Big Endian
			                    //    flash_wr_data_32b[(num_of_bytes>>2)][31:24] = wr_data_32b[7:0];
			                    //    flash_wr_data_32b[(num_of_bytes>>2)][23:16] = wr_data_32b[15:8];
			                    //    flash_wr_data_32b[(num_of_bytes>>2)][15:8]  = wr_data_32b[23:16];
			                    //    flash_wr_data_32b[(num_of_bytes>>2)][7:0]   = wr_data_32b[31:24];
			    	            //end else begin // Little Endian
			                        flash_wr_data_32b[(num_of_bytes>>2)][31:0] = wr_data_32b;
			    	            //end
		                        #100; write_to_intf(addr_32b, wr_data_32b);
			    	            $display("---INFO : @%0dns :: Write Data 0x%x", $time, wr_data_32b);
			        	    	num_of_bytes = num_of_bytes + 4;
			        	    end
			        	    else begin
		                        #50;
			        	    end
			        	end
			        	else begin// ENABLE_TRANSMIT_FIFO == 1 
			        	    if (rd_data_32b[0] == 1) begin
			                    // Write to Interrupt Status Register
		                        addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		                        wr_data_32b = 32'h00000001;
		                        #100; write_to_intf(addr_32b, wr_data_32b);
		                        // Write to pkt_data_0
		                        addr_32b    = TX_FIFO_MAPPING_REG_ADDR;
		                        wr_data_32b = $random;
			    	            //if (DATA_ENDIANNESS == 1 ) begin // Big Endian
			                    //    flash_wr_data_32b[(num_of_bytes>>2)][31:24] = wr_data_32b[7:0];
			                    //    flash_wr_data_32b[(num_of_bytes>>2)][23:16] = wr_data_32b[15:8];
			                    //    flash_wr_data_32b[(num_of_bytes>>2)][15:8]  = wr_data_32b[23:16];
			                    //    flash_wr_data_32b[(num_of_bytes>>2)][7:0]   = wr_data_32b[31:24];
			    	            //end else begin // Little Endian
			                        flash_wr_data_32b[(num_of_bytes>>2)][31:0] = wr_data_32b;
			    	            //end
		                        #100; write_to_intf(addr_32b, wr_data_32b);
			    	            $display("---INFO : @%0dns :: Write Data 0x%x", $time, wr_data_32b);
			        	    	num_of_bytes = num_of_bytes + 4;
			        	    end
			        	    else begin
		                        #50;
			        	    end
			        	end
			    	end
				    read_from_intf(INTERRUPT_STATUS_REG_ADDR, rd_data_32b);
				    while (rd_data_32b[1:0] != 2'b11) begin
		                read_from_intf(INTERRUPT_STATUS_REG_ADDR, rd_data_32b);
		                #100;
		            end
			        // Write to Interrupt Status Register
		            addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		            wr_data_32b = 32'hFFFFFFFF;
		            #100; write_to_intf(addr_32b, wr_data_32b);
		            read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
			    	$display("# ---INFO : @%0dns :: Polling transaction status register.", $time);	
                    if (rd_data_32b[0] == 1) $display("# ---INFO : @%0dns :: Page program is still on-going.", $time);				
		            while (rd_data_32b[0] == 1) begin
		                read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
		                #100;
		            end
			    	$display("# ---INFO : @%0dns :: Page program done.", $time);
			    
		        // Standard SPI Read 	
		            // flash_command_code == 5'h0A // Read Data
		            // flash_command_code == 5'h0B // Fast Read
		        // Dual SPI Read
		            // flash_command_code == 5'h0C // Dual Output Fast Read
		            // flash_command_code == 5'h0D // Dual Input/Output Fast Read
		        // Quad SPI Read
		            // flash_command_code == 5'h0E // Quad Output Fast Read
		            // flash_command_code == 5'h0F // Quad Input/Output Fast Read
			        
		            // Write 0 to Start transaction Register
		            addr_32b    = START_TRANSACTION_REG_ADDR;
		            wr_data_32b = 32'h00000000;
		            #100; write_to_intf(addr_32b, wr_data_32b);
			    	
			        $display("# ---INFO : @%0dns :: Setting registers to execute page read operation.", $time);
			        xfer_len_bytes          = 16'h100; // 256 bytes
					if (supported_protocol == 2'b00) begin // Standard Mode
			            if (standard_spi_fast_read_en == 0) begin
		                    flash_cmd_code        = 5'h0A; // Read Data 
		                    num_wait_state        = 8'h0;
			            end
			            else begin
		                    flash_cmd_code        = 5'h0B; // Fast Read  
		                    num_wait_state        = 8'h08;
			            end
					end
					else if (supported_protocol == 2'b10) begin // Quad Mode
		                flash_cmd_code        = 5'h0F; // Read Data 
		                num_wait_state        = 8'h6;
					end
		            with_payload          = 1'h0; 
		            sup_flash_cmd         = 1'h1; 
		            addr_32b = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_0_REG_ADDR;
		            packet_header_0_wr_data = {xfer_len_bytes, num_wait_state, multiple_flash_target, flash_cmd_code, with_payload, sup_flash_cmd};
		            wr_data_32b = packet_header_0_wr_data;
		            #100; write_to_intf(addr_32b, wr_data_32b);
		            // Write to pkt_header_1
		            flash_addr_width        = 3'b010; // 24-bit address, need to add EN4B when 32-bit address
		            tgt_cs                  = 5'h0; 
		            data_lane_width         = supported_protocol;  // Standard/Quad SPI
		            addr_lane_width         = supported_protocol;  // Standard/Quad SPI
		            cmd_lane_width          = supported_protocol;  // Standard/Quad SPI 
		            packet_header_1_wr_data = {16'h0, flash_addr_width, tgt_cs, 2'h0, data_lane_width, addr_lane_width, cmd_lane_width};
		            addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_1_REG_ADDR;
			        wr_data_32b = packet_header_1_wr_data;
		            #100; write_to_intf(addr_32b, wr_data_32b);
		            // Write to pkt_header_2 and pkt_header_3
		            addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_2_REG_ADDR;
		            if (m_i_i==0) begin
					   wr_data_32b = pkt_hdr_addr_32b;
					end
					else begin
			            if (DATA_ENDIANNESS == 1 ) begin //Big Endian
					        wr_data_32b        = pkt_hdr_addr_32b + ((256*(m_i_i)<<8));
			            end
			            else begin // Little Endian
						    addr_inc_val       = (256*(m_i_i));
							//addr_inc_val_shift = addr_inc_val[31:24]>>16 + addr_inc_val[23:16]>>8 + addr_inc_val[15:8]<<8;
							addr_inc_val_shift = {addr_inc_val[7:0], addr_inc_val[15:8], addr_inc_val[23:16],  addr_inc_val[31:24]}>>8;
					        wr_data_32b        = pkt_hdr_addr_32b + addr_inc_val_shift;
			            end
					end
		            #100; write_to_intf(addr_32b, wr_data_32b);
			    	if (ENABLE_TRANSMIT_FIFO == 0) begin
		               addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_3_REG_ADDR;
		               wr_data_32b = 32'h0;
		               #100; write_to_intf(addr_32b, wr_data_32b);
			    	end
			        // Write to Interrupt Status Register
		            addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		            wr_data_32b = 32'hFFFFFFFF;
		            #100; write_to_intf(addr_32b, wr_data_32b);
			        // Enable Interrupt Status Register
		            addr_32b    = INTERRUPT_ENABLE_REG_ADDR;
		            wr_data_32b = 32'h00000030;
		            #100; write_to_intf(addr_32b, wr_data_32b);
		            // Start transaction
		            addr_32b    = START_TRANSACTION_REG_ADDR;
		            wr_data_32b = 32'h00000001;
		            #100; write_to_intf(addr_32b, wr_data_32b);
		            // Read TRANSACTION_STATUS
		            #100; read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
			    	$display("# ---INFO : @%0dns :: Polling transaction status register.", $time);
			    	if (rd_data_32b[0] == 1) begin
			    	    $display("# ---INFO : @%0dns :: Page read started.", $time);
			    	end
			    	else begin
			    	    $display("# ---INFO : @%0dns :: Page read not yet started.", $time);
			    	end	
			        num_of_bytes = 0;
			    	//limit_num_of_bytes = ENABLE_RECEIVE_FIFO ? (xfer_len_bytes+1) : (xfer_len_bytes-3);
			    	while (num_of_bytes < xfer_len_bytes-1) begin
			            read_from_intf(INTERRUPT_STATUS_REG_ADDR, rd_data_32b);
			        	if (rd_data_32b[4] == 1) begin
		                    //Read from pkt_data_0
			    			addr_32b = ENABLE_RECEIVE_FIFO ? RX_FIFO_MAPPING_REG_ADDR : PACKET_DATA_0_REG_ADDR;
			                read_from_intf(addr_32b, rd_data_32b);
			                flash_rd_data_32b[(num_of_bytes>>2)][31:0] = rd_data_32b;
                            do_data_compare(flash_wr_data_32b[(num_of_bytes>>2)],flash_rd_data_32b[(num_of_bytes>>2)]);
		                    //#100;
			                // Write to Interrupt Status Register
		                    addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		                    wr_data_32b = 32'h00000010;
		                    //#100; 
							write_to_intf(addr_32b, wr_data_32b);
			                read_from_intf(INTERRUPT_STATUS_REG_ADDR, rd_data_32b);
			        		num_of_bytes = num_of_bytes + 4;
			        	end
			        	else begin
		                    #100;
			        	end
			    	end
		            read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);	
			    	$display("# ---INFO : @%0dns :: Polling transaction status register.", $time);		
		            while (rd_data_32b[0] == 1) begin
		                read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
		                #100;
			    	    if (rd_data_32b[0] == 1) begin
			    	        $display("# ---INFO : @%0dns :: Page read still on-going.", $time);
			    	    end
			    	    else begin
			    	        $display("# ---INFO : @%0dns :: Page read done.", $time);
			    	    end	
		            end
				end
				
			    // Exit Quad Mode of the flash
			    if (supported_protocol == 2'b10) begin
				    disable_quad_io();
			    end
		end
	endtask
		
	// Erase-Write-Read Sequence using Supported Commands for FIFO Enabled Only
	// For Write and Read Sequence, with FIFO enabled, writing/reading to registers and TX/RX FIFO are the same.
	// Write : Write all packet data to FIFO first before starting the transaction.
    // Read  : Reading all packet data from FIFO after the read transaction is done.	
	task erase_write_read_using_supported_commands_fifo_enabled;
	    input [31:0] flash_addr;
		input [1:0] supported_protocol;
        reg [31:0] addr_32b;
        reg [31:0] flash_addr_32b;
        reg [31:0] flash_wr_data_32b [255:0];
        reg [31:0] flash_rd_data_32b [255:0];
        reg [31:0] pkt_hdr_addr_32b;
        reg [31:0] wr_data_32b;
		reg [31:0] rd_data_32b;
		reg [31:0] num_of_bytes;
		integer m_i_i;
		integer m_j_i;
		integer qspi_config_0_val_sel;
		integer standard_spi_read_cmd_sel;
		
		//QSPI_CONFIG_REG_0_REG_ADDR
		reg [31:0] qspi_config_0_wr_data;
		reg en_frame_end_done_cntr;
        reg en_flash_address_space_map;
        reg data_endianness;                        
        reg [4:0] sck_rate;
		reg chip_select_behaviour;                  
        reg [2:0] min_idle_time;  
        reg en_back_to_back_trans;		
        reg cpha;                                   
        reg cpol;                                   
        reg first_bit_transfer;
		
		//QSPI_CONFIG_REG_1_REG_ADDR
		reg [31:0] qspi_config_1_wr_data;
		reg [15:0] trgt_rd_trans_cnt;
		reg [15:0] trgt_wr_trans_cnt;
		
		//PACKET_HEADER_0
		reg [31:0] packet_header_0_wr_data;
		reg [15:0] xfer_len_bytes; 
		reg [7:0] num_wait_state;  
		reg multiple_flash_target; 
		reg [4:0] flash_cmd_code;  
		reg with_payload;          
		reg sup_flash_cmd;  

		//PACKET_HEADER_1
		reg [31:0] packet_header_1_wr_data;
        reg [2:0] flash_addr_width;
        reg [4:0] tgt_cs;          
        reg [1:0] data_lane_width; 
        reg [1:0] addr_lane_width; 
        reg [1:0] cmd_lane_width;  		
		
	    begin
			    #12000; // wait for a_reset_n_i assertion
			    #1000;
				if (supported_protocol == 2'b00) begin
			        $display("# ---INFO : @%0dns :: Test Name : erase_write_read_using_supported_commands_fifo_enabled_standard_spi", $time);
			    end
				else if (supported_protocol == 2'b10) begin
			        $display("# ---INFO : @%0dns :: Test Name : erase_write_read_using_supported_commands_fifo_enabled_quad_spi", $time);
			    end
			    pkt_hdr_addr_32b           = flash_addr;
		        // Write to config0 - Configuration Register 0, this setting will be used for Erase, Write and Read Operation
		        en_frame_end_done_cntr     = 1'h0;
                en_flash_address_space_map = 1'h0;
                data_endianness            = 1'h0;                        
                sck_rate                   = 5'h02;
		        chip_select_behaviour      = 1'h0;                  
                min_idle_time              = 3'h0;  
                en_back_to_back_trans      = 1'h0;		
                cpha                       = 1'h0;                                    
                cpol                       = 1'h0; 	                                   
                first_bit_transfer         = 1'h0;
			    addr_32b                   = QSPI_CONFIG_REG_0_REG_ADDR;
			    qspi_config_0_wr_data      = {16'b0, en_frame_end_done_cntr, en_flash_address_space_map, 
			                                  data_endianness, sck_rate, chip_select_behaviour, min_idle_time, 
			    						      en_back_to_back_trans, cpha, cpol, first_bit_transfer};
			    wr_data_32b = qspi_config_0_wr_data;
			    if (overwrite_gui_settings == 1) begin
			        #100; write_to_intf(addr_32b, wr_data_32b);
			    end
			    // Write to config1 - Configuration Register 1, this setting will be used for Write and Read Operation
		        trgt_rd_trans_cnt     = 16'h100;
			    trgt_wr_trans_cnt     = 16'h100;
			    addr_32b              = QSPI_CONFIG_REG_1_REG_ADDR;
			    qspi_config_1_wr_data = {trgt_rd_trans_cnt, trgt_wr_trans_cnt};
			    wr_data_32b           = qspi_config_1_wr_data;
			    #100; write_to_intf(addr_32b, wr_data_32b);
				
				if(supported_protocol == 2'b10) begin
				    enable_quad_io();
				end
				
		    // Erase - For MX25L51245G can work on Standard SPI and Quad SPI
		        // flash_command_code == 5'h10 // Block Erase Type 1
		        // flash_command_code == 5'h11 // Block Erase Type 2
		        // flash_command_code == 5'h12 // Block Erase Type 3
		        // flash_command_code == 5'h13 // Chip Erase
				
		        // Write 0 to Start transaction Register
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000000;
		        #100; write_to_intf(addr_32b, wr_data_32b);
			    $display("# ---INFO : @%0dns :: Setting registers to execute erase operation.", $time);
		        // Write to pkt_header_0 - supported flash command
		        xfer_len_bytes          = 16'h0;
		        num_wait_state          = 8'h0;
		        multiple_flash_target   = 1'h0;
		        flash_cmd_code          = 5'h10; // Block Erase Type 1 
		        with_payload            = 1'h0; 
		        sup_flash_cmd           = 1'h1;
			    addr_32b                = TX_FIFO_MAPPING_REG_ADDR;
		        packet_header_0_wr_data = {xfer_len_bytes, num_wait_state, multiple_flash_target, flash_cmd_code, with_payload, sup_flash_cmd};
		        wr_data_32b             = packet_header_0_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_1
		        flash_addr_width        = 3'b010; // 24-bit address, need to add EN4B when 32-bit address
		        tgt_cs                  = 5'h0; 
		        data_lane_width         = supported_protocol;  // Standard/Quad SPI
		        addr_lane_width         = supported_protocol;  // Standard/Quad SPI
		        cmd_lane_width          = supported_protocol;  // Standard/Quad SPI
		        packet_header_1_wr_data = {16'h0, flash_addr_width, tgt_cs, 2'h0, data_lane_width, addr_lane_width, cmd_lane_width};
                addr_32b    = TX_FIFO_MAPPING_REG_ADDR;
		        wr_data_32b = packet_header_1_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_2 and pkt_header_3
                addr_32b    = TX_FIFO_MAPPING_REG_ADDR;
		        wr_data_32b = pkt_hdr_addr_32b;
		        #100; write_to_intf(addr_32b, wr_data_32b);
                //addr_32b    = TX_FIFO_MAPPING_REG_ADDR;  <-- removed since only 24-bit flash address is used
		        // wr_data_32b = 32'h0;
		        //#100; write_to_intf(addr_32b, wr_data_32b);
		        // Start transaction
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000001;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Read TRANSACTION_STATUS
		        #100; read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
				$display("# ---INFO : @%0dns :: Polling transaction status register.", $time);
				if (rd_data_32b[0] == 1) begin
				    $display("# ---INFO : @%0dns :: Erase operation started.", $time);
				end
				else begin
				    $display("# ---INFO : @%0dns :: Erase operation not yet started.", $time);
				end
		        while (rd_data_32b[0] == 1) begin
		            read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b); #100;
		        end
				$display("# ---INFO : @%0dns :: Erase operation done.", $time);
			    
		    // Page Program	
		        // Standard SPI Write 
		            // flash_command_code == 5'h17 // Page Program
		        // Dual SPI Write 
		            // flash_command_code == 5'h18 // Dual Input Fast Program
		            // flash_command_code == 5'h19 // Extended Dual Input Fast Program
		        // Quad SPI Write 
		            // flash_command_code == 5'h1A // Quad Input Fast Program
		            // flash_command_code == 5'h1B // Extended Quad Input Fast Program
			    
		        // Write 0 to Start transaction Register
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000000;
		        #100; write_to_intf(addr_32b, wr_data_32b);	
			    $display("# ---INFO : @%0dns :: Setting registers to execute page program operation.", $time);
		        // Write to pkt_header_0 - supported flash command
		        xfer_len_bytes          = 16'h100; // 256 bytes
		        num_wait_state          = 8'h0; 
		        multiple_flash_target   = 1'h0;
		        flash_cmd_code          = 5'h17; // Page Program 
		        with_payload            = 1'h1; 
		        sup_flash_cmd           = 1'h1; 
                addr_32b                = TX_FIFO_MAPPING_REG_ADDR;
		        packet_header_0_wr_data = {xfer_len_bytes, num_wait_state, multiple_flash_target, flash_cmd_code, with_payload, sup_flash_cmd};
		        wr_data_32b             = packet_header_0_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_1
		        flash_addr_width        = 3'b010; // 24-bit address, need to add EN4B when 32-bit address
		        tgt_cs                  = 5'h0; 
		        data_lane_width         = supported_protocol;  // Standard/Quad SPI
		        addr_lane_width         = supported_protocol;  // Standard/Quad SPI
		        cmd_lane_width          = supported_protocol;  // Standard/Quad SPI
		        packet_header_1_wr_data = {16'h0, flash_addr_width, tgt_cs, 2'h0, data_lane_width, addr_lane_width, cmd_lane_width};
		        addr_32b                = TX_FIFO_MAPPING_REG_ADDR;
			    wr_data_32b             = packet_header_1_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_2 and pkt_header_3
			    addr_32b    = TX_FIFO_MAPPING_REG_ADDR;
		        wr_data_32b = pkt_hdr_addr_32b;
		        #100; write_to_intf(addr_32b, wr_data_32b);
			    //addr_32b    = TX_FIFO_MAPPING_REG_ADDR;   <-- removed since only 24-bit flash address is used
		        //wr_data_32b = 32'h0;
		        //#100; write_to_intf(addr_32b, wr_data_32b);
			    // Write to Interrupt Status Register
		        addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		        wr_data_32b = 32'hFFFFFFFF;
		        #100; write_to_intf(addr_32b, wr_data_32b);
			    // Enable Interrupt Status Register
		        // addr_32b    = INTERRUPT_ENABLE_REG_ADDR;
		        // wr_data_32b = 32'h00000003;
		        //#100; write_to_intf(addr_32b, wr_data_32b);
			    for(m_i_i = 0; m_i_i < ((xfer_len_bytes)>>2); m_i_i = m_i_i +1) begin
		            // Write to TX FIFO
		            addr_32b    = TX_FIFO_MAPPING_REG_ADDR;
		            wr_data_32b = $random;
			        flash_wr_data_32b[(m_i_i)][31:0] = wr_data_32b;
				    $display("---INFO : @%0dns :: Write Data 0x%x", $time, wr_data_32b);
		            #100; write_to_intf(addr_32b, wr_data_32b);
			    end
			    // Start transaction
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000001;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Read TRANSACTION_STATUS
		        #100; read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
				$display("# ---INFO : @%0dns :: Polling transaction status register.", $time);
				if (rd_data_32b[0] == 1) begin
				    $display("# ---INFO : @%0dns :: Page program started.", $time);
				end
				else begin
				    $display("# ---INFO : @%0dns :: Page program not yet started.", $time);
				end
		        while (rd_data_32b[0] == 1) begin
		            read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
		            #100;
		        end
				$display("# ---INFO : @%0dns :: Page program done.", $time);
			    
		    // Standard SPI Read 	
		        // flash_command_code == 5'h0A // Read Data
		        // flash_command_code == 5'h0B // Fast Read
		    // Dual SPI Read
		        // flash_command_code == 5'h0C // Dual Output Fast Read
		        // flash_command_code == 5'h0D // Dual Input/Output Fast Read
		    // Quad SPI Read
		        // flash_command_code == 5'h0E // Quad Output Fast Read
		        // flash_command_code == 5'h0F // Quad Input/Output Fast Read
			    
		        // Write 0 to Start transaction Register
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000000;
		        #100; write_to_intf(addr_32b, wr_data_32b);
			    $display("# ---INFO : @%0dns :: Setting registers to execute page read operation.", $time);
		        xfer_len_bytes        = 16'h100;
		        multiple_flash_target = 1'h0;
				if (supported_protocol == 2'b00) begin // Standard Mode
			        if (standard_spi_fast_read_en == 0) begin
		                flash_cmd_code        = 5'h0A; // Read Data 
		                num_wait_state        = 8'h0;
			        end
			        else begin
		                flash_cmd_code        = 5'h0B; // Fast Read  
		                num_wait_state        = 8'h08;
			        end
				end
				else if (supported_protocol == 2'b10) begin // Quad Mode
		            flash_cmd_code        = 5'h0F; // Read Data 
		            num_wait_state        = 8'h6;
				end
		        with_payload          = 1'h1; 
		        sup_flash_cmd         = 1'h1; 
		        addr_32b = TX_FIFO_MAPPING_REG_ADDR;
		        packet_header_0_wr_data = {xfer_len_bytes, num_wait_state, multiple_flash_target, flash_cmd_code, with_payload, sup_flash_cmd};
		        wr_data_32b = packet_header_0_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_1
		        flash_addr_width      = 3'b010; // 24-bit address, need to add EN4B when 32-bit address
		        tgt_cs                = 5'h0; 
		        data_lane_width       = supported_protocol;  // Standard/Quad SPI
		        addr_lane_width       = supported_protocol;  // Standard/Quad SPI
		        cmd_lane_width        = supported_protocol;  // Standard/Quad SPI
		        packet_header_1_wr_data = {16'h0, flash_addr_width, tgt_cs, 2'h0, data_lane_width, addr_lane_width, cmd_lane_width};
		        addr_32b    = TX_FIFO_MAPPING_REG_ADDR;
			    wr_data_32b = packet_header_1_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_2 and pkt_header_3
		        addr_32b    = TX_FIFO_MAPPING_REG_ADDR;
		        wr_data_32b = pkt_hdr_addr_32b;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        //addr_32b    = TX_FIFO_MAPPING_REG_ADDR;   <-- removed since only 24-bit flash address is used
		        //wr_data_32b = 32'h0;
		        //#100; write_to_intf(addr_32b, wr_data_32b);
			    // Write to Interrupt Status Register
		        addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		        wr_data_32b = 32'hFFFFFFFF;
		        #100; write_to_intf(addr_32b, wr_data_32b);
			    // Enable Interrupt Status Register
		        //addr_32b    = INTERRUPT_ENABLE_REG_ADDR;
		        //wr_data_32b = 32'h00000030;
		        //#100; write_to_intf(addr_32b, wr_data_32b);
		        // Start transaction
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000001;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Read TRANSACTION_STATUS
		        #100; read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
				$display("# ---INFO : @%0dns :: Polling transaction status register.", $time);
				if (rd_data_32b[0] == 1) begin
				    $display("# ---INFO : @%0dns :: Page read started.", $time);
				end
				else begin
				    $display("# ---INFO : @%0dns :: Page read not yet started.", $time);
				end	
		        while (rd_data_32b[0] == 1) begin
		            read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
		            #100;
		        end
				$display("# ---INFO : @%0dns :: Page read done.", $time);
				num_of_bytes = 0;
			    for(m_i_i = 0; m_i_i < ((xfer_len_bytes)>>2); m_i_i = m_i_i +1) begin 
			        read_from_intf(RX_FIFO_MAPPING_REG_ADDR, rd_data_32b);
			        flash_rd_data_32b[m_i_i][31:0] = rd_data_32b;
					//#100;
                    do_data_compare(flash_wr_data_32b[m_i_i],flash_rd_data_32b[m_i_i]);
				end
				
				if (supported_protocol == 2'b10) begin
				    disable_quad_io();
				end
		end
	endtask	
	
	// Erase-Write-Read Sequence using Supported Commands for FIFO Enabled Only
	// For Write and Read Sequence, with FIFO enabled, writing/reading to registers and TX/RX FIFO are the same.
	// Write : Write all packet data to FIFO first before starting the transaction.
    // Read  : Reading all packet data from FIFO after the read transaction is done.	
	task erase_write_read_using_supported_commands_fifo_enabled_less_xfer_len;
	    input [31:0] flash_addr;
		input [1:0] erase_test;
		input [1:0] supported_protocol;
        reg [31:0] addr_32b;
        reg [31:0] flash_addr_32b;
        reg [31:0] flash_wr_data_32b [262143:0];
        reg [31:0] flash_rd_data_32b [262143:0];
        reg [31:0] pkt_hdr_addr_32b;
        reg [31:0] wr_data_32b;
		reg [31:0] rd_data_32b;
		reg [31:0] num_of_bytes;
		reg [31:0] fifo_depth;
		integer m_i_i;
		integer m_j_i;
		integer qspi_config_0_val_sel;
		integer standard_spi_read_cmd_sel;
		
		//QSPI_CONFIG_REG_0_REG_ADDR
		reg [31:0] qspi_config_0_wr_data;
		reg en_frame_end_done_cntr;
        reg en_flash_address_space_map;
        reg data_endianness;                        
        reg [4:0] sck_rate;
		reg chip_select_behaviour;                  
        reg [2:0] min_idle_time;  
        reg en_back_to_back_trans;		
        reg cpha;                                   
        reg cpol;                                   
        reg first_bit_transfer;
		
		//QSPI_CONFIG_REG_1_REG_ADDR
		reg [31:0] qspi_config_1_wr_data;
		reg [15:0] trgt_rd_trans_cnt;
		reg [15:0] trgt_wr_trans_cnt;
		
		//PACKET_HEADER_0
		reg [31:0] packet_header_0_wr_data;
		reg [15:0] xfer_len_bytes; 
		reg [7:0] num_wait_state;  
		reg multiple_flash_target; 
		reg [4:0] flash_cmd_code;  
		reg with_payload;          
		reg sup_flash_cmd;  

		//PACKET_HEADER_1
		reg [31:0] packet_header_1_wr_data;
        reg [2:0] flash_addr_width;
        reg [4:0] tgt_cs;          
        reg [1:0] data_lane_width; 
        reg [1:0] addr_lane_width; 
        reg [1:0] cmd_lane_width;  		
		
	    begin
			    #12000; // wait for a_reset_n_i assertion
			    #1000;
				if (supported_protocol == 2'b00) begin
			        $display("# ---INFO : @%0dns :: Test Name : erase_write_read_using_supported_commands_fifo_enabled_less_xfer_len_standard_spi", $time);
			    end
				else if (supported_protocol == 2'b10) begin
			        $display("# ---INFO : @%0dns :: Test Name : erase_write_read_using_supported_commands_fifo_enabled_less_xfer_len_quad_spi", $time);
			    end
			    
				pkt_hdr_addr_32b    = flash_addr;
				
		        // Write to config0 - Configuration Register 0, this setting will be used for Erase, Write and Read Operation
		        en_frame_end_done_cntr     = 1'h0;
                en_flash_address_space_map = 1'h0;
                data_endianness            = 1'h0;                        
                sck_rate                   = 5'h02;
		        chip_select_behaviour      = 1'h0;                  
                min_idle_time              = 3'h0;  
                en_back_to_back_trans      = 1'h0;		
                cpha                       = 1'h0;                                    
                cpol                       = 1'h0; 	                                   
                first_bit_transfer         = 1'h0;
			    addr_32b                   = QSPI_CONFIG_REG_0_REG_ADDR;
			    qspi_config_0_wr_data      = {16'b0, en_frame_end_done_cntr, en_flash_address_space_map, 
			                                  data_endianness, sck_rate, chip_select_behaviour, min_idle_time, 
			    						      en_back_to_back_trans, cpha, cpol, first_bit_transfer};
			    wr_data_32b = qspi_config_0_wr_data;
			    if (overwrite_gui_settings == 1) begin
			        #100; write_to_intf(addr_32b, wr_data_32b);
			    end
			    // Write to config1 - Configuration Register 1, this setting will be used for Write and Read Operation
		        trgt_rd_trans_cnt     = 16'h100;
			    trgt_wr_trans_cnt     = 16'h100;
			    addr_32b              = QSPI_CONFIG_REG_1_REG_ADDR;
			    qspi_config_1_wr_data = {trgt_rd_trans_cnt, trgt_wr_trans_cnt};
			    wr_data_32b           = qspi_config_1_wr_data;
			    #100; write_to_intf(addr_32b, wr_data_32b);
				
				if(supported_protocol == 2'b10) begin
				    enable_quad_io();
				end
				
		    // Erase - For MX25L51245G can work on Standard SPI and Quad SPI
		        // flash_command_code == 5'h10 // Block Erase Type 1
		        // flash_command_code == 5'h11 // Block Erase Type 2
		        // flash_command_code == 5'h12 // Block Erase Type 3
		        // flash_command_code == 5'h13 // Chip Erase
				
		        // Write 0 to Start transaction Register
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000000;
		        #100; write_to_intf(addr_32b, wr_data_32b);
			    $display("# ---INFO : @%0dns :: Setting registers to execute erase operation.", $time);
		        // Write to pkt_header_0 - supported flash command
		        xfer_len_bytes          = 16'h0;
		        num_wait_state          = 8'h0;
		        multiple_flash_target   = 1'h0;
				if (erase_test == 3'b000) begin
		            flash_cmd_code          = 5'h10; // Block Erase Type 1 
				end
				else if (erase_test == 3'b001) begin
		            flash_cmd_code          = 5'h11; // Block Erase Type 2
				end
				else if (erase_test == 3'b010) begin
		            flash_cmd_code          = 5'h12; // Block Erase Type 3 
				end
				else begin
		            flash_cmd_code          = 5'h10; // Block Erase Type 1 
				end
		        with_payload            = 1'h0; 
		        sup_flash_cmd           = 1'h1;
			    addr_32b                = TX_FIFO_MAPPING_REG_ADDR;
		        packet_header_0_wr_data = {xfer_len_bytes, num_wait_state, multiple_flash_target, flash_cmd_code, with_payload, sup_flash_cmd};
		        wr_data_32b             = packet_header_0_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_1
		        flash_addr_width        = 3'b010; // 24-bit address, need to add EN4B when 32-bit address
		        tgt_cs                  = 5'h0; 
		        data_lane_width         = supported_protocol;  // Standard/Quad SPI
		        addr_lane_width         = supported_protocol;  // Standard/Quad SPI
		        cmd_lane_width          = supported_protocol;  // Standard/Quad SPI
		        packet_header_1_wr_data = {16'h0, flash_addr_width, tgt_cs, 2'h0, data_lane_width, addr_lane_width, cmd_lane_width};
                addr_32b    = TX_FIFO_MAPPING_REG_ADDR;
		        wr_data_32b = packet_header_1_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_2 and pkt_header_3
                addr_32b    = TX_FIFO_MAPPING_REG_ADDR;
		        wr_data_32b = pkt_hdr_addr_32b;
		        #100; write_to_intf(addr_32b, wr_data_32b);
                //addr_32b    = TX_FIFO_MAPPING_REG_ADDR;  <-- removed since only 24-bit flash address is used
		        // wr_data_32b = 32'h0;
		        //#100; write_to_intf(addr_32b, wr_data_32b);
		        // Start transaction
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000001;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Read TRANSACTION_STATUS
		        #100; read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
				$display("# ---INFO : @%0dns :: Polling transaction status register.", $time);
				if (rd_data_32b[0] == 1) begin
				    $display("# ---INFO : @%0dns :: Erase operation started.", $time);
				end
				else begin
				    $display("# ---INFO : @%0dns :: Erase operation not yet started.", $time);
				end
		        while (rd_data_32b[0] == 1) begin
		            read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b); #100;
		        end
				$display("# ---INFO : @%0dns :: Erase operation done.", $time);
			    
		    // Page Program	
		        // Standard SPI Write 
		            // flash_command_code == 5'h17 // Page Program
		        // Dual SPI Write 
		            // flash_command_code == 5'h18 // Dual Input Fast Program
		            // flash_command_code == 5'h19 // Extended Dual Input Fast Program
		        // Quad SPI Write 
		            // flash_command_code == 5'h1A // Quad Input Fast Program
		            // flash_command_code == 5'h1B // Extended Quad Input Fast Program
			    
		        // Write 0 to Start transaction Register
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000000;
		        #100; write_to_intf(addr_32b, wr_data_32b);	
			    $display("# ---INFO : @%0dns :: Setting registers to execute page program operation.", $time);
		        // Write to pkt_header_0 - supported flash command
				if (erase_test == 3'b000) begin
		            //xfer_len_bytes          = 16'h1000; // 4KB = 4096 bytes 
		            //xfer_len_bytes          = 16'h0200; // 4KB = 4096 bytes 
		            xfer_len_bytes          = 16'h0100; // 4KB = 4096 bytes 
				end
				else if (erase_test == 3'b001) begin
		            xfer_len_bytes          = 16'h8000; // 32KB = 32768 bytes
				end
				else if (erase_test == 3'b010) begin
		            xfer_len_bytes          = 16'h8000; // 32KB = 32768 bytes 
				end
				else begin
		            xfer_len_bytes          = 16'h1000; // 4KB = 4096 bytes 
				end
		        num_wait_state          = 8'h0; 
		        multiple_flash_target   = 1'h0;
		        flash_cmd_code          = 5'h17; // Page Program 
		        with_payload            = 1'h1; 
		        sup_flash_cmd           = 1'h1; 
                addr_32b                = TX_FIFO_MAPPING_REG_ADDR;
		        packet_header_0_wr_data = {xfer_len_bytes, num_wait_state, multiple_flash_target, flash_cmd_code, with_payload, sup_flash_cmd};
		        wr_data_32b             = packet_header_0_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_1
		        flash_addr_width        = 3'b010; // 24-bit address, need to add EN4B when 32-bit address
		        tgt_cs                  = 5'h0; 
		        data_lane_width         = supported_protocol;  // Standard/Quad SPI
		        addr_lane_width         = supported_protocol;  // Standard/Quad SPI
		        cmd_lane_width          = supported_protocol;  // Standard/Quad SPI
		        packet_header_1_wr_data = {16'h0, flash_addr_width, tgt_cs, 2'h0, data_lane_width, addr_lane_width, cmd_lane_width};
		        addr_32b                = TX_FIFO_MAPPING_REG_ADDR;
			    wr_data_32b             = packet_header_1_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_2 and pkt_header_3
			    addr_32b    = TX_FIFO_MAPPING_REG_ADDR;
		        wr_data_32b = pkt_hdr_addr_32b;
		        #100; write_to_intf(addr_32b, wr_data_32b);
			    //addr_32b    = TX_FIFO_MAPPING_REG_ADDR;   <-- removed since only 24-bit flash address is used
		        //wr_data_32b = 32'h0;
		        //#100; write_to_intf(addr_32b, wr_data_32b);
			    // Write to Interrupt Status Register
		        addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		        wr_data_32b = 32'hFFFFFFFF;
		        #100; write_to_intf(addr_32b, wr_data_32b);
			    // Enable Interrupt Status Register
		        addr_32b    = INTERRUPT_ENABLE_REG_ADDR;
		        wr_data_32b = 32'h00000008;
		        #100; write_to_intf(addr_32b, wr_data_32b);
				// Write to whole FIFO
				fifo_depth = ADDRESS_DEPTH_TX;
			    for(m_i_i = 0; m_i_i < (32'h020); m_i_i = m_i_i +1) begin
		            // Write to TX FIFO
		            addr_32b    = TX_FIFO_MAPPING_REG_ADDR;
		            wr_data_32b = $random;
			        flash_wr_data_32b[(m_i_i)][31:0] = wr_data_32b;
				    $display("---INFO : @%0dns :: Write Data 0x%x", $time, wr_data_32b);
		            #100; write_to_intf(addr_32b, wr_data_32b);
			    end
			    // Start transaction
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000001;
		        //#100; 
				write_to_intf(addr_32b, wr_data_32b);
		        // Read TRANSACTION_STATUS
		        //#100; 
				read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
				$display("# ---INFO : @%0dns :: Polling transaction status register.", $time);
				if (rd_data_32b[0] == 1) begin
				    $display("# ---INFO : @%0dns :: Page program started.", $time);
				end
				else begin
				    $display("# ---INFO : @%0dns :: Page program not yet started.", $time);
				end
				//num_of_bytes = 32'h800;
				num_of_bytes = 32'h80;
		        while (num_of_bytes < xfer_len_bytes-1) begin
			        // Enable Interrupt Status Register
		            //addr_32b    = INTERRUPT_ENABLE_REG_ADDR;
		            //wr_data_32b = 32'h00000008;
		            //#100; write_to_intf(addr_32b, wr_data_32b);
		            read_from_intf(INTERRUPT_STATUS_REG_ADDR, rd_data_32b);
					if (rd_data_32b[3] != 1) begin
		                // Write to TX FIFO
		                addr_32b    = TX_FIFO_MAPPING_REG_ADDR;
		                wr_data_32b = $random;
			            //flash_wr_data_32b[(m_i_i+32'h200)][31:0] = wr_data_32b;
			            flash_wr_data_32b[num_of_bytes>>2][31:0] = wr_data_32b;
		                //#100; 
						write_to_intf(addr_32b, wr_data_32b);
				        $display("---INFO : @%0dns :: Write Data 0x%x", $time, wr_data_32b);
						num_of_bytes = num_of_bytes + 32'h04;
					end
					else begin
					   #100;
					end
		        end
		        // Read TRANSACTION_STATUS
		        #100; read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
				$display("# ---INFO : @%0dns :: Polling transaction status register.", $time);
				if (rd_data_32b[0] == 1) begin
				    $display("# ---INFO : @%0dns :: Page program is still on-going.", $time);
				end
			    while (rd_data_32b[0] == 1) begin
		               read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
		               #100;
		        end
			    $display("# ---INFO : @%0dns :: Page program done.", $time);
				
		    // Standard SPI Read 	
		        // flash_command_code == 5'h0A // Read Data
		        // flash_command_code == 5'h0B // Fast Read
		    // Dual SPI Read
		        // flash_command_code == 5'h0C // Dual Output Fast Read
		        // flash_command_code == 5'h0D // Dual Input/Output Fast Read
		    // Quad SPI Read
		        // flash_command_code == 5'h0E // Quad Output Fast Read
		        // flash_command_code == 5'h0F // Quad Input/Output Fast Read
			    
		        // Write 0 to Start transaction Register
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000000;
		        #100; write_to_intf(addr_32b, wr_data_32b);
			    $display("# ---INFO : @%0dns :: Setting registers to execute page read operation.", $time);
		        xfer_len_bytes        = 16'h100;
		        multiple_flash_target = 1'h0;
				if (supported_protocol == 2'b00) begin // Standard Mode
			        if (standard_spi_fast_read_en == 0) begin
		                flash_cmd_code        = 5'h0A; // Read Data 
		                num_wait_state        = 8'h0;
			        end
			        else begin
		                flash_cmd_code        = 5'h0B; // Fast Read  
		                num_wait_state        = 8'h08;
			        end
				end
				else if (supported_protocol == 2'b10) begin // Quad Mode
		            flash_cmd_code        = 5'h0F; // Read Data 
		            num_wait_state        = 8'h6;
				end
		        with_payload          = 1'h1; 
		        sup_flash_cmd         = 1'h1; 
		        addr_32b = TX_FIFO_MAPPING_REG_ADDR;
		        packet_header_0_wr_data = {xfer_len_bytes, num_wait_state, multiple_flash_target, flash_cmd_code, with_payload, sup_flash_cmd};
		        wr_data_32b = packet_header_0_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_1
		        flash_addr_width      = 3'b010; // 24-bit address, need to add EN4B when 32-bit address
		        tgt_cs                = 5'h0; 
		        data_lane_width       = supported_protocol;  // Standard/Quad SPI
		        addr_lane_width       = supported_protocol;  // Standard/Quad SPI
		        cmd_lane_width        = supported_protocol;  // Standard/Quad SPI
		        packet_header_1_wr_data = {16'h0, flash_addr_width, tgt_cs, 2'h0, data_lane_width, addr_lane_width, cmd_lane_width};
		        addr_32b    = TX_FIFO_MAPPING_REG_ADDR;
			    wr_data_32b = packet_header_1_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_2 and pkt_header_3
		        addr_32b    = TX_FIFO_MAPPING_REG_ADDR;
		        wr_data_32b = pkt_hdr_addr_32b;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        //addr_32b    = TX_FIFO_MAPPING_REG_ADDR;   <-- removed since only 24-bit flash address is used
		        //wr_data_32b = 32'h0;
		        //#100; write_to_intf(addr_32b, wr_data_32b);
			    // Write to Interrupt Status Register
		        addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		        wr_data_32b = 32'hFFFFFFFF;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Start transaction
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000001;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Read TRANSACTION_STATUS
		        #100; read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
				$display("# ---INFO : @%0dns :: Polling transaction status register.", $time);
				if (rd_data_32b[0] == 1) begin
				    $display("# ---INFO : @%0dns :: Page read started.", $time);
				end
				else begin
				    $display("# ---INFO : @%0dns :: Page read not yet started.", $time);
				end
			    // Enable Interrupt Status Register
		        addr_32b    = INTERRUPT_ENABLE_REG_ADDR;
		        wr_data_32b = 32'h00000010;
		        #100; write_to_intf(addr_32b, wr_data_32b);
				num_of_bytes = 0;	
			    while(num_of_bytes < xfer_len_bytes-1) begin 
			        read_from_intf(INTERRUPT_STATUS_REG_ADDR, rd_data_32b);
					if (rd_data_32b[4] != 1) begin
			            // Write to Interrupt Status Register
		                addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		                wr_data_32b = 32'h00000010;
						// Read from FIFO
			            read_from_intf(RX_FIFO_MAPPING_REG_ADDR, rd_data_32b);
			            flash_rd_data_32b[num_of_bytes>>2][31:0] = rd_data_32b;
					    //#100;
                        do_data_compare(flash_wr_data_32b[num_of_bytes>>2],flash_rd_data_32b[num_of_bytes>>2]);
			        	num_of_bytes = num_of_bytes + 4;
					end
					else begin
					    #100;
					end
				end	
		        read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);			
		        while (rd_data_32b[0] == 1) begin
		            read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
		            #100;
		        end
				$display("# ---INFO : @%0dns :: Page read done.", $time);
				
				if (supported_protocol == 2'b10) begin
				    disable_quad_io();
				end
		end
	endtask	
	
	// Read Status Register Sequence using Unsupported Commands
	task read_stat_reg_unsupported_commands_standard_spi;
	    input  [0:0] test_0_1;
	    output [7:0] read_stat_reg_data;
	
        reg [31:0] addr_32b;
        reg [31:0] flash_addr_32b;
        reg [31:0] flash_wr_data_32b [255:0];
        reg [31:0] flash_rd_data_32b [255:0];
        reg [31:0] pkt_hdr_addr_32b;
        reg [31:0] wr_data_32b;
		reg [31:0] rd_data_32b;
		reg [31:0] num_of_bytes;
		integer m_i_i;
		integer m_j_i;
		integer qspi_config_0_val_sel;
		
		//QSPI_CONFIG_REG_0_REG_ADDR
		reg [31:0] qspi_config_0_wr_data;
		reg en_frame_end_done_cntr;
        reg en_flash_address_space_map;
        reg data_endianness;                        
        reg [4:0] sck_rate;
		reg chip_select_behaviour;                  
        reg [2:0] min_idle_time;  
        reg en_back_to_back_trans;		
        reg cpha;                                   
        reg cpol;                                   
        reg first_bit_transfer;

		//PACKET_HEADER_0 - Unsupported Commands
		reg [31:0] packet_header_0_wr_data;
		reg [15:0] xfer_len_bytes;
		reg [2:0]  num_wait_sck;
		reg [4:0]  tgt_cs;
		reg        multiple_target;
		reg        frm_end;
		reg        frm_start;
		reg        data_rate;
		reg [1:0]  lane_width;
		reg        cmd_type;
		reg        sup_flash_cmd;
		
		//PACKET DATA 0 - Unsupported Commands
		reg [7:0]  flash_cmd_opcode;
		reg [23:0] flash_address;
		
		begin
		
		// Write Read Status Register Command
		    $display("# ---INFO : @%0dns :: Setting registers to send Read Status Register command.", $time);
		    // Write to pkt_header_0 - Unsupported Command
		    xfer_len_bytes          = 16'h1;
		    num_wait_sck            = 3'h0;
		    tgt_cs                  = 5'h0;
		    multiple_target         = 1'h0;
		    frm_end                 = 1'h0; // SPI transaction will be put on hold while waiting for return data from flash
		    frm_start               = 1'h1; 
		    data_rate               = 1'h0;
		    lane_width              = 2'h0;
		    cmd_type                = 1'h1; // SPI Write Transaction
		    sup_flash_cmd           = 1'h0;
		    addr_32b                = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_0_REG_ADDR;
		    packet_header_0_wr_data = {xfer_len_bytes, num_wait_sck, tgt_cs, multiple_target, 
		                              frm_end, frm_start, data_rate, lane_width, cmd_type, sup_flash_cmd};
		    wr_data_32b             = packet_header_0_wr_data;
		    #100; write_to_intf(addr_32b, wr_data_32b);
		    //Write to pkt_data_0
		    addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_DATA_0_REG_ADDR;
		    wr_data_32b = {READ_STAT_REG_CMD_OPCODE, 24'h0};
		    #100; write_to_intf(addr_32b, wr_data_32b);
		    // Start transaction
		    addr_32b    = START_TRANSACTION_REG_ADDR;
		    wr_data_32b = 32'h00000001;
		    #100; write_to_intf(addr_32b, wr_data_32b);
		    // Read TRANSACTION_STATUS
		    read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);		
		    $display("# ---INFO : @%0dns :: Polling transaction status register.", $time);
		    if (rd_data_32b[0] == 1) begin
		        $display("# ---INFO : @%0dns :: Read status register operation started.", $time);
		    end
		    else begin
		        $display("# ---INFO : @%0dns :: Read status register operation not yet started.", $time);
		    end
		    while (rd_data_32b[0] == 1) begin
		        read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
		        //#100;
		    end
		    $display("# ---INFO : @%0dns :: Read status register command is already sent.", $time);
		    // Start transaction
		    addr_32b    = START_TRANSACTION_REG_ADDR;
		    wr_data_32b = 32'h00000000;
		    #100; write_to_intf(addr_32b, wr_data_32b);
		
		    if (test_0_1 == 1'h0) begin
		    // Read Transaction Status Register to know if its done then read the data    
		    // Read status register
		        $display("# ---INFO : @%0dns :: Setting registers to read the status register.", $time);
		        // Write to pkt_header_0 - Unsupported Command
		        xfer_len_bytes          = 16'h1;
		        num_wait_sck            = 3'h0;
		        tgt_cs                  = 5'h0;
		        multiple_target         = 1'h0;
		        frm_end                 = 1'h1;
		        frm_start               = 1'h0; // continuation of SPI transaction
		        data_rate               = 1'h0;
		        lane_width              = 2'h0;
		        cmd_type                = 1'h0; // SPI Read Transaction
		        sup_flash_cmd           = 1'h0;
		        addr_32b                = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_0_REG_ADDR;
		        packet_header_0_wr_data = {xfer_len_bytes, num_wait_sck, tgt_cs, multiple_target, 
		                                  frm_end, frm_start, data_rate, lane_width, cmd_type, sup_flash_cmd};
		        wr_data_32b             = packet_header_0_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Start transaction
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000001;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Read TRANSACTION_STATUS
		        read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);				
		        $display("# ---INFO : @%0dns :: Polling transaction status register.", $time);
		        if (rd_data_32b[0] == 1) begin
		            $display("# ---INFO : @%0dns :: Read status register operation done.", $time);
		        end
		        else begin
		            $display("# ---INFO : @%0dns :: Read status register operation is on-going.", $time);
		        end
		        while (rd_data_32b[0] == 1) begin
		            read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
		            //#100; // when this is removed, this transaction will hang.
		        end
		        $display("# ---INFO : @%0dns :: Read status register operation done.", $time);
		        //Read from pkt_data_0
		        addr_32b = ENABLE_RECEIVE_FIFO ? RX_FIFO_MAPPING_REG_ADDR : PACKET_DATA_0_REG_ADDR;
		        read_from_intf(addr_32b, rd_data_32b);
		    	read_stat_reg_data = rd_data_32b[31:24];
		        // Start transaction
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000000;
		        #100; write_to_intf(addr_32b, wr_data_32b);	
		    end
		    else begin
		    // Read Packet Data Register flag to know if its not empty then read the data    
		    // Read status register
		        $display("# ---INFO : @%0dns :: Setting registers to read the status register.", $time);
		        // Write to pkt_header_0 - Unsupported Command
		        xfer_len_bytes          = 16'h1;
		        num_wait_sck            = 3'h0;
		        tgt_cs                  = 5'h0;
		        multiple_target         = 1'h0;
		        frm_end                 = 1'h1;
		        frm_start               = 1'h0; // continuation of SPI transaction
		        data_rate               = 1'h0;
		        lane_width              = 2'h0;
		        cmd_type                = 1'h0; // SPI Read Transaction
		        sup_flash_cmd           = 1'h0;
		        addr_32b                = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_0_REG_ADDR;
		        packet_header_0_wr_data = {xfer_len_bytes, num_wait_sck, tgt_cs, multiple_target, 
		                                  frm_end, frm_start, data_rate, lane_width, cmd_type, sup_flash_cmd};
		        wr_data_32b             = packet_header_0_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		    	// Write to Interrupt Status Register
		        addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		        wr_data_32b = 32'hFFFFFFFF;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		    	// Enable Interrupt Status Register
		        addr_32b    = INTERRUPT_ENABLE_REG_ADDR;
		        wr_data_32b = 32'h00000030;
		        // Start transaction
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000001;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Read TRANSACTION_STATUS
		        read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);				
		        $display("# ---INFO : @%0dns :: Polling transaction status register.", $time);
		        if (rd_data_32b[0] == 1) begin
		            $display("# ---INFO : @%0dns :: Read status register operation done.", $time);
		        end
		        else begin
		            $display("# ---INFO : @%0dns :: Read status register operation is on-going.", $time);
		        end
		    	read_from_intf(INTERRUPT_STATUS_REG_ADDR, rd_data_32b);
		        while (rd_data_32b[4] == 0) begin
		    	    read_from_intf(INTERRUPT_STATUS_REG_ADDR, rd_data_32b);
		            //#100;
		        end
		        //Read from pkt_data_0
		        addr_32b = ENABLE_RECEIVE_FIFO ? RX_FIFO_MAPPING_REG_ADDR : PACKET_DATA_0_REG_ADDR;
		        read_from_intf(addr_32b, rd_data_32b);
		    	read_stat_reg_data = rd_data_32b[31:24];
		        $display("# ---INFO : @%0dns :: Read status register operation done.", $time);
		        // Start transaction
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000000;
		        #100; write_to_intf(addr_32b, wr_data_32b);	
		    	// Write to Interrupt Status Register
		        addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		        wr_data_32b = 32'hFFFFFFFF;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		    end
        end			
	endtask
	
	// Erase-Write-Read Sequence using Supported Commands
	// For Write and Read Sequence, either with FIFO enabled or disabled, writing/reading to registers and TX/RX FIFO are the same.
	// Write : Checks the interrupt status accordingly, when the register or FIFO is empty, new data will be written.
    // Read  : Checks the interrupt status accordingly, when the register or FIFO is not empty, packet data will be read.	
	task erase_write_read_using_supported_commands_diff_lanes_quad_spi;
        reg [31:0] addr_32b;
        reg [31:0] flash_addr_32b;
        reg [31:0] flash_wr_data_32b [255:0];
        reg [31:0] flash_rd_data_32b [255:0];
        reg [31:0] pkt_hdr_addr_32b;
        reg [31:0] wr_data_32b;
		reg [31:0] rd_data_32b;
		reg [31:0] num_of_bytes;
		reg [31:0] limit_num_of_bytes;
		integer m_i_i;
		integer m_j_i;
		
		//QSPI_CONFIG_REG_0_REG_ADDR
		reg [31:0] qspi_config_0_wr_data;
		reg en_frame_end_done_cntr;
        reg en_flash_address_space_map;
        reg data_endianness;                        
        reg [4:0] sck_rate;
		reg chip_select_behaviour;                  
        reg [2:0] min_idle_time;  
        reg en_back_to_back_trans;		
        reg cpha;                                   
        reg cpol;                                   
        reg first_bit_transfer;
		
		//QSPI_CONFIG_REG_1_REG_ADDR
		reg [31:0] qspi_config_1_wr_data;
		reg [15:0] trgt_rd_trans_cnt;
		reg [15:0] trgt_wr_trans_cnt;
		
		//PACKET_HEADER_0
		reg [31:0] packet_header_0_wr_data;
		reg [15:0] xfer_len_bytes; 
		reg [7:0] num_wait_state;  
		reg multiple_flash_target; 
		reg [4:0] flash_cmd_code;  
		reg with_payload;          
		reg sup_flash_cmd;  

		//PACKET_HEADER_1
		reg [31:0] packet_header_1_wr_data;
        reg [2:0] flash_addr_width;
        reg [4:0] tgt_cs;          
        reg [1:0] data_lane_width; 
        reg [1:0] addr_lane_width; 
        reg [1:0] cmd_lane_width; 
		
		//PACKET_HEADER_0 - Unsupported Commands
		reg [2:0]  num_wait_sck;
		reg        multiple_target;
		reg        frm_end;
		reg        frm_start;
		reg        data_rate;
		reg [1:0]  lane_width;
		reg        cmd_type;
		
		//PACKET DATA 0 - Unsupported Commands
		reg [7:0]  flash_cmd_opcode;
		reg [23:0] flash_address;
		
	    begin
                #12000; // wait for a_reset_n_i assertion
			    #1000;
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_using_supported_commands_diff_lanes_quad_spi", $time);
			    //Generate Address to be used on Erase, Write, Read
                flash_addr_32b[31:12] = 20'h00000;
                flash_addr_32b[11:2]  = $random;
                flash_addr_32b[1:0]   = 2'h0;
			    if (DATA_ENDIANNESS == 1 ) begin //Big Endian
			        pkt_hdr_addr_32b    = 32'h01000000; // 24-bit address is 24'h010000
			    end
			    else begin // Little Endian
			        pkt_hdr_addr_32b    = 32'h00000001; // 24-bit address is 24'h010000
			    end
		        
				// Write to config0 - Configuration Register 0, this setting will be used for Erase, Write and Read Operation
		        en_frame_end_done_cntr     = 1'h0;
                en_flash_address_space_map = 1'h0;
                data_endianness            = 1'h0;                        
                sck_rate                   = 5'h02;
                //sck_rate                   = 5'h001;
		        chip_select_behaviour      = 1'h0;                  
                min_idle_time              = 3'h0;  
                en_back_to_back_trans      = 1'h0;		
                cpha                       = 1'h1;                                    
                cpol                       = 1'h1; 		
                //cpha                       = m_i_i[0];                                    
                //cpol                       = m_i_i[0];                                   
                first_bit_transfer         = 1'h0;
			    addr_32b                   = QSPI_CONFIG_REG_0_REG_ADDR;
			    qspi_config_0_wr_data      = {16'b0, en_frame_end_done_cntr, en_flash_address_space_map, 
			                                  data_endianness, sck_rate, chip_select_behaviour, min_idle_time, 
			    						      en_back_to_back_trans, cpha, cpol, first_bit_transfer};
			    wr_data_32b = qspi_config_0_wr_data;
			    if (overwrite_gui_settings == 1) begin
			        #100; write_to_intf(addr_32b, wr_data_32b);
			    end
			    // Write to config1 - Configuration Register 1, this setting will be used for Write and Read Operation
		        trgt_rd_trans_cnt     = 16'h100;
			    trgt_wr_trans_cnt     = 16'h100;
			    addr_32b              = QSPI_CONFIG_REG_1_REG_ADDR;
			    qspi_config_1_wr_data = {trgt_rd_trans_cnt, trgt_wr_trans_cnt};
			    wr_data_32b           = qspi_config_1_wr_data;
			    #100; write_to_intf(addr_32b, wr_data_32b);
				
			// Enter 4-byte Address Mode - Supported Command
			    // flash_command_code == 5'h1C // Enter 4-byte Address Mode		
							
		        // Write 0 to Start transaction Register
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000000;
		        #100; write_to_intf(addr_32b, wr_data_32b);	
				
			    $display("# ---INFO : @%0dns :: Setting registers to execute Enter 4-byte address mode command.", $time);
		        // Write to pkt_header_0 - supported flash command
		        xfer_len_bytes          = 16'h0;
		        num_wait_state          = 8'h0;
		        multiple_flash_target   = 1'h0;
		        flash_cmd_code          = 5'h1C; // Enter 4-byte Address Mode	
		        with_payload            = 1'h0; 
		        sup_flash_cmd           = 1'h1;
			    addr_32b                = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_0_REG_ADDR;
		        packet_header_0_wr_data = {xfer_len_bytes, num_wait_state, multiple_flash_target, flash_cmd_code, with_payload, sup_flash_cmd};
		        wr_data_32b             = packet_header_0_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_1
		        flash_addr_width        = 3'b000;
		        tgt_cs                  = 5'h0; 
		        data_lane_width         = 2'b00;  // Standard SPI
		        addr_lane_width         = 2'b00;  // Standard SPI
		        cmd_lane_width          = 2'b00;  // Standard SPI 
		        packet_header_1_wr_data = {16'h0, flash_addr_width, tgt_cs, 2'h0, data_lane_width, addr_lane_width, cmd_lane_width};
                addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_1_REG_ADDR;
		        wr_data_32b = packet_header_1_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Start transaction
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000001;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Read TRANSACTION_STATUS
		        #100; read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
				$display("# ---INFO : @%0dns :: Polling transaction status register.", $time);
				if (rd_data_32b[0] == 1) begin
				    $display("# ---INFO : @%0dns :: Flash operation started.", $time);
				end
				else begin
				    $display("# ---INFO : @%0dns :: Flash operation not yet started.", $time);
				end
		        while (rd_data_32b[0] == 1) begin
		            read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b); #100;
		        end
				$display("# ---INFO : @%0dns :: Flash operation done.", $time);	
			
			// Exit 4-byte Address Mode
			    // flash_command_code == 5'h1D // Exit 4-byte Address Mode		
							
		        // Write 0 to Start transaction Register
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000000;
		        #100; write_to_intf(addr_32b, wr_data_32b);	
				
			    $display("# ---INFO : @%0dns :: Setting registers to execute Exit 4-byte address mode command.", $time);
		        // Write to pkt_header_0 - supported flash command
		        xfer_len_bytes          = 16'h0;
		        num_wait_state          = 8'h0;
		        multiple_flash_target   = 1'h0;
		        flash_cmd_code          = 5'h1D; // Exit 4-byte Address Mode	
		        with_payload            = 1'h0; 
		        sup_flash_cmd           = 1'h1;
			    addr_32b                = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_0_REG_ADDR;
		        packet_header_0_wr_data = {xfer_len_bytes, num_wait_state, multiple_flash_target, flash_cmd_code, with_payload, sup_flash_cmd};
		        wr_data_32b             = packet_header_0_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_1
		        flash_addr_width        = 3'b000;
		        tgt_cs                  = 5'h0; 
		        data_lane_width         = 2'b00;  // Standard SPI
		        addr_lane_width         = 2'b00;  // Standard SPI
		        cmd_lane_width          = 2'b00;  // Standard SPI 
		        packet_header_1_wr_data = {16'h0, flash_addr_width, tgt_cs, 2'h0, data_lane_width, addr_lane_width, cmd_lane_width};
                addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_1_REG_ADDR;
		        wr_data_32b = packet_header_1_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Start transaction
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000001;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Read TRANSACTION_STATUS
		        #100; read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
				$display("# ---INFO : @%0dns :: Polling transaction status register.", $time);
				if (rd_data_32b[0] == 1) begin
				    $display("# ---INFO : @%0dns :: Flash operation started.", $time);
				end
				else begin
				    $display("# ---INFO : @%0dns :: Flash operation not yet started.", $time);
				end
		        while (rd_data_32b[0] == 1) begin
		            read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b); #100;
		        end
				$display("# ---INFO : @%0dns :: Flash operation done.", $time);
							
			// Enter Quad Mode - Supported Command	
			    // flash_command_code == 5'h1E // Enter Quad I/O Mode		
							
		        // Write 0 to Start transaction Register
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000000;
		        #100; write_to_intf(addr_32b, wr_data_32b);	
				
			    $display("# ---INFO : @%0dns :: Setting registers to execute Enter Quad I/O mode command.", $time);
		        // Write to pkt_header_0 - supported flash command
		        xfer_len_bytes          = 16'h0;
		        num_wait_state          = 8'h0;
		        multiple_flash_target   = 1'h0;
		        flash_cmd_code          = 5'h1E; // Enter Quad I/O Mode	
		        with_payload            = 1'h0; 
		        sup_flash_cmd           = 1'h1;
			    addr_32b                = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_0_REG_ADDR;
		        packet_header_0_wr_data = {xfer_len_bytes, num_wait_state, multiple_flash_target, flash_cmd_code, with_payload, sup_flash_cmd};
		        wr_data_32b             = packet_header_0_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_1
		        flash_addr_width        = 3'b000;
		        tgt_cs                  = 5'h0; 
		        data_lane_width         = 2'b00;  // Standard SPI
		        addr_lane_width         = 2'b00;  // Standard SPI
		        cmd_lane_width          = 2'b00;  // Standard SPI 
		        packet_header_1_wr_data = {16'h0, flash_addr_width, tgt_cs, 2'h0, data_lane_width, addr_lane_width, cmd_lane_width};
                addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_1_REG_ADDR;
		        wr_data_32b = packet_header_1_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Start transaction
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000001;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Read TRANSACTION_STATUS
		        #100; read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
				$display("# ---INFO : @%0dns :: Polling transaction status register.", $time);
				if (rd_data_32b[0] == 1) begin
				    $display("# ---INFO : @%0dns :: Flash operation started.", $time);
				end
				else begin
				    $display("# ---INFO : @%0dns :: Flash operation not yet started.", $time);
				end
		        while (rd_data_32b[0] == 1) begin
		            read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b); #100;
		        end
				$display("# ---INFO : @%0dns :: Flash operation done.", $time);
				
		    // Erase - For MX25L51245G can work on Standard SPI and Quad SPI
		        // flash_command_code == 5'h10 // Block Erase Type 1
		        // flash_command_code == 5'h11 // Block Erase Type 2
		        // flash_command_code == 5'h12 // Block Erase Type 3
		        // flash_command_code == 5'h13 // Chip Erase
				
		        // Write 0 to Start transaction Register
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000000;
		        #100; write_to_intf(addr_32b, wr_data_32b);	
				
			    $display("# ---INFO : @%0dns :: Setting registers to execute erase operation.", $time);
		        // Write to pkt_header_0 - supported flash command
		        xfer_len_bytes          = 16'h0;
		        num_wait_state          = 8'h0;
		        multiple_flash_target   = 1'h0;
		        flash_cmd_code          = 5'h10; // Block Erase Type 1 
		        with_payload            = 1'h0; 
		        sup_flash_cmd           = 1'h1;
			    addr_32b                = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_0_REG_ADDR;
		        packet_header_0_wr_data = {xfer_len_bytes, num_wait_state, multiple_flash_target, flash_cmd_code, with_payload, sup_flash_cmd};
		        wr_data_32b             = packet_header_0_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_1
		        //flash_addr_width        = 3'b011; // 32-bit address, need to add EN4B when 32-bit address
		        flash_addr_width        = 3'b010; // 24-bit address, need to add EN4B when 32-bit address
		        tgt_cs                  = 5'h0; 
		        data_lane_width         = 2'b10;  // Quad SPI
		        addr_lane_width         = 2'b10;  // Quad SPI
		        cmd_lane_width          = 2'b10;  // Quad SPI 
		        packet_header_1_wr_data = {16'h0, flash_addr_width, tgt_cs, 2'h0, data_lane_width, addr_lane_width, cmd_lane_width};
                addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_1_REG_ADDR;
		        wr_data_32b = packet_header_1_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_2 and pkt_header_3
                addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_2_REG_ADDR;
		        wr_data_32b = pkt_hdr_addr_32b;
		        #100; write_to_intf(addr_32b, wr_data_32b);
				if (ENABLE_TRANSMIT_FIFO == 0) begin
                    addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_3_REG_ADDR;
		            wr_data_32b = 32'h0;
		            #100; write_to_intf(addr_32b, wr_data_32b);
				end
		        // Start transaction
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000001;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Read TRANSACTION_STATUS
		        #100; read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
				$display("# ---INFO : @%0dns :: Polling transaction status register.", $time);
				if (rd_data_32b[0] == 1) begin
				    $display("# ---INFO : @%0dns :: Erase operation started.", $time);
				end
				else begin
				    $display("# ---INFO : @%0dns :: Erase operation not yet started.", $time);
				end
		        while (rd_data_32b[0] == 1) begin
		            read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b); #100;
		        end
				$display("# ---INFO : @%0dns :: Erase operation done.", $time);
			
			// Exit Quad Mode	
			    // flash_command_code == 5'h1F // Exit Quad I/O Mode		
							
		        // Write 0 to Start transaction Register
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000000;
		        #100; write_to_intf(addr_32b, wr_data_32b);	
				
			    $display("# ---INFO : @%0dns :: Setting registers to execute Exit Quad I/O mode command.", $time);
		        // Write to pkt_header_0 - supported flash command
		        xfer_len_bytes          = 16'h0;
		        num_wait_state          = 8'h0;
		        multiple_flash_target   = 1'h0;
		        flash_cmd_code          = 5'h1F; // Exit Quad I/O Mode	
		        with_payload            = 1'h0; 
		        sup_flash_cmd           = 1'h1;
			    addr_32b                = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_0_REG_ADDR;
		        packet_header_0_wr_data = {xfer_len_bytes, num_wait_state, multiple_flash_target, flash_cmd_code, with_payload, sup_flash_cmd};
		        wr_data_32b             = packet_header_0_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_1
		        flash_addr_width        = 3'b000;
		        tgt_cs                  = 5'h0; 
		        data_lane_width         = 2'b10;  // Quad SPI
		        addr_lane_width         = 2'b10;  // Quad SPI
		        cmd_lane_width          = 2'b10;  // Quad SPI 
		        packet_header_1_wr_data = {16'h0, flash_addr_width, tgt_cs, 2'h0, data_lane_width, addr_lane_width, cmd_lane_width};
                addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_1_REG_ADDR;
		        wr_data_32b = packet_header_1_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Start transaction
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000001;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Read TRANSACTION_STATUS
		        #100; read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
				$display("# ---INFO : @%0dns :: Polling transaction status register.", $time);
				if (rd_data_32b[0] == 1) begin
				    $display("# ---INFO : @%0dns :: Flash operation started.", $time);
				end
				else begin
				    $display("# ---INFO : @%0dns :: Flash operation not yet started.", $time);
				end
		        while (rd_data_32b[0] == 1) begin
		            read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b); #100;
		        end
				$display("# ---INFO : @%0dns :: Flash operation done.", $time);
			
            // For Quad Enable Bit setting on Configuration Register
			    if (DATA_ENDIANNESS == 1) begin // Big Endian
			        supported_commands_test_send_command_and_write_data({8'h40, 24'h000000}, 5'h00, 1'h0, 5'h0);
				end
				else begin
			        supported_commands_test_send_command_and_write_data({24'h000000, 8'h40}, 5'h00, 1'h0, 5'h0);
				end
			
		    // Page Program	
		        // Quad SPI Write 
		            // flash_command_code == 5'h1A // 32h opcode Quad Input Fast Program in Micron, PP in QPI Mode in Macronix
		            // flash_command_code == 5'h1B // 38h opcode Extended Quad Input Fast Program  1-4-4
		            // flash_command_code == 5'h17 // PP in QPI Mode in Macronix
			    
		        // Write 0 to Start transaction Register
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000000;
		        #100; write_to_intf(addr_32b, wr_data_32b);	
				
			    $display("# ---INFO : @%0dns :: Setting registers to execute page program operation.", $time);
		        // Write to pkt_header_0 - supported flash command
		        xfer_len_bytes          = 16'h100; // 256 bytes
		        num_wait_state          = 8'h0;  
		        multiple_flash_target   = 1'h0;
		        flash_cmd_code          = 5'h1B; //  38h opcode
		        with_payload            = 1'h1; 
		        sup_flash_cmd           = 1'h1; 
                addr_32b                = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_0_REG_ADDR;
		        packet_header_0_wr_data = {xfer_len_bytes, num_wait_state, multiple_flash_target, flash_cmd_code, with_payload, sup_flash_cmd};
		        wr_data_32b             = packet_header_0_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_1
		        flash_addr_width        = 3'b010; // 24-bit address, need to add EN4B when 32-bit address
		        tgt_cs                  = 5'h0;  
		        data_lane_width         = 2'b10;  // Quad SPI
		        addr_lane_width         = 2'b10;  // Quad SPI
		        cmd_lane_width          = 2'b00;  // Standard SPI 
		        packet_header_1_wr_data = {16'h0, flash_addr_width, tgt_cs, 2'h0, data_lane_width, addr_lane_width, cmd_lane_width};
		        addr_32b                = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_1_REG_ADDR;
			    wr_data_32b             = packet_header_1_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_2 and pkt_header_3
			    addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_2_REG_ADDR;
		        wr_data_32b = pkt_hdr_addr_32b;
		        #100; write_to_intf(addr_32b, wr_data_32b);
				if (ENABLE_TRANSMIT_FIFO == 0) begin
			        addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_3_REG_ADDR;
		            wr_data_32b = 32'h0;
		            #100; write_to_intf(addr_32b, wr_data_32b);
				end
			    // Write to Interrupt Status Register
		        addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		        wr_data_32b = 32'hFFFFFFFF;
		        #100; write_to_intf(addr_32b, wr_data_32b);
			    // Enable Interrupt Status Register
		        addr_32b    = INTERRUPT_ENABLE_REG_ADDR;
		        wr_data_32b = 32'h00000003;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_data_0
		        addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_DATA_0_REG_ADDR;
		        wr_data_32b = $random;
			    flash_wr_data_32b[0][31:0] = wr_data_32b;
		        #100; write_to_intf(addr_32b, wr_data_32b);
				$display("---INFO : @%0dns :: Write Data 0x%x", $time, wr_data_32b);
                // Write to pkt_data_1
		        addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_DATA_1_REG_ADDR;
		        wr_data_32b = $random;
			    flash_wr_data_32b[1][31:0] = wr_data_32b;
		        #100; write_to_intf(addr_32b, wr_data_32b);
				$display("---INFO : @%0dns :: Write Data 0x%x", $time, wr_data_32b);
			    // Start transaction
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000001;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Read TRANSACTION_STATUS
		        #100; read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
				$display("# ---INFO : @%0dns :: Polling transaction status register.", $time);
				if (rd_data_32b[0] == 1) begin
				    $display("# ---INFO : @%0dns :: Page program started.", $time);
				end
				else begin
				    $display("# ---INFO : @%0dns :: Page program not yet started.", $time);
				end
			    num_of_bytes = 8;
				limit_num_of_bytes = ENABLE_TRANSMIT_FIFO ? (xfer_len_bytes-8) : (xfer_len_bytes-1);
				while (num_of_bytes < limit_num_of_bytes) begin // write remaining 254 bytes of data
				    read_from_intf(INTERRUPT_STATUS_REG_ADDR, rd_data_32b);
			        if (ENABLE_TRANSMIT_FIFO == 0) begin
			    	    if (rd_data_32b[0] == 1) begin
			                // Write to Interrupt Status Register
		                    addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		                    wr_data_32b = 32'h00000001;
		                    #100; write_to_intf(addr_32b, wr_data_32b);
		                    // Write to pkt_data_0
		                    addr_32b    = PACKET_DATA_0_REG_ADDR;
		                    wr_data_32b = $random;
			                flash_wr_data_32b[(num_of_bytes>>2)][31:0] = wr_data_32b;
		                    #100; write_to_intf(addr_32b, wr_data_32b);
				            $display("---INFO : @%0dns :: Write Data 0x%x", $time, wr_data_32b);
			    	    	num_of_bytes = num_of_bytes + 4;
			    	    end
			    	    else begin
		                    #50;
			    	    end
			            read_from_intf(INTERRUPT_STATUS_REG_ADDR, rd_data_32b);
			    	    if (rd_data_32b[1] == 1) begin
			                // Write to Interrupt Status Register
		                    addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		                    wr_data_32b = 32'h00000002;
		                    #100; write_to_intf(addr_32b, wr_data_32b);
		                    // Write to pkt_data_0
		                    addr_32b    = PACKET_DATA_1_REG_ADDR;
		                    wr_data_32b = $random;
			                flash_wr_data_32b[(num_of_bytes>>2)][31:0] = wr_data_32b;
		                    #100; write_to_intf(addr_32b, wr_data_32b);
				            $display("---INFO : @%0dns :: Write Data 0x%x", $time, wr_data_32b);
			    	    	num_of_bytes = num_of_bytes + 4;
			    	    end
			    	    else begin
		                    #50;
			    	    end
			    	end
			    	else begin// ENABLE_TRANSMIT_FIFO == 1 
			    	    if (rd_data_32b[0] == 1) begin
			                // Write to Interrupt Status Register
		                    addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		                    wr_data_32b = 32'h00000001;
		                    #100; write_to_intf(addr_32b, wr_data_32b);
		                    // Write to pkt_data_0
		                    addr_32b    = TX_FIFO_MAPPING_REG_ADDR;
		                    wr_data_32b = $random;
			                flash_wr_data_32b[(num_of_bytes>>2)][31:0] = wr_data_32b;
		                    #100; write_to_intf(addr_32b, wr_data_32b);
				            $display("---INFO : @%0dns :: Write Data 0x%x", $time, wr_data_32b);
			    	    	num_of_bytes = num_of_bytes + 4;
			    	    end
			    	    else begin
		                    #50;
			    	    end
			    	end
				end
		        read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
				$display("# ---INFO : @%0dns :: Polling transaction status register.", $time);	
                if (rd_data_32b[0] == 1) $display("# ---INFO : @%0dns :: Page program is still on-going.", $time);				
		        while (rd_data_32b[0] == 1) begin
		            read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
		            #100;
		        end
				$display("# ---INFO : @%0dns :: Page program done.", $time);
			    
		    // Quad SPI Read
		        // flash_command_code == 5'h0F // Quad Input/Output Fast Read in Micron
		        // flash_command_code == 5'h0F // 4xI/O Read QPI Mode 1-4-4
			    
		        // Write 0 to Start transaction Register
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000000;
		        #100; write_to_intf(addr_32b, wr_data_32b);
				
			    $display("# ---INFO : @%0dns :: Setting registers to execute page read operation.", $time);
		        xfer_len_bytes        = 16'h100; // 256-bytes
		        multiple_flash_target = 1'h0;
		        flash_cmd_code        = 5'h0F; // Quad Input/Output Fast Read
		        num_wait_state        = 8'h6;
		        with_payload          = 1'h0; 
		        sup_flash_cmd         = 1'h1; 
		        addr_32b = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_0_REG_ADDR;
		        packet_header_0_wr_data = {xfer_len_bytes, num_wait_state, multiple_flash_target, flash_cmd_code, with_payload, sup_flash_cmd};
		        wr_data_32b = packet_header_0_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_1
		        flash_addr_width        = 3'b010; // 24-bit address, need to add EN4B when 32-bit address
		        tgt_cs                  = 5'h0; 
		        data_lane_width         = 2'b10;  // Quad SPI
		        addr_lane_width         = 2'b10;  // Quad SPI
		        cmd_lane_width          = 2'b00;  // Standard SPI 
		        packet_header_1_wr_data = {16'h0, flash_addr_width, tgt_cs, 2'h0, data_lane_width, addr_lane_width, cmd_lane_width};
		        addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_1_REG_ADDR;
			    wr_data_32b = packet_header_1_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_2 and pkt_header_3
		        addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_2_REG_ADDR;
		        wr_data_32b = pkt_hdr_addr_32b;
		        #100; write_to_intf(addr_32b, wr_data_32b);
				if (ENABLE_TRANSMIT_FIFO == 0) begin
		           addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_3_REG_ADDR;
		           wr_data_32b = 32'h0;
		           #100; write_to_intf(addr_32b, wr_data_32b);
				end
			    // Write to Interrupt Status Register
		        addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		        wr_data_32b = 32'hFFFFFFFF;
		        #100; write_to_intf(addr_32b, wr_data_32b);
			    // Enable Interrupt Status Register
		        addr_32b    = INTERRUPT_ENABLE_REG_ADDR;
		        wr_data_32b = 32'h00000030;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Start transaction
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000001;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Read TRANSACTION_STATUS
		        #100; read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
				$display("# ---INFO : @%0dns :: Polling transaction status register.", $time);
				if (rd_data_32b[0] == 1) begin
				    $display("# ---INFO : @%0dns :: Page read started.", $time);
				end
				else begin
				    $display("# ---INFO : @%0dns :: Page read not yet started.", $time);
				end	
			    num_of_bytes = 0;
				//limit_num_of_bytes = ENABLE_RECEIVE_FIFO ? (xfer_len_bytes+1) : (xfer_len_bytes-3);
				while (num_of_bytes < xfer_len_bytes-1) begin
			        read_from_intf(INTERRUPT_STATUS_REG_ADDR, rd_data_32b);
			    	if (rd_data_32b[4] == 1) begin
		                //Read from pkt_data_0
						addr_32b = ENABLE_RECEIVE_FIFO ? RX_FIFO_MAPPING_REG_ADDR : PACKET_DATA_0_REG_ADDR;
			            read_from_intf(addr_32b, rd_data_32b);
			            flash_rd_data_32b[(num_of_bytes>>2)][31:0] = rd_data_32b;
                        do_data_compare(flash_wr_data_32b[(num_of_bytes>>2)],flash_rd_data_32b[(num_of_bytes>>2)]);
		                //#100;
			            // Write to Interrupt Status Register
		                addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		                wr_data_32b = 32'h00000010;
		                //#100; 
						write_to_intf(addr_32b, wr_data_32b);
			            read_from_intf(INTERRUPT_STATUS_REG_ADDR, rd_data_32b);
			    		num_of_bytes = num_of_bytes + 4;
			    	end
			    	else begin
		                #100;
			    	end
				end
		        read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);	
				$display("# ---INFO : @%0dns :: Polling transaction status register.", $time);		
		        while (rd_data_32b[0] == 1) begin
		            read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
		            #100;
				    if (rd_data_32b[0] == 1) begin
				        $display("# ---INFO : @%0dns :: Page read still on-going.", $time);
				    end
				    else begin
				        $display("# ---INFO : @%0dns :: Page read done.", $time);
				    end	
		        end
			
            // For Quad Enable Bit setting on Configuration Register
			// Writing 0 to reset quad enable bit setting
			    supported_commands_test_send_command_and_write_data(32'h00000000, 5'h00, 1'h0, 5'h0);
		end
	endtask
	
	// General tests starts here
	
	// Below test sequence can be used when flash command code needs to be updated prior to flash Operation
	// Flash Command Code 0-7 Register 
	// Offset Address 0x0000_000C to 0x0000_0028
	task set_flash_command_code;
	    input [31:0] flash_cmd_code_register_addr;
	    input [31:0] flash_cmd_code_register_write_data;
        reg [31:0] addr_32b;
        reg [31:0] wr_data_32b;
		reg [31:0] rd_data_32b;
        reg [4:0] flash_command_code_reg [5:0];
		integer m_i_i;
		integer m_j_i;
		integer m_k_i;
		reg [31:0] max_loop;
		
		//QSPI_CONFIG_REG_0_REG_ADDR
		reg [31:0] qspi_config_0_wr_data;
		reg en_frame_end_done_cntr;
        reg en_flash_address_space_map;
        reg data_endianness;                        
        reg [4:0] sck_rate;
		reg chip_select_behaviour;                  
        reg [2:0] min_idle_time;  
        reg en_back_to_back_trans;		
        reg cpha;                                   
        reg cpol;                                   
        reg first_bit_transfer;
		
		//PACKET_HEADER_0
		reg [31:0] packet_header_0_wr_data;
		reg [15:0] xfer_len_bytes; 
		reg [7:0] num_wait_state;  
		reg multiple_flash_target; 
		reg [4:0] flash_cmd_code;  
		reg with_payload;          
		reg sup_flash_cmd;  

		//PACKET_HEADER_1
		reg [31:0] packet_header_1_wr_data;
        reg [2:0] flash_addr_width;
        reg [4:0] tgt_cs;          
        reg [1:0] data_lane_width; 
        reg [1:0] addr_lane_width; 
        reg [1:0] cmd_lane_width;  		
		
	    begin
            #12000; // wait for a_reset_n_i assertion
			#1000;
			$display("# ---INFO : @%0dns :: Test Name : set_flash_command_code", $time);
				// Write to config0 - Configuration Register
		        en_frame_end_done_cntr     = 1'h0;
                en_flash_address_space_map = 1'h0;
                data_endianness            = 1'h0;                        
                sck_rate                   = 5'h02;
		        chip_select_behaviour      = 1'h0;                  
                min_idle_time              = 3'h0;  
                en_back_to_back_trans      = 1'h0;		
                cpha                       = 1'h1;                                   
                cpol                       = 1'h1;                                  
                first_bit_transfer         = 1'h0;
			    addr_32b = QSPI_CONFIG_REG_0_REG_ADDR;
			    qspi_config_0_wr_data = {16'b0, en_frame_end_done_cntr, en_flash_address_space_map, 
			                             data_endianness, sck_rate, chip_select_behaviour, min_idle_time, 
			    						 en_back_to_back_trans, cpha, cpol, first_bit_transfer};
			    wr_data_32b = qspi_config_0_wr_data;
			    if (overwrite_gui_settings == 1) begin
			        #100; write_to_intf(addr_32b, wr_data_32b);
			    end
		        // Write 0 to Start transaction Register
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000000;
		        #100; write_to_intf(addr_32b, wr_data_32b);
				// Set Address and Data
		        addr_32b = flash_cmd_code_register_addr;
				wr_data_32b = flash_cmd_code_register_write_data;
		        #100;
		        write_to_intf(addr_32b, wr_data_32b);
			$display("# ---INFO : @%0dns :: Done set_flash_command_code testing", $time);
	    end
	endtask
	
	// Below sequence can be used on flash operations which sends command only
	// flash_command_code == 5'h14 // Write Enable                 06h
	// flash_command_code == 5'h15 // Write Disable                04h
	// flash_command_code == 5'h1C // Enter 4-Byte Address Mode    B7h
	// flash_command_code == 5'h1D // Exit 4-Byte Address Mode     E9h
	// flash_command_code == 5'h1E // Enter Quad Input/Output Mode 35h
	// flash_command_code == 5'h1F // Reset Quad Input/Output Mode F5h
	task supported_flash_command_opcode_only;
	    input [0:0] multiple_flash_target_input;
	    input [4:0] flash_cmd_code_input;
		input [4:0] tgt_cs_input;
        reg [31:0] addr_32b;
        reg [31:0] wr_data_32b;
		reg [31:0] rd_data_32b;
        reg [4:0] flash_command_code_reg [5:0];
		integer m_i_i;
		integer m_j_i;
		integer m_k_i;
		reg [31:0] max_loop;
		
		//QSPI_CONFIG_REG_0_REG_ADDR
		reg [31:0] qspi_config_0_wr_data;
		reg en_frame_end_done_cntr;
        reg en_flash_address_space_map;
        reg data_endianness;                        
        reg [4:0] sck_rate;
		reg chip_select_behaviour;                  
        reg [2:0] min_idle_time;  
        reg en_back_to_back_trans;		
        reg cpha;                                   
        reg cpol;                                   
        reg first_bit_transfer;
		
		//PACKET_HEADER_0
		reg [31:0] packet_header_0_wr_data;
		reg [15:0] xfer_len_bytes; 
		reg [7:0] num_wait_state;  
		reg multiple_flash_target; 
		reg [4:0] flash_cmd_code;  
		reg with_payload;          
		reg sup_flash_cmd;  

		//PACKET_HEADER_1
		reg [31:0] packet_header_1_wr_data;
        reg [2:0] flash_addr_width;
        reg [4:0] tgt_cs;          
        reg [1:0] data_lane_width; 
        reg [1:0] addr_lane_width; 
        reg [1:0] cmd_lane_width;  		
		
	    begin
            #12000; // wait for a_reset_n_i assertion
			#1000;
			$display("# ---INFO : @%0dns :: Test Name : supported_flash_command_opcode_only", $time);
				// Write to config0 - Configuration Register
		        en_frame_end_done_cntr     = 1'h0;
                en_flash_address_space_map = 1'h0;
                data_endianness            = 1'h0;                        
                sck_rate                   = 5'h02;
		        chip_select_behaviour      = 1'h0;                  
                min_idle_time              = 3'h0;  
                en_back_to_back_trans      = 1'h0;		
                cpha                       = 1'h1;                                   
                cpol                       = 1'h1;                                  
                first_bit_transfer         = 1'h0;
			    addr_32b = QSPI_CONFIG_REG_0_REG_ADDR;
			    qspi_config_0_wr_data = {16'b0, en_frame_end_done_cntr, en_flash_address_space_map, 
			                             data_endianness, sck_rate, chip_select_behaviour, min_idle_time, 
			    						 en_back_to_back_trans, cpha, cpol, first_bit_transfer};
			    wr_data_32b = qspi_config_0_wr_data;
			    if (overwrite_gui_settings == 1) begin
			        #100; write_to_intf(addr_32b, wr_data_32b);
			    end
		        // Write 0 to Start transaction Register
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000000;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_0 - supported flash command
		        xfer_len_bytes        = 16'h0;
		        num_wait_state        = 8'h0;
		        multiple_flash_target = multiple_flash_target_input;
		        flash_cmd_code        = flash_cmd_code_input;
		        with_payload          = 1'h0; 
		        sup_flash_cmd         = 1'h1; 
		        addr_32b              = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_0_REG_ADDR;
		        packet_header_0_wr_data = {xfer_len_bytes, num_wait_state, multiple_flash_target, flash_cmd_code, with_payload, sup_flash_cmd};
		        wr_data_32b = packet_header_0_wr_data;
		        #100;
		        write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_1
		        flash_addr_width      = 3'b000;
		        tgt_cs                = tgt_cs_input; 
                if (flash_cmd_code_input == 5'h1F) begin	
		            data_lane_width       = 2'b10;  // Quad SPI
		            addr_lane_width       = 2'b10;  // Quad SPI
		            cmd_lane_width        = 2'b10;  // Quad SPI	
				end else begin				
		            data_lane_width       = 2'b00;  // Standard SPI
		            addr_lane_width       = 2'b00;  // Standard SPI
		            cmd_lane_width        = 2'b00;  // Standard SPI 
				end
		        packet_header_1_wr_data = {16'h0, flash_addr_width, tgt_cs, 2'h0, data_lane_width, addr_lane_width, cmd_lane_width};
		        addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_1_REG_ADDR;
		        wr_data_32b = packet_header_1_wr_data;
		        #100;
		        write_to_intf(addr_32b, wr_data_32b);
		        //// Write to pkt_header_2 and pkt_header_3
		        //addr_32b    = PACKET_HEADER_2_REG_ADDR;
		        //wr_data_32b = 32'h0;
		        //#100;
		        //write_to_intf(addr_32b, wr_data_32b);
		        //addr_32b    = PACKET_HEADER_3_REG_ADDR;
		        //wr_data_32b = 32'h0;
		        //#100;
		        //write_to_intf(addr_32b, wr_data_32b);
		        // Start transaction
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000001;
		        #100;
		        write_to_intf(addr_32b, wr_data_32b);
		        #100;
		        read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
		        while (rd_data_32b[0] == 1) begin
		            read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
		            #100;
		        end
		        // Start transaction
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000000; // without this only 1 transaction will be started by the controller
		        #100;  write_to_intf(addr_32b, wr_data_32b);
			$display("# ---INFO : @%0dns :: Done supported_flash_command_opcode_only testing", $time);
	    end
	endtask
	
	
	
	// Erase Sequence using Supported Commands
	task erase_using_supported_commands;
		input [0:0] multiple_flash_target_input;
	    input [4:0] flash_cmd_code_input;
		input [2:0] flash_addr_width_input;
		input [1:0] data_lane_width_input;
		input [1:0] addr_lane_width_input;
	    input [1:0] cmd_lane_width_input;
		input [31:0] flash_addr_input;
		input [4:0] tgt_cs_input;
		
        reg [31:0] addr_32b;
        reg [31:0] flash_addr_32b;
        reg [31:0] flash_wr_data_32b [255:0];
        reg [31:0] flash_rd_data_32b [255:0];
        reg [31:0] pkt_hdr_addr_32b;
        reg [31:0] wr_data_32b;
		reg [31:0] rd_data_32b;
		reg [31:0] num_of_bytes;
		reg [31:0] limit_num_of_bytes;
		integer m_i_i;
		integer m_j_i;
		
		//QSPI_CONFIG_REG_0_REG_ADDR
		reg [31:0] qspi_config_0_wr_data;
		reg en_frame_end_done_cntr;
        reg en_flash_address_space_map;
        reg data_endianness;                        
        reg [4:0] sck_rate;
		reg chip_select_behaviour;                  
        reg [2:0] min_idle_time;  
        reg en_back_to_back_trans;		
        reg cpha;                                   
        reg cpol;                                   
        reg first_bit_transfer;
		
		//QSPI_CONFIG_REG_1_REG_ADDR
		reg [31:0] qspi_config_1_wr_data;
		reg [15:0] trgt_rd_trans_cnt;
		reg [15:0] trgt_wr_trans_cnt;
		
		//PACKET_HEADER_0
		reg [31:0] packet_header_0_wr_data;
		reg [15:0] xfer_len_bytes; 
		reg [7:0] num_wait_state;  
		reg multiple_flash_target; 
		reg [4:0] flash_cmd_code;  
		reg with_payload;          
		reg sup_flash_cmd;  

		//PACKET_HEADER_1
		reg [31:0] packet_header_1_wr_data;
        reg [2:0] flash_addr_width;
        reg [4:0] tgt_cs;          
        reg [1:0] data_lane_width; 
        reg [1:0] addr_lane_width; 
        reg [1:0] cmd_lane_width; 
		
		//PACKET_HEADER_0 - Unsupported Commands
		reg [2:0]  num_wait_sck;
		reg        multiple_target;
		reg        frm_end;
		reg        frm_start;
		reg        data_rate;
		reg [1:0]  lane_width;
		reg        cmd_type;
		
		//PACKET DATA 0 - Unsupported Commands
		reg [7:0]  flash_cmd_opcode;
		reg [23:0] flash_address;
	    begin
		    // Erase - For MX25L51245G can work on Standard SPI and Quad SPI
		        // flash_command_code == 5'h10 // Block Erase Type 1
		        // flash_command_code == 5'h11 // Block Erase Type 2
		        // flash_command_code == 5'h12 // Block Erase Type 3
		        // flash_command_code == 5'h13 // Chip Erase
			
			// Erase - For Winbond W25Q512JV, 1-1-1 sequence
		        // flash_command_code == 5'h10 // Block Erase Type 1
		        // flash_command_code == 5'h11 // Block Erase Type 2
		        // flash_command_code == 5'h12 // Block Erase Type 3
		        // flash_command_code == 5'h13 // Chip Erase
				
		        // Write 0 to Start transaction Register
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000000;
		        #100; write_to_intf(addr_32b, wr_data_32b);	
				
			    $display("# ---INFO : @%0dns :: Setting registers to execute erase operation.", $time);
		        // Write to pkt_header_0 - supported flash command
		        xfer_len_bytes          = 16'h0;
		        num_wait_state          = 8'h0;
		        multiple_flash_target   = multiple_flash_target_input;
		        flash_cmd_code          = flash_cmd_code_input; 
		        with_payload            = 1'h0; 
		        sup_flash_cmd           = 1'h1;
			    addr_32b                = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_0_REG_ADDR;
		        packet_header_0_wr_data = {xfer_len_bytes, num_wait_state, multiple_flash_target, flash_cmd_code, with_payload, sup_flash_cmd};
		        wr_data_32b             = packet_header_0_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_1
		        flash_addr_width        = flash_addr_width_input;
		        tgt_cs                  = tgt_cs_input; 
		        data_lane_width         = data_lane_width_input;
		        addr_lane_width         = addr_lane_width_input;
		        cmd_lane_width          = cmd_lane_width_input; 
		        packet_header_1_wr_data = {16'h0, flash_addr_width, tgt_cs, 2'h0, data_lane_width, addr_lane_width, cmd_lane_width};
                addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_1_REG_ADDR;
		        wr_data_32b = packet_header_1_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_2 and pkt_header_3
                addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_2_REG_ADDR;
		        wr_data_32b = flash_addr_input;
		        #100; write_to_intf(addr_32b, wr_data_32b);
				if (ENABLE_TRANSMIT_FIFO == 0) begin
                    addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_3_REG_ADDR;
		            wr_data_32b = 32'h0;
		            #100; write_to_intf(addr_32b, wr_data_32b);
				end
		        // Start transaction
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000001;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Read TRANSACTION_STATUS
		        #100; read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
				$display("# ---INFO : @%0dns :: Polling transaction status register.", $time);
				if (rd_data_32b[0] == 1) begin
				    $display("# ---INFO : @%0dns :: Erase operation started.", $time);
				end
				else begin
				    $display("# ---INFO : @%0dns :: Erase operation not yet started.", $time);
				end
		        while (rd_data_32b[0] == 1) begin
		            read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b); #100;
		        end
				$display("# ---INFO : @%0dns :: Erase operation done.", $time);
		end
	endtask
	
	// Page Program Sequence using Supported Commands
	task page_program_using_supported_commands;
	    input [15:0] wr_xfer_len_bytes;
		input [4:0] flash_cmd_code_input; 
		input [2:0] flash_addr_width_input;
		input [1:0] data_lane_width_input;
		input [1:0] addr_lane_width_input;
	    input [1:0] cmd_lane_width_input; 
		input [31:0] flash_addr_input;
		//output [31:0] flash_wr_data_32b [262143:0];
	    reg  [31:0] flash_wr_data_32b [262143:0];
		
        reg [31:0] addr_32b;
        reg [31:0] flash_addr_32b;
        reg [31:0] flash_rd_data_32b [255:0];
        reg [31:0] pkt_hdr_addr_32b;
        reg [31:0] wr_data_32b;
		reg [31:0] rd_data_32b;
		reg [31:0] num_of_bytes;
		reg [31:0] limit_num_of_bytes;
		integer m_i_i;
		integer m_j_i;
		
		//QSPI_CONFIG_REG_0_REG_ADDR
		reg [31:0] qspi_config_0_wr_data;
		reg en_frame_end_done_cntr;
        reg en_flash_address_space_map;
        reg data_endianness;                        
        reg [4:0] sck_rate;
		reg chip_select_behaviour;                  
        reg [2:0] min_idle_time;  
        reg en_back_to_back_trans;		
        reg cpha;                                   
        reg cpol;                                   
        reg first_bit_transfer;
		
		//QSPI_CONFIG_REG_1_REG_ADDR
		reg [31:0] qspi_config_1_wr_data;
		reg [15:0] trgt_rd_trans_cnt;
		reg [15:0] trgt_wr_trans_cnt;
		
		//PACKET_HEADER_0
		reg [31:0] packet_header_0_wr_data;
		reg [15:0] xfer_len_bytes; 
		reg [7:0] num_wait_state;  
		reg multiple_flash_target; 
		reg [4:0] flash_cmd_code;  
		reg with_payload;          
		reg sup_flash_cmd;  

		//PACKET_HEADER_1
		reg [31:0] packet_header_1_wr_data;
        reg [2:0] flash_addr_width;
        reg [4:0] tgt_cs;          
        reg [1:0] data_lane_width; 
        reg [1:0] addr_lane_width; 
        reg [1:0] cmd_lane_width; 
		
		//PACKET_HEADER_0 - Unsupported Commands
		reg [2:0]  num_wait_sck;
		reg        multiple_target;
		reg        frm_end;
		reg        frm_start;
		reg        data_rate;
		reg [1:0]  lane_width;
		reg        cmd_type;
		
		//PACKET DATA 0 - Unsupported Commands
		reg [7:0]  flash_cmd_opcode;
		reg [23:0] flash_address;
	    begin 
		    // Write 0 to Start transaction Register
		    addr_32b    = START_TRANSACTION_REG_ADDR;
		    wr_data_32b = 32'h00000000;
		    #100; write_to_intf(addr_32b, wr_data_32b);	
			
			$display("# ---INFO : @%0dns :: Setting registers to execute page program operation.", $time);
		    // Write to pkt_header_0 - supported flash command
		    xfer_len_bytes          = wr_xfer_len_bytes;
		    num_wait_state          = 8'h0;  
		    multiple_flash_target   = 1'h0;
		    flash_cmd_code          = flash_cmd_code_input;
		    with_payload            = 1'h1; 
		    sup_flash_cmd           = 1'h1; 
            addr_32b                = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_0_REG_ADDR;
		    packet_header_0_wr_data = {xfer_len_bytes, num_wait_state, multiple_flash_target, flash_cmd_code, with_payload, sup_flash_cmd};
		    wr_data_32b             = packet_header_0_wr_data;
		    #100; write_to_intf(addr_32b, wr_data_32b);
		    // Write to pkt_header_1
		    flash_addr_width        = flash_addr_width_input;
		    tgt_cs                  = 5'h0;  
		    data_lane_width         = data_lane_width_input;
		    addr_lane_width         = addr_lane_width_input;
		    cmd_lane_width          = cmd_lane_width_input; 
		    packet_header_1_wr_data = {16'h0, flash_addr_width, tgt_cs, 2'h0, data_lane_width, addr_lane_width, cmd_lane_width};
		    addr_32b                = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_1_REG_ADDR;
			wr_data_32b             = packet_header_1_wr_data;
		    #100; write_to_intf(addr_32b, wr_data_32b);
		    // Write to pkt_header_2 and pkt_header_3
			addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_2_REG_ADDR;
		    wr_data_32b = flash_addr_input;
		    #100; write_to_intf(addr_32b, wr_data_32b);
			if (ENABLE_TRANSMIT_FIFO == 0) begin
			    addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_3_REG_ADDR;
		        wr_data_32b = 32'h0;
		        #100; write_to_intf(addr_32b, wr_data_32b);
			end
			// Write to Interrupt Status Register
		    addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		    wr_data_32b = 32'hFFFFFFFF;
		    #100; write_to_intf(addr_32b, wr_data_32b);
			// Enable Interrupt Status Register
		    addr_32b    = INTERRUPT_ENABLE_REG_ADDR;
		    wr_data_32b = 32'h00000003;
		    #100; write_to_intf(addr_32b, wr_data_32b);
		    // Write to pkt_data_0
		    addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_DATA_0_REG_ADDR;
		    wr_data_32b = $random;
			flash_wr_data_32b[0][31:0] = wr_data_32b;
		    #100; write_to_intf(addr_32b, wr_data_32b);
			$display("---INFO : @%0dns :: Write Data 0x%x", $time, wr_data_32b);
            // Write to pkt_data_1
		    addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_DATA_1_REG_ADDR;
		    wr_data_32b = $random;
			flash_wr_data_32b[1][31:0] = wr_data_32b;
		    #100; write_to_intf(addr_32b, wr_data_32b);
			$display("---INFO : @%0dns :: Write Data 0x%x", $time, wr_data_32b);
			if (ENABLE_TRANSMIT_FIFO == 0) begin
			    // Start transaction
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000001;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Read TRANSACTION_STATUS
		        #100; read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
			    $display("# ---INFO : @%0dns :: Polling transaction status register.", $time);
			    if (rd_data_32b[0] == 1) begin
			        $display("# ---INFO : @%0dns :: Page program started.", $time);
			    end
			    else begin
			        $display("# ---INFO : @%0dns :: Page program not yet started.", $time);
			    end
			    num_of_bytes = 8;
			    limit_num_of_bytes = xfer_len_bytes-1;
			    while (num_of_bytes < limit_num_of_bytes) begin // write remaining bytes of data
			        read_from_intf(INTERRUPT_STATUS_REG_ADDR, rd_data_32b);
			    	if (rd_data_32b[0] == 1) begin
			            // Write to Interrupt Status Register
		                addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		                wr_data_32b = 32'h00000001;
		                #100; write_to_intf(addr_32b, wr_data_32b);
		                // Write to pkt_data_0
		                addr_32b    = PACKET_DATA_0_REG_ADDR;
		                wr_data_32b = $random;
			            flash_wr_data_32b[(num_of_bytes>>2)][31:0] = wr_data_32b;
		                #100; write_to_intf(addr_32b, wr_data_32b);
			            $display("---INFO : @%0dns :: Write Data 0x%x", $time, wr_data_32b);
			    		num_of_bytes = num_of_bytes + 4;
			    	end
			    	else begin
		                #50;
			    	end
			        read_from_intf(INTERRUPT_STATUS_REG_ADDR, rd_data_32b);
			    	if (rd_data_32b[1] == 1) begin
			            // Write to Interrupt Status Register
		                addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		                wr_data_32b = 32'h00000002;
		                #100; write_to_intf(addr_32b, wr_data_32b);
		                // Write to pkt_data_0
		                addr_32b    = PACKET_DATA_1_REG_ADDR;
		                wr_data_32b = $random;
			            flash_wr_data_32b[(num_of_bytes>>2)][31:0] = wr_data_32b;
		                #100; write_to_intf(addr_32b, wr_data_32b);
			            $display("---INFO : @%0dns :: Write Data 0x%x", $time, wr_data_32b);
			    		num_of_bytes = num_of_bytes + 4;
			    	end
			    	else begin
		                #50;
			    	end
			    end
				read_from_intf(INTERRUPT_STATUS_REG_ADDR, rd_data_32b);
				while (rd_data_32b[1:0] != 2'b11) begin
		            read_from_intf(INTERRUPT_STATUS_REG_ADDR, rd_data_32b);
		            #100;
		        end
			    // Write to Interrupt Status Register
		        addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		        wr_data_32b = 32'hFFFFFFFF;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
			    $display("# ---INFO : @%0dns :: Polling transaction status register.", $time);	
                if (rd_data_32b[0] == 1) $display("# ---INFO : @%0dns :: Page program is still on-going.", $time);				
		        while (rd_data_32b[0] == 1) begin
		            read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
		            #100;
		        end
			    $display("# ---INFO : @%0dns :: Page program done.", $time);
			end
			else begin
			    for(m_i_i = 0; m_i_i < ((xfer_len_bytes)>>2); m_i_i = m_i_i +1) begin
		            // Write to TX FIFO
		            addr_32b    = TX_FIFO_MAPPING_REG_ADDR;
		            wr_data_32b = $random;
			        flash_wr_data_32b[(m_i_i)][31:0] = wr_data_32b;
				    $display("---INFO : @%0dns :: Write Data 0x%x", $time, wr_data_32b);
		            #100; write_to_intf(addr_32b, wr_data_32b);
			    end
			    // Start transaction
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000001;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Read TRANSACTION_STATUS
		        #100; read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
				$display("# ---INFO : @%0dns :: Polling transaction status register.", $time);
				if (rd_data_32b[0] == 1) begin
				    $display("# ---INFO : @%0dns :: Page program started.", $time);
				end
				else begin
				    $display("# ---INFO : @%0dns :: Page program not yet started.", $time);
				end
		        while (rd_data_32b[0] == 1) begin
		            read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
		            #100;
		        end
				$display("# ---INFO : @%0dns :: Page program done.", $time);
			end
		end
	endtask
	
	// Read Sequence using Supported Commands
	task read_using_supported_commands;
	    input [15:0] rd_xfer_len_bytes_input;
		input [4:0] flash_cmd_code_input; 
		input [7:0] num_wait_state_input;
		input [2:0] flash_addr_width_input;
		input [1:0] data_lane_width_input;
		input [1:0] addr_lane_width_input;
	    input [1:0] cmd_lane_width_input; 
		input [31:0] flash_addr_input;
		input [31:0] flash_wr_data_32b [262143:0];
		input [31:0] loop_read_cntr;
		input [15:0] rd_xfer_len_bytes_for_loop;
		
        reg [31:0] addr_32b;
        reg [31:0] flash_addr_32b;
        reg [31:0] flash_rd_data_32b [262143:0];
        reg [31:0] pkt_hdr_addr_32b;
        reg [31:0] wr_data_32b;
		reg [31:0] rd_data_32b;
		reg [31:0] num_of_bytes;
		reg [31:0] limit_num_of_bytes;
		integer m_i_i;
		integer m_j_i;
		
		//QSPI_CONFIG_REG_0_REG_ADDR
		reg [31:0] qspi_config_0_wr_data;
		reg en_frame_end_done_cntr;
        reg en_flash_address_space_map;
        reg data_endianness;                        
        reg [4:0] sck_rate;
		reg chip_select_behaviour;                  
        reg [2:0] min_idle_time;  
        reg en_back_to_back_trans;		
        reg cpha;                                   
        reg cpol;                                   
        reg first_bit_transfer;
		
		//QSPI_CONFIG_REG_1_REG_ADDR
		reg [31:0] qspi_config_1_wr_data;
		reg [15:0] trgt_rd_trans_cnt;
		reg [15:0] trgt_wr_trans_cnt;
		
		//PACKET_HEADER_0
		reg [31:0] packet_header_0_wr_data;
		reg [15:0] xfer_len_bytes; 
		reg [7:0] num_wait_state;  
		reg multiple_flash_target; 
		reg [4:0] flash_cmd_code;  
		reg with_payload;          
		reg sup_flash_cmd;  

		//PACKET_HEADER_1
		reg [31:0] packet_header_1_wr_data;
        reg [2:0] flash_addr_width;
        reg [4:0] tgt_cs;          
        reg [1:0] data_lane_width; 
        reg [1:0] addr_lane_width; 
        reg [1:0] cmd_lane_width; 
		
		//PACKET_HEADER_0 - Unsupported Commands
		reg [2:0]  num_wait_sck;
		reg        multiple_target;
		reg        frm_end;
		reg        frm_start;
		reg        data_rate;
		reg [1:0]  lane_width;
		reg        cmd_type;
		
		//PACKET DATA 0 - Unsupported Commands
		reg [7:0]  flash_cmd_opcode;
		reg [23:0] flash_address;
	    begin
		    // Write 0 to Start transaction Register
		    addr_32b    = START_TRANSACTION_REG_ADDR;
		    wr_data_32b = 32'h00000000;
		    #100; write_to_intf(addr_32b, wr_data_32b);
			
			$display("# ---INFO : @%0dns :: Setting registers to execute page read operation.", $time);
		    xfer_len_bytes        = rd_xfer_len_bytes_input;
		    multiple_flash_target = 1'h0;
		    flash_cmd_code        = flash_cmd_code_input;
		    num_wait_state        = num_wait_state_input;
		    with_payload          = 1'h0; 
		    sup_flash_cmd         = 1'h1; 
		    addr_32b = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_0_REG_ADDR;
		    packet_header_0_wr_data = {xfer_len_bytes, num_wait_state, multiple_flash_target, flash_cmd_code, with_payload, sup_flash_cmd};
		    wr_data_32b = packet_header_0_wr_data;
		    #100; write_to_intf(addr_32b, wr_data_32b);
		    // Write to pkt_header_1
		    flash_addr_width        = flash_addr_width_input;
		    tgt_cs                  = 5'h0; 
		    data_lane_width         = data_lane_width_input;
		    addr_lane_width         = addr_lane_width_input;
		    cmd_lane_width          = cmd_lane_width_input;
		    packet_header_1_wr_data = {16'h0, flash_addr_width, tgt_cs, 2'h0, data_lane_width, addr_lane_width, cmd_lane_width};
		    addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_1_REG_ADDR;
			wr_data_32b = packet_header_1_wr_data;
		    #100; write_to_intf(addr_32b, wr_data_32b);
		    // Write to pkt_header_2 and pkt_header_3
		    addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_2_REG_ADDR;
		    wr_data_32b = flash_addr_input;
		    #100; write_to_intf(addr_32b, wr_data_32b);
			if (ENABLE_TRANSMIT_FIFO == 0) begin
		       addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_3_REG_ADDR;
		       wr_data_32b = 32'h0;
		       #100; write_to_intf(addr_32b, wr_data_32b);
			end
			// Write to Interrupt Status Register
		    addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		    wr_data_32b = 32'hFFFFFFFF;
		    #100; write_to_intf(addr_32b, wr_data_32b);
			// Enable Interrupt Status Register
		    addr_32b    = INTERRUPT_ENABLE_REG_ADDR;
		    wr_data_32b = 32'h00000030;
		    #100; write_to_intf(addr_32b, wr_data_32b);
		    // Start transaction
		    addr_32b    = START_TRANSACTION_REG_ADDR;
		    wr_data_32b = 32'h00000001;
		    #100; write_to_intf(addr_32b, wr_data_32b);
		    // Read TRANSACTION_STATUS
		    #100; read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
			$display("# ---INFO : @%0dns :: Polling transaction status register.", $time);
			if (rd_data_32b[0] == 1) begin
			    $display("# ---INFO : @%0dns :: Page read started.", $time);
			end
			else begin
			    $display("# ---INFO : @%0dns :: Page read not yet started.", $time);
			end
            if (ENABLE_RECEIVE_FIFO == 0) begin			
			    num_of_bytes = 0;
			    while (num_of_bytes < xfer_len_bytes-1) begin
			        read_from_intf(INTERRUPT_STATUS_REG_ADDR, rd_data_32b);
			    	if (rd_data_32b[4] == 1) begin
		                //Read from pkt_data_0
			    		addr_32b = ENABLE_RECEIVE_FIFO ? RX_FIFO_MAPPING_REG_ADDR : PACKET_DATA_0_REG_ADDR;
			            read_from_intf(addr_32b, rd_data_32b);
			            flash_rd_data_32b[(num_of_bytes>>2)+(rd_xfer_len_bytes_for_loop*loop_read_cntr)][31:0] = rd_data_32b;
                        do_data_compare(flash_wr_data_32b[(num_of_bytes>>2)],flash_rd_data_32b[(num_of_bytes>>2)]);
		                //#100;
			            // Write to Interrupt Status Register
		                addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		                wr_data_32b = 32'h00000010;
		                //#100; 
			    		write_to_intf(addr_32b, wr_data_32b);
			            read_from_intf(INTERRUPT_STATUS_REG_ADDR, rd_data_32b);
			    		num_of_bytes = num_of_bytes + 4;
			    	end
			    	else begin
		                #100;
			    	end
			    end
		        read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);	
			    $display("# ---INFO : @%0dns :: Polling transaction status register.", $time);		
		        while (rd_data_32b[0] == 1) begin
		            read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
		            #100;
			        if (rd_data_32b[0] == 1) begin
			            $display("# ---INFO : @%0dns :: Page read still on-going.", $time);
			        end
			        else begin
			            $display("# ---INFO : @%0dns :: Page read done.", $time);
			        end	
		        end
			end
			else begin
		        while (rd_data_32b[0] == 1) begin
		            read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
		            #100;
		        end
				$display("# ---INFO : @%0dns :: Page read done.", $time);
				num_of_bytes = 0;
			    for(m_i_i = 0; m_i_i < ((xfer_len_bytes)>>2); m_i_i = m_i_i +1) begin 
			        read_from_intf(RX_FIFO_MAPPING_REG_ADDR, rd_data_32b);
			        flash_rd_data_32b[m_i_i][31:0] = rd_data_32b;
					//#100;
                    do_data_compare(flash_wr_data_32b[m_i_i],flash_rd_data_32b[m_i_i]);
				end
			end
		end
	endtask

	// Page Program - Read Sequence using Supported Commands
	task page_program_read_using_supported_commands;
	    // For Page Program
	    input [15:0] prog_xfer_len_bytes_input;
		input [0:0] multiple_flash_target_input;
		input [4:0] prog_flash_cmd_code_input; 
		input [2:0] prog_flash_addr_width_input;
		input [4:0] tgt_cs_input;
		input [1:0] prog_data_lane_width_input;
		input [1:0] prog_addr_lane_width_input;
	    input [1:0] prog_cmd_lane_width_input; 
		input [31:0] flash_addr_input_val;
		
		// For Read
	    input [15:0] rd_xfer_len_bytes_input;
		input [4:0] read_flash_cmd_code_input; 
		input [7:0] num_wait_state_input;
		input [2:0] rd_flash_addr_width_input;
		input [1:0] rd_data_lane_width_input;
		input [1:0] rd_addr_lane_width_input;
	    input [1:0] rd_cmd_lane_width_input; 
		
		// For loops
		input [31:0] loop_write;
		input [31:0] loop_read;
		input [31:0] loop_write_read;
		input [31:0] prog_xfer_len_bytes_for_loop;
		input [31:0] rd_xfer_len_bytes_for_loop;
		
        reg [31:0] addr_32b;
        reg [31:0] flash_addr_32b;
		reg [31:0] flash_wr_data_32b [262143:0];
        reg [31:0] flash_rd_data_32b [262143:0];
        reg [31:0] pkt_hdr_addr_32b;
        reg [31:0] wr_data_32b;
		reg [31:0] rd_data_32b;
		reg [31:0] num_of_bytes;
		reg [31:0] limit_num_of_bytes;
		integer m_i_i;
		integer m_j_i;
		
		reg [31:0] loop_write_cntr;
		reg [31:0] loop_read_cntr;
		reg [31:0] loop_write_read_cntr;
	    reg [31:0] loop_flash_addr;
		reg [31:0] addr_inc_val;
		reg [31:0] addr_inc_val_shift;
		reg [31:0] loop_flash_wr_data_32b_cntr;
		reg [31:0] test_cntr;
		reg [31:0] start_flash_wr_data_cntr;
		reg [31:0] stop_flash_wr_data_cntr;
		reg [31:0] addr_shift;
		reg [31:0] bit_cntr;
		
		//QSPI_CONFIG_REG_0_REG_ADDR
		reg [31:0] qspi_config_0_wr_data;
		reg en_frame_end_done_cntr;
        reg en_flash_address_space_map;
        reg data_endianness;                        
        reg [4:0] sck_rate;
		reg chip_select_behaviour;                  
        reg [2:0] min_idle_time;  
        reg en_back_to_back_trans;		
        reg cpha;                                   
        reg cpol;                                   
        reg first_bit_transfer;
		
		//QSPI_CONFIG_REG_1_REG_ADDR
		reg [31:0] qspi_config_1_wr_data;
		reg [15:0] trgt_rd_trans_cnt;
		reg [15:0] trgt_wr_trans_cnt;
		
		//PACKET_HEADER_0
		reg [31:0] packet_header_0_wr_data;
		reg [15:0] xfer_len_bytes; 
		reg [7:0] num_wait_state;  
		reg multiple_flash_target; 
		reg [4:0] flash_cmd_code;  
		reg with_payload;          
		reg sup_flash_cmd;  

		//PACKET_HEADER_1
		reg [31:0] packet_header_1_wr_data;
        reg [2:0] flash_addr_width;
        reg [4:0] tgt_cs;          
        reg [1:0] data_lane_width; 
        reg [1:0] addr_lane_width; 
        reg [1:0] cmd_lane_width; 
		
		//PACKET_HEADER_0 - Unsupported Commands
		reg [2:0]  num_wait_sck;
		reg        multiple_target;
		reg        frm_end;
		reg        frm_start;
		reg        data_rate;
		reg [1:0]  lane_width;
		reg        cmd_type;
		
		//PACKET DATA 0 - Unsupported Commands
		reg [7:0]  flash_cmd_opcode;
		reg [23:0] flash_address;
		
	    begin 
		
		for (loop_write_read_cntr = 32'h00000000; loop_write_read_cntr < loop_write_read; loop_write_read_cntr = loop_write_read_cntr+1) begin
            if (flash_device == 2'b00) begin
			    if (prog_cmd_lane_width_input == 2'b00 & prog_data_lane_width_input == 2'b10 & prog_addr_lane_width_input == 2'b10 ) begin // Address and Data to be sent on 4 IO lanes	
                    // For Quad Enable Bit setting on Configuration Register
			        if (DATA_ENDIANNESS == 1) begin // Big Endian
			            supported_commands_test_send_command_and_write_data({8'h40, 24'h000000}, 5'h00, 1'h0, 5'h0);
			    	end
			    	else begin
			            supported_commands_test_send_command_and_write_data({24'h000000, 8'h40}, 5'h00, 1'h0, 5'h0);
			    	end   
				end
				else if (prog_cmd_lane_width_input == 2'b10 & prog_data_lane_width_input == 2'b10 & prog_addr_lane_width_input == 2'b10 ) begin // Address and Data to be sent on 4 IO lanes	
                    // Enter Quad I/O
					supported_flash_command_opcode_only(1'h0, 5'h1E, 5'h0);     
				end
			end
			
			if (flash_device == 2'b01) begin
			    // Settings for Page Program		
			    if (prog_data_lane_width_input == 2'b10) begin // Data to be send on 4 IO lanes	
			        // Set Quad Enable bit on Status Register 2
			        // Change opcode of WRSR on Flash Command Code 5 0x0000_0020 since there is no supported command for WRSR-2
			        // Data {WREN, WRDIS, WRSR, PP}
			    	$display("# ---INFO : @%0dns :: Change WRSR command opcode.", $time);
			        set_flash_command_code(32'h00000020, {8'h06, 8'h04, 8'h31, 8'h02});
			        if (DATA_ENDIANNESS == 1) begin // Big Endian
			            // Write 1 to Quad Enable Bit
			            supported_commands_test_send_command_and_write_data({8'h02, 24'h000000}, 5'h01, 1'h1, 5'h1);
			        end
			        else begin
			    	    // Write 1 to Quad Enable Bit
			            supported_commands_test_send_command_and_write_data({24'h000000, 8'h02}, 5'h01, 1'h1, 5'h1);
			        end	
			    end
			
			    // Flash Byte Address Mode 
			    if (prog_flash_addr_width_input == 3'b011) begin //4-bytes address
	    	        // ENTER_4_BYTE_ADDRESS_MODE
	    	        //supported_flash_command_opcode_only(5'h1C);
			        // Update the command opcodes to 4-byte operation opcodes
			    	command_code_update(1);
			    end
		        else begin // just to add some random test
	    	        // ENTER_4_BYTE_ADDRESS_MODE
	    	        supported_flash_command_opcode_only(1'h1, 5'h1C, 5'h1);
	    	        // EXIT_4_BYTE_ADDRESS_MODE
	    	        supported_flash_command_opcode_only(1'h1, 5'h1D, 5'h1);
			    	command_code_update(0);
			    end	
			end
			
			// Flash Byte Address Mode 
			if (prog_flash_addr_width_input == 3'b011) begin //4-bytes address
				addr_shift = 32'h0;
			end
		    else begin
				addr_shift = 32'h8;
			end	
			
		    // Start of Page Program
			for (loop_write_cntr = 32'h00000000; loop_write_cntr < loop_write; loop_write_cntr = loop_write_cntr+1) begin
	    	// Calculate starting flash address for the Loop
			    if (DATA_ENDIANNESS == 1 ) begin //Big Endian
				    loop_flash_addr    = flash_addr_input_val + ((256*(loop_write_cntr+loop_write_read_cntr)<<addr_shift));
			    end
			    else begin // Little Endian
				    addr_inc_val       = (256*(loop_write_cntr+loop_write_read_cntr));
			        if (prog_flash_addr_width_input == 3'b011) begin //4-bytes address
					    addr_inc_val_shift = {addr_inc_val[7:0], addr_inc_val[15:8], addr_inc_val[23:16], addr_inc_val[31:24]};
				        loop_flash_addr    = flash_addr_input_val + addr_inc_val_shift;
			        end
		            else begin
					    addr_inc_val_shift = {addr_inc_val[7:0], addr_inc_val[15:8], addr_inc_val[23:16], 8'h0};
				        loop_flash_addr    = flash_addr_input_val + addr_inc_val_shift;
			        end	
			    end
			// Start of Page Program
		        // Write 0 to Start transaction Register
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000000;
		        #100; write_to_intf(addr_32b, wr_data_32b);	
			    
			    $display("# ---INFO : @%0dns :: Setting registers to execute page program operation.", $time);
		        // Write to pkt_header_0 - supported flash command
		        xfer_len_bytes          = prog_xfer_len_bytes_for_loop;
		        num_wait_state          = 8'h0;  
		        multiple_flash_target   = multiple_flash_target_input;
		        flash_cmd_code          = prog_flash_cmd_code_input;
		        with_payload            = 1'h1; 
		        sup_flash_cmd           = 1'h1; 
                addr_32b                = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_0_REG_ADDR;
		        packet_header_0_wr_data = {xfer_len_bytes, num_wait_state, multiple_flash_target, flash_cmd_code, with_payload, sup_flash_cmd};
		        wr_data_32b             = packet_header_0_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_1
		        flash_addr_width        = prog_flash_addr_width_input;
		        tgt_cs                  = tgt_cs_input;  
		        data_lane_width         = prog_data_lane_width_input;
		        addr_lane_width         = prog_addr_lane_width_input;
		        cmd_lane_width          = prog_cmd_lane_width_input; 
		        packet_header_1_wr_data = {16'h0, flash_addr_width, tgt_cs, 2'h0, data_lane_width, addr_lane_width, cmd_lane_width};
		        addr_32b                = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_1_REG_ADDR;
			    wr_data_32b             = packet_header_1_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_2 and pkt_header_3
			    addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_2_REG_ADDR;
		        wr_data_32b = loop_flash_addr;
		        #100; write_to_intf(addr_32b, wr_data_32b);
			    if (ENABLE_TRANSMIT_FIFO == 0) begin
			        addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_3_REG_ADDR;
		            wr_data_32b = 32'h0;
		            #100; write_to_intf(addr_32b, wr_data_32b);
			    end
			    // Write to Interrupt Status Register
		        addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		        wr_data_32b = 32'hFFFFFFFF;
		        #100; write_to_intf(addr_32b, wr_data_32b);
			    // Enable Interrupt Status Register
		        addr_32b    = INTERRUPT_ENABLE_REG_ADDR;
		        wr_data_32b = 32'h00000003;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_data_0
		        addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_DATA_0_REG_ADDR;
		        wr_data_32b = $random;
			    flash_wr_data_32b[0+(64*loop_write_cntr)][31:0] = wr_data_32b;
		        #100; write_to_intf(addr_32b, wr_data_32b);
			    $display("---INFO : @%0dns :: Write Data 0x%x", $time, wr_data_32b);
                // Write to pkt_data_1
		        addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_DATA_1_REG_ADDR;
		        wr_data_32b = $random;
			    flash_wr_data_32b[1+(64*loop_write_cntr)][31:0] = wr_data_32b;
		        #100; write_to_intf(addr_32b, wr_data_32b);
			    $display("---INFO : @%0dns :: Write Data 0x%x", $time, wr_data_32b);
			    if (ENABLE_TRANSMIT_FIFO == 0) begin
			        // Start transaction
		            addr_32b    = START_TRANSACTION_REG_ADDR;
		            wr_data_32b = 32'h00000001;
		            #100; write_to_intf(addr_32b, wr_data_32b);
		            // Read TRANSACTION_STATUS
		            #100; read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
			        $display("# ---INFO : @%0dns :: Polling transaction status register.", $time);
			        if (rd_data_32b[0] == 1) begin
			            $display("# ---INFO : @%0dns :: Page program started.", $time);
			        end
			        else begin
			            $display("# ---INFO : @%0dns :: Page program not yet started.", $time);
			        end
			        num_of_bytes = 8;
			        limit_num_of_bytes = xfer_len_bytes-1;
			        while (num_of_bytes < limit_num_of_bytes) begin // write remaining bytes of data
			            read_from_intf(INTERRUPT_STATUS_REG_ADDR, rd_data_32b);
			        	if (rd_data_32b[0] == 1) begin
			                // Write to Interrupt Status Register
		                    addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		                    wr_data_32b = 32'h00000001;
		                    #100; write_to_intf(addr_32b, wr_data_32b);
		                    // Write to pkt_data_0
		                    addr_32b    = PACKET_DATA_0_REG_ADDR;
		                    wr_data_32b = $random;
			                flash_wr_data_32b[(num_of_bytes>>2)+(64*loop_write_cntr)][31:0] = wr_data_32b;
		                    #100; write_to_intf(addr_32b, wr_data_32b);
			                $display("---INFO : @%0dns :: Write Data 0x%x", $time, wr_data_32b);
			        		num_of_bytes = num_of_bytes + 4;
			        	end
			        	else begin
		                    #50;
			        	end
			            read_from_intf(INTERRUPT_STATUS_REG_ADDR, rd_data_32b);
			        	if (rd_data_32b[1] == 1) begin
			                // Write to Interrupt Status Register
		                    addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		                    wr_data_32b = 32'h00000002;
		                    #100; write_to_intf(addr_32b, wr_data_32b);
		                    // Write to pkt_data_0
		                    addr_32b    = PACKET_DATA_1_REG_ADDR;
		                    wr_data_32b = $random;
			                flash_wr_data_32b[(num_of_bytes>>2)+(64*loop_write_cntr)][31:0] = wr_data_32b;
		                    #100; write_to_intf(addr_32b, wr_data_32b);
			                $display("---INFO : @%0dns :: Write Data 0x%x", $time, wr_data_32b);
			        		num_of_bytes = num_of_bytes + 4;
			        	end
			        	else begin
		                    #50;
			        	end
			        end
			    	read_from_intf(INTERRUPT_STATUS_REG_ADDR, rd_data_32b);
			    	while (rd_data_32b[1:0] != 2'b11) begin
		                read_from_intf(INTERRUPT_STATUS_REG_ADDR, rd_data_32b);
		                #100;
		            end
			        // Write to Interrupt Status Register
		            addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		            wr_data_32b = 32'hFFFFFFFF;
		            #100; write_to_intf(addr_32b, wr_data_32b);
		            read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
			        $display("# ---INFO : @%0dns :: Polling transaction status register.", $time);	
                    if (rd_data_32b[0] == 1) $display("# ---INFO : @%0dns :: Page program is still on-going.", $time);				
		            while (rd_data_32b[0] == 1) begin
		                read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
		                #100;
		            end
			        $display("# ---INFO : @%0dns :: Page program done.", $time);
			    end
			    else begin
			        for(m_i_i = 2; m_i_i < ((xfer_len_bytes)>>2); m_i_i = m_i_i +1) begin
		                // Write to TX FIFO
		                addr_32b    = TX_FIFO_MAPPING_REG_ADDR;
		                wr_data_32b = $random;
			            flash_wr_data_32b[(m_i_i)+(64*loop_write_cntr)][31:0] = wr_data_32b;
			    	    $display("---INFO : @%0dns :: Write Data 0x%x", $time, wr_data_32b);
		                #100; write_to_intf(addr_32b, wr_data_32b);
			        end
			        // Start transaction
		            addr_32b    = START_TRANSACTION_REG_ADDR;
		            wr_data_32b = 32'h00000001;
		            #100; write_to_intf(addr_32b, wr_data_32b);
		            // Read TRANSACTION_STATUS
		            #100; read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
			    	$display("# ---INFO : @%0dns :: Polling transaction status register.", $time);
			    	if (rd_data_32b[0] == 1) begin
			    	    $display("# ---INFO : @%0dns :: Page program started.", $time);
			    	end
			    	else begin
			    	    $display("# ---INFO : @%0dns :: Page program not yet started.", $time);
			    	end
		            while (rd_data_32b[0] == 1) begin
		                read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
		                #100;
		            end
			    	$display("# ---INFO : @%0dns :: Page program done.", $time);
			    end
			end
			// End of Page Program
            if (flash_device == 2'b00) begin
			    if (prog_cmd_lane_width_input == 2'b00 & prog_data_lane_width_input == 2'b10 & prog_addr_lane_width_input == 2'b10 ) begin // Address and Data to be sent on 4 IO lanes	
			        supported_commands_test_send_command_and_write_data(32'h0, 5'h00, 1'h0, 5'h0);
				end
				else if (prog_cmd_lane_width_input == 2'b10 & prog_data_lane_width_input == 2'b10 & prog_addr_lane_width_input == 2'b10 ) begin // Address and Data to be sent on 4 IO lanes	
                    supported_flash_command_opcode_only(1'h0, 5'h1F, 5'h0);     
				end
			end
			if (flash_device == 2'b01) begin
			    supported_commands_test_send_command_and_write_data(32'h00000000, 5'h01, 1'h1, 5'h1);
			end
			
		// Settings for Read 
			if (flash_device == 2'b00) begin
			    if ((rd_cmd_lane_width_input == 2'b00 & rd_addr_lane_width_input == 2'b10 & rd_data_lane_width_input == 2'b10) |  // Address and Data to be sent on 4 IO lanes	
				    (rd_cmd_lane_width_input == 2'b00 & rd_addr_lane_width_input == 2'b00 & rd_data_lane_width_input == 2'b10) ) begin  // Data to be sent on 4 IO lanes	
                    // For Quad Enable Bit setting on Configuration Register
			        if (DATA_ENDIANNESS == 1) begin // Big Endian
			            supported_commands_test_send_command_and_write_data({8'h40, 24'h000000}, 5'h00, 1'h0, 5'h0);
			    	end
			    	else begin
			            supported_commands_test_send_command_and_write_data({24'h000000, 8'h40}, 5'h00, 1'h0, 5'h0);
			    	end   
				end
				else if (rd_cmd_lane_width_input == 2'b10 & rd_data_lane_width_input == 2'b10 & rd_addr_lane_width_input == 2'b10) begin // Address and Data to be sent on 4 IO lanes	
                    // Exit Quad I/O
					supported_flash_command_opcode_only(1'h0, 5'h1E, 5'h0);     
				end
			end
			if (flash_device == 2'b01) begin
			    if (rd_addr_lane_width_input == 2'b10 | rd_data_lane_width_input == 2'b10) begin // Addr/Data to be send on 4 IO lanes	
			        // Set Quad Enable bit on Status Register 2
			        // Change opcode of WRSR on Flash Command Code 5 0x0000_0020 since there is no supported command for WRSR-2
			        // Data {WREN, WRDIS, WRSR, PP}
			        set_flash_command_code(32'h00000020, {8'h06, 8'h04, 8'h31, 8'h02});
			        if (DATA_ENDIANNESS == 1) begin // Big Endian
			            // Write 1 to Quad Enable Bit
			            supported_commands_test_send_command_and_write_data({8'h02, 24'h000000}, 5'h01, 1'h1, 5'h1);
			        end
			        else begin
			    	    // Write 1 to Quad Enable Bit
			            supported_commands_test_send_command_and_write_data({24'h000000, 8'h02}, 5'h01, 1'h1, 5'h1);
			        end	
			    end	
			
			    // Flash Byte Address Mode 
			    if (rd_flash_addr_width_input == 3'b011) begin //4-bytes address
	    	        // ENTER_4_BYTE_ADDRESS_MODE
	    	        //supported_flash_command_opcode_only(5'h1C);
			        // Update the command opcodes to 4-byte operation opcodes
			        command_code_update(1);
			    end
		        else begin // just to add some random test
	    	        // ENTER_4_BYTE_ADDRESS_MODE
	    	        supported_flash_command_opcode_only(1'h1, 5'h1C, 5'h1);
	    	        // EXIT_4_BYTE_ADDRESS_MODE
	    	        supported_flash_command_opcode_only(1'h1, 5'h1D, 5'h1);
			        command_code_update(0);
			    end
			end
			
			// Flash Byte Address Mode 
			if (rd_flash_addr_width_input == 3'b011) begin //4-bytes address
				addr_shift = 32'h0;
			end
		    else begin // just to add some random test
				addr_shift = 32'h8;
			end
				
			// Start of Read Operation
			for (loop_read_cntr = 32'h00000000; loop_read_cntr < loop_read; loop_read_cntr = loop_read_cntr+1) begin
	    	// Calculate starting flash address for the Loop
			    if (DATA_ENDIANNESS == 1 ) begin //Big Endian
				    loop_flash_addr    = flash_addr_input_val + ((rd_xfer_len_bytes_for_loop*(loop_read_cntr+loop_write_read_cntr)<<addr_shift));
			    end
			    else begin // Little Endian
				    addr_inc_val       = (rd_xfer_len_bytes_for_loop*(loop_read_cntr+loop_write_read_cntr));
					if (rd_flash_addr_width_input == 3'b011) begin
					    addr_inc_val_shift = {addr_inc_val[7:0], addr_inc_val[15:8], addr_inc_val[23:16],addr_inc_val[31:24]};
				        loop_flash_addr    = flash_addr_input_val + addr_inc_val_shift;
					end
					else begin
					    addr_inc_val_shift = {addr_inc_val[7:0], addr_inc_val[15:8], addr_inc_val[23:16],8'h0};
				        loop_flash_addr    = flash_addr_input_val + addr_inc_val_shift;
					end
			    end
		        // Write 0 to Start transaction Register
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000000;
		        #100; write_to_intf(addr_32b, wr_data_32b);
			    
			    $display("# ---INFO : @%0dns :: Setting registers to execute page read operation.", $time);
		        xfer_len_bytes        = rd_xfer_len_bytes_for_loop;
		        multiple_flash_target = multiple_flash_target_input;
		        flash_cmd_code        = read_flash_cmd_code_input;
		        num_wait_state        = num_wait_state_input;
		        with_payload          = 1'h0; 
		        sup_flash_cmd         = 1'h1; 
		        addr_32b = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_0_REG_ADDR;
		        packet_header_0_wr_data = {xfer_len_bytes, num_wait_state, multiple_flash_target, flash_cmd_code, with_payload, sup_flash_cmd};
		        wr_data_32b = packet_header_0_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_1
		        flash_addr_width        = rd_flash_addr_width_input;
		        tgt_cs                  = tgt_cs_input; 
		        data_lane_width         = rd_data_lane_width_input;
		        addr_lane_width         = rd_addr_lane_width_input;
		        cmd_lane_width          = rd_cmd_lane_width_input;
		        packet_header_1_wr_data = {16'h0, flash_addr_width, tgt_cs, 2'h0, data_lane_width, addr_lane_width, cmd_lane_width};
		        addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_1_REG_ADDR;
			    wr_data_32b = packet_header_1_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_2 and pkt_header_3
		        addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_2_REG_ADDR;
		        wr_data_32b = loop_flash_addr;
		        #100; write_to_intf(addr_32b, wr_data_32b);
			    if (ENABLE_TRANSMIT_FIFO == 0) begin
		           addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_3_REG_ADDR;
		           wr_data_32b = 32'h0;
		           #100; write_to_intf(addr_32b, wr_data_32b);
			    end
			    // Write to Interrupt Status Register
		        addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		        wr_data_32b = 32'hFFFFFFFF;
		        #100; write_to_intf(addr_32b, wr_data_32b);
			    // Enable Interrupt Status Register
		        addr_32b    = INTERRUPT_ENABLE_REG_ADDR;
		        wr_data_32b = 32'h00000030;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Start transaction
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000001;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Read TRANSACTION_STATUS
		        #100; read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
			    $display("# ---INFO : @%0dns :: Polling transaction status register.", $time);
			    if (rd_data_32b[0] == 1) begin
			        $display("# ---INFO : @%0dns :: Page read started.", $time);
			    end
			    else begin
			        $display("# ---INFO : @%0dns :: Page read not yet started.", $time);
			    end
                if (ENABLE_RECEIVE_FIFO == 0) begin			
			        num_of_bytes = 0;
			        while (num_of_bytes < xfer_len_bytes-1) begin
			            read_from_intf(INTERRUPT_STATUS_REG_ADDR, rd_data_32b);
			        	if (rd_data_32b[4] == 1) begin
		                    //Read from pkt_data_0
			        		addr_32b = ENABLE_RECEIVE_FIFO ? RX_FIFO_MAPPING_REG_ADDR : PACKET_DATA_0_REG_ADDR;
			                read_from_intf(addr_32b, rd_data_32b);
			                flash_rd_data_32b[(num_of_bytes>>2)+((rd_xfer_len_bytes_for_loop>>2)*loop_read_cntr)][31:0] = rd_data_32b;
                            do_data_compare(flash_wr_data_32b[(num_of_bytes>>2)+((rd_xfer_len_bytes_for_loop>>2)*loop_read_cntr)],flash_rd_data_32b[(num_of_bytes>>2)+((rd_xfer_len_bytes_for_loop>>2)*loop_read_cntr)]);
		                    //#100;
			                // Write to Interrupt Status Register
		                    addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		                    wr_data_32b = 32'h00000010;
		                    //#100; 
			        		write_to_intf(addr_32b, wr_data_32b);
			                read_from_intf(INTERRUPT_STATUS_REG_ADDR, rd_data_32b);
			        		num_of_bytes = num_of_bytes + 4;
			        	end
			        	else begin
		                    #100;
			        	end
			        end
		            read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);	
			        $display("# ---INFO : @%0dns :: Polling transaction status register.", $time);		
		            while (rd_data_32b[0] == 1) begin
		                read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
		                #100;
			            if (rd_data_32b[0] == 1) begin
			                $display("# ---INFO : @%0dns :: Page read still on-going.", $time);
			            end
			            else begin
			                $display("# ---INFO : @%0dns :: Page read done.", $time);
			            end	
		            end
			    end
			    else begin
		            while (rd_data_32b[0] == 1) begin
		                read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
		                #100;
		            end
			    	$display("# ---INFO : @%0dns :: Page read done.", $time);
			    	num_of_bytes = 0;
			        //for(m_i_i = 0; m_i_i < ((xfer_len_bytes)>>2); m_i_i = m_i_i +1) begin 
			        //    read_from_intf(RX_FIFO_MAPPING_REG_ADDR, rd_data_32b);
			        //    flash_rd_data_32b[(m_i_i)+((rd_xfer_len_bytes_for_loop>>2)*loop_read_cntr)][31:0] = rd_data_32b;
			    	//	//#100;
                    //    do_data_compare(flash_wr_data_32b[(m_i_i)+((rd_xfer_len_bytes_for_loop>>2)*loop_read_cntr)],flash_rd_data_32b[(m_i_i)+((rd_xfer_len_bytes_for_loop>>2)*loop_read_cntr)]);
			    	//end		
			        num_of_bytes = 0;
			        while (num_of_bytes < xfer_len_bytes-1) begin
		                //Read from pkt_data_0
			        	addr_32b = ENABLE_RECEIVE_FIFO ? RX_FIFO_MAPPING_REG_ADDR : PACKET_DATA_0_REG_ADDR;
			            read_from_intf(addr_32b, rd_data_32b);
			            flash_rd_data_32b[(num_of_bytes>>2)+((rd_xfer_len_bytes_for_loop>>2)*loop_read_cntr)][31:0] = rd_data_32b;
                        do_data_compare(flash_wr_data_32b[(num_of_bytes>>2)+((rd_xfer_len_bytes_for_loop>>2)*loop_read_cntr)],flash_rd_data_32b[(num_of_bytes>>2)+((rd_xfer_len_bytes_for_loop>>2)*loop_read_cntr)]);
		                num_of_bytes = num_of_bytes + 4;
			        end
			    end		
			end
			if (flash_device == 2'b00) begin
			    if (rd_cmd_lane_width_input == 2'b00 & rd_data_lane_width_input == 2'b10 & rd_addr_lane_width_input == 2'b10 ) begin // Address and Data to be sent on 4 IO lanes	
                    // For Quad Enable Bit setting on Configuration Register
			        supported_commands_test_send_command_and_write_data(32'h0, 5'h00, 1'h0, 5'h0);
				end
				else if (rd_cmd_lane_width_input == 2'b10 & rd_data_lane_width_input == 2'b10 & rd_addr_lane_width_input == 2'b10 ) begin // Address and Data to be sent on 4 IO lanes	
                    // Exit Quad I/O
					supported_flash_command_opcode_only(1'h0, 5'h1F, 5'h0);     
				end
			end
			if (flash_device == 2'b01) begin
			    supported_commands_test_send_command_and_write_data({24'h000000, 8'h00}, 5'h01, 1'h1, 5'h1);
			end
		end // end of loop_write_read
		end
	endtask
	

    task direct_write_read_access;
	    input [1:0] wr_data_lane_width_input;
		input [1:0] wr_addr_lane_width_input;
		input [1:0] wr_cmd_lane_width_input;
		input       wr_xip_addr_width_input;
		input [2:0] wr_dummy_clock_cycles_input; 
		input [2:0] flash_map_en_wr_access_cmd_input;
		    // 3'h0 Page Program
			// 3'h1 Dual Input Fast Program
			// 3'h2 Extended Dual Input Fast Program
			// 3'h3 Quad Input Fast Program
			// 3'h4 Extended Quad Input Fast Program
		
	    input [1:0] rd_data_lane_width_input;
		input [1:0] rd_addr_lane_width_input;
		input [1:0] rd_cmd_lane_width_input;
		input       rd_xip_addr_width_input;
		input [2:0] rd_dummy_clock_cycles_input;
		input [2:0] flash_map_en_rd_access_cmd_input;
		    // 3'h0 Read
			// 3'h1 Fast Read
			// 3'h2 Dual Output Fast Read
			// 3'h3 Dual Input/Output Fast Read
			// 3'h4 Quad Output Fast Read
			// 3'h5 Quad Input/Output Fast Read
		
		input [31:0] direct_flash_address;
		input [31:0] number_of_direct_write;
		input [31:0] number_of_direct_read;
		
		input en_burst_trans;
		    // 1'h0 single transaction
			// 1'h1 burst transaction
		input enable_xip_mode;
		    // 1'h0 non-XiP access
			// 1'h1 XiP access
		
		
		//QSPI_CONFIG_REG_0_REG_ADDR
		reg [31:0] qspi_config_0_wr_data;
	    reg [1:0] dat_lane_width;
		reg [1:0] addr_lane_width;
		reg [1:0] cmd_lane_width;
		reg       xip_addr_width;
		reg [2:0] dummy_clock_cycles; 
		reg [2:0] flash_map_en_rd_access_cmd;
		reg [2:0] flash_map_en_wr_access_cmd;
		reg en_frame_end_done_cntr;
        reg data_endianness;                        
        reg [4:0] sck_rate;      		
        reg cpha;                                   
        reg cpol;                                   
        reg first_bit_transfer;
		
		//QSPI_CONFIG_REG_0_REG_ADDR
        reg en_flash_address_space_map;
		reg chip_select_behaviour;                  
        reg [2:0] min_idle_time;  
        reg en_back_to_back_trans;
		
		//QSPI_CONFIG_REG_1_REG_ADDR
		reg [31:0] qspi_config_1_wr_data;
		reg [15:0] trgt_rd_trans_cnt;
		reg [15:0] trgt_wr_trans_cnt;
		
		//PACKET_HEADER_0
		reg [31:0] packet_header_0_wr_data;
		reg [15:0] xfer_len_bytes; 
		reg [7:0] num_wait_state;  
		reg multiple_flash_target; 
		reg [4:0] flash_cmd_code;  
		reg with_payload;          
		reg sup_flash_cmd;  

		//PACKET_HEADER_1
		reg [31:0] packet_header_1_wr_data;
        reg [2:0] flash_addr_width;
        reg [4:0] tgt_cs;          
        reg [1:0] data_lane_width; 
		
		//PACKET_HEADER_0 - Unsupported Commands
		reg [2:0]  num_wait_sck;
		reg        multiple_target;
		reg        frm_end;
		reg        frm_start;
		reg        data_rate;
		reg [1:0]  lane_width;
		reg        cmd_type;
		
		//PACKET DATA 0 - Unsupported Commands
		reg [7:0]  flash_cmd_opcode;
		reg [23:0] flash_address;
		
		
	    reg [15:0] wr_xfer_len_bytes;
		reg [4:0] flash_cmd_code_input; 
		reg [2:0] flash_addr_width_input;
		reg [1:0] data_lane_width_input;
		reg [1:0] addr_lane_width_input;
	    reg [1:0] cmd_lane_width_input; 
		reg [31:0] flash_addr_input;
		
        reg [31:0] addr_32b;
        reg [31:0] flash_addr_32b;
		reg [31:0] flash_wr_data_32b [262143:0];
        reg [31:0] flash_rd_data_32b [262143:0];
        reg [31:0] pkt_hdr_addr_32b;
        reg [31:0] wr_data_32b;
		reg [31:0] rd_data_32b;
		reg [31:0] num_of_bytes;
		reg [31:0] limit_num_of_bytes;
		reg [31:0] loop_write_cntr;
		reg [31:0] loop_read_cntr;
		reg [3:0]  addr_shift;
		reg [2:0]  erase_flash_addr_width;
		reg [31:0] direct_flash_address_val;
		reg [31:0] start_trans_wr_data_32b;
		integer m_i_i;
		integer m_j_i;
		
		begin
            #12000; // wait for a_reset_n_i assertion
			#1000;
			
			if (enable_xip_mode) begin
			    start_trans_wr_data_32b = 32'h00000002;
			end
			else begin
			    start_trans_wr_data_32b = 32'h00000000;
			end
			
		    // Write 0 to Start transaction Register
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000000;
		        #100; write_to_intf(addr_32b, wr_data_32b);
			
            // For 1 SPI Target Only			
		    // Test Setting Flash Address Mapping attribute through register
		        //addr_32b    = MIN_FLASH_ADDRESS_ALIGN_REG_ADDR;
		        //wr_data_32b = 32'hFFFFE000;  //8KB - 32'h2000
		        //#100; write_to_intf(addr_32b, wr_data_32b);
		        //addr_32b    = STARTING_FLASH_ADDRESS_REG_ADDR;
		        //wr_data_32b = 32'h00000100; 
		        //#100; write_to_intf(addr_32b, wr_data_32b);
		        //addr_32b    = FLASH_MEMORY_MAP_SIZE_REG_ADDR;
		        //wr_data_32b = 32'hFFFFE000; 
		        //#100; write_to_intf(addr_32b, wr_data_32b);
		        //addr_32b    = AXI_ADDRESS_MAP_REG_ADDR;
		        //wr_data_32b = 32'hFFFFFFFF; 
		        //#100; write_to_intf(addr_32b, wr_data_32b);
			
            // For 2 SPI Target 			
		    // Test Setting Flash Address Mapping attribute through register
		        //addr_32b    = MIN_FLASH_ADDRESS_ALIGN_REG_ADDR;
		        //wr_data_32b = 32'hFFFFC000;  //8KB - 32'h1000
		        //#100; write_to_intf(addr_32b, wr_data_32b);
		        //addr_32b    = STARTING_FLASH_ADDRESS_REG_ADDR;
		        //wr_data_32b = 32'h00001000;  // second 4KB sector
		        //#100; write_to_intf(addr_32b, wr_data_32b);
		        //addr_32b    = FLASH_MEMORY_MAP_SIZE_REG_ADDR; //16KB
		        //wr_data_32b = 32'hFFFF8000; 
		        //#100; write_to_intf(addr_32b, wr_data_32b);
		        //addr_32b    = AXI_ADDRESS_MAP_REG_ADDR;
		        //wr_data_32b = 32'hFFFFFFFF; 
		        //#100; write_to_intf(addr_32b, wr_data_32b);
				
			    if (flash_device == 2'b01) begin // Winbond 4-byte address test
			        if (wr_xip_addr_width_input == 1'b1 & rd_xip_addr_width_input == 1'b1) begin //4-bytes address
				        erase_flash_addr_width = 3'b011;
			            command_code_update(1);
				        erase_using_supported_commands(1'h1,                   // multiple_flash_target
				                                       5'h10,                  // flash_cmd_code
				        							   erase_flash_addr_width, // flash_addr_width
				        							   2'h0,                   // data_lane_width
				        							   2'h0,                   // addr_lane_width
				                                       2'h0,                   // cmd_lane_width
				        							   32'h00000000,           // flash_address 
													   //32'h00002000,               // flash_address - for register test , big endian, 2 SPI Target
				    							       5'h1);                  // SPI target 
			        end
			    end	
				else begin // Macronix 3-byte address test
				    erase_flash_addr_width = 3'b010;
				    erase_using_supported_commands(1'h0,                       // multiple_flash_target
				                                   5'h10,                      // flash_cmd_code
				    							   erase_flash_addr_width,     // flash_addr_width
				    							   2'h0,                       // data_lane_width
				    							   2'h0,                       // addr_lane_width
				                                   2'h0,                       // cmd_lane_width
				    							   32'h00000000,             // flash_address 
				    							   //32'h00020000,               // flash_address - for register test , big endian, 1 SPI Target
				    							   5'h0);                      // SPI target 
				end
											   
		    // Write 0 to Start transaction Register
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000000;
		        #100; write_to_intf(addr_32b, wr_data_32b);
				
		        if (flash_device == 2'b00) begin
			        if (wr_cmd_lane_width_input == 2'b00 & wr_addr_lane_width_input == 2'b10 & wr_data_lane_width_input == 2'b10 ) begin // Address and Data to be sent on 4 IO lanes	
                        // For Quad Enable Bit setting on Configuration Register
			            if (DATA_ENDIANNESS == 1) begin // Big Endian
			                supported_commands_test_send_command_and_write_data({8'h40, 24'h000000}, 5'h00, 1'h0, 5'h0);
			        	end
			        	else begin
			                supported_commands_test_send_command_and_write_data({24'h000000, 8'h40}, 5'h00, 1'h0, 5'h0);
			        	end   
			    	end
			    	else if (wr_cmd_lane_width_input == 2'b10 & wr_addr_lane_width_input == 2'b10 & wr_data_lane_width_input == 2'b10 ) begin // Address and Data to be sent on 4 IO lanes	
                        // Enter Quad I/O
			    		supported_flash_command_opcode_only(1'h0, 5'h1E, 5'h0);     
			    	end
			    end
			    
			    if (flash_device == 2'b01) begin
			        // Settings for Page Program		
			        if (wr_data_lane_width_input == 2'b10) begin // Data to be send on 4 IO lanes	
			            // Set Quad Enable bit on Status Register 2
			            // Change opcode of WRSR on Flash Command Code 5 0x0000_0020 since there is no supported command for WRSR-2
			            // Data {WREN, WRDIS, WRSR, PP}
			        	$display("# ---INFO : @%0dns :: Change WRSR command opcode.", $time);
			            set_flash_command_code(32'h00000020, {8'h06, 8'h04, 8'h31, 8'h02});
			            if (DATA_ENDIANNESS == 1) begin // Big Endian
			                // Write 1 to Quad Enable Bit
			                supported_commands_test_send_command_and_write_data({8'h02, 24'h000000}, 5'h01, 1'h1, 5'h1);
			            end
			            else begin
			        	    // Write 1 to Quad Enable Bit
			                supported_commands_test_send_command_and_write_data({24'h000000, 8'h02}, 5'h01, 1'h1, 5'h1);
			            end	
			        end
			    
			        // Flash Byte Address Mode 
			        if (wr_xip_addr_width_input == 1'b1) begin //4-bytes address
	    	            // ENTER_4_BYTE_ADDRESS_MODE
	    	            //supported_flash_command_opcode_only(5'h1C);
			            // Update the command opcodes to 4-byte operation opcodes
			        	command_code_update(1);
			        end
		            else begin // just to add some random test
	    	            // ENTER_4_BYTE_ADDRESS_MODE
	    	            supported_flash_command_opcode_only(1'h1, 5'h1C, 5'h1);
	    	            // EXIT_4_BYTE_ADDRESS_MODE
	    	            supported_flash_command_opcode_only(1'h1, 5'h1D, 5'h1);
			        	command_code_update(0);
			        end	
			    end	
											   
            // Direct Write Access
		    // Write 0 to Start transaction Register
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000000;
		        #100; write_to_intf(addr_32b, wr_data_32b);
				
		    // Write to config0 - Configuration Register
			    dat_lane_width             = wr_data_lane_width_input;  
			    addr_lane_width            = wr_addr_lane_width_input;
			    cmd_lane_width             = wr_cmd_lane_width_input;
			    xip_addr_width             = wr_xip_addr_width_input;
			    dummy_clock_cycles         = wr_dummy_clock_cycles_input; 
			    flash_map_en_rd_access_cmd = 3'h0;
			    flash_map_en_wr_access_cmd = flash_map_en_wr_access_cmd_input;
		        en_frame_end_done_cntr     = 1'h0;
                data_endianness            = (DATA_ENDIANNESS == 1) ? 1'b1 : 1'b0;                        
                sck_rate                   = SPI_CLOCK_FREQUENCY_DIVIDER/2;	
                cpha                       = SPI_CLOCK_PHASE;                                   
                cpol                       = SPI_CLOCK_POLARITY;                                   
                first_bit_transfer         = FIRST_TRANSMITTED_BIT;
				addr_32b                   = QSPI_CONFIG_REG_0_REG_ADDR;
				qspi_config_0_wr_data      = {dat_lane_width, addr_lane_width, cmd_lane_width, xip_addr_width,
				                              dummy_clock_cycles, flash_map_en_rd_access_cmd, flash_map_en_wr_access_cmd,
											  en_frame_end_done_cntr, 1'h0, data_endianness, sck_rate, 5'h0, 
				                              cpha, cpol, first_bit_transfer};
				wr_data_32b                = qspi_config_0_wr_data;
		        write_to_intf(addr_32b, wr_data_32b);
				
				if (en_burst_trans == 1'h0) begin // Single Transaction
				    for (loop_write_cntr = 32'h00000000; loop_write_cntr < number_of_direct_write; loop_write_cntr = loop_write_cntr+1) begin
				        //direct_flash_address_val = 32'hFFFFE100;                      // for register test only, 1 SPI Target
						//addr_32b    = direct_flash_address_val + (4*loop_write_cntr); // for register test only, 1 SPI Target
				        //direct_flash_address_val = 32'hFFFF9000;                        // for register test only, 2 SPI Target
						//addr_32b    = direct_flash_address_val + (4*loop_write_cntr);   // for register test only, 2 SPI Target
				        addr_32b    = direct_flash_address + (4*loop_write_cntr);
				        wr_data_32b = $random;
				    	flash_wr_data_32b[loop_write_cntr] = wr_data_32b;
				        $display("---INFO : @%0dns :: Write Data 0x%x", $time, wr_data_32b);
				    	direct_write_to_intf(addr_32b, wr_data_32b);
						/*
		                //Write 0 to Start transaction Register
		                addr_32b    = START_TRANSACTION_REG_ADDR;
		                wr_data_32b = 32'h00000001;
		                #100; write_to_intf(addr_32b, wr_data_32b);
		                //Write 0 to Start transaction Register
		                addr_32b    = START_TRANSACTION_REG_ADDR;
		                wr_data_32b = 32'h00000000;
		                #100; write_to_intf(addr_32b, wr_data_32b);
						*/
						//supported_commands_test_send_command();
						//#1000; 
                    end
				end
				else begin // Burst Transaction
					wr_data_32b = $random;
				    addr_32b    = direct_flash_address;
					burst_write_ahb(addr_32b, wr_data_32b, 2, number_of_direct_write);
		            // Write 0 to Start transaction Register
		            //addr_32b    = START_TRANSACTION_REG_ADDR;
		            //wr_data_32b = 32'h00000000;
		            //#100; write_to_intf(addr_32b, wr_data_32b);	
                    #1200000; // added delay before issuing burst read
				end
				
				//if (INTERFACE == 0) begin
				//    // Wait for Direct Write Access to finish
                //    while (ahbl_hready_o != 1'h1) begin
                //        #100;
			    //    end	
			    //    #1000;
				//end
				//else begin
				    // Poll transaction status register 
					// Added some clock delays before polling transaction status register on AXI4L 
					// since it will take some time for the controller to determine that its a direct access and the transaction will be started.
					@(posedge a_clk_i);
					@(posedge a_clk_i);
					@(posedge a_clk_i);
					@(posedge a_clk_i);
					@(posedge a_clk_i);
					@(posedge a_clk_i);
					@(posedge a_clk_i);
					@(posedge a_clk_i);
					@(posedge a_clk_i);
					@(posedge a_clk_i);
		            read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
			        $display("# ---INFO : @%0dns :: Polling transaction status register.", $time);	
                    if (rd_data_32b[0] == 1) $display("# ---INFO : @%0dns :: Flash transaction is still on-going.", $time);				
		            while (rd_data_32b[0] == 1) begin
		                read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
		                #100;
		            end
				    $display("# ---INFO : @%0dns :: Flash transaction done.", $time);	
				//end
			/*
			// Start of Page Program
		        // Write 0 to Start transaction Register
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000000;
		        #100; write_to_intf(addr_32b, wr_data_32b);	
			    loop_write_cntr = 32'h0;
			    $display("# ---INFO : @%0dns :: Setting registers to execute page program operation.", $time);
		        // Write to pkt_header_0 - supported flash command
		        xfer_len_bytes          = 32'h100;
		        num_wait_state          = 8'h0;  
		        multiple_flash_target   = 1'h0;
		        flash_cmd_code          = 5'h17;
		        with_payload            = 1'h1; 
		        sup_flash_cmd           = 1'h1; 
                addr_32b                = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_0_REG_ADDR;
		        packet_header_0_wr_data = {xfer_len_bytes, num_wait_state, multiple_flash_target, flash_cmd_code, with_payload, sup_flash_cmd};
		        wr_data_32b             = packet_header_0_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_1
		        flash_addr_width        = 3'h02;
		        tgt_cs                  = 1'h0;  
		        data_lane_width         = 2'h0;
		        addr_lane_width         = 2'h0;
		        cmd_lane_width          = 2'h0; 
		        packet_header_1_wr_data = {16'h0, flash_addr_width, tgt_cs, 2'h0, data_lane_width, addr_lane_width, cmd_lane_width};
		        addr_32b                = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_1_REG_ADDR;
			    wr_data_32b             = packet_header_1_wr_data;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_header_2 and pkt_header_3
			    addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_2_REG_ADDR;
		        wr_data_32b = 32'h00000000;
		        #100; write_to_intf(addr_32b, wr_data_32b);
			    if (ENABLE_TRANSMIT_FIFO == 0) begin
			        addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_HEADER_3_REG_ADDR;
		            wr_data_32b = 32'h0;
		            #100; write_to_intf(addr_32b, wr_data_32b);
			    end
			    // Write to Interrupt Status Register
		        addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		        wr_data_32b = 32'hFFFFFFFF;
		        #100; write_to_intf(addr_32b, wr_data_32b);
			    // Enable Interrupt Status Register
		        addr_32b    = INTERRUPT_ENABLE_REG_ADDR;
		        wr_data_32b = 32'h00000003;
		        #100; write_to_intf(addr_32b, wr_data_32b);
		        // Write to pkt_data_0
		        addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_DATA_0_REG_ADDR;
		        wr_data_32b = $random;
			    flash_wr_data_32b[0+(64*loop_write_cntr)][31:0] = wr_data_32b;
		        #100; write_to_intf(addr_32b, wr_data_32b);
			    $display("---INFO : @%0dns :: Write Data 0x%x", $time, wr_data_32b);
                // Write to pkt_data_1
		        addr_32b    = ENABLE_TRANSMIT_FIFO ? TX_FIFO_MAPPING_REG_ADDR : PACKET_DATA_1_REG_ADDR;
		        wr_data_32b = $random;
			    flash_wr_data_32b[1+(64*loop_write_cntr)][31:0] = wr_data_32b;
		        #100; write_to_intf(addr_32b, wr_data_32b);
			    $display("---INFO : @%0dns :: Write Data 0x%x", $time, wr_data_32b);
			    if (ENABLE_TRANSMIT_FIFO == 0) begin
			        // Start transaction
		            addr_32b    = START_TRANSACTION_REG_ADDR;
		            wr_data_32b = 32'h00000001;
		            #100; write_to_intf(addr_32b, wr_data_32b);
		            // Read TRANSACTION_STATUS
		            #100; read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
			        $display("# ---INFO : @%0dns :: Polling transaction status register.", $time);
			        if (rd_data_32b[0] == 1) begin
			            $display("# ---INFO : @%0dns :: Page program started.", $time);
			        end
			        else begin
			            $display("# ---INFO : @%0dns :: Page program not yet started.", $time);
			        end
			        num_of_bytes = 8;
			        limit_num_of_bytes = xfer_len_bytes-1;
			        while (num_of_bytes < limit_num_of_bytes) begin // write remaining bytes of data
			            read_from_intf(INTERRUPT_STATUS_REG_ADDR, rd_data_32b);
			        	if (rd_data_32b[0] == 1) begin
			                // Write to Interrupt Status Register
		                    addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		                    wr_data_32b = 32'h00000001;
		                    #100; write_to_intf(addr_32b, wr_data_32b);
		                    // Write to pkt_data_0
		                    addr_32b    = PACKET_DATA_0_REG_ADDR;
		                    wr_data_32b = $random;
			                flash_wr_data_32b[(num_of_bytes>>2)+(64*loop_write_cntr)][31:0] = wr_data_32b;
		                    #100; write_to_intf(addr_32b, wr_data_32b);
			                $display("---INFO : @%0dns :: Write Data 0x%x", $time, wr_data_32b);
			        		num_of_bytes = num_of_bytes + 4;
			        	end
			        	else begin
		                    #50;
			        	end
			            read_from_intf(INTERRUPT_STATUS_REG_ADDR, rd_data_32b);
			        	if (rd_data_32b[1] == 1) begin
			                // Write to Interrupt Status Register
		                    addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		                    wr_data_32b = 32'h00000002;
		                    #100; write_to_intf(addr_32b, wr_data_32b);
		                    // Write to pkt_data_0
		                    addr_32b    = PACKET_DATA_1_REG_ADDR;
		                    wr_data_32b = $random;
			                flash_wr_data_32b[(num_of_bytes>>2)+(64*loop_write_cntr)][31:0] = wr_data_32b;
		                    #100; write_to_intf(addr_32b, wr_data_32b);
			                $display("---INFO : @%0dns :: Write Data 0x%x", $time, wr_data_32b);
			        		num_of_bytes = num_of_bytes + 4;
			        	end
			        	else begin
		                    #50;
			        	end
			        end
			    	read_from_intf(INTERRUPT_STATUS_REG_ADDR, rd_data_32b);
			    	while (rd_data_32b[1:0] != 2'b11) begin
		                read_from_intf(INTERRUPT_STATUS_REG_ADDR, rd_data_32b);
		                #100;
		            end
			        // Write to Interrupt Status Register
		            addr_32b    = INTERRUPT_STATUS_REG_ADDR;
		            wr_data_32b = 32'hFFFFFFFF;
		            #100; write_to_intf(addr_32b, wr_data_32b);
		            read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
			        $display("# ---INFO : @%0dns :: Polling transaction status register.", $time);	
                    if (rd_data_32b[0] == 1) $display("# ---INFO : @%0dns :: Page program is still on-going.", $time);				
		            while (rd_data_32b[0] == 1) begin
		                read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
		                #100;
		            end
			        $display("# ---INFO : @%0dns :: Page program done.", $time);
			    end
			*/	
			// Write 0 to Start transaction Register
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h0;
		        #100; write_to_intf(addr_32b, wr_data_32b);
				
		        if (flash_device == 2'b00) begin
			        if (wr_cmd_lane_width_input == 2'b00 & wr_addr_lane_width_input == 2'b10 & wr_data_lane_width_input == 2'b10 ) begin // Address and Data to be sent on 4 IO lanes	
                        supported_commands_test_send_command_and_write_data(32'h0, 5'h00, 1'h0, 5'h0);
			    	end
			    	else if (wr_cmd_lane_width_input == 2'b10 & wr_addr_lane_width_input == 2'b10 & wr_data_lane_width_input == 2'b10 ) begin // Address and Data to be sent on 4 IO lanes	
                        // Exit Quad I/O
			    		supported_flash_command_opcode_only(1'h0, 5'h1F, 5'h0);     
			    	end
			    end
			    
			    if (flash_device == 2'b01) begin
			        // Settings for Page Program		
			        if (wr_data_lane_width_input == 2'b10) begin // Data to be send on 4 IO lanes	
						supported_commands_test_send_command_and_write_data(32'h0, 5'h01, 1'h1, 5'h1);
			        end
					
			        // Flash Byte Address Mode 
			        if (wr_xip_addr_width_input == 1'b1) begin //4-bytes address
			            // Re-update the command opcodes to 3-byte operation opcodes
			        	command_code_update(0);
			        end
			    end	
			
		    // Write 0 to Start transaction Register
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000000;
		        #100; write_to_intf(addr_32b, wr_data_32b);
			
			// For Direct Read Access	
			    //#10000;
			    if (flash_device == 2'b00) begin
			        if ((rd_cmd_lane_width_input == 2'b00 & rd_addr_lane_width_input == 2'b10 & rd_data_lane_width_input == 2'b10) |  // Address and Data to be sent on 4 IO lanes	
			    	    (rd_cmd_lane_width_input == 2'b00 & rd_addr_lane_width_input == 2'b00 & rd_data_lane_width_input == 2'b10) ) begin  // Data to be sent on 4 IO lanes	
                        // For Quad Enable Bit setting on Configuration Register
			            if (DATA_ENDIANNESS == 1) begin // Big Endian
			                supported_commands_test_send_command_and_write_data({8'h40, 24'h000000}, 5'h00, 1'h0, 5'h0);
			        	end
			        	else begin
			                supported_commands_test_send_command_and_write_data({24'h000000, 8'h40}, 5'h00, 1'h0, 5'h0);
			        	end   
			    	end
			    	else if (rd_cmd_lane_width_input == 2'b10 & rd_data_lane_width_input == 2'b10 & rd_addr_lane_width_input == 2'b10) begin // Address and Data to be sent on 4 IO lanes	
                        // Enter Quad I/O
			    		supported_flash_command_opcode_only(1'h0, 5'h1E, 5'h0);     
			    	end
			    end
				
			    if (flash_device == 2'b01) begin
			        if (rd_addr_lane_width_input == 2'b10 | rd_data_lane_width_input == 2'b10) begin // Addr/Data to be send on 4 IO lanes	
			            // Set Quad Enable bit on Status Register 2
			            // Change opcode of WRSR on Flash Command Code 5 0x0000_0020 since there is no supported command for WRSR-2
			            // Data {WREN, WRDIS, WRSR, PP}
			            set_flash_command_code(32'h00000020, {8'h06, 8'h04, 8'h31, 8'h02});
			            if (DATA_ENDIANNESS == 1) begin // Big Endian
			                // Write 1 to Quad Enable Bit
			                supported_commands_test_send_command_and_write_data({8'h02, 24'h000000}, 5'h01, 1'h1, 5'h1);
			            end
			            else begin
			        	    // Write 1 to Quad Enable Bit
			                supported_commands_test_send_command_and_write_data({24'h000000, 8'h02}, 5'h01, 1'h1, 5'h1);
			            end	
			        end	
			    
			        // Flash Byte Address Mode 
			        if (rd_xip_addr_width_input == 1'b1) begin //4-bytes address
	    	            // ENTER_4_BYTE_ADDRESS_MODE
	    	            //supported_flash_command_opcode_only(5'h1C);
			            // Update the command opcodes to 4-byte operation opcodes
			            command_code_update(1);
			        end
		            else begin // just to add some random test
	    	            // ENTER_4_BYTE_ADDRESS_MODE
	    	            supported_flash_command_opcode_only(1'h1, 5'h1C, 5'h1);
	    	            // EXIT_4_BYTE_ADDRESS_MODE
	    	            supported_flash_command_opcode_only(1'h1, 5'h1D, 5'h1);
			            command_code_update(0);
			        end
			    end	
			
		    // Direct Read Access
                //while (ahbl_hready_o != 1'h1) begin
                //    #100;
			    //end	
			    //#1000;
				// Poll transaction status register 
				// Added some clock delays before polling transaction status register on AXI4L 
				// since it will take some time for the controller to determine that its a direct access and the transaction will be started.
				@(posedge a_clk_i);
				@(posedge a_clk_i);
				@(posedge a_clk_i);
				@(posedge a_clk_i);
				@(posedge a_clk_i);
				@(posedge a_clk_i);
				@(posedge a_clk_i);
				@(posedge a_clk_i);
				@(posedge a_clk_i);
				@(posedge a_clk_i);
		        read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
			    $display("# ---INFO : @%0dns :: Polling transaction status register.", $time);	
                if (rd_data_32b[0] == 1) $display("# ---INFO : @%0dns :: Flash transaction is still on-going.", $time);				
		        while (rd_data_32b[0] == 1) begin
		            read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
		            #100;
		        end
				$display("# ---INFO : @%0dns :: Flash transaction done.", $time);	
			// Enable XiP Mode of Macronix flash
			    //if (enable_xip_mode) begin
			    //    if (flash_device == 2'b00) begin
				//        
				//    end
				//end
				
		    // Write to config0 - Configuration Register
			    dat_lane_width             = rd_data_lane_width_input;  
			    addr_lane_width            = rd_addr_lane_width_input;
			    cmd_lane_width             = rd_cmd_lane_width_input;
			    xip_addr_width             = rd_xip_addr_width_input;
			    dummy_clock_cycles         = rd_dummy_clock_cycles_input; 
			    flash_map_en_rd_access_cmd = flash_map_en_rd_access_cmd_input;
			    flash_map_en_wr_access_cmd = 3'h0;
		        en_frame_end_done_cntr     = 1'h0;
                data_endianness            = (DATA_ENDIANNESS == 1) ? 1'b1 : 1'b0;                        
                sck_rate                   = SPI_CLOCK_FREQUENCY_DIVIDER/2;	
                cpha                       = SPI_CLOCK_PHASE;                                   
                cpol                       = SPI_CLOCK_POLARITY;                                   
                first_bit_transfer         = FIRST_TRANSMITTED_BIT;
				addr_32b                   = QSPI_CONFIG_REG_0_REG_ADDR;
				qspi_config_0_wr_data      = {dat_lane_width, addr_lane_width, cmd_lane_width, xip_addr_width,
				                              dummy_clock_cycles, flash_map_en_rd_access_cmd, flash_map_en_wr_access_cmd,
											  en_frame_end_done_cntr, 1'h0, data_endianness, sck_rate, 5'h0, 
				                              cpha, cpol, first_bit_transfer};
				wr_data_32b                = qspi_config_0_wr_data;
		        write_to_intf(addr_32b, wr_data_32b);
				#100;
				
			// Write 0 to Start transaction Register
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = start_trans_wr_data_32b;
		        #100; write_to_intf(addr_32b, wr_data_32b);
				
				if (en_burst_trans == 1'h0) begin // Single Transaction
				    for (loop_read_cntr = 32'h00000000; loop_read_cntr < number_of_direct_read; loop_read_cntr = loop_read_cntr+1) begin
				        //direct_flash_address_val = 32'hFFFFE100;                      // for register test only, 1 SPI Target
						//addr_32b    = direct_flash_address_val + (4*loop_read_cntr);  // for register test only, 1 SPI Target
				        //direct_flash_address_val = 32'hFFFF9000;                      // for register test only, 2 SPI Target
						//addr_32b    = direct_flash_address_val + (4*loop_read_cntr);  // for register test only, 2 SPI Target
				        addr_32b    = direct_flash_address + (4*loop_read_cntr);
				    	direct_read_from_intf(addr_32b, rd_data_32b);
				    	flash_rd_data_32b[loop_read_cntr] = rd_data_32b;
                        do_data_compare(flash_wr_data_32b[loop_read_cntr],flash_rd_data_32b[loop_read_cntr]);
		                // Write 0 to Start transaction Register
		                //addr_32b    = START_TRANSACTION_REG_ADDR;
		                //wr_data_32b = start_trans_wr_data_32b;
		                //#100; write_to_intf(addr_32b, wr_data_32b);	
                    end
				end
				else begin // Burst Transaction
				    addr_32b    = direct_flash_address;
					if (INTERFACE == 0) begin
				        burst_read_ahb(addr_32b, 2, number_of_direct_read);
					    #12000;
					end
					else begin
                        //axi_read_bulk(addr_32b,8'hFF,3'b010,2'b01); 
                        axi_read_bulk(addr_32b, (number_of_direct_read-1),3'b010,2'b01); 
					end
					//for (loop_read_cntr = 32'h00000001; loop_read_cntr < number_of_direct_read+1; loop_read_cntr = loop_read_cntr+1) begin
					for (loop_read_cntr = 32'h00000001; loop_read_cntr < number_of_direct_read; loop_read_cntr = loop_read_cntr+1) begin
                        do_data_compare(burst_prg_data_2d_32b[loop_read_cntr],burst_rd_data_2d_32b[loop_read_cntr]);
					end
				end
				
				// Poll transaction status register 
				// Added some clock delays before polling transaction status register on AXI4L 
				// since it will take some time for the controller to determine that its a direct access and the transaction will be started.
				@(posedge a_clk_i);
				@(posedge a_clk_i);
				@(posedge a_clk_i);
				@(posedge a_clk_i);
				@(posedge a_clk_i);
				@(posedge a_clk_i);
				@(posedge a_clk_i);
				@(posedge a_clk_i);
				@(posedge a_clk_i);
				@(posedge a_clk_i);
		        read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
			    $display("# ---INFO : @%0dns :: Polling transaction status register.", $time);	
                if (rd_data_32b[0] == 1) $display("# ---INFO : @%0dns :: Flash transaction is still on-going.", $time);				
		        while (rd_data_32b[0] == 1) begin
		            read_from_intf(TRANSACTION_STATUS_REG_ADDR, rd_data_32b);
		            #100;
		        end
				$display("# ---INFO : @%0dns :: Flash transaction done.", $time);
			
		    // Write 0 to Start transaction Register
		        addr_32b    = START_TRANSACTION_REG_ADDR;
		        wr_data_32b = 32'h00000000;
		        #100; write_to_intf(addr_32b, wr_data_32b);
				
			    if (flash_device == 2'b00) begin
			        if ((rd_cmd_lane_width_input == 2'b00 & rd_addr_lane_width_input == 2'b10 & rd_data_lane_width_input == 2'b10) |  // Address and Data to be sent on 4 IO lanes	
			    	    (rd_cmd_lane_width_input == 2'b00 & rd_addr_lane_width_input == 2'b00 & rd_data_lane_width_input == 2'b10) ) begin  // Data to be sent on 4 IO lanes	
                        supported_commands_test_send_command_and_write_data(32'h0, 5'h00, 1'h0, 5'h0);   
			    	end
			    	else if (rd_cmd_lane_width_input == 2'b10 & rd_data_lane_width_input == 2'b10 & rd_addr_lane_width_input == 2'b10) begin // Address and Data to be sent on 4 IO lanes	
                        // Exit Quad I/O
			    		supported_flash_command_opcode_only(1'h0, 5'h1F, 5'h0);     
			    	end
			    end
			    if (flash_device == 2'b01) begin
			        if (rd_addr_lane_width_input == 2'b10 | rd_data_lane_width_input == 2'b10) begin // Addr/Data to be send on 4 IO lanes	
                        supported_commands_test_send_command_and_write_data(32'h0, 5'h01, 1'h1, 5'h1);
			        end	
			        // Flash Byte Address Mode 
			        if (rd_xip_addr_width_input == 1'b1) begin //4-bytes address
			            // Re-update the command opcodes to 3-byte operation opcodes
			            command_code_update(0);
			        end
			    end	
				
		end
	endtask

	
	// Below tasks are for Winbond Flash
	task command_code_update;
	    input [0:0] byte_address_mode;
	    begin	
		    if (byte_address_mode == 1) begin
			    //Change opcodes on Flash Command Code 4 0x0000_001C
			    //Data {BLOCK_ERASE_TYPE1, BLOCK_ERASE_TYPE2, BLOCK_ERASE_TYPE3, CHIP_ERASE}
			    $display("# ---INFO : @%0dns :: Change flash erase command opcodes.", $time);
			    set_flash_command_code(32'h0000001C, {8'h21, 8'h52, 8'hDC, 8'hC7});
                // Change opcode on Flash Command Code 5 0x0000_0020
			    // Data {WRITE_ENABLE, WRITE_DISABLE, WRITE_STATUS_CONFIGURATION_REGISTER, PAGE_PROGRAM}
			    $display("# ---INFO : @%0dns :: Change page program command opcode.", $time);
			    set_flash_command_code(32'h00000020, {8'h06, 8'h04, 8'h31, 8'h12});
			    // Change opcode on Flash Command Code 6 0x0000_0024
			    // Data {DUAL_INPUT_FAST_PROGRAM, EXTENDED_DUAL_INPUT_FAST_PROGRAM, QUAD_INPUT_FAST_PROGRAM, EXTENDED_QUAD_INPUT_FAST_PROGRAM}
			    $display("# ---INFO : @%0dns :: Change page program command opcode.", $time);
			    set_flash_command_code(32'h00000024, {8'hA2, 8'hD2, 8'h34, 8'h38});
			    // Change opcode on Flash Command Code 2 0x0000_0014
			    // Data {READ_MANUFACTURER_AND_DEVICE_ID_DUAL_IO,
			    //       READ_MANUFACTURER_AND_DEVICE_ID_QUAD_IO,
			    //		 READ_DATA,
			    //		 FAST_READ
			    //		 }
			    $display("# ---INFO : @%0dns :: Change read command opcode.", $time);
			    set_flash_command_code(32'h00000014, {8'h92, 8'h94, 8'h13, 8'h0C});
			    // Change opcode on Flash Command Code 3 0x0000_0018
			    // Data {DUAL_OUTPUT_FAST_READ, DUAL_INPUT_OUTPUT_FAST_READ, QUAD_OUTPUT_FAST_READ, QUAD_INPUT_OUTPUT_FAST_READ}
			    set_flash_command_code(32'h00000018, {8'h3C, 8'hBC, 8'h6C, 8'hEC});
			end
			else begin
			    //Change opcodes on Flash Command Code 4 0x0000_001C
			    //Data {BLOCK_ERASE_TYPE1, BLOCK_ERASE_TYPE2, BLOCK_ERASE_TYPE3, CHIP_ERASE}
			    $display("# ---INFO : @%0dns :: Change flash erase command opcodes.", $time);
			    set_flash_command_code(32'h0000001C, {8'h20, 8'h52, 8'hD8, 8'hC7});
                // Change opcode on Flash Command Code 5 0x0000_0020
			    // Data {WRITE_ENABLE, WRITE_DISABLE, WRITE_STATUS_CONFIGURATION_REGISTER, PAGE_PROGRAM}
			    $display("# ---INFO : @%0dns :: Change page program command opcode.", $time);
			    set_flash_command_code(32'h00000020, {8'h06, 8'h04, 8'h31, 8'h02});
			    // Change opcode on Flash Command Code 6 0x0000_0024
			    // Data {DUAL_INPUT_FAST_PROGRAM, EXTENDED_DUAL_INPUT_FAST_PROGRAM, QUAD_INPUT_FAST_PROGRAM, EXTENDED_QUAD_INPUT_FAST_PROGRAM}
			    $display("# ---INFO : @%0dns :: Change page program command opcode.", $time);
			    set_flash_command_code(32'h00000024, {8'hA2, 8'hD2, 8'h32, 8'h38});
			    // Change opcode on Flash Command Code 2 0x0000_0014
			    // Data {READ_MANUFACTURER_AND_DEVICE_ID_DUAL_IO,
			    //       READ_MANUFACTURER_AND_DEVICE_ID_QUAD_IO,
			    //		 READ_DATA,
			    //		 FAST_READ
			    //		 }
			    $display("# ---INFO : @%0dns :: Change read command opcode.", $time);
			    set_flash_command_code(32'h00000014, {8'h92, 8'h94, 8'h03, 8'h0B});
			    // Change opcode on Flash Command Code 3 0x0000_0018
			    // Data {DUAL_OUTPUT_FAST_READ, DUAL_INPUT_OUTPUT_FAST_READ, QUAD_OUTPUT_FAST_READ, QUAD_INPUT_OUTPUT_FAST_READ}
			    set_flash_command_code(32'h00000018, {8'h3B, 8'hBB, 8'h6B, 8'hEb});
			end
		end
	endtask
	
	// Test for flash operations on varying command, address and data IO lanes 
	// 4KB Erase - 256-bytes Quad Input Fast Program - 256-bytes Fast Read Quad I/O
	task erase_write_read_test_supported_commands;
	    // For Erase Operation
	    input [1:0] erase_test_input;
		    // Same erase commands for Macronix and Winbond
			    // 2'b00 - Block Erase Type 1
			    // 2'b01 - Block Erase Type 2
			    // 2'b10 - Block Erase Type 3
			    // 2'b11 - Chip Erase
		input [2:0] erase_flash_addr_width_input;
		input [1:0] erase_data_lane_width_input;
		    // 2'b00 - 1 IO lane
			// 2'b01 - 2 IO lanes
			// 2'b10 - 4 IO lanes
		input [1:0] erase_addr_lane_width_input;
	    input [1:0] erase_cmd_lane_width_input;
		input [31:0] flash_addr_input;
		input [0:0] multiple_flash_target_input;
		input [4:0] tgt_cs_input;
			
		// For Page Program Operation
		input [15:0] prog_xfer_len_bytes_input;
		input [0:0]  page_prog_operation_input;
		    // Macronix
		        // 1'b0 - Page Program
			    // 1'b1 - Quad Input/Output Fast Program
		    // Winbond
		        // 1'b0 - Page Program
			    // 1'b1 - Quad Input Fast Program
		input [2:0] prog_flash_addr_width_input;
		input [1:0] prog_data_lane_width_input;
		input [1:0] prog_addr_lane_width_input;
	    input [1:0] prog_cmd_lane_width_input; 
		
		// For Read Operation
		input [15:0] rd_xfer_len_bytes_input;
		input [2:0]  read_operation_input;
		    // Same read commands for Macronix and Winbond
		        // 3'b000 - Read Data
		        // 3'b001 - Fast Read
		        // 3'b010 - Dual Output Fast Read 1-1-2
		        // 3'b011 - Dual Input/Output Fast Read 1-2-2
		        // 3'b100 - Quad Output Fast Read 1-1-4
		        // 3'b101 - Quad Input/Output Fast Read 1-4-4
		input [7:0] num_wait_state_input;
		input [2:0] rd_flash_addr_width_input;
		input [1:0] rd_data_lane_width_input;
		input [1:0] rd_addr_lane_width_input;
	    input [1:0] rd_cmd_lane_width_input; 
		
		input [1:0] write_read_sequence;
		    // 2'b00 : any erase, 256-byte write, 256-bytes read
		    // 2'b01 : multiple write then read sequence will be used
			// 2'b10 : complete write then continouos read sequence
			
	    reg [4:0] erase_test_flash_command_code;
        reg [4:0] page_prog_flash_command_code;		
		reg [4:0] read_flash_command_code;
	    reg [31:0] flash_addr_input_val;
		reg [31:0] flash_wr_data_32b [262143:0];
		reg [31:0] flash_wr_data_32b_val [262143:0];
		reg [31:0] loop_write;
		reg [31:0] loop_read;
		reg [31:0] loop_write_read;
		reg [31:0] prog_xfer_len_bytes_for_loop;
		reg [31:0] rd_xfer_len_bytes_for_loop;
		reg [31:0] loop_write_cntr;
		reg [31:0] loop_read_cntr;
		reg [31:0] loop_write_read_cntr;
	    reg [31:0] loop_flash_addr;
		reg [31:0] addr_inc_val;
		reg [31:0] addr_inc_val_shift;
		reg [31:0] loop_flash_wr_data_32b_cntr;
		reg [31:0] test_cntr;
		reg [31:0] start_flash_wr_data_cntr;
		reg [31:0] stop_flash_wr_data_cntr;
		reg [31:0] addr_shift;
		reg [31:0] bit_cntr;
		
	    begin
			// Erase Test Decoding
			if (erase_test_input == 2'b00) begin
			    erase_test_flash_command_code = 5'h10;
			end
			else if (erase_test_input == 2'b01) begin
			    erase_test_flash_command_code = 5'h11;
			end
			else if (erase_test_input == 2'b10) begin
			    erase_test_flash_command_code = 5'h12;
			end
			else begin
			    erase_test_flash_command_code = 5'h13;
			end
			
			// Page Program Operation Decoding
			if (flash_device == 2'b00) begin
			    if (page_prog_operation_input == 1'b0) begin
			        page_prog_flash_command_code = 5'h17;
			    end
			    else begin
			        page_prog_flash_command_code = 5'h1B;
			    end
			end
			else if (flash_device == 2'b01) begin
			    if (page_prog_operation_input == 1'b0) begin
			        page_prog_flash_command_code = 5'h17;
			    end
			    else begin
			        page_prog_flash_command_code = 5'h1A;
			    end
			end
			
			// Read Operation Decoding
			if (read_operation_input == 3'b000) begin
			    read_flash_command_code = 5'h0A;
			end
			else if (read_operation_input == 3'b001) begin
			    read_flash_command_code = 5'h0B;
			end
			else if (read_operation_input == 3'b010) begin
			    read_flash_command_code = 5'h0C;
			end
			else if (read_operation_input == 3'b011) begin
			    read_flash_command_code = 5'h0D;
			end
			else if (read_operation_input == 3'b100) begin
			    read_flash_command_code = 5'h0E;
			end
			else if (read_operation_input == 3'b101) begin
			    read_flash_command_code = 5'h0F;
			end
			else begin
			    read_flash_command_code = 5'h0A;
			end
			
			if (flash_device == 2'b01) begin
			    // Flash Byte Address Mode 
			    if (erase_flash_addr_width_input == 3'b011) begin //4-bytes address
	    	        // ENTER_4_BYTE_ADDRESS_MODE
	    	        //supported_flash_command_opcode_only(5'h1C);
			    	// Update the command opcodes to 4-byte operation opcodes
			    	command_code_update(1);
			    end
		        else begin // just to add some random test
	    	        // ENTER_4_BYTE_ADDRESS_MODE
	    	        supported_flash_command_opcode_only(1'h1, 5'h1C, 5'h1);
	    	        // EXIT_4_BYTE_ADDRESS_MODE
	    	        supported_flash_command_opcode_only(1'h1, 5'h1D, 5'h1);
			    	command_code_update(0);
			    end
			end
			
	    	// Flash Address Input
	    	if (DATA_ENDIANNESS == 1) begin
			    if (erase_flash_addr_width_input == 3'b010) begin //3-byte address
				    flash_addr_input_val = {flash_addr_input[31:8], 8'h0};
			    end
			    else if (erase_flash_addr_width_input == 3'b011) begin //4-byte address
	    	        flash_addr_input_val = flash_addr_input;
			    end
	    	end
	    	else begin
			    if (erase_flash_addr_width_input == 3'b010) begin //3-byte address
				    flash_addr_input_val = {flash_addr_input[15:8], flash_addr_input[23:16], flash_addr_input[31:24], 8'h0};
	    	    end
			    else if (erase_flash_addr_width_input == 3'b011) begin //4-byte address
	    	        flash_addr_input_val = {flash_addr_input[7:0], flash_addr_input[15:8], flash_addr_input[23:16], flash_addr_input[31:24]};
	    	    end
			end
			
			// Start : Erase operation
            // 4KB/32KB/64KB Sector Erase 1-1-1
	    	    erase_using_supported_commands(multiple_flash_target_input,    // multiple_flash_target
				                               erase_test_flash_command_code,  // flash_cmd_code
											   erase_flash_addr_width_input,   // flash_addr_width
											   erase_data_lane_width_input,    // data_lane_width
											   erase_addr_lane_width_input,    // addr_lane_width
				                               erase_cmd_lane_width_input,     // cmd_lane_width
											   flash_addr_input_val,           // flash_address 
											   tgt_cs_input);                  // SPI target         
		    // End : Erase operation
			
			if (write_read_sequence == 2'b00) begin
			    loop_write                    = 1;
                loop_read                     = 1;
		        loop_write_read               = 1;
		        prog_xfer_len_bytes_for_loop  = prog_xfer_len_bytes_input;
		        rd_xfer_len_bytes_for_loop    = rd_xfer_len_bytes_input;
			end
			else if (write_read_sequence == 2'b01) begin
				if (erase_test_input == 2'b00) begin
				    if (ENABLE_RECEIVE_FIFO) begin // Assuming 512 FIFO DEPTH
                        loop_read                     = 2;
		                rd_xfer_len_bytes_for_loop    = 16'h0800;
					end
					else begin
                        loop_read                     = 1;
		                rd_xfer_len_bytes_for_loop    = 16'h1000;
					end
		            loop_write                    = 32'h10; // 1 PP = 256 bytes : 4KB = 4096 bytes : 4096/256 = 16
		            loop_write_read               = 1;
		            prog_xfer_len_bytes_for_loop  = 32'h100;
				end
				else if (erase_test_input == 2'b01) begin
				    if (ENABLE_RECEIVE_FIFO) begin // Assuming 512 FIFO DEPTH
                        loop_read                     = 32'h10;
		                rd_xfer_len_bytes_for_loop    = 16'h0800;
					end
					else begin
                        loop_read                     = 1;
		                rd_xfer_len_bytes_for_loop    = 16'h8000;
					end
		            loop_write                    = 32'h80; // 1 PP = 256 bytes : 32KB = 32768 bytes : 32768/256 = 128 
		            loop_write_read               = 1;
		            prog_xfer_len_bytes_for_loop  = 32'h100;
				end
				else if (erase_test_input == 2'b10) begin
				    if (ENABLE_RECEIVE_FIFO) begin // Assuming 512 FIFO DEPTH
                        loop_read                     = 32'h20;
		                rd_xfer_len_bytes_for_loop    = 16'h0800;
					end
					else begin
                        loop_read                     = 2;
		                rd_xfer_len_bytes_for_loop    = 16'h8000;
					end
		            loop_write                    = 32'h100; // 1 PP = 256 bytes : 64KB = 65536 bytes : 65536/256 = 256 
		            loop_write_read               = 1;
		            prog_xfer_len_bytes_for_loop  = 32'h100;
				end
				else begin
				    if (ENABLE_RECEIVE_FIFO) begin // Assuming 512 FIFO DEPTH
                        loop_read                     = 32'h02;
		                rd_xfer_len_bytes_for_loop    = 16'h0800;
					end
					else begin
                        loop_read                     = 1;
		                rd_xfer_len_bytes_for_loop    = 16'h1000;
					end
		            loop_write                    = 32'h10; // 1 PP = 256 bytes : 4KB = 4096 bytes : 4096/256 = 16
		            loop_write_read               = 1;
		            prog_xfer_len_bytes_for_loop  = 32'h100;
				end
			end
			else if (write_read_sequence == 2'b10) begin
				if (erase_test_input == 2'b00) begin
		            loop_write_read = 32'h10; // 1 PP = 256 bytes : 4KB = 4096 bytes : 4096/256 = 16
				end
				else if (erase_test_input == 2'b01) begin
		            loop_write_read = 32'h80; // 1 PP = 256 bytes : 32KB = 32768 bytes : 32768/256 = 128 
				end
				else if (erase_test_input == 2'b10) begin
		            loop_write_read = 32'h100; // 1 PP = 256 bytes : 64KB = 65536 bytes : 65536/256 = 256 
				end
				else begin
		            loop_write_read = 32'h10; // 1 PP = 256 bytes : 4KB = 4096 bytes : 4096/256 = 16
				end
		        loop_write                    = 1;
                loop_read                     = 1;
		        prog_xfer_len_bytes_for_loop  = 32'h100;
		        rd_xfer_len_bytes_for_loop    = 32'h100;
			end
			
			// Page Program - Read sequence
			page_program_read_using_supported_commands(
			    prog_xfer_len_bytes_input,
				multiple_flash_target_input,
                page_prog_flash_command_code,
                prog_flash_addr_width_input,
				tgt_cs_input,
                prog_data_lane_width_input,
                prog_addr_lane_width_input,
                prog_cmd_lane_width_input,
                flash_addr_input_val,
                rd_xfer_len_bytes_input,
                read_flash_command_code,
                num_wait_state_input,
                rd_flash_addr_width_input,   
                rd_data_lane_width_input,
                rd_addr_lane_width_input, 
				rd_cmd_lane_width_input,
				loop_write,                   
				loop_read,                   
				loop_write_read,              
				prog_xfer_len_bytes_for_loop, 
			    rd_xfer_len_bytes_for_loop  
			);
		end
	endtask
	
	// Below are compiled tasks
	
	// This task will run supported flash commands with below functions:
	// Send opcode Only
	// Send command and write data
	// Send command then read data
	task supported_commands_test_send_command_write_read_data;
	    begin
		    //supported_commands_test_send_command_and_read_data();
	        supported_commands_test_send_command();
		    if (DATA_ENDIANNESS == 1) begin // Big Endian
		        // Write 1 to Quad Enable Bit
		        supported_commands_test_send_command_and_write_data({8'h40, 24'h000000}, 5'h00, 1'h0, 5'h0);
		        // Write 0 to Quad Enable Bit
		        supported_commands_test_send_command_and_write_data(32'h00000000, 5'h00, 1'h0, 5'h0);
		    end
		    else begin
		        // Write 1 to Quad Enable Bit
		        supported_commands_test_send_command_and_write_data({24'h000000, 8'h40}, 5'h00, 1'h0, 5'h0);
		        // Write 0 to Quad Enable Bit
		        supported_commands_test_send_command_and_write_data(32'h00000000, 5'h00, 1'h0, 5'h0);
		    end
		end
	endtask
	
	// 5 loops of 4KB erase 256-byte write and read on Standard(1-1-1)/Quad(4-4-4) SPI mode
	task erase_page_program_and_read_fifo_disabled;
	    input [1:0] supported_protocol;
	    begin
			if (DATA_ENDIANNESS == 1) begin // Big-endian
			    // Inputs are Address and Supported Protocol
			    erase_write_read_using_supported_commands(32'h01000000,supported_protocol);
			    erase_write_read_using_supported_commands(32'h01010000,supported_protocol);
			    erase_write_read_using_supported_commands(32'h01020000,supported_protocol);
			    erase_write_read_using_supported_commands(32'h01030000,supported_protocol);
			    erase_write_read_using_supported_commands(32'h01040000,supported_protocol);
			end
			else begin // Little-endian
			    // Inputs are Address and Supported Protocol
			    erase_write_read_using_supported_commands(32'h00000001,supported_protocol);
			    erase_write_read_using_supported_commands(32'h00000101,supported_protocol);
			    erase_write_read_using_supported_commands(32'h00000201,supported_protocol);
			    erase_write_read_using_supported_commands(32'h00000301,supported_protocol);
			    erase_write_read_using_supported_commands(32'h00000401,supported_protocol);
			end
		end
	endtask
	
	// 4KB/32KB/64KB erase-write-read tests
	// Standard(1-1-1)/Quad(4-4-4) SPI mode
	task sector_block_erase_write_read_fifo_disabled;
	    input [1:0] supported_protocol;
	    begin
		    // Inputs are Erase Test and Supported Protocol
			// 4KB
			erase_multiple_write_single_read_using_supported_commands(0,supported_protocol);
			erase_multiple_write_and_read_using_supported_commands(0,supported_protocol);
			// 32KB
			erase_multiple_write_single_read_using_supported_commands(1,supported_protocol);
			erase_multiple_write_and_read_using_supported_commands(1,supported_protocol);
			// 64KB
			erase_multiple_write_single_read_using_supported_commands(2,supported_protocol);
			erase_multiple_write_and_read_using_supported_commands(2,supported_protocol);	
		end
	endtask
	
	// 5 loops of 4KB erase 256-byte write and read on Standard(1-1-1)/Quad(4-4-4) SPI mode
    task erase_page_program_and_read_fifo_enabled;
	    input [1:0] supported_protocol; 
	    begin
		    if (DATA_ENDIANNESS == 1) begin // Big-endian
		        // Inputs are Address and Supported Protocol
	            erase_write_read_using_supported_commands_fifo_enabled(32'h01000000,supported_protocol);
	            erase_write_read_using_supported_commands_fifo_enabled(32'h01010000,supported_protocol);
		        erase_write_read_using_supported_commands_fifo_enabled(32'h01020000,supported_protocol);
		        // Inputs are Address, Erase Test and Supported Protocol
		        erase_write_read_using_supported_commands_fifo_enabled_less_xfer_len(32'h01030000,2'b00,supported_protocol);
		        erase_write_read_using_supported_commands_fifo_enabled_less_xfer_len(32'h01040000,2'b00,supported_protocol);
		    end
		    else begin // Little-endian
		        // Inputs are Address and Supported Protocol
	            erase_write_read_using_supported_commands_fifo_enabled(32'h00000001,2'b00);
	            erase_write_read_using_supported_commands_fifo_enabled(32'h00000101,2'b00);
		        erase_write_read_using_supported_commands_fifo_enabled(32'h00000201,2'b00);
		        // Inputs are Address, Erase Test and Supported Protocol
		        erase_write_read_using_supported_commands_fifo_enabled_less_xfer_len(32'h00000301,2'b00,supported_protocol);
		        erase_write_read_using_supported_commands_fifo_enabled_less_xfer_len(32'h00000401,2'b00,supported_protocol);
		    end	
		end
	endtask
	
	// Macronix Flash Testing
    task erase_write_read_test_supported_commands_main_mx;
	    input [31:0] test;
	    begin
		// Test 1 - 6 : Test all PP and Read Commands on Macronix SPI Mode using 4KB Sector Erase
		    // Test 1
		    if (test == 32'd1) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 1", $time);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 4KB sector erase 1-1-1 3-byte address mode SPI Mode
		        	2'b00,        // erase_test_input 
		        	3'b010,       // erase_flash_addr_width_input
		        	2'b00,        // erase_data_lane_width_input
		        	2'b00,        // erase_addr_lane_width_input
		        	2'b00,        // erase_cmd_lane_width_input
		        	32'h00010000, // flash address
					1'h0,         // multiple_flash_target
					5'h0,         // tgt_cs
		        	// Write Operation : Page Program 1-1-1 3-byte address 256-bytes SPI Mode
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h0,         // page_prog_operation_input
		        	3'b010,       // prog_flash_addr_width_input
		        	2'b00,        // prog_data_lane_width_input
		        	2'b00,        // prog_addr_lane_width_input
		        	2'b00,        // prog_cmd_lane_width_input
		        	// Read Operation : Read Data 1-1-1 3-byte address 256-bytes
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b000,       // read_operation_input
		        	8'h0,         // num_wait_state_input
		        	3'b010,       // rd_flash_addr_width_input
		        	2'b00,        // rd_data_lane_width_input
		        	2'b00,        // rd_addr_lane_width_input
		        	2'b00,        // rd_cmd_lane_width_input
					2'b00         // Write Read Sequence
		        );
			end
		    // Test 2
		    if (test == 32'd2) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 2", $time);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 4KB sector erase 1-1-1 3-byte address mode SPI Mode
		        	2'b00,        // erase_test_input 
		        	3'b010,       // erase_flash_addr_width_input
		        	2'b00,        // erase_data_lane_width_input
		        	2'b00,        // erase_addr_lane_width_input
		        	2'b00,        // erase_cmd_lane_width_input
		        	32'h00010000, // flash address
					1'h0,         // multiple_flash_target
					5'h0,         // tgt_cs
		        	// Write Operation : Quad Input/Output Fast Page Program 1-1-1 3-byte address 256-bytes SPI Mode
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h0,         // page_prog_operation_input
		        	3'b010,       // prog_flash_addr_width_input
		        	2'b00,        // prog_data_lane_width_input
		        	2'b00,        // prog_addr_lane_width_input
		        	2'b00,        // prog_cmd_lane_width_input
		        	// Read Operation : Fast Read Data 1-1-1 3-byte address 256-bytes
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b001,       // read_operation_input
		        	8'h8,         // num_wait_state_input
		        	3'b010,       // rd_flash_addr_width_input
		        	2'b00,        // rd_data_lane_width_input
		        	2'b00,        // rd_addr_lane_width_input
		        	2'b00,        // rd_cmd_lane_width_input
					2'b00         // Write Read Sequence
		        );
			end
		    // Test 3
		    if (test == 32'd3) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 3", $time);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 4KB sector erase 1-1-1 3-byte address mode SPI Mode
		        	2'b00,        // erase_test_input 
		        	3'b010,       // erase_flash_addr_width_input
		        	2'b00,        // erase_data_lane_width_input
		        	2'b00,        // erase_addr_lane_width_input
		        	2'b00,        // erase_cmd_lane_width_input
		        	32'h00010000, // flash address
					1'h0,         // multiple_flash_target
					5'h0,         // tgt_cs
		        	// Write Operation : Page Program 1-1-1 3-byte address 256-bytes SPI Mode
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h0,         // page_prog_operation_input
		        	3'b010,       // prog_flash_addr_width_input
		        	2'b00,        // prog_data_lane_width_input
		        	2'b00,        // prog_addr_lane_width_input
		        	2'b00,        // prog_cmd_lane_width_input
		        	// Read Operation : Dual Output Fast Read 1-1-2 3-byte address 256-bytes
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b010,       // read_operation_input
		        	8'h8,         // num_wait_state_input
		        	3'b010,       // rd_flash_addr_width_input
		        	2'b01,        // rd_data_lane_width_input
		        	2'b00,        // rd_addr_lane_width_input
		        	2'b00,        // rd_cmd_lane_width_input
					2'b00         // Write Read Sequence
		        );
			end
		    // Test 4
		    if (test == 32'd4) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 4", $time);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 4KB sector erase 1-1-1 3-byte address mode SPI Mode
		        	2'b00,        // erase_test_input 
		        	3'b010,       // erase_flash_addr_width_input
		        	2'b00,        // erase_data_lane_width_input
		        	2'b00,        // erase_addr_lane_width_input
		        	2'b00,        // erase_cmd_lane_width_input
		        	32'h00010000, // flash address
					1'h0,         // multiple_flash_target
					5'h0,         // tgt_cs
		        	// Write Operation : Quad Input/Output Fast Page Program 1-1-1 3-byte address 256-bytes SPI Mode
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h0,         // page_prog_operation_input
		        	3'b010,       // prog_flash_addr_width_input
		        	2'b00,        // prog_data_lane_width_input
		        	2'b00,        // prog_addr_lane_width_input
		        	2'b00,        // prog_cmd_lane_width_input
		        	// Read Operation : Dual Input/Output Fast Read 1-2-2 3-byte address 256-bytes
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b011,       // read_operation_input
		        	8'h4,         // num_wait_state_input
		        	3'b010,       // rd_flash_addr_width_input
		        	2'b01,        // rd_data_lane_width_input
		        	2'b01,        // rd_addr_lane_width_input
		        	2'b00,        // rd_cmd_lane_width_input
					2'b00         // Write Read Sequence
		        );
			end
		    // Test 5
		    if (test == 32'd5) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 5", $time);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 4KB sector erase 1-1-1 3-byte address mode SPI Mode
		        	2'b00,        // erase_test_input 
		        	3'b010,       // erase_flash_addr_width_input
		        	2'b00,        // erase_data_lane_width_input
		        	2'b00,        // erase_addr_lane_width_input
		        	2'b00,        // erase_cmd_lane_width_input
		        	32'h00010000, // flash address
					1'h0,         // multiple_flash_target
					5'h0,         // tgt_cs
		        	// Write Operation : Page Program 1-4-4 3-byte address 256-bytes SPI Mode
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h1,         // page_prog_operation_input
		        	3'b010,       // prog_flash_addr_width_input
		        	2'b10,        // prog_data_lane_width_input
		        	2'b10,        // prog_addr_lane_width_input
		        	2'b00,        // prog_cmd_lane_width_input
		        	// Read Operation : Quad Output Fast Read 1-1-4 3-byte address 256-bytes
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b100,       // read_operation_input
		        	8'h8,         // num_wait_state_input
		        	3'b010,       // rd_flash_addr_width_input
		        	2'b10,        // rd_data_lane_width_input
		        	2'b00,        // rd_addr_lane_width_input
		        	2'b00,        // rd_cmd_lane_width_input
					2'b00         // Write Read Sequence
		        );
			end
		    // Test 6
		    if (test == 32'd6) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 6", $time);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 4KB sector erase 1-1-1 3-byte address mode SPI Mode
		        	2'b00,        // erase_test_input 
		        	3'b010,       // erase_flash_addr_width_input
		        	2'b00,        // erase_data_lane_width_input
		        	2'b00,        // erase_addr_lane_width_input
		        	2'b00,        // erase_cmd_lane_width_input
		        	32'h00010000, // flash address
					1'h0,         // multiple_flash_target
					5'h0,         // tgt_cs
		        	// Write Operation : Quad Input/Output Fast Page Program 1-4-4 3-byte address 256-bytes SPI Mode
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h1,         // page_prog_operation_input
		        	3'b010,       // prog_flash_addr_width_input
		        	2'b10,        // prog_data_lane_width_input
		        	2'b10,        // prog_addr_lane_width_input
		        	2'b00,        // prog_cmd_lane_width_input
		        	// Read Operation : Quad Input/Output Fast Read 1-4-4 3-byte address 256-bytes
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b101,       // read_operation_input
		        	8'h6,         // num_wait_state_input
		        	3'b010,       // rd_flash_addr_width_input
		        	2'b10,        // rd_data_lane_width_input
		        	2'b10,        // rd_addr_lane_width_input
		        	2'b00,        // rd_cmd_lane_width_input
					2'b00         // Write Read Sequence
		        );
			end
		// Test 7 - 9 : Test Commands on QPI Mode, Multiple Write, Single Read, 3 Different Erase Commands
      		// Test 7
		    if (test == 32'd7) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 7", $time);
				supported_flash_command_opcode_only(1'h0, 5'h1E, 5'h0);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 4KB sector erase 4-4-4 3-byte address mode QPI Mode
		        	2'b00,        // erase_test_input 
		        	3'b010,       // erase_flash_addr_width_input
		        	2'b10,        // erase_data_lane_width_input
		        	2'b10,        // erase_addr_lane_width_input
		        	2'b10,        // erase_cmd_lane_width_input
		        	32'h01000000, // flash address
					1'h0,         // multiple_flash_target
					5'h0,         // tgt_cs
		        	// Write Operation : Page Program 4-4-4 3-byte address 256-bytes QPI Mode
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h0,         // page_prog_operation_input
		        	3'b010,       // prog_flash_addr_width_input
		        	2'b10,        // prog_data_lane_width_input
		        	2'b10,        // prog_addr_lane_width_input
		        	2'b10,        // prog_cmd_lane_width_input
		        	// Read Operation : Quad Input/Output Fast Read 4-4-4 3-byte address 256-bytes QPI Mode
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b101,       // read_operation_input
		        	8'h6,         // num_wait_state_input
		        	3'b010,       // rd_flash_addr_width_input
		        	2'b10,        // rd_data_lane_width_input
		        	2'b10,        // rd_addr_lane_width_input
		        	2'b10,        // rd_cmd_lane_width_input
					2'b01         // Write Read Sequence
		        );
				supported_flash_command_opcode_only(1'h0, 5'h1F, 5'h0);
			end
      		// Test 8
		    if (test == 32'd8) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 8", $time);
				supported_flash_command_opcode_only(1'h0, 5'h1E, 5'h0);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 32KB sector erase 4-4-4 3-byte address mode QPI Mode
		        	2'b01,        // erase_test_input 
		        	3'b010,       // erase_flash_addr_width_input
		        	2'b10,        // erase_data_lane_width_input
		        	2'b10,        // erase_addr_lane_width_input
		        	2'b10,        // erase_cmd_lane_width_input
		        	32'h01000000, // flash address
					1'h0,         // multiple_flash_target
					5'h0,         // tgt_cs
		        	// Write Operation : Page Program 4-4-4 3-byte address 256-bytes QPI Mode
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h0,         // page_prog_operation_input
		        	3'b010,       // prog_flash_addr_width_input
		        	2'b10,        // prog_data_lane_width_input
		        	2'b10,        // prog_addr_lane_width_input
		        	2'b10,        // prog_cmd_lane_width_input
		        	// Read Operation : Quad Input/Output Fast Read 4-4-4 3-byte address 256-bytes QPI Mode
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b101,       // read_operation_input
		        	8'h6,         // num_wait_state_input
		        	3'b010,       // rd_flash_addr_width_input
		        	2'b10,        // rd_data_lane_width_input
		        	2'b10,        // rd_addr_lane_width_input
		        	2'b10,        // rd_cmd_lane_width_input
					2'b01         // Write Read Sequence
		        );
				supported_flash_command_opcode_only(1'h0, 5'h1F, 5'h0);
			end
      		// Test 9
		    if (test == 32'd9) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 9", $time);
				supported_flash_command_opcode_only(1'h0, 5'h1E, 5'h0);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 64KB sector erase 4-4-4 3-byte address mode QPI Mode
		        	2'b10,        // erase_test_input 
		        	3'b010,       // erase_flash_addr_width_input
		        	2'b10,        // erase_data_lane_width_input
		        	2'b10,        // erase_addr_lane_width_input
		        	2'b10,        // erase_cmd_lane_width_input
		        	32'h01000000, // flash address
					1'h0,         // multiple_flash_target
					5'h0,         // tgt_cs
		        	// Write Operation : Page Program 4-4-4 3-byte address 256-bytes QPI Mode
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h0,         // page_prog_operation_input
		        	3'b010,       // prog_flash_addr_width_input
		        	2'b10,        // prog_data_lane_width_input
		        	2'b10,        // prog_addr_lane_width_input
		        	2'b10,        // prog_cmd_lane_width_input
		        	// Read Operation : Quad Input/Output Fast Read 4-4-4 3-byte address 256-bytes QPI Mode
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b101,       // read_operation_input
		        	8'h6,         // num_wait_state_input
		        	3'b010,       // rd_flash_addr_width_input
		        	2'b10,        // rd_data_lane_width_input
		        	2'b10,        // rd_addr_lane_width_input
		        	2'b10,        // rd_cmd_lane_width_input
					2'b01         // Write Read Sequence
		        );
				supported_flash_command_opcode_only(1'h0, 5'h1F, 5'h0);
			end
        // Test 10 - 12 : Test Commands on QPI Mode, Multiple Single Write - Single Read, 3 Different Erase Commands       	
		    // Test 10
		    if (test == 32'd10) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 10", $time);
				supported_flash_command_opcode_only(1'h0, 5'h1E, 5'h0);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 4KB sector erase 4-4-4 3-byte address mode QPI Mode
		        	2'b00,        // erase_test_input 
		        	3'b010,       // erase_flash_addr_width_input
		        	2'b10,        // erase_data_lane_width_input
		        	2'b10,        // erase_addr_lane_width_input
		        	2'b10,        // erase_cmd_lane_width_input
		        	32'h01000000, // flash address
					1'h0,         // multiple_flash_target
					5'h0,         // tgt_cs
		        	// Write Operation : Page Program 4-4-4 3-byte address 256-bytes QPI Mode
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h0,         // page_prog_operation_input
		        	3'b010,       // prog_flash_addr_width_input
		        	2'b10,        // prog_data_lane_width_input
		        	2'b10,        // prog_addr_lane_width_input
		        	2'b10,        // prog_cmd_lane_width_input
		        	// Read Operation : Quad Input/Output Fast Read 4-4-4 3-byte address 256-bytes QPI Mode
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b101,       // read_operation_input
		        	8'h6,         // num_wait_state_input
		        	3'b010,       // rd_flash_addr_width_input
		        	2'b10,        // rd_data_lane_width_input
		        	2'b10,        // rd_addr_lane_width_input
		        	2'b10,        // rd_cmd_lane_width_input
					2'b10         // Write Read Sequence
		        );
				supported_flash_command_opcode_only(1'h0, 5'h1F, 5'h0);
			end
      		// Test 11
		    if (test == 32'd11) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 11", $time);
				supported_flash_command_opcode_only(1'h0, 5'h1E, 5'h0);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 32KB sector erase 4-4-4 3-byte address mode QPI Mode
		        	2'b01,        // erase_test_input 
		        	3'b010,       // erase_flash_addr_width_input
		        	2'b10,        // erase_data_lane_width_input
		        	2'b10,        // erase_addr_lane_width_input
		        	2'b10,        // erase_cmd_lane_width_input
		        	32'h01000000, // flash address
					1'h0,         // multiple_flash_target
					5'h0,         // tgt_cs
		        	// Write Operation : Page Program 4-4-4 3-byte address 256-bytes QPI Mode
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h0,         // page_prog_operation_input
		        	3'b010,       // prog_flash_addr_width_input
		        	2'b10,        // prog_data_lane_width_input
		        	2'b10,        // prog_addr_lane_width_input
		        	2'b10,        // prog_cmd_lane_width_input
		        	// Read Operation : Quad Input/Output Fast Read 4-4-4 3-byte address 256-bytes QPI Mode
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b101,       // read_operation_input
		        	8'h6,         // num_wait_state_input
		        	3'b010,       // rd_flash_addr_width_input
		        	2'b10,        // rd_data_lane_width_input
		        	2'b10,        // rd_addr_lane_width_input
		        	2'b10,        // rd_cmd_lane_width_input
					2'b10         // Write Read Sequence
		        );
				supported_flash_command_opcode_only(1'h0, 5'h1F, 5'h0);
			end
      		// Test 12
		    if (test == 32'd12) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 12", $time);
				supported_flash_command_opcode_only(1'h0, 5'h1E, 5'h0);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 64KB sector erase 4-4-4 3-byte address mode QPI Mode
		        	2'b10,        // erase_test_input 
		        	3'b010,       // erase_flash_addr_width_input
		        	2'b10,        // erase_data_lane_width_input
		        	2'b10,        // erase_addr_lane_width_input
		        	2'b10,        // erase_cmd_lane_width_input
		        	32'h01000000, // flash address
					1'h0,         // multiple_flash_target
					5'h0,         // tgt_cs
		        	// Write Operation : Page Program 4-4-4 3-byte address 256-bytes QPI Mode
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h0,         // page_prog_operation_input
		        	3'b010,       // prog_flash_addr_width_input
		        	2'b10,        // prog_data_lane_width_input
		        	2'b10,        // prog_addr_lane_width_input
		        	2'b10,        // prog_cmd_lane_width_input
		        	// Read Operation : Quad Input/Output Fast Read 4-4-4 3-byte address 256-bytes QPI Mode
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b101,       // read_operation_input
		        	8'h6,         // num_wait_state_input
		        	3'b010,       // rd_flash_addr_width_input
		        	2'b10,        // rd_data_lane_width_input
		        	2'b10,        // rd_addr_lane_width_input
		        	2'b10,        // rd_cmd_lane_width_input
					2'b10         // Write Read Sequence
		        );
				supported_flash_command_opcode_only(1'h0, 5'h1F, 5'h0);
			end
		// Test 13 - 14 : SPI sequence on Multiple Write-Single Read, Multiple Single Write - Single Read
			// Test 13
			if (test == 32'd13) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 13", $time);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 4KB sector erase 1-1-1 3-byte address mode SPI Mode
		        	2'b00,        // erase_test_input 
		        	3'b010,       // erase_flash_addr_width_input
		        	2'b00,        // erase_data_lane_width_input
		        	2'b00,        // erase_addr_lane_width_input
		        	2'b00,        // erase_cmd_lane_width_input
		        	32'h01000000, // flash address
					1'h0,         // multiple_flash_target
					5'h0,         // tgt_cs
		        	// Write Operation : Page Program 1-1-1 3-byte address 256-bytes SPI Mode
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h0,         // page_prog_operation_input
		        	3'b010,       // prog_flash_addr_width_input
		        	2'b00,        // prog_data_lane_width_input
		        	2'b00,        // prog_addr_lane_width_input
		        	2'b00,        // prog_cmd_lane_width_input
		        	// Read Operation : Read Data 1-1-1 3-byte address 256-bytes
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b000,       // read_operation_input
		        	8'h0,         // num_wait_state_input
		        	3'b010,       // rd_flash_addr_width_input
		        	2'b00,        // rd_data_lane_width_input
		        	2'b00,        // rd_addr_lane_width_input
		        	2'b00,        // rd_cmd_lane_width_input
					2'b01         // Write Read Sequence
		        );
			end
		    // Test 14
		    if (test == 32'd14) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 14", $time);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 4KB sector erase 1-1-1 3-byte address mode SPI Mode
		        	2'b00,        // erase_test_input 
		        	3'b010,       // erase_flash_addr_width_input
		        	2'b00,        // erase_data_lane_width_input
		        	2'b00,        // erase_addr_lane_width_input
		        	2'b00,        // erase_cmd_lane_width_input
		        	32'h01000000, // flash address
					1'h0,         // multiple_flash_target
					5'h0,         // tgt_cs
		        	// Write Operation : Quad Input/Output Fast Page Program 1-1-1 3-byte address 256-bytes SPI Mode
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h0,         // page_prog_operation_input
		        	3'b010,       // prog_flash_addr_width_input
		        	2'b00,        // prog_data_lane_width_input
		        	2'b00,        // prog_addr_lane_width_input
		        	2'b00,        // prog_cmd_lane_width_input
		        	// Read Operation : Fast Read Data 1-1-1 3-byte address 256-bytes
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b001,       // read_operation_input
		        	8'h8,         // num_wait_state_input
		        	3'b010,       // rd_flash_addr_width_input
		        	2'b00,        // rd_data_lane_width_input
		        	2'b00,        // rd_addr_lane_width_input
		        	2'b00,        // rd_cmd_lane_width_input
					2'b10         // Write Read Sequence
		        );
			end
		// Test 15 - 16 : SPI/DSPI sequence on Multiple Write-Single Read, Multiple Single Write - Single Read
      		// Test 15
		    if (test == 32'd15) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 15", $time);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 4KB sector erase 1-1-1 3-byte address mode SPI Mode
		        	2'b00,        // erase_test_input 
		        	3'b010,       // erase_flash_addr_width_input
		        	2'b00,        // erase_data_lane_width_input
		        	2'b00,        // erase_addr_lane_width_input
		        	2'b00,        // erase_cmd_lane_width_input
		        	32'h01000000, // flash address
					1'h0,         // multiple_flash_target
					5'h0,         // tgt_cs
		        	// Write Operation : Page Program 1-1-1 3-byte address 256-bytes SPI Mode
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h0,         // page_prog_operation_input
		        	3'b010,       // prog_flash_addr_width_input
		        	2'b00,        // prog_data_lane_width_input
		        	2'b00,        // prog_addr_lane_width_input
		        	2'b00,        // prog_cmd_lane_width_input
		        	// Read Operation : Dual Output Fast Read 1-1-2 3-byte address 256-bytes
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b010,       // read_operation_input
		        	8'h8,         // num_wait_state_input
		        	3'b010,       // rd_flash_addr_width_input
		        	2'b01,        // rd_data_lane_width_input
		        	2'b00,        // rd_addr_lane_width_input
		        	2'b00,        // rd_cmd_lane_width_input
					2'b01         // Write Read Sequence
		        );
			end
		    // Test 16
		    if (test == 32'd16) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 16", $time);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 4KB sector erase 1-1-1 3-byte address mode SPI Mode
		        	2'b00,        // erase_test_input 
		        	3'b010,       // erase_flash_addr_width_input
		        	2'b00,        // erase_data_lane_width_input
		        	2'b00,        // erase_addr_lane_width_input
		        	2'b00,        // erase_cmd_lane_width_input
		        	32'h01000000, // flash address
					1'h0,         // multiple_flash_target
					5'h0,         // tgt_cs
		        	// Write Operation : Quad Input/Output Fast Page Program 1-1-1 3-byte address 256-bytes SPI Mode
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h0,         // page_prog_operation_input
		        	3'b010,       // prog_flash_addr_width_input
		        	2'b00,        // prog_data_lane_width_input
		        	2'b00,        // prog_addr_lane_width_input
		        	2'b00,        // prog_cmd_lane_width_input
		        	// Read Operation : Dual Input/Output Fast Read 1-2-2 3-byte address 256-bytes
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b011,       // read_operation_input
		        	8'h4,         // num_wait_state_input
		        	3'b010,       // rd_flash_addr_width_input
		        	2'b01,        // rd_data_lane_width_input
		        	2'b01,        // rd_addr_lane_width_input
		        	2'b00,        // rd_cmd_lane_width_input
					2'b10         // Write Read Sequence
		        );
			end
		end
	endtask
	
	task standard_spi_test_mx;
	    begin
	        erase_write_read_test_supported_commands_main_mx(1);
	        erase_write_read_test_supported_commands_main_mx(2);
	        erase_write_read_test_supported_commands_main_mx(13);
		    if (run_full_regr == 1) begin
	            erase_write_read_test_supported_commands_main_mx(14);
		    end
		end
	endtask
	
	task dual_spi_test_mx;
        begin
	        erase_write_read_test_supported_commands_main_mx(3);
	        erase_write_read_test_supported_commands_main_mx(4);
	        erase_write_read_test_supported_commands_main_mx(16);
		    if (run_full_regr == 1) begin
	            erase_write_read_test_supported_commands_main_mx(15);
		    end
		end
	endtask
	
	task quad_spi_test_mx;
        begin
	        erase_write_read_test_supported_commands_main_mx(5);
	        erase_write_read_test_supported_commands_main_mx(6);
	        erase_write_read_test_supported_commands_main_mx(7);
	        erase_write_read_test_supported_commands_main_mx(11);
		    if (run_full_regr == 1) begin
	            erase_write_read_test_supported_commands_main_mx(8);
	            erase_write_read_test_supported_commands_main_mx(9);
	            erase_write_read_test_supported_commands_main_mx(10);
	            erase_write_read_test_supported_commands_main_mx(12);
		    end
		end
	endtask
	
	task direct_access_main_mx;
	    input [31:0] test;
	    begin
		    // Test 1 - 7: Direct Access - Single Transaction
		    if (test == 32'd1) begin
			    $display("# ---INFO : @%0dns :: Test Name : direct_access_test 1", $time);
				direct_write_read_access(
				// Write Operation : Page Program 1-1-1 3-byte address 256-bytes SPI Mode
				2'h0, // wr_dat_lane_width
				2'h0, // wr_addr_lane_width_input
				2'h0, // wr_cmd_lane_width_input
				1'h0, // wr_xip_addr_width_input
				3'h0, // wr_dummy_clock_cycles_input
				3'h0, // flash_map_en_wr_access_cmd_input
				// Read Operation : Read Data 1-1-1 3-byte address 256-bytes
				2'h0, // rd_dat_lane_width_input
				2'h0, // rd_addr_lane_width_input
				2'h0, // rd_cmd_lane_width_input
				1'h0, // rd_xip_addr_width_input
				3'h0, // rd_dummy_clock_cycles_input
				3'h0, // flash_map_en_rd_access_cmd_input
				//Others
				32'h00010000,  // direct_flash_address
				32'h40, // number_of_direct_write
				32'h40, // number_of_direct_read
				1'h0,   // single0/burst1 transaction
				1'h0    // enable xip mode
				);
			end
		    if (test == 32'd2) begin
			    $display("# ---INFO : @%0dns :: Test Name : direct_access_test 2", $time);
			    direct_write_read_access(
				// Write Operation : Page Program 1-1-1 3-byte address 256-bytes SPI Mode
				2'h0, // wr_dat_lane_width
				2'h0, // wr_addr_lane_width_input
				2'h0, // wr_cmd_lane_width_input
				1'h0, // wr_xip_addr_width_input
				3'h0, // wr_dummy_clock_cycles_input
				3'h0, // flash_map_en_wr_access_cmd_input
				// Read Operation : Fast Read Data 1-1-1 3-byte address 256-bytes
				2'h0, // rd_dat_lane_width_input
				2'h0, // rd_addr_lane_width_input
				2'h0, // rd_cmd_lane_width_input
				1'h0, // rd_xip_addr_width_input
				3'h4, // rd_dummy_clock_cycles_input
				3'h1, // flash_map_en_rd_access_cmd_input
				//Others
				32'h00010000,  // direct_flash_address
				32'h40, // number_of_direct_write
				32'h40, // number_of_direct_read
				1'h0,   // single0/burst1 transaction
				1'h0    // enable xip mode
				);
			end
		    if (test == 32'd3) begin
			    $display("# ---INFO : @%0dns :: Test Name : direct_access_test 3", $time);
			    direct_write_read_access(
				// Write Operation : Page Program 1-1-1 3-byte address 256-bytes SPI Mode
				2'h0, // wr_dat_lane_width
				2'h0, // wr_addr_lane_width_input
				2'h0, // wr_cmd_lane_width_input
				1'h0, // wr_xip_addr_width_input
				3'h0, // wr_dummy_clock_cycles_input
				3'h0, // flash_map_en_wr_access_cmd_input
				// Read Operation : Dual Output Fast Read 1-1-2 3-byte address 256-bytes
				2'h1, // rd_dat_lane_width_input
				2'h0, // rd_addr_lane_width_input
				2'h0, // rd_cmd_lane_width_input
				1'h0, // rd_xip_addr_width_input
				3'h4, // rd_dummy_clock_cycles_input
				3'h2, // flash_map_en_rd_access_cmd_input
				//Others
				32'h00010000,  // direct_flash_address
				32'h40, // number_of_direct_write
				32'h40, // number_of_direct_read
				1'h0,   // single0/burst1 transaction
				1'h0    // enable xip mode
				);
			end
		    if (test == 32'd4) begin
			    $display("# ---INFO : @%0dns :: Test Name : direct_access_test 4", $time);
			    direct_write_read_access(
				// Write Operation : Page Program 1-1-1 3-byte address 256-bytes SPI Mode
				2'h0, // wr_dat_lane_width
				2'h0, // wr_addr_lane_width_input
				2'h0, // wr_cmd_lane_width_input
				1'h0, // wr_xip_addr_width_input
				3'h0, // wr_dummy_clock_cycles_input
				3'h0, // flash_map_en_wr_access_cmd_input
				// Read Operation : Dual Input/Output Fast Read 1-2-2 3-byte address 256-bytes
				2'h1, // rd_dat_lane_width_input
				2'h1, // rd_addr_lane_width_input
				2'h0, // rd_cmd_lane_width_input
				1'h0, // rd_xip_addr_width_input
				3'h2, // rd_dummy_clock_cycles_input
				3'h3, // flash_map_en_rd_access_cmd_input
				//Others
				32'h00010000,  // direct_flash_address
				32'h40, // number_of_direct_write
				32'h40, // number_of_direct_read
				1'h0,   // single0/burst1 transaction
				1'h0    // enable xip mode
				);
			end
		    if (test == 32'd5) begin
			    $display("# ---INFO : @%0dns :: Test Name : direct_access_test 5", $time);
			    direct_write_read_access(
				// Write Operation : Page Program 4-4-4 3-byte address 256-bytes SPI Mode
				2'h2, // wr_dat_lane_width
				2'h2, // wr_addr_lane_width_input
				2'h2, // wr_cmd_lane_width_input
				1'h0, // wr_xip_addr_width_input
				3'h0, // wr_dummy_clock_cycles_input
				3'h0, // flash_map_en_wr_access_cmd_input
				// Read Operation : Quad Output Fast Read 1-1-4 3-byte address 256-bytes
				2'h2, // rd_dat_lane_width_input
				2'h0, // rd_addr_lane_width_input
				2'h0, // rd_cmd_lane_width_input
				1'h0, // rd_xip_addr_width_input
				3'h4, // rd_dummy_clock_cycles_input
				3'h4, // flash_map_en_rd_access_cmd_input
				//Others
				32'h00010000,  // direct_flash_address
				32'h40, // number_of_direct_write
				32'h40, // number_of_direct_read
				1'h0,   // single0/burst1 transaction
				1'h0    // enable xip mode
				);
			end
		    if (test == 32'd6) begin
			    $display("# ---INFO : @%0dns :: Test Name : direct_access_test 6", $time);
			    direct_write_read_access(
				// Write Operation : Page Program 1-4-4 3-byte address 256-bytes SPI Mode
				2'h2, // wr_dat_lane_width
				2'h2, // wr_addr_lane_width_input
				2'h0, // wr_cmd_lane_width_input
				1'h0, // wr_xip_addr_width_input
				3'h0, // wr_dummy_clock_cycles_input
				3'h4, // flash_map_en_wr_access_cmd_input
				// Read Operation : Quad Input/Output Fast Read 1-4-4 3-byte address 256-bytes
				2'h2, // rd_dat_lane_width_input
				2'h2, // rd_addr_lane_width_input
				2'h0, // rd_cmd_lane_width_input
				1'h0, // rd_xip_addr_width_input
				3'h3, // rd_dummy_clock_cycles_input
				3'h5, // flash_map_en_rd_access_cmd_input
				//Others
				32'h00010000,  // direct_flash_address
				32'h40, // number_of_direct_write
				32'h40, // number_of_direct_read
				1'h0,   // single0/burst1 transaction
				1'h0    // enable xip mode
				);
			end
		    if (test == 32'd7) begin
			    $display("# ---INFO : @%0dns :: Test Name : direct_access_test 7", $time);
			    direct_write_read_access(
				// Write Operation : Page Program 1-4-4 3-byte address 256-bytes SPI Mode
				2'h2, // wr_dat_lane_width
				2'h2, // wr_addr_lane_width_input
				2'h0, // wr_cmd_lane_width_input
				1'h0, // wr_xip_addr_width_input
				3'h0, // wr_dummy_clock_cycles_input
				3'h4, // flash_map_en_wr_access_cmd_input
				// Read Operation : Quad Input/Output Fast Read 4-4-4 3-byte address 256-bytes
				2'h2, // rd_dat_lane_width_input
				2'h2, // rd_addr_lane_width_input
				2'h2, // rd_cmd_lane_width_input
				1'h0, // rd_xip_addr_width_input
				3'h3, // rd_dummy_clock_cycles_input
				3'h5, // flash_map_en_rd_access_cmd_input
				//Others
				32'h00010000,  // direct_flash_address
				32'h40, // number_of_direct_write
				32'h40, // number_of_direct_read
				1'h0,   // single0/burst1 transaction
				1'h0    // enable xip mode
				);
			end
		    // Test 8 - 14: Direct Access - Burst Transaction
		    if (test == 32'd8) begin
			    $display("# ---INFO : @%0dns :: Test Name : direct_access_test 8", $time);
				direct_write_read_access(
				// Write Operation : Page Program 1-1-1 3-byte address 256-bytes SPI Mode
				2'h0, // wr_dat_lane_width
				2'h0, // wr_addr_lane_width_input
				2'h0, // wr_cmd_lane_width_input
				1'h0, // wr_xip_addr_width_input
				3'h0, // wr_dummy_clock_cycles_input
				3'h0, // flash_map_en_wr_access_cmd_input
				// Read Operation : Read Data 1-1-1 3-byte address 256-bytes
				2'h0, // rd_dat_lane_width_input
				2'h0, // rd_addr_lane_width_input
				2'h0, // rd_cmd_lane_width_input
				1'h0, // rd_xip_addr_width_input
				3'h0, // rd_dummy_clock_cycles_input
				3'h0, // flash_map_en_rd_access_cmd_input
				//Others
				32'h00010000,  // direct_flash_address
				32'h40, // number_of_direct_write
				32'h40, // number_of_direct_read
				1'h1,   // single0/burst1 transaction
				1'h0    // enable xip mode
				);
			end
		    if (test == 32'd9) begin
			    $display("# ---INFO : @%0dns :: Test Name : direct_access_test 9", $time);
			    direct_write_read_access(
				// Write Operation : Page Program 1-1-1 3-byte address 256-bytes SPI Mode
				2'h0, // wr_dat_lane_width
				2'h0, // wr_addr_lane_width_input
				2'h0, // wr_cmd_lane_width_input
				1'h0, // wr_xip_addr_width_input
				3'h0, // wr_dummy_clock_cycles_input
				3'h0, // flash_map_en_wr_access_cmd_input
				// Read Operation : Fast Read Data 1-1-1 3-byte address 256-bytes
				2'h0, // rd_dat_lane_width_input
				2'h0, // rd_addr_lane_width_input
				2'h0, // rd_cmd_lane_width_input
				1'h0, // rd_xip_addr_width_input
				3'h4, // rd_dummy_clock_cycles_input
				3'h1, // flash_map_en_rd_access_cmd_input
				//Others
				32'h00010000,  // direct_flash_address
				32'h40, // number_of_direct_write
				32'h40, // number_of_direct_read
				1'h1,   // single0/burst1 transaction
				1'h0    // enable xip mode
				);
			end
		    if (test == 32'd10) begin
			    $display("# ---INFO : @%0dns :: Test Name : direct_access_test 10", $time);
			    direct_write_read_access(
				// Write Operation : Page Program 1-1-1 3-byte address 256-bytes SPI Mode
				2'h0, // wr_dat_lane_width
				2'h0, // wr_addr_lane_width_input
				2'h0, // wr_cmd_lane_width_input
				1'h0, // wr_xip_addr_width_input
				3'h0, // wr_dummy_clock_cycles_input
				3'h0, // flash_map_en_wr_access_cmd_input
				// Read Operation : Dual Output Fast Read 1-1-2 3-byte address 256-bytes
				2'h1, // rd_dat_lane_width_input
				2'h0, // rd_addr_lane_width_input
				2'h0, // rd_cmd_lane_width_input
				1'h0, // rd_xip_addr_width_input
				3'h4, // rd_dummy_clock_cycles_input
				3'h2, // flash_map_en_rd_access_cmd_input
				//Others
				32'h00010000,  // direct_flash_address
				32'h40, // number_of_direct_write
				32'h40, // number_of_direct_read
				1'h1,   // single0/burst1 transaction
				1'h0    // enable xip mode
				);
			end
		    if (test == 32'd11) begin
			    $display("# ---INFO : @%0dns :: Test Name : direct_access_test 11", $time);
			    direct_write_read_access(
				// Write Operation : Page Program 1-1-1 3-byte address 256-bytes SPI Mode
				2'h0, // wr_dat_lane_width
				2'h0, // wr_addr_lane_width_input
				2'h0, // wr_cmd_lane_width_input
				1'h0, // wr_xip_addr_width_input
				3'h0, // wr_dummy_clock_cycles_input
				3'h0, // flash_map_en_wr_access_cmd_input
				// Read Operation : Dual Input/Output Fast Read 1-2-2 3-byte address 256-bytes
				2'h1, // rd_dat_lane_width_input
				2'h1, // rd_addr_lane_width_input
				2'h0, // rd_cmd_lane_width_input
				1'h0, // rd_xip_addr_width_input
				3'h2, // rd_dummy_clock_cycles_input
				3'h3, // flash_map_en_rd_access_cmd_input
				//Others
				32'h00010000,  // direct_flash_address
				32'h40, // number_of_direct_write
				32'h40, // number_of_direct_read
				1'h1,   // single0/burst1 transaction
				1'h0    // enable xip mode
				);
			end
		    if (test == 32'd12) begin
			    $display("# ---INFO : @%0dns :: Test Name : direct_access_test 12", $time);
			    direct_write_read_access(
				// Write Operation : Page Program 4-4-4 3-byte address 256-bytes SPI Mode
				2'h2, // wr_dat_lane_width
				2'h2, // wr_addr_lane_width_input
				2'h2, // wr_cmd_lane_width_input
				1'h0, // wr_xip_addr_width_input
				3'h0, // wr_dummy_clock_cycles_input
				3'h0, // flash_map_en_wr_access_cmd_input
				// Read Operation : Quad Output Fast Read 1-1-4 3-byte address 256-bytes
				2'h2, // rd_dat_lane_width_input
				2'h0, // rd_addr_lane_width_input
				2'h0, // rd_cmd_lane_width_input
				1'h0, // rd_xip_addr_width_input
				3'h4, // rd_dummy_clock_cycles_input
				3'h4, // flash_map_en_rd_access_cmd_input
				//Others
				32'h00010000,  // direct_flash_address
				32'h40, // number_of_direct_write
				32'h40, // number_of_direct_read
				1'h1,   // single0/burst1 transaction
				1'h0    // enable xip mode
				);
			end
		    if (test == 32'd13) begin
			    $display("# ---INFO : @%0dns :: Test Name : direct_access_test 13", $time);
			    direct_write_read_access(
				// Write Operation : Page Program 1-4-4 3-byte address 256-bytes SPI Mode
				2'h2, // wr_dat_lane_width
				2'h2, // wr_addr_lane_width_input
				2'h0, // wr_cmd_lane_width_input
				1'h0, // wr_xip_addr_width_input
				3'h0, // wr_dummy_clock_cycles_input
				3'h4, // flash_map_en_wr_access_cmd_input
				// Read Operation : Quad Input/Output Fast Read 1-4-4 3-byte address 256-bytes
				2'h2, // rd_dat_lane_width_input
				2'h2, // rd_addr_lane_width_input
				2'h0, // rd_cmd_lane_width_input
				1'h0, // rd_xip_addr_width_input
				3'h3, // rd_dummy_clock_cycles_input
				3'h5, // flash_map_en_rd_access_cmd_input
				//Others
				32'h00010000,  // direct_flash_address
				32'h40, // number_of_direct_write
				32'h40, // number_of_direct_read
				1'h1,   // single0/burst1 transaction
				1'h0    // enable xip mode
				);
			end
			if (test == 32'd14) begin
			    $display("# ---INFO : @%0dns :: Test Name : direct_access_test 14", $time);
			    direct_write_read_access(
				// Write Operation : Page Program 1-4-4 3-byte address 256-bytes SPI Mode
				2'h2, // wr_dat_lane_width
				2'h2, // wr_addr_lane_width_input
				2'h0, // wr_cmd_lane_width_input
				1'h0, // wr_xip_addr_width_input
				3'h0, // wr_dummy_clock_cycles_input
				3'h4, // flash_map_en_wr_access_cmd_input
				// Read Operation : Quad Input/Output Fast Read 4-4-4 3-byte address 256-bytes
				2'h2, // rd_dat_lane_width_input
				2'h2, // rd_addr_lane_width_input
				2'h2, // rd_cmd_lane_width_input
				1'h0, // rd_xip_addr_width_input
				3'h3, // rd_dummy_clock_cycles_input
				3'h5, // flash_map_en_rd_access_cmd_input
				//Others
				32'h00010000,  // direct_flash_address
				32'h40, // number_of_direct_write
				32'h40, // number_of_direct_read
				1'h1,   // single0/burst1 transaction
				1'h0    // enable xip mode
				);
			end
		    // Test 15 : Direct Access - XiP Mode Single Transaction
			if (test == 32'd15) begin
			    $display("# ---INFO : @%0dns :: Test Name : direct_access_test 15", $time);
			    direct_write_read_access(
				// Write Operation : Page Program 1-4-4 3-byte address 256-bytes SPI Mode
				2'h2, // wr_dat_lane_width
				2'h2, // wr_addr_lane_width_input
				2'h0, // wr_cmd_lane_width_input
				1'h0, // wr_xip_addr_width_input
				3'h0, // wr_dummy_clock_cycles_input
				3'h4, // flash_map_en_wr_access_cmd_input
				// Read Operation : Quad Input/Output Fast Read 1-4-4 3-byte address 256-bytes
				2'h2, // rd_dat_lane_width_input
				2'h2, // rd_addr_lane_width_input
				2'h0, // rd_cmd_lane_width_input
				1'h0, // rd_xip_addr_width_input
				3'h3, // rd_dummy_clock_cycles_input
				3'h5, // flash_map_en_rd_access_cmd_input
				//Others
				32'h00010000,  // direct_flash_address
				32'h40, // number_of_direct_write
				32'h40, // number_of_direct_read
				1'h0,   // single0/burst1 transaction
				1'h1    // enable xip mode
				);
		    end		    
			// Test 16 : Direct Access - XiP Mode Burst Transaction
			if (test == 32'd16) begin
			    $display("# ---INFO : @%0dns :: Test Name : direct_access_test 16", $time);
			    direct_write_read_access(
				// Write Operation : Page Program 1-4-4 3-byte address 256-bytes SPI Mode
				2'h2, // wr_dat_lane_width
				2'h2, // wr_addr_lane_width_input
				2'h0, // wr_cmd_lane_width_input
				1'h0, // wr_xip_addr_width_input
				3'h0, // wr_dummy_clock_cycles_input
				3'h4, // flash_map_en_wr_access_cmd_input
				// Read Operation : Quad Input/Output Fast Read 1-4-4 3-byte address 256-bytes
				2'h2, // rd_dat_lane_width_input
				2'h2, // rd_addr_lane_width_input
				2'h0, // rd_cmd_lane_width_input
				1'h0, // rd_xip_addr_width_input
				3'h3, // rd_dummy_clock_cycles_input
				3'h5, // flash_map_en_rd_access_cmd_input
				//Others
				32'h00010000,  // direct_flash_address
				32'h40, // number_of_direct_write
				32'h40, // number_of_direct_read
				1'h1,   // single0/burst1 transaction
				1'h1    // enable xip mode
				);
		    end
		end
	endtask
	
	task standard_spi_direct_access_test_mx;
	    begin
		    direct_access_main_mx(1);
		    direct_access_main_mx(2);
			if (INTERFACE == 0) begin
		        direct_access_main_mx(8);
		        direct_access_main_mx(9);
			end
		end
	endtask
	
	task dual_spi_direct_access_test_mx;
	    begin
		    direct_access_main_mx(3);
		    direct_access_main_mx(4);
			if (INTERFACE == 0) begin
		        direct_access_main_mx(10);
		        direct_access_main_mx(11);
			end
		end
	endtask
	
	task quad_spi_direct_access_test_mx;
	    begin
		    direct_access_main_mx(5);
		    direct_access_main_mx(6);
			if (INTERFACE == 0) begin
		        direct_access_main_mx(7);
		        direct_access_main_mx(12);
		        direct_access_main_mx(13);
		        direct_access_main_mx(14);
		        //direct_access_main_mx(15); // XiP test -> sequence not yet updated
		        //direct_access_main_mx(16); // XiP test -> sequence not yet updated
		    end
		end
	endtask
	
	task read_id_main_mx;
	    input [31:0] test;
	    begin
		    if (test == 32'd1) begin
			    $display("# ---INFO : @%0dns :: Test Name : supported_commands_test_send_command_and_read_data 1", $time);
				// Read Identification - Standard SPI Only 9Fh
				supported_commands_test_send_command_and_read_data(
				    16'h3, // xfer_len_bytes_input
					1'h0,  // multiple_flash_target_input
					5'h04, // flash_cmd_code_input
					8'h0,  // num_wait_state_input
					3'h0,  // flash_addr_width_input
					5'h0,  // tgt_cs_input
					2'h0,  // data_lane_width_input
					2'h0,  // addr_lane_width_input
					2'h0,  // cmd_lane_width_input
					32'h0  // flash_addr_input 
				);
			end
		    if (test == 32'd2) begin
			    $display("# ---INFO : @%0dns :: Test Name : supported_commands_test_send_command_and_read_data 2", $time);
				// Read Electronic Signature - Standard SPI ABh
				supported_commands_test_send_command_and_read_data(
				    16'h1, // xfer_len_bytes_input
					1'h0,  // multiple_flash_target_input
					5'h05, // flash_cmd_code_input
					8'h18,  // num_wait_state_input
					3'h0,  // flash_addr_width_input
					5'h0,  // tgt_cs_input
					2'h0,  // data_lane_width_input
					2'h0,  // addr_lane_width_input
					2'h0,  // cmd_lane_width_input
					32'h0  // flash_addr_input 
				);
			end
			if (test == 32'd3) begin
			    $display("# ---INFO : @%0dns :: Test Name : supported_commands_test_send_command_and_read_data 3", $time);
				// Read Electronic Signature - Quad SPI ABh
				supported_commands_test_send_command_and_read_data(
				    16'h1, // xfer_len_bytes_input
					1'h0,  // multiple_flash_target_input
					5'h05, // flash_cmd_code_input
					8'h6,  // num_wait_state_input
					3'h0,  // flash_addr_width_input
					5'h0,  // tgt_cs_input
					2'h2,  // data_lane_width_input
					2'h2,  // addr_lane_width_input
					2'h2,  // cmd_lane_width_input
					32'h0  // flash_addr_input 
				);
			end
		    if (test == 32'd4) begin
			    $display("# ---INFO : @%0dns :: Test Name : supported_commands_test_send_command_and_read_data 4", $time);
				// Read Electronic Manufacturer ID and Device ID - Standard SPI Only 90h
				supported_commands_test_send_command_and_read_data(
				    16'h2, // xfer_len_bytes_input
					1'h0,  // multiple_flash_target_input
					5'h07, // flash_cmd_code_input
					8'h0,  // num_wait_state_input
					3'h2,  // flash_addr_width_input // 2 bytes dummy and 1 byte 00h address
					5'h0,  // tgt_cs_input
					2'h0,  // data_lane_width_input
					2'h0,  // addr_lane_width_input
					2'h0,  // cmd_lane_width_input
					32'h0  // flash_addr_input // can be 01h or 00h
				);
			end
		    if (test == 32'd5) begin
			    $display("# ---INFO : @%0dns :: Test Name : supported_commands_test_send_command_and_read_data 5", $time);
				// Read Electronic Manufacturer ID and Device ID - Quad SPI AFh
				supported_commands_test_send_command_and_read_data(
				    16'h3, // xfer_len_bytes_input
					1'h0,  // multiple_flash_target_input
					5'h06, // flash_cmd_code_input
					8'h0,  // num_wait_state_input
					3'h0,  // flash_addr_width_input
					5'h0,  // tgt_cs_input
					2'h2,  // data_lane_width_input
					2'h2,  // addr_lane_width_input
					2'h2,  // cmd_lane_width_input
					32'h0  // flash_addr_input // can be 01h or 00h
				);
			end
			if (test == 32'd6) begin
			    $display("# ---INFO : @%0dns :: Test Name : supported_commands_test_send_command_and_read_data 6", $time);
				// Read Electronic Manufacturer ID and Device ID - Standard SPI Only 90h
				supported_commands_test_send_command_and_read_data(
				    16'h2, // xfer_len_bytes_input
					1'h0,  // multiple_flash_target_input
					5'h07, // flash_cmd_code_input
					8'h18,  // num_wait_state_input
					3'h0,  // flash_addr_width_input
					5'h0,  // tgt_cs_input
					2'h0,  // data_lane_width_input
					2'h0,  // addr_lane_width_input
					2'h0,  // cmd_lane_width_input
					32'h0  // flash_addr_input // can be 01h or 00h
				);
			end
		end
	endtask

	task standard_spi_read_id_test_mx;
	    begin
		    read_id_main_mx(1);
	        read_id_main_mx(2);
	        read_id_main_mx(4);
	        read_id_main_mx(6);
		end
	endtask	

	task quad_spi_read_id_test_mx;
	    begin
		    read_id_main_mx(3);
	        read_id_main_mx(5);
		end
	endtask	
	
	
	// Winbond Flash testing
	task erase_write_read_test_supported_commands_main_wb;
	    input [31:0] test;
	    begin
		// All program and read Winbond commands are used on below tests
		
		// Test 1 - 6 : 3-byte address, any erase - 256-bytes write - 256-bytes read
		    // Test 1
		    if (test == 32'd1) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 1", $time);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 4KB sector erase 1-1-1 3-byte address mode
		        	2'b00,        // erase_test_input 
		        	3'b010,       // erase_flash_addr_width_input
		        	2'b00,        // erase_data_lane_width_input
		        	2'b00,        // erase_addr_lane_width_input
		        	2'b00,        // erase_cmd_lane_width_input
		        	32'h00010000, // flash address
					1'h1,         // multiple_flash_target
					5'h01,        // tgt_cs
		        	// Write Operation : Page Program 1-1-1 3-byte address 256-bytes
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h0,         // page_prog_operation_input
		        	3'b010,       // prog_flash_addr_width_input
		        	2'b00,        // prog_data_lane_width_input
		        	2'b00,        // prog_addr_lane_width_input
		        	2'b00,        // prog_cmd_lane_width_input
		        	// Read Operation : Read Data 1-1-1 3-byte address 256-bytes
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b000,       // read_operation_input
		        	8'h0,         // num_wait_state_input
		        	3'b010,       // rd_flash_addr_width_input
		        	2'b00,        // rd_data_lane_width_input
		        	2'b00,        // rd_addr_lane_width_input
		        	2'b00,        // rd_cmd_lane_width_input
					2'b00         // Write Read Sequence
		        );
		    end
		    // Test 2
		    if (test == 32'd2) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 2", $time);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 4KB sector erase 1-1-1 3-byte address mode
		        	2'b00,        // erase_test_input 
		        	3'b010,       // erase_flash_addr_width_input
		        	2'b00,        // erase_data_lane_width_input
		        	2'b00,        // erase_addr_lane_width_input
		        	2'b00,        // erase_cmd_lane_width_input
		        	32'h00010000, // flash address
					1'h1,         // multiple_flash_target
					5'h01,        // tgt_cs
		        	// Write Operation : Page Program 1-1-1 3-byte address 256-bytes
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h0,         // page_prog_operation_input
		        	3'b010,       // prog_flash_addr_width_input
		        	2'b00,        // prog_data_lane_width_input
		        	2'b00,        // prog_addr_lane_width_input
		        	2'b00,        // prog_cmd_lane_width_input
		        	// Read Operation : Fast Read Data 1-1-1 3-byte address 256-bytes
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b001,       // read_operation_input
		        	8'h8,         // num_wait_state_input
		        	3'b010,       // rd_flash_addr_width_input
		        	2'b00,        // rd_data_lane_width_input
		        	2'b00,        // rd_addr_lane_width_input
		        	2'b00,        // rd_cmd_lane_width_input
					2'b00         // Write Read Sequence
		        );
		    end
		    // Test 3
			if (test == 32'd3) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 3", $time);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 32KB sector erase 1-1-1 3-byte address mode
		        	2'b01,        // erase_test_input 
		        	3'b010,       // erase_flash_addr_width_input
		        	2'b00,        // erase_data_lane_width_input
		        	2'b00,        // erase_addr_lane_width_input
		        	2'b00,        // erase_cmd_lane_width_input
		        	32'h00010000, // flash address
					1'h1,         // multiple_flash_target
					5'h01,        // tgt_cs
		        	// Write Operation : Page Program 1-1-1 3-byte address 256-bytes
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h0,         // page_prog_operation_input
		        	3'b010,       // prog_flash_addr_width_input
		        	2'b00,        // prog_data_lane_width_input
		        	2'b00,        // prog_addr_lane_width_input
		        	2'b00,        // prog_cmd_lane_width_input
		        	// Read Operation : Fast Read Dual Output 1-1-2 3-byte address 32KB read
		        	//16'h8000,     // rd_xfer_len_bytes_input
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b010,       // read_operation_input
		        	8'h8,         // num_wait_state_input
		        	3'b010,       // rd_flash_addr_width_input
		        	2'b01,        // rd_data_lane_width_input
		        	2'b00,        // rd_addr_lane_width_input
		        	2'b00,        // rd_cmd_lane_width_input
					2'b00         // Write Read Sequence
		        );
		    end
		    // Test 4
			if (test == 32'd4) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 4", $time);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 32KB sector erase 1-1-1 3-byte address mode
		        	2'b01,        // erase_test_input 
		        	3'b010,       // erase_flash_addr_width_input
		        	2'b00,        // erase_data_lane_width_input
		        	2'b00,        // erase_addr_lane_width_input
		        	2'b00,        // erase_cmd_lane_width_input
		        	32'h00010000, // flash address
					1'h1,         // multiple_flash_target
					5'h01,        // tgt_cs
		        	// Write Operation : Page Program 1-1-1 3-byte address 256-bytes
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h0,         // page_prog_operation_input
		        	3'b010,       // prog_flash_addr_width_input
		        	2'b00,        // prog_data_lane_width_input
		        	2'b00,        // prog_addr_lane_width_input
		        	2'b00,        // prog_cmd_lane_width_input
		        	// Read Operation : Fast Read Dual Input/Output 1-2-2 3-byte address 32KB read
		        	//16'h8000,     // rd_xfer_len_bytes_input
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b011,       // read_operation_input
		        	8'h4,         // num_wait_state_input
		        	3'b010,       // rd_flash_addr_width_input
		        	2'b01,        // rd_data_lane_width_input
		        	2'b01,        // rd_addr_lane_width_input
		        	2'b00,        // rd_cmd_lane_width_input
					2'b00         // Write Read Sequence
		        );
		    end
		    // Test 5
		    if (test == 32'd5) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 5", $time);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 32KB sector erase 1-1-1 3-byte address mode
		        	2'b01,        // erase_test_input 
		        	3'b010,       // erase_flash_addr_width_input
		        	2'b00,        // erase_data_lane_width_input
		        	2'b00,        // erase_addr_lane_width_input
		        	2'b00,        // erase_cmd_lane_width_input
		        	32'h00010000, // flash address
					1'h1,         // multiple_flash_target
					5'h01,        // tgt_cs
		        	// Write Operation : Quad Input Page Program 1-1-4 3-byte address 32KB write
		        	//16'h8000,     // prog_xfer_len_bytes_input
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h1,         // page_prog_operation_input
		        	3'b010,       // prog_flash_addr_width_input
		        	2'b10,        // prog_data_lane_width_input
		        	2'b00,        // prog_addr_lane_width_input
		        	2'b00,        // prog_cmd_lane_width_input
		        	// Read Operation : Fast Read Quad Output 1-1-4 3-byte address 32KB read
		        	//16'h8000,     // rd_xfer_len_bytes_input
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b100,       // read_operation_input
		        	8'h8,         // num_wait_state_input
		        	3'b010,       // rd_flash_addr_width_input
		        	2'b10,        // rd_data_lane_width_input
		        	2'b00,        // rd_addr_lane_width_input
		        	2'b00,        // rd_cmd_lane_width_input
					2'b00         // Write Read Sequence
		        );
		    end
		    // Test 6
			if (test == 32'd6) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 6", $time);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 32KB sector erase 1-1-1 3-byte address mode
		        	2'b01,        // erase_test_input 
		        	3'b010,       // erase_flash_addr_width_input
		        	2'b00,        // erase_data_lane_width_input
		        	2'b00,        // erase_addr_lane_width_input
		        	2'b00,        // erase_cmd_lane_width_input
		        	32'h00010000, // flash address
					1'h1,         // multiple_flash_target
					5'h01,        // tgt_cs
		        	// Write Operation : Quad Input Page Program 1-1-4 3-byte address 32KB write
		        	//16'h8000,     // prog_xfer_len_bytes_input
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h1,         // page_prog_operation_input
		        	3'b010,       // prog_flash_addr_width_input
		        	2'b10,        // prog_data_lane_width_input
		        	2'b00,        // prog_addr_lane_width_input
		        	2'b00,        // prog_cmd_lane_width_input
		        	// Read Operation : Fast Read Quad Input/Output 1-4-4 3-byte address 32KB read
		        	//16'h8000,     // rd_xfer_len_bytes_input
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b101,       // read_operation_input
		        	8'h6,         // num_wait_state_input
		        	3'b010,       // rd_flash_addr_width_input
		        	2'b10,        // rd_data_lane_width_input
		        	2'b10,        // rd_addr_lane_width_input
		        	2'b00,        // rd_cmd_lane_width_input
					2'b00         // Write Read Sequence
		        );
		    end
		// Test 7 - 12 : 4-byte address, any erase - 256-bytes write - 256-bytes read    
		    // Test 7
		    if (test == 32'd7) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 7", $time);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 4KB sector erase 1-1-1 4-byte address mode
		        	2'b00,        // erase_test_input 
		        	3'b011,       // erase_flash_addr_width_input
		        	2'b00,        // erase_data_lane_width_input
		        	2'b00,        // erase_addr_lane_width_input
		        	2'b00,        // erase_cmd_lane_width_input
		        	32'h00001000, // flash address
					1'h1,         // multiple_flash_target
					5'h01,        // tgt_cs
		        	// Write Operation : Page Program 1-1-1 4-byte address 256-bytes
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h0,         // page_prog_operation_input
		        	3'b011,       // prog_flash_addr_width_input
		        	2'b00,        // prog_data_lane_width_input
		        	2'b00,        // prog_addr_lane_width_input
		        	2'b00,        // prog_cmd_lane_width_input
		        	// Read Operation : Read Data 1-1-1 4-byte address 256-bytes
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b000,       // read_operation_input
		        	8'h0,         // num_wait_state_input
		        	3'b011,       // rd_flash_addr_width_input
		        	2'b00,        // rd_data_lane_width_input
		        	2'b00,        // rd_addr_lane_width_input
		        	2'b00,        // rd_cmd_lane_width_input
					2'b00         // Write Read Sequence
		        );
		    end
		    // Test 8
		    if (test == 32'd8) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 8", $time);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 4KB sector erase 1-1-1 4-byte address mode
		        	2'b00,        // erase_test_input 
		        	3'b011,       // erase_flash_addr_width_input
		        	2'b00,        // erase_data_lane_width_input
		        	2'b00,        // erase_addr_lane_width_input
		        	2'b00,        // erase_cmd_lane_width_input
		        	32'h00001000, // flash address
					1'h1,         // multiple_flash_target
					5'h01,        // tgt_cs
		        	// Write Operation : Page Program 1-1-1 4-byte address 256-bytes
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h0,         // page_prog_operation_input
		        	3'b011,       // prog_flash_addr_width_input
		        	2'b00,        // prog_data_lane_width_input
		        	2'b00,        // prog_addr_lane_width_input
		        	2'b00,        // prog_cmd_lane_width_input
		        	// Read Operation : Fast Read Data 1-1-1 4-byte address 256-bytes
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b001,       // read_operation_input
		        	8'h8,         // num_wait_state_input
		        	3'b011,       // rd_flash_addr_width_input
		        	2'b00,        // rd_data_lane_width_input
		        	2'b00,        // rd_addr_lane_width_input
		        	2'b00,        // rd_cmd_lane_width_input
					2'b00         // Write Read Sequence
		        );
		    end
		    // Test 9
			if (test == 32'd9) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 9", $time);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 32KB sector erase 1-1-1 4-byte address mode
		        	2'b10,        // erase_test_input 
		        	3'b011,       // erase_flash_addr_width_input
		        	2'b00,        // erase_data_lane_width_input
		        	2'b00,        // erase_addr_lane_width_input
		        	2'b00,        // erase_cmd_lane_width_input
		        	32'h003E8000, // flash address
					1'h1,         // multiple_flash_target
					5'h01,        // tgt_cs
		        	// Write Operation : Page Program 1-1-1 4-byte address 256-bytes
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h0,         // page_prog_operation_input
		        	3'b011,       // prog_flash_addr_width_input
		        	2'b00,        // prog_data_lane_width_input
		        	2'b00,        // prog_addr_lane_width_input
		        	2'b00,        // prog_cmd_lane_width_input
		        	// Read Operation : Fast Read Dual Output 1-1-2 4-byte address 32KB read
		        	//16'h8000,     // rd_xfer_len_bytes_input
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b010,       // read_operation_input
		        	8'h8,         // num_wait_state_input
		        	3'b011,       // rd_flash_addr_width_input
		        	2'b01,        // rd_data_lane_width_input
		        	2'b00,        // rd_addr_lane_width_input
		        	2'b00,        // rd_cmd_lane_width_input
					2'b00         // Write Read Sequence
		        );
		    end
		    // Test 10
			if (test == 32'd10) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 10", $time);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 32KB sector erase 1-1-1 4-byte address mode
		        	2'b10,        // erase_test_input 
		        	3'b011,       // erase_flash_addr_width_input
		        	2'b00,        // erase_data_lane_width_input
		        	2'b00,        // erase_addr_lane_width_input
		        	2'b00,        // erase_cmd_lane_width_input
		        	32'h003E8000, // flash address
					1'h1,         // multiple_flash_target
					5'h01,        // tgt_cs
		        	// Write Operation : Page Program 1-1-1 4-byte address 256-bytes
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h0,         // page_prog_operation_input
		        	3'b011,       // prog_flash_addr_width_input
		        	2'b00,        // prog_data_lane_width_input
		        	2'b00,        // prog_addr_lane_width_input
		        	2'b00,        // prog_cmd_lane_width_input
		        	// Read Operation : Fast Read Dual Input/Output 1-2-2 4-byte address 32KB read
		        	//16'h8000,     // rd_xfer_len_bytes_input
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b011,       // read_operation_input
		        	8'h4,         // num_wait_state_input
		        	3'b011,       // rd_flash_addr_width_input
		        	2'b01,        // rd_data_lane_width_input
		        	2'b01,        // rd_addr_lane_width_input
		        	2'b00,        // rd_cmd_lane_width_input
					2'b00         // Write Read Sequence
		        );
		    end
		    // Test 11
		    if (test == 32'd11) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 11", $time);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 32KB sector erase 1-1-1 4-byte address mode
		        	2'b10,        // erase_test_input 
		        	3'b011,       // erase_flash_addr_width_input
		        	2'b00,        // erase_data_lane_width_input
		        	2'b00,        // erase_addr_lane_width_input
		        	2'b00,        // erase_cmd_lane_width_input
		        	32'h003E8000, // flash address
					1'h1,         // multiple_flash_target
					5'h01,        // tgt_cs
		        	// Write Operation : Quad Input Page Program 1-1-4 4-byte address 32KB write
		        	//16'h8000,     // prog_xfer_len_bytes_input
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h1,         // page_prog_operation_input
		        	3'b011,       // prog_flash_addr_width_input
		        	2'b10,        // prog_data_lane_width_input
		        	2'b00,        // prog_addr_lane_width_input
		        	2'b00,        // prog_cmd_lane_width_input
		        	// Read Operation : Fast Read Quad Output 1-1-4 4-byte address 32KB read
		        	//16'h8000,     // rd_xfer_len_bytes_input
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b100,       // read_operation_input
		        	8'h8,         // num_wait_state_input
		        	3'b011,       // rd_flash_addr_width_input
		        	2'b10,        // rd_data_lane_width_input
		        	2'b00,        // rd_addr_lane_width_input
		        	2'b00,        // rd_cmd_lane_width_input
					2'b00         // Write Read Sequence
		        );
		    end
		    // Test 12
			if (test == 32'd12) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 12", $time);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 32KB sector erase 1-1-1 4-byte address mode
		        	2'b10,        // erase_test_input 
		        	3'b011,       // erase_flash_addr_width_input
		        	2'b00,        // erase_data_lane_width_input
		        	2'b00,        // erase_addr_lane_width_input
		        	2'b00,        // erase_cmd_lane_width_input
		        	32'h003E8000, // flash address
					1'h1,         // multiple_flash_target
					5'h01,        // tgt_cs
		        	// Write Operation : Quad Input Page Program 1-1-4 4-byte address 32KB write
		        	//16'h8000,     // prog_xfer_len_bytes_input
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h1,         // page_prog_operation_input
		        	3'b011,       // prog_flash_addr_width_input
		        	2'b10,        // prog_data_lane_width_input
		        	2'b00,        // prog_addr_lane_width_input
		        	2'b00,        // prog_cmd_lane_width_input
		        	// Read Operation : Fast Read Quad Input/Output 1-4-4 4-byte address 32KB read
		        	//16'h8000,     // rd_xfer_len_bytes_input
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b101,       // read_operation_input
		        	8'h6,         // num_wait_state_input
		        	3'b011,       // rd_flash_addr_width_input
		        	2'b10,        // rd_data_lane_width_input
		        	2'b10,        // rd_addr_lane_width_input
		        	2'b00,        // rd_cmd_lane_width_input
					2'b00         // Write Read Sequence
		        );
		    end
		// Test 13 - 18 : 3-byte address, any erase - multiple 256-bytes write - single read
		    // Test 13
		    if (test == 32'd13) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 13", $time);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 4KB sector erase 1-1-1 3-byte address mode
		        	2'b00,        // erase_test_input 
		        	3'b010,       // erase_flash_addr_width_input
		        	2'b00,        // erase_data_lane_width_input
		        	2'b00,        // erase_addr_lane_width_input
		        	2'b00,        // erase_cmd_lane_width_input
		        	32'h00100000, // flash address
					1'h1,         // multiple_flash_target
					5'h01,        // tgt_cs
		        	// Write Operation : Page Program 1-1-1 3-byte address 256-bytes
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h0,         // page_prog_operation_input
		        	3'b010,       // prog_flash_addr_width_input
		        	2'b00,        // prog_data_lane_width_input
		        	2'b00,        // prog_addr_lane_width_input
		        	2'b00,        // prog_cmd_lane_width_input
		        	// Read Operation : Read Data 1-1-1 3-byte address 256-bytes
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b000,       // read_operation_input
		        	8'h0,         // num_wait_state_input
		        	3'b010,       // rd_flash_addr_width_input
		        	2'b00,        // rd_data_lane_width_input
		        	2'b00,        // rd_addr_lane_width_input
		        	2'b00,        // rd_cmd_lane_width_input
					2'b01         // Write Read Sequence
					        
		        );
		    end
			// Test 14
		    if (test == 32'd14) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 14", $time);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 4KB sector erase 1-1-1 3-byte address mode
		        	2'b00,        // erase_test_input 
		        	3'b010,       // erase_flash_addr_width_input
		        	2'b00,        // erase_data_lane_width_input
		        	2'b00,        // erase_addr_lane_width_input
		        	2'b00,        // erase_cmd_lane_width_input
		        	32'h00100000, // flash address
					1'h1,         // multiple_flash_target
					5'h01,        // tgt_cs
		        	// Write Operation : Page Program 1-1-1 3-byte address 256-bytes
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h0,         // page_prog_operation_input
		        	3'b010,       // prog_flash_addr_width_input
		        	2'b00,        // prog_data_lane_width_input
		        	2'b00,        // prog_addr_lane_width_input
		        	2'b00,        // prog_cmd_lane_width_input
		        	// Read Operation : Fast Read Data 1-1-1 3-byte address 256-bytes
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b001,       // read_operation_input
		        	8'h8,         // num_wait_state_input
		        	3'b010,       // rd_flash_addr_width_input
		        	2'b00,        // rd_data_lane_width_input
		        	2'b00,        // rd_addr_lane_width_input
		        	2'b00,        // rd_cmd_lane_width_input
					2'b01         // Write Read Sequence
		        );
		    end
		    // Test 15
			if (test == 32'd15) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 15", $time);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 4KB sector erase 1-1-1 3-byte address mode
		        	2'b00,        // erase_test_input 
		        	3'b010,       // erase_flash_addr_width_input
		        	2'b00,        // erase_data_lane_width_input
		        	2'b00,        // erase_addr_lane_width_input
		        	2'b00,        // erase_cmd_lane_width_input
		        	32'h00100000, // flash address
					1'h1,         // multiple_flash_target
					5'h01,        // tgt_cs
		        	// Write Operation : Page Program 1-1-1 3-byte address 256-bytes
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h0,         // page_prog_operation_input
		        	3'b010,       // prog_flash_addr_width_input
		        	2'b00,        // prog_data_lane_width_input
		        	2'b00,        // prog_addr_lane_width_input
		        	2'b00,        // prog_cmd_lane_width_input
		        	// Read Operation : Fast Read Dual Output 1-1-2 3-byte address 32KB read
		        	//16'h8000,     // rd_xfer_len_bytes_input
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b010,       // read_operation_input
		        	8'h8,         // num_wait_state_input
		        	3'b010,       // rd_flash_addr_width_input
		        	2'b01,        // rd_data_lane_width_input
		        	2'b00,        // rd_addr_lane_width_input
		        	2'b00,        // rd_cmd_lane_width_input
					2'b01         // Write Read Sequence
		        );
		    end
		    // Test 16
			if (test == 32'd16) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 16", $time);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 4KB sector erase 1-1-1 3-byte address mode
		        	2'b00,        // erase_test_input 
		        	3'b010,       // erase_flash_addr_width_input
		        	2'b00,        // erase_data_lane_width_input
		        	2'b00,        // erase_addr_lane_width_input
		        	2'b00,        // erase_cmd_lane_width_input
		        	32'h00100000, // flash address
					1'h1,         // multiple_flash_target
					5'h01,        // tgt_cs
		        	// Write Operation : Page Program 1-1-1 3-byte address 256-bytes
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h0,         // page_prog_operation_input
		        	3'b010,       // prog_flash_addr_width_input
		        	2'b00,        // prog_data_lane_width_input
		        	2'b00,        // prog_addr_lane_width_input
		        	2'b00,        // prog_cmd_lane_width_input
		        	// Read Operation : Fast Read Dual Input/Output 1-2-2 3-byte address 32KB read
		        	//16'h8000,     // rd_xfer_len_bytes_input
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b011,       // read_operation_input
		        	8'h4,         // num_wait_state_input
		        	3'b010,       // rd_flash_addr_width_input
		        	2'b01,        // rd_data_lane_width_input
		        	2'b01,        // rd_addr_lane_width_input
		        	2'b00,        // rd_cmd_lane_width_input
					2'b01         // Write Read Sequence
		        );
		    end
		    // Test 17
		    if (test == 32'd17) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 17", $time);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 4KB sector erase 1-1-1 3-byte address mode
		        	2'b00,        // erase_test_input 
		        	3'b010,       // erase_flash_addr_width_input
		        	2'b00,        // erase_data_lane_width_input
		        	2'b00,        // erase_addr_lane_width_input
		        	2'b00,        // erase_cmd_lane_width_input
		        	32'h00100000, // flash address
					1'h1,         // multiple_flash_target
					5'h01,        // tgt_cs
		        	// Write Operation : Quad Input Page Program 1-1-4 3-byte address 32KB write
		        	//16'h8000,     // prog_xfer_len_bytes_input
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h1,         // page_prog_operation_input
		        	3'b010,       // prog_flash_addr_width_input
		        	2'b10,        // prog_data_lane_width_input
		        	2'b00,        // prog_addr_lane_width_input
		        	2'b00,        // prog_cmd_lane_width_input
		        	// Read Operation : Fast Read Quad Output 1-1-4 3-byte address 32KB read
		        	//16'h8000,     // rd_xfer_len_bytes_input
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b100,       // read_operation_input
		        	8'h8,         // num_wait_state_input
		        	3'b010,       // rd_flash_addr_width_input
		        	2'b10,        // rd_data_lane_width_input
		        	2'b00,        // rd_addr_lane_width_input
		        	2'b00,        // rd_cmd_lane_width_input
					2'b01         // Write Read Sequence
		        );
		    end
		    // Test 18
			if (test == 32'd18) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 18", $time);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 4KB sector erase 1-1-1 3-byte address mode
		        	2'b00,        // erase_test_input 
		        	3'b010,       // erase_flash_addr_width_input
		        	2'b00,        // erase_data_lane_width_input
		        	2'b00,        // erase_addr_lane_width_input
		        	2'b00,        // erase_cmd_lane_width_input
		        	32'h00100000, // flash address
					1'h1,         // multiple_flash_target
					5'h01,        // tgt_cs
		        	// Write Operation : Quad Input Page Program 1-1-4 3-byte address 32KB write
		        	//16'h8000,     // prog_xfer_len_bytes_input
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h1,         // page_prog_operation_input
		        	3'b010,       // prog_flash_addr_width_input
		        	2'b10,        // prog_data_lane_width_input
		        	2'b00,        // prog_addr_lane_width_input
		        	2'b00,        // prog_cmd_lane_width_input
		        	// Read Operation : Fast Read Quad Input/Output 1-4-4 3-byte address 32KB read
		        	//16'h8000,     // rd_xfer_len_bytes_input
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b101,       // read_operation_input
		        	8'h6,         // num_wait_state_input
		        	3'b010,       // rd_flash_addr_width_input
		        	2'b10,        // rd_data_lane_width_input
		        	2'b10,        // rd_addr_lane_width_input
		        	2'b00,        // rd_cmd_lane_width_input
					2'b01         // Write Read Sequence
		        );
		    end
		// Test 19 - 24: 3-byte address, any erase - multiple (256-bytes write - 256-bytes read)			
		    // Test 19
			if (test == 32'd19) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 19", $time);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 4KB sector erase 1-1-1 3-byte address mode
		        	2'b00,        // erase_test_input 
		        	3'b010,       // erase_flash_addr_width_input
		        	2'b00,        // erase_data_lane_width_input
		        	2'b00,        // erase_addr_lane_width_input
		        	2'b00,        // erase_cmd_lane_width_input
		        	32'h00100000, // flash address
					1'h1,         // multiple_flash_target
					5'h01,        // tgt_cs
		        	// Write Operation : Page Program 1-1-1 3-byte address 256-bytes
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h0,         // page_prog_operation_input
		        	3'b010,       // prog_flash_addr_width_input
		        	2'b00,        // prog_data_lane_width_input
		        	2'b00,        // prog_addr_lane_width_input
		        	2'b00,        // prog_cmd_lane_width_input
		        	// Read Operation : Read Data 1-1-1 3-byte address 256-bytes
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b000,       // read_operation_input
		        	8'h0,         // num_wait_state_input
		        	3'b010,       // rd_flash_addr_width_input
		        	2'b00,        // rd_data_lane_width_input
		        	2'b00,        // rd_addr_lane_width_input
		        	2'b00,        // rd_cmd_lane_width_input
					2'b10         // Write Read Sequence
		        );
		    end
			// Test 20
		    if (test == 32'd20) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 20", $time);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 4KB sector erase 1-1-1 3-byte address mode
		        	2'b00,        // erase_test_input 
		        	3'b010,       // erase_flash_addr_width_input
		        	2'b00,        // erase_data_lane_width_input
		        	2'b00,        // erase_addr_lane_width_input
		        	2'b00,        // erase_cmd_lane_width_input
		        	32'h00100000, // flash address
					1'h1,         // multiple_flash_target
					5'h01,        // tgt_cs
		        	// Write Operation : Page Program 1-1-1 3-byte address 256-bytes
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h0,         // page_prog_operation_input
		        	3'b010,       // prog_flash_addr_width_input
		        	2'b00,        // prog_data_lane_width_input
		        	2'b00,        // prog_addr_lane_width_input
		        	2'b00,        // prog_cmd_lane_width_input
		        	// Read Operation : Fast Read Data 1-1-1 3-byte address 256-bytes
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b001,       // read_operation_input
		        	8'h8,         // num_wait_state_input
		        	3'b010,       // rd_flash_addr_width_input
		        	2'b00,        // rd_data_lane_width_input
		        	2'b00,        // rd_addr_lane_width_input
		        	2'b00,        // rd_cmd_lane_width_input
					2'b10         // Write Read Sequence
		        );
		    end
		    // Test 21
			if (test == 32'd21) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 21", $time);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 4KB sector erase 1-1-1 3-byte address mode
		        	2'b00,        // erase_test_input 
		        	3'b010,       // erase_flash_addr_width_input
		        	2'b00,        // erase_data_lane_width_input
		        	2'b00,        // erase_addr_lane_width_input
		        	2'b00,        // erase_cmd_lane_width_input
		        	32'h00100000, // flash address
					1'h1,         // multiple_flash_target
					5'h01,        // tgt_cs
		        	// Write Operation : Page Program 1-1-1 3-byte address 256-bytes
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h0,         // page_prog_operation_input
		        	3'b010,       // prog_flash_addr_width_input
		        	2'b00,        // prog_data_lane_width_input
		        	2'b00,        // prog_addr_lane_width_input
		        	2'b00,        // prog_cmd_lane_width_input
		        	// Read Operation : Fast Read Dual Output 1-1-2 3-byte address 32KB read
		        	//16'h8000,     // rd_xfer_len_bytes_input
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b010,       // read_operation_input
		        	8'h8,         // num_wait_state_input
		        	3'b010,       // rd_flash_addr_width_input
		        	2'b01,        // rd_data_lane_width_input
		        	2'b00,        // rd_addr_lane_width_input
		        	2'b00,        // rd_cmd_lane_width_input
					2'b10         // Write Read Sequence
		        );
		    end
		    // Test 22
			if (test == 32'd22) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 22", $time);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 4KB sector erase 1-1-1 3-byte address mode
		        	2'b00,        // erase_test_input 
		        	3'b010,       // erase_flash_addr_width_input
		        	2'b00,        // erase_data_lane_width_input
		        	2'b00,        // erase_addr_lane_width_input
		        	2'b00,        // erase_cmd_lane_width_input
		        	32'h00100000, // flash address
					1'h1,         // multiple_flash_target
					5'h01,        // tgt_cs
		        	// Write Operation : Page Program 1-1-1 3-byte address 256-bytes
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h0,         // page_prog_operation_input
		        	3'b010,       // prog_flash_addr_width_input
		        	2'b00,        // prog_data_lane_width_input
		        	2'b00,        // prog_addr_lane_width_input
		        	2'b00,        // prog_cmd_lane_width_input
		        	// Read Operation : Fast Read Dual Input/Output 1-2-2 3-byte address 32KB read
		        	//16'h8000,     // rd_xfer_len_bytes_input
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b011,       // read_operation_input
		        	8'h4,         // num_wait_state_input
		        	3'b010,       // rd_flash_addr_width_input
		        	2'b01,        // rd_data_lane_width_input
		        	2'b01,        // rd_addr_lane_width_input
		        	2'b00,        // rd_cmd_lane_width_input
					2'b10         // Write Read Sequence
		        );
		    end
		    // Test 23
		    if (test == 32'd23) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 23", $time);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 4KB sector erase 1-1-1 3-byte address mode
		        	2'b00,        // erase_test_input 
		        	3'b010,       // erase_flash_addr_width_input
		        	2'b00,        // erase_data_lane_width_input
		        	2'b00,        // erase_addr_lane_width_input
		        	2'b00,        // erase_cmd_lane_width_input
		        	32'h00100000, // flash address
					1'h1,         // multiple_flash_target
					5'h01,        // tgt_cs
		        	// Write Operation : Quad Input Page Program 1-1-4 3-byte address 32KB write
		        	//16'h8000,     // prog_xfer_len_bytes_input
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h1,         // page_prog_operation_input
		        	3'b010,       // prog_flash_addr_width_input
		        	2'b10,        // prog_data_lane_width_input
		        	2'b00,        // prog_addr_lane_width_input
		        	2'b00,        // prog_cmd_lane_width_input
		        	// Read Operation : Fast Read Quad Output 1-1-4 3-byte address 32KB read
		        	//16'h8000,     // rd_xfer_len_bytes_input
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b100,       // read_operation_input
		        	8'h8,         // num_wait_state_input
		        	3'b010,       // rd_flash_addr_width_input
		        	2'b10,        // rd_data_lane_width_input
		        	2'b00,        // rd_addr_lane_width_input
		        	2'b00,        // rd_cmd_lane_width_input
					2'b10         // Write Read Sequence
		        );
		    end
		    // Test 24
			if (test == 32'd24) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 24", $time);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 4KB sector erase 1-1-1 3-byte address mode
		        	2'b00,        // erase_test_input 
		        	3'b010,       // erase_flash_addr_width_input
		        	2'b00,        // erase_data_lane_width_input
		        	2'b00,        // erase_addr_lane_width_input
		        	2'b00,        // erase_cmd_lane_width_input
		        	32'h00100000, // flash address
					1'h1,         // multiple_flash_target
					5'h01,        // tgt_cs
		        	// Write Operation : Quad Input Page Program 1-1-4 3-byte address 32KB write
		        	//16'h8000,     // prog_xfer_len_bytes_input
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h1,         // page_prog_operation_input
		        	3'b010,       // prog_flash_addr_width_input
		        	2'b10,        // prog_data_lane_width_input
		        	2'b00,        // prog_addr_lane_width_input
		        	2'b00,        // prog_cmd_lane_width_input
		        	// Read Operation : Fast Read Quad Input/Output 1-4-4 3-byte address 32KB read
		        	//16'h8000,     // rd_xfer_len_bytes_input
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b101,       // read_operation_input
		        	8'h6,         // num_wait_state_input
		        	3'b010,       // rd_flash_addr_width_input
		        	2'b10,        // rd_data_lane_width_input
		        	2'b10,        // rd_addr_lane_width_input
		        	2'b00,        // rd_cmd_lane_width_input
					2'b10         // Write Read Sequence
		        );
		    end
		// Test 25 - 30 : 4-byte address, any erase - multiple 256-bytes write - single read
		    // Test 25
		    if (test == 32'd25) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 25", $time);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 4KB sector erase 1-1-1 4-byte address mode
		        	2'b00,        // erase_test_input 
		        	3'b011,       // erase_flash_addr_width_input
		        	2'b00,        // erase_data_lane_width_input
		        	2'b00,        // erase_addr_lane_width_input
		        	2'b00,        // erase_cmd_lane_width_input
		        	32'h00001000, // flash address
					1'h1,         // multiple_flash_target
					5'h01,        // tgt_cs
		        	// Write Operation : Page Program 1-1-1 4-byte address 256-bytes
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h0,         // page_prog_operation_input
		        	3'b011,       // prog_flash_addr_width_input
		        	2'b00,        // prog_data_lane_width_input
		        	2'b00,        // prog_addr_lane_width_input
		        	2'b00,        // prog_cmd_lane_width_input
		        	// Read Operation : Read Data 1-1-1 4-byte address 256-bytes
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b000,       // read_operation_input
		        	8'h0,         // num_wait_state_input
		        	3'b011,       // rd_flash_addr_width_input
		        	2'b00,        // rd_data_lane_width_input
		        	2'b00,        // rd_addr_lane_width_input
		        	2'b00,        // rd_cmd_lane_width_input
					2'b01         // Write Read Sequence
		        );
		    end
		    // Test 26
		    if (test == 32'd26) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 26", $time);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 4KB sector erase 1-1-1 4-byte address mode
		        	2'b00,        // erase_test_input 
		        	3'b011,       // erase_flash_addr_width_input
		        	2'b00,        // erase_data_lane_width_input
		        	2'b00,        // erase_addr_lane_width_input
		        	2'b00,        // erase_cmd_lane_width_input
		        	32'h00001000, // flash address
					1'h1,         // multiple_flash_target
					5'h01,        // tgt_cs
		        	// Write Operation : Page Program 1-1-1 4-byte address 256-bytes
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h0,         // page_prog_operation_input
		        	3'b011,       // prog_flash_addr_width_input
		        	2'b00,        // prog_data_lane_width_input
		        	2'b00,        // prog_addr_lane_width_input
		        	2'b00,        // prog_cmd_lane_width_input
		        	// Read Operation : Fast Read Data 1-1-1 4-byte address 256-bytes
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b001,       // read_operation_input
		        	8'h8,         // num_wait_state_input
		        	3'b011,       // rd_flash_addr_width_input
		        	2'b00,        // rd_data_lane_width_input
		        	2'b00,        // rd_addr_lane_width_input
		        	2'b00,        // rd_cmd_lane_width_input
					2'b01         // Write Read Sequence
		        );
		    end
		    // Test 27
			if (test == 32'd27) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 27", $time);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 4KB sector erase 1-1-1 4-byte address mode
		        	2'b00,        // erase_test_input 
		        	3'b011,       // erase_flash_addr_width_input
		        	2'b00,        // erase_data_lane_width_input
		        	2'b00,        // erase_addr_lane_width_input
		        	2'b00,        // erase_cmd_lane_width_input
		        	32'h003E8000, // flash address
					1'h1,         // multiple_flash_target
					5'h01,        // tgt_cs
		        	// Write Operation : Page Program 1-1-1 4-byte address 256-bytes
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h0,         // page_prog_operation_input
		        	3'b011,       // prog_flash_addr_width_input
		        	2'b00,        // prog_data_lane_width_input
		        	2'b00,        // prog_addr_lane_width_input
		        	2'b00,        // prog_cmd_lane_width_input
		        	// Read Operation : Fast Read Dual Output 1-1-2 4-byte address 32KB read
		        	//16'h8000,     // rd_xfer_len_bytes_input
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b010,       // read_operation_input
		        	8'h8,         // num_wait_state_input
		        	3'b011,       // rd_flash_addr_width_input
		        	2'b01,        // rd_data_lane_width_input
		        	2'b00,        // rd_addr_lane_width_input
		        	2'b00,        // rd_cmd_lane_width_input
					2'b01         // Write Read Sequence
		        );
		    end
		    // Test 28
			if (test == 32'd28) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 28", $time);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 4KB sector erase 1-1-1 4-byte address mode
		        	2'b00,        // erase_test_input 
		        	3'b011,       // erase_flash_addr_width_input
		        	2'b00,        // erase_data_lane_width_input
		        	2'b00,        // erase_addr_lane_width_input
		        	2'b00,        // erase_cmd_lane_width_input
		        	32'h003E8000, // flash address
					1'h1,         // multiple_flash_target
					5'h01,        // tgt_cs
		        	// Write Operation : Page Program 1-1-1 4-byte address 256-bytes
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h0,         // page_prog_operation_input
		        	3'b011,       // prog_flash_addr_width_input
		        	2'b00,        // prog_data_lane_width_input
		        	2'b00,        // prog_addr_lane_width_input
		        	2'b00,        // prog_cmd_lane_width_input
		        	// Read Operation : Fast Read Dual Input/Output 1-2-2 4-byte address 32KB read
		        	//16'h8000,     // rd_xfer_len_bytes_input
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b011,       // read_operation_input
		        	8'h4,         // num_wait_state_input
		        	3'b011,       // rd_flash_addr_width_input
		        	2'b01,        // rd_data_lane_width_input
		        	2'b01,        // rd_addr_lane_width_input
		        	2'b00,        // rd_cmd_lane_width_input
					2'b01         // Write Read Sequence
		        );
		    end
		    // Test 29
		    if (test == 32'd29) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 29", $time);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 4KB sector erase 1-1-1 4-byte address mode
		        	2'b00,        // erase_test_input 
		        	3'b011,       // erase_flash_addr_width_input
		        	2'b00,        // erase_data_lane_width_input
		        	2'b00,        // erase_addr_lane_width_input
		        	2'b00,        // erase_cmd_lane_width_input
		        	32'h003E8000, // flash address
					1'h1,         // multiple_flash_target
					5'h01,        // tgt_cs
		        	// Write Operation : Quad Input Page Program 1-1-4 4-byte address 32KB write
		        	//16'h8000,     // prog_xfer_len_bytes_input
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h1,         // page_prog_operation_input
		        	3'b011,       // prog_flash_addr_width_input
		        	2'b10,        // prog_data_lane_width_input
		        	2'b00,        // prog_addr_lane_width_input
		        	2'b00,        // prog_cmd_lane_width_input
		        	// Read Operation : Fast Read Quad Output 1-1-4 4-byte address 32KB read
		        	//16'h8000,     // rd_xfer_len_bytes_input
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b100,       // read_operation_input
		        	8'h8,         // num_wait_state_input
		        	3'b011,       // rd_flash_addr_width_input
		        	2'b10,        // rd_data_lane_width_input
		        	2'b00,        // rd_addr_lane_width_input
		        	2'b00,        // rd_cmd_lane_width_input
					2'b01         // Write Read Sequence
		        );
		    end
		    // Test 30
			if (test == 32'd30) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 30", $time);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 4KB sector erase 1-1-1 4-byte address mode
		        	2'b00,        // erase_test_input 
		        	3'b011,       // erase_flash_addr_width_input
		        	2'b00,        // erase_data_lane_width_input
		        	2'b00,        // erase_addr_lane_width_input
		        	2'b00,        // erase_cmd_lane_width_input
		        	32'h003E8000, // flash address
					1'h1,         // multiple_flash_target
					5'h01,        // tgt_cs
		        	// Write Operation : Quad Input Page Program 1-1-4 4-byte address 32KB write
		        	//16'h8000,     // prog_xfer_len_bytes_input
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h1,         // page_prog_operation_input
		        	3'b011,       // prog_flash_addr_width_input
		        	2'b10,        // prog_data_lane_width_input
		        	2'b00,        // prog_addr_lane_width_input
		        	2'b00,        // prog_cmd_lane_width_input
		        	// Read Operation : Fast Read Quad Input/Output 1-4-4 4-byte address 32KB read
		        	//16'h8000,     // rd_xfer_len_bytes_input
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b101,       // read_operation_input
		        	8'h6,         // num_wait_state_input
		        	3'b011,       // rd_flash_addr_width_input
		        	2'b10,        // rd_data_lane_width_input
		        	2'b10,        // rd_addr_lane_width_input
		        	2'b00,        // rd_cmd_lane_width_input
					2'b01         // Write Read Sequence
		        );
		    end
		// Test 31 - 36 : 4-byte address, any erase - multiple (256-bytes write - 256-bytes read)	
		    // Test 31
		    if (test == 32'd31) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 31", $time);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 4KB sector erase 1-1-1 4-byte address mode
		        	2'b00,        // erase_test_input 
		        	3'b011,       // erase_flash_addr_width_input
		        	2'b00,        // erase_data_lane_width_input
		        	2'b00,        // erase_addr_lane_width_input
		        	2'b00,        // erase_cmd_lane_width_input
		        	32'h00001000, // flash address
					1'h1,         // multiple_flash_target
					5'h01,        // tgt_cs
		        	// Write Operation : Page Program 1-1-1 4-byte address 256-bytes
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h0,         // page_prog_operation_input
		        	3'b011,       // prog_flash_addr_width_input
		        	2'b00,        // prog_data_lane_width_input
		        	2'b00,        // prog_addr_lane_width_input
		        	2'b00,        // prog_cmd_lane_width_input
		        	// Read Operation : Read Data 1-1-1 4-byte address 256-bytes
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b000,       // read_operation_input
		        	8'h0,         // num_wait_state_input
		        	3'b011,       // rd_flash_addr_width_input
		        	2'b00,        // rd_data_lane_width_input
		        	2'b00,        // rd_addr_lane_width_input
		        	2'b00,        // rd_cmd_lane_width_input
					2'b10         // Write Read Sequence
		        );
		    end
		    // Test 32
		    if (test == 32'd32) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 32", $time);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 4KB sector erase 1-1-1 4-byte address mode
		        	2'b00,        // erase_test_input 
		        	3'b011,       // erase_flash_addr_width_input
		        	2'b00,        // erase_data_lane_width_input
		        	2'b00,        // erase_addr_lane_width_input
		        	2'b00,        // erase_cmd_lane_width_input
		        	32'h00001000, // flash address
					1'h1,         // multiple_flash_target
					5'h01,        // tgt_cs
		        	// Write Operation : Page Program 1-1-1 4-byte address 256-bytes
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h0,         // page_prog_operation_input
		        	3'b011,       // prog_flash_addr_width_input
		        	2'b00,        // prog_data_lane_width_input
		        	2'b00,        // prog_addr_lane_width_input
		        	2'b00,        // prog_cmd_lane_width_input
		        	// Read Operation : Fast Read Data 1-1-1 4-byte address 256-bytes
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b001,       // read_operation_input
		        	8'h8,         // num_wait_state_input
		        	3'b011,       // rd_flash_addr_width_input
		        	2'b00,        // rd_data_lane_width_input
		        	2'b00,        // rd_addr_lane_width_input
		        	2'b00,        // rd_cmd_lane_width_input
					2'b10         // Write Read Sequence
		        );
		    end
		    // Test 33
			if (test == 32'd33) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 33", $time);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 4KB sector erase 1-1-1 4-byte address mode
		        	2'b00,        // erase_test_input 
		        	3'b011,       // erase_flash_addr_width_input
		        	2'b00,        // erase_data_lane_width_input
		        	2'b00,        // erase_addr_lane_width_input
		        	2'b00,        // erase_cmd_lane_width_input
		        	32'h003E8000, // flash address
					1'h1,         // multiple_flash_target
					5'h01,        // tgt_cs
		        	// Write Operation : Page Program 1-1-1 4-byte address 256-bytes
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h0,         // page_prog_operation_input
		        	3'b011,       // prog_flash_addr_width_input
		        	2'b00,        // prog_data_lane_width_input
		        	2'b00,        // prog_addr_lane_width_input
		        	2'b00,        // prog_cmd_lane_width_input
		        	// Read Operation : Fast Read Dual Output 1-1-2 4-byte address 32KB read
		        	//16'h8000,     // rd_xfer_len_bytes_input
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b010,       // read_operation_input
		        	8'h8,         // num_wait_state_input
		        	3'b011,       // rd_flash_addr_width_input
		        	2'b01,        // rd_data_lane_width_input
		        	2'b00,        // rd_addr_lane_width_input
		        	2'b00,        // rd_cmd_lane_width_input
					2'b10         // Write Read Sequence
		        );
		    end
		    // Test 34
			if (test == 32'd34) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 34", $time);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 4KB sector erase 1-1-1 4-byte address mode
		        	2'b00,        // erase_test_input 
		        	3'b011,       // erase_flash_addr_width_input
		        	2'b00,        // erase_data_lane_width_input
		        	2'b00,        // erase_addr_lane_width_input
		        	2'b00,        // erase_cmd_lane_width_input
		        	32'h003E8000, // flash address
					1'h1,         // multiple_flash_target
					5'h01,        // tgt_cs
		        	// Write Operation : Page Program 1-1-1 4-byte address 256-bytes
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h0,         // page_prog_operation_input
		        	3'b011,       // prog_flash_addr_width_input
		        	2'b00,        // prog_data_lane_width_input
		        	2'b00,        // prog_addr_lane_width_input
		        	2'b00,        // prog_cmd_lane_width_input
		        	// Read Operation : Fast Read Dual Input/Output 1-2-2 4-byte address 32KB read
		        	//16'h8000,     // rd_xfer_len_bytes_input
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b011,       // read_operation_input
		        	8'h4,         // num_wait_state_input
		        	3'b011,       // rd_flash_addr_width_input
		        	2'b01,        // rd_data_lane_width_input
		        	2'b01,        // rd_addr_lane_width_input
		        	2'b00,        // rd_cmd_lane_width_input
					2'b10         // Write Read Sequence
		        );
		    end
		    // Test 35
		    if (test == 32'd35) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 35", $time);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 4KB sector erase 1-1-1 4-byte address mode
		        	2'b00,        // erase_test_input 
		        	3'b011,       // erase_flash_addr_width_input
		        	2'b00,        // erase_data_lane_width_input
		        	2'b00,        // erase_addr_lane_width_input
		        	2'b00,        // erase_cmd_lane_width_input
		        	32'h003E8000, // flash address
					1'h1,         // multiple_flash_target
					5'h01,        // tgt_cs
		        	// Write Operation : Quad Input Page Program 1-1-4 4-byte address 32KB write
		        	//16'h8000,     // prog_xfer_len_bytes_input
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h1,         // page_prog_operation_input
		        	3'b011,       // prog_flash_addr_width_input
		        	2'b10,        // prog_data_lane_width_input
		        	2'b00,        // prog_addr_lane_width_input
		        	2'b00,        // prog_cmd_lane_width_input
		        	// Read Operation : Fast Read Quad Output 1-1-4 4-byte address 32KB read
		        	//16'h8000,     // rd_xfer_len_bytes_input
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b100,       // read_operation_input
		        	8'h8,         // num_wait_state_input
		        	3'b011,       // rd_flash_addr_width_input
		        	2'b10,        // rd_data_lane_width_input
		        	2'b00,        // rd_addr_lane_width_input
		        	2'b00,        // rd_cmd_lane_width_input
					2'b10         // Write Read Sequence
		        );
		    end
		    // Test36
			if (test == 32'd36) begin
			    $display("# ---INFO : @%0dns :: Test Name : erase_write_read_test_supported_commands 36", $time);
	            erase_write_read_test_supported_commands(
		            // Erase Operation : 4KB sector erase 1-1-1 4-byte address mode
		        	2'b00,        // erase_test_input 
		        	3'b011,       // erase_flash_addr_width_input
		        	2'b00,        // erase_data_lane_width_input
		        	2'b00,        // erase_addr_lane_width_input
		        	2'b00,        // erase_cmd_lane_width_input
		        	32'h003E8000, // flash address
					1'h1,         // multiple_flash_target
					5'h01,        // tgt_cs
		        	// Write Operation : Quad Input Page Program 1-1-4 4-byte address 32KB write
		        	//16'h8000,     // prog_xfer_len_bytes_input
		        	16'h100,      // prog_xfer_len_bytes_input
		        	1'h1,         // page_prog_operation_input
		        	3'b011,       // prog_flash_addr_width_input
		        	2'b10,        // prog_data_lane_width_input
		        	2'b00,        // prog_addr_lane_width_input
		        	2'b00,        // prog_cmd_lane_width_input
		        	// Read Operation : Fast Read Quad Input/Output 1-4-4 4-byte address 32KB read
		        	//16'h8000,     // rd_xfer_len_bytes_input
		        	16'h100,      // rd_xfer_len_bytes_input
		        	3'b101,       // read_operation_input
		        	8'h6,         // num_wait_state_input
		        	3'b011,       // rd_flash_addr_width_input
		        	2'b10,        // rd_data_lane_width_input
		        	2'b10,        // rd_addr_lane_width_input
		        	2'b00,        // rd_cmd_lane_width_input
					2'b10         // Write Read Sequence
		        );
		    end		
		end
	endtask
	
	task standard_spi_test_wb;
	    begin    
		    // Standard SPI Tests
		    erase_write_read_test_supported_commands_main_wb(8);
		    erase_write_read_test_supported_commands_main_wb(25);
		    erase_write_read_test_supported_commands_main_wb(32);
		    if (run_full_regr == 1) begin
			    //3-byte address mode will be tested on Macronix and not Winbond
		        erase_write_read_test_supported_commands_main_wb(1);
		        erase_write_read_test_supported_commands_main_wb(13);
			    //3-byte address mode will be tested on Macronix and not Winbond
		        erase_write_read_test_supported_commands_main_wb(2);
		        erase_write_read_test_supported_commands_main_wb(7);
		        erase_write_read_test_supported_commands_main_wb(14);
		        erase_write_read_test_supported_commands_main_wb(19);
		        erase_write_read_test_supported_commands_main_wb(20);
		        erase_write_read_test_supported_commands_main_wb(26);
		        erase_write_read_test_supported_commands_main_wb(31);
			end
		end
	endtask
	
	task dual_spi_test_wb;
	    begin
			// Dual SPI Tests
			erase_write_read_test_supported_commands_main_wb(9);
			erase_write_read_test_supported_commands_main_wb(28);
			erase_write_read_test_supported_commands_main_wb(33);
		    if (run_full_regr == 1) begin
			    //3-byte address mode will be tested on Macronix and not Winbond
			    erase_write_read_test_supported_commands_main_wb(4);
			    //3-byte address mode will be tested on Macronix and not Winbond
			    erase_write_read_test_supported_commands_main_wb(3);
			    erase_write_read_test_supported_commands_main_wb(10);
			    erase_write_read_test_supported_commands_main_wb(15);
			    erase_write_read_test_supported_commands_main_wb(16);
			    erase_write_read_test_supported_commands_main_wb(21);
			    erase_write_read_test_supported_commands_main_wb(22);
			    erase_write_read_test_supported_commands_main_wb(27);
			    erase_write_read_test_supported_commands_main_wb(34);
			end
		end
	endtask
	
	task quad_spi_test_wb;
	    begin
			erase_write_read_test_supported_commands_main_wb(11);
			erase_write_read_test_supported_commands_main_wb(29);
			erase_write_read_test_supported_commands_main_wb(36);
		    if (run_full_regr == 1) begin
			    //3-byte address mode will be tested on Macronix and not Winbond
			    erase_write_read_test_supported_commands_main_wb(6);
			    erase_write_read_test_supported_commands_main_wb(18);
			    //3-byte address mode will be tested on Macronix and not Winbond
			    erase_write_read_test_supported_commands_main_wb(5);
			    erase_write_read_test_supported_commands_main_wb(12);
			    erase_write_read_test_supported_commands_main_wb(17);
			    erase_write_read_test_supported_commands_main_wb(23);
			    erase_write_read_test_supported_commands_main_wb(24);
			    erase_write_read_test_supported_commands_main_wb(30);
			    erase_write_read_test_supported_commands_main_wb(35);
			end
	    end
	endtask
	
	task direct_access_main_wb;
	    input [31:0] test;
	    begin
		    // Test 1 - 6: Direct Access - Single Transaction
		    if (test == 32'd1) begin
			    $display("# ---INFO : @%0dns :: Test Name : direct_access_test 1", $time);
				direct_write_read_access(
				// Write Operation : Page Program 1-1-1 3-byte address 256-bytes SPI Mode
				2'h0, // wr_dat_lane_width
				2'h0, // wr_addr_lane_width_input
				2'h0, // wr_cmd_lane_width_input
				1'h1, // wr_xip_addr_width_input
				3'h0, // wr_dummy_clock_cycles_input
				3'h0, // flash_map_en_wr_access_cmd_input
				// Read Operation : Read Data 1-1-1 3-byte address 256-bytes
				2'h0, // rd_dat_lane_width_input
				2'h0, // rd_addr_lane_width_input
				2'h0, // rd_cmd_lane_width_input
				1'h1, // rd_xip_addr_width_input
				3'h0, // rd_dummy_clock_cycles_input
				3'h0, // flash_map_en_rd_access_cmd_input
				//Others
				32'h00011000,  // direct_flash_address
				//32'h0000E000,  // direct_flash_address
				32'h40, // number_of_direct_write
				32'h40, // number_of_direct_read
				1'h0,   // single0/burst1 transaction
				1'h0    // enable xip mode
				);
			end
		    if (test == 32'd2) begin
			    $display("# ---INFO : @%0dns :: Test Name : direct_access_test 2", $time);
			    direct_write_read_access(
				// Write Operation : Page Program 1-1-1 3-byte address 256-bytes SPI Mode
				2'h0, // wr_dat_lane_width
				2'h0, // wr_addr_lane_width_input
				2'h0, // wr_cmd_lane_width_input
				1'h1, // wr_xip_addr_width_input
				3'h0, // wr_dummy_clock_cycles_input
				3'h0, // flash_map_en_wr_access_cmd_input
				// Read Operation : Fast Read Data 1-1-1 3-byte address 256-bytes
				2'h0, // rd_dat_lane_width_input
				2'h0, // rd_addr_lane_width_input
				2'h0, // rd_cmd_lane_width_input
				1'h1, // rd_xip_addr_width_input
				3'h4, // rd_dummy_clock_cycles_input
				3'h1, // flash_map_en_rd_access_cmd_input
				//Others
				32'h00011000,  // direct_flash_address
				32'h40, // number_of_direct_write
				32'h40, // number_of_direct_read
				1'h0,   // single0/burst1 transaction
				1'h0    // enable xip mode
				);
			end
		    if (test == 32'd3) begin
			    $display("# ---INFO : @%0dns :: Test Name : direct_access_test 3", $time);
			    direct_write_read_access(
				// Write Operation : Page Program 1-1-1 3-byte address 256-bytes SPI Mode
				2'h0, // wr_dat_lane_width
				2'h0, // wr_addr_lane_width_input
				2'h0, // wr_cmd_lane_width_input
				1'h1, // wr_xip_addr_width_input
				3'h0, // wr_dummy_clock_cycles_input
				3'h0, // flash_map_en_wr_access_cmd_input
				// Read Operation : Dual Output Fast Read 1-1-2 3-byte address 256-bytes
				2'h1, // rd_dat_lane_width_input
				2'h0, // rd_addr_lane_width_input
				2'h0, // rd_cmd_lane_width_input
				1'h1, // rd_xip_addr_width_input
				3'h4, // rd_dummy_clock_cycles_input
				3'h2, // flash_map_en_rd_access_cmd_input
				//Others
				32'h00011000,  // direct_flash_address
				32'h40, // number_of_direct_write
				32'h40, // number_of_direct_read
				1'h0,   // single0/burst1 transaction
				1'h0    // enable xip mode
				);
			end
		    if (test == 32'd4) begin
			    $display("# ---INFO : @%0dns :: Test Name : direct_access_test 4", $time);
			    direct_write_read_access(
				// Write Operation : Page Program 1-1-1 3-byte address 256-bytes SPI Mode
				2'h0, // wr_dat_lane_width
				2'h0, // wr_addr_lane_width_input
				2'h0, // wr_cmd_lane_width_input
				1'h1, // wr_xip_addr_width_input
				3'h0, // wr_dummy_clock_cycles_input
				3'h0, // flash_map_en_wr_access_cmd_input
				// Read Operation : Dual Input/Output Fast Read 1-2-2 3-byte address 256-bytes
				2'h1, // rd_dat_lane_width_input
				2'h1, // rd_addr_lane_width_input
				2'h0, // rd_cmd_lane_width_input
				1'h1, // rd_xip_addr_width_input
				3'h2, // rd_dummy_clock_cycles_input
				3'h3, // flash_map_en_rd_access_cmd_input
				//Others
				32'h00011000,  // direct_flash_address
				32'h40, // number_of_direct_write
				32'h40, // number_of_direct_read
				1'h0,   // single0/burst1 transaction
				1'h0    // enable xip mode
				);
			end
		    if (test == 32'd5) begin
			    $display("# ---INFO : @%0dns :: Test Name : direct_access_test 5", $time);
			    direct_write_read_access(
				// Write Operation : Page Program 1-1-1 3-byte address 256-bytes SPI Mode
				2'h0, // wr_dat_lane_width
				2'h0, // wr_addr_lane_width_input
				2'h0, // wr_cmd_lane_width_input
				1'h1, // wr_xip_addr_width_input
				3'h0, // wr_dummy_clock_cycles_input
				3'h0, // flash_map_en_wr_access_cmd_input
				// Read Operation : Quad Output Fast Read 1-1-4 3-byte address 256-bytes
				2'h2, // rd_dat_lane_width_input
				2'h0, // rd_addr_lane_width_input
				2'h0, // rd_cmd_lane_width_input
				1'h1, // rd_xip_addr_width_input
				3'h4, // rd_dummy_clock_cycles_input
				3'h4, // flash_map_en_rd_access_cmd_input
				//Others
				32'h00011000,  // direct_flash_address
				32'h40, // number_of_direct_write
				32'h40, // number_of_direct_read
				1'h0,   // single0/burst1 transaction
				1'h0    // enable xip mode
				);
			end
		    if (test == 32'd6) begin
			    $display("# ---INFO : @%0dns :: Test Name : direct_access_test 6", $time);
			    direct_write_read_access(
				// Write Operation : Page Program 1-1-1 3-byte address 256-bytes SPI Mode
				2'h0, // wr_dat_lane_width
				2'h0, // wr_addr_lane_width_input
				2'h0, // wr_cmd_lane_width_input
				1'h1, // wr_xip_addr_width_input
				3'h0, // wr_dummy_clock_cycles_input
				3'h0, // flash_map_en_wr_access_cmd_input
				// Read Operation : Quad Input/Output Fast Read 1-4-4 3-byte address 256-bytes
				2'h2, // rd_dat_lane_width_input
				2'h2, // rd_addr_lane_width_input
				2'h0, // rd_cmd_lane_width_input
				1'h1, // rd_xip_addr_width_input
				3'h3, // rd_dummy_clock_cycles_input
				3'h5, // flash_map_en_rd_access_cmd_input
				//Others
				32'h00011000,  // direct_flash_address
				32'h40, // number_of_direct_write
				32'h40, // number_of_direct_read
				1'h0,   // single0/burst1 transaction
				1'h0    // enable xip mode
				);
			end
		    // Test 7 - 12: Direct Access - Burst Transaction
		    if (test == 32'd7) begin
			    $display("# ---INFO : @%0dns :: Test Name : direct_access_test 7", $time);
				direct_write_read_access(
				// Write Operation : Page Program 1-1-1 3-byte address 256-bytes SPI Mode
				2'h0, // wr_dat_lane_width
				2'h0, // wr_addr_lane_width_input
				2'h0, // wr_cmd_lane_width_input
				1'h1, // wr_xip_addr_width_input
				3'h0, // wr_dummy_clock_cycles_input
				3'h0, // flash_map_en_wr_access_cmd_input
				// Read Operation : Read Data 1-1-1 3-byte address 256-bytes
				2'h0, // rd_dat_lane_width_input
				2'h0, // rd_addr_lane_width_input
				2'h0, // rd_cmd_lane_width_input
				1'h1, // rd_xip_addr_width_input
				3'h0, // rd_dummy_clock_cycles_input
				3'h0, // flash_map_en_rd_access_cmd_input
				//Others
				32'h00011000,  // direct_flash_address
				32'h40, // number_of_direct_write
				32'h40, // number_of_direct_read
				1'h1,   // single0/burst1 transaction
				1'h0    // enable xip mode
				);
			end
		    if (test == 32'd8) begin
			    $display("# ---INFO : @%0dns :: Test Name : direct_access_test 8", $time);
			    direct_write_read_access(
				// Write Operation : Page Program 1-1-1 3-byte address 256-bytes SPI Mode
				2'h0, // wr_dat_lane_width
				2'h0, // wr_addr_lane_width_input
				2'h0, // wr_cmd_lane_width_input
				1'h1, // wr_xip_addr_width_input
				3'h0, // wr_dummy_clock_cycles_input
				3'h0, // flash_map_en_wr_access_cmd_input
				// Read Operation : Fast Read Data 1-1-1 3-byte address 256-bytes
				2'h0, // rd_dat_lane_width_input
				2'h0, // rd_addr_lane_width_input
				2'h0, // rd_cmd_lane_width_input
				1'h1, // rd_xip_addr_width_input
				3'h4, // rd_dummy_clock_cycles_input
				3'h1, // flash_map_en_rd_access_cmd_input
				//Others
				32'h00011000,  // direct_flash_address
				32'h40, // number_of_direct_write
				32'h40, // number_of_direct_read
				1'h1,   // single0/burst1 transaction
				1'h0    // enable xip mode
				);
			end
		    if (test == 32'd9) begin
			    $display("# ---INFO : @%0dns :: Test Name : direct_access_test 9", $time);
			    direct_write_read_access(
				// Write Operation : Page Program 1-1-1 3-byte address 256-bytes SPI Mode
				2'h0, // wr_dat_lane_width
				2'h0, // wr_addr_lane_width_input
				2'h0, // wr_cmd_lane_width_input
				1'h1, // wr_xip_addr_width_input
				3'h0, // wr_dummy_clock_cycles_input
				3'h0, // flash_map_en_wr_access_cmd_input
				// Read Operation : Dual Output Fast Read 1-1-2 3-byte address 256-bytes
				2'h1, // rd_dat_lane_width_input
				2'h0, // rd_addr_lane_width_input
				2'h0, // rd_cmd_lane_width_input
				1'h1, // rd_xip_addr_width_input
				3'h4, // rd_dummy_clock_cycles_input
				3'h2, // flash_map_en_rd_access_cmd_input
				//Others
				32'h00011000,  // direct_flash_address
				32'h40, // number_of_direct_write
				32'h40, // number_of_direct_read
				1'h1,   // single0/burst1 transaction
				1'h0    // enable xip mode
				);
			end
		    if (test == 32'd10) begin
			    $display("# ---INFO : @%0dns :: Test Name : direct_access_test 10", $time);
			    direct_write_read_access(
				// Write Operation : Page Program 1-1-1 3-byte address 256-bytes SPI Mode
				2'h0, // wr_dat_lane_width
				2'h0, // wr_addr_lane_width_input
				2'h0, // wr_cmd_lane_width_input
				1'h1, // wr_xip_addr_width_input
				3'h0, // wr_dummy_clock_cycles_input
				3'h0, // flash_map_en_wr_access_cmd_input
				// Read Operation : Dual Input/Output Fast Read 1-2-2 3-byte address 256-bytes
				2'h1, // rd_dat_lane_width_input
				2'h1, // rd_addr_lane_width_input
				2'h0, // rd_cmd_lane_width_input
				1'h1, // rd_xip_addr_width_input
				3'h2, // rd_dummy_clock_cycles_input
				3'h3, // flash_map_en_rd_access_cmd_input
				//Others
				32'h00011000,  // direct_flash_address
				32'h40, // number_of_direct_write
				32'h40, // number_of_direct_read
				1'h1,   // single0/burst1 transaction
				1'h0    // enable xip mode
				);
			end
		    if (test == 32'd11) begin
			    $display("# ---INFO : @%0dns :: Test Name : direct_access_test 11", $time);
			    direct_write_read_access(
				// Write Operation : Page Program 1-1-1 3-byte address 256-bytes SPI Mode
				2'h0, // wr_dat_lane_width
				2'h0, // wr_addr_lane_width_input
				2'h0, // wr_cmd_lane_width_input
				1'h1, // wr_xip_addr_width_input
				3'h0, // wr_dummy_clock_cycles_input
				3'h0, // flash_map_en_wr_access_cmd_input
				// Read Operation : Quad Output Fast Read 1-1-4 3-byte address 256-bytes
				2'h2, // rd_dat_lane_width_input
				2'h0, // rd_addr_lane_width_input
				2'h0, // rd_cmd_lane_width_input
				1'h1, // rd_xip_addr_width_input
				3'h4, // rd_dummy_clock_cycles_input
				3'h4, // flash_map_en_rd_access_cmd_input
				//Others
				32'h00011000,  // direct_flash_address
				32'h40, // number_of_direct_write
				32'h40, // number_of_direct_read
				1'h1,   // single0/burst1 transaction
				1'h0    // enable xip mode
				);
			end
		    if (test == 32'd12) begin
			    $display("# ---INFO : @%0dns :: Test Name : direct_access_test 12", $time);
			    direct_write_read_access(
				// Write Operation : Page Program 1-1-1 3-byte address 256-bytes SPI Mode
				2'h0, // wr_dat_lane_width
				2'h0, // wr_addr_lane_width_input
				2'h0, // wr_cmd_lane_width_input
				1'h1, // wr_xip_addr_width_input
				3'h0, // wr_dummy_clock_cycles_input
				3'h0, // flash_map_en_wr_access_cmd_input
				// Read Operation : Quad Input/Output Fast Read 1-4-4 3-byte address 256-bytes
				2'h2, // rd_dat_lane_width_input
				2'h2, // rd_addr_lane_width_input
				2'h0, // rd_cmd_lane_width_input
				1'h1, // rd_xip_addr_width_input
				3'h3, // rd_dummy_clock_cycles_input
				3'h5, // flash_map_en_rd_access_cmd_input
				//Others
				32'h00011000,  // direct_flash_address
				32'h40, // number_of_direct_write
				32'h40, // number_of_direct_read
				1'h1,   // single0/burst1 transaction
				1'h0    // enable xip mode
				);
			end		
		end
    endtask
	
	task standard_spi_direct_access_test_wb;
	    begin
		    direct_access_main_wb(1);
		    direct_access_main_wb(2);
			if (INTERFACE == 0) begin
		        direct_access_main_wb(7);
		        direct_access_main_wb(8);
			end
		end
	endtask
	
	task dual_spi_direct_access_test_wb;
	    begin
		    direct_access_main_wb(3);
		    direct_access_main_wb(4);
			if (INTERFACE == 0) begin
		        direct_access_main_wb(9);
		        direct_access_main_wb(10);
			end
		end
	endtask
	
	task quad_spi_direct_access_test_wb;
	    begin
		    direct_access_main_wb(5);
		    direct_access_main_wb(6);
			if (INTERFACE == 0) begin
		        direct_access_main_wb(11);
		        direct_access_main_wb(12);
			end
		end
	endtask
	
	task read_id_main_wb;
	    input [31:0] test;
	    begin
		    if (test == 32'd1) begin
			    $display("# ---INFO : @%0dns :: Test Name : supported_commands_test_send_command_and_read_data 1", $time);
				// Read JEDEC ID
				supported_commands_test_send_command_and_read_data(
				    16'h3, // xfer_len_bytes_input
					1'h1,  // multiple_flash_target_input
					5'h04, // flash_cmd_code_input
					8'h0,  // num_wait_state_input
					3'h0,  // flash_addr_width_input
					5'h1,  // tgt_cs_input
					2'h0,  // data_lane_width_input
					2'h0,  // addr_lane_width_input
					2'h0,  // cmd_lane_width_input
					32'h0  // flash_addr_input 
				);
			end
		    if (test == 32'd2) begin
			    $display("# ---INFO : @%0dns :: Test Name : supported_commands_test_send_command_and_read_data 2", $time);
				// Read Device ID
				supported_commands_test_send_command_and_read_data(
				    16'h1, // xfer_len_bytes_input
					1'h1,  // multiple_flash_target_input
					5'h05, // flash_cmd_code_input
					8'h18, // num_wait_state_input
					3'h0,  // flash_addr_width_input
					5'h1,  // tgt_cs_input
					2'h0,  // data_lane_width_input
					2'h0,  // addr_lane_width_input
					2'h0,  // cmd_lane_width_input
					32'h0  // flash_addr_input 
				);
			end
		    if (test == 32'd3) begin
			    $display("# ---INFO : @%0dns :: Test Name : supported_commands_test_send_command_and_read_data 3", $time);
				// Read Manufacturer / Device ID - Standard SPI
				supported_commands_test_send_command_and_read_data(
				    16'h2, // xfer_len_bytes_input
					1'h1,  // multiple_flash_target_input
					5'h07, // flash_cmd_code_input
					8'h0,  // num_wait_state_input
					3'h2,  // flash_addr_width_input
					5'h1,  // tgt_cs_input
					2'h0,  // data_lane_width_input
					2'h0,  // addr_lane_width_input
					2'h0,  // cmd_lane_width_input
					32'h0  // flash_addr_input 
				);
			end
		    if (test == 32'd4) begin
			    $display("# ---INFO : @%0dns :: Test Name : supported_commands_test_send_command_and_read_data 4", $time);
				// Read Manufacturer / Device ID - Dual SPI
				supported_commands_test_send_command_and_read_data(
				    16'h2, // xfer_len_bytes_input
					1'h1,  // multiple_flash_target_input
					5'h08, // flash_cmd_code_input
					8'h4,  // num_wait_state_input
					3'h2,  // flash_addr_width_input
					5'h1,  // tgt_cs_input
					2'h1,  // data_lane_width_input
					2'h1,  // addr_lane_width_input
					2'h0,  // cmd_lane_width_input
					32'h0  // flash_addr_input 
				);
			end
		    if (test == 32'd5) begin
			    $display("# ---INFO : @%0dns :: Test Name : supported_commands_test_send_command_and_read_data 5", $time);
				// Read Manufacturer / Device ID - Quad SPI
				supported_commands_test_send_command_and_read_data(
				    16'h2, // xfer_len_bytes_input
					1'h1,  // multiple_flash_target_input
					5'h09, // flash_cmd_code_input
					8'h6,  // num_wait_state_input
					3'h2,  // flash_addr_width_input
					5'h1,  // tgt_cs_input
					2'h2,  // data_lane_width_input
					2'h2,  // addr_lane_width_input
					2'h0,  // cmd_lane_width_input
					32'h0  // flash_addr_input 
				);
			end
		end
	endtask
	
	task standard_spi_read_id_test_wb;
	    begin
	        read_id_main_wb(1);
	        read_id_main_wb(2);
	        read_id_main_wb(3);
		end
	endtask
	
	task dual_spi_read_id_test_wb;
	    begin
	        read_id_main_wb(4);
		end
	endtask
	
	task quad_spi_read_id_test_wb;
	    begin
		    read_id_main_wb(5);
		end
	endtask
	
	// Main test sequence
	task test_runner;
	    begin
	        if ($test$plusargs("overwrite_gui_settings")) begin
	            overwrite_gui_settings = 1;
	    	end else begin
	            overwrite_gui_settings = 0;
	    	end
	        if ($test$plusargs("standard_spi_fast_read_en")) begin
	            standard_spi_fast_read_en = 1;
	    	end else begin
	            standard_spi_fast_read_en = 0;
	    	end
	        if ($test$plusargs("disp_sim_log")) begin
	            disp_sim_log = 1;
	    	end else begin
	            disp_sim_log = 0;
	    	end
			if ($test$plusargs("run_full_regr")) begin
	            run_full_regr = 1;
	    	end else begin
	            run_full_regr = 0;
	    	end
	        if ($value$plusargs("target_flash=%0d",flash_device)) begin
			    if (flash_device == 0) begin
                    $display("Setting target flash device to MX25L51245G.");
					flash_device = 2'b00;
				end
				else if (flash_device == 1) begin
                    $display("Setting target flash device to W25Q512JVxIQ.");
					flash_device = 2'b01;
				end
            end
			else begin
                $display("Setting target flash device to MX25L51245G.");
				flash_device = 2'b00;
			end
	    	
	        if ($test$plusargs("read_default_register_test")) begin
	            read_default_register_test();
	    	end
	        else if ($test$plusargs("write_read_register_test")) begin
	    	    write_read_register_test();
	    	end
	        else if ($test$plusargs("supported_commands_test_send_command_sclk_rate_test")) begin
	    	    supported_commands_test_send_command_sclk_rate_test();
	    	end
	        else if ($test$plusargs("supported_commands_test_send_command_clk_mode_test")) begin
	    	    supported_commands_test_send_command_clk_mode_test();
	    	end
	        else if ($test$plusargs("supported_commands_test_send_command_and_address")) begin
	    	    supported_commands_test_send_command_and_address();
	    	end
	        else if ($test$plusargs("supported_commands_test_send_command")) begin
	    	    supported_commands_test_send_command();
	    	end
	    	else begin	
	    	    if (ENABLE_TRANSMIT_FIFO == 0 && ENABLE_RECEIVE_FIFO == 0)  begin
				    if (flash_device == 0) begin // Macronix
					    standard_spi_read_id_test_mx();
						supported_commands_test_send_command_write_read_data(); 
					    standard_spi_test_mx();
						if (ENABLE_FLASH_ADDRESS_MAPPING == 1) begin 
					        standard_spi_direct_access_test_mx();
						end
						if (SUPPORTED_PROTOCOL == 1 || SUPPORTED_PROTOCOL == 2) begin 
						    dual_spi_test_mx(); 
						    if (ENABLE_FLASH_ADDRESS_MAPPING == 1) begin
						        dual_spi_direct_access_test_mx();
							end
						end
					    if (SUPPORTED_PROTOCOL == 2) begin 
                            quad_spi_read_id_test_mx();	
						    quad_spi_test_mx(); 
						    if (ENABLE_FLASH_ADDRESS_MAPPING == 1) begin
						        quad_spi_direct_access_test_mx();
							end
						end
						#1000;
					end
					
					if (flash_device == 1) begin // Applicable for Winbond only
					    standard_spi_read_id_test_wb();
						standard_spi_test_wb();
						if (ENABLE_FLASH_ADDRESS_MAPPING == 1) begin 
						    standard_spi_direct_access_test_wb();
						end
						if (SUPPORTED_PROTOCOL == 1 || SUPPORTED_PROTOCOL == 2) begin 
						    dual_spi_read_id_test_wb();
							dual_spi_test_wb();
							if (ENABLE_FLASH_ADDRESS_MAPPING == 1) begin 
						        dual_spi_direct_access_test_wb();
						    end
						end
					    if (SUPPORTED_PROTOCOL == 2) begin 
						    quad_spi_read_id_test_wb();
						    quad_spi_test_wb(); 
						    if (ENABLE_FLASH_ADDRESS_MAPPING == 1) begin 
							    quad_spi_direct_access_test_wb();
							end
						end
						#1000;
					end
				end
	    		else if (ENABLE_TRANSMIT_FIFO == 1 && ENABLE_RECEIVE_FIFO == 1)  begin
				    if (flash_device == 0) begin // Macronix
					    standard_spi_read_id_test_mx();
						supported_commands_test_send_command_write_read_data(); 
					    standard_spi_test_mx();
						if (SUPPORTED_PROTOCOL == 1 || SUPPORTED_PROTOCOL == 2) begin 
						    dual_spi_test_mx(); 
						end
					    if (SUPPORTED_PROTOCOL == 2) begin 
                            quad_spi_read_id_test_mx();
						    quad_spi_test_mx();  
						end
						#1000;
					end
					
					if (flash_device == 1) begin // Applicable for Winbond only
					    standard_spi_read_id_test_wb();
						standard_spi_test_wb();
						if (SUPPORTED_PROTOCOL == 1 || SUPPORTED_PROTOCOL == 2) begin 
						    dual_spi_read_id_test_wb();
							dual_spi_test_wb();
						end
					    if (SUPPORTED_PROTOCOL == 2) begin 
						    quad_spi_read_id_test_wb();
							quad_spi_test_wb();  
						end
						#1000;
					end
	    		end
	    	end
	    end
    endtask
    
endmodule