module sgdma_ed_axil_m #(
    parameter NUM_LOOP      = 2,    // 1-15; 0 = forever loop
    parameter ADDR_WIDTH    = 32,
    parameter DATA_WIDTH    = 32
)(
    input  logic                        aclk,
    input  logic                        aresetn,
    output logic [ADDR_WIDTH-1:0]       m_axil_awaddr_o,            
    output logic                        m_axil_awvalid_o,           
    input  logic                        m_axil_awready_i,       
    output logic [2:0]                  m_axil_awprot_o,  
    output logic [DATA_WIDTH-1:0]       m_axil_wdata_o, 
    output logic [(DATA_WIDTH/8)-1:0]   m_axil_wstrb_o,   
    output logic                        m_axil_wvalid_o,            
    input  logic                        m_axil_wready_i,    
    input  logic [1:0]                  m_axil_bresp_i,             
    input  logic                        m_axil_bvalid_i,        
    output logic                        m_axil_bready_o,        
    output logic [ADDR_WIDTH-1:0]       m_axil_araddr_o,            
    output logic                        m_axil_arvalid_o,           
    input  logic                        m_axil_arready_i,   
    output logic [2:0]                  m_axil_arprot_o, 
    input  logic [DATA_WIDTH-1:0]       m_axil_rdata_i,         
    input  logic [1:0]                  m_axil_rresp_i,         
    input  logic                        m_axil_rvalid_i,            
    output logic                        m_axil_rready_o,
    input  logic                        s2mm_irq_i,
    input  logic                        mm2s_irq_i
);

    //------------------------------------------------------------------------------
    // Local Parameter
    //------------------------------------------------------------------------------
    // SGDMA Register Offset
    localparam  MM2S_CTRL           = 32'h00000000,
                MM2S_STS            = 32'h00000004,
                MM2S_CURDESC        = 32'h00000008,
                MM2S_MSB_CURDESC    = 32'h0000000C,
                S2MM_CTRL           = 32'h00000020,
                S2MM_STS            = 32'h00000024,
                S2MM_CURDESC        = 32'h00000028,
                S2MM_MSB_CURDESC    = 32'h0000002C;

    // SGDMA Register Offset
    localparam  S2MM_BD_BASE        = 32'h00000000;
    localparam  MM2S_BD_BASE        = 32'h80000000;

    //------------------------------------------------------------------------------
    // Signal Declaration
    //------------------------------------------------------------------------------
    logic [3:0]     counter;
    logic           init_req;
    logic           ping_pong;  // 0 = S2MM, 1 = MM2S
    logic [3:0]     cycle_cnt;
    logic           next_cycle;
    
    //------------------------------------------------------------------------------
    // Counter after reset
    //------------------------------------------------------------------------------
    always @ (posedge aclk or negedge aresetn)
    begin
        if (~aresetn)
        begin
            counter <= 4'd0;
            init_req <= 1'b0;
            ping_pong <= 1'b0;
            cycle_cnt <= 4'd1;
            next_cycle <= 1'b0;
        end
        else
        begin
            counter <= (&counter) ? counter : counter + 4'd1;
            init_req <= (counter==4'hE) ? 1'b1 : 1'b0;
            ping_pong <= s2mm_irq_i ? 1'b1 : mm2s_irq_i ? 1'b0 : ping_pong;
            cycle_cnt <= ((cycle_cnt==4'd0) | (cycle_cnt==NUM_LOOP)) ? cycle_cnt : mm2s_irq_i ? (cycle_cnt + 4'd1) : cycle_cnt; 
            next_cycle <= (cycle_cnt==4'd0) ? mm2s_irq_i : (cycle_cnt==NUM_LOOP) ? 1'b0 : mm2s_irq_i;
        end
    end
   
    //------------------------------------------------------------------------------
    // Write FSM
    //------------------------------------------------------------------------------
    localparam  [1:0]   W_IDLE  = 2'd0,
                        W0      = 2'd1,
                        W1      = 2'd2,
                        W2      = 2'd3;

    logic [1:0] wfsm;
    
    always @ (posedge aclk or negedge aresetn)
    begin
        if (~aresetn)
        begin
            wfsm                <= W_IDLE;
            m_axil_awaddr_o     <= {ADDR_WIDTH{1'b0}};
            m_axil_awvalid_o    <= 1'b0;
            m_axil_awprot_o     <= 2'd0;
            m_axil_wdata_o      <= {DATA_WIDTH{1'b0}};
            m_axil_wstrb_o      <= {(DATA_WIDTH/8){1'b1}};
            m_axil_wvalid_o     <= 1'b0;
            m_axil_bready_o     <= 1'b0;
            m_axil_araddr_o     <= {ADDR_WIDTH{1'b0}};
            m_axil_arvalid_o    <= 1'b0;
            m_axil_arprot_o     <= 2'd0;
            m_axil_rready_o     <= 1'b0;
        end
        else
        begin
            m_axil_arvalid_o <= m_axil_rvalid_i ? 1'b0 : m_axil_arvalid_o;
            m_axil_rready_o <= m_axil_rvalid_i ? 1'b0 : m_axil_rready_o;
            case (wfsm)
                W_IDLE :
                begin
                    m_axil_awaddr_o <= {ADDR_WIDTH{1'b0}};
                    m_axil_awvalid_o <= 1'b0;
                    m_axil_wvalid_o <= 1'b0;
                    m_axil_bready_o <= 1'b0;
                    if (init_req | s2mm_irq_i | next_cycle)
                    begin
                        wfsm <= W0;
                        m_axil_awaddr_o <= ping_pong ? MM2S_CTRL : S2MM_CTRL;
                        m_axil_awvalid_o <= 1'b1;
                        m_axil_wdata_o <= 32'h00000002;
                        m_axil_wvalid_o <= 1'b1;
                        m_axil_araddr_o     <= ping_pong ? S2MM_STS : MM2S_STS;
                        m_axil_arvalid_o    <= 1'b1;
                        m_axil_rready_o     <= 1'b1;
                    end
                end
                W0 :
                begin
                    if (m_axil_wready_i)
                    begin
                        m_axil_awvalid_o <= 1'b0;
                        m_axil_wvalid_o <= 1'b0;
                        m_axil_bready_o <= 1'b1;
                    end
                    if (m_axil_bready_o && m_axil_bvalid_i)
                    begin
                        wfsm <= W1;
                        m_axil_bready_o <= 1'b0;
                        m_axil_awaddr_o <= ping_pong ? MM2S_CURDESC : S2MM_CURDESC;
                        m_axil_awvalid_o <= 1'b1;
                        m_axil_wdata_o <= ping_pong ? MM2S_BD_BASE : S2MM_BD_BASE;
                        m_axil_wvalid_o <= 1'b1;
                    end
                end
                W1 :
                begin
                    if (m_axil_wready_i)
                    begin
                        m_axil_awvalid_o <= 1'b0;
                        m_axil_wvalid_o <= 1'b0;
                        m_axil_bready_o <= 1'b1;
                    end
                    if (m_axil_bready_o && m_axil_bvalid_i)
                    begin
                        wfsm <= W2;
                        m_axil_bready_o <= 1'b0;
                        m_axil_awaddr_o <= ping_pong ? MM2S_CTRL : S2MM_CTRL;
                        m_axil_awvalid_o <= 1'b1;
                        m_axil_wdata_o <= 32'h00000001;
                        m_axil_wvalid_o <= 1'b1;
                    end
                end
                W2 :
                begin
                    if (m_axil_wready_i)
                    begin
                        m_axil_awvalid_o <= 1'b0;
                        m_axil_wvalid_o <= 1'b0;
                        m_axil_bready_o <= 1'b1;
                    end
                    if (m_axil_bready_o && m_axil_bvalid_i)
                    begin
                        wfsm <= W_IDLE;
                        m_axil_bready_o <= 1'b0;
                    end
                end
                default : wfsm <= W_IDLE;
            endcase
        end    
    end

endmodule