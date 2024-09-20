`ifndef TSE_MAC_OUTPUT_MONITOR_V
`define TSE_MAC_OUTPUT_MONITOR_V
//0---------------------------------------------------------------------------------------------------
// File Name      : tse_mac_output_monitor.v
// Project        : TSE_MAC IIP
// Date Created   : 14-06-2020
// Description    : This is used for Output monitor
// Generator      : Test bench Compiler Version 1.1
//0---------------------------------------------------------------------------------------------------

`timescale 1ns/1ps
`include "tse_mac_defines.v"

module tse_mac_output_monitor #(

  //1###################################################################################################
  // Parameter Declaration
  //1###################################################################################################
  parameter MII_GMII      = 0,
  parameter SGMII_TSMAC   = 0,
  parameter CLASSIC_TSMAC = 0,
  parameter GBE_MAC       = 1,
  parameter MIIM_MODULE   = 0,
  parameter RGMII         = 0
  ) (
  //1###################################################################################################
  // Input/Output Signal Declaration
  //1###################################################################################################
  input   wire       i_tx_mac_clk,       // Transmitter clk 
  input   wire       i_tx_mac_clk_en,    // Transmitter clk enable
  input   wire [7:0] i_txd,              // Transmitter output data
  input   wire       i_tx_en,            // Transmitter output enable
  input   wire       i_tx_er,            // Transmitter output error
  input   wire [3:0] i_rgmii_txd,        // RGMII Transmitter input data
  input   wire       i_rgmii_tx_ctl,     // RGMII Transmitter input control
  input   wire [7:0] i_mii_gmii_txd,     // MII/GMII Transmitter input data
  input   wire       i_mii_gmii_tx_en,   // MII/GMII Transmitter input data valid
  input   wire       i_mii_gmii_tx_er,   // MII/GMII Transmitter input error
  output  reg [31:0] o_tx_gdata_idx,     // Transmitter got data index
  output  reg [31:0] o_tx_gdata_size,    // Transmitter got data size
  input   wire       i_rx_mac_clk,       // Receiver clk 
  input   wire       i_rx_ready,         // Receiver input ready
  input   wire       i_rx_data_valid,    // Receiver data valid
  input   wire [7:0] i_rx_data,          // Receiver output data
  output  reg [31:0] o_rx_gdata_idx,     // Receiver got data index
  output  reg [31:0] o_rx_gdata_size,    // Receiver got data size
  input   wire       i_mdc,              // MIIM clock signal
  input   wire       i_mdo,              // MIIM data signal
  output  reg [31:0] o_mdio_gdata_idx,   // MIIM Transmitter got data index
  output  reg [31:0] o_mdio_gdata_size,  // MIIM Transmitter got data size
  output  reg [7:0]  o_tx_data_8b,       // RGMII TX data
  output  reg        o_tx_en,            // RGMII TX enable
  output  reg        o_tx_err            // RGMII TX error

  );
  //1###################################################################################################
  // Local Variable Declaration
  //1###################################################################################################
  integer     tx_state_i                ; // Transmitter state vector
  integer     idx_i                     ; // Index
  reg [2:0]   tx_pre_cnt_3b             ; // Transmitter peramble count
  reg [6:0]   tx_ipg_cnt_7b             ; // Transmitter ipg count
  reg [63:0]  tx_gdata_2d_64b [0:64999] ; // Got data array
  integer     rx_state_i                ; // Receiver state vector
  integer     rx_idx_i                  ; // Reciever Index
  integer     cnt_i                     ; // Variable for local count
  reg [63:0]  rx_gdata_2d_64b [0:64999] ; // Got data array
  reg [7:0]   tx_data_8b                ; // Transmitter sampled data for classic mac 100M mode
  reg [3:0]   rgmii_tx_ndata            ; // Transmitter sampled data for RGMII mode
  reg         rgmii_tx_nctrl            ; // Variable for RGMII control signal 
  reg         tx_nibble_b               ; // Variable for nibble
  reg         tx_byte_b                 ; // variable for byte enable
  integer     mdio_state_i              ; // MIIM Transmitter state vector
  integer     pre_cnt_i                 ; // Variable for MIIM preamble count
  integer     ref_cnt_i                 ; // Variable for reference count
  reg         mdio_start_b              ; // variable for MIIM start bit 
  reg [31:0]  mdio_gdata_2d_32b         ; // MIIM Got data array


  //1###################################################################################################
  // Initilize all the variales
  //1###################################################################################################
  initial
  begin
    o_tx_gdata_idx      = 0; 
    o_tx_gdata_size     = 0; 
    tx_state_i          = 0;  
    tx_pre_cnt_3b       = 0;  
    tx_ipg_cnt_7b       = 0; 
    idx_i               = 0;
    rx_state_i          = 0;  
    rx_idx_i            = 0;
    cnt_i               = 0;
    o_rx_gdata_idx      = 0;
    o_rx_gdata_size     = 0;
    tx_data_8b          = 0; 
    o_tx_data_8b        = 0; 
    tx_nibble_b         = 0; 
    tx_byte_b           = 0; 
    rgmii_tx_ndata      = 0; 
    o_tx_en             = 0; 
    o_tx_err            = 0; 
    rgmii_tx_nctrl      = 0; 
    o_mdio_gdata_idx    = 0; 
    o_mdio_gdata_size   = 0; 
    mdio_gdata_2d_32b   = 0; 
    mdio_state_i        = 0;  
    mdio_start_b        = 0; 
    ref_cnt_i           = 0;  
    pre_cnt_i           = 0;  
    //2-----------------------------------------------------------------------------------------------
    // Initialize the memory 
    //2-----------------------------------------------------------------------------------------------
    for (idx_i = 0; idx_i < 65000; idx_i = idx_i + 1) begin
      tx_gdata_2d_64b[idx_i]     = 0;
      rx_gdata_2d_64b[rx_idx_i]  = 0;
    end
  end

  //1-------------------------------------------------------------------------------------------------
  // collect_tx_frame :This method is used for collect transmit frame 
  //1-------------------------------------------------------------------------------------------------
  always @ (posedge i_tx_mac_clk) begin 

   if ((CLASSIC_TSMAC == 1) && (tb_top.cpu_if_gbit_en_o == 0)) begin 
     case(tx_state_i)
       //---------------------------------------------------------------------------------
       // Case item to wait transmitter enable 
       //---------------------------------------------------------------------------------
       0   : begin
         if (i_tx_en == 1 && i_tx_mac_clk_en == 1) begin
           $write("MSG :: @%0dns %m() :: Sampling data from the TSE-MAC Transmitter..... \n",$time);
           tx_state_i = 1;
           if (tx_nibble_b == 1) begin
              tx_data_8b[7:4] = i_txd[3:0];
              tx_nibble_b = 0;
              tx_byte_b = 1;
              tx_pre_cnt_3b = 1;
           end else begin
              tx_data_8b[3:0] = i_txd[3:0];
              tx_nibble_b = 1;
           end
           //if (tx_ipg_cnt_7b < 12) begin
           //  $error("Expected Minimum IPG size is %0d, Got %0d",12,tx_ipg_cnt_7b);
           //  process_err();
           //end
         end
       end
       //---------------------------------------------------------------------------------
       // Case item to wait preamble and sfd 
       //---------------------------------------------------------------------------------
       1   : begin
         if (i_tx_en == 1 && i_tx_mac_clk_en == 1) begin
           if (tx_nibble_b == 1) begin
              tx_data_8b[7:4] = i_txd[3:0];
              tx_nibble_b = 0;
              tx_byte_b = 1;
           end else begin
              tx_data_8b[3:0] = i_txd[3:0];
              tx_nibble_b = 1;
           end
           if (tx_byte_b == 1) begin
             tx_byte_b = 0;
             if (tx_data_8b == 8'hD5 && i_tx_mac_clk_en == 1) begin
               tx_state_i = 2;
               if (tx_pre_cnt_3b != 7) begin
                 if (tx_pre_cnt_3b < 7) begin
                   $error("Expected Preamble length %0d, Got %0d",7,tx_pre_cnt_3b);
                   //U_scoreboard.process_err();
                 end 
               end
               tx_pre_cnt_3b = 0;
             end else begin
               tx_pre_cnt_3b  = tx_pre_cnt_3b + 1;
             end
           end
         end
       end
       //---------------------------------------------------------------------------------
       // Case item for collect all datas 
       //---------------------------------------------------------------------------------
       2   : begin
         if (i_tx_en == 1 ) begin
           if (i_tx_mac_clk_en == 1) begin
              if (tx_nibble_b == 1) begin
                 tx_data_8b[7:4] = i_txd[3:0];
                 tx_nibble_b = 0;
                 tx_byte_b = 1;
              end else begin
                 tx_data_8b[3:0] = i_txd[3:0];
                 tx_nibble_b = 1;
              end
              if (tx_byte_b == 1) begin
                 tx_byte_b = 0;
                 tx_gdata_2d_64b[o_tx_gdata_idx] = tx_data_8b;
                 o_tx_gdata_idx  = o_tx_gdata_idx + 1;
                 if (i_tx_er == 0) begin
                 end
              end
           end
         end else begin
           o_tx_gdata_size = o_tx_gdata_idx - 4;
           @(posedge i_tx_mac_clk);
           @(posedge i_tx_mac_clk);
           //U_scoreboard.check_tx_frame();
           tx_state_i      = 0;
           o_tx_gdata_idx  = 0;
           o_tx_gdata_size = 0;
         end
       end
     endcase
   end else if (RGMII == 1) begin 
     case(tx_state_i)
       //---------------------------------------------------------------------------------
       // Case item to wait transmitter enable 
       //---------------------------------------------------------------------------------
       0   : begin
         if (i_rgmii_tx_ctl == 1 && i_tx_mac_clk_en == 1) begin
           $write("MSG :: @%0dns %m() :: Sampling data from the TSE-MAC Transmitter..... \n",$time);
           tx_state_i = 1;
           tx_pre_cnt_3b = 1;
           o_tx_data_8b = {i_rgmii_txd,rgmii_tx_ndata};
           o_tx_en = rgmii_tx_nctrl;
           o_tx_err = i_rgmii_tx_ctl ^ rgmii_tx_nctrl;
           //if (tx_ipg_cnt_7b < 12) begin
           //  $error("Expected Minimum IPG size is %0d, Got %0d",12,tx_ipg_cnt_7b);
           //  process_err();
           //end
         end
       end
       //---------------------------------------------------------------------------------
       // Case item to wait preamble and sfd 
       //---------------------------------------------------------------------------------
       1   : begin
         if (i_rgmii_tx_ctl == 1 && i_tx_mac_clk_en == 1) begin
           o_tx_data_8b = {i_rgmii_txd,rgmii_tx_ndata};
           o_tx_en = rgmii_tx_nctrl;
           o_tx_err = i_rgmii_tx_ctl ^ rgmii_tx_nctrl;
             if (o_tx_data_8b == 8'hD5 && i_tx_mac_clk_en == 1) begin
               tx_state_i = 2;
               if (tx_pre_cnt_3b != 7) begin
                 if (tx_ipg_cnt_7b < 12) begin
                   $error("Expected Preamble length %0d, Got %0d",7,tx_pre_cnt_3b);
                   //U_scoreboard.process_err();
                 end 
               end
             end else begin
               tx_pre_cnt_3b  = tx_pre_cnt_3b + 1;
             end
         end
       end
       //---------------------------------------------------------------------------------
       // Case item for collect all datas 
       //---------------------------------------------------------------------------------
       2   : begin
         if (i_rgmii_tx_ctl == 1 ) begin
           if (i_tx_mac_clk_en == 1) begin
              o_tx_data_8b = {i_rgmii_txd,rgmii_tx_ndata};
              o_tx_en =  rgmii_tx_nctrl;
              o_tx_err = i_rgmii_tx_ctl ^ rgmii_tx_nctrl;
              tx_gdata_2d_64b[o_tx_gdata_idx] = o_tx_data_8b;
              o_tx_gdata_idx  = o_tx_gdata_idx + 1;
           end
         end else begin
           o_tx_gdata_size = o_tx_gdata_idx - 4;
           @(posedge i_tx_mac_clk);
           o_tx_en =  0;
           o_tx_err = 0;
           o_tx_data_8b = 0;
           //@(posedge i_tx_mac_clk);
           //U_scoreboard.check_tx_frame();
           tx_state_i      = 0;
           o_tx_gdata_idx  = 0;
           o_tx_gdata_size = 0;
         end
       end
     endcase
	 
   end else if (MII_GMII == 1) begin 
     case(tx_state_i)
       //---------------------------------------------------------------------------------
       // Case item to wait transmitter enable 
       //---------------------------------------------------------------------------------
       0   : begin
         if (i_mii_gmii_tx_en == 1 && i_tx_mac_clk_en == 1) begin
           $write("MSG :: @%0dns %m() :: Sampling data from the TSE-MAC Transmitter..... \n",$time);
           tx_state_i = 1;
           tx_pre_cnt_3b = 1;
           o_tx_data_8b = i_mii_gmii_txd;
           o_tx_en = i_mii_gmii_tx_en;
           o_tx_err = i_mii_gmii_tx_er;
           //if (tx_ipg_cnt_7b < 12) begin
           //  $error("Expected Minimum IPG size is %0d, Got %0d",12,tx_ipg_cnt_7b);
           //  process_err();
           //end
         end
       end
       //---------------------------------------------------------------------------------
       // Case item to wait preamble and sfd 
       //---------------------------------------------------------------------------------
       1   : begin
         if (i_mii_gmii_tx_en == 1 && i_tx_mac_clk_en == 1) begin
           o_tx_data_8b = i_mii_gmii_txd;
           o_tx_en = i_mii_gmii_tx_en;
           o_tx_err = i_mii_gmii_tx_er;
             if (o_tx_data_8b == 8'hD5 && i_tx_mac_clk_en == 1) begin
               tx_state_i = 2;
               if (tx_pre_cnt_3b != 7) begin
                 if (tx_ipg_cnt_7b < 12) begin
                   $error("Expected Preamble length %0d, Got %0d",7,tx_pre_cnt_3b);
                   //U_scoreboard.process_err();
                 end 
               end
             end else begin
               tx_pre_cnt_3b  = tx_pre_cnt_3b + 1;
             end
         end
       end
       //---------------------------------------------------------------------------------
       // Case item for collect all datas 
       //---------------------------------------------------------------------------------
       2   : begin
         if (i_mii_gmii_tx_en == 1 ) begin
           if (i_tx_mac_clk_en == 1) begin
              o_tx_data_8b = i_mii_gmii_txd;
              o_tx_en =  i_mii_gmii_tx_en;
              o_tx_err = i_mii_gmii_tx_er;
              tx_gdata_2d_64b[o_tx_gdata_idx] = o_tx_data_8b;
              o_tx_gdata_idx  = o_tx_gdata_idx + 1;
           end
         end else begin
           o_tx_gdata_size = o_tx_gdata_idx - 4;
           @(posedge i_tx_mac_clk);
           o_tx_en =  0;
           o_tx_err = 0;
           o_tx_data_8b = 0;
           //@(posedge i_tx_mac_clk);
           //U_scoreboard.check_tx_frame();
           tx_state_i      = 0;
           o_tx_gdata_idx  = 0;
           o_tx_gdata_size = 0;
         end
       end
     endcase
   end else begin
     case(tx_state_i)
       //---------------------------------------------------------------------------------
       // Case item to wait transmitter enable 
       //---------------------------------------------------------------------------------
       0   : begin
         if (i_tx_en == 1 && i_tx_mac_clk_en == 1) begin
           $write("MSG :: @%0dns %m() :: Sampling data from the TSE-MAC Transmitter..... \n",$time);
           tx_state_i = 1;
           tx_pre_cnt_3b = 1;
           //if (tx_ipg_cnt_7b < 12) begin
           //  $error("Expected Minimum IPG size is %0d, Got %0d",12,tx_ipg_cnt_7b);
           //  process_err();
           //end
         end
       end
       //---------------------------------------------------------------------------------
       // Case item to wait preamble and sfd 
       //---------------------------------------------------------------------------------
       1   : begin
         if (i_tx_en == 1 && i_tx_mac_clk_en == 1) begin
           if (i_txd == 8'hD5 && i_tx_mac_clk_en == 1) begin
             tx_state_i = 2;
             if (tx_pre_cnt_3b != 7) begin
               if (tx_ipg_cnt_7b < 12) begin
                 $error("Expected Preamble length %0d, Got %0d",7,tx_pre_cnt_3b);
                 //U_scoreboard.process_err();
               end 
             end
           end else begin
             tx_pre_cnt_3b  = tx_pre_cnt_3b + 1;
           end
         end
       end
       //---------------------------------------------------------------------------------
       // Case item for collect all datas 
       //---------------------------------------------------------------------------------
       2   : begin
         if (i_tx_en == 1 ) begin
           if (i_tx_mac_clk_en == 1) begin
             tx_gdata_2d_64b[o_tx_gdata_idx] = i_txd;
             o_tx_gdata_idx  = o_tx_gdata_idx + 1;
             if (i_tx_er == 0) begin
             end
           end
         end else begin
           o_tx_gdata_size = o_tx_gdata_idx - 4;
           @(posedge i_tx_mac_clk);
           //U_scoreboard.check_tx_frame();
           tx_state_i      = 0;
           o_tx_gdata_idx  = 0;
           o_tx_gdata_size = 0;
         end
       end
     endcase
   end
  end
generate 
  if (RGMII) begin 
    always @(negedge i_tx_mac_clk) begin
       if (i_rgmii_tx_ctl == 1 && i_tx_mac_clk_en == 1) begin
         rgmii_tx_ndata <= i_rgmii_txd;
         rgmii_tx_nctrl <= i_rgmii_tx_ctl;
       end
    end
  end else if(MIIM_MODULE) begin
    always @(posedge i_mdc) begin
     case(mdio_state_i)
       //---------------------------------------------------------------------------------
       // Case item to wait transmitter enable 
       //---------------------------------------------------------------------------------
       0   : begin
         if (tb_top.mdio_en_o == 1) begin
           if (pre_cnt_i == 1) begin
             $write("MSG :: @%0dns %m() :: Sampling MDIO data from the TSE-MAC Transmitter..... \n",$time);
           end
           if (i_mdo == 1'b0) begin
             mdio_start_b = 1;
             if (pre_cnt_i < 32) begin
               $error("Expected Minimum PREAMBLE size is %0d, Got %0d",32,pre_cnt_i);
             end
             pre_cnt_i  = 0;
           end else if (mdio_start_b == 1) begin
             mdio_state_i = 1;
           end else begin
             pre_cnt_i  = pre_cnt_i + 1;
           end
           //if (tx_ipg_cnt_7b < 12) begin
           //  $error("Expected Minimum IPG size is %0d, Got %0d",12,tx_ipg_cnt_7b);
           //  process_err();
           //end
         end
       end
       //---------------------------------------------------------------------------------
       // Case item to wait preamble and sfd 
       //---------------------------------------------------------------------------------
       1   : begin
         if (tb_top.mdio_en_o == 1) begin
           ref_cnt_i = ref_cnt_i + 1;
           if (ref_cnt_i == 13 || ref_cnt_i == 14) begin
           end else begin
             mdio_gdata_2d_32b[o_mdio_gdata_idx] = i_mdo;
             o_mdio_gdata_idx = o_mdio_gdata_idx + 1; 
           end
         end else begin
           if (ref_cnt_i == 30) begin
             o_mdio_gdata_size = o_mdio_gdata_idx;
             @(posedge i_mdc);
             mdio_state_i      = 0;
             o_mdio_gdata_idx  = 0;
             o_mdio_gdata_size = 0;
             mdio_start_b      = 0;
             ref_cnt_i = 0;
           end else begin
             mdio_state_i      = 0;
             mdio_start_b      = 0;
           end
         end
       end
     endcase
    end
  end
endgenerate

  //1-------------------------------------------------------------------------------------------------
  // collect_rx_frame :This method is used for collect receive frame 
  //1-------------------------------------------------------------------------------------------------
  //             parameter :No parameter 
  //1-------------------------------------------------------------------------------------------------
  task collect_rx_frame;
    begin
      o_rx_gdata_idx   = 0;
      //o_rx_gdata_size  = 0;
      $display("Start collect RX Packet");
      while (1) begin
        @(posedge i_rx_mac_clk);
        case(rx_state_i)
          //---------------------------------------------------------------------------------
          // Case item to wait Receive data ready 
          //---------------------------------------------------------------------------------
          0   : begin
            if (i_rx_ready == 1) begin
              //tb_top.drive_reset(0,10);
              if(i_rx_data_valid == 1 && tb_top.rxmac_clk_en_i) begin
               $write("MSG :: @%0dns %m() :: Sampling data from the TSE-MAC Receiver..... \n",$time);
               rx_state_i = 1;
               rx_gdata_2d_64b[o_rx_gdata_idx] = i_rx_data;
               o_rx_gdata_idx = o_rx_gdata_idx + 1;
              end
            end
          end
          //---------------------------------------------------------------------------------
          // Case item for collect all datas 
          //---------------------------------------------------------------------------------
          1   : begin
            if (i_rx_data_valid == 1 && tb_top.rxmac_clk_en_i) begin
              //if (cnt_i == 14) begin
              rx_gdata_2d_64b[o_rx_gdata_idx] = i_rx_data;
              o_rx_gdata_idx  = o_rx_gdata_idx + 1;
              //end else begin
              //  cnt_i = cnt_i + 1;
              //end
            end else if (!i_rx_data_valid) begin
              o_rx_gdata_size = o_rx_gdata_idx;
              @(posedge i_rx_mac_clk);
              rx_state_i      = 0;
              o_rx_gdata_idx  = 0;
              cnt_i           = 0;
              o_rx_gdata_size = 0;
            end
          end
        endcase
      end
    end
  endtask

endmodule
`endif
