module tb_pc_blk ();
  bit clk, reset, enable = '1;

  logic [1:0] jump_mode;
  logic cond_skip_enable;
  logic [15:0] skip_amount;
  logic [7:0] jump_addr;
  logic [15:0] result;

  logic [15:0] expected_output;

  pc_blk pc_blk (
      .clk(clk),
      .reset(reset),
      .enable(enable),

      .jump_mode(jump_mode),
      .cond_skip_enable(cond_skip_enable),
      .skip_amount(skip_amount),
      .jump_addr(jump_addr),

      .cur_instr_addr(cur_instr_addr)
  );

  always begin  // clock
    #5ns clk = 1'b1;
    #5ns clk = 1'b0;
  end

  task automatic validate(logic [256*8:0] msg);
    #9ns;
    assert (expected_output == result)
    else $display("%s, %u != %u", msg, expected_output, cur_instr_addr);
    #1ns;
  endtask

  initial begin
    #15ns reset = 1'b0;
    #3ns;
    enable = 1;
    expected_output = 16'd0;

    // step instruction
    jump_mode = 2'd0;
    skip_amount = 16'd4;
    jump_addr = 16'd512;  // try a random value and see if it gets ignored
    cond_skip_enable = 1'd0;
    expected_output = 16'd1;
    validate("step failed");

    // skip forward
    jump_mode = 2'd0;
    skip_amount = 16'd4;
    jump_addr = 16'd512;  // try a random value and see if it gets ignored
    cond_skip_enable = 1'd0;
    expected_output = 16'd1;
    validate("step failed");

    // skip forward
    jump_mode = 2'd1;
    skip_amount = 16'd4;
    jump_addr = 16'd512;  // try a random value and see if it gets ignored
    cond_skip_enable = 1'd0;
    expected_output = 16'd1;
    validate("step failed");


    // nonzero skip/conditional skip
    jump_mode = 2'd2;
    skip_amount = 16'd4;
    jump_addr = 16'd512;  // try a random value and see if it gets ignored
    cond_skip_enable = 1'd0;
    expected_output = 16'd1;
    validate("step failed");

    // jump
    jump_mode = 2'd3;
    skip_amount = 16'd4;
    jump_addr = 16'd512;  // try a random value and see if it gets ignored
    cond_skip_enable = 1'd0;
    expected_output = 16'd1;
    validate("step failed");

  end
endmodule
