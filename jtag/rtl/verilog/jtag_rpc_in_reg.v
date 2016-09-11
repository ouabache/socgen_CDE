 module 
  cde_jtag_rpc_in_reg 
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
 input   wire    [ BITS-1 :  0]        capture_value,
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
 assign tdo = buffer[0];
  endmodule
