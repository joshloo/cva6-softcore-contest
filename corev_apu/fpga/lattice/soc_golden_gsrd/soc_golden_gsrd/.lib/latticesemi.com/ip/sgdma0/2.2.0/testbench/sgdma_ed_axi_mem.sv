module sgdma_ed_axi_mem # (
    parameter ADDR_WIDTH    = 32,           // AXI Addr Width : 32, 64
    parameter DATA_WIDTH    = 32,           // AXI Data Width : 32, 64, 128
    parameter ID_WIDTH      = 4,            // AXI ID Width : 1-8
    parameter MEM_DEPTH     = 512,
    parameter INIT_MODE     = 0,
    parameter S2MM_BASE     = 32'h00000000,
    parameter MM2S_BASE     = 32'h80000000,
    parameter BD_BUFF_SIZE  = 16'h0020
)(
    input  logic                        aclk,
    input  logic                        aresetn,
    input  logic [ID_WIDTH-1:0]         s_axi_awid,
    input  logic [ADDR_WIDTH-1:0]       s_axi_awaddr,
    input  logic [3:0]                  s_axi_awregion,
    input  logic [7:0]                  s_axi_awlen,
    input  logic [2:0]                  s_axi_awsize,
    input  logic [1:0]                  s_axi_awburst,
    input  logic                        s_axi_awlock,
    input  logic [3:0]                  s_axi_awcache,
    input  logic [2:0]                  s_axi_awprot,
    input  logic [3:0]                  s_axi_awqos,
    input  logic                        s_axi_awvalid,
    output logic                        s_axi_awready,
    input  logic [DATA_WIDTH-1:0]       s_axi_wdata,
    input  logic [(DATA_WIDTH/8)-1:0]   s_axi_wstrb,
    input  logic                        s_axi_wlast,
    input  logic                        s_axi_wvalid,
    output logic                        s_axi_wready,
    output logic [ID_WIDTH-1:0]         s_axi_bid,
    output logic [1:0]                  s_axi_bresp,
    output logic                        s_axi_bvalid,
    input  logic                        s_axi_bready,
    input  logic [ID_WIDTH-1:0]         s_axi_arid,
    input  logic [ADDR_WIDTH-1:0]       s_axi_araddr,
    input  logic [3:0]                  s_axi_arregion,
    input  logic [7:0]                  s_axi_arlen,
    input  logic [2:0]                  s_axi_arsize,
    input  logic [1:0]                  s_axi_arburst,
    input  logic                        s_axi_arlock,
    input  logic [3:0]                  s_axi_arcache,
    input  logic [2:0]                  s_axi_arprot,
    input  logic [3:0]                  s_axi_arqos,
    input  logic                        s_axi_arvalid,
    output logic                        s_axi_arready,
    output logic [ID_WIDTH-1:0]         s_axi_rid,
    output logic [DATA_WIDTH-1:0]       s_axi_rdata,
    output logic [1:0]                  s_axi_rresp,
    output logic                        s_axi_rlast,
    output logic                        s_axi_rvalid,
    input  logic                        s_axi_rready
);
    //------------------------------------------------------------------------------
    // Local Parameter
    //------------------------------------------------------------------------------
    localparam OFFSET_WIDTH = $clog2(MEM_DEPTH);
    localparam NUM_BYTE     = DATA_WIDTH/8;
    localparam BYTE_SHIFT   = $clog2(NUM_BYTE);
    //------------------------------------------------------------------------------
    // Signal Declaration
    //------------------------------------------------------------------------------
    //logic [7:0]                 mem_map [0:MEM_DEPTH*2-1];  // Per Byte
    logic [DATA_WIDTH-1:0]      rdata;
    //logic [OFFSET_WIDTH-1:0]    addr_offset;
    logic                       wr_en;
    logic [OFFSET_WIDTH-1:0]    wr_cnt;
    logic [OFFSET_WIDTH-1:0]    rd_cnt, rd_len_cnt;
    logic [1+8+BYTE_SHIFT-1:0]  wr_size;
    logic [1+8+BYTE_SHIFT-1:0]  rd_size;
    //logic [7:0]                 mem_init [0:MEM_DEPTH*2-1];
    logic                       fetch;
    //------------------------------------------------------------------------------
    // BD
    //------------------------------------------------------------------------------
    generate
        if (INIT_MODE)
        begin
            logic                   rd_mm2s;
            logic [MEM_DEPTH*8-1:0] s2mm_mem_map;
            logic [MEM_DEPTH*8-1:0] mm2s_mem_map;
            logic [MEM_DEPTH*8-1:0] mem_map;
            assign s2mm_mem_map = {48'd0,BD_BUFF_SIZE,64'd0};
            assign mm2s_mem_map = {40'd0,8'h12,BD_BUFF_SIZE,64'd0};
            always @ (posedge aclk or negedge aresetn)
            begin
                if (~aresetn)
                begin
                    mem_map <= {48'd0,BD_BUFF_SIZE,64'd0};
                end
                else
                begin
                    if (s_axi_arvalid)
                    begin
                        mem_map <= (s_axi_araddr[31]) ? mm2s_mem_map : s2mm_mem_map;
                    end
                    else if (fetch)
                    begin
                        mem_map <= {{DATA_WIDTH{1'b0}}, mem_map[((MEM_DEPTH*8)-1):DATA_WIDTH]};
                    end
                end
            end
            assign rdata = mem_map[DATA_WIDTH-1:0];
        end
        else
        begin
            logic [(MEM_DEPTH*8)-1:0]    mem_map;
            always @ (posedge aclk or negedge aresetn)
            begin
                if (~aresetn)
                begin
                    mem_map <= {(MEM_DEPTH*8){1'b0}};
                end
                else
                begin
                    if (wr_en)
                    begin
                        mem_map <= {s_axi_wdata, mem_map[((MEM_DEPTH*8)-1):DATA_WIDTH]};
                    end
                    if (fetch)
                    begin
                        mem_map <= {{DATA_WIDTH{1'b0}}, mem_map[((MEM_DEPTH*8)-1):DATA_WIDTH]};
                    end
                end    
            end
            assign rdata = mem_map[DATA_WIDTH-1:0];
        end
    endgenerate
    //------------------------------------------------------------------------------
    // Memory Mapping
    //------------------------------------------------------------------------------
    assign wr_en = s_axi_wready & s_axi_wvalid;
    always @ (posedge aclk or negedge aresetn)
    begin
        if (~aresetn)
        begin
            //addr_offset <= {OFFSET_WIDTH{1'b0}},
            wr_size <= {(1+8+BYTE_SHIFT){1'b0}};
            wr_cnt <= {OFFSET_WIDTH{1'b0}};
            s_axi_awready <= 1'b0;
            s_axi_wready <= 1'b0;
            s_axi_bid <= {ID_WIDTH{1'b0}};
            s_axi_bresp <= 2'd0;
            s_axi_bvalid <= 1'b0;
        end
        else
        begin
            //addr_offset <= s_axi_awvalid ? s_axi_awaddr[OFFSET_WIDTH-1:0] : addr_offset;
            wr_size <= s_axi_awvalid ? {({1'b0,s_axi_awlen}+9'd1), {BYTE_SHIFT{1'b0}}} : wr_size;
            wr_cnt <= s_axi_awvalid ? s_axi_awaddr[OFFSET_WIDTH-1:0] : (wr_en) ? wr_cnt + NUM_BYTE : wr_cnt;
            s_axi_awready <= s_axi_awvalid;
            s_axi_wready <=(s_axi_wlast & wr_en) ? 1'b0 : s_axi_awvalid ? 1'b1 : s_axi_wready;
            s_axi_bid <= s_axi_awvalid ? s_axi_awid : s_axi_bid;
            s_axi_bresp <= 2'd0;
            s_axi_bvalid <= (s_axi_wlast & wr_en) ? 1'b1 : s_axi_bready ? 1'b0 : s_axi_bvalid;
        end
    end
    always @ (posedge aclk or negedge aresetn)
    begin
        if (~aresetn)
        begin
            rd_cnt <= {OFFSET_WIDTH{1'b0}};
            rd_len_cnt <= 8'd1;
            rd_size <= 8'd0;
            fetch <= 1'b0;
            s_axi_arready <= 1'b0;
            s_axi_rid <= {ID_WIDTH{1'b0}};
            s_axi_rdata <= {DATA_WIDTH{1'b0}};
            s_axi_rresp <= 2'd0;
            s_axi_rlast <= 1'b0;
            s_axi_rvalid <= 1'b0;
        end
        else
        begin
            rd_cnt <= s_axi_arvalid ? s_axi_araddr[OFFSET_WIDTH-1:0] : (fetch) ? rd_cnt + NUM_BYTE : rd_cnt;
            rd_len_cnt <= s_axi_arvalid ? 8'd0 : (fetch) ? rd_len_cnt + 8'd1 : rd_len_cnt;
            rd_size <= s_axi_arvalid ? s_axi_arlen : rd_size;
            fetch <= (rd_len_cnt >= rd_size) ? 1'b0 : (s_axi_rready) ? 1'b1 : 1'b0;
            s_axi_arready <= s_axi_arvalid;
            s_axi_rid <= s_axi_arvalid ? s_axi_arid : s_axi_rid;
            s_axi_rvalid <= fetch ? 1'b1 : 1'b0;
            s_axi_rdata <= fetch ? rdata :s_axi_rdata;
            s_axi_rresp <= 2'd0;
            s_axi_rlast <= (s_axi_rlast & s_axi_rready) ? 1'b0 : (rd_len_cnt == rd_size) ? 1'b1 : 1'b0;
        end
    end
    //------------------------------------------------------------------------------
    // Function Definition
    //------------------------------------------------------------------------------
    function [31:0] clog2;
        input [31:0] value;
        logic [31:0] num;
        begin
            num = value - 1;
            for (clog2=0; num>0; clog2=clog2+1) num = num>>1;
        end
    endfunction
    
endmodule