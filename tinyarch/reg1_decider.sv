module reg1_decider (
    input logic [1:0] reg1_sel,
    input logic [8:0] instr,

    output logic [3:0] reg1
);

    // reg1_sel values:
    // 0. accumulator
    // 1. frame base register (register 13)
    // 2. instr[5:3] (instruction-encoded reg1)
  always_comb begin
    case (reg1_sel)
      0: begin  // accumulator
        reg1 = 4'hf;
      end
      1: begin  // frame base register
        reg1 = 4'hd;
      end
      2: begin  // instruction-encoded reg
        reg1 = {1'b0, instr[5:3]};
      end
      default:  // bad state, default to accumulator?
      // TODO: add crash logic
      reg1 = 4'd15;
    endcase
  end

endmodule
