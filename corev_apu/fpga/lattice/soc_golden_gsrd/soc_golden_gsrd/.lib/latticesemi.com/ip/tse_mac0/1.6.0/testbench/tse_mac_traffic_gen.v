`ifndef TSE_MAC_TRAFFIC_GEN_V
`define TSE_MAC_TRAFFIC_GEN_V
//0---------------------------------------------------------------------------------------------------
// File Name      : tse_mac_traffic_gen.v
// Project        : TSE_MAC IIP
// Date Created   : 21-08-2020
// Description    : This is HDL file input generation
// Generator      : Test bench Compiler Version 1.1
//0---------------------------------------------------------------------------------------------------

`timescale 1ns/1ps
`include "tse_mac_defines.v"

module tse_mac_traffic_gen #(

  //1###################################################################################################
  // Parameter Declaration
  //1###################################################################################################
  parameter MII_GMII      = 0,
  parameter SGMII_TSMAC   = 0,
  parameter CLASSIC_TSMAC = 0,
  parameter GBE_MAC       = 1,
  parameter MIIM_MODULE   = 0,
  parameter RGMII         = 0,
  parameter RMII          = 0
  ) (
 
  //1###################################################################################################
  // Input/Output Signal Declaration
  //1###################################################################################################
  input   wire       i_txmac_clk,         // Tx mac clk 
  input   wire       i_ds_lmmi_clk,       // Ds lmmi clk
  input   wire       i_ds_lmmi_ready,     // Ds lmmi ready
  output  reg [31:0] o_tx_edata_idx,      // Transmitter expected data index
  output  reg [31:0] o_tx_edata_size,     // Transmitter expected data size
  output  reg        o_ds_lmmi_wr_rdn,    // Ds lmmi write/read enable 
  output  reg [8:0]  o_ds_lmmi_wdata,     // Ds lmmi write data
  input   wire       i_rxmac_clk,         // Rx mac clk 
  output  reg [31:0] o_rx_edata_idx,      // Receiver expected data index
  output  reg [31:0] o_rx_edata_size,     // Receiver expected data size
  output  reg        o_rx_dv_b,           // Receiver data valid signal   
  output  reg        o_rx_er_b,           // Receiver error signal
  output  reg [7:0]  o_rxd_8b,            // Receiver data signal
  output  reg        o_rgmii_rx_ctl,      // RGMII Receiver control signal
  output  reg [3:0]  o_rgmii_rxd_4b,      // RGMII Receiver data signal
  output  reg [7:0]  o_mii_gmii_rxd,      // MII/GMII Receiver data signal
  output  reg        o_mii_gmii_rx_dv,    // MII/GMII Receiver data valid signal
  output  reg        o_mii_gmii_rx_er,    // MII/GMII Receiver error signal
  output  reg [1:0]  o_rmii_rxd_2b,       // RMII Receiver error signal
  output  reg        o_rmii_rx_crs_dv,    // RMII Receiver error signal
  output  reg        o_rmii_rx_er         // RMII Receiver error signal
  );

  //1###################################################################################################
  // Local Variable Declaration
  //1###################################################################################################
  integer    idx_i;                      // Index
  reg [63:0] tx_edata_2d_64b [0:64999];  // TX Expected data array
  reg        crc_err_b;                  // CRC Error
  reg        fifo_err_b;                 // FIFO Underrun Error
  reg        tx_done_b;                  // TX Data Transmit Done
  reg        rx_done_b;                  // RX data Transmit Done
  reg [31:0] rx_crc_32b;                 // Variable to store the calculated CRC
  reg [63:0] rx_edata_2d_64b [0:64999];  // RX Expected data array
  reg        rgmii_rx_dv_b;              // RGMII RX data enable
  reg        rgmii_rx_er_b;              // RGMII RX data error


  //1###################################################################################################
  // Initilize all the variales
  //1###################################################################################################
  initial
  begin
    o_ds_lmmi_wdata    = 0;
    o_ds_lmmi_wr_rdn   = 0;
    o_tx_edata_size    = 0;
    o_tx_edata_idx     = 0;
    idx_i              = 0;
    crc_err_b          = 0;
    fifo_err_b         = 0;
    tx_done_b          = 1;
    rx_done_b          = 1;
    o_rx_dv_b          = 0;
    o_rx_er_b          = 0;
    o_rxd_8b           = 0;
    o_rgmii_rx_ctl     = 0;
    o_rgmii_rxd_4b     = 0;
    o_rmii_rxd_2b      = 0;
    o_rmii_rx_crs_dv   = 0;
    o_rmii_rx_er       = 0;
    //2-----------------------------------------------------------------------------------------------
    // Initialize the memory 
    //2-----------------------------------------------------------------------------------------------
    for (idx_i = 0; idx_i < 65000; idx_i = idx_i + 1) begin
      tx_edata_2d_64b[idx_i]  = 0;
      rx_edata_2d_64b[idx_i]  = 0;
    end

  end

  //1-------------------------------------------------------------------------------------------------
  // tx_fifo_data_write :This method is used send data into tx fifo  
  //1-------------------------------------------------------------------------------------------------
  //        p_des_addr_48b  : Parameter for the Destination Address field
  //        p_scr_addr_48b  : Parameter for the Source Address field
  //        p_data_size_16b : Parameter for the Data size field
  //1-------------------------------------------------------------------------------------------------
  task tx_fifo_data_write;
    input   [47:0]  p_des_addr_48b;
    input   [47:0]  p_scr_addr_48b;
    input   [15:0]  p_data_size_16b;
    integer         m_idx_i;
    begin
      o_tx_edata_idx    = 0;
      o_tx_edata_size   = 0; 
      m_idx_i           = 0;
      tx_done_b         = 0;
      @(posedge i_txmac_clk);
      $write("MSG :: @%0dns %m() :: TX Traffic Generation..... \n",$time);
     `ifndef RADIANT_ENV
      if (tb_top.rst_4b != 0 & tb_top.rst_4b != 7 & tb_top.rst_4b != 8) begin
        for (m_idx_i = 0; m_idx_i < p_data_size_16b; m_idx_i = m_idx_i + 1) begin
          if (tb_top.u_dut.U1_lscc_tx_mac.U1_lscc_tx_macsm.tx_fifoavail != 1) begin
            send_tx_data($random(),0,0);
          end
        end
        if (tb_top.u_dut.U1_lscc_tx_mac.U1_lscc_tx_macsm.tx_fifoavail == 1) begin
          if (tb_top.rst_4b == 1) begin //Assert the hardware reset in preamble field
            while (tb_top.u_dut.U1_lscc_tx_mac.U1_lscc_tx_macsm.tx_preamble_st != 1) begin    
              @(posedge i_txmac_clk);
            end
          end else if (tb_top.rst_4b == 2) begin //Assert the hardware reset in SFD field
            while (tb_top.u_dut.U1_lscc_tx_mac.U1_lscc_tx_macsm.tx_sfd_st != 1) begin    
              @(posedge i_txmac_clk);
            end
          end else if (tb_top.rst_4b == 3) begin //Assert the hardware reset in Destination address field
            while (tb_top.u_dut.U1_lscc_tx_mac.U1_lscc_tx_macsm.tx_rdfifo_st != 1) begin    
              @(posedge i_txmac_clk);
            end
            repeat (3)
            send_tx_data($random(),0,0);
          end else if (tb_top.rst_4b == 4) begin //Assert the hardware in Source address field 
            while (tb_top.u_dut.U1_lscc_tx_mac.U1_lscc_tx_macsm.tx_rdfifo_st != 1) begin    
              @(posedge i_txmac_clk);
            end
            repeat (8)
            send_tx_data($random(),0,0);
          end else if (tb_top.rst_4b == 5) begin //Assert the hardware in Length/Type field 
            while (tb_top.u_dut.U1_lscc_tx_mac.U1_lscc_tx_macsm.tx_rdfifo_st != 1) begin    
              @(posedge i_txmac_clk);
            end
            repeat (12)
            send_tx_data($random(),0,0);
          end else if (tb_top.rst_4b == 6) begin //Assert the hardware in payload field 
            while (tb_top.u_dut.U1_lscc_tx_mac.U1_lscc_tx_macsm.tx_rdfifo_st != 1) begin    
              @(posedge i_txmac_clk);
            end
            repeat (18) 
              send_tx_data($random(),0,0);
          end
          tb_top.reset_n_r = 0;
          @(posedge i_txmac_clk);
          tb_top.rst_4b    = 0;
          tb_top.reset_n_r = 1;
        end
      end else if (tb_top.rst_4b == 7) begin //Assert the hardware in padding field 
        for (m_idx_i = 0; m_idx_i < p_data_size_16b; m_idx_i = m_idx_i + 1) begin
          if (m_idx_i + 1 == p_data_size_16b) begin
            send_tx_data($random(),1,1);
          end else begin
            send_tx_data($random(),0,1);
          end
        end
        while (tb_top.u_dut.U1_lscc_tx_mac.U1_lscc_tx_macsm.tx_genpad_st != 1) begin    
          @(posedge i_txmac_clk);
        end
        tb_top.reset_n_r = 0;
          @(posedge i_txmac_clk);
        tb_top.rst_4b    = 0;
        tb_top.reset_n_r = 1;
      end else if (tb_top.rst_4b == 8) begin //Assert the hardware in fcs field 
        for (m_idx_i = 0; m_idx_i < p_data_size_16b; m_idx_i = m_idx_i + 1) begin
          if (m_idx_i + 1 == p_data_size_16b) begin
            send_tx_data($random(),1,1);
          end else begin
            send_tx_data($random(),0,1);
          end
        end
        while (tb_top.u_dut.U1_lscc_tx_mac.U1_lscc_tx_macsm.tx_goodfcs_st != 1) begin    
          @(posedge i_txmac_clk);
           send_tx_data($random(),0,0);
        end
        tb_top.reset_n_r = 0;
          @(posedge i_txmac_clk);
        tb_top.rst_4b    = 0;
        tb_top.reset_n_r = 1;
      end else begin 
     `endif
        //Send Destination Address
        send_tx_data(p_des_addr_48b[47:40],0,1);
        send_tx_data(p_des_addr_48b[39:32],0,1);
        send_tx_data(p_des_addr_48b[31:24],0,1);
        send_tx_data(p_des_addr_48b[23:16],0,1);
        send_tx_data(p_des_addr_48b[15:8],0,1);
        send_tx_data(p_des_addr_48b[7:0],0,1);
        // Send Source Address
        send_tx_data(p_scr_addr_48b[47:40],0,1);
        send_tx_data(p_scr_addr_48b[39:32],0,1);
        send_tx_data(p_scr_addr_48b[31:24],0,1);
        send_tx_data(p_scr_addr_48b[23:16],0,1);
        send_tx_data(p_scr_addr_48b[15:8],0,1);
        send_tx_data(p_scr_addr_48b[7:0],0,1);
        // Send Length
        p_data_size_16b = p_data_size_16b ;
        send_tx_data(p_data_size_16b[15:8],0,1);
        send_tx_data(p_data_size_16b[7:0],0,1);
        for (m_idx_i = 0; m_idx_i < p_data_size_16b; m_idx_i = m_idx_i + 1) begin
          if (((m_idx_i + 1) == p_data_size_16b) && (!crc_err_b) && (!fifo_err_b) ) begin
            send_tx_data($random(),1,1);
          end else begin
            send_tx_data($random(),0,1);
          end
        end
        o_tx_edata_size   = o_tx_edata_idx;
     `ifndef RADIANT_ENV
      end
     `endif
      $display("WRITE TO Data Stream FIFO: Data size: %0d time: %0d", p_data_size_16b, $time);
      @(posedge i_txmac_clk);
      o_ds_lmmi_wr_rdn  = 1'b0;
      o_ds_lmmi_wdata   = 9'b0;
      crc_err_b         = 0;
      fifo_err_b        = 0;
      tx_done_b         = 1;
      while (i_ds_lmmi_ready  == 1'b0) begin
        @(posedge i_txmac_clk);
      end
      #1;
      //ds_lmmi_req_b = 1'b0;
    end
  endtask

  //1-------------------------------------------------------------------------------------------------
  // gen_tx_jumbo_frame :This method is used to send the jumbo frame into
  // transmitter
  //1-------------------------------------------------------------------------------------------------
  //        p_scr_addr_48b : Source address to send
  //        p_jum_type_16b : Jumbo type to send 
  //        p_size_bv      :Data to send 
  //1-------------------------------------------------------------------------------------------------
  task gen_tx_jumbo_frame;
    input   [47:0]  p_des_addr_48b;
    input   [47:0]  p_scr_addr_48b;
    input   [15:0]  p_jum_type_16b;
    input   [15:0]  p_size_16b;
    integer         m_idx_i;
    begin
      o_tx_edata_idx    = 0;
      o_tx_edata_size   = 0; 
      m_idx_i           = 0;
      @(posedge i_txmac_clk);
      $write("MSG :: @%0dns %m() :: TX Traffic Generation..... \n",$time);
      // Send Destination Address
      send_tx_data(p_des_addr_48b[47:40],0,1);
      send_tx_data(p_des_addr_48b[39:32],0,1);
      send_tx_data(p_des_addr_48b[31:24],0,1);
      send_tx_data(p_des_addr_48b[23:16],0,1);
      send_tx_data(p_des_addr_48b[15:8],0,1);
      send_tx_data(p_des_addr_48b[7:0],0,1);
      // Send Source Address
      send_tx_data(p_scr_addr_48b[47:40],0,1);
      send_tx_data(p_scr_addr_48b[39:32],0,1);
      send_tx_data(p_scr_addr_48b[31:24],0,1);
      send_tx_data(p_scr_addr_48b[23:16],0,1);
      send_tx_data(p_scr_addr_48b[15:8],0,1);
      send_tx_data(p_scr_addr_48b[7:0],0,1);
      // Send Jumbo Type
      send_tx_data(p_jum_type_16b[15:8],0,1);
      send_tx_data(p_jum_type_16b[7:0],0,1);
      // Send data
      for (m_idx_i = 0; m_idx_i < p_size_16b; m_idx_i = m_idx_i + 1) begin
        if (m_idx_i + 1 == p_size_16b) begin
          send_tx_data($random(),1,1);
        end else begin
          send_tx_data($random(),0,1);
        end
      end
      o_tx_edata_size   = o_tx_edata_idx;
      $display("WRITE TO Jumbo Frame into Stream FIFO: Data size: %0d %0d %0d %0d time: %0d", p_des_addr_48b, p_scr_addr_48b, p_jum_type_16b, p_size_16b, $time);
      @(posedge i_txmac_clk);
      o_ds_lmmi_wr_rdn  = 1'b0;
      o_ds_lmmi_wdata   = 9'b0;
      while (i_ds_lmmi_ready  == 1'b0) begin
        @(posedge i_txmac_clk);
      end
    end

  endtask 

  //1-------------------------------------------------------------------------------------------------
  // gen_tx_ctrl_frame :This method is used to send the pause control into
  // transmitter
  //1-------------------------------------------------------------------------------------------------
  //        p_scr_addr_48b     : Source address to be send 
  //        p_ctrl_type_16b    : Control type to be send 
  //        p_pause_opcode_16b : Pause opcode to be send 
  //        p_pause_quanta_16b : Pause quanta to be send 
  //        p_size_16b         : data size to send 
  //1-------------------------------------------------------------------------------------------------
  task gen_tx_ctrl_frame;
    input   [47:0]  p_scr_addr_48b;
    input   [15:0]  p_ctrl_type_16b;
    input   [15:0]  p_pause_opcode_16b;
    input   [15:0]  p_pause_quanta_16b;
    input   [15:0]  p_size_16b;
    integer         m_idx_i;
    begin
      o_tx_edata_idx    = 0;
      o_tx_edata_size   = 0; 
      m_idx_i           = 0;
      @(posedge i_txmac_clk);
      $write("MSG :: @%0dns %m() :: TX Traffic Generation..... \n",$time);
      tb_top.tx_fifoctrl_b = 1;  
      // Send Destination Address
      send_tx_data(8'h01,0,1);
      send_tx_data(8'h80,0,1);
      send_tx_data(8'hC2,0,1);
      send_tx_data(8'h00,0,1);
      send_tx_data(8'h00,0,1);
      send_tx_data(8'h01,0,1);
      // Send Source Address
      send_tx_data(p_scr_addr_48b[47:40],0,1);
      send_tx_data(p_scr_addr_48b[39:32],0,1);
      send_tx_data(p_scr_addr_48b[31:24],0,1);
      send_tx_data(p_scr_addr_48b[23:16],0,1);
      send_tx_data(p_scr_addr_48b[15:8],0,1);
      send_tx_data(p_scr_addr_48b[7:0],0,1);
      // Send Control Type
      send_tx_data(p_ctrl_type_16b[15:8],0,1);
      send_tx_data(p_ctrl_type_16b[7:0],0,1);
      // Send Control Opcode
      send_tx_data(p_pause_opcode_16b[15:8],0,1);
      send_tx_data(p_pause_opcode_16b[7:0],0,1);
      // Send Pause Quanta
      send_tx_data(p_pause_quanta_16b[15:8],0,1);
      send_tx_data(p_pause_quanta_16b[7:0],0,1);
      // Send Padding
      for (m_idx_i = 0; m_idx_i < p_size_16b; m_idx_i = m_idx_i + 1) begin
        if (m_idx_i + 1 == p_size_16b) begin
          send_tx_data(8'h0,1,1);
        end else begin
          send_tx_data(8'h0,0,1);
        end
      end
      o_tx_edata_size   = o_tx_edata_idx;
      $display("WRITE TO Control Frame into Stream FIFO: Data size: %0d %0d %0d %0d time: %0d", p_scr_addr_48b, p_ctrl_type_16b, p_pause_opcode_16b, p_size_16b, $time);
      @(posedge i_txmac_clk);
      o_ds_lmmi_wr_rdn  = 1'b0;
      o_ds_lmmi_wdata   = 9'b0;
      tb_top.tx_fifoctrl_b = 0;  
      while (i_ds_lmmi_ready  == 1'b0) begin
        @(posedge i_txmac_clk);
      end
      #1;
    end
  endtask

  //1-------------------------------------------------------------------------------------------------
  // gen_tx_vlan_frame :This method is used to send the VLAN tagged frame 
  // transmitter
  //1-------------------------------------------------------------------------------------------------
  //        p_wr_data_bv :Data to send 
  //1-------------------------------------------------------------------------------------------------
  task gen_tx_vlan_frame;
    input   [47:0]  p_scr_addr_48b;
    input   [47:0]  p_des_addr_48b;
    input   [15:0]  p_vlan_tag_16b;
    input   [15:0]  p_vlan_type_16b;
    input   [15:0]  p_size_16b;
    integer         m_idx_i;
    begin 
      o_tx_edata_idx    = 0;
      o_tx_edata_size   = 0; 
      m_idx_i           = 0;
      @(posedge i_txmac_clk);
      $write("MSG :: @%0dns %m() :: TX Traffic Generation..... \n",$time);
      // Send Destination Address
      send_tx_data(p_des_addr_48b[47:40],0,1);
      send_tx_data(p_des_addr_48b[39:32],0,1);
      send_tx_data(p_des_addr_48b[31:24],0,1);
      send_tx_data(p_des_addr_48b[23:16],0,1);
      send_tx_data(p_des_addr_48b[15:8],0,1);
      send_tx_data(p_des_addr_48b[7:0],0,1);
      // Send Source Address
      send_tx_data(p_scr_addr_48b[47:40],0,1);
      send_tx_data(p_scr_addr_48b[39:32],0,1);
      send_tx_data(p_scr_addr_48b[31:24],0,1);
      send_tx_data(p_scr_addr_48b[23:16],0,1);
      send_tx_data(p_scr_addr_48b[15:8],0,1);
      send_tx_data(p_scr_addr_48b[7:0],0,1);
      // Send VLAN Type
      send_tx_data(p_vlan_type_16b[15:8],0,1);
      send_tx_data(p_vlan_type_16b[7:0],0,1);
      // Send VLAN Opcode
      send_tx_data(p_vlan_tag_16b[15:8],0,1);
      send_tx_data(p_vlan_tag_16b[7:0],0,1);
      // Send size
      send_tx_data(p_size_16b[15:8],0,1);
      send_tx_data(p_size_16b[7:0],0,1);
      // Send Padding
     `ifndef RADIANT_ENV
      if (tb_top.rst_4b == 9) begin //Assert the hardware reset in VLAN Tag field
        while (tb_top.u_dut.U1_lscc_tx_mac.U1_lscc_tx_macsm.tx_rdfifo_st != 1) begin    
          @(posedge i_txmac_clk);
        end
        repeat(14) 
        @(posedge i_txmac_clk);
        tb_top.reset_n_r = 0;
        o_tx_edata_size  = 0;
        o_tx_edata_idx   = 0;
        @(posedge i_txmac_clk);
        tb_top.rst_4b    = 0;
        tb_top.reset_n_r = 1;
      end else begin  
      `endif
        for (m_idx_i = 0; m_idx_i < p_size_16b; m_idx_i = m_idx_i + 1) begin
          if (m_idx_i + 1 == p_size_16b) begin
            send_tx_data($random(),1,1);
          end else begin
            send_tx_data($random(),0,1);
          end
        end
     `ifndef RADIANT_ENV
      end
     `endif
      o_tx_edata_size   = o_tx_edata_idx;
      $display("WRITE TO VLAN Frame into Stream FIFO: Data size: %0d %0d %0d %0d time: %0d", p_scr_addr_48b, p_vlan_type_16b, p_vlan_tag_16b, p_size_16b, $time);
      @(posedge i_txmac_clk);
      o_ds_lmmi_wr_rdn  = 1'b0;
      o_ds_lmmi_wdata   = 9'b0;
      tb_top.tx_sndpausereq_b = 0;
      while (i_ds_lmmi_ready  == 1'b0) begin
        @(posedge i_txmac_clk);
      end
      #1;
    end
  endtask

  //1-------------------------------------------------------------------------------------------------
  // send_tx_data :This method is used send data into tx fifo  
  //1-------------------------------------------------------------------------------------------------
  //        p_wr_data_bv :Data to send 
  //1-------------------------------------------------------------------------------------------------
  task send_tx_data;
    input   [8:0]  p_data_9b;
    input   p_eof_b;
    input   p_exp_b;
    begin 
      @ (posedge i_txmac_clk)
      if (p_exp_b == 1) begin 
        if (SGMII_TSMAC == 1) begin 
          tx_edata_2d_64b[o_tx_edata_idx] = p_data_9b;
          o_tx_edata_idx  = o_tx_edata_idx + 1;
          o_ds_lmmi_wdata   = {p_eof_b,p_data_9b[7:0]};
		  o_ds_lmmi_wr_rdn  = 1'b1;
		  if (tb_top.sgmii_spd_2b == 0) begin 
            while (!tb_top.txmac_clk_en_i) begin 
              @(posedge i_txmac_clk);
            end
          end else if (tb_top.sgmii_spd_2b == 1) begin 
            repeat (9) begin 
              @(posedge i_txmac_clk);
            end
          end else if (tb_top.sgmii_spd_2b == 2) begin 
            repeat (99) begin 
              @(posedge i_txmac_clk);
            end
          end
        end else begin
          tx_edata_2d_64b[o_tx_edata_idx] = p_data_9b;
          o_tx_edata_idx  = o_tx_edata_idx + 1;
          o_ds_lmmi_wdata   = {p_eof_b,p_data_9b[7:0]};
		  o_ds_lmmi_wr_rdn  = 1'b1;
        end
      end
    end
  endtask

  //1###################################################################################################
  //Method to drive the input data to receiver
  //1###################################################################################################
  task  gen_rx_data;
    input   [47:0]  p_des_addr_48b;
    input   [47:0]  p_src_addr_48b;
    input   [15:0]  p_data_size_16b;
    integer m_idx_i;
    begin
      o_rx_edata_idx    = 0;
      o_rx_edata_size   = 0; 
      m_idx_i           = 0;
      rx_done_b         = 0;
      rx_crc_32b        = 32'hFFFF_FFFF;
	  o_rmii_rx_crs_dv  = 1;
      @(posedge i_rxmac_clk);
      $write("MSG :: @%0dns %m() :: RX Traffic Generation..... \n",$time);
      //Send Preamble
      repeat (7) begin 
        send_rx_data(8'h55,0,0);
      end
      //Send SFD
      send_rx_data(8'hD5,0,0);
      //Send Destination Address
      send_rx_data(p_des_addr_48b[47:40],1,1);
      send_rx_data(p_des_addr_48b[39:32],1,1);
      send_rx_data(p_des_addr_48b[31:24],1,1);
      send_rx_data(p_des_addr_48b[23:16],1,1);
      send_rx_data(p_des_addr_48b[15:8],1,1);
      send_rx_data(p_des_addr_48b[7:0],1,1);
      // Send Source Address
      send_rx_data(p_src_addr_48b[47:40],1,1);
      send_rx_data(p_src_addr_48b[39:32],1,1);
      send_rx_data(p_src_addr_48b[31:24],1,1);
      send_rx_data(p_src_addr_48b[23:16],1,1);
      send_rx_data(p_src_addr_48b[15:8],1,1);
      send_rx_data(p_src_addr_48b[7:0],1,1);
      // Send Length
      p_data_size_16b = p_data_size_16b ;
      send_rx_data(p_data_size_16b[15:8],1,1);
      send_rx_data(p_data_size_16b[7:0],1,1);
      for (m_idx_i = 0; m_idx_i < p_data_size_16b; m_idx_i = m_idx_i + 1) begin
        send_rx_data($random(),1,1);
      end
      rx_crc_32b[7:0]   = ~reverse_bits(rx_crc_32b[7:0]);
      rx_crc_32b[15:8]  = ~reverse_bits(rx_crc_32b[15:8]);
      rx_crc_32b[23:16] = ~reverse_bits(rx_crc_32b[23:16]);
      rx_crc_32b[31:24] = ~reverse_bits(rx_crc_32b[31:24]);
      // Send Length
      send_rx_data(rx_crc_32b[7:0],0,1);
      send_rx_data(rx_crc_32b[15:8],0,1);
      send_rx_data(rx_crc_32b[23:16],0,1);
      send_rx_data(rx_crc_32b[31:24],0,1);
      o_rx_edata_size = o_rx_edata_idx;
	  if(tb_top.rmii_100m_en == 0) begin
	    repeat (10) begin 
		  @ (posedge i_rxmac_clk); 
		end
	  end
	  else begin
      @ (posedge i_rxmac_clk);
      end	  
      o_rx_dv_b = 0;
      o_rx_er_b = 0;
      o_rxd_8b  = 0;
      o_rgmii_rx_ctl = 0;
      o_rgmii_rxd_4b = 0;
      o_rmii_rxd_2b    = 0;
      o_rmii_rx_crs_dv = 0;
      o_rmii_rx_er     = 0;
      rx_done_b = 1;
    end 
  endtask 
  //1###################################################################################################
  //Method to drive the input data to receiver
  //1###################################################################################################
  task send_rx_data;
    input [7:0] p_data_8b;
    input       p_crc_b;
    input       p_exp_b;
    begin
      if ( (CLASSIC_TSMAC == 1 || MII_GMII == 1) && (tb_top.cpu_if_gbit_en_o == 0 ) )
	  begin 
        @ (posedge i_rxmac_clk)
        o_rx_dv_b = 1;
        o_rx_er_b = 0;
        o_rxd_8b  = {4'b0 , p_data_8b[3:0]};
        @ (posedge i_rxmac_clk)
        o_rx_dv_b = 1;
        o_rx_er_b = 0;
        o_rxd_8b  = {4'b0 , p_data_8b[7:4]};
      end else if (RGMII == 1) begin 
        rgmii_rx_dv_b = 1;
        rgmii_rx_er_b = 0;
		if(tb_top.cpu_if_gbit_en_o == 1) begin
          @ (posedge i_rxmac_clk)
          o_rgmii_rxd_4b  = p_data_8b[3:0];
          o_rgmii_rx_ctl  = rgmii_rx_dv_b ^ rgmii_rx_er_b;
          @ (negedge i_rxmac_clk)
          o_rgmii_rxd_4b  = p_data_8b[7:4];
          o_rgmii_rx_ctl  = rgmii_rx_dv_b;
		end else begin
		  @ (posedge i_rxmac_clk)
          o_rgmii_rxd_4b  = p_data_8b[3:0];
          o_rgmii_rx_ctl  = rgmii_rx_dv_b ^ rgmii_rx_er_b;
          @ (posedge i_rxmac_clk)
          o_rgmii_rxd_4b  = p_data_8b[7:4];
          o_rgmii_rx_ctl  = rgmii_rx_dv_b;
		end
	  end else if (RMII == 1) begin 
        if(tb_top.rmii_100m_en == 0) begin
          o_rmii_rx_crs_dv = 1;
          o_rmii_rx_er     = 0;
          repeat (10) begin 
		    @ (posedge i_rxmac_clk); 
		  end
          o_rmii_rxd_2b  = p_data_8b[1:0];
          repeat (10) begin 
		    @ (posedge i_rxmac_clk); 
		  end
          o_rmii_rxd_2b  = p_data_8b[3:2];
		  repeat (10) begin 
		    @ (posedge i_rxmac_clk); 
		  end
          o_rmii_rxd_2b  = p_data_8b[5:4];
		  repeat (10) begin 
		    @ (posedge i_rxmac_clk); 
		  end
          o_rmii_rxd_2b  = p_data_8b[7:6];
		end
		else begin
		  o_rmii_rx_crs_dv = 1;
		  o_rmii_rx_er     = 0;
		  @ (posedge i_rxmac_clk)
		  o_rmii_rxd_2b  = p_data_8b[1:0];
		  @ (posedge i_rxmac_clk)
		  o_rmii_rxd_2b  = p_data_8b[3:2];
		  @ (posedge i_rxmac_clk)
		  o_rmii_rxd_2b  = p_data_8b[5:4];
		  @ (posedge i_rxmac_clk)
		  o_rmii_rxd_2b  = p_data_8b[7:6];
		end
      end else begin
        @ (posedge i_rxmac_clk)
        o_rx_dv_b = 1;
        o_rx_er_b = 0;
        o_rxd_8b  = p_data_8b;
      end
	  
      if (p_exp_b == 0) begin 
        if (SGMII_TSMAC == 1) begin 
          if (tb_top.sgmii_spd_2b == 0) begin 
            while (tb_top.rxmac_clk_en_i != 1) begin 
              @ (posedge i_rxmac_clk);
            end
          end else if (tb_top.sgmii_spd_2b == 1) begin 
            repeat (9) begin
              @ (posedge i_rxmac_clk);
            end
          end else if (tb_top.sgmii_spd_2b == 2) begin 
            repeat (99) begin
              @ (posedge i_rxmac_clk);
            end
          end
        end
	  end
	  
      if (p_exp_b == 1) begin 
        if (SGMII_TSMAC == 1) begin 
          if (tb_top.sgmii_spd_2b == 0) begin 
            while (tb_top.rxmac_clk_en_i != 1) begin 
              @ (posedge i_rxmac_clk);
            end
          end else if (tb_top.sgmii_spd_2b == 1) begin 
            repeat (9) begin
              @ (posedge i_rxmac_clk);
            end
          end else if (tb_top.sgmii_spd_2b == 2) begin 
            repeat (99) begin
              @ (posedge i_rxmac_clk);
            end
          end
          rx_edata_2d_64b[o_rx_edata_idx] = p_data_8b;
          o_rx_edata_idx  = o_rx_edata_idx + 1;
        end else begin
          rx_edata_2d_64b[o_rx_edata_idx] = p_data_8b;
          o_rx_edata_idx  = o_rx_edata_idx + 1;
        end
      end
      if (p_crc_b == 1) begin 
        if (tb_top.rxmac_clk_en_i) begin 
          rx_crc_32b = nextcrc(rx_crc_32b,p_data_8b);
        end
      end
    end
  endtask
  //1-------------------------------------------------------------------------------------------------
  // nextcrc :Calculate the CRC 
  //1-------------------------------------------------------------------------------------------------
  //               returns :Calculated 32 bit CRC 
  //               p_c_32b :CRC from last compute 
  //                p_d_8b :Input data width is 8bit 
  //1-------------------------------------------------------------------------------------------------
  function [31:0] nextcrc;
    input [31:0]           p_c_32b          ;
    input [7:0]            p_d_8b           ;
    reg   [31:0]           m_newcrc_32b     ; // Calculated new crc
    begin
      m_newcrc_32b[0]                = p_c_32b[24] ^ p_c_32b[30] ^ p_d_8b[ 1]  ^ p_d_8b[7];
      m_newcrc_32b[1]                = p_c_32b[25] ^ p_c_32b[31] ^ p_d_8b[ 0]  ^ p_d_8b[ 6]  ^ p_c_32b[24] ^ p_c_32b[30] ^ p_d_8b[ 1]  ^ p_d_8b[7];
      m_newcrc_32b[2]                = p_c_32b[26] ^ p_d_8b[ 5]  ^ p_c_32b[25] ^ p_c_32b[31] ^ p_d_8b[ 0]  ^ p_d_8b[ 6]  ^ p_c_32b[24] ^ p_c_32b[30] ^  p_d_8b[ 1]  ^ p_d_8b[ 7];
      m_newcrc_32b[3]                = p_c_32b[27] ^ p_d_8b[ 4]  ^ p_c_32b[26] ^ p_d_8b[5] ^ p_c_32b[25] ^ p_c_32b[31] ^ p_d_8b[ 0]  ^ p_d_8b[6];
      m_newcrc_32b[4]                = p_c_32b[28] ^ p_d_8b[ 3]  ^ p_c_32b[27] ^ p_d_8b[4] ^ p_c_32b[26] ^ p_d_8b[ 5]  ^ p_c_32b[24] ^ p_c_32b[30] ^  p_d_8b[ 1]  ^ p_d_8b[ 7];
      m_newcrc_32b[5]                = p_c_32b[29] ^ p_d_8b[ 2]  ^ p_c_32b[28] ^ p_d_8b[ 3]  ^ p_c_32b[27] ^ p_d_8b[4] ^ p_c_32b[25] ^ p_c_32b[31] ^  p_d_8b[ 0]  ^ p_d_8b[ 6]  ^ p_c_32b[24] ^ p_c_32b[30] ^ p_d_8b[ 1]  ^ p_d_8b[7];
      m_newcrc_32b[6]                = p_c_32b[30] ^ p_d_8b[ 1]  ^ p_c_32b[29] ^ p_d_8b[ 2]  ^ p_c_32b[28] ^ p_d_8b[3] ^ p_c_32b[26] ^ p_d_8b[5] ^  p_c_32b[25] ^ p_c_32b[31] ^ p_d_8b[ 0]  ^ p_d_8b[6];
      m_newcrc_32b[7]                = p_c_32b[31] ^ p_d_8b[ 0]  ^ p_c_32b[29] ^ p_d_8b[2] ^ p_c_32b[27] ^ p_d_8b[4] ^ p_c_32b[26] ^ p_d_8b[5] ^  p_c_32b[24] ^ p_d_8b[7];
      m_newcrc_32b[8]                = p_c_32b[0] ^ p_c_32b[28] ^ p_d_8b[3] ^ p_c_32b[27] ^ p_d_8b[4] ^ p_c_32b[25] ^ p_d_8b[6] ^ p_c_32b[24] ^ p_d_8b[7];
      m_newcrc_32b[9]                = p_c_32b[1] ^ p_c_32b[29] ^ p_d_8b[2] ^ p_c_32b[28] ^ p_d_8b[3] ^ p_c_32b[26] ^ p_d_8b[5] ^ p_c_32b[25] ^ p_d_8b[6];
      m_newcrc_32b[10]               = p_c_32b[2] ^ p_c_32b[29] ^ p_d_8b[2] ^ p_c_32b[27] ^ p_d_8b[4] ^ p_c_32b[26] ^ p_d_8b[5] ^ p_c_32b[24] ^ p_d_8b[7];
      m_newcrc_32b[11]               = p_c_32b[3] ^ p_c_32b[28] ^ p_d_8b[3] ^ p_c_32b[27] ^ p_d_8b[4] ^ p_c_32b[25] ^ p_d_8b[6] ^ p_c_32b[24] ^ p_d_8b[7];
      m_newcrc_32b[12]               = p_c_32b[4] ^ p_c_32b[29] ^ p_d_8b[2] ^ p_c_32b[28] ^ p_d_8b[3] ^ p_c_32b[26] ^ p_d_8b[5] ^ p_c_32b[25] ^ p_d_8b[6] ^  p_c_32b[24] ^ p_c_32b[30] ^ p_d_8b[1] ^ p_d_8b[7];
      m_newcrc_32b[13]               = p_c_32b[ 5] ^ p_c_32b[30] ^ p_d_8b[1] ^ p_c_32b[29] ^ p_d_8b[2] ^ p_c_32b[27] ^ p_d_8b[4] ^ p_c_32b[26] ^ p_d_8b[5] ^  p_c_32b[25] ^ p_c_32b[31] ^ p_d_8b[0] ^ p_d_8b[ 6];
      m_newcrc_32b[14]               = p_c_32b[ 6] ^ p_c_32b[31] ^ p_d_8b[0] ^ p_c_32b[30] ^ p_d_8b[1] ^ p_c_32b[28] ^ p_d_8b[3] ^ p_c_32b[27] ^ p_d_8b[4] ^  p_c_32b[26] ^ p_d_8b[5];
      m_newcrc_32b[15]               = p_c_32b[7] ^ p_c_32b[31] ^ p_d_8b[0] ^ p_c_32b[29] ^ p_d_8b[2] ^ p_c_32b[28] ^ p_d_8b[3] ^ p_c_32b[27] ^ p_d_8b[4];
      m_newcrc_32b[16]               = p_c_32b[8] ^ p_c_32b[29] ^ p_d_8b[2] ^ p_c_32b[28] ^ p_d_8b[3] ^ p_c_32b[24] ^ p_d_8b[7];
      m_newcrc_32b[17]               = p_c_32b[9] ^ p_c_32b[30] ^ p_d_8b[1] ^ p_c_32b[29] ^ p_d_8b[2] ^ p_c_32b[25] ^ p_d_8b[6];
      m_newcrc_32b[18]               = p_c_32b[10] ^ p_c_32b[31] ^ p_d_8b[0] ^ p_c_32b[30] ^ p_d_8b[1] ^ p_c_32b[26] ^ p_d_8b[5];
      m_newcrc_32b[19]               = p_c_32b[11] ^ p_c_32b[31] ^ p_d_8b[0] ^ p_c_32b[27] ^ p_d_8b[4];
      m_newcrc_32b[20]               = p_c_32b[12] ^ p_c_32b[28] ^ p_d_8b[3];
      m_newcrc_32b[21]               = p_c_32b[13] ^ p_c_32b[29] ^ p_d_8b[2];
      m_newcrc_32b[22]               = p_c_32b[14] ^ p_c_32b[24] ^ p_d_8b[7];
      m_newcrc_32b[23]               = p_c_32b[15] ^ p_c_32b[25] ^ p_d_8b[6] ^ p_c_32b[24] ^ p_c_32b[30] ^ p_d_8b[1] ^ p_d_8b[7];
      m_newcrc_32b[24]               = p_c_32b[16] ^ p_c_32b[26] ^ p_d_8b[5] ^ p_c_32b[25] ^ p_c_32b[31] ^ p_d_8b[0] ^ p_d_8b[6];
      m_newcrc_32b[25]               = p_c_32b[17] ^ p_c_32b[27] ^ p_d_8b[4] ^ p_c_32b[26] ^ p_d_8b[5];
      m_newcrc_32b[26]               = p_c_32b[18] ^ p_c_32b[28] ^ p_d_8b[3] ^ p_c_32b[27] ^ p_d_8b[4] ^ p_c_32b[24] ^ p_c_32b[30] ^ p_d_8b[1] ^ p_d_8b[7];
      m_newcrc_32b[27]               = p_c_32b[19] ^ p_c_32b[29] ^ p_d_8b[2] ^ p_c_32b[28] ^ p_d_8b[3] ^ p_c_32b[25] ^ p_c_32b[31] ^ p_d_8b[0] ^ p_d_8b[6];
      m_newcrc_32b[28]               = p_c_32b[20] ^ p_c_32b[30] ^ p_d_8b[1] ^ p_c_32b[29] ^ p_d_8b[2] ^ p_c_32b[26] ^ p_d_8b[5];
      m_newcrc_32b[29]               = p_c_32b[21] ^ p_c_32b[31] ^ p_d_8b[0] ^ p_c_32b[30] ^ p_d_8b[1] ^ p_c_32b[27] ^ p_d_8b[4];
      m_newcrc_32b[30]               = p_c_32b[22] ^ p_c_32b[31] ^ p_d_8b[0] ^ p_c_32b[28] ^ p_d_8b[3];
      m_newcrc_32b[31]               = p_c_32b[23] ^ p_c_32b[29] ^ p_d_8b[2];
      nextcrc                        = m_newcrc_32b;
    end
  endfunction
  //1-------------------------------------------------------------------------------------------------
  // reverse_bits :This function is used for reversing bits in a byte 
  //1-------------------------------------------------------------------------------------------------
  //               returns :Reversed byte 
  //             p_data_8b :Data to do bit reverse 
  //1-------------------------------------------------------------------------------------------------
  function [7:0] reverse_bits;
    input [7:0]     p_data_8b ;
    reg   [7:0]     m_data_8b ; // Reversed temp data
    begin
      m_data_8b[0]                   = p_data_8b[7];
      m_data_8b[1]                   = p_data_8b[6];
      m_data_8b[2]                   = p_data_8b[5];
      m_data_8b[3]                   = p_data_8b[4];
      m_data_8b[4]                   = p_data_8b[3];
      m_data_8b[5]                   = p_data_8b[2];
      m_data_8b[6]                   = p_data_8b[1];
      m_data_8b[7]                   = p_data_8b[0];
      reverse_bits                   = m_data_8b;
    end
  endfunction

endmodule
`endif
