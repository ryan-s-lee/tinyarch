module op1_decider (
    input logic [8:0] instr,
    input logic[7:0] reg1_value,
    input logic op1_sel,

    output logic [7:0] op1
);

    // op1_sel values:
    // 0. rx
    // 1. instr[2:0] (imm3)
  always_comb begin
    case (op1_sel)
      0: begin  // rx
        op1 = reg1_value;
      end
      1: begin  // imm5
        op1 = {3'b0, instr[4:0]};
      end
      default:  // bad state, default to accumulator?
      // TODO: add crash logic
      op1 = 4'hf;
    endcase
  end

endmodule
