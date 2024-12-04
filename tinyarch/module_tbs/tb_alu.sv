module tb_alu ();
  bit clk, reset = '1;
  logic [7:0] op1, op2;

  // Recall operations are:
  // 0. add
  // 1. rshift
  // 2. lshift
  // 3. bitwise or
  // 4. bitwise and
  // 5. set-op2
  // 6. set-op2
  // 7.
  // 8. bitwise negation
  // 9. logical negation
  // 10. shift overflow
  // 11. add carry
  // 12. exit
  // 13. no-op
  // 14. jump
  // 15.
  logic [3:0] operation;
  logic [7:0] expected_output;
  logic [7:0] result;

  alu alu (
      .clk(clk),
      .rst(1'b0),
      .op1(op1),
      .op2(op2),
      .operation(operation),
      .result(result),
      .exit()
  );

  always begin  // clock
    #5ns clk = 1'b1;
    #5ns clk = 1'b0;
  end

  task automatic validate (logic [256*8:0] msg);
    #9ns;
    assert (expected_output == result) else $display("%s, %u != %u", msg, expected_output, result);
    #1ns;
  endtask

  initial begin  // test sequence
    #20ns reset = 1'b0;
    #8ns;

    // add
    {op1, op2, operation, expected_output} = {8'd0, 8'd3, 4'd0, 8'd3};
    validate("add failed");
    // rshift
    {op1, op2, operation, expected_output} = {8'd128, 8'd3, 4'd1, 8'd16};
    validate("rshift failed");
    // lshift
    {op1, op2, operation, expected_output} = {8'd1, 8'd3, 4'd2, 8'd8};
    validate("lshift failed");
    // bor
    {op1, op2, operation, expected_output} = {8'b11011101, 8'b00111100, 4'd3, 8'b11111101};
    validate("bitwise or failed");
    // ban
    {op1, op2, operation, expected_output} = {8'b11011101, 8'b00111100, 4'd4, 8'b00011100};
    validate("bitwise and failed");
    // set-op2
    {op1, op2, operation, expected_output} = {8'b11011101, 8'b00111100, 4'd5, 8'b00111100};
    validate("set op2 failed for operation 5");
    {op1, op2, operation, expected_output} = {8'b11011101, 8'b00111100, 4'd6, 8'b00111100};
    validate("set op2 failed for operation 6");
    // bne
    {op1, op2, operation, expected_output} = {8'b11011101, 8'b00111100, 4'd8, 8'b00100010};
    validate("bitwise negation failed");
    // lne
    {op1, op2, operation, expected_output} = {8'b11011101, 8'b00111100, 4'd9, 8'd0};
    validate("logical negation with negative output failed");
    {op1, op2, operation, expected_output} = {8'b00000000, 8'b00111100, 4'd9, 8'd1};
    validate("logical negation with positive output failed");
    // sho
    {op1, op2, operation, expected_output} = {8'b00110000, 8'd3, 4'd2, 8'b10000000};
    validate("lshift failed during shift overflow test");
    {op1, op2, operation, expected_output} = {8'b00000000, 8'd3, 4'd10, 8'b00000001};
    validate("shift overflow failed");
    // adc
    {op1, op2, operation, expected_output} = {8'd255, 8'd3, 4'd0, 8'd2};
    validate("addition failed during add carry test");
    {op1, op2, operation, expected_output} = {8'd255, 8'd3, 4'd11, 8'd0};
    validate("add carry #1 failed");
    {op1, op2, operation, expected_output} = {8'd128, 8'd3, 4'd11, 8'd129};
    validate("add carry #2 failed");
    $stop;
  end

endmodule
