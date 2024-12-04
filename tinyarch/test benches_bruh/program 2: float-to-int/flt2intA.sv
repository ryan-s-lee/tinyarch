// behavioral model of float to integer converter
// not intended to be synthesizable -- just shows the algorithm
// CSE141L  
module flt2int0(					 // my dummy placeholder for your design
  input              clk, 
                     reset, 
                     req,        //	request from test bench
  output logic       ack);		 // acknowledge back to test bench

logic[15:0] flt_in,				 // incoming floating point value
            int_out;			 // outgoing interger equivalent
logic[ 4:0] exp;	             // incoming exponent
logic[41:0] int_frac;            // internal fixed point
// 32 shift positions, 11 bit mantissa, so 31+11=42
logic       sign,
            req_q;				 // request delayed 1 cycle
logic[ 7:0] ctr;				 // cycle counter
// memory core
logic[ 7:0] dm_out, dm_in, dm_addr;

data_mem dm1(.CLK(clk), .ReadMem('1), .WriteMem('0), 
  .DataOut(dm_out), .DataIn(dm_in), .DataAddress(dm_addr));

always @(posedge clk) begin
  if(reset)	begin
    req_q   <= '0;
	ctr     <= '0;
  end
  else begin
    req_q   <= req;
    ctr     <= ctr + 'b1;		 // count clock cycles
  end   
end

// we'll ignore the sign bit and solve for magnitudes first
// negatives require a final sign-mag to two's comp conversion, below
// slight cheat: I am limiting negatives to 16'h81, rather than 16'h80
always begin
  wait(req_q && !req)
  flt_in   = {dm1.mem_core[4],dm1.mem_core[5]};
  sign     = flt_in[15];
  exp      = flt_in[14:10];
  int_frac = {31'b0,|flt_in[14:10],flt_in[ 9: 0]};
  int_frac = int_frac<<exp;
  int_out  = int_frac[39:25];    // exp bias = 15; 10 bits of fraction
  case({int_frac[25:24],|int_frac[23:0]})	 // round to nearest even
	3'b011: int_out++;
	3'b110:	int_out++;
	3'b111:	int_out++;
  endcase
// limit overflow to max. positive
  if(int_frac[41:40]) int_frac[39:25] = 15'h7fff;
  if(sign)		                  // negative result -- take two's comp.
    {dm1.mem_core[6],dm1.mem_core[7]} = ~int_out + 'b1;
  else 
    {dm1.mem_core[6],dm1.mem_core[7]} = int_out;
  #210ns ack = '1;				 // send ack pulse to test bench
  #20ns ack = '0;
end

endmodule