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
  cde_jtag_tap_sm 
    #( parameter 
      BYPASS=4'b1111,
      CHIP_ID_ACCESS=4'b0011,
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
 input   wire                 clk,
 input   wire                 tdi_pad_in,
 input   wire                 tdo_in,
 input   wire                 tms_pad_in,
 input   wire                 trst_n_pad_in,
 output   reg                 bsr_output_mode,
 output   reg                 capture_dr_o,
 output   reg                 shift_dr_o,
 output   reg                 tap_highz_mode,
 output   reg                 tdo_pad_oe,
 output   reg                 tdo_pad_out,
 output   reg                 test_logic_reset_o,
 output   reg                 update_dr_o,
 output   reg    [ 3 :  0]        instruction,
 output   wire                 jtag_reset,
 output   wire                 update_dr_clk_o);
//********************************************************************
//*** 
//********************************************************************
reg     [ 3 :  0]          next_tap_state;
reg     [ 3 :  0]          tap_state;
reg                        bypass_tdo;
reg                        capture_ir;
reg                        next_tdo;
reg                        shift_ir;
reg                        update_ir;
assign jtag_reset  = ! trst_n_pad_in;
//********************************************************************
//*** TAP Controller State Machine
//********************************************************************
// TAP state parameters
localparam TEST_LOGIC_RESET = 4'b1111, 
           RUN_TEST_IDLE    = 4'b1100,
           SELECT_DR_SCAN   = 4'b0111, 
           CAPTURE_DR       = 4'b0110,
           SHIFT_DR         = 4'b0010, 
           EXIT1_DR         = 4'b0001,
           PAUSE_DR         = 4'b0011,
           EXIT2_DR         = 4'b0000,
           UPDATE_DR        = 4'b0101,
           SELECT_IR_SCAN   = 4'b0100, 
           CAPTURE_IR       = 4'b1110,
           SHIFT_IR         = 4'b1010,
           EXIT1_IR         = 4'b1001,
           PAUSE_IR         = 4'b1011,
           EXIT2_IR         = 4'b1000,
           UPDATE_IR        = 4'b1101;
// next state decode for tap controller
always @(*)
    case (tap_state)	// synopsys parallel_case
      TEST_LOGIC_RESET: next_tap_state = tms_pad_in ? TEST_LOGIC_RESET : RUN_TEST_IDLE;
      RUN_TEST_IDLE:    next_tap_state = tms_pad_in ? SELECT_DR_SCAN   : RUN_TEST_IDLE;
      SELECT_DR_SCAN:   next_tap_state = tms_pad_in ? SELECT_IR_SCAN   : CAPTURE_DR;
      CAPTURE_DR:       next_tap_state = tms_pad_in ? EXIT1_DR         : SHIFT_DR;
      SHIFT_DR:         next_tap_state = tms_pad_in ? EXIT1_DR         : SHIFT_DR;
      EXIT1_DR:         next_tap_state = tms_pad_in ? UPDATE_DR        : PAUSE_DR;
      PAUSE_DR:         next_tap_state = tms_pad_in ? EXIT2_DR         : PAUSE_DR;
      EXIT2_DR:         next_tap_state = tms_pad_in ? UPDATE_DR        : SHIFT_DR;
      UPDATE_DR:        next_tap_state = tms_pad_in ? SELECT_DR_SCAN   : RUN_TEST_IDLE;
      SELECT_IR_SCAN:   next_tap_state = tms_pad_in ? TEST_LOGIC_RESET : CAPTURE_IR;
      CAPTURE_IR:       next_tap_state = tms_pad_in ? EXIT1_IR         : SHIFT_IR;
      SHIFT_IR:         next_tap_state = tms_pad_in ? EXIT1_IR         : SHIFT_IR;
      EXIT1_IR:         next_tap_state = tms_pad_in ? UPDATE_IR        : PAUSE_IR;
      PAUSE_IR:         next_tap_state = tms_pad_in ? EXIT2_IR         : PAUSE_IR;
      EXIT2_IR:         next_tap_state = tms_pad_in ? UPDATE_IR        : SHIFT_IR;
      UPDATE_IR:        next_tap_state = tms_pad_in ? SELECT_DR_SCAN   : RUN_TEST_IDLE;
    endcase
//********************************************************************
//*** TAP Controller State Machine Register
//********************************************************************
always @(posedge clk or negedge trst_n_pad_in)
  if (!trst_n_pad_in)     tap_state  <= TEST_LOGIC_RESET;
  else                    tap_state  <= next_tap_state;
 always @(*)
   begin
   shift_ir     = (tap_state == SHIFT_IR);
   shift_dr_o   = (tap_state == SHIFT_DR);
   update_ir    = (tap_state == UPDATE_IR);
   update_dr_o  = (tap_state == UPDATE_DR);
   capture_dr_o = (tap_state == CAPTURE_DR);
   capture_ir   = (tap_state == CAPTURE_IR);
  end
//******************************************************
//*** Instruction Register
//******************************************************
reg	[INST_LENGTH-1:0]      instruction_buffer;
// buffer the instruction register while shifting
always @(posedge clk or negedge trst_n_pad_in)
  if (!trst_n_pad_in)          instruction_buffer <= INST_RESET;
  else 
  if (capture_ir)              instruction_buffer <= INST_RETURN;  
  else 
  if (shift_ir)                instruction_buffer <= {tdi_pad_in,instruction_buffer[INST_LENGTH-1:1]};
always @(posedge clk  or negedge trst_n_pad_in)
  if (!trst_n_pad_in)                   instruction <= INST_RESET;
  else 
  if (tap_state == TEST_LOGIC_RESET)    instruction <= INST_RESET;
  else 
  if (update_ir)                        instruction <= instruction_buffer;
//**********************************************************
// Decode tap_state to get test_logic_reset  signal
//**********************************************************
always @(posedge clk  or negedge trst_n_pad_in)
if (!trst_n_pad_in)                        test_logic_reset_o   <= 1'b1;
else 
if (next_tap_state == TEST_LOGIC_RESET)    test_logic_reset_o   <= 1'b1;
else                                       test_logic_reset_o   <= 1'b0;
//**********************************************************
//** Boundary scan control signals
//**********************************************************
always @(posedge clk  or negedge trst_n_pad_in)
  if (!trst_n_pad_in)                             bsr_output_mode <= 1'b0;
  else 
  if (tap_state == TEST_LOGIC_RESET)       bsr_output_mode <= 1'b0;
  else 
  if (update_ir)                           bsr_output_mode <=    (instruction_buffer  == EXTEST) || (instruction_buffer  == CLAMP);
//**********************************************************
//**  Control chip pads when we are in highz_mode
//**********************************************************
always @(posedge clk  or negedge trst_n_pad_in)
  if (!trst_n_pad_in)                                 tap_highz_mode <= 1'b0;
  else if (tap_state == TEST_LOGIC_RESET)      tap_highz_mode <= 1'b0;
  else if (update_ir)                          tap_highz_mode <= (instruction_buffer  == HIGHZ_MODE);
//**********************************************************
//*** Bypass register
//**********************************************************
always @(posedge clk or negedge trst_n_pad_in)
  if (!trst_n_pad_in)         bypass_tdo <= 1'b0;
  else 
  if (capture_dr_o)           bypass_tdo <= 1'b0;
  else 
  if (shift_dr_o)             bypass_tdo <= tdi_pad_in;
  else                        bypass_tdo <= bypass_tdo;
//****************************************************************
//*** Choose what goes out on the TDO pin
//****************************************************************
// bypass anytime we are not doing a defined instructions, or if in clamp or bypass mode
wire bypass_select;
assign   bypass_select  = ( instruction == CLAMP ) || ( instruction == BYPASS );
// output the instruction register when tap_state[3] is 1, else
//   put out the appropriate data register.  
always@(*)
  begin
     if( tap_state[3] )    next_tdo =  instruction_buffer[0];
     else
     if(bypass_select)     next_tdo =  bypass_tdo;
     else                  next_tdo =  tdo_in;
  end
wire   clk_n;
assign clk_n = ! clk;
always @(posedge clk_n or negedge trst_n_pad_in)
        if (!trst_n_pad_in)         tdo_pad_out <= 1'b0;
        else                        tdo_pad_out <= next_tdo;
// output enable for TDO pad
always @(posedge clk_n or negedge trst_n_pad_in)
	if ( !trst_n_pad_in )    tdo_pad_oe   <= 1'b0;
	else                     tdo_pad_oe   <= ( (tap_state == SHIFT_DR) || (tap_state == SHIFT_IR) );
  endmodule
