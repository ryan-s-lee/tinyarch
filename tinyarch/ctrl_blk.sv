module ctrl_blk (
    input logic [8:0] instr,
    input logic finished,

    output logic [1:0] jump_mode,
    output logic reg_wr_enable,
    output logic mem_wr_enable,
    output logic load_from_mem,
    output logic [3:0] operation,
    output logic op1_sel,
    output logic [1:0] op2_sel,
    output logic [1:0] reg1_sel,
    output logic reg2_sel,
    output logic [2:0] wr_reg_sel
);

  logic [2:0] unary_opcod;
  logic [3:0] binary_opcod;
  assign unary_opcod  = instr[2:0];
  assign binary_opcod = instr[6:3];

  always_comb begin

    jump_mode = 0;  // decides whether to step, skip, conditionally skip, or jump
    reg_wr_enable = 1;  // Decides whether to write to register file
    mem_wr_enable = 0;  // Decides whether to write to memory
    load_from_mem = 0;  // Decides whether to write memory-loaded addr to reg instead of alu
    operation = 0;  // decides alu operation

    // op2_sel values:
    // 0. reg2
    // 1. imm3
    // 2. imm5
    // 3. imm8
    op2_sel = 0;  // op2 is often reg2

    // op1_sel values:
    // 0. rx (the usual)
    // 1. instr[2:0] (instruction-encoded reg1, specifically for sti
    // isntruction sadge )
    op1_sel = 0;  // op1 is usually accumulator

    // reg1_sel values:
    // 0. accumulator
    // 1. frame base register (register 13)
    // 2. instr[5:3] (instruction-encoded reg1)
    reg1_sel = 2'b00;

    // reg2_sel values:
    // 0. instruction-encoded value. This is the usual case.
    // 1. accumulator. Used for ldi/sti.
    reg2_sel = 1'b0;

    // wr_reg_sel values:
    // 0. accumulator
    // 1. r7 (the immediate register)
    // 2. accumulator reference
    // 3. frame base register (register 13)
    wr_reg_sel = 0;  // write to accumulator
    casez (instr)
      'b0????????: begin  // move immediate
        operation = 4'b0101;  // op2 passthrough
        op2_sel = 2'b11;
        // don't care about register 1 lol
        wr_reg_sel = 2'b01;
      end
      'b100??????: begin  // move register
        operation = 4'b0101;  // select op2
        reg1_sel  = 2;  // use instruction-encoded reg1
        // op2_sel = 0 uses reg2 as alu input, which is what we want
        // reg_wr_enable is 1 by default, which triggers write
        wr_reg_sel = 4;  // write to instruction-encoded reg0
      end
      'b101??????: begin  // load/store immediate
        operation = 0;  // add, to add the immediate to frame base
        // let reg1 remain as the accumulator, to be passed as memory DataIn
        // for sti instructions
        reg2_sel = 1;  // select frame base to be reg2, for use in op2
        op1_sel = 1;  // use imm5, the lowest 5 bits in the instruction, as op1 in the addition
        // leave op2 as frame base register, to be added to the immediate to compute the data address
        load_from_mem = !instr[5];  // will be 1 if instruction is ldi
        reg_wr_enable = !instr[5];  // only write if instruction is ldi, not sti
        mem_wr_enable = instr[5] && !finished;  // will be 1 if sti
      end
      'b11???????: begin
        if (&instr[6:3]) begin  // unary operations
          operation = {1'b1, instr[2:0]};
          reg_wr_enable = unary_opcod < 4;
          // never write to memory, or load from it

          if (unary_opcod == 6) begin
            reg1_sel = 2;  // select bits 5-3 of the instruction, which produces register 7, used for jumping.
            jump_mode = 3;
          end
          // We exploit the opcode to select the registers we want to use for
          // jumps!
          // The last 6 bits are 111110 in a jmp instruction, specially chosen
          // so that the register file automatically retrieves those values for
          // use when jump_mode == 3. Wires can then just connect the retrieved
          // values to the jump select mux.

          // op2_sel is already set to reg2

          // wr_reg_sel is already accumulator, other instructions don't care
        end else begin  // binary operations
          operation = {1'b0, instr[6:4]};
          if (binary_opcod == 6) begin  // nonzero skip
            jump_mode = 1;
          end else if (binary_opcod == 8) begin  // unconditional skip
            jump_mode = 2;
          end

          reg_wr_enable = !(binary_opcod == 6 || binary_opcod == 8 || binary_opcod == 11);
          mem_wr_enable = binary_opcod == 11;
          load_from_mem = binary_opcod == 10;
          op2_sel = binary_opcod == 10 ? 0 : !binary_opcod[0];  // even encodes use imm3, odds use reg2
          // opcode 10 ("load") is the exception because there are more reg2's
          // than imm3s.
          // all instructions in this bracket either use accumulator as op1, or
          // don't care because they use set-op2 as the alu operation

          if (binary_opcod >= 12) begin
            // write to accumulator reference register (2) or frame base
            // register (3)
            wr_reg_sel = {1'b1, binary_opcod[0]};
          end
        end
      end
      default: begin
      end
    endcase
  end

endmodule
