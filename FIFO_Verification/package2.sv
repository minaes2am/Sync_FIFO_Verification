package FIFO_coverage_pkg;
import shared_pkg::*;
import FIFO_transaction_pkg::*;
 FIFO_transaction F_cvg_txn = new(70,70);

 class FIFO_coverage;
     //FIFO_4
    covergroup cvr_gp;
      cp_wr_en    : coverpoint F_cvg_txn.wr_en;
      cp_rd_en    : coverpoint F_cvg_txn.rd_en;
      cp_full        : coverpoint F_cvg_txn.full;
      cp_empty       : coverpoint F_cvg_txn.empty;
      cp_almostfull  : coverpoint F_cvg_txn.almostfull;
      cp_almostempty : coverpoint F_cvg_txn.almostempty;
      cp_overflow    : coverpoint F_cvg_txn.overflow;
      cp_underflow   : coverpoint F_cvg_txn.underflow;
      cp_wr_ack      : coverpoint F_cvg_txn.wr_ack;

      wr_ack_C: cross cp_wr_en, cp_rd_en, cp_wr_ack{
        illegal_bins zero_zero_one = binsof(cp_wr_en) intersect {0} && binsof(cp_wr_ack) intersect {1}; 
        } 
      overflow_C: cross cp_wr_en, cp_rd_en, cp_overflow{
                illegal_bins zero_w_one = binsof(cp_wr_en) intersect {0} && binsof(cp_overflow) intersect {1}; 
        } 
      full_C: cross cp_wr_en, cp_rd_en, cp_full{
                illegal_bins one_r_one = binsof(cp_rd_en) intersect {1} && binsof(cp_full) intersect {1}; 
        } 
      empty_C: cross cp_wr_en, cp_rd_en, cp_empty;
      almostfull_C: cross cp_wr_en, cp_rd_en, cp_almostfull; 
      almostempty_C: cross cp_wr_en, cp_rd_en, cp_almostempty; 
      underflow_C: cross cp_wr_en, cp_rd_en, cp_underflow{
                illegal_bins zero_r_one = binsof(cp_rd_en) intersect {0} && binsof(cp_underflow) intersect {1};
        }
    endgroup

    function void sample_data(FIFO_transaction F_txn);
      cvr_gp.sample();
      F_cvg_txn = F_txn;
    endfunction

    function new();
      cvr_gp = new();
    endfunction

 endclass
endpackage
