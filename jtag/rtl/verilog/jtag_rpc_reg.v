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
  cde_jtag_rpc_reg 
    #( parameter 
      BITS=16,
      RESET_VALUE='h0)
     (
 input   wire                 capture_dr,
 input   wire                 clk,
 input   wire                 reset,
 input   wire                 select,
 input   wire                 shift_dr,
 input   wire                 tdi,
 input   wire                 update_dr,
 input   wire    [ BITS-1 :  0]        capture_value,
 output   reg    [ BITS-1 :  0]        update_value,
 output   wire                 tdo);
// shift  buffer and shadow
reg [BITS-1:0]  buffer;
always @(posedge clk or posedge reset)
  if (reset)                            buffer <= RESET_VALUE;
  else 
  if (select && capture_dr)             buffer <= capture_value;
  else 
  if (select && shift_dr)               buffer <= { tdi, buffer[BITS-1:1] };
  else                                  buffer <= buffer;
  always @(posedge update_dr  or posedge reset)
   if (reset)                          update_value <= RESET_VALUE;
   else 
   if (select)                         update_value <= buffer;
   else                                update_value <= update_value;
assign tdo = buffer[0];
  endmodule
