// =============================================================================
//                         FILE DETAILS         
// Project               : 
// File                  : defines.v
// Title                 : 
// Dependencies          : 1.
//                       : 2.
// Description           : 
// =============================================================================
//                        REVISION HISTORY
// Version               : 1.0.0
// Author(s)             : 
// Mod. Date             : 
// Changes Made          : Initial release.
// =============================================================================

// -----------------------------------------------------------------------------
// Test Knobs
// -----------------------------------------------------------------------------

`ifndef TEST_LOG_FILE
  `define LOG_FILE  "OFF"
 `else
  `define LOG_FILE  "ON"
`endif

// -----------------------------------------------------------------------------
// Misc
// -----------------------------------------------------------------------------
`ifndef NORMAL_MSG
  `define NORMAL_MSG  "ON"
`endif

`ifndef ERROR_MSG
  `define ERROR_MSG   "ON"
`endif

`ifndef WARNING_MSG
  `define WARNING_MSG "ON"
`endif

`define INC(cnt) cnt=((cnt)+1);
`define DEC(cnt) cnt=((cnt)-1);

`define TIME_DELAY(num_cycles,clk) repeat((num_cycles)) @(posedge (clk));
`define TIMED_FINISH(num_cycles,clk) `TIME_DELAY(num_cycles,clk)$finish;

`define MSG_FORMAT(tag,msg) $display("[%t]:%0s%0s[%m]%0s%0s",\
                            $time,tag,"---","--- ",($sformatf msg));
`define MSG_FORMAT_ERR(tag,msg) $error("[%0t]:%0s%0s[%m]%0s%0s",\
                            $time,tag,"---","--- ",($sformatf msg));

`define DATA_FORMAT(tag,msg) $display("[%t]:%0s%0s %0s",\
                             $time,tag,"---",($sformatf msg));

`define D_LOG(msg) \
        begin \
          if(`LOG_FILE == "ON") \
          begin \
              $fdisplay(tb_top.tx_fptr,($sformatf("[%t]:%0s%0s[%m]%0s%0s", \
                                        $time,"[Data]","---","---",($sformatf msg)))); \
          end \
        end

`define D_MSG(msg) \
        begin \
          if(`NORMAL_MSG == "ON") \
          begin \
            `DATA_FORMAT("[Data]",msg) \
          end \
        end

`define K_MSG(msg) \
        begin \
          if(`NORMAL_MSG == "ON") \
          begin \
            if (tx0rx1) \
            `MSG_FORMAT("[Rx K-ch]",msg) \
            else \
            `MSG_FORMAT("[Tx K-ch]",msg) \
            `D_LOG(msg) \
          end \
        end

`define C_MSG(msg) \
        begin \
          if(`NORMAL_MSG == "ON") \
          begin \
            if (tx0rx1) \
            `MSG_FORMAT("[Rx Cfg ]",msg) \
            else \
            `MSG_FORMAT("[Tx Cfg ]",msg) \
            `D_LOG(msg) \
          end \
        end

`define N_MSG(msg) \
        begin \
          if(`NORMAL_MSG == "ON") \
          begin \
            //`INC(tb_top.n_msg_cnt) \
            `MSG_FORMAT("[Normal ]",msg) \
          end \
        end

`define E_MSG(msg) \
        begin \
          if(`ERROR_MSG == "ON") \
          begin \
            //`INC(tb_top.e_msg_cnt) \
            `MSG_FORMAT_ERR("[Error  ]",msg) \
          end \
        end

`define W_MSG(msg) \
        begin \
          if(`WARNING_MSG == "ON") \
          begin \
            //`INC(tb_top.w_msg_cnt) \
            `MSG_FORMAT("[Warning]",msg) \
          end \
        end

`define ENDSIM(num_cycles,clk) \
        begin \
          `TIME_DELAY(num_cycles,clk) \
          //tb_top.report; \
          $finish; \
        end

//=============================================================================
// defines.v
// Local Variables:
// verilog-library-directories:(".")
// End:
//=============================================================================
