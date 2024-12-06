// test bench for float to integer
// CSE141L	 version w/o rounding required
module flt2int_tb_noround();
  bit   clk = '0, 
        reset='1,
        req;
  wire  ack0,					 // from my dummy DUT
        ack;					 // from your DUT
  bit[15:0] flt_in = '0;
  logic sign;
  logic signed[5:0] exp;		 // de-biased exponent in
  logic[10:0] mant;              // significand in
  real int_equiv;                // computed value of integer 
  real mant2;					 // real equiv. of mant.
  logic signed[15:0] int_out;			 // two's comp. result
  int  score0, score1, 
       count;                   
  flt2int0 f2(.clk(clk),		 // my dummy DUT goes here
    .reset (reset),
    .start (req  ),
    .done  (ack0));				 
  tinyarch f3(.clk(clk),			 // your DUT goes here
    .reset (reset),
    .start (req  ),
    .done  (ack) );				 
  always begin
    #5ns clk = 1;
	#5ns clk = 0;
  end
  initial begin
//    $monitor(flt_in,,,int_out);
    #20ns reset = '0;
	flt_in = '0;
    disp;	                       // task call
	flt_in = 16'b0_01111_0000000000;
    disp;
//    flt_in = 16'b0_01111_1000000000;
//	disp;
//	flt_in = 16'b0_01111_0100000000;
//    disp;
//    flt_in = 16'b0_01111_1100000000;
//	disp;
    flt_in = 16'b0_10000_0000000000;
    disp;
    flt_in = 16'b0_10000_1000000000;
    disp;
//    flt_in = 16'b0_10000_1100000000;
//    disp;
//    flt_in = 16'b0_10000_1110000000;
//    disp;
    flt_in = 16'b0_10000_0001000000;
    disp;
    flt_in = 16'b0_10000_0001000000;
    disp;
//    flt_in = 16'b0_10000_0101000000;
//    disp;
//    flt_in = 16'b0_10000_0111000000;
//    disp;
	flt_in = 16'b0_10010_1100000000;
	disp;
	flt_in = 16'b0_10010_1110000000;
	disp;
	flt_in = 16'b0_11000_1100000000;
	disp;
	flt_in = 16'b0_11001_1100000000;
	disp;
	flt_in = 16'b0_11101_1110000000;
	disp;
	flt_in = 16'b0_11110_1110000000;
	disp;
	flt_in = 16'h8000;
    disp;	                       // task call
	flt_in = 16'b1_01111_0000000000;
    disp;
//    flt_in = 16'b1_01111_1000000000;
//	disp;
	flt_in = 16'b1_01111_0100000000;
    disp;
//    flt_in = 16'b1_01111_1100000000;
//	disp;
    flt_in = 16'b1_10000_0000000000;
    disp;
    flt_in = 16'b1_10000_1000000000;
    disp;
//    flt_in = 16'b1_10000_1100000000;
//    disp;
//    flt_in = 16'b1_10000_1110000000;
//    disp;
    flt_in = 16'b1_10000_0001000000;
    disp;
    flt_in = 16'b1_10000_0001000000;
    disp;
//    flt_in = 16'b1_10000_0101000000;
//    disp;
//    flt_in = 16'b1_10000_0111000000;
//    disp;
	flt_in = 16'b1_10010_1100000000;
	disp;
	flt_in = 16'b1_10010_1110000000;
	disp;
	flt_in = 16'b1_11000_1100000000;
	disp;
	flt_in = 16'b1_11001_1100000000;
	disp;
	flt_in = 16'b1_11101_1110000000;
	disp;
	flt_in = 16'b1_11110_1110000000;
	disp;
	#20ns $display("correct %d out of total %d",score0,count); 
		  $display("correct %d out of total %d",score1,count);
	$stop; 
  end
  task disp();
    $readmemb("p2.bin", f3.instr_mem.mem_core);
    #10ns req = '1;
    {f2.dm1.mem_core[5],f2.dm1.mem_core[4]} = flt_in;	 // inject flt_in to dat_mem
    {f3.data_mem1.mem_core[5],f3.data_mem1.mem_core[4]} = flt_in;	 //    same for your DUT
    #10ns req = '0;
    sign      = flt_in[15];
    exp       = flt_in[14:10]-15;	     // remove exponent bias      
    mant[10]  = |flt_in[14:10];	         // restore hidden bit
    mant[9:0] = flt_in[ 9: 0];	         // parse mantissa fraction
    mant2     = mant/1024.0;	         // equiv. floating point value of mant.
	#4000ns wait(ack0 || ack);
    if(exp>14) begin
      if(sign) int_out = -32768;         // max neg. trap        
      else     int_out =  32767;		 // max pos. trap
    end
    else begin
	int_equiv = mant2 * 2**exp;
	int_out   = sign? -int_equiv : int_equiv;
	end
    #20ns $display("%f * 2**%d = %f = %d",mant2,exp,int_equiv,int_out);
          $display("original binary = %b_%b_%b",flt_in[15],flt_in[14:10],flt_in[9:0]);
    #20ns $display("from dum = %b = %d",{f2.dm1.mem_core[7],f2.dm1.mem_core[6]},
        {f2.dm1.mem_core[7],f2.dm1.mem_core[6]});
    $display("from DUT = %b = %d",{f3.data_mem1.mem_core[7],f3.data_mem1.mem_core[6]},
        {f3.data_mem1.mem_core[7],f3.data_mem1.mem_core[6]});      
    count++;
	if({f3.data_mem1.mem_core[7],f3.data_mem1.mem_core[6]} == {f2.dm1.mem_core[7],f2.dm1.mem_core[6]}) score0++;
    if(int_out == {f3.data_mem1.mem_core[7],f3.data_mem1.mem_core[6]}) score1++;
	$display("                ct = %d, score0 = %d, score1 =  %d",count,score0,score1);
  endtask
endmodule

