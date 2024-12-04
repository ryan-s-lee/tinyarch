module op2_decider (
    input logic [8:0] instr,
    input logic [7:0] reg2_value,
    input logic [1:0] op2_sel,

    output logic [7:0] op2
);

  // TODO: consider pipelining this operation
  // TODO: ensure that sign is NOT extended!
  always_comb begin
    case (op2_sel)
      2'b00: begin  // reg2
        op2 = reg2_value;
      end
      2'b01: begin  // imm3
        op2 = {5'b0, instr[2:0]};
        // if instructions are shift-immediate instructions (lsi or rsi), bias the shift by
        // 1 to get a shift between 1-8 instead of 0-7, since shifting by 0 is
        // useless.
        if (instr[8:3] == 6'b110100 || instr[8:3] == 6'b110010) begin  // yikes, big compare. Possibly change ISA to not bias shift immediates?
          op2 = op2 + 8'h1;
        end
      end
      2'b10: begin  // imm5
        op2 = {3'b0, instr[4:0]};
      end
      2'b11: begin  // imm8
        op2 = instr[7:0];
      end
      default: begin
        op2 = reg2_value;
      end
    endcase
  end

endmodule

