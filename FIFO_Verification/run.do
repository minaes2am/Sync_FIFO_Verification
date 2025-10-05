vlib work
vlog *v  +define+SIM +cover  
vsim -voptargs=+acc top -sv_seed 261396889 -l sim.log -cover
run 0
add wave -position insertpoint  \
sim:/top/f_if/clk \
sim:/top/f_if/data_in \
sim:/top/f_if/rst_n \
sim:/top/f_if/wr_en \
sim:/top/f_if/rd_en \
sim:/top/f_if/data_out \
sim:/top/f_if/wr_ack \
sim:/top/f_if/overflow \
sim:/top/f_if/underflow \
sim:/top/f_if/full \
sim:/top/f_if/empty \
sim:/top/f_if/almostfull \
sim:/top/f_if/almostempty
coverage save top.ucdb -onexit
run -all