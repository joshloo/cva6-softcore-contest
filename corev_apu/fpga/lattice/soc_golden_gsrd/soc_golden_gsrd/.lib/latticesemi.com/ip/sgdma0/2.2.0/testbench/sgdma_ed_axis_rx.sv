
module sgdma_ed_axis_rx # (
    parameter NUM_LOOP          = 2,
    parameter TDATA_WIDTH       = 32,   // AXIS Data Width : 8, 16, 32, 64, 128
    parameter FIFO_DEPTH        = 1024  // Fifo Depth : 4096
)(
    input  logic                        aclk,
    input  logic                        aresetn,
    input  logic                        axis_mm2s_tvalid,
    input  logic [TDATA_WIDTH-1:0]      axis_mm2s_tdata,
    input  logic [(TDATA_WIDTH/8)-1:0]  axis_mm2s_tkeep,
    input  logic                        axis_mm2s_tlast,
    output logic                        axis_mm2s_tready,
    input  logic                        axis_s2mm_tvalid,
    input  logic [TDATA_WIDTH-1:0]      axis_s2mm_tdata,
    input  logic [(TDATA_WIDTH/8)-1:0]  axis_s2mm_tkeep,
    input  logic                        axis_s2mm_tlast,
    input  logic                        axis_s2mm_tready,
    output logic                        compare_fail
);

    localparam  DEPTH = clog2(FIFO_DEPTH);

    logic                   chk_trigger;
    logic [DEPTH-1:0]       s2mm_count;
    logic [DEPTH-1:0]       mm2s_count;
    logic [FIFO_DEPTH*8-1:0]  s2mm_data_store;
    logic [TDATA_WIDTH-1:0] mm2s_data, curr_mm2s_data, s2mm_data, curr_s2mm_data;

    assign axis_mm2s_tready = 1'b1;
    
    always @ (posedge aclk or negedge aresetn)
    begin
        if (~aresetn)
        begin
            s2mm_data_store <= {(FIFO_DEPTH*8){1'b0}};
            s2mm_count <= {{DEPTH-1{1'b0}}, 1'b1};
            mm2s_count <= {DEPTH{1'b0}};
            compare_fail <= 1'b0;
            chk_trigger <= 1'b0;
        end
        else
        begin
            if (axis_s2mm_tready & axis_s2mm_tvalid)
            begin
                s2mm_data_store <= {s2mm_data, s2mm_data_store[FIFO_DEPTH*8-1 : TDATA_WIDTH]};
            end
            
            if (axis_mm2s_tvalid)
            begin
                curr_mm2s_data <= mm2s_data;
                curr_s2mm_data <= s2mm_data_store[TDATA_WIDTH-1:0];
                s2mm_data_store <= {{TDATA_WIDTH{1'b0}}, s2mm_data_store[FIFO_DEPTH*8-1 : TDATA_WIDTH]};
            end
            
            s2mm_count <= (axis_s2mm_tready & axis_s2mm_tvalid) ? s2mm_count + 'd1 : s2mm_count;
            mm2s_count <= (axis_mm2s_tvalid) ? mm2s_count + 'd1 : mm2s_count;
            compare_fail <= chk_trigger ? ((curr_s2mm_data == curr_mm2s_data) ? 1'b0 : 1'b1) : 1'b0;
            chk_trigger <= axis_mm2s_tvalid;
        end    
    end
    
    generate
        if (TDATA_WIDTH==128)
        begin

            assign s2mm_data = {({8{axis_s2mm_tkeep[15]}} & axis_s2mm_tdata[15+:8]),

                                ({8{axis_s2mm_tkeep[14]}} & axis_s2mm_tdata[14*8+:8]),

                                ({8{axis_s2mm_tkeep[13]}} & axis_s2mm_tdata[13*8+:8]),

                                ({8{axis_s2mm_tkeep[12]}} & axis_s2mm_tdata[12*8+:8]),

                                ({8{axis_s2mm_tkeep[11]}} & axis_s2mm_tdata[11*8+:8]),

                                ({8{axis_s2mm_tkeep[10]}} & axis_s2mm_tdata[10*8+:8]),

                                ({8{axis_s2mm_tkeep[9]}} & axis_s2mm_tdata[9*8+:8]),

                                ({8{axis_s2mm_tkeep[8]}} & axis_s2mm_tdata[8*8+:8]),

                                ({8{axis_s2mm_tkeep[7]}} & axis_s2mm_tdata[7*8+:8]),

                                ({8{axis_s2mm_tkeep[6]}} & axis_s2mm_tdata[6*8+:8]),

                                ({8{axis_s2mm_tkeep[5]}} & axis_s2mm_tdata[5*8+:8]),

                                ({8{axis_s2mm_tkeep[4]}} & axis_s2mm_tdata[4*8+:8]),

                                ({8{axis_s2mm_tkeep[3]}} & axis_s2mm_tdata[3*8+:8]),

                                ({8{axis_s2mm_tkeep[2]}} & axis_s2mm_tdata[2*8+:8]),

                                ({8{axis_s2mm_tkeep[1]}} & axis_s2mm_tdata[1*8+:8]),

                                ({8{axis_s2mm_tkeep[0]}} & axis_s2mm_tdata[0*8+:8])};
                                
            assign mm2s_data = {({8{axis_mm2s_tkeep[15]}} & axis_mm2s_tdata[15+:8]),

                                ({8{axis_mm2s_tkeep[14]}} & axis_mm2s_tdata[14*8+:8]),

                                ({8{axis_mm2s_tkeep[13]}} & axis_mm2s_tdata[13*8+:8]),

                                ({8{axis_mm2s_tkeep[12]}} & axis_mm2s_tdata[12*8+:8]),

                                ({8{axis_mm2s_tkeep[11]}} & axis_mm2s_tdata[11*8+:8]),

                                ({8{axis_mm2s_tkeep[10]}} & axis_mm2s_tdata[10*8+:8]),

                                ({8{axis_mm2s_tkeep[9]}} & axis_mm2s_tdata[9*8+:8]),

                                ({8{axis_mm2s_tkeep[8]}} & axis_mm2s_tdata[8*8+:8]),

                                ({8{axis_mm2s_tkeep[7]}} & axis_mm2s_tdata[7*8+:8]),

                                ({8{axis_mm2s_tkeep[6]}} & axis_mm2s_tdata[6*8+:8]),

                                ({8{axis_mm2s_tkeep[5]}} & axis_mm2s_tdata[5*8+:8]),

                                ({8{axis_mm2s_tkeep[4]}} & axis_mm2s_tdata[4*8+:8]),

                                ({8{axis_mm2s_tkeep[3]}} & axis_mm2s_tdata[3*8+:8]),

                                ({8{axis_mm2s_tkeep[2]}} & axis_mm2s_tdata[2*8+:8]),

                                ({8{axis_mm2s_tkeep[1]}} & axis_mm2s_tdata[1*8+:8]),

                                ({8{axis_mm2s_tkeep[0]}} & axis_mm2s_tdata[0*8+:8])};
        end
        else if (TDATA_WIDTH==64)
        begin

            assign s2mm_data = {({8{axis_s2mm_tkeep[7]}} & axis_s2mm_tdata[7*8+:8]),

                                ({8{axis_s2mm_tkeep[6]}} & axis_s2mm_tdata[6*8+:8]),

                                ({8{axis_s2mm_tkeep[5]}} & axis_s2mm_tdata[5*8+:8]),

                                ({8{axis_s2mm_tkeep[4]}} & axis_s2mm_tdata[4*8+:8]),

                                ({8{axis_s2mm_tkeep[3]}} & axis_s2mm_tdata[3*8+:8]),

                                ({8{axis_s2mm_tkeep[2]}} & axis_s2mm_tdata[2*8+:8]),

                                ({8{axis_s2mm_tkeep[1]}} & axis_s2mm_tdata[1*8+:8]),

                                ({8{axis_s2mm_tkeep[0]}} & axis_s2mm_tdata[0*8+:8])};
            assign mm2s_data = {({8{axis_mm2s_tkeep[7]}} & axis_mm2s_tdata[7*8+:8]),

                                ({8{axis_mm2s_tkeep[6]}} & axis_mm2s_tdata[6*8+:8]),

                                ({8{axis_mm2s_tkeep[5]}} & axis_mm2s_tdata[5*8+:8]),

                                ({8{axis_mm2s_tkeep[4]}} & axis_mm2s_tdata[4*8+:8]),

                                ({8{axis_mm2s_tkeep[3]}} & axis_mm2s_tdata[3*8+:8]),

                                ({8{axis_mm2s_tkeep[2]}} & axis_mm2s_tdata[2*8+:8]),

                                ({8{axis_mm2s_tkeep[1]}} & axis_mm2s_tdata[1*8+:8]),

                                ({8{axis_mm2s_tkeep[0]}} & axis_mm2s_tdata[0*8+:8])};
                                                                
        end
        else if (TDATA_WIDTH==32)
        begin
            assign s2mm_data = {({8{axis_s2mm_tkeep[3]}} & axis_s2mm_tdata[3*8+:8]),

                                ({8{axis_s2mm_tkeep[2]}} & axis_s2mm_tdata[2*8+:8]),

                                ({8{axis_s2mm_tkeep[1]}} & axis_s2mm_tdata[1*8+:8]),

                                ({8{axis_s2mm_tkeep[0]}} & axis_s2mm_tdata[0*8+:8])};

            assign mm2s_data = {({8{axis_mm2s_tkeep[3]}} & axis_mm2s_tdata[3*8+:8]),

                                ({8{axis_mm2s_tkeep[2]}} & axis_mm2s_tdata[2*8+:8]),

                                ({8{axis_mm2s_tkeep[1]}} & axis_mm2s_tdata[1*8+:8]),

                                ({8{axis_mm2s_tkeep[0]}} & axis_mm2s_tdata[0*8+:8])};
        end
        else if (TDATA_WIDTH==16)
        begin

            assign s2mm_data = {({8{axis_s2mm_tkeep[1]}} & axis_s2mm_tdata[1*8+:8]),

                                ({8{axis_s2mm_tkeep[0]}} & axis_s2mm_tdata[0*8+:8])};

            assign mm2s_data = {({8{axis_mm2s_tkeep[1]}} & axis_mm2s_tdata[1*8+:8]),

                                ({8{axis_mm2s_tkeep[0]}} & axis_mm2s_tdata[0*8+:8])};

        end
        else //if (TDATA_WIDTH==8)
        begin

            assign s2mm_data = ({8{axis_s2mm_tkeep[0]}} & axis_s2mm_tdata[0*8+:8]);

            assign mm2s_data = ({8{axis_mm2s_tkeep[0]}} & axis_mm2s_tdata[0*8+:8]);
        end
    endgenerate

    sgdma_axis_rx_assertion:
        assert property (@(posedge aclk) chk_trigger |-> ##1 (!compare_fail))
        else $error ("(%0t) [Error] Data mismatch : S2MM = %X ; MM2S = %X\n", $time,curr_s2mm_data,curr_mm2s_data);
         
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
