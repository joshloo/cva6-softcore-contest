`ifdef LAV_AT
  `ifndef DEBUG_C_CODE
  `define DEBUG_C_CODE

  module debug_c_code #(
  parameter DDR_TYPE      = 0,
  parameter ASSERT_ADDR   = 0,
  parameter GOOD_CODE     = 0
  )(
    input 	clk_i            ,
    input 	rst_i            ,
    input [31:0] cpu_addr     ,
    input [1:0]  cpu_htrans   ,
    input [31:0] cpu_hwdata   ,
    input        cpu_hwrite   ,
    output logic training_done,
    input        cpu_hreadyout
  );

  logic [31:0] cpu_masked_data;
  logic        check_en;
  logic [31:0] decode;
  logic        sig_train;
  logic [15:0] count;
  //logic training_done;
  integer i = 0;

  assign cpu_masked_data = cpu_hwdata & 32'hFF0000FF;
  assign decode          = cpu_hwdata[31:8];
  assign sig_train       = (cpu_masked_data == 32'h8000000D) ? decode[0] : 0;

  always_ff @(posedge clk_i or negedge rst_i) begin
    if(!rst_i) begin
      training_done  <=  1'b0;
    end
    else begin
      if(sig_train == 1) begin
        training_done <= 1'b1;
      end
      else begin
        training_done <= training_done;
      end
    end
  end

  always_ff @(posedge clk_i or negedge rst_i) begin
    if(!rst_i)
      check_en  <= 1'b0;
    else begin
      if (cpu_hreadyout) begin
        if((cpu_addr == ASSERT_ADDR) && (cpu_htrans == 2) && cpu_hwrite)
          check_en <= 1'b1;
        else
          check_en <= 1'b0;
      end
    end
  end //always_ff

  always @(negedge clk_i) begin
    if(check_en && cpu_hreadyout) begin
      case(cpu_masked_data)
        32'h80000001 : $display(" @ %0d [C_DBG]: udelay() Start", $time);
        32'h80000002 : $display(" @ %0d [C_DBG]: ZQ_CALIBRATION MRW_CTRL :reg_write_phy()", $time);
        32'h80000003 : $display(" @ %0d [C_DBG]: ZQ_LAT MRW_CTRL :reg_write_phy()", $time);
        32'h80000004 : $display(" @ %0d [C_DBG]: COMMAND_BUS_TRAINING STARTED : command_bus_training", $time);
        32'h80000005 : $display(" @ %0d [C_DBG]: CS/CA TRAINING ENTRY : cbt_entry_exit()", $time);
        32'h80000006 : begin
        $display(" @ %0d [C_DBG]: \n Terminate C code \n", $time);
        $finish;
          end
        32'h80000008 : $display(" @ %0d [C_DBG]: CS  TRAINING ENTRY   :do_training()", $time);
        32'h80000009 : $display(" @ %0d [C_DBG]: CS  TRAINING FIRST_BYTE : Value of first byte : %h first_byte short_cbt = %h cpu_hwdata = %h ", $time,decode[5:0],decode[16:8],cpu_hwdata);
        32'h80000007 : $display(" @ %0d [C_DBG]: CS  TRAINING VALUES  :cpu_masked_data =%h ca_training = %d ,cs_training = %d,first_read_pass =%d, no_pass_window_so_far = %d, pass_window_in_one_dir = %d , ca_training_complete = %d ",$time,cpu_hwdata,decode[0],~decode[0],decode[2],decode[4],decode[6],decode[8]);
        32'h80000010 : $display(" @ %0d [C_DBG]: CA  TRAINING ENTRY :   do_training()" ,$time);
        32'h80000014 : $display(" @ %0d [C_DBG]: CS  TRAINING ENTRY :   read_training_data_lp4() CBT_CTRL Sampled_data = %h  i = %d", $time, decode, i);
        32'h80000012 : $display(" @ %0d [C_DBG]: CS  TRAINING ENTRY :    read_training_data_lp4() WRLVL_CTRL read_Data = %h  i = %d", $time, decode, i);
        32'h80000013 : $display(" @ %0d [C_DBG]: CS  TRAINING ENTRY :    read_training_data_lp4() Return : Sampled_Data = %h ", $time, decode[5:0]);
        32'h8000000A : $display(" @ %0d [C_DBG]: ---------------------- WRITE_LEVELING PASS ----------------------------------------------", $time);
        32'h8000000C : $display(" @ %0d [C_DBG]: ---------------------- SCL passed for all LANES -----------------------------------------", $time);
        32'h8000000D : $display(" @ %0d [C_DBG]: ---------------------- TRAINING DONE  -----------------------------------------", $time);
        32'h80000021 : $display(" @ %0d [C_DBG]: ca_swizzle() Ended", $time);
        32'h80000022 : $display(" @ %0d [C_DBG]: execInitFilecmds() Register setting done. ", $time);
        32'h80000023 : $display(" @ %0d [C_DBG]: execInitFilecmds() Ended", $time);
        32'h80000018 : $display(" @ %0d [C_DBG]: training_pattern value = %h",$time, decode[5:0]);
        32'h80000019 : $display(" @ %0d [C_DBG]: cpu_hwdata = %h pass_count = %h",$time,cpu_hwdata ,decode[7:0]);
        32'h80000020 : $display(" @ %0d [C_DBG]: cpu_hwdata = %h first_pass = %d last_pass = %d",$time,cpu_hwdata,decode[7:0],decode[16:8]);
        32'h80000024 : $display(" @ %0d [C_DBG]: cpu_hwdata = %h incr_decr_trim = %d final_calibrated_dly = %d",$time,cpu_hwdata,decode[7:0],decode[16:8]);
        32'h80000025 : begin
                          if(decode[0] == 0)
                            $display("------------------------FULL LENGTH CBT TRAINING------------------------");
                          else
                            $display("------------------------THE CBT IS SHORTENED FOR SIMULATION----------- ");
                      end
        32'h80000026 : $display(" @ %0d [C_DBG]: ---------------------- READ_BIT_LEVELING PASS ----------------------------------------------", $time);
        32'h80000027 : $display(" @ %0d [C_DBG]: ---------------------- WRITE_BIT_LEVELING PASS ----------------------------------------------", $time);
        32'h80000029 : $display(" @ %0d [C_DBG]: ---------------------- DYNAMIC_BIT_LEVELING SKIPPED ----------------------------------------------", $time);
        32'h80000030 : count = cpu_hwdata[23:8];
      32'h80000031 : begin
                    $display(" @ %0d [C_DBG]: PLL Reg[%02d] = 0x%04x", $time, count, cpu_hwdata[23:8]);
            count = count +16'h0001;
      end
      32'h80000032 : $display(" @ %0d [C_DBG]: clock_freq_change(%0d) started", $time, cpu_hwdata[23:8]);
      32'h80000033 : $display(" @ %0d [C_DBG]: clock_freq_change() ended", $time);
      32'h80000034 : $display(" @ %0d [C_DBG]: training_status = 0x%0x", $time, cpu_masked_data[23:8]);
        GOOD_CODE    : begin
                      $display(" @ %0d [C_DBG]: GOOD_CODE - terminate the test", $time);
                      $finish;
        end


        default       : begin
          case (cpu_hwdata[31:24])
            8'hF1 :    $display(" @ %0d [C_DBG]: udelay(%0d) End", $time, cpu_hwdata[23:0]);
            default : begin
                      $display(" @ %0d [C_DBG]: ERROR in C, error_Code = 0x%08x", $time, cpu_hwdata);
                      $finish;
            end
          endcase
        end // default
      endcase
    end // if(check_en && cpu_hreadyout)
  end // always

  endmodule
  `endif
`else
  module debug_c_code #(
  parameter    DDR_TYPE    = 0,
  parameter    ASSERT_ADDR = 0,
  parameter    GOOD_CODE   = 0
  ) (
  input        clk_i        ,
  input        reset_n_i    ,
  input [31:0] cpu_haddr    ,
  input [1:0]  cpu_htrans   ,
  input [31:0] cpu_hwdata   ,
  input        cpu_hreadyout
  );

  logic        hwdata_check_en_r;
  logic [31:0] cpu_hwdata_masked;
  logic [15:0] debug_value;

  assign cpu_hwdata_masked = cpu_hwdata & 32'hF0000FFF;
  assign debug_value       = cpu_hwdata[27:12];

  always_ff @(posedge clk_i or negedge reset_n_i) begin
      if (!reset_n_i)
          hwdata_check_en_r <= 1'b0;
      else if ((cpu_haddr == ASSERT_ADDR) && (cpu_htrans == 2'h2) && cpu_hreadyout)
          hwdata_check_en_r <= 1'b1;
      else if (cpu_hreadyout)
          hwdata_check_en_r <= 1'b0;
  end

  always @(negedge clk_i) begin
      if (hwdata_check_en_r && cpu_hreadyout) begin
          case(cpu_hwdata_masked)
            // LPDDR4 debugs
            32'h80000001 : $display("%0d C-Code Debug: memc_init_fields()", $time);
            32'h80000002 : $display("%0d C-Code Debug: wait_phy_ready() done", $time);
            32'h80000003 : $display("%0d C-Code Debug: clock_freq_change()", $time);
            32'h80000004 : $display("%0d C-Code Debug: memc_cmd_bus_trn()", $time);
            32'h80000005 : $display("%0d C-Code Debug: memc_cmd_bus_trn_skip()", $time);
            32'h80000006 : $display("%0d C-Code Debug: memc_write_leveling()", $time);
            32'h80000007 : $display("%0d C-Code Debug: memc_write_leveling_skip()", $time);
            32'h80000008 : $display("%0d C-Code Debug: memc_read_dqs_training()", $time);
            32'h80000009 : $display("%0d C-Code Debug: memc_read_dqs_training_skip()", $time);
            32'h8000000A : $display("%0d C-Code Debug: memc_read_read_data_eye_training()", $time);
            32'h8000000B : $display("%0d C-Code Debug: memc_write_training()", $time);
            32'h8000000C : $display("%0d C-Code Debug: memc_write_training_skip()", $time);
            32'h8000000D : $display("%0d C-Code Debug: memc_initialize()", $time);
            32'h8000000E : $display("%0d C-Code Debug: cbt_check_dq_feedback(): %s", $time, ((debug_value == 0) ? "Pass" : "Fail"));
  //          32'h8010000E : $display("%0d C-Code Debug: cbt_check_dq_feedback(): Fail", $time);
            32'h8000000F : $display("%0d C-Code Debug: memc_cbt_scan()", $time);
            32'h80000010 : $display("%0d C-Code Debug: wrlvl_check_dq_feedback(): %s", $time, ((debug_value == 0) ? "Pass" : "Fail"));
  //          32'h80100010 : $display("%0d C-Code Debug: wrlvl_check_dq_feedback(): Fail", $time);
            32'h80000011 : $display("%0d C-Code Debug: memc_wrlvl_scan()", $time);
            32'h80000012 : $display("%0d C-Code Debug: memc_wrlvl_scan() negative path", $time);
            32'h80000013 : $display("%0d C-Code Debug: memc_cmd_bus_trn() CS training", $time);
            32'h80000014 : $display("%0d C-Code Debug: memc_delay_move(), cnt=%0d", $time, debug_value);
            32'h80000015 : $display("%0d C-Code Debug: memc_read_dqs_scan()", $time);
            32'h80000016 : $display("%0d C-Code Debug: memc_read_dqs_scan_fine()", $time);
            32'h80000017 : $display("%0d C-Code Debug: memc_read_tdqsq_training()", $time);
            32'h80000018 : $display("%0d C-Code Debug: memc_mc_dq_vref_training()", $time);
            32'h80000019 : $display("%0d C-Code Debug: memc_read_tdqsq_scan()", $time);
            32'h80000020 : $display("%0d C-Code Debug: memc_mem_dq_vref_training()", $time);
            32'h80000021 : $display("%0d C-Code Debug: memc_write_dqs2dq_scan()", $time);

            // DDR3 debugs
            32'hC0000001 : $display("%0d C-Code Debug: memc_ddr3_initialize()", $time);
            32'hC0000002 : $display("%0d C-Code Debug: memc_ddr3_write_leveling()", $time);
            32'hC0000003 : $display("%0d C-Code Debug: memc_ddr3_write_leveling_skip()", $time);
            32'hC0000004 : $display("%0d C-Code Debug: memc_ddr3_read_dqs_training()", $time);
            32'hC0000005 : $display("%0d C-Code Debug: memc_ddr3_read_dqs_training_skip()", $time);
            32'hC0000006 : $display("%0d C-Code Debug: memc_ddr3_wrlvl_scan()", $time);
            32'hC0000007 : $display("%0d C-Code Debug: memc_ddr3_read_dqs_scan()", $time);
            32'hC0000008 : $display("%0d C-Code Debug: memc_ddr3_read_tdqsck_scan()", $time);
            32'hC0000009 : $display("%0d C-Code Debug: memc_ddr3_read_tdqsck_training() done", $time);
            32'hC000000A : $display("%0d C-Code Debug: memc_ddr3_write_dqs2dq_scan()", $time);
            32'hC000000B : $display("%0d C-Code Debug: memc_ddr3_write_training()", $time);
            GOOD_CODE    : begin
                          $display("GOOD_CODE: C-Code terminates the test");
                          $finish;
            end
            default      : begin
                          $display("C-Code Error: C Error Code=0x%08x", cpu_hwdata);
                          $finish;
            end
          endcase
      end
  end

  endmodule
`endif
