module top_module();
    bit clk;
    initial begin
        clk = 0;
        forever begin
            #1 clk=~clk;
        end
    end
    fifo_if f_if (clk);
    FIFO DUT (f_if);
    fifo_tb TEST (f_if);
    fifo_monitor MONITOR (f_if);

    always_comb begin
     if(!f_if.rst_n) begin
     wr_ack_rst: assert final(f_if.wr_ack == 0);
      overflow_rst: assert final(f_if.overflow == 0);
      empty_rst: assert final(f_if.empty == 1);
      underflow_rst: assert final(f_if.underflow == 0);
      almostfull_rst: assert final(f_if.almostfull == 0);
      almostempty_rst: assert final(f_if.almostempty == 0);
      full_rst: assert final(f_if.full == 0);
      wr_ack_rst_c: cover final(f_if.wr_ack == 0);
      overflow_rst_c: cover final(f_if.overflow == 0);
      empty_rst_c: cover final(f_if.empty == 1);
      underflow_rst_c: cover final(f_if.underflow == 0);
      almostfull_rst_c: cover final(f_if.almostfull == 0);
      almostempty_rst_c: cover final(f_if.almostempty == 0);
      full_rst_c: cover final(f_if.full == 0);
	 end
    end

endmodule