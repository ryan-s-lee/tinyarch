module wr_reg_decider (
    input  logic [8:0] instruction,
    input  logic [2:0] wr_reg_sel,
    output logic [3:0] wr_reg
);

    // 0. accumulator
    // 1. r7 (the immediate register)
    // 2. accumulator reference
    // 3. frame base register (register 13)
always_comb begin
  case (wr_reg_sel)
    0 : wr_reg = 4'hf;  // accumulator register
    1 : wr_reg = 4'h7;  // immediate register
    2 : wr_reg = 4'he;  // accumulator reference
    3 : wr_reg = 4'hd;  // frame base register
    4 : wr_reg = {1'b0, instruction[5:3]};  // instruction-encoded register (for move instruction)
    default : wr_reg = 4'hf;   // bad value
  endcase

end

endmodule

