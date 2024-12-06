module alu (
    input logic clk,
    input logic rst,

    input logic [7:0] op1,
    input logic [7:0] op2,
    input logic [3:0] operation,

    output logic [7:0] result,
    output logic exit
);

  logic [15:0] shift_buffer;
  logic last_shift_dir;  // 0 is left, 1 is right
  logic [7:0] last_shift_amount;

  logic [39:0] shift_value;
  logic shifting_overflow;
  logic [7:0] shift_amount;
  logic shift_dir;
  logic [39:0] shift_result;

  logic [8:0] carry_add_result;
  logic carry_bit;
  logic [8:0] normal_add_result;

  // shift stuff
  assign shifting_overflow = operation[3];
  assign shift_value[39:24] = (shifting_overflow && shift_dir) ? shift_buffer : 16'd0;
  assign shift_value[23:16] = op1;
  assign shift_value[15:0] = (shifting_overflow && !shift_dir) ? shift_buffer : 16'd0;
  assign shift_amount = shifting_overflow ? last_shift_amount : op2;
  assign shift_dir = shifting_overflow ? last_shift_dir : operation[0];
  assign shift_result = shift_dir ? shift_value >> shift_amount : shift_value << shift_amount;

  // carry tuff
  assign normal_add_result = {1'b0, op1} + {1'b0, op2};
  assign carry_add_result = {1'b0, op1} + {8'b0, carry_bit};

  always_ff @(posedge clk) begin
    case (operation)
      0: begin  // add
        carry_bit <= normal_add_result[8];
      end
      1: begin  // rshift
        shift_buffer <= shift_result[15:0] >> (16 - shift_amount);
        last_shift_dir <= 1;
        last_shift_amount <= op2;
      end
      2: begin  // lshift
        shift_buffer <= shift_result[39:24] << (16 - shift_amount);
        last_shift_dir <= 0;
        last_shift_amount <= op2;
      end
      10: begin  // sho
        shift_buffer <= shift_dir ? (shift_result[15:0] >> (16 - shift_amount)) : (shift_result[39:24] << (16 - shift_amount));
      end
      11: begin  // add carry
        carry_bit <= carry_add_result[8];
      end
      default:begin end  // do nothing
      // 13 is no op, don't care.
      // 14 is jump, implemented elsewhere
      // 15 is empty
    endcase
  end

  always_comb begin
    exit = 0;
    case (operation)
      0: begin  // add
        result = normal_add_result[7:0];
      end
      1: begin  // rshift
        result = shift_result[23:16];
      end
      2: begin  // lshift
        result = shift_result[23:16];
      end
      3: begin  // bitwise or
        result = op1 | op2;
      end
      4: begin  // bitwise and
        result = op1 & op2;
      end
      5, 6: begin  // select op2
        result = op2;
      end
      // 7 is empty
      8: begin  // bitwise negation
        result = ~op1;
      end
      9: begin  // logical negation
        result = !op1;
      end
      10: begin  // sho
        result = shift_result[23:16];
      end
      11: begin  // add carry
        result = carry_add_result[7:0];
      end
      12 : begin  // exit
        result = 0;
        exit = 1;
      end
      default: result = 0;
      // 13 is no op, don't care.
      // 14 is jump, implemented elsewhere
      // 15 is empty
    endcase
  end
endmodule

