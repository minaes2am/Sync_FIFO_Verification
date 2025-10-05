import shared_pkg::*;
import FIFO_transaction_pkg::*;
module fifo_tb(fifo_if.TEST f_if);
  FIFO_transaction tr = new(75,75);
  initial begin
    f_if.wr_en = 0; f_if.rd_en = 0;
    f_if.data_in = 16'h0000;
    //FIFO_5
    assert_reset;
    for (int i=0;i<15000;i++) begin
      //FIFO_6
        assert(tr.randomize());
        f_if.rst_n = tr.rst_n;
        f_if.data_in = tr.data_in;
        f_if.wr_en = tr.wr_en;
        f_if.rd_en = tr.rd_en;
        @(negedge f_if.clk);
        //FIFO_7
        -> sample_event;
    end
    test_finished = 1;
  end

task assert_reset;
    f_if.rst_n = 0;
    @(negedge f_if.clk);
    f_if.rst_n = 1;
    @(negedge f_if.clk);
endtask
endmodule