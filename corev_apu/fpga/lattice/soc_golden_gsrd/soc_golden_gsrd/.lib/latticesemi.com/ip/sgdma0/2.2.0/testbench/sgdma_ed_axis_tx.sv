module sgdma_ed_axis_tx #(
    parameter AXIS_LEN      = 1024, // 
    parameter TID_WIDTH     = 8,    // 1-8
    parameter TDEST_WIDTH   = 8,    // 1-8
    parameter TDATA_WIDTH   = 32    // AXIS width = 8, 16, 32, 64, 128
)(
    input  logic                        aclk,
    input  logic                        aresetn,

    // AXI Stream Master Interface
    input  logic                        m_axis_tready_i,
    output logic                        m_axis_tvalid_o,
    output logic [TDATA_WIDTH-1:0]      m_axis_tdata_o,
    //output logic [(TDATA_WIDTH/8)-1:0]  m_axis_tstrb_o,
    output logic [(TDATA_WIDTH/8)-1:0]  m_axis_tkeep_o,
    output logic                        m_axis_tlast_o,
    output logic [TID_WIDTH-1:0]        m_axis_tid_o,
    output logic [TDEST_WIDTH-1:0]      m_axis_tdest_o
);


    //------------------------------------------------------------------------------
    // Local Parameter
    //------------------------------------------------------------------------------
    localparam [15:0]   TDATA_BYTE  = TDATA_WIDTH/8;
    localparam          BYTE_SHIFT  = clog2(TDATA_BYTE);
    localparam          CLOG_BYTE   = clog2(AXIS_LEN);
    localparam [1:0]    IDLE        = 2'b00,
                        LAST        = 2'b01,
                        STREAM      = 2'b10;

    //------------------------------------------------------------------------------
    // Signal Declaration
    //------------------------------------------------------------------------------
    logic [1:0]             fsm;
    logic [4:0]             counter;
    logic                   init_req;
    logic [15:0]            data_cnt;
    //logic [TDATA_WIDTH-1:0] tdata;
    
    //------------------------------------------------------------------------------
    // Counter after reset
    //------------------------------------------------------------------------------
    always @ (posedge aclk or negedge aresetn)
    begin
        if (~aresetn)
        begin
            counter <= 5'd0;
            init_req <= 1'b0;
            data_cnt <= TDATA_BYTE;
            //tdata <= {TDATA_WIDTH{1'b0}};
        end
        else
        begin
            counter <= (&counter) ? counter : counter + 5'd1;
            init_req <= (counter==5'h1E) ? 1'b1 : 1'b0;
            data_cnt <= (~|fsm) ? TDATA_BYTE : 
                        (m_axis_tvalid_o & m_axis_tready_i) ? data_cnt + TDATA_BYTE : data_cnt;
            //tdata <= (~|fsm) ? {TDATA_WIDTH{1'b0}} : 
            //         (m_axis_tvalid_o & m_axis_tready_i) ? tdata + {{(TDATA_WIDTH-1){1'b0}}, 1'b1} : tdata;
        end
    end
   
    // -------------------------------------------------------
    // FSM
    // -------------------------------------------------------
    always @ (posedge aclk or negedge aresetn)
    begin
        if (~aresetn)
        begin
            fsm             <= IDLE;
            m_axis_tvalid_o <= 1'b0;
            m_axis_tdata_o  <= {TDATA_WIDTH{1'b0}};
            m_axis_tkeep_o  <= {(TDATA_WIDTH/8){1'b0}};
            m_axis_tlast_o  <= 1'b0;
            m_axis_tid_o    <= {TID_WIDTH{1'b0}};
            m_axis_tdest_o  <= {TDEST_WIDTH{1'b0}};
        end
        else
        begin
            case (fsm)
                IDLE :
                begin
                    if (init_req | m_axis_tready_i)
                    begin
                        fsm <= STREAM;
                        m_axis_tvalid_o <= 1'b1;
                        m_axis_tdata_o  <= (m_axis_tvalid_o & m_axis_tready_i) ? m_axis_tdata_o + {{(TDATA_WIDTH-1){1'b0}}, 1'b1} : m_axis_tdata_o;
                        m_axis_tkeep_o <= {(TDATA_WIDTH/8){1'b1}};
                    end
                end
                STREAM :
                begin
                    m_axis_tvalid_o <= 1'b1;
                    m_axis_tdata_o  <= (m_axis_tvalid_o & m_axis_tready_i) ? m_axis_tdata_o + {{(TDATA_WIDTH-1){1'b0}}, 1'b1} : m_axis_tdata_o;
                    m_axis_tkeep_o <= {(TDATA_WIDTH/8){1'b1}};
                    if (data_cnt==(AXIS_LEN-TDATA_BYTE))
                    begin
                        fsm <= LAST;
                        m_axis_tlast_o  <= 1'b1;
                    end
                end
                LAST :
                begin
                    if (m_axis_tready_i)
                    begin
                        fsm <= IDLE;
                        m_axis_tvalid_o <= 1'b0;
                        m_axis_tdata_o  <= {TDATA_WIDTH{1'b0}};
                        m_axis_tkeep_o  <= {(TDATA_WIDTH/8){1'b0}};
                        m_axis_tlast_o  <= 1'b0;
                    end
                end
                default : fsm <= IDLE;
            endcase        
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