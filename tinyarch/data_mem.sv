module data_mem #(
    parameter integer ADDR_WIDTH  = 8,
    parameter integer DATA_WIDTH = 8
) (
    input logic                    clk,          // wires for all DataMem ports
    input logic [ADDR_WIDTH - 1:0] DataAddress,  // in your model you would connect these
    input logic                    ReadMem,      //  to other blocks/modules
    input logic                    WriteMem,
    input logic [DATA_WIDTH - 1:0] DataIn,

    output logic [DATA_WIDTH - 1:0] DataOut

);

  logic [DATA_WIDTH - 1:0] mem_core[2 ** ADDR_WIDTH];

  always_ff @(posedge clk) begin
    if (WriteMem) begin
      mem_core[DataAddress] <= DataIn;
    end
  end

  assign DataOut = mem_core[DataAddress];

endmodule
