`ifndef TSE_MAC_SCOREBOARD_V
`define TSE_MAC_SCOREBOARD_V
//0---------------------------------------------------------------------------------------------------
// File Name      : tse_mac_scoreboard.v
// Project        : TSE_MAC IIP
// Date Created   : 30-06-2020
// Description    : This is used for Transmitter Scoreboard
// Generator      : Test bench Compiler Version 1.1
//0---------------------------------------------------------------------------------------------------

`timescale 1ns/1ps
`include "tse_mac_defines.v"

module tse_mac_scoreboard #(

  //1###################################################################################################
  // Parameter Declaration
  //1###################################################################################################
  parameter SGMII_TSMAC   = 0,
  parameter CLASSIC_TSMAC = 0,
  parameter GBE_MAC       = 1,
  parameter MIIM_MODULE   = 0,
  parameter RGMII         = 0
  ) (

  //1###################################################################################################
  // Input/Output Signal Declaration
  //1###################################################################################################
  input  wire [31:0] i_tx_edata_size,    // Transmitter expected data size
  input  wire [31:0] i_tx_gdata_size,    // Transmitter got data size
  input  wire [31:0] i_rx_edata_size,    // Transmitter expected data size
  input  wire [31:0] i_rx_gdata_size,    // Transmitter got data size
  input  wire [31:0] i_mdio_gdata_size   // Transmitter MIIM got data size

  ); 

  //1###################################################################################################
  // Local Variable Declaration
  //1###################################################################################################
    integer     idx_i;
    reg         m_err_b;
    integer     rx_idx_i;
    reg         m_rx_err_b;
    reg [127:0] rx_exp_data_128b;
    reg [127:0] rx_got_data_128b;
    reg [15:0]  mdio_exp_data_16b;
    reg [1:0]   mdio_exp_opcode_2b;
    reg [4:0]   mdio_exp_phy_addr_5b;
    reg [4:0]   mdio_exp_reg_addr_5b;
    reg [15:0]  mdio_got_data_16b;
    reg [1:0]   mdio_got_opcode_2b;
    reg [4:0]   mdio_got_phy_addr_5b;
    reg [4:0]   mdio_got_reg_addr_5b;
    integer     mdio_idx_i;
    reg [7:0]   mdio_exp_data_8b;
    reg [7:0]   mdio_addr_8b;
    reg         regression_b;
    reg [127:0] tx_exp_data_128b;
    reg [127:0] tx_got_data_128b;

    initial
    begin
      regression_b = `REGRESSION;
    end

  //1###################################################################################################
  //Always block to compaer the data for the Transmitter 
  //1###################################################################################################
    always @ (posedge tb_top.txmac_clk_i) begin 
      if (!tb_top.reset_n_i) begin 
        idx_i            = 0;
        tx_exp_data_128b = 0;
        tx_got_data_128b = 0;
        m_err_b          = 0;
      end else begin 
        if (i_tx_gdata_size != 0) begin 
          tx_checker();
        end
      end
    end

  //1###################################################################################################
  //Always block to compaer the data for the Receiver 
  //1###################################################################################################
    always @ (posedge tb_top.rxmac_clk_i) begin 
      if (!tb_top.reset_n_i) begin 
        rx_idx_i          = 0;
        rx_exp_data_128b  = 0;
        rx_got_data_128b  = 0;
        m_rx_err_b        = 0;
      end else begin 
        if (i_rx_gdata_size != 0) begin 
          rx_checker();
        end
      end
    end

  //1###################################################################################################
  //Always block to compaer the data for the MIIM module Tranmitter 
  //1###################################################################################################
    always @ (posedge tb_top.mdc_i) begin 
      if (!tb_top.reset_n_i) begin 
        mdio_idx_i           = 0;
        mdio_exp_data_16b    = 0;
        mdio_exp_opcode_2b   = 0;
        mdio_exp_phy_addr_5b = 0;
        mdio_exp_reg_addr_5b = 0;
        mdio_got_data_16b    = 0;
        mdio_got_opcode_2b   = 0;
        mdio_got_phy_addr_5b = 0;
        mdio_got_reg_addr_5b = 0;
        mdio_addr_8b         = 0;
      end else begin 
        if (i_mdio_gdata_size != 0) begin 
          mdio_checker();
        end
      end
    end


  //-------------------------------------------------------------------------------------------------
  // process_err
  //-------------------------------------------------------------------------------------------------
  task process_err;
    begin
      tb_top.errs_i = tb_top.errs_i + 1;
      if (tb_top.finish_on_error_b == 1) begin
        $finish(1);
      end
    end
  endtask

  //1-------------------------------------------------------------------------------------------------
  // tx_checker :This method is used for checking data
  //1-------------------------------------------------------------------------------------------------
  //             parameter :No parameter 
  //1-------------------------------------------------------------------------------------------------
  task automatic tx_checker;
    reg [255:0]                    m_cmp_s                      ; // Result of compare function
    reg [255:0]                    m_r_s                        ; // Result of compare function
    reg                            m_result_b                   ; // Hold the result of compare
    integer                        m_i_i                        ; // Iterative variable
    integer                        m_j_i                        ; // Iterative variable
    integer                        m_size_i                     ; // Variable to hold the array size
    reg                            m_valid_b                    ; // Variable for dummy flag

    begin
      m_i_i                          = 0; 
      m_j_i                          = 0; 
      m_size_i                       = 0; 
      m_result_b                     = 0; 
      m_cmp_s                        = ""; 
      m_r_s                          = ""; 
      //---------------------------------------------------------------------------------------------
      // Mismatch exp and got size
      //---------------------------------------------------------------------------------------------  
      if(regression_b == 0)begin
        $write("\n");
        $write("+----------------------------------------------------------------------------+\n");
        $write("| FIELD               | EXPECTED                  | GOT                      |\n");
        $write("+----------------------------------------------------------------------------+\n");
      end
      if (i_tx_edata_size != i_tx_gdata_size) begin
        m_r_s = "X";
        m_result_b = 0;
        if(regression_b == 0)begin
          $write("| SIZE                    | %0d                                     %0s %0d                                |\n",i_tx_edata_size,m_r_s,i_tx_gdata_size);
          $write("MSG :: @%0dns %m() :: ERROR Expected size %0d Got %0d\n",
           $time,i_tx_edata_size,i_tx_gdata_size);
         end
         process_err();
      //---------------------------------------------------------------------------------------------
      // Compare the data 
      //---------------------------------------------------------------------------------------------
      end else begin
        m_r_s = "|";
        m_result_b = 1;
        if(regression_b == 0)begin
          $write("| FRAME SIZE          | %05d                     %0s %05d                    |\n",i_tx_edata_size,m_r_s,i_tx_gdata_size);
        end
        //4-------------------------------------------------------------------------------------------
        // loop for compare the data 
        //4-------------------------------------------------------------------------------------------
        for (idx_i=0; idx_i < i_tx_edata_size; idx_i = idx_i + 1) begin
          tx_exp_data_128b[63:56]  = U_traffic_gen.tx_edata_2d_64b[idx_i];
          tx_got_data_128b[63:56]  = U_output_monitor.tx_gdata_2d_64b[idx_i];
          if (m_j_i == 7) begin
             if (tx_exp_data_128b !== tx_got_data_128b) begin
               m_r_s = "X";
               m_result_b = 0;
             end else begin
               m_r_s = "|";
               m_result_b = 1;
             end
             if(regression_b == 0)begin
               $write("| DATA                | 0x%16x        %0s 0x%16x       |\n",tx_exp_data_128b,m_r_s,tx_got_data_128b);
             end
              m_j_i = 0;
              tx_got_data_128b = 0;
              tx_exp_data_128b = 0;
          end else begin
            tx_got_data_128b = tx_got_data_128b  >> 8;
            tx_exp_data_128b = tx_exp_data_128b  >> 8;
            m_j_i = m_j_i + 1;
          end
        end
        if (m_j_i != 0) begin
          tx_got_data_128b = tx_got_data_128b  >> ((7-m_j_i) * 8);
          tx_exp_data_128b = tx_exp_data_128b  >> ((7-m_j_i) * 8);
          if (tx_exp_data_128b !== tx_got_data_128b) begin
            m_r_s = "X";
            m_result_b = 0;
          end else begin
            m_r_s = "|";
            m_result_b = 1;
          end
          if(regression_b == 0)begin
            $write("| DATA                | 0x%16x        %0s 0x%16x       |\n",tx_exp_data_128b,m_r_s,tx_got_data_128b);
          end
           m_j_i = 0;
           tx_got_data_128b = 0;
           tx_exp_data_128b = 0;
        end
        if(m_result_b == 0) process_err();

        if(regression_b == 0)begin
          $write("+----------------------------------------------------------------------------+\n");
        end
      end
      tb_top.ntran_ui  = tb_top.ntran_ui + 1; 
      tb_top.trans_i   = tb_top.trans_i + 1; 
    end
  endtask

  //1-------------------------------------------------------------------------------------------------
  // rx_checker :This method is used for checking data
  //1-------------------------------------------------------------------------------------------------
  //             parameter :No parameter 
  //1-------------------------------------------------------------------------------------------------
  task automatic rx_checker;
    reg [255:0]                    m_cmp_s                      ; // Result of compare function
    reg [255:0]                    m_r_s                        ; // Result of compare function
    reg                            m_result_b                   ; // Hold the result of compare
    integer                        m_i_i                        ; // Iterative variable
    integer                        m_j_i                        ; // Iterative variable
    integer                        m_size_i                     ; // Variable to hold the array size
    reg                            m_valid_b                    ; // Variable for dummy flag

    begin
      m_i_i                          = 0; 
      m_j_i                          = 0; 
      m_size_i                       = 0; 
      m_result_b                     = 0; 
      m_cmp_s                        = ""; 
      m_r_s                          = ""; 
      //---------------------------------------------------------------------------------------------
      // Mismatch exp and got size
      //---------------------------------------------------------------------------------------------  
      if(regression_b == 0)begin
        $write("\n");
        $write("+----------------------------------------------------------------------------+\n");
        $write("| FIELD               | EXPECTED                  | GOT                      |\n");
        $write("+----------------------------------------------------------------------------+\n");
      end
      if (i_rx_edata_size != i_rx_gdata_size) begin
        m_r_s = "X";
        m_result_b = 0;
        if(regression_b == 0)begin
          $write("| SIZE                    | %0d                                     %0s %0d                                |\n",i_rx_edata_size,m_r_s,i_rx_gdata_size);
          $write("MSG :: @%0dns %m() :: ERROR Expected size %0d Got %0d\n",
           $time,i_rx_edata_size,i_rx_gdata_size);
         end
         process_err();
      //---------------------------------------------------------------------------------------------
      // Compare the data 
      //---------------------------------------------------------------------------------------------
      end else begin
        m_r_s = "|";
        m_result_b = 1;
        if(regression_b == 0)begin
          $write("| FRAME SIZE          | %05d                     %0s %05d                    |\n",i_rx_edata_size,m_r_s,i_rx_gdata_size);
        end
        //4-------------------------------------------------------------------------------------------
        // loop for compare the data 
        //4-------------------------------------------------------------------------------------------
        for (idx_i=0; idx_i < i_rx_edata_size; idx_i = idx_i + 1) begin
          rx_exp_data_128b[63:56]  = U_traffic_gen.rx_edata_2d_64b[idx_i];
          rx_got_data_128b[63:56]  = U_output_monitor.rx_gdata_2d_64b[idx_i];
          if (m_j_i == 7) begin
             if (tx_exp_data_128b !== tx_got_data_128b) begin
               m_r_s = "X";
               m_result_b = 0;
             end else begin
               m_r_s = "|";
               m_result_b = 1;
             end
             if(regression_b == 0)begin
               $write("| DATA                | 0x%16x        %0s 0x%16x       |\n",rx_exp_data_128b,m_r_s,rx_got_data_128b);
             end
              m_j_i = 0;
              rx_got_data_128b = 0;
              rx_exp_data_128b = 0;
          end else begin
            rx_got_data_128b = rx_got_data_128b  >> 8;
            rx_exp_data_128b = rx_exp_data_128b  >> 8;
            m_j_i = m_j_i + 1;
          end
        end
        if (m_j_i != 0) begin
          rx_got_data_128b = rx_got_data_128b  >> ((7-m_j_i) * 8);
          rx_exp_data_128b = rx_exp_data_128b  >> ((7-m_j_i) * 8);
          if (rx_exp_data_128b !== rx_got_data_128b) begin
            m_r_s = "X";
            m_result_b = 0;
          end else begin
            m_r_s = "|";
            m_result_b = 1;
          end
          if(regression_b == 0)begin
            $write("| DATA                | 0x%16x        %0s 0x%16x       |\n",rx_exp_data_128b,m_r_s,rx_got_data_128b);
          end
           m_j_i = 0;
           rx_got_data_128b = 0;
           rx_exp_data_128b = 0;
        end
        if(m_result_b == 0) process_err();

        if(regression_b == 0)begin
          $write("+----------------------------------------------------------------------------+\n");
        end
      end
      tb_top.ntran_ui  = tb_top.ntran_ui + 1; 
      tb_top.trans_i  = tb_top.trans_i + 1; 
    end
  endtask

  //1-------------------------------------------------------------------------------------------------
  // tx_checker :This method is used for checking data
  //1-------------------------------------------------------------------------------------------------
  //             parameter :No parameter 
  //1-------------------------------------------------------------------------------------------------
  task automatic mdio_checker;
    reg [255:0]                    m_cmp_s                      ; // Result of compare function
    reg [255:0]                    m_r_s                        ; // Result of compare function
    reg                            m_result_b                   ; // Hold the result of compare
    integer                        m_i_i                        ; // Iterative variable
    integer                        m_j_i                        ; // Iterative variable
    integer                        m_size_i                     ; // Variable to hold the array size
    reg                            m_valid_b                    ; // Variable for dummy flag
    reg[7:0]                       m_data_8b                    ; // Variable for 8bit data 
    reg[31:0]                      m_data_size_32b              ; // Variable for data size 

    begin
      m_i_i                        = 0; 
      m_j_i                        = 0; 
      m_size_i                     = 0; 
      m_result_b                   = 0; 
      m_cmp_s                      = ""; 
      m_r_s                        = ""; 
      m_data_8b                    = 0; 

      //---------------------------------------------------------------------------------------------
      // Mismatch exp and got size
      //---------------------------------------------------------------------------------------------  
      if(regression_b == 0)begin
        $write("\n");
        $write("+------------------------------------------------+\n");
        $write("| FIELD               | EXPECTED    | GOT        |\n");
        $write("+------------------------------------------------+\n");
      end
        //4-------------------------------------------------------------------------------------------
        // loop for compare the data 
        //4-------------------------------------------------------------------------------------------
        //Read from the register
        //--------------------------------------------------------------------------------------------------
        m_data_size_32b = i_mdio_gdata_size;
        mdio_addr_8b = 8'h14;
        tb_top.get_ahb_read(mdio_addr_8b);
        if (tb_top.ahbl_hreadyout_o) begin
          m_data_8b = tb_top.ahbl_hrdata_o;
        end
        mdio_exp_reg_addr_5b[4:0] = m_data_8b[4:0]; 
        mdio_addr_8b = 8'h15;
        tb_top.get_ahb_read(mdio_addr_8b);
        if (tb_top.ahbl_hreadyout_o) begin
          m_data_8b = tb_top.ahbl_hrdata_o;
        end
        mdio_exp_phy_addr_5b[4:0] = m_data_8b[4:0]; 
        if (m_data_8b[5] == 1) begin
          mdio_exp_opcode_2b[1:0] = 2'b01; 
        end else begin
          mdio_exp_opcode_2b[1:0] = 2'b10; 
        end
        mdio_addr_8b = 8'h16;
        tb_top.get_ahb_read(mdio_addr_8b);
        if (tb_top.ahbl_hreadyout_o) begin
          mdio_exp_data_16b[7:0] = tb_top.ahbl_hrdata_o;
        end
        mdio_addr_8b = 8'h17;
        tb_top.get_ahb_read(mdio_addr_8b);
        if (tb_top.ahbl_hreadyout_o) begin
          mdio_exp_data_16b[15:8] = tb_top.ahbl_hrdata_o;
        end

        for (mdio_idx_i=0; mdio_idx_i < m_data_size_32b; mdio_idx_i = mdio_idx_i + 1) begin
          if (mdio_idx_i <= 1) begin
            mdio_got_opcode_2b     = mdio_got_opcode_2b << 1;
            mdio_got_opcode_2b[0]  = U_output_monitor.mdio_gdata_2d_32b[mdio_idx_i];
            if (mdio_idx_i == 1) begin
              if (mdio_exp_opcode_2b !== mdio_got_opcode_2b) begin
                m_r_s = "X";
                m_result_b = 0;
              end else begin
                m_r_s = "|";
                m_result_b = 1;
              end
              $write("| MDIO OPCODE         | 0x%1x         %0s 0x%1x        |\n",mdio_exp_opcode_2b,m_r_s,mdio_got_opcode_2b);
            end
          end else if (mdio_idx_i <= 6) begin
            mdio_got_phy_addr_5b     = mdio_got_phy_addr_5b << 1;
            mdio_got_phy_addr_5b[0]  = U_output_monitor.mdio_gdata_2d_32b[mdio_idx_i];
            if (mdio_idx_i == 6) begin
              if (mdio_exp_phy_addr_5b !== mdio_got_phy_addr_5b) begin
                m_r_s = "X";
                m_result_b = 0;
              end else begin
                m_r_s = "|";
                m_result_b = 1;
              end
              $write("| MDIO PHYADDR        | 0x%2x        %0s 0x%2x       |\n",mdio_exp_phy_addr_5b[4:0],m_r_s,mdio_got_phy_addr_5b);
            end
          end else if (mdio_idx_i <= 11) begin
            mdio_got_reg_addr_5b     = mdio_got_reg_addr_5b << 1;
            mdio_got_reg_addr_5b[0]  = U_output_monitor.mdio_gdata_2d_32b[mdio_idx_i];
            if (mdio_idx_i == 11) begin
              if (mdio_exp_reg_addr_5b !== mdio_got_reg_addr_5b) begin
                m_r_s = "X";
                m_result_b = 0;
              end else begin
                m_r_s = "|";
                m_result_b = 1;
              end
              $write("| MDIO REGADDR        | 0x%2x        %0s 0x%2x       |\n",mdio_exp_reg_addr_5b[4:0],m_r_s,mdio_got_reg_addr_5b);
            end
          end else begin
            mdio_got_data_16b     = mdio_got_data_16b << 1;
            mdio_got_data_16b[0]  = U_output_monitor.mdio_gdata_2d_32b[mdio_idx_i];
            if (mdio_idx_i == 27) begin
              if (mdio_exp_data_16b !== mdio_got_data_16b) begin
                m_r_s = "X";
                m_result_b = 0;
              end else begin
                m_r_s = "|";
                m_result_b = 1;
              end
              $write("| MDIO DATA           | 0x%4x      %0s 0x%4x     |\n",mdio_exp_data_16b,m_r_s,mdio_got_data_16b);
            end

          end
        end
        if(m_result_b == 0) process_err();

        if(regression_b == 0)begin
          $write("+------------------------------------------------+\n");
        end
      tb_top.ntran_ui  = tb_top.ntran_ui + 1; 
      tb_top.trans_i   = tb_top.trans_i + 1; 
    end
  endtask

endmodule
`endif
