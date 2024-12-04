onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group tinyarch /int2flt_tbA/clk
add wave -noupdate -expand -group tinyarch /int2flt_tbA/reset
add wave -noupdate -expand -group tinyarch /int2flt_tbA/req
add wave -noupdate -expand -group tinyarch /int2flt_tbA/ack
add wave -noupdate -expand -group tinyarch /int2flt_tbA/ack2
add wave -noupdate -expand -group tinyarch /int2flt_tbA/int_in
add wave -noupdate -expand -group tinyarch /int2flt_tbA/shift
add wave -noupdate -expand -group tinyarch /int2flt_tbA/flt_out2
add wave -noupdate -expand -group tinyarch /int2flt_tbA/flt_out3
add wave -noupdate -expand -group tinyarch /int2flt_tbA/flt_out_dut
add wave -noupdate -expand -group tinyarch /int2flt_tbA/score1
add wave -noupdate -expand -group tinyarch /int2flt_tbA/score2
add wave -noupdate -expand -group tinyarch /int2flt_tbA/count
add wave -noupdate -expand -group tinyarch /int2flt_tbA/ack0
add wave -noupdate -expand -group reg_file /int2flt_tbA/f3/reg_file/clk
add wave -noupdate -expand -group reg_file /int2flt_tbA/f3/reg_file/rx
add wave -noupdate -expand -group reg_file /int2flt_tbA/f3/reg_file/ry
add wave -noupdate -expand -group reg_file /int2flt_tbA/f3/reg_file/wr_reg
add wave -noupdate -expand -group reg_file /int2flt_tbA/f3/reg_file/wr_value
add wave -noupdate -expand -group reg_file /int2flt_tbA/f3/reg_file/wr_enable
add wave -noupdate -expand -group reg_file /int2flt_tbA/f3/reg_file/rx_value
add wave -noupdate -expand -group reg_file /int2flt_tbA/f3/reg_file/ry_value
add wave -noupdate -expand -group reg_file /int2flt_tbA/f3/reg_file/rx_real
add wave -noupdate -expand -group reg_file /int2flt_tbA/f3/reg_file/ry_real
add wave -noupdate -expand -group reg_file /int2flt_tbA/f3/reg_file/wr_reg_real
add wave -noupdate -expand -group pc_blk /int2flt_tbA/f3/pc_blk/clk
add wave -noupdate -expand -group pc_blk /int2flt_tbA/f3/pc_blk/enable
add wave -noupdate -expand -group pc_blk /int2flt_tbA/f3/pc_blk/reset
add wave -noupdate -expand -group pc_blk /int2flt_tbA/f3/pc_blk/jump_mode
add wave -noupdate -expand -group pc_blk /int2flt_tbA/f3/pc_blk/cond_skip_enable
add wave -noupdate -expand -group pc_blk /int2flt_tbA/f3/pc_blk/skip_amount
add wave -noupdate -expand -group pc_blk /int2flt_tbA/f3/pc_blk/jump_addr
add wave -noupdate -expand -group pc_blk -radix unsigned /int2flt_tbA/f3/pc_blk/cur_instr_addr
add wave -noupdate -expand -group pc_blk /int2flt_tbA/f3/pc_blk/next_instr_addr
add wave -noupdate -expand -group ctrl_blk /int2flt_tbA/f3/ctrl_blk/instr
add wave -noupdate -expand -group ctrl_blk /int2flt_tbA/f3/ctrl_blk/finished
add wave -noupdate -expand -group ctrl_blk /int2flt_tbA/f3/ctrl_blk/jump_mode
add wave -noupdate -expand -group ctrl_blk /int2flt_tbA/f3/ctrl_blk/reg_wr_enable
add wave -noupdate -expand -group ctrl_blk /int2flt_tbA/f3/ctrl_blk/mem_wr_enable
add wave -noupdate -expand -group ctrl_blk /int2flt_tbA/f3/ctrl_blk/load_from_mem
add wave -noupdate -expand -group ctrl_blk /int2flt_tbA/f3/ctrl_blk/operation
add wave -noupdate -expand -group ctrl_blk /int2flt_tbA/f3/ctrl_blk/op2_sel
add wave -noupdate -expand -group ctrl_blk /int2flt_tbA/f3/ctrl_blk/reg1_sel
add wave -noupdate -expand -group ctrl_blk /int2flt_tbA/f3/ctrl_blk/wr_reg_sel
add wave -noupdate -expand -group ctrl_blk /int2flt_tbA/f3/ctrl_blk/unary_opcod
add wave -noupdate -expand -group ctrl_blk /int2flt_tbA/f3/ctrl_blk/binary_opcod
add wave -noupdate -expand -group data_mem /int2flt_tbA/f3/data_mem1/CLK
add wave -noupdate -expand -group data_mem -radix unsigned /int2flt_tbA/f3/data_mem1/DataAddress
add wave -noupdate -expand -group data_mem /int2flt_tbA/f3/data_mem1/ReadMem
add wave -noupdate -expand -group data_mem /int2flt_tbA/f3/data_mem1/WriteMem
add wave -noupdate -expand -group data_mem /int2flt_tbA/f3/data_mem1/DataIn
add wave -noupdate -expand -group data_mem /int2flt_tbA/f3/data_mem1/DataOut
add wave -noupdate -expand -group alu /int2flt_tbA/f3/alu/clk
add wave -noupdate -expand -group alu /int2flt_tbA/f3/alu/rst
add wave -noupdate -expand -group alu /int2flt_tbA/f3/alu/op1
add wave -noupdate -expand -group alu /int2flt_tbA/f3/alu/op2
add wave -noupdate -expand -group alu /int2flt_tbA/f3/alu/operation
add wave -noupdate -expand -group alu /int2flt_tbA/f3/alu/result
add wave -noupdate -expand -group alu /int2flt_tbA/f3/alu/exit
add wave -noupdate -expand -group alu /int2flt_tbA/f3/alu/shift_buffer
add wave -noupdate -expand -group alu /int2flt_tbA/f3/alu/last_shift_dir
add wave -noupdate -expand -group alu /int2flt_tbA/f3/alu/last_shift_amount
add wave -noupdate -expand -group alu /int2flt_tbA/f3/alu/shift_value
add wave -noupdate -expand -group alu /int2flt_tbA/f3/alu/shifting_overflow
add wave -noupdate -expand -group alu /int2flt_tbA/f3/alu/shift_amount
add wave -noupdate -expand -group alu /int2flt_tbA/f3/alu/shift_dir
add wave -noupdate -expand -group alu /int2flt_tbA/f3/alu/shift_result
add wave -noupdate -expand -group alu /int2flt_tbA/f3/alu/carry_add_result
add wave -noupdate -expand -group alu /int2flt_tbA/f3/alu/carry_bit
add wave -noupdate -expand -group alu /int2flt_tbA/f3/alu/normal_add_result
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {852931 ps} 0} {{Cursor 2} {426779 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {398256 ps} {625603 ps}
view wave 
wave clipboard store
wave create -pattern none -portmode input -language vlog /reg_file/clk 
wave create -pattern none -portmode input -language vlog -range 3 0 /reg_file/rx 
wave create -pattern none -portmode input -language vlog -range 3 0 /reg_file/ry 
wave create -pattern none -portmode input -language vlog -range 3 0 /reg_file/wr_reg 
wave create -pattern none -portmode input -language vlog -range 7 0 /reg_file/wr_value 
wave create -pattern none -portmode input -language vlog /reg_file/wr_enable 
wave create -pattern none -portmode output -language vlog -range 7 0 /reg_file/rx_value 
wave create -pattern none -portmode output -language vlog -range 7 0 /reg_file/ry_value 
WaveCollapseAll -1
wave clipboard restore
