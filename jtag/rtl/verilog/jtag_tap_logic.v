/**********************************************************************/
/*                                                                    */
/*                                                                    */
/*   Copyright (c) 2012-2015 Ouabache Design Works                    */
/*                                                                    */
/*          All Rights Reserved Worldwide                             */
/*                                                                    */
/*   Licensed under the Apache License,Version2.0 (the'License');     */
/*   you may not use this file except in compliance with the License. */
/*   You may obtain a copy of the License at                          */
/*                                                                    */
/*       http://www.apache.org/licenses/LICENSE-2.0                   */
/*                                                                    */
/*   Unless required by applicable law or agreed to in                */
/*   writing, software distributed under the License is               */
/*   distributed on an 'AS IS' BASIS, WITHOUT WARRANTIES              */
/*   OR CONDITIONS OF ANY KIND, either express or implied.            */
/*   See the License for the specific language governing              */
/*   permissions and limitations under the License.                   */
/**********************************************************************/
 module 
  cde_jtag_tap_logic 
    #( parameter 
      BYPASS=4'b1111,
      CHIP_ID_ACCESS=4'b0011,
      CHIP_ID_VAL=32'h00000000,
      CLAMP=4'b1000,
      EXTEST=4'b0000,
      HIGHZ_MODE=4'b0010,
      INST_LENGTH=4,
      INST_RESET=4'b1111,
      INST_RETURN=4'b1101,
      NUM_USER=2,
      RPC_ADD=4'b1001,
      RPC_DATA=4'b1010,
      SAMPLE=4'b0001,
      USER=8'b1010_1001)
     (
 input   wire                 aux_tdo_i,
 input   wire                 capture_dr_o,
 input   wire                 chip_id_tdo,
 input   wire                 jtag_shift_clk,
 input   wire                 shift_dr_o,
 input   wire                 tdi_pad_in,
 input   wire                 tdo_i,
 input   wire                 test_logic_reset_o,
 input   wire                 update_dr_clk_o,
 input   wire                 update_dr_o,
 input   wire    [ 3 :  0]        instruction,
 output   reg                 next_tdo,
 output   wire                 aux_capture_dr_o,
 output   wire                 aux_jtag_clk,
 output   wire                 aux_select_o,
 output   wire                 aux_shift_dr_o,
 output   wire                 aux_shiftcapture_dr_clk_o,
 output   wire                 aux_tdi_o,
 output   wire                 aux_test_logic_reset_o,
 output   wire                 aux_update_dr_clk_o,
 output   wire                 aux_update_dr_o,
 output   wire                 bsr_select_o,
 output   wire                 chip_id_select,
 output   wire                 clamp,
 output   wire                 extest,
 output   wire                 jtag_clk,
 output   wire                 jtag_reset,
 output   wire                 sample,
 output   wire                 select_o,
 output   wire                 shiftcapture_dr_clk_o,
 output   wire                 shiftcapture_dr_o,
 output   wire                 tdi_o,
 output   wire    [ 31 :  0]        chip_id_value);
//********************************************************************
//*** assignments for 2nd channel
//********************************************************************
 assign      aux_jtag_clk               = jtag_clk;
 assign      aux_update_dr_clk_o        = update_dr_clk_o;
 assign      aux_shiftcapture_dr_clk_o  = shiftcapture_dr_clk_o;
 assign      aux_test_logic_reset_o     = test_logic_reset_o;
 assign      aux_tdi_o                  = tdi_o;
 assign      aux_capture_dr_o           = capture_dr_o;
 assign      aux_shift_dr_o             = shift_dr_o;
 assign      aux_update_dr_o            = update_dr_o;
 assign      chip_id_value              = CHIP_ID_VAL ;
 assign      shiftcapture_dr_o          =  shift_dr_o || capture_dr_o;   
 assign      tdi_o                      =  tdi_pad_in;   
// Instruction Decoder
 assign      extest          = ( instruction == EXTEST );
 assign      sample          = ( instruction == SAMPLE );
 assign      clamp           = ( instruction == CLAMP );
 assign      chip_id_select  = ( instruction == CHIP_ID_ACCESS );
// bypass anytime we are not doing a defined instructions, or if in clamp or bypass mode
 assign      shiftcapture_dr_clk_o     =  jtag_shift_clk;
 assign      select_o                  = ( instruction == RPC_ADD );
 assign      aux_select_o              = ( instruction == RPC_DATA );
 assign      bsr_select_o              = ( instruction == EXTEST ) || ( instruction == SAMPLE )       ;
//****************************************************************
//*** Choose what goes out on the TDO pin
//****************************************************************
always@(*)
  begin
     if(chip_id_select)       next_tdo =  chip_id_tdo;
     else
     if(select_o)             next_tdo =  tdo_i;
     else
     if(aux_select_o)         next_tdo =  aux_tdo_i;
     else                     next_tdo =  1'b0;
  end
  endmodule
