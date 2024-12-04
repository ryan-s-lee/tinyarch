module tinyarch (
    input logic clk,  // your DUT goes here
    input logic reset,
    input logic start,
    output logic done
);
  logic [8:0] instr;
  logic enable;
  logic [1:0] jump_mode;
  logic reg_wr_enable;
  logic mem_wr_enable;
  logic load_from_mem;
  logic [3:0] operation;
  logic [1:0] op2_sel;
  logic [1:0] reg1_sel;
  logic [2:0] wr_reg_sel;
  logic reg2_sel;
  logic [3:0] reg2;
  logic [3:0] reg2_decider_reg2;
  logic op1_sel;
  logic [7:0] op1;

  logic [7:0] ry_value;
  logic [7:0] rx_value;
  logic [3:0] wr_reg;

  bit        RamReadMem = 1;
  wire [7:0] RamDataOut;  // data output port

  logic [15:0] cur_instr_addr;

  bit  [15:0] InsDataAddress;  // pointer
  assign InsDataAddress = cur_instr_addr;

  bit        InsReadMem = 1;
  bit        InsWriteMem = 0;  // write enable
  bit  [8:0] InsDataIn = 0;  // data input port

  logic [3:0] reg1_decider_reg1;

  logic [7:0] op2;

  logic exit;
  logic [7:0] alu_result;

  always_ff @(posedge clk) begin  // pc counter enable register
    if (start)
      enable <= 1;
    if (exit || reset)
      enable <= 0;
  end

  pc_blk pc_blk (
    .clk(clk),
    .enable(enable),
    .reset(start),
    .jump_mode(jump_mode),
    .cond_skip_enable(|rx_value),
    .skip_amount({13'h0, instr[2:0]} + 4'h2),  // +1 for bias, +1 to count the normal step
    .jump_addr({ry_value, rx_value}),

    .cur_instr_addr(cur_instr_addr)
    );


  data_mem #(
      .ADDR_WIDTH (16),
      .DATA_WIDTH(9)
  ) instr_mem (
      .clk(clk),
      .DataAddress(InsDataAddress),
      .ReadMem(InsReadMem),
      .WriteMem(InsWriteMem),
      .DataIn(InsDataIn),
      .DataOut(instr)
  );

  ctrl_blk ctrl_blk (
    .instr(instr),
    .finished(done),

    .jump_mode(jump_mode),
    .reg_wr_enable(reg_wr_enable),
    .mem_wr_enable(mem_wr_enable),
    .load_from_mem(load_from_mem),
    .operation(operation),
    .op1_sel(op1_sel),
    .op2_sel(op2_sel),
    .reg1_sel(reg1_sel),
    .reg2_sel(reg2_sel),
    .wr_reg_sel(wr_reg_sel)
  );


  reg1_decider reg1_decider(
    .reg1_sel(reg1_sel),
    .instr(instr),

    .reg1(reg1_decider_reg1)
    );


  reg2_decider reg2_decider(
    .reg2_sel(reg2_sel),
    .instr(instr),

    .reg2(reg2_decider_reg2)
    );

  reg_file reg_file (
    .clk(clk),
    .rx(reg1_decider_reg1),
    .ry(reg2_decider_reg2),  // TODO: Provide the ability to switch to accumulator, for sti instruction
    .wr_reg(wr_reg),
    .wr_value(load_from_mem ? RamDataOut : alu_result),
    .wr_enable(reg_wr_enable),

    .rx_value(rx_value),
    .ry_value(ry_value)
    );


  op1_decider op1_decider (
    .op1_sel(op1_sel),
    .instr(instr),
    .reg1_value(rx_value),

    .op1(op1)
    );

  op2_decider op2_decider (
    .instr(instr),
    .reg2_value(ry_value),
    .op2_sel(op2_sel),

    .op2(op2)
    );

  alu alu (
    .clk(clk),
    .rst(1'b0),
    .op1(op1),
    .op2(op2),
    .operation(operation),

    .result(alu_result),
    .exit(exit)
    );

  data_mem #(
      .ADDR_WIDTH (8),
      .DATA_WIDTH(8)
  ) data_mem1 (
      .clk(clk),
      .DataAddress(alu_result),
      .ReadMem(RamReadMem),
      .WriteMem(mem_wr_enable),

      // TODO: fix! rx is going to be the frame pointer. ry must be the register to use for the accumulator.
      // However, ry must be assigned as the accumulator value. So we need
      // another register selector for ry, or a way to pick the first operator
      // of alu (not just the second, like before).
      .DataIn(rx_value),  // whenever writemem is on, should always be accumulator. TODO: codify in test bench.

      .DataOut(RamDataOut)
  );


  wr_reg_decider wr_reg_decider(
    .wr_reg_sel(wr_reg_sel),
    .instruction(instr),
    .wr_reg(wr_reg)
    );

  always_ff @(posedge clk) begin  // ack register
    if (reset || start) done <= 0;
    if (exit) done <= 1;  // TODO: If pipelining, must use the exit signal of the last stage.
  end
endmodule
