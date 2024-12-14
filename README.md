# How 2 Test



## Modifications to Test Benches

I include my test benches in my submission, for reference, but you're free to use your
own if you add these modifications. 

* I think I formatted some test benches using Verilator, because ya'll's formatting is
  ugly. This should not affect the testbench at all.
* in 'tinyarch/test benches', I used `int2flt_tb_noround.sv`, `flt2int_tb.sv`, and
  `fltflt_no_rnd_tb.sv` as the testbenches. I decided to fill the instruction memory
  within the test benches rather than inside the instruction memory itself. This way,
  testers don't have to look in the instruction memory module and change the file
  to use as the instruction memory every single time you run a different test bench.
  Also, I use the same `data_mem.sv` module for instruction memory AND data memory.
  Therefore, you'll find a `$readmemb` call inside each of these test benches. I placed
  it within the test case function (`disp`, `disp2` or `flt_add`), but filling in the
  instruction memory a single time before all the tests should work as well.
* I use a slightly modified `data_mem.sv` module from the `data_mem.sv` modules
  provided in the test benches. The main difference is that I made the address
  width and the data width to be modifiable parameters. This makes it easy to
  use as both data memory (by setting addr and data width to 8) and instruction 
  memory (by setting addr width to 12, or 16; and setting data width to 9).
  Because the module names clashed, but the functionality is the same, I used my
  own testbench instead of the provided `data_mem.sv` modules in the test benches.
* I think all of the test benches start their count of the number of tests previously
  run at -1, but the scores start at 0. This means that the final score will typically be something like
  "passed 19 out of 18 tests". I believe for the program 1 test bench, I modified
  the count to start at 0, so that the number of passed tests would be less than or
  equal to the number of tests total. I didn't bother for the other benches though.
* In the original flt addition test bench, the request bit was not being set to 1
  before the first
  test, causing my architecture to never run or ack and thus cause the emergency 
  interrupt to trigger. So I added a line to the testbench along the lines of
  `req = 1'b1` to remedy this.



## Actually Running Tests

1. Go to the `asm/` directory and run `make p1 p2 p3`. Each target corresponds to
   the compiling of 1 program into a `px.bin` file. Each target will also produce 
   a preprocessed version of the code called `px.txt`. Finally, it will attempt
   to copy the file into the modelsim run directory. This may fail if you have not
   run Modelsim yet, and the directory hasn't been created. Ignore for now, we'll
   rectify this later.
2. Load the `tinyarch/` directory as a project in Quartus. Add all of its .sv files.
3. Open Quartus and add test benches. In particular, the test benches should not
   include the `data_mem.sv` inside of each individual program's directory, or a
   naming conflict will occur.
4. In each testbench `initial begin` code, make sure 
   `$readmemb("px.bin", t1.instr_mem.mem_core)` is called before any 
   tests are run.
5. Run the tests. They may or may not fail, but the modelsim directories should
   be created.
6. If the tests failed, go back to the asm directories and run `make p1 p2 p3` again.
   Then run the tests again, and they should work.



## Fin

If the test benches don't run for some reason, contact me at rsl001@ucsd.edu. I'll
help debug (my grade depends on it).
