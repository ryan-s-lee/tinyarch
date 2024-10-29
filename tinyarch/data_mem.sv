module data_mem #(
    parameter integer BUS_WIDTH  = 8,
    parameter integer DATA_WIDTH = 8
) (
    input logic         CLK,          // wires for all DataMem ports
    input logic [8-1:0] DataAddress,  // in your model you would connect thes
    input logic         ReadMem,      //  to other blocks/modules
    input logic         WriteMem,
    input logic [  7:0] DataIn,

    output logic [7:0] DataOut

);

  logic [DATA_WIDTH - 1:0] mem_core[2 ** BUS_WIDTH];

  always_ff @(posedge CLK) begin
    if (WriteMem) begin
      mem_core[DataAddress] <= DataIn;
    end
    if (ReadMem) begin
      DataOut <= mem_core[DataAddress];
    end
  end

endmodule
