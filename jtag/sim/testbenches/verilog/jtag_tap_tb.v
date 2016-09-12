 module 
  cde_jtag_tap_tb 
    #( parameter 
      BYPASS=4'b1111,
      CHIP_ID_ACCESS=4'b0011,
      CHIP_ID_VAL=32'h12345678,
      CLAMP=4'b1000,
      EXTEST=4'b0000,
      HIGHZ_MODE=4'b0010,
      INST_LENGTH=4,
      INST_RETURN=4'b1101,
      JTAG_MODEL_DIVCNT=4'h4,
      JTAG_MODEL_SIZE=4,
      JTAG_SEL=2,
      JTAG_USER1_RESET=8'h12,
      JTAG_USER1_WIDTH=8,
      JTAG_USER2_RESET=24'h123456,
      JTAG_USER2_WIDTH=24,
      PERIOD=40,
      RPC_ADD=4'b1001,
      RPC_DATA=4'b1010,
      SAMPLE=4'b0001,
      TIMEOUT=100000)
     (
 input   wire                 START,
 input   wire                 clk,
 output   wire                 FAIL,
 output   wire                 FINISH);
wire                        BAD;
wire                        STOP;
wire                        aux_select_o;
wire                        aux_tdo_i;
wire                        bsr_output_mode;
wire                        bsr_select_o;
wire                        bsr_tdo_i;
wire                        capture_dr_o;
wire                        jtag_clk;
wire                        reset;
wire                        select_o;
wire                        shift_dr_o;
wire                        shiftcapture_dr_clk_o;
wire                        tap_highz_mode;
wire                        tclk_pad_in;
wire                        tdi_o;
wire                        tdi_pad_in;
wire                        tdo_i;
wire                        tdo_pad_oe;
wire                        tdo_pad_out;
wire                        test_logic_reset_o;
wire                        tms_pad_in;
wire                        trst_n_pad_in;
wire                        update_dr_clk_o;
wire                        update_dr_o;
wire     [ 31 :  0]              bsr_wire;
wire     [ JTAG_USER1_WIDTH-1 :  0]              rpc_1_wire;
wire     [ JTAG_USER2_WIDTH-1 :  0]              rpc_2_wire;
/*  opencores.org:cde:jtag:classic_rpc_reg  */ 
cde_jtag_classic_rpc_reg
#( .BITS (32),
   .RESET_VALUE (32'h12345678))
bsr 
   (
    .capture_dr      ( capture_dr_o  ),
    .capture_value      ( bsr_wire[31:0] ),
    .select      ( bsr_select_o  ),
    .shift_dr      ( shift_dr_o  ),
    .shiftcapture_dr_clk      ( shiftcapture_dr_clk_o  ),
    .tdi      ( tdi_o  ),
    .tdo      ( bsr_tdo_i  ),
    .test_logic_reset      ( test_logic_reset_o  ),
    .update_dr_clk      ( update_dr_clk_o  ),
    .update_value      ( bsr_wire[31:0] ));
/*  opencores.org:Testbench:clock_gen:def  */ 
clock_gen_def
cg 
   (
    .BAD      ( BAD  ),
    .FAIL      ( FAIL  ),
    .FINISH      ( FINISH  ),
    .START      ( START  ),
    .STOP      ( STOP  ),
    .clk      ( clk  ),
    .reset      ( reset  ));
/*  opencores.org:cde:jtag:tap  */ 
cde_jtag_tap
#( .BYPASS (BYPASS),
   .CHIP_ID_ACCESS (CHIP_ID_ACCESS),
   .CHIP_ID_VAL (CHIP_ID_VAL),
   .CLAMP (CLAMP),
   .EXTEST (EXTEST),
   .HIGHZ_MODE (HIGHZ_MODE),
   .INST_LENGTH (INST_LENGTH),
   .INST_RETURN (INST_RETURN),
   .RPC_ADD (RPC_ADD),
   .RPC_DATA (RPC_DATA),
   .SAMPLE (SAMPLE))
dut 
   (
    .aux_select_o      ( aux_select_o  ),
    .aux_tdo_i      ( aux_tdo_i  ),
    .bsr_output_mode      ( bsr_output_mode  ),
    .bsr_select_o      ( bsr_select_o  ),
    .bsr_tdo_i      ( bsr_tdo_i  ),
    .capture_dr_o      ( capture_dr_o  ),
    .jtag_clk      ( jtag_clk  ),
    .select_o      ( select_o  ),
    .shift_dr_o      ( shift_dr_o  ),
    .shiftcapture_dr_clk_o      ( shiftcapture_dr_clk_o  ),
    .tap_highz_mode      ( tap_highz_mode  ),
    .tclk_pad_in      ( tclk_pad_in  ),
    .tdi_o      ( tdi_o  ),
    .tdi_pad_in      ( tdi_pad_in  ),
    .tdo_i      ( tdo_i  ),
    .tdo_pad_oe      ( tdo_pad_oe  ),
    .tdo_pad_out      ( tdo_pad_out  ),
    .test_logic_reset_o      ( test_logic_reset_o  ),
    .tms_pad_in      ( tms_pad_in  ),
    .trst_n_pad_in      ( trst_n_pad_in  ),
    .update_dr_clk_o      ( update_dr_clk_o  ),
    .update_dr_o      ( update_dr_o  ));
/*  opencores.org:Testbench:jtag_model:def  */ 
jtag_model_def
#( .DIVCNT (JTAG_MODEL_DIVCNT),
   .SIZE (JTAG_MODEL_SIZE))
jtag_model 
   (
    .clk      ( clk  ),
    .reset      ( reset  ),
    .tclk      ( tclk_pad_in  ),
    .tdi      ( tdo_pad_out  ),
    .tdo      ( tdi_pad_in  ),
    .tms      ( tms_pad_in  ),
    .trst_n      ( trst_n_pad_in  ));
/*  opencores.org:cde:jtag:classic_rpc_reg  */ 
cde_jtag_classic_rpc_reg
#( .BITS (JTAG_USER1_WIDTH),
   .RESET_VALUE (JTAG_USER1_RESET))
rpc_1 
   (
    .capture_dr      ( capture_dr_o  ),
    .capture_value      ( rpc_1_wire[JTAG_USER1_WIDTH-1:0] ),
    .select      ( select_o  ),
    .shift_dr      ( shift_dr_o  ),
    .shiftcapture_dr_clk      ( shiftcapture_dr_clk_o  ),
    .tdi      ( tdi_o  ),
    .tdo      ( tdo_i  ),
    .test_logic_reset      ( test_logic_reset_o  ),
    .update_dr_clk      ( update_dr_clk_o  ),
    .update_value      ( rpc_1_wire[JTAG_USER1_WIDTH-1:0] ));
/*  opencores.org:cde:jtag:classic_rpc_in_reg  */ 
cde_jtag_classic_rpc_in_reg
#( .BITS (JTAG_USER2_WIDTH))
rpc_2 
   (
    .capture_dr      ( capture_dr_o  ),
    .capture_value      ( rpc_2_wire[JTAG_USER2_WIDTH-1:0] ),
    .select      ( aux_select_o  ),
    .shift_dr      ( shift_dr_o  ),
    .shiftcapture_dr_clk      ( shiftcapture_dr_clk_o  ),
    .tdi      ( tdi_o  ),
    .tdo      ( aux_tdo_i  ),
    .test_logic_reset      ( test_logic_reset_o  ));
reg [JTAG_USER2_WIDTH-1:0] rpc_2_reg;
always @(posedge clk or posedge reset)
begin
if(reset)  rpc_2_reg <= JTAG_USER2_RESET; 
else       rpc_2_reg <= rpc_2_reg;
end
assign  rpc_2_wire =   rpc_2_reg;
  endmodule
