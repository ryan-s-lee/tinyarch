module pc_blk (
    input clk,
    input enable,
    input reset,

    input  logic [ 1:0] jump_mode,
    input  logic cond_skip_enable,
    input  logic [15:0] skip_amount,
    input  logic [15:0] jump_addr,
    output logic [15:0] cur_instr_addr
);

  logic [15:0] next_instr_addr;

  always_comb begin
    case (jump_mode)
      2'b00: begin  // step instruction
        next_instr_addr = cur_instr_addr + 16'h1;
      end
      2'b01: begin  // nonzero skip/conditional skip
        next_instr_addr = cur_instr_addr + (|cond_skip_enable ? skip_amount : 16'h1);
      end
      2'b10: begin  // skip
        next_instr_addr = cur_instr_addr + skip_amount;
      end
      2'b11: begin  // jump
        next_instr_addr = jump_addr;
      end
      default:  // default to normal behavior
      next_instr_addr = cur_instr_addr + 16'h1;
    endcase

  end

  always_ff @(posedge clk) begin
    cur_instr_addr <= reset ? 16'h0000 : (enable ? next_instr_addr : cur_instr_addr);  // synchronous reset
    // cur_instr_addr <= reset ? 16'hffff : next_instr_addr;  // synchronous reset
  end


endmodule

