module reg_file #(
    parameter integer REG_ADDR_WIDTH = 4,
    parameter integer REG_WIDTH = 8
) (
    input clk,

    input logic [REG_ADDR_WIDTH - 1:0] rx,
    input logic [REG_ADDR_WIDTH - 1:0] ry,
    input logic [REG_ADDR_WIDTH - 1:0] wr_reg,
    input logic [REG_WIDTH - 1:0] wr_value,
    input logic wr_enable,

    output logic [REG_WIDTH - 1:0] rx_value,
    output logic [REG_WIDTH - 1:0] ry_value
);

  logic [REG_WIDTH - 1:0] reg_core[2 ** REG_ADDR_WIDTH];

  // register select logic
  // addressing register 15 really means address accumulator, which is the
  // value stored in reg_core[14].
  logic [3:0] rx_real;
  assign rx_real = (rx == 15) ? reg_core[14] : rx;
  logic [3:0] ry_real;
  assign ry_real = (ry == 15) ? reg_core[14] : ry;
  logic [3:0] wr_reg_real;
  assign wr_reg_real = (wr_reg == 15) ? reg_core[14] : wr_reg;

  always_comb begin
    rx_value = reg_core[rx_real];
    ry_value = reg_core[ry_real];
  end

  always_ff @(posedge clk) begin
    if (wr_enable) begin
      reg_core[wr_reg_real] <= wr_value;
    end
  end

endmodule

