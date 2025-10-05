vlib work
vlog *v +define+SIM +cover
vsim -voptargs=+acc top_module -cover
run 0
add wave *
add wave -position insertpoint  \
sim:/top_module/f_if/clk \
sim:/top_module/f_if/data_in \
sim:/top_module/f_if/rst_n \
sim:/top_module/f_if/wr_en \
sim:/top_module/f_if/rd_en \
sim:/top_module/f_if/data_out \
sim:/top_module/f_if/wr_ack \
sim:/top_module/f_if/overflow \
sim:/top_module/f_if/underflow \
sim:/top_module/f_if/full \
sim:/top_module/f_if/empty \
sim:/top_module/f_if/almostfull \
sim:/top_module/f_if/almostempty
add wave -position insertpoint  \
sim:/shared_pkg::correct_count \
sim:/shared_pkg::error_count \
sim:/shared_pkg::test_finished
coverage save top_module.ucdb -onexit -du FIFO
run -all