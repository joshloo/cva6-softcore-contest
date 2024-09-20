// -------------------------------------------------------------------------
//
//  PROJECT: AXI SGDMA Example Design
//  COMPANY: Northwest Logic, Inc.
//
// ------------------------- CONFIDENTIAL ----------------------------------
//
//                 Copyright 2023 by Northwest Logic, Inc.
//
//  All rights reserved.  No part of this source code may be reproduced or
//  transmitted in any form or by any means, electronic or mechanical,
//  including photocopying, recording, or any information storage and
//  retrieval system, without permission in writing from Northwest Logic, Inc.
//
//  Further, no use of this source code is permitted in any form or means
//  without a valid, written license agreement with Northwest Logic, Inc.
//
//                         Northwest Logic, Inc.
//                  1100 NW Compton Drive, Suite 100
//                      Beaverton, OR 97006, USA
//
//                       Ph.  +1 503 533 5800
//                       Fax. +1 503 533 5900
//                          www.nwlogic.com
//
// -------------------------------------------------------------------------
`ifndef TB_TOP
`define TB_TOP

`timescale 1ns/1ps

`include "sgdma_ed_axil_m.sv"
`include "sgdma_ed_axis_rx.sv"
`include "sgdma_ed_axis_tx.sv"
`include "sgdma_ed_axi_mem.sv"

// -----------------------
// -- Module Definition --
// -----------------------  
module tb_top;
`include "dut_params.v"

    // =============================================================================
    // Localparam
    // =============================================================================
    localparam XFER_BUFF_SIZE   = 1024;
    localparam AXI_CLK_PERIOD   = 8000;     // 125Mhz
    localparam AXIL_CLK_PERIOD  = 10000;    // 100Mhz
    localparam NUM_LOOP         = 2;        // Number of S2MM->MM2S loopback cycle
    // =============================================================================
    // To separate S2MM BD and MM2S BD addressing, This ED must always use
    // BD_S2MM_BASE = 32'h00000000 and BD_MM2S_BASE = 32'h80000000
    // =============================================================================
    localparam BD_S2MM_BASE     = 32'h00000000;
    localparam BD_MM2S_BASE     = 32'h80000000;

    // =============================================================================
    // Variable Declarations
    // =============================================================================
    logic                           clk;
    logic                           rstn;
    logic                           axil_clk;
    logic                           axil_rstn;
    //--------------------------------------------------------------------------------------
    // AXI4L Interface Signal
    //--------------------------------------------------------------------------------------
    logic [AXIL_AWIDTH-1:0]         s_axil_awaddr_i;
    logic                           s_axil_awvalid_i;
    logic                           s_axil_awready_o;
    logic [2:0]                     s_axil_awprot_i;
    logic [AXIL_DWIDTH-1:0]         s_axil_wdata_i;
    logic [AXIL_DWIDTH/8-1:0]       s_axil_wstrb_i;
    logic                           s_axil_wvalid_i;
    logic                           s_axil_wready_o;
    logic [1:0]                     s_axil_bresp_o;
    logic                           s_axil_bvalid_o;
    logic                           s_axil_bready_i;
    logic [AXIL_AWIDTH-1:0]         s_axil_araddr_i;
    logic                           s_axil_arvalid_i;
    logic                           s_axil_arready_o;
    logic [2:0]                     s_axil_arprot_i;
    logic [AXIL_DWIDTH-1:0]         s_axil_rdata_o;
    logic [1:0]                     s_axil_rresp_o;
    logic                           s_axil_rvalid_o;
    logic                           s_axil_rready_i;
    //--------------------------------------------------------------------------------------
    // AXI4 MM Slave Interface Signal
    //--------------------------------------------------------------------------------------
    logic [AXI_ID_WIDTH-1:0]        m_axi_s2mm_awid_o;
    logic [3:0]                     m_axi_s2mm_awregion_o;
    logic [7:0]                     m_axi_s2mm_awlen_o;
    logic [2:0]                     m_axi_s2mm_awsize_o;
    logic [1:0]                     m_axi_s2mm_awburst_o;
    logic                           m_axi_s2mm_awlock_o;
    logic [3:0]                     m_axi_s2mm_awcache_o;
    logic [3:0]                     m_axi_s2mm_awqos_o;
    logic                           m_axi_s2mm_wlast_o;
    logic [AXI_ID_WIDTH-1:0]        m_axi_s2mm_bid_i;
    logic [AXI_AWIDTH-1:0]          m_axi_s2mm_awaddr_o;
    logic                           m_axi_s2mm_awvalid_o;
    logic                           m_axi_s2mm_awready_i;
    logic [2:0]                     m_axi_s2mm_awprot_o;
    logic [AXI_DWIDTH-1:0]          m_axi_s2mm_wdata_o;
    logic [AXI_DWIDTH/8-1:0]        m_axi_s2mm_wstrb_o;
    logic                           m_axi_s2mm_wvalid_o;
    logic                           m_axi_s2mm_wready_i;
    logic [1:0]                     m_axi_s2mm_bresp_i;
    logic                           m_axi_s2mm_bvalid_i;
    logic                           m_axi_s2mm_bready_o;
    logic [AXI_ID_WIDTH-1:0]        m_axi_mm2s_arid_o;
    logic [3:0]                     m_axi_mm2s_arregion_o;
    logic [7:0]                     m_axi_mm2s_arlen_o;
    logic [2:0]                     m_axi_mm2s_arsize_o;
    logic [1:0]                     m_axi_mm2s_arburst_o;
    logic                           m_axi_mm2s_arlock_o;
    logic [3:0]                     m_axi_mm2s_arcache_o;
    logic [3:0]                     m_axi_mm2s_arqos_o;
    logic [AXI_ID_WIDTH-1:0]        m_axi_mm2s_rid_i;
    logic                           m_axi_mm2s_rlast_i;
    logic [AXI_AWIDTH-1:0]          m_axi_mm2s_araddr_o;
    logic                           m_axi_mm2s_arvalid_o;
    logic                           m_axi_mm2s_arready_i;
    logic [2:0]                     m_axi_mm2s_arprot_o;
    logic [AXI_DWIDTH-1:0]          m_axi_mm2s_rdata_i;
    logic [1:0]                     m_axi_mm2s_rresp_i;
    logic                           m_axi_mm2s_rvalid_i;
    logic                           m_axi_mm2s_rready_o;
    //--------------------------------------------------------------------------------------
    // Descriptor AXI-MM Signals
    //--------------------------------------------------------------------------------------
    logic [AXI_ID_WIDTH-1:0]        m_axi_bd_arid_o;
    logic [BD_AWIDTH-1:0]           m_axi_bd_araddr_o;
    logic [3:0]                     m_axi_bd_arregion_o;
    logic [7:0]                     m_axi_bd_arlen_o;
    logic [2:0]                     m_axi_bd_arsize_o;
    logic [1:0]                     m_axi_bd_arburst_o;
    logic                           m_axi_bd_arlock_o;
    logic [3:0]                     m_axi_bd_arcache_o;
    logic [2:0]                     m_axi_bd_arprot_o;
    logic [3:0]                     m_axi_bd_arqos_o;
    logic                           m_axi_bd_arvalid_o;
    logic                           m_axi_bd_arready_i;
    logic [AXI_ID_WIDTH-1:0]        m_axi_bd_rid_i;
    logic [BD_DWIDTH-1:0]           m_axi_bd_rdata_i;
    logic [1:0]                     m_axi_bd_rresp_i;
    logic                           m_axi_bd_rlast_i;
    logic                           m_axi_bd_rvalid_i;
    logic                           m_axi_bd_rready_o;
    logic [AXI_ID_WIDTH-1:0]        m_axi_bd_awid_o;
    logic [3:0]                     m_axi_bd_awregion_o;
    logic [7:0]                     m_axi_bd_awlen_o;
    logic [2:0]                     m_axi_bd_awsize_o;
    logic [1:0]                     m_axi_bd_awburst_o;
    logic                           m_axi_bd_awlock_o;
    logic [3:0]                     m_axi_bd_awcache_o;
    logic [3:0]                     m_axi_bd_awqos_o;
    logic                           m_axi_bd_wlast_o;
    logic [AXI_ID_WIDTH-1:0]        m_axi_bd_bid_i;
    logic [BD_AWIDTH-1:0]           m_axi_bd_awaddr_o;
    logic                           m_axi_bd_awvalid_o;
    logic                           m_axi_bd_awready_i;
    logic [2:0]                     m_axi_bd_awprot_o;
    logic [BD_DWIDTH-1:0]           m_axi_bd_wdata_o;
    logic [BD_AWIDTH/8-1:0]         m_axi_bd_wstrb_o;
    logic                           m_axi_bd_wvalid_o;
    logic                           m_axi_bd_wready_i;
    logic [1:0]                     m_axi_bd_bresp_i;
    logic                           m_axi_bd_bvalid_i;
    logic                           m_axi_bd_bready_o;
    //--------------------------------------------------------------------------------------
    // AXI4Stream Interface Signal
    //--------------------------------------------------------------------------------------
    logic                           rx_axis_s2mm_tvalid_i;
    logic [TDATA_WIDTH-1:0]         rx_axis_s2mm_tdata_i;
    logic [(TDATA_WIDTH/8)-1:0]     rx_axis_s2mm_tkeep_i;
    logic                           rx_axis_s2mm_tlast_i;
    logic [TID_WIDTH-1:0]           rx_axis_s2mm_tid_i;
    logic [TDEST_WIDTH-1:0]         rx_axis_s2mm_tdest_i;
    logic                           rx_axis_s2mm_tready_o;
    logic                           tx_axis_mm2s_tready_i;
    logic                           tx_axis_mm2s_tvalid_o;
    logic [TDATA_WIDTH-1:0]         tx_axis_mm2s_tdata_o;
    logic [(TDATA_WIDTH/8)-1:0]     tx_axis_mm2s_tkeep_o;
    logic                           tx_axis_mm2s_tlast_o;
    logic [TID_WIDTH-1:0]           tx_axis_mm2s_tid_o;
    logic [TDEST_WIDTH-1:0]         tx_axis_mm2s_tdest_o;
    logic                           s2mm_xfer_cmpl_irq_o;
    logic                           mm2s_xfer_cmpl_irq_o;
    logic                           data_mismatch;

    // =============================================================================
    // Assign Statements 
    // =============================================================================
   // ---------------
   // Clock and Reset

   // Generate AXI-MM and AXI-S clock
   initial
     begin
        clk = 0;
        forever
          begin
             #(AXI_CLK_PERIOD/2);
             clk = ~clk;
          end
     end

    always @(posedge clk)
        rstn <= 1'b1;   

   // Generate AXI-L clock
   initial
     begin
        axil_clk = 0;
        forever
          begin
             #(AXIL_CLK_PERIOD/2);
             axil_clk = ~axil_clk;
          end
     end

    logic [2:0] axil_rst_cnt;
    always @(posedge axil_clk)
    begin
        axil_rst_cnt <= (&axil_rst_cnt) ? axil_rst_cnt : axil_rst_cnt + 3'd1;
        axil_rstn <= axil_rst_cnt[2];
    end

    // =============================================================================
    // Top level instantiations for SGMDA IP core
    // =============================================================================
    `include "dut_inst.v"

    // =============================================================================
    // SGDMA Example Design Component.
    // All sgmda_ed_* modules are designed to demonstrate SGDMA ED.
    // They are not meant for production purpose.
    // =============================================================================
    // sgdma_ed_axil_m will initiate AXI4-L cycle to configure SGDMA CSR.
    // BD Addressing are fixed as defined in localparam.
    // =============================================================================
    sgdma_ed_axil_m #(
        .NUM_LOOP           (NUM_LOOP),
        .ADDR_WIDTH         (AXIL_AWIDTH),
        .DATA_WIDTH         (AXIL_DWIDTH)
    ) u_sgdma_ed_axil_m (
        .aclk               (axil_clk),
        .aresetn            (axil_rstn),
        .m_axil_awaddr_o    (s_axil_awaddr_i),
        .m_axil_awvalid_o   (s_axil_awvalid_i),
        .m_axil_awready_i   (s_axil_awready_o),
        .m_axil_awprot_o    (s_axil_awprot_i),
        .m_axil_wdata_o     (s_axil_wdata_i),
        .m_axil_wstrb_o     (s_axil_wstrb_i),
        .m_axil_wvalid_o    (s_axil_wvalid_i),
        .m_axil_wready_i    (s_axil_wready_o),
        .m_axil_bresp_i     (s_axil_bresp_o),
        .m_axil_bvalid_i    (s_axil_bvalid_o),
        .m_axil_bready_o    (s_axil_bready_i),
        .m_axil_araddr_o    (s_axil_araddr_i),
        .m_axil_arvalid_o   (s_axil_arvalid_i),
        .m_axil_arready_i   (s_axil_arready_o),
        .m_axil_arprot_o    (s_axil_arprot_i),
        .m_axil_rdata_i     (s_axil_rdata_o),
        .m_axil_rresp_i     (s_axil_rresp_o),
        .m_axil_rvalid_i    (s_axil_rvalid_o),
        .m_axil_rready_o    (s_axil_rready_i),
        .s2mm_irq_i         (s2mm_xfer_cmpl_irq_o),
        .mm2s_irq_i         (mm2s_xfer_cmpl_irq_o)
    );

    // =============================================================================
    // sgdma_ed_axis_tx will stream #AXIS_LEN of TDATA to SGDMA.
    // AXIS_LEN must aligned to the TDATA_WIDTH.
    // Eg. if TDATA_WIDTH = 32, AXIS_LEN must be in full DW.
    // =============================================================================
    sgdma_ed_axis_tx #(
        .AXIS_LEN           (XFER_BUFF_SIZE),         //Number of bytes
        .TID_WIDTH          (TID_WIDTH),
        .TDEST_WIDTH        (TDEST_WIDTH),
        .TDATA_WIDTH        (TDATA_WIDTH)
    ) u_sgdma_ed_axis_tx ( 
        .aclk               (clk),
        .aresetn            (rstn),
        .m_axis_tready_i    (rx_axis_s2mm_tready_o),
        .m_axis_tvalid_o    (rx_axis_s2mm_tvalid_i),
        .m_axis_tdata_o     (rx_axis_s2mm_tdata_i),
        .m_axis_tkeep_o     (rx_axis_s2mm_tkeep_i),
        .m_axis_tlast_o     (rx_axis_s2mm_tlast_i),
        .m_axis_tid_o       (rx_axis_s2mm_tid_i),
        .m_axis_tdest_o     (rx_axis_s2mm_tdest_i)
    );

    // =============================================================================
    // sgdma_ed_axis_rx will receive TDATA from MM2S data streaming and compare
    // with MM2S TDATA.
    // compare_fail is live indication to data mismatch
    // =============================================================================
    sgdma_ed_axis_rx #(
        .NUM_LOOP           (NUM_LOOP),
        .TDATA_WIDTH        (TDATA_WIDTH),
        .FIFO_DEPTH         (XFER_BUFF_SIZE)
    ) u_sgdma_ed_axis_rx (
        .aclk               (clk),
        .aresetn            (rstn),
        .axis_mm2s_tready   (tx_axis_mm2s_tready_i),
        .axis_mm2s_tvalid   (tx_axis_mm2s_tvalid_o),
        .axis_mm2s_tdata    (tx_axis_mm2s_tdata_o),
        .axis_mm2s_tkeep    (tx_axis_mm2s_tkeep_o),
        .axis_mm2s_tlast    (tx_axis_mm2s_tlast_o),
        .axis_s2mm_tvalid   (rx_axis_s2mm_tvalid_i),
        .axis_s2mm_tdata    (rx_axis_s2mm_tdata_i),
        .axis_s2mm_tkeep    (rx_axis_s2mm_tkeep_i),
        .axis_s2mm_tlast    (rx_axis_s2mm_tlast_i),
        .axis_s2mm_tready   (rx_axis_s2mm_tready_o),
        .compare_fail       (data_mismatch)
    );

    // =============================================================================
    // u_sgdma_ed_axi_mem is to act as Data Memory to store AXI-MM Data transfer.
    // =============================================================================
    sgdma_ed_axi_mem #(
        .ADDR_WIDTH         (AXI_AWIDTH),
        .DATA_WIDTH         (AXI_DWIDTH),
        .ID_WIDTH           (AXI_ID_WIDTH),
        .MEM_DEPTH          (XFER_BUFF_SIZE),
        .INIT_MODE          (0)
    ) u_sgdma_ed_axi_mem (
        .aclk               (clk),
        .aresetn            (rstn),
        .s_axi_awid         (m_axi_s2mm_awid_o),
        .s_axi_awaddr       (m_axi_s2mm_awaddr_o),
        .s_axi_awregion     (m_axi_s2mm_awregion_o),
        .s_axi_awlen        (m_axi_s2mm_awlen_o),
        .s_axi_awsize       (m_axi_s2mm_awsize_o),
        .s_axi_awburst      (m_axi_s2mm_awburst_o),
        .s_axi_awlock       (m_axi_s2mm_awlock_o),
        .s_axi_awcache      (m_axi_s2mm_awcache_o),
        .s_axi_awprot       (m_axi_s2mm_awprot_o),
        .s_axi_awqos        (m_axi_s2mm_awqos_o),
        .s_axi_awvalid      (m_axi_s2mm_awvalid_o),
        .s_axi_awready      (m_axi_s2mm_awready_i),
        .s_axi_wdata        (m_axi_s2mm_wdata_o),
        .s_axi_wstrb        (m_axi_s2mm_wstrb_o),
        .s_axi_wlast        (m_axi_s2mm_wlast_o),
        .s_axi_wvalid       (m_axi_s2mm_wvalid_o),
        .s_axi_wready       (m_axi_s2mm_wready_i),
        .s_axi_bid          (m_axi_s2mm_bid_i),
        .s_axi_bresp        (m_axi_s2mm_bresp_i),
        .s_axi_bvalid       (m_axi_s2mm_bvalid_i),
        .s_axi_bready       (m_axi_s2mm_bready_o),
        .s_axi_arid         (m_axi_mm2s_arid_o),
        .s_axi_araddr       (m_axi_mm2s_araddr_o),
        .s_axi_arregion     (m_axi_mm2s_arregion_o),
        .s_axi_arlen        (m_axi_mm2s_arlen_o),
        .s_axi_arsize       (m_axi_mm2s_arsize_o),
        .s_axi_arburst      (m_axi_mm2s_arburst_o),
        .s_axi_arlock       (m_axi_mm2s_arlock_o),
        .s_axi_arcache      (m_axi_mm2s_arcache_o),
        .s_axi_arprot       (m_axi_mm2s_arprot_o),
        .s_axi_arqos        (m_axi_mm2s_arqos_o),
        .s_axi_arvalid      (m_axi_mm2s_arvalid_o),
        .s_axi_arready      (m_axi_mm2s_arready_i),
        .s_axi_rid          (m_axi_mm2s_rid_i),
        .s_axi_rdata        (m_axi_mm2s_rdata_i),
        .s_axi_rresp        (m_axi_mm2s_rresp_i),
        .s_axi_rlast        (m_axi_mm2s_rlast_i),
        .s_axi_rvalid       (m_axi_mm2s_rvalid_i),
        .s_axi_rready       (m_axi_mm2s_rready_o)
    );

    // =============================================================================
    // u_sgdma_ed_axi_bd_mem is to act as BD Data Memory.
    // =============================================================================
    sgdma_ed_axi_mem #(
        .ADDR_WIDTH         (BD_AWIDTH),
        .DATA_WIDTH         (BD_DWIDTH),
        .ID_WIDTH           (AXI_ID_WIDTH),
        .MEM_DEPTH          (16),               // in Bytes. 1 BD = 16 bytes
        .INIT_MODE          (1),
        .S2MM_BASE          (BD_S2MM_BASE),
        .MM2S_BASE          (BD_MM2S_BASE),
        .BD_BUFF_SIZE       (XFER_BUFF_SIZE)    // Buffer Transfer Size in Byte
    ) u_sgdma_ed_axi_bd_mem (
        .aclk               (clk),
        .aresetn            (rstn),
        .s_axi_awid         (m_axi_bd_awid_o),
        .s_axi_awaddr       (m_axi_bd_awaddr_o),
        .s_axi_awregion     (m_axi_bd_awregion_o),
        .s_axi_awlen        (m_axi_bd_awlen_o),
        .s_axi_awsize       (m_axi_bd_awsize_o),
        .s_axi_awburst      (m_axi_bd_awburst_o),
        .s_axi_awlock       (m_axi_bd_awlock_o),
        .s_axi_awcache      (m_axi_bd_awcache_o),
        .s_axi_awprot       (m_axi_bd_awprot_o),
        .s_axi_awqos        (m_axi_bd_awqos_o),
        .s_axi_awvalid      (m_axi_bd_awvalid_o),
        .s_axi_awready      (m_axi_bd_awready_i),
        .s_axi_wdata        (m_axi_bd_wdata_o),
        .s_axi_wstrb        (m_axi_bd_wstrb_o),
        .s_axi_wlast        (m_axi_bd_wlast_o),
        .s_axi_wvalid       (m_axi_bd_wvalid_o),
        .s_axi_wready       (m_axi_bd_wready_i),
        .s_axi_bid          (m_axi_bd_bid_i),
        .s_axi_bresp        (m_axi_bd_bresp_i),
        .s_axi_bvalid       (m_axi_bd_bvalid_i),
        .s_axi_bready       (m_axi_bd_bready_o),
        .s_axi_arid         (m_axi_bd_arid_o),
        .s_axi_araddr       (m_axi_bd_araddr_o),
        .s_axi_arregion     (m_axi_bd_arregion_o),
        .s_axi_arlen        (m_axi_bd_arlen_o),
        .s_axi_arsize       (m_axi_bd_arsize_o),
        .s_axi_arburst      (m_axi_bd_arburst_o),
        .s_axi_arlock       (m_axi_bd_arlock_o),
        .s_axi_arcache      (m_axi_bd_arcache_o),
        .s_axi_arprot       (m_axi_bd_arprot_o),
        .s_axi_arqos        (m_axi_bd_arqos_o),
        .s_axi_arvalid      (m_axi_bd_arvalid_o),
        .s_axi_arready      (m_axi_bd_arready_i),
        .s_axi_rid          (m_axi_bd_rid_i),
        .s_axi_rdata        (m_axi_bd_rdata_i),
        .s_axi_rresp        (m_axi_bd_rresp_i),
        .s_axi_rlast        (m_axi_bd_rlast_i),
        .s_axi_rvalid       (m_axi_bd_rvalid_i),
        .s_axi_rready       (m_axi_bd_rready_o)
    );


    // -----------------------------------------------------------------------------------------------
    // Initial block
    // -----------------------------------------------------------------------------------------------
    initial begin 
        rstn = 1'b0;
        axil_rstn = 1'b0;
        axil_rst_cnt = 3'b000;
    end

    // -----------------------------------------------------------------------------------------------
    // Test Done
    // -----------------------------------------------------------------------------------------------
    logic [3:0] test_count;
    logic       test_done;
    logic       test_fail;
    always_ff @ (posedge axil_clk or negedge axil_rstn)
    begin
        if (~axil_rstn)
        begin
            test_count <= 4'd0;
            test_done <= 1'b0;
            test_fail <= 1'b0;
        end
        else
        begin
            test_count <= (tx_axis_mm2s_tlast_o & tx_axis_mm2s_tvalid_o) ? test_count + 4'd1 : test_count;
            test_done <= (test_count == NUM_LOOP) ? 1'b1 : 1'b0;
            test_fail <= data_mismatch ? 1'b1 : test_fail;
        end
    end

    always @(data_mismatch)
    begin
        if (data_mismatch == 1'b1)
            $display("[Error] Data Mismatch at Time: %t ", $time);
    end

    always @(test_done)
    begin
        if (test_done == 1'b1)
        begin
            if (test_fail == 1'b1)
            begin
                $display("---------------------------------------");
                $display("------------- Test Failed -------------");
                $display("---------------------------------------");
            end
            else
            begin
                $display("---------------------------------------");
                $display("------------- SIMULATION PASSED -------------");
                $display("---------------------------------------");
            end
            $stop;
        end
    end

endmodule
`endif // TB_TOP
