module reg2_decider (
    input logic [8:0] instr,
    input logic reg2_sel,
    output logic [3:0] reg2
);

  always_comb begin
    case (reg2_sel)
      1'b0: begin  // instruction-encoded, as normal
        reg2 = {1'b0, instr[2:0]};
      end
      1'b1: begin  // force frame base, for sti
        reg2 = 4'hd;
      end
      default: begin  // bad state
        reg2 = {1'b0, instr[2:0]};
      end
    endcase
  end

endmodule

