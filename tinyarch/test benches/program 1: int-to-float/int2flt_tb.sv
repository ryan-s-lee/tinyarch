// CSE141L   revised 2024.10.14
// testbench for integer to float conversion
// bench computes theoretical result
// bench holds your DUT and my dummy DUT
// (ideally, all three should agree :) )
// keyword bit is same as logic, except it self-initializes
//  to 0 and cannot take on x or z value
module int2flt_tb ();
  bit clk, reset = '1, req;
  wire ack,  // my dummy done flag
  ack2;  // your DUT's done flag
  bit   [15:0] int_in;  // incoming operand
  logic [15:0] int_out0;  // reconstructed integer from my reference
  logic [15:0] int_out;  // reconstructed integer from your floating point output
  logic [15:0] int_outM;  // reconstructed integer from mathetmical floating point conversion
  bit   [ 3:0] shift;  // for incoming data sizing
  logic [15:0]
      flt_out0,  // my design final result
      flt_out,  // your design final result
      flt_outM;  // mathematical final result
  int
      scoreM,  // your DUT vs. theory
      score0,  // your DUT vs. mine
      count = 0;  // number of trials

  int2flt0 f0 (  // my dummy DUT to generate right answer
      .clk  (clk),
      .start(req),
      .reset(reset),
      .done (ack0)
  );  //
  tinyarch f1 (  // your DUT goes here
      .clk  (clk),    // rename module & ports
      .start(req),    //  as necessary
      .reset(reset),  //
      .done (ack)
  );  // your ack is the one that counts

  always begin  // clock
    #5ns clk = '1;
    #5ns clk = '0;
  end

  initial begin  // test sequence
    #20ns reset = '0;
    disp2(int_in);  // subroutine call
    int_in = 16'd1;  // minimum nonzero positive
    disp2(int_in);
    int_in = 16'd2;  // start w/ contrived tests
    disp2(int_in);
    int_in = 16'd3;  //
    disp2(int_in);
    int_in = 16'd12;  //
    disp2(int_in);
    int_in = 16'd48;  //
    disp2(int_in);
    int_in = 16'd8191;  // qtr maximum positive
    disp2(int_in);
    int_in = 16'd16383;  // half maximum positive
    disp2(int_in);
    int_in = 16'd32767;  // maximum positive
    disp2(int_in);
    int_in = 16'd30767;  // near maximum positive
    disp2(int_in);
    int_in = -16'd1;  // minimum magnitude negative
    disp2(int_in);
    int_in = -16'd2;  // start w/ contrived tests
    disp2(int_in);
    int_in = -16'd3;  //
    disp2(int_in);
    int_in = -16'd12;  //
    disp2(int_in);
    int_in = -16'd48;  //
    disp2(int_in);
    int_in = -16'd8191;  // qtr maximum magnitude negative
    disp2(int_in);
    int_in = -16'd16383;  // half maximum magnitude negative
    disp2(int_in);
    int_in = -16'd32767;  // maximum magnitude negative
    disp2(int_in);
    int_in = -16'd30767;  // near maximum magnitude negative
    disp2(int_in);
    forever begin  // random tests
      //	  shift  = $random;
      int_in = $random;
      int_in = int_in >> shift;
      //	  int_in[15] = int_in[15] && !int_in[14:0]; // zero out extreme neg
      disp2(int_in);
      if (count > 70) begin
        #20ns $display("scores = %d %d out of %d", score0, scoreM, count);
        $stop;
      end
    end
  end

  task automatic disp2(input [15:0] int_in);  // subroutine for each operand value
    logic        sgn_M;  // mathemtaical answer sign
    logic [ 4:0] exp_M;  //                     exponent
    logic [11:0] mant_M;  //					  mantissa
    $readmemb("p1.bin", f1.instr_mem.mem_core);
    req                      = '1;
    f0.data_mem1.mem_core[1] = int_in[15:8];  // load operands into my memory
    f0.data_mem1.mem_core[0] = int_in[7:0];
    f1.data_mem1.mem_core[1] = int_in[15:8];  // load operands into your memory
    f1.data_mem1.mem_core[0] = int_in[7:0];
    sgn_M                    = int_in[15];  //
    //    flt_out_M[15]     = sgn_M;                 // sign is a passthrough
    #20ns req = '0;
    #4000ns wait (ack || ack0);  // whicheve ack comes first
    flt_out0 = {f0.data_mem1.mem_core[3], f0.data_mem1.mem_core[2]};  // results from my dummy DUT
    flt_out  = {f1.data_mem1.mem_core[3], f1.data_mem1.mem_core[2]};  // results from your memory
    $display("what's feeding the case %b", int_in);
    exp_M  = '0;  // initial point -- override as needed
    mant_M = '0;
    if (!int_in[14:0]) begin  // trap 0 or max neg
      if (sgn_M) exp_M = 'd30;
      mant_M = '0;
    end else begin
      if (sgn_M) int_in = ~int_in + 1;  // negatives
      casez (int_in[14:0])  // normalization
        15'b1??_????_????_????: begin
          exp_M  = 29;
          mant_M = int_in[14:4];
          if (int_in[4] || (|int_in[2:0])) mant_M = mant_M + int_in[3];
          if (mant_M[11]) begin
            exp_M++;
            mant_M = mant_M >> 1;
          end
        end
        15'b01?_????_????_????: begin
          exp_M  = 28;
          mant_M = int_in[13:3];
          if (int_in[3] || (|int_in[1:0])) mant_M = mant_M + int_in[2];
          if (mant_M[11]) begin
            exp_M++;
            mant_M = mant_M >> 1;
          end
        end
        15'b001_????_????_????: begin
          exp_M  = 27;
          mant_M = int_in[12:2];
          if (int_in[2] || (int_in[0])) mant_M = mant_M + int_in[1];
          if (mant_M[11]) begin
            exp_M++;
            mant_M = mant_M >> 1;
          end
        end
        15'b000_1???_????_????: begin
          exp_M  = 26;
          mant_M = int_in[11:1];
          if (int_in[1]) mant_M = mant_M + int_in[0];
          if (mant_M[11]) begin
            exp_M++;
            mant_M = mant_M >> 1;
          end
        end
        15'b000_01??_????_????: begin
          exp_M  = 25;
          mant_M = int_in[10:0];
        end
        15'b000_001?_????_????: begin
          exp_M  = 24;
          mant_M = {int_in[9:0], 1'b0};
        end
        15'b000_0001_????_????: begin
          exp_M  = 23;
          mant_M = {int_in[8:0], 2'b0};
        end
        15'b000_0000_1???_????: begin
          exp_M  = 22;
          mant_M = {int_in[7:0], 3'b0};
        end
        15'b000_0000_01??_????: begin
          exp_M  = 21;
          mant_M = {int_in[6:0], 4'b0};
        end
        15'b000_0000_001?_????: begin
          exp_M  = 20;
          mant_M = {int_in[5:0], 5'b0};
        end
        15'b000_0000_0001_????: begin
          exp_M  = 19;
          mant_M = {int_in[4:0], 6'b0};
        end
        15'b000_0000_0000_1???: begin
          exp_M  = 18;
          mant_M = {int_in[3:0], 7'b0};
        end
        15'b000_0000_0000_01??: begin
          exp_M  = 17;
          mant_M = {int_in[2:0], 8'b0};
        end
        15'b000_0000_0000_001?: begin
          exp_M  = 16;
          mant_M = {int_in[1:0], 9'b0};
        end
        15'b000_0000_0000_0001: begin
          exp_M  = 15;
          mant_M = 11'b100_0000_0000;
        end
      endcase
    end
    if (exp_M == 0) begin  // no hidden; force exp = 0
      $display("flt_out_M = %d = %f * 2**%d flt_out_dummy = %b %d %b", int_in,
               real'((mant_M / 1024.0)), exp_M, flt_out0[15], flt_out0[14:10], flt_out0[9:0]);
      $display("flt_out_M = %b_%b_%b, flt_out_you = %b_%b_%b", sgn_M, exp_M, mant_M, flt_out[15],
               flt_out[14:10], flt_out[9:0]);
      if ((exp_M == flt_out[14:10]) && (mant_M == flt_out[9:0])) scoreM++;
      if (flt_out == flt_out0) score0++;
    end else begin  // normal, non-underflow
      $display("flt_out_M = %d = %f * 2**%d flt_out0=%b %d %b", int_in, real'(mant_M / 1024.0),
               exp_M, flt_out0[15], flt_out0[14:10], flt_out0[9:0]);
      $display("flt_out_M = %b_%b_%b, flt_out = %b_%b_%b", flt_out[15], flt_out[14:10],
               flt_out[9:0], flt_out[15], flt_out[14:10], flt_out[9:0]);
      $display("%d = %f * 2**%d flt_out=%b %d 1.%b", int_in, real'(mant_M / 1024.0), exp_M - 15,
               flt_out[15], flt_out[14:10] - 15, flt_out[9:0]);
      $display("flt_out0=%b_%b_%b, flt_out = %b_%b_%b", flt_out0[15], flt_out0[14:10],
               flt_out0[9:0], flt_out[15], flt_out[14:10], flt_out[9:0]);
      if ((exp_M[4:0] == flt_out[14:10]) && (mant_M[9:0] == flt_out[9:0])) scoreM++;
      if (flt_out == flt_out0) score0++;
    end
    count++;
    $display("scores: you vs. me = %d, you vs. math %d, out of %d", score0, scoreM, count);
    $display();
  endtask
endmodule

