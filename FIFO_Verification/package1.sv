package FIFO_transaction_pkg;
import shared_pkg::*;
parameter FIFO_WIDTH = 16;
parameter FIFO_DEPTH = 8;
class FIFO_transaction;
  rand bit [FIFO_WIDTH-1:0] data_in;
  bit clk;
  rand bit rst_n;
  rand bit wr_en;
  rand bit rd_en;
  bit [FIFO_WIDTH-1:0] data_out;
  bit wr_ack, overflow, underflow;
  bit full, empty, almostfull, almostempty;
  integer RD_EN_ON_DIST , WR_EN_ON_DIST;

  function new(int rd_dist = 30, int wr_dist = 70);
    this.RD_EN_ON_DIST = rd_dist;
    this.WR_EN_ON_DIST = wr_dist;
  endfunction
  //FIFO_1
  constraint rst_dist
  {
    rst_n dist {0:/5 , 1:/95};
  }
  //FIFO_2
  constraint wr_en_dist 
  {
    wr_en dist { 0:/(100 - WR_EN_ON_DIST) , 1:/WR_EN_ON_DIST};
  }
  //FIFO_3
  constraint rd_en_c 
  {
    rd_en dist { 0:/(100 - RD_EN_ON_DIST) , 1:/RD_EN_ON_DIST };
  }
endclass
    
endpackage
