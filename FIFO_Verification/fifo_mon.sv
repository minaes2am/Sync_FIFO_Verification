import shared_pkg::*;
import FIFO_transaction_pkg::*;
import FIFO_coverage_pkg::*;
import FIFO_scoreboard_pkg::*;
module fifo_monitor(fifo_if.MONITOR f_if);
    FIFO_transaction trans_mon = new(65,65);
    FIFO_coverage cover_mon = new();
    FIFO_scoreboard score_mon = new();
    initial begin
        forever begin
         wait(sample_event.triggered);
         @(negedge f_if.clk); 
         trans_mon.data_in = f_if.data_in;
         trans_mon.rst_n = f_if.rst_n;
         trans_mon.wr_en = f_if.wr_en;
         trans_mon.rd_en = f_if.rd_en;
         trans_mon.data_out = f_if.data_out;
         trans_mon.wr_ack = f_if.wr_ack;
         trans_mon.overflow = f_if.overflow;
         trans_mon.underflow = f_if.underflow;
         trans_mon.full = f_if.full;
         trans_mon.almostfull = f_if.almostfull;
         trans_mon.empty = f_if.empty;
         trans_mon.almostempty = f_if.almostempty;
        fork
          cover_mon.sample_data(trans_mon);  
          score_mon.check_data(trans_mon);
        join

        if (test_finished == 1'b1) begin
            $display("correct count =%d , error count =%d",correct_count,error_count);
            $stop;
        end
        
        end
    end
endmodule