module tinyarch (
    input clk,  // your DUT goes here
    input reset,
    input req,
    output logic ack
);

  bit        RamCLK;
  bit  [7:0] RamDataAddress = 0;  // pointer
  bit        RamReadMem = 0;
  bit        RamWriteMem = 0;  // write enable
  bit  [7:0] RamDataIn = 0;  // data input port
  wire [7:0] RamDataOut;  // data output port
  assign RamCLK = clk;
  data_mem #(
      .BUS_WIDTH (8),
      .DATA_WIDTH(8)
  ) data_mem1 (
      .CLK(RamCLK),
      .DataAddress(RamDataAddress),
      .ReadMem(RamReadMem),
      .WriteMem(RamWriteMem),
      .DataIn(RamDataIn),
      .DataOut(RamDataOut)
  );

  bit        InsCLK;
  bit  [7:0] InsDataAddress = 0;  // pointer
  bit        InsReadMem = 0;
  bit        InsWriteMem = 0;  // write enable
  bit  [7:0] InsDataIn = 0;  // data input port
  wire [7:0] InsDataOut;  // data output port
  assign InsCLK = clk;
  data_mem #(
      .BUS_WIDTH (16),
      .DATA_WIDTH(9)
  ) instr_mem (
      .DataAddress(InsDataAddress),
      .ReadMem(InsReadMem),
      .WriteMem(InsWriteMem),
      .DataIn(InsDataIn),
      .DataOut(InsDataOut)
  );
  assign ack = 1'b1;

endmodule
